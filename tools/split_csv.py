"""Cắt một file CSV lớn thành 2 phần (giữ header ở cả 2 phần).

Dùng cho file gốc (archive/Accidents_500.csv) hoặc file đã làm sạch
(us_accident_500_cleaned.csv) khi cần nạp/tải lên từng phần.

Cách dùng:
    python tools/split_csv.py <input.csv> [so_dong_phan_1]
Kết quả: <input>_part1.csv và <input>_part2.csv cạnh file gốc.
"""
import csv
import sys
import time
from pathlib import Path

if len(sys.argv) < 2:
    sys.exit("Cách dùng: python tools/split_csv.py <input.csv> [so_dong_phan_1]")

input_path = Path(sys.argv[1])
split_count = int(sys.argv[2]) if len(sys.argv) > 2 else 250_000
part1_path = input_path.with_name(f"{input_path.stem}_part1.csv")
part2_path = input_path.with_name(f"{input_path.stem}_part2.csv")

start_time = time.time()
print(f"Bắt đầu cắt đôi file: {input_path}")

with open(input_path, mode="r", encoding="utf-8-sig", newline="") as infile:
    reader = csv.reader(infile)
    header = next(reader)

    # Phần 1: split_count dòng đầu
    with open(part1_path, mode="w", encoding="utf-8", newline="") as f1:
        writer1 = csv.writer(f1)
        writer1.writerow(header)
        count1 = 0
        for row in reader:
            writer1.writerow(row)
            count1 += 1
            if count1 >= split_count:
                break
    print(f"Phần 1: {count1:,} dòng -> {part1_path}")

    # Phần 2: phần còn lại
    with open(part2_path, mode="w", encoding="utf-8", newline="") as f2:
        writer2 = csv.writer(f2)
        writer2.writerow(header)
        count2 = 0
        for row in reader:
            writer2.writerow(row)
            count2 += 1
    print(f"Phần 2: {count2:,} dòng -> {part2_path}")

print(f"Hoàn thành trong {time.time() - start_time:.2f} giây.")
