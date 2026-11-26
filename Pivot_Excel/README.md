# Kết quả Pivot Excel

| Câu | Workbook | Nội dung |
|---|---|---|
| a | [Pivot_a.xlsx](Pivot_a.xlsx) | Số vụ theo năm và bốn điều kiện hạ tầng; đối chiếu toàn quốc với California |
| b | [Pivot_b.xlsx](Pivot_b.xlsx) | Số vụ severity 4 theo thành phố/bang trong Q2/2021 |
| c | [Pivot_c.xlsx](Pivot_c.xlsx) | Thành phố Texas có trên 1.000 vụ, kèm Distance trung bình |
| d | [Pivot_d.xlsx](Pivot_d.xlsx) | Tỷ lệ tai nạn sương mù theo bang năm 2022 (trên 5%) |
| e | [Pivot_e.xlsx](Pivot_e.xlsx) | Roll-up tháng → quý → năm, phân biệt ngày thường/cuối tuần và Day/Night |
| f | [Pivot_f.xlsx](Pivot_f.xlsx) | Top 5 cặp đường–thành phố tại California, điều kiện Night và Traffic_Signal=1, giữ đồng hạng thứ 5 |
| g | [Pivot_g.xlsx](Pivot_g.xlsx) | Số vụ, YoY%, tỷ lệ severity 3–4 và tỷ lệ ban đêm theo quý, roll-up năm 2019–2022 |
| 8 | [Pivot_8.xlsx](Pivot_8.xlsx) | Top 5 bang theo tổng Distance năm 2021; drill-down Top 3 thành phố California |
| 9 | [Pivot_9.xlsx](Pivot_9.xlsx) | Số vụ, tỷ lệ, tổng Distance, tầm nhìn TB theo Severity (có dòng ALL) |
| 10 | [Pivot_10.xlsx](Pivot_10.xlsx) | Bang có số vụ cực đại/cực tiểu kèm Distance, tỷ lệ Severity 3–4, nhiệt độ/độ ẩm/áp suất TB |
| 11 | [Pivot_11.xlsx](Pivot_11.xlsx) | Số vụ, tầm nhìn TB, tốc độ gió TB theo County–City tại California |
| 12 | [Pivot_12.xlsx](Pivot_12.xlsx) | Số vụ, nhiệt độ/lượng mưa/Distance TB theo Weather Condition × Wind Direction |
| 13 | [Pivot_13.xlsx](Pivot_13.xlsx) | Junction-only / Signal-only / cả hai theo năm, kèm tỷ lệ Severity 3–4 |
| 14 | [Pivot_14.xlsx](Pivot_14.xlsx) | Top 5 điều kiện thời tiết tại New York, kèm Distance/tầm nhìn TB và tỷ lệ ban đêm |
| 15 | [Pivot_15.xlsx](Pivot_15.xlsx) | Top 5 bang 2022: (Junction hoặc Signal) và (Rain/Fog) và Severity 3–4 |

## Mở workbook

1. Tải file `.xlsx` bằng **Download raw file** trên GitHub, hoặc mở từ thư mục này sau khi clone repo.
2. Mở bằng Excel desktop. Workbook lưu bố cục Pivot và dữ liệu đã lưu ở lần lưu gần nhất.
3. Khi cần Refresh, máy phải truy cập được SSAS database `SSAS`, cube `US Accidents DW`. Vào **Data → Queries & Connections → Connections → Properties → Definition** để kiểm tra server trong Connection string theo máy của nhóm; server hiện dùng `LAPTOP-40H784NV\SSASMD` (câu a–g) và `DESKTOP-0E618DG` (câu 8–15).

## Lưu kết quả tiếp theo

- Lưu câu f bằng **F12 → Excel Workbook (*.xlsx)** vào `D:\OLAP\Pro\Pivot_Excel\Pivot_f.xlsx`.
- Giữ mỗi câu trong một workbook riêng: `Pivot_b.xlsx`, `Pivot_e.xlsx`, `Pivot_f.xlsx`.
- Nhấn **Ctrl+S** sau khi chỉnh bộ lọc hoặc bố cục. Trong Visual Studio, Ctrl+S lưu project; muốn lưu bằng chứng manual thì chụp ảnh kết quả và bộ lọc.

[Hướng dẫn b, e, f](../Tai_lieu/Huong_dan_manual_b_e_f.md) · [Manual và Pivot câu f](../Tai_lieu/Huong_dan_cau_f_Top5.md) · [Về trang chính](../README.md)

Hướng dẫn lập workbook câu a và chụp ảnh đưa vào báo cáo: [Hướng dẫn câu a](../Tai_lieu/Huong_dan_bao_cao_cau_a.md).
