# Kết quả Pivot Excel

| Câu | Workbook | Nội dung |
|---|---|---|
| a | Pivot_a.xlsx (tạo theo hướng dẫn) | Số vụ theo năm và bốn điều kiện hạ tầng; đối chiếu toàn quốc với California |
| b | [Pivot_b.xlsx](Pivot_b.xlsx) | Số vụ severity 4 theo thành phố/bang trong Q2/2021 |
| e | [Pivot_e.xlsx](Pivot_e.xlsx) | Roll-up tháng → quý → năm, phân biệt ngày thường/cuối tuần và Day/Night |
| f | Chưa có workbook | Top 5 cặp đường–thành phố tại California, điều kiện Night và Traffic_Signal=1, giữ đồng hạng thứ 5 |

## Mở workbook

1. Tải file `.xlsx` bằng **Download raw file** trên GitHub, hoặc mở từ thư mục này sau khi clone repo.
2. Mở bằng Excel desktop. Workbook lưu bố cục Pivot và dữ liệu đã lưu ở lần lưu gần nhất.
3. Khi cần Refresh, máy phải truy cập được SSAS database `SSAS`, cube `US Accidents DW`. Vào **Data → Queries & Connections → Connections → Properties → Definition** để kiểm tra server trong Connection string theo máy của nhóm; server hiện dùng `LAPTOP-40H784NV\SSASMD`.

## Lưu kết quả tiếp theo

- Lưu câu f bằng **F12 → Excel Workbook (*.xlsx)** vào `D:\OLAP\Pro\Pivot_Excel\Pivot_f.xlsx`.
- Giữ mỗi câu trong một workbook riêng: `Pivot_b.xlsx`, `Pivot_e.xlsx`, `Pivot_f.xlsx`.
- Nhấn **Ctrl+S** sau khi chỉnh bộ lọc hoặc bố cục. Trong Visual Studio, Ctrl+S lưu project; muốn lưu bằng chứng manual thì chụp ảnh kết quả và bộ lọc.

[Hướng dẫn b, e, f](../Tai_lieu/Huong_dan_manual_b_e_f.md) · [Manual và Pivot câu f](../Tai_lieu/Huong_dan_cau_f_Top5.md) · [Về trang chính](../README.md)

Hướng dẫn lập workbook câu a và chụp ảnh đưa vào báo cáo: [Hướng dẫn câu a](../Tai_lieu/Huong_dan_bao_cao_cau_a.md).
