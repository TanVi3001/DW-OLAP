# Hướng dẫn thực hiện và viết báo cáo câu a

Tài liệu này theo bố cục trong báo cáo mẫu: thực hiện bằng Cube Browser (manual), PivotTable Excel, MDX, sau đó đối chiếu và nhận xét. Ảnh trong báo cáo phải được chụp từ project và Excel của nhóm; danh sách ảnh dưới đây cho biết nội dung và vị trí cần chèn.

## Câu a

**Theo từng năm, thống kê tổng số vụ tai nạn toàn quốc tại các vị trí có giao lộ (<code>Junction = 1</code>), vòng xoay (<code>Roundabout = 1</code>), đường sắt (<code>Railway = 1</code>) và đèn giao thông (<code>Traffic_Signal = 1</code>). Sau đó, drill-down vào bang California (<code>State = 'CA'</code>) để so sánh xu hướng riêng của bang này với xu hướng cả nước. Sắp xếp theo năm tăng dần.**

### Mục tiêu và cách hiểu

Đếm measure <code>FACT ACCIDENT Count</code> theo <code>YEAR</code>, trước tiên để <code>STATE</code> ở All (toàn quốc), sau đó lọc <code>STATE = CA</code>. Mỗi điều kiện hạ tầng được chạy riêng: Junction, Roundabout, Railway và Traffic Signal. Trong mô hình, các cột cờ BIT hiển thị trong SSAS dưới dạng <code>True/False</code>; vì vậy lọc <code>True</code> chính là lọc giá trị nguồn bằng 1.

Một vụ tai nạn có thể đồng thời có nhiều đặc điểm hạ tầng. Do đó, bốn cột/chuỗi kết quả không loại trừ lẫn nhau và **không được cộng bốn loại lại để gọi là tổng số vụ tai nạn**.

### 1. Thực hiện manual trong Visual Studio (Cube Browser)

Thao tác trên cube <code>US Accidents DW</code> trong database <code>SSAS</code>. Nếu Browser còn giữ bộ lọc câu b/e/f, xóa chúng trước để câu a không bị lọc nhầm severity, quý, ngày/đêm hoặc vị trí.

1. Mở solution SSAS trong Visual Studio. Trong Solution Explorer, mở <code>Cubes</code> → nhấp đúp <code>US Accidents DW.cube</code> → chọn tab **Browser**.
2. Chọn Measure Group <code>FACT ACCIDENT</code>. Xóa các dòng lọc cũ trong lưới Filter phía trên kết quả. Đảm bảo không còn điều kiện severity, quarter, sunrise/sunset hoặc location.
3. Thêm measure **FACT ACCIDENT Count** vào kết quả. Trong Metadata, mở <code>ID START DATE</code>, kéo thuộc tính **YEAR** vào trục hàng/kết quả. Dùng riêng thuộc tính YEAR, không kéo cả hierarchy nhiều cấp nếu nó làm hiện Quarter/Month/Day.
4. Trong Metadata, mở <code>DIM ROAD STRUCTURE</code> và thêm thuộc tính cần xét vào lưới Filter: lần lượt <code>JUNCTION</code>, <code>ROUNDABOUT</code>, <code>RAILWAY</code>. Với mỗi lần chạy, đặt Operator là <code>Equal</code>, chỉ chọn member **True**, rồi bấm **Run/Execute**.
5. Để lấy kết quả toàn quốc, không lọc <code>STATE</code> (tương đương State = All). Ghi nhận số vụ theo từng năm. Lặp lại bước 4 cho cả ba cờ của <code>DIM ROAD STRUCTURE</code>.
6. Với từng cờ trên, thêm <code>DIM LOCATION</code> → thuộc tính <code>STATE</code> vào Filter, chọn **CA**, rồi chạy lại. Ghi thành chuỗi riêng cho California.
7. Với <code>TRAFFIC SIGNAL</code>, thuộc tính nằm trong dimension <code>DIM TRAFFIC SIGNAL</code>, không nằm trong <code>DIM ROAD STRUCTURE</code>. Lọc <code>TRAFFIC SIGNAL = True</code>; chạy một lần với State = All và một lần với State = CA.
8. Kiểm tra năm chạy theo thứ tự tăng dần. Ghi lại các giá trị rỗng trong kết quả như 0 vụ ở điều kiện/năm đó; không nhầm ô rỗng với lỗi xử lý cube.

Thứ tự thao tác tương đương là: **YEAR ở Rows + FACT ACCIDENT Count ở Values + một cờ hạ tầng = True + (không lọc State hoặc State = CA)**. Tổng cộng có 8 lượt xem kết quả: 4 điều kiện × 2 phạm vi địa lý.

**Ảnh minh chứng cho manual:** chụp mỗi kết quả sao cho nhìn được tên dimension/thuộc tính đang lọc, member <code>True</code>, trạng thái State (<code>All</code> hoặc <code>CA</code>), các năm và measure count. Có thể chụp một ảnh cho mỗi điều kiện toàn quốc và một ảnh cho mỗi điều kiện California (tổng 8 ảnh). Đặt chú thích từ **Hình 3.10.1** đến **Hình 3.10.8**, theo thứ tự: Junction toàn quốc/CA, Roundabout toàn quốc/CA, Railway toàn quốc/CA, Traffic Signal toàn quốc/CA.

### 2. Thực hiện bằng PivotTable Excel

Tạo workbook riêng để không ghi đè các kết quả câu b, e, f: <code>Pivot_Excel/Pivot_a.xlsx</code>.

#### 2.1 Kết nối Excel đến cube

1. Mở Excel → tạo **Blank workbook**.
2. Chọn **Data → Get Data → From Database → From Analysis Services** (một số phiên bản ghi **From SQL Server Analysis Services**).
3. Nhập Analysis Services server của máy đang chạy SSAS (máy nhóm hiện dùng instance <code>LAPTOP-40H784NV\SSASMD</code>; nếu mở trên máy khác, thay bằng server của máy đó).
4. Chọn database <code>SSAS</code>, cube <code>US Accidents DW</code>, rồi chọn tạo PivotTable report. Nếu được hỏi kiểu kết nối, dùng kết nối tới Analysis Services cube.
5. Lưu workbook ngay bằng **F12** → chọn thư mục project <code>D:\OLAP\Pro\Pivot_Excel</code> → tên <code>Pivot_a.xlsx</code> → loại <code>Excel Workbook (*.xlsx)</code>.

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

Thực hiện các bước sau cho PivotTable đầu tiên, sau đó tạo thêm PivotTable thứ hai từ cùng kết nối cube và đặt bộ lọc State = CA:

1. Trong vùng **Rows**, đặt <code>YEAR</code>; trong **Values**, đặt đúng measure <code>FACT ACCIDENT Count</code>.
2. Trong **Filters**, đặt cờ hạ tầng của sheet. Mở bộ lọc và chỉ tích <code>True</code>. Với sheet Traffic_Signal, lấy cờ từ <code>DIM TRAFFIC SIGNAL</code>; ba sheet còn lại lấy cờ từ <code>DIM ROAD STRUCTURE</code>.
3. Thêm <code>STATE</code> vào **Filters**. Đặt PivotTable bên trái ở <code>(All)</code> để biểu diễn toàn quốc; đặt PivotTable bên phải ở <code>CA</code>.
4. Nếu Excel xếp năm giảm dần, nhấp phải vào năm → **Sort → Sort Smallest to Largest**.
5. Lặp lại cho đủ 4 sheet, mỗi sheet có hai bảng Toàn quốc/California. Đổi tiêu đề các PivotTable hoặc thêm nhãn ô phía trên để người xem phân biệt rõ.
6. Nhấn **Ctrl+S**. Nếu Pivot có ô trống, có thể để nguyên và chú thích trong báo cáo rằng ô trống là không có dòng dữ liệu cho điều kiện/năm đó (tức số vụ bằng 0); không tự suy diễn là toàn bộ dataset thiếu dữ liệu.

**Ảnh minh chứng cho Excel:** chụp từng sheet sao cho cả hai PivotTable, tiêu đề Toàn quốc/California và bộ lọc <code>True</code> nhìn thấy được. Chụp 4 ảnh, mỗi ảnh một sheet. Nếu danh sách field làm PivotTable quá chật, thu gọn panel Fields hoặc phóng rộng cửa sổ trước khi chụp; không cắt mất bộ lọc hoặc Grand Total nếu đang hiển thị.

### 3. Thực hiện bằng MDX

#### 3.1 Chạy truy vấn

Có thể mở SQL Server Management Studio (SSMS), kết nối kiểu **Analysis Services** đến instance của nhóm, chọn **New MDX Query**, dán truy vấn bên dưới và nhấn **Execute/F5**. Cũng có thể dùng cửa sổ MDX Query của Visual Studio nếu phiên bản đang cài hỗ trợ. Truy vấn chỉ đọc cube, không cần sửa/deploy project.

Lưu truy vấn trong project tại <code>SSAS/MDX_a/a.mdx</code>.

~~~mdx
WITH
MEMBER [Measures].[US Junction] AS
    ([Measures].[FACT ACCIDENT Count],
     [DIM ROAD STRUCTURE].[JUNCTION].&[True])
MEMBER [Measures].[CA Junction] AS
    ([Measures].[FACT ACCIDENT Count],
     [DIM LOCATION].[STATE].&[CA],
     [DIM ROAD STRUCTURE].[JUNCTION].&[True])
MEMBER [Measures].[US Roundabout] AS
    ([Measures].[FACT ACCIDENT Count],
     [DIM ROAD STRUCTURE].[ROUNDABOUT].&[True])
MEMBER [Measures].[CA Roundabout] AS
    ([Measures].[FACT ACCIDENT Count],
     [DIM LOCATION].[STATE].&[CA],
     [DIM ROAD STRUCTURE].[ROUNDABOUT].&[True])
MEMBER [Measures].[US Railway] AS
    ([Measures].[FACT ACCIDENT Count],
     [DIM ROAD STRUCTURE].[RAILWAY].&[True])
MEMBER [Measures].[CA Railway] AS
    ([Measures].[FACT ACCIDENT Count],
     [DIM LOCATION].[STATE].&[CA],
     [DIM ROAD STRUCTURE].[RAILWAY].&[True])
MEMBER [Measures].[US Traffic Signal] AS
    ([Measures].[FACT ACCIDENT Count],
     [DIM TRAFFIC SIGNAL].[TRAFFIC SIGNAL].&[True])
MEMBER [Measures].[CA Traffic Signal] AS
    ([Measures].[FACT ACCIDENT Count],
     [DIM LOCATION].[STATE].&[CA],
     [DIM TRAFFIC SIGNAL].[TRAFFIC SIGNAL].&[True])

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
~~~

Tên member <code>&amp;[True]</code> phản ánh key BIT sau khi SSAS đưa vào dimension. Dòng US không có State tuple nên dùng toàn bộ bang; dòng CA thêm member State California. NONEMPTY chỉ trả năm có dữ liệu và YEAR là trục hàng để kết quả tăng dần theo key năm.

**Ảnh minh chứng cho MDX:** chụp một ảnh có phần đầu và thân truy vấn trong editor; chụp thêm ảnh kết quả có đủ 8 cột và các năm. Nếu màn hình không đủ rộng, dùng hai ảnh thay vì thu nhỏ chữ đến mức khó đọc. Chú thích lần lượt **Hình 3.10.13. Truy vấn MDX câu a** và **Hình 3.10.14. Kết quả MDX câu a**.

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

1. Trước khi chụp, phóng to cửa sổ Visual Studio/Excel, kéo đủ rộng cột để không bị dấu ba chấm rút gọn, và để con trỏ tránh che bảng.
2. Nhấn **Win + Shift + S**, chọn vùng gồm phần bộ lọc và bảng kết quả. Chọn ảnh chụp hình chữ nhật; không cần chụp toàn desktop nếu chữ quá nhỏ.
3. Mở Paint, nhấn **Ctrl + V**, rồi **Ctrl + Shift + S** để lưu PNG. Tạo thư mục <code>Tai_lieu/Bao_cao/Hinh_cau_a/</code> và đặt tên ảnh rõ nghĩa, ví dụ <code>Manual_US_Junction.png</code>, <code>Manual_CA_Junction.png</code>, <code>Pivot_Junction.png</code>, <code>MDX_Result.png</code>.
4. Trong báo cáo Word, đặt phần câu a theo cùng thứ tự phương pháp của mẫu: **Cube Browser → Pivot Excel → MDX → nhận xét**. Sau đoạn mô tả thao tác, chọn **Insert → Pictures → This Device** để chèn ảnh phù hợp.
5. Đặt chú thích ngay dưới ảnh bằng **References → Insert Caption** (Label: Figure/Hình), hoặc nhập nhất quán bằng tay, ví dụ: “Hình 3.10.1. Cube Browser - số vụ tại Junction trên toàn quốc theo năm”. Trong nội dung, dẫn ảnh: “Kết quả được thể hiện ở Hình 3.10.1.”
6. Đặt ảnh ở giữa trang, đủ rộng để đọc được filter và con số; giữ ảnh cùng chú thích trên một trang nếu có thể. Nếu một ảnh quá dày, tách thành hai ảnh có chú thích riêng. Không ghép/cắt theo cách làm mất filter hoặc tên measure.
7. Sau khi chèn, nhấn **Ctrl + S** và kiểm tra lại trang Word ở chế độ Print Layout. Lưu workbook Excel bằng **Ctrl + S** và giữ riêng file .xlsx trong <code>Pivot_Excel</code>.

#### Danh sách ảnh đề xuất

| Số hình | Nội dung ảnh | Vị trí đặt |
|---|---|---|
| 3.10.1–3.10.8 | Cube Browser: 4 điều kiện × Toàn quốc/California | Cuối tiểu mục manual, sau khi mô tả từng lượt lọc |
| 3.10.9–3.10.12 | Excel: sheet Junction, Roundabout, Railway, Traffic_Signal; mỗi sheet có hai PivotTable | Tiểu mục Pivot Excel, ngay sau giải thích cách bố trí |
| 3.10.13–3.10.14 | Editor MDX và bảng kết quả MDX | Tiểu mục MDX, sau câu lệnh và mô tả kết quả |

> Trước khi nộp, thay tất cả vị trí ảnh minh họa bằng screenshot thật và kiểm tra tên database/cube, filter, tiêu đề, số liệu. Nếu báo cáo chính dùng cách đánh số hình khác, tiếp tục số hình của chương đó thay vì giữ số 3.10.x.
