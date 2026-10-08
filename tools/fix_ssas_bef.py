"""Apply the b/e/f dimension fixes to the local SSAS project, with backups."""
from copy import deepcopy
from datetime import datetime
from pathlib import Path
import hashlib
import json
import re
import shutil
import uuid

from lxml import etree as ET

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "SSAS" / "SSAS"
NS = "http://schemas.microsoft.com/analysisservices/2003/engine"
DWD = "http://schemas.microsoft.com/DataWarehouse/Designer/1.0"
N = {"a": NS}


def tag(name):
    return f"{{{NS}}}{name}"


def attributes(root):
    return {a.findtext("a:ID", namespaces=N): a
            for a in root.findall("a:Attributes/a:Attribute", N)}


def keys(attribute, columns):
    container = attribute.find("a:KeyColumns", N)
    by_column = {k.findtext("a:Source/a:ColumnID", namespaces=N): k
                 for k in container}
    wanted = [by_column[c] for c in columns]
    for child in list(container):
        container.remove(child)
    container.extend(wanted)
    wanted[-1].tail = "\n      "


def relationships(attribute, related):
    current = attribute.find("a:AttributeRelationships", N)
    old = {} if current is None else {
        r.findtext("a:AttributeID", namespaces=N): r for r in current}
    if current is not None:
        position = list(attribute).index(current)
        attribute.remove(current)
    else:
        name_column = attribute.find("a:NameColumn", N)
        anchor = name_column if name_column is not None else attribute.find("a:KeyColumns", N)
        position = list(attribute).index(anchor) + 1
    if not related:
        return
    container = ET.Element(tag("AttributeRelationships"))
    for name in related:
        relationship = old.get(name)
        if relationship is None:
            relationship = ET.Element(tag("AttributeRelationship"))
            relationship.set(f"{{{DWD}}}design-time-name", str(uuid.uuid4()))
            ET.SubElement(relationship, tag("AttributeID")).text = name
            ET.SubElement(relationship, tag("Name")).text = name
        container.append(relationship)
    ET.indent(container, space="  ", level=3)
    container.tail = "\n      "
    attribute.insert(position, container)


def fresh_design_ids(element):
    for e in element.iter():
        if f"{{{DWD}}}design-time-name" in e.attrib:
            e.set(f"{{{DWD}}}design-time-name", str(uuid.uuid4()))


paths = [PROJECT / name for name in (
    "DIM TIME.dim", "DIM LOCATION.dim", "FACT ACCIDENT.dim", "US Accidents DW.cube")]
original = {p: p.read_bytes() for p in paths}
roots = {p.name: ET.fromstring(data, parser=ET.XMLParser(strip_cdata=False))
         for p, data in original.items()}

time = attributes(roots["DIM TIME.dim"])
keys(time["HOUR"], ["HOUR"])
keys(time["MINUTE"], ["HOUR", "MINUTE"])
keys(time["SECOND"], ["HOUR", "MINUTE", "SECOND"])
for source, targets in {
    "ID TIME": ["FULL TIME", "SECOND"], "SECOND": ["MINUTE"],
    "MINUTE": ["HOUR"], "HOUR": []}.items():
    relationships(time[source], targets)

location_root = roots["DIM LOCATION.dim"]
location = attributes(location_root)
for name, columns in {
    "STATE": ["STATE"], "COUNTY": ["STATE", "COUNTY"],
    "CITY": ["STATE", "CITY"], "STREET": ["STATE", "CITY", "STREET"]}.items():
    keys(location[name], columns)
for source, targets in {
    "ID LOCATION": ["STREET", "COUNTY", "TIMEZONE"], "STREET": ["CITY"],
    "CITY": ["STATE"], "COUNTY": ["STATE"], "STATE": []}.items():
    relationships(location[source], targets)
for hierarchy in location_root.findall("a:Hierarchies/a:Hierarchy", N):
    levels = hierarchy.find("a:Levels", N)
    level_ids = [level.findtext("a:SourceAttributeID", namespaces=N) for level in levels]
    if level_ids == ["STATE", "COUNTY", "CITY", "STREET"]:
        for level in list(levels):
            if level.findtext("a:SourceAttributeID", namespaces=N) == "COUNTY":
                levels.remove(level)
        hierarchy.find("a:Name", N).text = "Location_BEF"

fact_root = roots["FACT ACCIDENT.dim"]
fact = attributes(fact_root)
if "SUNRISE SUNSET" not in fact:
    attribute = deepcopy(fact["ID SEVERITY"])
    fresh_design_ids(attribute)
    attribute.find("a:ID", N).text = "SUNRISE SUNSET"
    attribute.find("a:Name", N).text = "SUNRISE SUNSET"
    item = attribute.find("a:KeyColumns/a:KeyColumn", N)
    item.find("a:DataType", N).text = "WChar"
    data_size = ET.Element(tag("DataSize"))
    data_size.text = "10"
    item.insert(1, data_size)
    null_processing = ET.Element(tag("NullProcessing"))
    null_processing.text = "ZeroOrBlank"
    item.insert(2, null_processing)
    item.find("a:Source/a:ColumnID", N).text = "SUNRISE_SUNSET"
    attribute.find("a:AttributeHierarchyVisible", N).text = "true"
    ET.indent(attribute, space="  ", level=2)
    attribute.tail = "\n  "
    container = fact_root.find("a:Attributes", N)
    if len(container):
        container[-1].tail = "\n    "
    container.append(attribute)
    current = fact["ID FACT"].find("a:AttributeRelationships", N)
    related = [r.findtext("a:AttributeID", namespaces=N) for r in current]
    relationships(fact["ID FACT"], related + ["SUNRISE SUNSET"])

cube = roots["US Accidents DW.cube"]
dimension = next(d for d in cube.findall("a:Dimensions/a:Dimension", N)
                 if d.findtext("a:ID", namespaces=N) == "FACT ACCIDENT")
cube_attributes = dimension.find("a:Attributes", N)
if not any(a.findtext("a:AttributeID", namespaces=N) == "SUNRISE SUNSET"
           for a in cube_attributes):
    attribute = deepcopy(cube_attributes[0])
    fresh_design_ids(attribute)
    attribute.find("a:AttributeID", N).text = "SUNRISE SUNSET"
    ET.indent(attribute, space="  ", level=4)
    cube_attributes[-1].tail = "\n        "
    attribute.tail = "\n      "
    cube_attributes.append(attribute)

# Parse every generated document before writing any project file.
updated = {}
for path in paths:
    data = ET.tostring(roots[path.name], encoding="utf-8").replace(b"\r\n", b"\n")
    data = re.sub(rb"(?<!\s)/>", b" />", data)
    old_header = original[path].removeprefix(b"\xef\xbb\xbf").splitlines()[0]
    data = old_header + b"\n" + data.split(b"\n", 1)[1]
    data = data.replace(b"\n", b"\r\n")
    if original[path].startswith(b"\xef\xbb\xbf"):
        data = b"\xef\xbb\xbf" + data
    ET.fromstring(data)
    updated[path] = data

backup = ROOT / "SSAS" / "backups" / ("bef_" + datetime.now().strftime("%Y%m%d_%H%M%S"))
backup.mkdir(parents=True, exist_ok=False)
report = {"backup": str(backup), "changed": []}
for path in paths:
    if path.read_bytes() != original[path]:
        raise RuntimeError(f"File changed during preparation: {path}")
    shutil.copy2(path, backup / path.name)
for path, data in updated.items():
    path.write_bytes(data)
    report["changed"].append({"file": str(path),
                              "before_sha256": hashlib.sha256(original[path]).hexdigest(),
                              "after_sha256": hashlib.sha256(data).hexdigest()})
(backup / "changes.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
print(json.dumps(report, indent=2))
