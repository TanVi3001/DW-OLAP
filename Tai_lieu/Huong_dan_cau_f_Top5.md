# Câu f: manual Visual Studio trước, Pivot Excel sau

**Đề:** Liệt kê Top 5 cặp đường và thành phố tại California (`State = 'CA'`) có số vụ tai nạn cao nhất, chỉ tính các vụ xảy ra ban đêm (`Sunrise_Sunset = 'Night'`) tại nơi có đèn giao thông (`Traffic_Signal = 1`), kèm số vụ của từng địa điểm và lấy cả các địa điểm đồng hạng ở vị trí thứ 5.

Cube: `US Accidents DW`, database SSAS: `SSAS`. Trong giao diện cube, Traffic_Signal=1 hiện là **True**. Dùng toàn bộ các năm và mọi mức severity.

## 1. Manual trong Visual Studio

1. Mở `US Accidents DW.cube` → **Browser** → Reconnect nếu cần.
2. Gỡ trường và bộ lọc của câu trước khỏi Browser.
3. Đặt ba bộ lọc:

| Dimension | Hierarchy | Operator | Giá trị |
|---|---|---|---|
| DIM LOCATION | STATE | Equal | CA |
| DIM TRAFFIC SIGNAL | TRAFFIC SIGNAL | Equal | True |
| FACT ACCIDENT | SUNRISE SUNSET | Equal | Night |

4. Kéo **DIM LOCATION → CITY**, **STREET** và **Measures → FACT ACCIDENT → FACT ACCIDENT Count** xuống vùng kết quả.
5. Execute Query (**!**). Kết quả là số vụ theo từng cặp City–Street, dưới đồng thời ba điều kiện.
6. Đối chiếu số vụ trên toàn danh sách để xác định thứ hạng; ghi số vụ của vị trí thứ 5 là M. Nếu Browser không thuận tiện để xếp hạng, dùng Pivot ở mục 2 để sắp xếp và kiểm chứng trên cùng điều kiện.
7. Với dữ liệu đã kiểm tra: các số vụ đầu là **11, 10, 9, 8, 8**, nên M=8; lấy mọi địa điểm có ít nhất 8 vụ. Kết quả gồm 6 địa điểm như mục 3.
8. Chụp kết quả kèm bộ lọc, lưu `Ket_qua/f_manual.png`. Việc đổi bộ lọc/khung kết quả không cần Deploy lại.

## 2. Pivot Excel trong workbook riêng

1. Ctrl+S lưu workbook đang mở; Ctrl+N tạo workbook riêng.
2. **Data → From Other Sources → From Analysis Services**. Nếu dùng menu mới: bật **File → Options → Data → From Data Connection Wizard (Legacy)**, rồi **Data → Get Data → Legacy Wizards → From Data Connection Wizard** và chọn Analysis Services.
3. Server: `LAPTOP-40H784NV\SSASMD`, Windows Authentication; database **SSAS**, cube **US Accidents DW**.
4. Finish → **PivotTable Report → New worksheet → OK**.
5. Trong **PivotTable Fields**, đặt:

| Vùng | Trường và giá trị |
|---|---|
| Filters | DIM LOCATION → More Fields → STATE=CA |
| Filters | DIM TRAFFIC SIGNAL → TRAFFIC SIGNAL=True |
| Filters | FACT ACCIDENT → SUNRISE SUNSET=Night |
| Rows, ban đầu | DIM LOCATION → More Fields → STREET |
| Values | FACT ACCIDENT Count |

6. Ban đầu chỉ dùng STREET ở Rows để xếp hạng toàn California. Khóa STREET gồm STATE, CITY, STREET nên tên đường giống nhau ở các thành phố khác nhau vẫn là member riêng.
7. Chuột phải một ô Count → **Sort → Largest to Smallest**. Ghi số vụ của dòng đường thứ 5 là M; không tính dòng Grand Total. Với dữ liệu hiện tại, M=8.
8. Mũi tên STREET → **Value Filters → Greater Than Or Equal To** → measure **FACT ACCIDENT Count** → nhập M → OK. Cách này giữ các địa điểm đồng hạng ở vị trí thứ 5.
9. Kéo **CITY trong More Fields** vào Rows, đặt trên STREET để hiển thị tên thành phố; giữ bộ lọc STREET ≥M đã đặt.
10. **Design → Report Layout → Show in Tabular Form → Repeat All Item Labels**; **Subtotals → Do Not Show Subtotals**; **Grand Totals → Off for Rows and Columns**.
11. Đối chiếu danh sách với mục 3. Thứ hạng đã được xác định trước khi thêm CITY; tránh đặt Top 5 riêng dưới từng thành phố.
12. F12 → **Excel Workbook (*.xlsx)** → lưu `D:\OLAP\Pro\Pivot_Excel\Pivot_f.xlsx`; đổi tên sheet thành **f**. Ctrl+S sau mỗi lần chỉnh.

## 3. Kết quả đối chiếu

Cube được truy vấn ngày 08/10/2026, giữ STATE=CA, TRAFFIC SIGNAL=True, SUNRISE SUNSET=Night:

| City | Street | Số vụ |
|---|---|---:|
| Los Angeles | I-5 N | 11 |
| Los Angeles | I-10 E | 10 |
| Los Angeles | Harbor Fwy S | 9 |
| Culver City | I-405 N | 8 |
| Los Angeles | E Imperial Hwy | 8 |
| Los Angeles | E Olympic Blvd | 8 |

Ba địa điểm cùng có 8 vụ đều được giữ, nên Top 5 kèm đồng hạng trả về 6 địa điểm. Khi dữ liệu thay đổi, cần xác định lại M.

[Đề bài](ngu_canh_va_bo_cau_hoi_nghiep_vu.md) · [Hướng dẫn b, e, f](Huong_dan_manual_b_e_f.md) · [Thư mục Pivot Excel](../Pivot_Excel/)
