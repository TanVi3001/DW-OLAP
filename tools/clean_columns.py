import csv
import sys
import time

# Cách dùng: python tools/clean_columns.py [input.csv] [output.csv]
input_path = sys.argv[1] if len(sys.argv) > 1 else "archive/Accidents_500.csv"
output_path = sys.argv[2] if len(sys.argv) > 2 else "us_accident_500_cleaned.csv"

COLUMNS_TO_KEEP = [
    "ID",
    "Severity",
    "Start_Time",
    "End_Time",
    "Distance(mi)",
    "Street",
    "City",
    "County",
    "State",
    "Timezone",
    "Temperature(F)",
    "Humidity(%)",
    "Pressure(in)",
    "Visibility(mi)",
    "Wind_Direction",
    "Wind_Speed(mph)",
    "Precipitation(in)",
    "Weather_Condition",
    "Amenity",
    "Bump",
    "Crossing",
    "Give_Way",
    "Junction",
    "No_Exit",
    "Railway",
    "Roundabout",
    "Station",
    "Stop",
    "Traffic_Calming",
    "Traffic_Signal",
    "Sunrise_Sunset",
]

start_time = time.time()
print(f"Bắt đầu xử lý file: {input_path}")

with open(input_path, mode="r", encoding="utf-8-sig", newline="") as infile:
    reader = csv.reader(infile)
    header = next(reader)
    
    # Xác định vị trí các cột cần giữ
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
    
    with open(output_path, mode="w", encoding="utf-8", newline="") as outfile:
        writer = csv.writer(outfile)
        # Ghi header mới
        writer.writerow(COLUMNS_TO_KEEP)
        
        count = 0
        for row in reader:
            if not row:
                continue
            writer.writerow([row[i] if i < len(row) else "" for i in indices])
            count += 1
            if count % 100000 == 0:
                print(f"Đã xử lý {count:,} dòng...")

elapsed = time.time() - start_time
print(f"Hoàn thành! Đã ghi {count:,} dòng vào {output_path} trong {elapsed:.2f} giây.")

