# Chạy MDX b, e, f bằng tay

Các truy vấn trong thư mục này đã chạy thành công trên cube `US Accidents DW`, database `SSAS`, instance `localhost\SSASMD` ngày 08/10/2026. Không cần sửa hoặc deploy lại cube để chạy chúng.

## 1. Mở cửa sổ MDX trong SSMS

1. Mở SQL Server Management Studio (SSMS).
2. Trong Object Explorer, chọn **Connect → Analysis Services**.
3. Server name: `LAPTOP-40H784NV\SSASMD` (hoặc `localhost\SSASMD`). Authentication: Windows Authentication. Nhấn Connect.
4. Mở Databases, chọn database `SSAS`.
5. Chọn **New Query → MDX**. Nếu thanh công cụ không hiện MDX, dùng **File → New → Analysis Services MDX Query**.
6. Kiểm tra database trên thanh công cụ là `SSAS`.
7. Mở file `.mdx` tương ứng trong thư mục này, copy toàn bộ và dán vào cửa sổ MDX vừa mở.
8. Nhấn **Execute / F5**. Mỗi cửa sổ chỉ chứa một truy vấn. Xem kết quả ở Results và lỗi ở Messages.
9. Có thể dùng Ctrl+S để lưu cửa sổ truy vấn thành file `.mdx`; các file mẫu đã được lưu sẵn.

Visual Studio trong các ảnh của bạn dùng để thiết kế/deploy SSAS. Các bước ở trên dùng SSMS để có cửa sổ chạy MDX riêng.

## 2. Câu b — b.mdx

Điều kiện: ngày bắt đầu thuộc Q2/2021, severity 4. Dòng kết quả là cặp State–City, cột là số vụ. FILTER so sánh với MAX trả về tất cả các thành phố đồng hạng.

Kết quả kiểm chứng:

| State | City | FACT ACCIDENT Count |
|---|---|---:|
| PA | Pittsburgh | 8 |

Khóa quý có hai phần: `&[2021]&[2]`. Đây là quý 2 của năm 2021.

## 3. Câu e — e.mdx

Truy vấn hiển thị các dòng YEAR, QUARTER và MONTH trong cùng kết quả. Cột Ky chỉ rõ năm/quý/tháng, ví dụ `2021 / Q2 / T4`.

Bốn cột số liệu:

| Cột | IS_WEEKEND | SUNRISE_SUNSET |
|---|---:|---|
| Ngay thuong - Day | 0 / False | Day |
| Ngay thuong - Night | 0 / False | Night |
| Cuoi tuan - Day | 1 / True | Day |
| Cuoi tuan - Night | 1 / True | Night |

Cube của bạn dùng khóa Boolean `False` và `True`, vì vậy các file sử dụng `&[False]` và `&[True]`.

SQL có cú pháp GROUP BY ROLLUP; trong MDX này, việc tổng hợp dùng các cấp sẵn có của hierarchy YEAR → QUARTER → MONTH. UNION chọn cả ba cấp và HIERARCHIZE sắp xếp chúng theo cây. Không cộng các dòng năm, quý và tháng với nhau vì chúng là ba mức biểu diễn cùng dữ liệu.

Truy vấn chạy trên toàn bộ các năm; không thêm bộ lọc năm 2021 vì đề e không yêu cầu giới hạn đó. Dòng năm 2021 trong cube hiện tại:

| Ky | Ngày thường Day | Ngày thường Night | Cuối tuần Day | Cuối tuần Night |
|---|---:|---:|---:|---:|
| 2021 | 51601 | 26008 | 15227 | 8519 |

Có 124 dòng năm/quý/tháng có dữ liệu. Ô null là không có vụ thuộc tổ hợp tương ứng. Những vụ không có nhãn Day/Night không thuộc bốn cột này.

## 4. Câu f — f1.mdx và f2.mdx

### Bước 1: f1.mdx

Giữ Traffic Signal=True, Sunrise Sunset=Night. Thống kê theo bang và sắp xếp giảm dần. Tỷ lệ mức 3–4 có mẫu số là toàn bộ các vụ thỏa hai điều kiện trong chính bang đó.

| State | Tổng số vụ | Số vụ mức 3–4 | Tỷ lệ mức 3–4 |
|---|---:|---:|---:|
| CA | 3046 | 258 | 8.47% |
| FL | 2739 | 184 | 6.72% |
| TX | 2447 | 297 | 12.14% |

### Bước 2: f2.mdx

Truy vấn tự chọn bang đứng đầu và đi xuống City–Street, giữ nguyên Night và Traffic Signal=True. Chỉ lấy các đường >50 vụ. Với mỗi đường đạt ngưỡng, tính giờ bắt đầu có nhiều vụ nhất; GENERATE nối tất cả các giờ đồng hạng trong một ô.

**Kết quả đúng trên dữ liệu hiện tại là 0 dòng:** tại CA, đường nhiều nhất theo City–Street có 11 vụ, không vượt 50.

Câu kết luận có thể đưa vào báo cáo:

> California có số vụ tai nạn ban đêm tại nơi có đèn giao thông cao nhất: 3.046 vụ, trong đó 258 vụ ở mức 3–4, tương ứng 8,47%. Drill-down tại California không tìm thấy cặp Street–City nào có trên 50 vụ trong cùng phạm vi điều kiện.

Nếu cần minh họa giờ cao điểm, tạo một bản sao f2 rồi đổi riêng điều kiện `> 50` thành `> 0`. Đây là truy vấn minh họa, không phải kết quả thỏa đề. Dòng đứng đầu khi minh họa:

| State | City | Street | Tổng số vụ | Giờ cao điểm | Số vụ ở mỗi giờ cao điểm |
|---|---|---|---:|---|---:|
| CA | Los Angeles | I-5 N | 11 | 02:00–02:59, 05:00–05:59, 20:00–20:59 | 2 |

## Tài liệu hàm MDX

- FILTER: https://learn.microsoft.com/en-us/sql/mdx/filter-mdx
- HIERARCHIZE: https://learn.microsoft.com/en-us/sql/mdx/hierarchize-mdx
- GENERATE: https://learn.microsoft.com/en-us/sql/mdx/generate-mdx
