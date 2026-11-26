import csv
import sys
import time

# Cách dùng: python Looker/extract_looker_data.py [cleaned.csv] [looker_data.csv]
input_path = sys.argv[1] if len(sys.argv) > 1 else "us_accident_500_cleaned.csv"
output_path = sys.argv[2] if len(sys.argv) > 2 else "looker_data.csv"

COLUMNS_TO_KEEP = [
    "ID",
    "Start_Time",
    "Severity",
    "Distance(mi)",
    "City",
    "State",
    "Junction",
    "Roundabout",
    "Railway",
    "Traffic_Signal",
    "Sunrise_Sunset",
]

start_time = time.time()
print(f"Bắt đầu xử lý file: {input_path}")

with open(input_path, mode="r", encoding="utf-8-sig", newline="") as infile:
    reader = csv.reader(infile)
    header = next(reader)
    
    indices = []
    missing_cols = []
    for col in COLUMNS_TO_KEEP:
        if col in header:
            indices.append(header.index(col))
        else:
            missing_cols.append(col)
            
    if missing_cols:
        print(f"Lỗi: Không tìm thấy các cột: {missing_cols}")
        sys.exit(1)
        
    print(f"Tổng số cột ban đầu: {len(header)}")
    print(f"Số cột được giữ lại: {len(indices)}")
    
    ca_2021_count = 0
    ca_2021_distance = 0.0
    
    idx_start_time = header.index("Start_Time")
    idx_state = header.index("State")
    idx_distance = header.index("Distance(mi)")
    
    with open(output_path, mode="w", encoding="utf-8", newline="") as outfile:
        writer = csv.writer(outfile)
        writer.writerow(COLUMNS_TO_KEEP)
        
        count = 0
        for row in reader:
            if not row:
                continue
            writer.writerow([row[i] if i < len(row) else "" for i in indices])
            count += 1
            
            # Kiểm tra đối chiếu số liệu CA năm 2021
            if row[idx_state] == "CA" and row[idx_start_time].startswith("2021"):
                ca_2021_count += 1
                try:
                    ca_2021_distance += float(row[idx_distance])
                except (ValueError, IndexError):
                    pass
                    
            if count % 100000 == 0:
                print(f"Đã xử lý {count:,} dòng...")

elapsed = time.time() - start_time
print(f"Hoàn thành! Đã ghi {count:,} dòng vào {output_path} trong {elapsed:.2f} giây.")
print(f"Kiểm tra nhanh (CA năm 2021): {ca_2021_count:,} vụ, tổng Distance = {ca_2021_distance:,.2f} dặm.")

