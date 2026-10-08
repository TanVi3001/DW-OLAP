# Hướng dẫn làm câu b, e, f bằng Visual Studio SSAS và PivotTable Excel

## 1. File đã đọc và công cụ sử dụng

- Đề: [Ngữ cảnh và 15 câu hỏi](ngu_canh_va_bo_cau_hoi_nghiep_vu.md).
- Báo cáo: [Báo cáo SSIS](Bao_cao/24520814_24521985_SSIS.docx), phần SSAS, PivotTable và MDX.
- Cấu trúc SQL: [QueryProject.sql](../SQL/QueryProject.sql).
- Project thực tế: `SSAS/SSAS.slnx`, `SSAS/SSAS/SSAS.dwproj`, các file `.dim`, `.dsv`, `.cube`.
- Dữ liệu đối chiếu: `archive/Accidents_500.csv`, đúng 500.000 dòng.

Làm bằng **Visual Studio có extension Microsoft Analysis Services Projects**, sau đó kéo thả trên **Excel desktop cho Windows**. VS Code có thể đọc file nhưng các màn hình Dimension Structure, Attribute Relationships và Cube Designer dưới đây nằm trong Visual Studio.

Không cần chạy lại `SQL/QueryProject.sql`: file đó có lệnh DROP/TRUNCATE. Hướng dẫn này dùng kho dữ liệu đã nạp.

Severity là mức ảnh hưởng đến giao thông; không suy ra số người chết hoặc bị thương từ mức 4.

## 2. Chuẩn bị project bằng giao diện, chỉ làm một lần

**Cập nhật 08/10/2026:** cube của bạn đã Deploy/Process thành công. Bạn bắt đầu ở mục 3; mục 2 là phần tham khảo khi cần kiểm tra cấu hình, không cần làm lại. Hierarchy ngày hiện có tên **Hierarchy**; hierarchy vị trí là **Location_BEF**.

### 2.1. Mở và kiểm tra kết nối

1. Mở Visual Studio → **File → Open → Project/Solution**.
2. Chọn `D:\OLAP\Pro\SSAS\SSAS.slnx`. Nếu phiên bản không mở được `.slnx`, chọn `D:\OLAP\Pro\SSAS\SSAS\SSAS.dwproj`.
3. Trong **Solution Explorer**, mở **Data Sources → US Accidents DW.ds**.
4. Bấm **Edit** ở Connection String. Server trong file hiện là `LAPTOP-40H784NV`; nếu đây không phải server của bạn, đổi sang server chứa database đã nạp. Máy được kiểm tra trong phiên này có SQL Server và SSAS đang chạy; kết nối SQL bằng `localhost` thấy database `US_Accidents_DW`.
5. Chọn database **US_Accidents_DW** → **Test Connection** → **OK**.
6. Nếu cấu hình project có connection mapping ghi đè Data Source, kiểm tra mapping đó cũng trỏ đúng server.

### 2.2. Cách sửa một thuộc tính

Các khóa hiện tại của YEAR, QUARTER, MONTH, STATE, CITY, HOUR chứa cả cột cấp chi tiết. Ví dụ YEAR đang có YEAR + QUARTER + MONTH + DAY, khiến nhiều member khác nhau cùng hiện nhãn năm 2021. Cần sửa trước khi phân tích.

1. Mở dimension trong **Solution Explorer → Dimensions**.
2. Vào **Dimension Structure**.
3. Trong khung **Attributes**, chọn thuộc tính → nhấn **F4** mở Properties.
4. Tại **KeyColumns**, bấm **…**.
5. Dùng nút **<** bỏ các cột cũ không cần, dùng **>** thêm đúng các cột trong bảng dưới; kiểm tra thứ tự → **OK**.
6. Tại **NameColumn**, bấm **…**, chọn cột nhãn trong bảng → **OK**.
7. Lặp lại cho các thuộc tính cần sửa. Không đổi khóa gốc ID_DATE, ID_LOCATION, ID_TIME.

### 2.3. DIM DATE: chuẩn bị Năm → Quý → Tháng → Ngày

| Attribute | KeyColumns, theo thứ tự | NameColumn |
|---|---|---|
| YEAR | YEAR | YEAR |
| QUARTER | YEAR, QUARTER | QUARTER |
| MONTH | YEAR, MONTH | MONTH |
| DAY | YEAR, MONTH, DAY | DAY |

1. Sửa các thuộc tính theo bảng.
2. Vào **Attribute Relationships**. Xóa các quan hệ phân cấp cũ đang đi YEAR → QUARTER → MONTH → DAY; giữ các quan hệ độc lập như FULL DATE, DAY OF WEEK, IS WEEKEND.
3. Tạo các quan hệ bằng chuột phải → **New Attribute Relationship**, chọn source và related attribute:
   - `ID_DATE → DAY`.
   - `DAY → MONTH`.
   - `MONTH → QUARTER`.
   - `QUARTER → YEAR`.
4. Quan hệ source → related ở đây nghĩa là mỗi source xác định được một related: một tháng thuộc một quý, một quý thuộc một năm.
5. Quan hệ trực tiếp `ID_DATE → YEAR` cũ có thể bỏ khi đã có đường dẫn qua DAY → MONTH → QUARTER → YEAR. Đảm bảo mọi thuộc tính vẫn có đường nối từ khóa gốc.
6. Trở về **Dimension Structure**, hierarchy đang có YEAR → QUARTER → MONTH → DAY. Giữ tên `Hierarchy` như cube hiện tại.
7. Nếu cần tạo lại: kéo YEAR vào khung Hierarchies trống, rồi kéo QUARTER, MONTH, DAY lần lượt xuống dưới.
8. `IS WEEKEND` dùng khóa `IS_WEEKEND` riêng, giữ hiển thị: 0 là ngày thường, 1 là thứ Bảy/Chủ nhật.

Khóa quý có cả năm để Q2/2021 khác Q2/2022; khóa tháng có cả năm để tháng 4/2021 khác tháng 4/2022.

### 2.4. DIM LOCATION: chuẩn bị đúng State → City → Street

Đề b nhóm theo (City, State), đề f nhóm đường theo (Street, City) trong bang đã chọn. Do đó CITY dùng State + City, STREET dùng State + City + Street.

| Attribute | KeyColumns, theo thứ tự | NameColumn |
|---|---|---|
| STATE | STATE | STATE |
| COUNTY | STATE, COUNTY | COUNTY |
| CITY | STATE, CITY | CITY |
| STREET | STATE, CITY, STREET | STREET |

1. Mở **DIM LOCATION.dim** → sửa khóa và nhãn theo bảng.
2. Vào **Attribute Relationships**, xóa các quan hệ cũ STATE → COUNTY → CITY → STREET.
3. Tạo `ID LOCATION → STREET`, `STREET → CITY`, `CITY → STATE`.
4. COUNTY giữ nhánh riêng: `ID LOCATION → COUNTY`, `COUNTY → STATE`. Giữ quan hệ TIMEZONE từ khóa gốc.
5. Bỏ quan hệ trực tiếp ID LOCATION → STATE cũ nếu đã có đường dẫn qua STREET/CITY. Kiểm tra mọi thuộc tính vẫn nối đến khóa gốc.
6. Trong **Dimension Structure**, kéo STATE vào vùng Hierarchies trống để tạo **Location_BEF**, kéo CITY rồi STREET xuống dưới.
7. Hierarchy cũ có COUNTY nằm giữa STATE và CITY không còn phù hợp với khóa CITY chỉ gồm STATE + CITY nếu một city trải qua nhiều county. Xóa riêng hierarchy cũ đó khỏi khung Hierarchies hoặc thiết kế lại cho bài khác; giữ attribute COUNTY. Hướng dẫn này dùng **Location_BEF**.

### 2.5. DIM TIME: giờ phải thực sự được nhóm theo giờ

| Attribute | KeyColumns, theo thứ tự | NameColumn |
|---|---|---|
| HOUR | HOUR | HOUR |
| MINUTE | HOUR, MINUTE | MINUTE |
| SECOND | HOUR, MINUTE, SECOND | SECOND |

1. Mở **DIM TIME.dim** → sửa theo bảng.
2. Xóa quan hệ cũ HOUR → MINUTE → SECOND.
3. Tạo `ID TIME → SECOND`, `SECOND → MINUTE`, `MINUTE → HOUR`. Giữ FULL TIME; có thể bỏ quan hệ trực tiếp ID TIME → HOUR sau khi có đường dẫn mới.
4. Hierarchy HOUR → MINUTE → SECOND trong **Dimension Structure** giữ nguyên.

### 2.6. Đưa Day/Night vào cube

DSV đã có `FACT_ACCIDENT.SUNRISE_SUNSET`, nhưng dimension FACT ACCIDENT hiện chưa có thuộc tính này.

1. Mở **FACT ACCIDENT.dim → Dimension Structure**.
2. Trong khung **Data Source View**, mở bảng FACT_ACCIDENT.
3. Kéo cột **SUNRISE_SUNSET** sang khung **Attributes**.
4. Chọn attribute vừa tạo → F4 → đặt **Name = SUNRISE SUNSET**, **KeyColumns = SUNRISE_SUNSET**, **NameColumn = SUNRISE_SUNSET**.
5. Kiểm tra **AttributeHierarchyEnabled = True**, **AttributeHierarchyVisible = True**.
6. Trong **Attribute Relationships**, kiểm tra có `ID FACT → SUNRISE SUNSET`; nếu chưa có thì tạo.
7. Mở **US Accidents DW.cube → Cube Structure**, kiểm tra dimension FACT ACCIDENT có attribute mới. Nếu cube giới hạn danh sách attribute thì bổ sung attribute này.

### 2.7. Kiểm tra measure và vai trò ngày/giờ

1. Trong **Cube Structure**, mở nhóm Measures FACT ACCIDENT.
2. Chọn **FACT ACCIDENT Count** → F4 → **AggregateFunction = Count**. Đây là measure đếm số dòng tai nạn của project; không dùng DISTANCE để đếm vụ.
3. Vào **Dimension Usage**, kiểm tra các giao điểm với measure group FACT ACCIDENT:

| Cube dimension | Relationship | Granularity attribute | Cột khóa bên fact |
|---|---|---|---|
| ID START DATE | Regular | ID_DATE | ID_START_DATE |
| ID START TIME | Regular | ID TIME | ID_START_TIME |
| DIM LOCATION | Regular | ID LOCATION | ID_LOCATION |
| DIM SEVERITY | Regular | ID SEVERITY | ID_SEVERITY |
| DIM TRAFFIC SIGNAL | Regular | ID TRAFFIC SIGNAL | ID_TRAFFIC_SIGNAL |
| FACT ACCIDENT | Fact | ID FACT | ID_FACT |

4. Các quan hệ trên đã có trong file cube; chỉ sửa nếu màn hình thực tế khác.
5. Cả ba bài đều dùng **ID START DATE** và **ID START TIME**. Không lấy nhầm ngày/giờ kết thúc.

### 2.8. Deploy và Process

1. **Ctrl + Shift + S** để Save All.
2. Chuột phải project **SSAS → Properties → Deployment**.
3. **Server**: server SSAS của bạn, ví dụ `localhost` nếu SSAS chạy trên máy này.
4. **Database**: xem và ghi lại tên database SSAS đích; database SSAS có thể khác tên SQL database. Cube là **US Accidents DW**.
5. Chuột phải project → **Deploy**, chờ Output báo thành công.
6. Nếu chưa process tự động: chuột phải cube → **Process → Process Full → Run**.
7. Nếu process báo thiếu quyền đọc SQL: kiểm tra **Data Source → Impersonation Information** và cấp quyền đọc `US_Accidents_DW` cho tài khoản được dùng để process.
8. Sau khi sửa khóa dimension, cần process lại dimension/cube; chỉ Refresh Excel sẽ không cập nhật cách nhóm dữ liệu.

## 3. Kết nối Excel trực tiếp vào cube

1. Mở Excel → **Blank workbook**.
2. Nếu có menu **Data → From Other Sources → From Analysis Services**, chọn menu đó.
3. Nếu không có: **File → Options → Data → Show legacy data import wizards → From Data Connection Wizard (Legacy)** → OK; đóng/mở lại workbook nếu menu chưa xuất hiện.
4. **Data → Get Data → Legacy Wizards → From Data Connection Wizard (Legacy)**.
5. Chọn **Microsoft SQL Server Analysis Services** → Next.
6. Nhập server SSAS `LAPTOP-40H784NV\SSASMD` hoặc `localhost\SSASMD`; dùng **Windows Authentication** → Next.
7. Chọn database SSAS **SSAS**, chọn cube **US Accidents DW** → Next → Finish.
8. Trong Import Data, chọn **PivotTable Report → New worksheet → OK**.
9. Chọn PivotTable → **PivotTable Analyze → Field List** để hiện danh sách trường.
10. Lưu mỗi câu trong một workbook riêng ở `Pivot_Excel/`: **Pivot_b.xlsx**, **Pivot_e.xlsx**, **Pivot_f.xlsx**.
11. Tạo workbook mới và kết nối lại theo các bước trên khi chuyển câu; kiểm tra bộ lọc của từng Pivot, nhất là Severity.

Đây là Pivot nối trực tiếp cube, có danh sách dimension và measure SSAS. Không cần nhập CSV để làm bài kéo thả này.

## 4. Câu b: thành phố nhiều vụ Severity 4 nhất trong Q2/2021

### 4.1. Kéo các trường

| Vùng Pivot | Trường |
|---|---|
| Filters | ID START DATE → YEAR |
| Filters | ID START DATE → QUARTER |
| Filters | DIM SEVERITY → ID SEVERITY |
| Rows | DIM LOCATION → CITY |
| Values | Measures → FACT ACCIDENT Count |

CITY đã dùng khóa (STATE, CITY), nên các city cùng tên ở hai bang vẫn là member riêng.

### 4.2. Lọc và tìm số lớn nhất

1. YEAR chọn **2021**.
2. QUARTER chọn member **quý 2 của 2021**. Nếu tên quý trùng giữa các năm, dùng **ID START DATE → Hierarchy** ở Filters, mở năm 2021 rồi chọn quý 2 trong cây (thay cho hai filter YEAR/QUARTER).
3. ID SEVERITY chọn **4**.
4. Nhấp một ô số vụ → chuột phải **Sort → Largest to Smallest**.
5. Ghi lại số lớn nhất M ở dòng đầu.
6. Mở mũi tên của **CITY → Value Filters → Equals** → chọn **FACT ACCIDENT Count**, nhập **M** → OK. Cách này giữ tất cả city đồng hạng.
7. Sau khi lọc CITY, kéo **STATE** vào Rows, đặt trên CITY để hiển thị rõ cặp State, City.
8. **Design → Report Layout → Show in Tabular Form**.
9. **Design → Subtotals → Do Not Show Subtotals**.

Nếu khi thêm STATE bộ lọc hoặc thứ tự thay đổi, giữ CITY Value Filter = M và kiểm tra tất cả dòng city đều có M vụ. M được lấy từ danh sách CITY toàn quốc trước khi thêm STATE.

**Đã kiểm chứng trên cube sau deploy:** Pittsburgh, PA, **8 vụ**.

## 5. Câu e: roll-up Tháng → Quý → Năm, tách Day/Night và cuối tuần

### 5.1. Kéo các trường

| Vùng Pivot | Trường |
|---|---|
| Rows | ID START DATE → Hierarchy |
| Columns, đầu tiên | ID START DATE → IS WEEKEND |
| Columns, tiếp theo | FACT ACCIDENT → SUNRISE SUNSET |
| Values | FACT ACCIDENT Count |

1. Xóa mọi lọc YEAR, QUARTER, Severity, bang còn sót từ sheet b.
2. SUNRISE SUNSET chỉ chọn **Day** và **Night**, bỏ member trống/Unknown nếu có.
3. IS WEEKEND giữ cả **False (0)** và **True (1)** theo khóa thực tế trong cube.
4. Hierarchy mở xuống đến **MONTH**, giữ cấp DAY thu gọn. Có thể chuột phải tên năm → **Expand/Collapse → Expand Entire Field**, lặp lại ở cấp quý.
5. **Design → Report Layout → Show in Outline Form**.
6. **Design → Subtotals → Show all Subtotals at Bottom of Group**.
7. Nếu chưa có subtotal năm/quý: chuột phải field YEAR/QUARTER → **Field Settings → Subtotals = Automatic**.
8. **Design → Grand Totals → Off for Rows and Columns** nếu chỉ muốn ba mức tháng/quý/năm.

### 5.2. Cách đọc và thao tác roll-up

- Dòng tháng: số vụ từng tháng, tách 0/Day, 0/Night, 1/Day, 1/Night.
- Dòng subtotal quý: tổng các tháng thuộc quý đó.
- Dòng subtotal năm: tổng các quý thuộc năm đó.
- Bấm **−** cạnh quý để thu các tháng; bấm **−** cạnh năm để thu các quý. Bấm **+** để mở lại.
- Giữ năm và quý mở đến tháng để cả ba mức hiện trên cùng Pivot.

Kiểm tra: subtotal quý phải bằng tổng các tháng; subtotal năm bằng tổng các quý, trong cùng một cột Day/Night và IS WEEKEND. Không cộng chung các dòng tháng, subtotal quý và subtotal năm vì chúng lặp cùng dữ liệu ở nhiều mức tổng hợp.

**Đối chiếu năm 2021 từ cube hiện tại, đã truy vấn ngày 08/10/2026:**

| IS WEEKEND | Day | Night |
|---|---:|---:|
| False / 0: ngày thường | 51.601 | 26.008 |
| True / 1: cuối tuần | 15.227 | 8.519 |

Tổng chỉ Day/Night không bao gồm những dòng thiếu Sunrise_Sunset. Bảng trên phân nhóm theo IS_WEEKEND đang có trong kho dữ liệu.

Đề gốc ghi “dùng ROLLUP”. Pivot thực hiện thao tác roll-up bằng hierarchy/subtotal; nếu giảng viên còn yêu cầu truy vấn có từ khóa SQL ROLLUP thì ảnh Pivot này cần đi cùng truy vấn đó. Hướng dẫn hiện tại tập trung phần kéo thả theo yêu cầu.

## 6. Câu f: Top 5 cặp đường–thành phố tại California

Liệt kê Top 5 cặp đường và thành phố tại California (`State = 'CA'`) có số vụ tai nạn cao nhất, chỉ tính các vụ xảy ra ban đêm (`Sunrise_Sunset = 'Night'`) tại nơi có đèn giao thông (`Traffic_Signal = 1`), kèm số vụ của từng địa điểm và lấy cả các địa điểm đồng hạng ở vị trí thứ 5.

Thực hiện theo [hướng dẫn câu f](Huong_dan_cau_f_Top5.md): manual Visual Studio trước, Pivot Excel sau. Bộ lọc là **STATE=CA**, **TRAFFIC SIGNAL=True**, **SUNRISE SUNSET=Night**; measure là **FACT ACCIDENT Count**. Xác định thứ hạng trên STREET toàn bang trước khi thêm CITY để trình bày.

Kết quả đã đối chiếu từ cube ngày 08/10/2026:

| City | Street | Số vụ |
|---|---|---:|
| Los Angeles | I-5 N | 11 |
| Los Angeles | I-10 E | 10 |
| Los Angeles | Harbor Fwy S | 9 |
| Culver City | I-405 N | 8 |
| Los Angeles | E Imperial Hwy | 8 |
| Los Angeles | E Olympic Blvd | 8 |

Vị trí thứ 5 đạt 8 vụ; có 6 địa điểm vì giữ cả đồng hạng. Nếu dữ liệu thay đổi, xác định lại ngưỡng thứ 5.

## 7. Lưu kết quả và ảnh manual

- Workbook b, e: [Pivot_Excel/](../Pivot_Excel/). Lưu câu f vào `Pivot_Excel/Pivot_f.xlsx` khi hoàn thành.
- Manual: chụp bảng kết quả cùng bộ lọc và lưu trong thư mục `Ket_qua/` của project.
- **b:** giữ ảnh Q2/2021, severity 4 và City/State có số vụ cao nhất.
- **e:** giữ ảnh cấp tháng, quý, năm với IS WEEKEND và Day/Night.
- **f:** giữ ảnh STATE=CA, TRAFFIC SIGNAL=True, SUNRISE SUNSET=Night và danh sách Top 5 kèm đồng hạng.

Ctrl+S trong Visual Studio lưu project. Thay trường hoặc bộ lọc trong Browser không cần Deploy lại; lưu ảnh trước khi đổi sang câu tiếp theo.

## 8. Kiểm tra nhanh khi kết quả khác dự kiến

| Hiện tượng | Kiểm tra |
|---|---|
| Không thấy Day/Night | Attribute SUNRISE SUNSET trong FACT ACCIDENT; cube visibility; Deploy/Process; Refresh connection Excel |
| Nhiều dòng 2021 hoặc CA giống nhau | KeyColumns còn chứa cột cấp chi tiết; sửa theo bảng và Process Full |
| Quý 2 xuất hiện nhiều lần | Chọn riêng Q2 dưới năm 2021 trong hierarchy, không chọn thêm cả năm |
| f thiếu hoặc dư đường | Kiểm tra ba bộ lọc; xác định ngưỡng thứ 5 trên STREET toàn CA trước khi thêm CITY; giữ đồng hạng |
| Không kéo CITY riêng được | Lấy attribute CITY trong DIM LOCATION → More Fields thay vì cấp CITY dưới Location_BEF |
| Số vụ khác CSV | Nguồn nạp, xử lý ETL, fact trùng, bộ lọc còn sót hoặc dùng ngày kết thúc |

Các file trong [SSAS/MDX_b_e_f/](../SSAS/MDX_b_e_f/) lưu truy vấn trước đó; f1/f2 dùng phiên bản đề f cũ và chưa tương ứng câu Top 5 hiện tại.

## 9. Tài liệu Microsoft đã kiểm tra

- Khóa ghép quý/tháng trong dimension: https://learn.microsoft.com/en-us/analysis-services/multidimensional-tutorial/lesson-3-4-modifying-the-date-dimension
- Hierarchy và đường dẫn điều hướng: https://learn.microsoft.com/en-us/analysis-services/multidimensional-models-olap-logical-dimension-objects/user-hierarchies
- Pivot với nguồn ngoài, gồm Analysis Services: https://support.microsoft.com/en-gb/excel/create-a-pivottable-with-an-external-data-source
- Bật legacy wizard: https://support.microsoft.com/en-us/excel/data-import-and-analysis-options-in-excel
- Value Filters: https://support.microsoft.com/en-us/excel/get-started/filter-data-in-a-pivottable
- Expand/Collapse: https://support.microsoft.com/en-US/Excel/expand-collapse-or-show-details-in-a-pivottable-or-pivotchart
