# Looker Studio

| File | Nội dung |
|---|---|
| [US_Accident_Looker.pdf](US_Accident_Looker.pdf) | Bản xuất PDF của báo cáo Looker Studio |
| [extract_looker_data.py](extract_looker_data.py) | Trích 11 cột từ file CSV đã làm sạch thành `looker_data.csv` để tải lên Looker |

## Tạo lại dữ liệu cho Looker

```powershell
python tools/clean_columns.py archive/Accidents_500.csv us_accident_500_cleaned.csv
python Looker/extract_looker_data.py us_accident_500_cleaned.csv looker_data.csv
```

`looker_data.csv` (~40 MB) không lưu trong repo; chạy lại 2 lệnh trên để tạo. Script in thêm số vụ và tổng Distance của California năm 2021 để đối chiếu với kết quả cube.

[Về trang chính](../README.md)
