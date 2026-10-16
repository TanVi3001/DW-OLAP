# Hướng dẫn thực hiện và viết báo cáo câu a

Tài liệu này theo bố cục trong báo cáo mẫu: sau mỗi bước thao tác quan trọng, chụp màn hình, chèn ảnh và ghi chú thích ngay bên dưới ảnh rồi mới chuyển bước tiếp theo. Thứ tự là Cube Browser (manual) → PivotTable Excel → MDX → đối chiếu và nhận xét. Ảnh phải được chụp từ project và Excel của nhóm.

## Câu a

**Theo từng năm, thống kê tổng số vụ tai nạn toàn quốc tại các vị trí có giao lộ (<code>Junction = 1</code>), vòng xoay (<code>Roundabout = 1</code>), đường sắt (<code>Railway = 1</code>) và đèn giao thông (<code>Traffic_Signal = 1</code>). Sau đó, drill-down vào bang California (<code>State = 'CA'</code>) để so sánh xu hướng riêng của bang này với xu hướng cả nước. Sắp xếp theo năm tăng dần.**

### Mục tiêu và cách hiểu

Đếm measure <code>FACT ACCIDENT Count</code> theo <code>YEAR</code>, trước tiên để <code>STATE</code> ở All (toàn quốc), sau đó lọc <code>STATE = CA</code>. Mỗi điều kiện hạ tầng được chạy riêng: Junction, Roundabout, Railway và Traffic Signal. Trong mô hình, các cột cờ BIT hiển thị trong SSAS dưới dạng <code>True/False</code>; vì vậy lọc <code>True</code> chính là lọc giá trị nguồn bằng 1.

Một vụ tai nạn có thể đồng thời có nhiều đặc điểm hạ tầng. Do đó, bốn cột/chuỗi kết quả không loại trừ lẫn nhau và **không được cộng bốn loại lại để gọi là tổng số vụ tai nạn**.

### 1. Thực hiện manual trong Visual Studio (Cube Browser)

Thao tác trên cube <code>US Accidents DW</code> trong database <code>SSAS</code>. Nếu Browser còn giữ bộ lọc câu b/e/f, xóa chúng trước để câu a không bị lọc nhầm severity, quý, ngày/đêm hoặc vị trí.

**Bước 1 - Chuẩn bị Cube Browser.** Mở solution SSAS trong Visual Studio. Trong Solution Explorer, mở <code>Cubes</code> → nhấp đúp <code>US Accidents DW.cube</code> → chọn tab **Browser**. Chọn Measure Group <code>FACT ACCIDENT</code>, xóa filter cũ, thêm measure **FACT ACCIDENT Count**, rồi kéo riêng thuộc tính **YEAR** của <code>ID START DATE</code> vào trục hàng/kết quả.

**Chụp và chèn ngay tại đây:** chụp cửa sổ Browser đã sạch filter, thấy YEAR và FACT ACCIDENT Count. Đặt ảnh sau đoạn này, ghi chú thích **Hình 3.10.1. Chuẩn bị Cube Browser cho truy vấn câu a**.

**Bước 2 - Junction toàn quốc.** Thêm <code>DIM ROAD STRUCTURE → JUNCTION</code> vào Filter; đặt Operator = Equal và chỉ chọn member **True**. Để State ở All, sau đó bấm **Run/Execute**.

**Chụp và chèn ngay tại đây:** ảnh phải thấy <code>JUNCTION = True</code>, YEAR và số vụ. Chú thích **Hình 3.10.2. Số vụ Junction theo năm trên toàn quốc**.

**Bước 3 - Junction tại California.** Giữ filter Junction, thêm <code>DIM LOCATION → STATE</code>, chọn **CA** và chạy lại.

**Chụp và chèn ngay tại đây:** ảnh phải thấy đồng thời <code>JUNCTION = True</code> và <code>STATE = CA</code>. Chú thích **Hình 3.10.3. Số vụ Junction theo năm tại California**.

**Bước 4 - Roundabout toàn quốc.** Xóa filter Junction, thay bằng <code>ROUNDABOUT = True</code>. Đặt State về All và chạy.

**Chụp và chèn ngay tại đây:** chú thích **Hình 3.10.4. Số vụ Roundabout theo năm trên toàn quốc**.

**Bước 5 - Roundabout tại California.** Giữ Roundabout = True, đổi State sang CA và chạy.

**Chụp và chèn ngay tại đây:** chú thích **Hình 3.10.5. Số vụ Roundabout theo năm tại California**.

**Bước 6 - Railway toàn quốc.** Thay filter Roundabout bằng <code>RAILWAY = True</code>, đặt State = All và chạy.

**Chụp và chèn ngay tại đây:** chú thích **Hình 3.10.6. Số vụ Railway theo năm trên toàn quốc**.

**Bước 7 - Railway tại California.** Giữ Railway = True, đổi State sang CA và chạy.

**Chụp và chèn ngay tại đây:** chú thích **Hình 3.10.7. Số vụ Railway theo năm tại California**.

**Bước 8 - Traffic Signal toàn quốc.** Xóa filter Railway. Trong Metadata mở <code>DIM TRAFFIC SIGNAL</code>, thêm <code>TRAFFIC SIGNAL</code> vào Filter và chọn **True**. Đặt State = All rồi chạy.

**Chụp và chèn ngay tại đây:** chú thích **Hình 3.10.8. Số vụ Traffic Signal theo năm trên toàn quốc**.

**Bước 9 - Traffic Signal tại California.** Giữ Traffic Signal = True, thêm/đổi filter <code>STATE = CA</code> và chạy.

**Chụp và chèn ngay tại đây:** ảnh phải cho thấy <code>TRAFFIC SIGNAL = True</code> và <code>STATE = CA</code>. Chú thích **Hình 3.10.9. Số vụ Traffic Signal theo năm tại California**.

Ở cả chín ảnh, giữ được phần filter, YEAR và FACT ACCIDENT Count. Nếu ô kết quả không xuất hiện ở một năm, ghi giá trị đó là 0 trong bảng tổng hợp. Browser cần chạy 8 truy vấn kết quả (4 điều kiện × 2 phạm vi); bước 1 là ảnh ghi nhận phần chuẩn bị chung.

Thứ tự thao tác tương đương là: **YEAR ở Rows + FACT ACCIDENT Count ở Values + một cờ hạ tầng = True + (không lọc State hoặc State = CA)**. Tổng cộng có 8 lượt xem kết quả: 4 điều kiện × 2 phạm vi địa lý.

Thực hiện theo thứ tự từng bước và đặt ảnh cùng chú thích ngay sau bước tương ứng; không gom toàn bộ ảnh xuống cuối mục manual.

### 2. Thực hiện bằng PivotTable Excel

Tạo workbook riêng để không ghi đè các kết quả câu b, e, f: <code>Pivot_Excel/Pivot_a.xlsx</code>.

#### 2.1 Kết nối Excel đến cube

1. Mở Excel → tạo **Blank workbook**.
2. Chọn **Data → Get Data → From Database → From Analysis Services** (một số phiên bản ghi **From SQL Server Analysis Services**).
3. Nhập Analysis Services server của máy đang chạy SSAS (máy nhóm hiện dùng instance <code>LAPTOP-40H784NV\SSASMD</code>; nếu mở trên máy khác, thay bằng server của máy đó).
4. Chọn database <code>SSAS</code>, cube <code>US Accidents DW</code>, rồi chọn tạo PivotTable report. Nếu được hỏi kiểu kết nối, dùng kết nối tới Analysis Services cube.
5. Lưu workbook ngay bằng **F12** → chọn thư mục project <code>D:\OLAP\Pro\Pivot_Excel</code> → tên <code>Pivot_a.xlsx</code> → loại <code>Excel Workbook (*.xlsx)</code>.

**Chụp và chèn ngay sau khi kết nối:** chụp Excel đã nạp PivotTable từ cube và đang mở khung PivotTable Fields. Chú thích **Hình 3.10.10. Kết nối Excel với cube US Accidents DW**.

#### 2.2 Tạo bảng đối chiếu

Tạo bốn sheet: <code>Junction</code>, <code>Roundabout</code>, <code>Railway</code>, <code>Traffic_Signal</code>. Trên mỗi sheet tạo hai PivotTable từ cùng kết nối cube, đặt cạnh nhau và ghi nhãn bên trên: **Toàn quốc** và **California**.

Trong mỗi PivotTable, kéo trường như sau:

| Trường trong PivotTable Fields | Khu vực PivotTable | Giá trị/thiết lập |
|---|---|---|
| <code>ID START DATE</code> → <code>YEAR</code> | Rows | Chỉ dùng cấp năm |
| <code>FACT ACCIDENT Count</code> | Values | Measure đếm số vụ |
| <code>DIM ROAD STRUCTURE</code> → cờ đang xét | Filters | <code>True</code> |
| <code>DIM TRAFFIC SIGNAL</code> → <code>TRAFFIC SIGNAL</code> | Filters, chỉ sheet Traffic_Signal | <code>True</code> |
| <code>DIM LOCATION</code> → <code>STATE</code> | Filters | Pivot toàn quốc: <code>(All)</code>; Pivot California: <code>CA</code> |

**Bước 1 - Tạo PivotTable Junction.** Tạo hai PivotTable từ kết nối cube và đặt cạnh nhau. Ở cả hai bảng, đặt YEAR vào **Rows**, FACT ACCIDENT Count vào **Values**, JUNCTION vào **Filters** rồi chỉ chọn True. Thêm STATE vào Filters; bảng Toàn quốc để (All), bảng California chọn CA. Nếu cần, sắp xếp YEAR từ nhỏ đến lớn.

**Chụp và chèn ngay tại đây:** chụp sheet Junction sao cho thấy hai PivotTable, tiêu đề Toàn quốc/California và các filter. Chú thích **Hình 3.10.11. PivotTable Junction - Toàn quốc và California**.

**Bước 2 - Tạo PivotTable Roundabout.** Thêm sheet Roundabout, tạo cặp PivotTable như bước 1, nhưng thay cờ lọc thành <code>ROUNDABOUT = True</code>.

**Chụp và chèn ngay tại đây:** chú thích **Hình 3.10.12. PivotTable Roundabout - Toàn quốc và California**.

**Bước 3 - Tạo PivotTable Railway.** Thêm sheet Railway, tạo cặp PivotTable như bước 1, nhưng thay cờ lọc thành <code>RAILWAY = True</code>.

**Chụp và chèn ngay tại đây:** chú thích **Hình 3.10.13. PivotTable Railway - Toàn quốc và California**.

**Bước 4 - Tạo PivotTable Traffic_Signal.** Thêm sheet Traffic_Signal. Trường lọc lần này lấy từ <code>DIM TRAFFIC SIGNAL → TRAFFIC SIGNAL</code>, chọn True; giữ YEAR, measure và State như các sheet trước.

**Chụp và chèn ngay tại đây:** chú thích **Hình 3.10.14. PivotTable Traffic Signal - Toàn quốc và California**.

Sau mỗi sheet, nếu Excel sắp xếp năm giảm dần, nhấp phải năm → **Sort → Sort Smallest to Largest**. Nhấn **Ctrl+S** sau khi hoàn tất. Nếu Pivot có ô trống, có thể ghi là 0 vụ cho tổ hợp điều kiện/năm đó; không suy diễn rằng toàn bộ dataset thiếu dữ liệu. Nếu panel Fields làm bảng chật, thu gọn panel hoặc phóng rộng cửa sổ nhưng vẫn để lộ hai PivotTable và filter.

### 3. Thực hiện bằng MDX

Thay vì dùng `WITH` để khai báo measure tạm thời trong từng câu query, mục này hướng dẫn **tạo Calculated Member trực tiếp trong Visual Studio** (lưu vĩnh viễn vào cube). Sau khi deploy, câu `SELECT` trong SSMS trở nên ngắn gọn và ai cũng dùng lại được mà không cần khai báo lại.

Lưu truy vấn cuối cùng trong project tại `SSAS/MDX_a/a.mdx`.

---

#### Bước 1 - Mở tab Calculations trong Visual Studio

Mở solution SSAS trong Visual Studio. Trong **Solution Explorer**, mở `Cubes` → nhấp đúp **`US Accidents DW.cube`** → chọn tab **Calculations** (nằm ở hàng tab trên cùng của Cube Designer, giữa tab Measures và KPIs).

**Chụp và chèn ngay tại đây:** chụp màn hình tab Calculations đang mở, thấy thanh toolbar có nút **New Calculated Member**. Chú thích **Hình 3.10.15. Tab Calculations trong Cube Designer**.

---

#### Bước 2 - Tạo tám Calculated Member

Với mỗi member dưới đây, nhấn nút **New Calculated Member** (biểu tượng `fx+` trên toolbar), điền **Name** và **Expression**, sau đó nhấn **Enter** hoặc chuyển sang member tiếp theo. **Parent hierarchy** luôn để là `Measures`.

**Member 1 — US Junction**

```
Name:       US Junction
Expression:
    ([Measures].[FACT ACCIDENT Count],
     [DIM ROAD STRUCTURE].[JUNCTION].&[True])
```

> **Ý nghĩa:** Đếm số vụ tai nạn **toàn quốc** xảy ra tại vị trí có **giao lộ** (`Junction = 1`). Tuple kết hợp measure đếm vụ với member `True` trên chiều `JUNCTION` — không lọc State nên SSAS tự tổng hợp tất cả bang. Tạo member này để chỉ cần gọi `[Measures].[US Junction]` thay vì lặp lại điều kiện lọc trong mọi query.


---

**Member 2 — CA Junction**

```
Name:       CA Junction
Expression:
    ([Measures].[FACT ACCIDENT Count],
     [DIM LOCATION].[STATE].&[CA],
     [DIM ROAD STRUCTURE].[JUNCTION].&[True])
```

> **Ý nghĩa:** Đếm số vụ tai nạn **riêng bang California** xảy ra tại vị trí có **giao lộ** (`Junction = 1`). Tuple có ba thành phần: measure đếm vụ + lọc `STATE = CA` + lọc `JUNCTION = True`. Đặt cạnh Member 1 trên COLUMNS cho phép so sánh xu hướng Junction của California với cả nước theo từng năm.


---

**Member 3 — US Roundabout**

```
Name:       US Roundabout
Expression:
    ([Measures].[FACT ACCIDENT Count],
     [DIM ROAD STRUCTURE].[ROUNDABOUT].&[True])
```

> **Ý nghĩa:** Đếm số vụ tai nạn **toàn quốc** xảy ra tại **vòng xoay** (`Roundabout = 1`). Không lọc State nên tổng hợp toàn bộ các bang. Roundabout có số vụ rất nhỏ; tạo member riêng giúp nhìn thấy con số thực thay vì viết điều kiện lọc thủ công mỗi lần.


---

**Member 4 — CA Roundabout**

```
Name:       CA Roundabout
Expression:
    ([Measures].[FACT ACCIDENT Count],
     [DIM LOCATION].[STATE].&[CA],
     [DIM ROAD STRUCTURE].[ROUNDABOUT].&[True])
```

> **Ý nghĩa:** Đếm số vụ tai nạn **riêng bang California** xảy ra tại **vòng xoay** (`Roundabout = 1`). Kết hợp ba lọc: measure + STATE = CA + ROUNDABOUT = True. Dùng để so sánh với Member 3 xem California chiếm bao nhiêu phần trăm vụ Roundabout toàn quốc.


---

**Member 5 — US Railway**

```
Name:       US Railway
Expression:
    ([Measures].[FACT ACCIDENT Count],
     [DIM ROAD STRUCTURE].[RAILWAY].&[True])
```

> **Ý nghĩa:** Đếm số vụ tai nạn **toàn quốc** xảy ra gần **đường sắt** (`Railway = 1`). Không lọc State nên là tổng cả nước. Tạo member này để theo dõi xu hướng tai nạn gần hạ tầng đường sắt qua các năm mà không cần viết lại điều kiện lọc.


---

**Member 6 — CA Railway**

```
Name:       CA Railway
Expression:
    ([Measures].[FACT ACCIDENT Count],
     [DIM LOCATION].[STATE].&[CA],
     [DIM ROAD STRUCTURE].[RAILWAY].&[True])
```

> **Ý nghĩa:** Đếm số vụ tai nạn **riêng bang California** xảy ra gần **đường sắt** (`Railway = 1`). Ba thành phần trong tuple: measure + STATE = CA + RAILWAY = True. Đặt cạnh Member 5 trên COLUMNS để so sánh xu hướng Railway của California với toàn quốc.


---

**Member 7 — US Traffic Signal**

```
Name:       US Traffic Signal
Expression:
    ([Measures].[FACT ACCIDENT Count],
     [DIM TRAFFIC SIGNAL].[TRAFFIC SIGNAL].&[True])
```

> **Ý nghĩa:** Đếm số vụ tai nạn **toàn quốc** xảy ra tại vị trí có **đèn giao thông** (`Traffic_Signal = 1`). Chiều lọc lấy từ `DIM TRAFFIC SIGNAL` (dimension riêng) thay vì `DIM ROAD STRUCTURE`. Không lọc State — member này cho thấy đèn giao thông có số vụ cao nhất trong bốn loại của câu a.


---

**Member 8 — CA Traffic Signal**

```
Name:       CA Traffic Signal
Expression:
    ([Measures].[FACT ACCIDENT Count],
     [DIM LOCATION].[STATE].&[CA],
     [DIM TRAFFIC SIGNAL].[TRAFFIC SIGNAL].&[True])
```

> **Ý nghĩa:** Đếm số vụ tai nạn **riêng bang California** xảy ra tại vị trí có **đèn giao thông** (`Traffic_Signal = 1`). Tuple: measure + STATE = CA + TRAFFIC SIGNAL = True. Kết hợp với Member 7 trên cùng câu SELECT để thấy California chiếm tỷ trọng thế nào trong tổng vụ Traffic Signal toàn quốc.

> **Lưu ý về `&[True]`:** ký tự `&` chỉ định key thay vì caption. Các cột cờ BIT trong nguồn được SSAS map thành member key `True`/`False`; vì vậy `&[True]` tương đương lọc giá trị nguồn bằng 1. Các member US không có State tuple nên áp dụng cho toàn quốc; các member CA thêm `[DIM LOCATION].[STATE].&[CA]` để drill-down vào bang California.

**Chụp và chèn ngay tại đây:** chụp tab Calculations sau khi tạo xong tám member, thấy danh sách đầy đủ trong Script Organizer bên trái. Chú thích **Hình 3.10.16. Tám Calculated Member đã tạo trong tab Calculations**.

---

#### Bước 3 - Deploy cube

Nhấn **Ctrl + S** để lưu file cube, sau đó vào menu **Build → Deploy `SSAS`** (hoặc nhấn **F5**). Chờ cửa sổ **Deployment Progress** báo `Deployment completed successfully`.

**Chụp và chèn ngay tại đây:** chụp cửa sổ Deployment Progress báo thành công. Chú thích **Hình 3.10.17. Deploy cube thành công sau khi thêm Calculated Member**.

---

#### Bước 4 - Chạy truy vấn SELECT trong SSMS

Sau khi deploy, tám Calculated Member đã tồn tại vĩnh viễn trong cube. Câu `SELECT` trong SSMS không cần `WITH` nữa — chỉ cần gọi thẳng tên measure.

Mở SSMS, kết nối kiểu **Analysis Services** tới instance SSAS của nhóm, chọn database `SSAS` và mở **New MDX Query**. Dán truy vấn sau và lưu vào `SSAS/MDX_a/a.mdx`:

```mdx
SELECT
{
    [Measures].[US Junction],
    [Measures].[CA Junction],
    [Measures].[US Roundabout],
    [Measures].[CA Roundabout],
    [Measures].[US Railway],
    [Measures].[CA Railway],
    [Measures].[US Traffic Signal],
    [Measures].[CA Traffic Signal]
} ON COLUMNS,
NONEMPTY(
    [ID START DATE].[YEAR].Levels(1).Members,
    [Measures].[FACT ACCIDENT Count]
) ON ROWS
FROM [US Accidents DW];
```

**Chụp và chèn ngay sau khi dán truy vấn:** chụp editor thấy rõ câu SELECT; chú thích **Hình 3.10.18. Truy vấn MDX câu a trong SSMS**.

---

#### Bước 5 - Thực thi và đối chiếu

Nhấn **Execute** (hoặc **F5**). Kiểm tra kết quả có các năm theo hàng và đủ tám cột so sánh (bốn điều kiện × Toàn quốc/California). Đối chiếu số liệu với kết quả Cube Browser và PivotTable ở các mục trên — ba phương pháp phải cho kết quả khớp nhau.

**Chụp và chèn ngay sau khi chạy:** chụp bảng kết quả; chú thích **Hình 3.10.19. Kết quả MDX câu a**. Nếu màn hình không đủ rộng, dùng hai ảnh thay vì thu nhỏ chữ đến mức khó đọc.

### 4. Kết quả và nhận xét

Các bảng dưới đây là kết quả đã chạy trên cube <code>US Accidents DW</code>. Ô <code>0</code> nghĩa là không ghi nhận vụ nào thỏa điều kiện trong năm và bang tương ứng. Nếu kết quả của bạn khác, trước hết kiểm tra State có đang (All)/CA, cờ có là True, trục hàng có YEAR, và không còn filter từ câu khác.

#### 4.1 Junction = 1

| Năm | Toàn quốc | California |
|---:|---:|---:|
| 2016 | 2.901 | 1.252 |
| 2017 | 4.196 | 1.343 |
| 2018 | 4.599 | 1.431 |
| 2019 | 4.475 | 1.826 |
| 2020 | 6.062 | 2.202 |
| 2021 | 6.296 | 1.733 |
| 2022 | 7.378 | 1.828 |
| 2023 | 1.100 | 361 |

#### 4.2 Roundabout = 1

| Năm | Toàn quốc | California |
|---:|---:|---:|
| 2016 | 1 | 1 |
| 2017 | 0 | 0 |
| 2018 | 3 | 0 |
| 2019 | 1 | 1 |
| 2020 | 1 | 0 |
| 2021 | 2 | 1 |
| 2022 | 4 | 0 |
| 2023 | 1 | 0 |

#### 4.3 Railway = 1

| Năm | Toàn quốc | California |
|---:|---:|---:|
| 2016 | 247 | 108 |
| 2017 | 472 | 116 |
| 2018 | 541 | 96 |
| 2019 | 611 | 171 |
| 2020 | 728 | 198 |
| 2021 | 830 | 213 |
| 2022 | 788 | 210 |
| 2023 | 103 | 39 |

#### 4.4 Traffic Signal = 1

| Năm | Toàn quốc | California |
|---:|---:|---:|
| 2016 | 5.221 | 876 |
| 2017 | 9.977 | 854 |
| 2018 | 11.710 | 887 |
| 2019 | 11.368 | 1.268 |
| 2020 | 13.336 | 1.564 |
| 2021 | 10.942 | 1.482 |
| 2022 | 10.115 | 1.475 |
| 2023 | 1.366 | 289 |

#### 4.5 Đối chiếu và diễn giải

Kết quả Cube Browser, PivotTable và MDX cần khớp nhau khi dùng cùng measure và cùng điều kiện lọc. Trên bộ dữ liệu hiện tại, Junction toàn quốc cao nhất năm 2022 (7.378), còn California cao nhất năm 2020 (2.202). Railway cao nhất năm 2021 ở cả nước (830) và California (213). Traffic Signal cao nhất năm 2020 ở cả nước (13.336) và California (1.564). Roundabout có số vụ rất ít trong bộ dữ liệu; California chỉ có giá trị khác 0 ở 2016, 2019 và 2021.

Năm 2023 có số đếm thấp hơn rõ rệt ở cả bốn điều kiện; cần kiểm tra độ phủ thời gian của dữ liệu trước khi kết luận mức tai nạn đã giảm mạnh, vì năm cuối có thể chưa đủ dữ liệu cho cả năm. Đây là số vụ **có mặt** từng điều kiện; số liệu không chứng minh rằng hạ tầng đó gây ra tai nạn.

### 5. Chụp ảnh và đưa vào báo cáo Word

1. Trước mỗi capture, phóng to Visual Studio/Excel, kéo cột đủ rộng để không bị rút gọn số, và tránh để con trỏ che kết quả.
2. Ngay sau thao tác được nêu trong hướng dẫn, nhấn **Win + Shift + S** rồi quét vùng có bộ lọc và kết quả. Không chờ đến cuối mục mới chụp.
3. Chọn thông báo chụp màn hình để mở ảnh, hoặc mở Paint rồi nhấn **Ctrl + V**; nhấn **Ctrl + Shift + S** để lưu PNG vào <code>Tai_lieu/Bao_cao/Hinh_cau_a/</code>. Đặt tên theo số hình, ví dụ <code>Hinh_3_10_2_Junction_US.png</code>.
4. Quay lại Word ngay sau bước đó → đặt con trỏ dưới phần mô tả thao tác → **Insert → Pictures → This Device** → chọn file vừa lưu.
5. Ngay dưới ảnh, chèn chú thích đã ghi trong hướng dẫn bằng **References → Insert Caption** hoặc nhập tay. Ví dụ: “Hình 3.10.2. Số vụ Junction theo năm trên toàn quốc”. Trong đoạn trước ảnh, dẫn hình: “Kết quả lọc Junction được trình bày tại Hình 3.10.2.”
6. Sau khi chèn ảnh và chú thích xong, mới chuyển sang bước thao tác tiếp theo. Căn giữa ảnh, giữ ảnh và chú thích trên cùng trang, không cắt mất bộ lọc hoặc tên measure.
7. Nhấn **Ctrl+S** trong Word sau từng phương pháp; lưu workbook Excel bằng **Ctrl+S**. Cuối cùng kiểm tra Word ở Print Layout để ảnh/chú thích không bị tách trang hoặc tràn lề.

#### Danh sách ảnh đề xuất

| Số hình | Nội dung ảnh | Vị trí đặt |
|---|---|---|
| 3.10.1–3.10.9 | Cube Browser: chuẩn bị và 4 điều kiện × Toàn quốc/California | Chèn ngay sau từng bước manual |
| 3.10.10 | Excel đã kết nối với cube | Chèn sau bước kết nối |
| 3.10.11–3.10.14 | Excel: bốn sheet, mỗi sheet có PivotTable Toàn quốc và California | Chèn sau khi hoàn thành từng sheet |
| 3.10.15 | Tab Calculations trong Cube Designer | Chèn sau Bước 1 |
| 3.10.16 | Tám Calculated Member đã tạo trong tab Calculations | Chèn sau Bước 2 |
| 3.10.17 | Deploy cube thành công | Chèn sau Bước 3 |
| 3.10.18 | Truy vấn MDX câu a trong SSMS | Chèn sau Bước 4 |
| 3.10.19 | Kết quả MDX câu a | Chèn sau Bước 5 |

> Trước khi nộp, thay tất cả vị trí ảnh minh họa bằng screenshot thật và kiểm tra tên database/cube, filter, tiêu đề, số liệu. Nếu báo cáo chính dùng cách đánh số hình khác, tiếp tục số hình của chương đó thay vì giữ số 3.10.x.
