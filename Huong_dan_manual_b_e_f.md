# Hướng dẫn làm câu b, e, f bằng Visual Studio SSAS và PivotTable Excel

## 1. File đã đọc và công cụ sử dụng

- Đề: `ngu_canh_va_bo_cau_hoi_nghiep_vu.md`, phần 15 câu hỏi.
- Báo cáo: `24520814_24521985_SSIS.docx`, phần SSAS, PivotTable và MDX.
- Cấu trúc SQL: `QueryProject.sql`.
- Project thực tế: `SSAS/SSAS.slnx`, `SSAS/SSAS/SSAS.dwproj`, các file `.dim`, `.dsv`, `.cube`.
- Dữ liệu đối chiếu: `archive/Accidents_500.csv`, đúng 500.000 dòng.

Làm bằng **Visual Studio có extension Microsoft Analysis Services Projects**, sau đó kéo thả trên **Excel desktop cho Windows**. VS Code có thể đọc file nhưng các màn hình Dimension Structure, Attribute Relationships và Cube Designer dưới đây nằm trong Visual Studio.

Không cần chạy lại `QueryProject.sql`: file đó có lệnh DROP/TRUNCATE. Hướng dẫn này dùng kho dữ liệu đã nạp.

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
10. Đổi tên sheet đầu thành **b**. Sao chép sheet này bằng chuột phải tab → **Move or Copy → Create a copy**, hoặc tạo Pivot mới từ cùng connection. Đặt các sheet **e**, **f_1**, **f_2**, **f_hour**.
11. Khi sao chép, kéo các trường đang dùng ra khỏi Rows/Columns/Filters/Values để bố trí lại cho bài mới. Kiểm tra bộ lọc của từng sheet, nhất là Severity.

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

## 6. Câu f, bước 1: bang nhiều vụ ban đêm tại nơi có đèn giao thông

### 6.1. Kéo các trường trên sheet f_1

| Vùng Pivot | Trường |
|---|---|
| Filters | DIM TRAFFIC SIGNAL → TRAFFIC SIGNAL |
| Filters | FACT ACCIDENT → SUNRISE SUNSET |
| Rows | DIM LOCATION → STATE |
| Columns | DIM SEVERITY → ID SEVERITY |
| Values | FACT ACCIDENT Count |

1. TRAFFIC SIGNAL chọn **True/1**, tùy nhãn BIT hiện trong cube.
2. SUNRISE SUNSET chọn **Night**.
3. Severity giữ **tất cả mức 1, 2, 3, 4**. Không lọc chỉ 3–4 vì mẫu số cần tất cả vụ thỏa điều kiện đèn giao thông + ban đêm.
4. Không thêm lọc năm: câu f dùng toàn bộ dữ liệu.
5. **Design → Grand Totals → On for Rows and Columns** để có tổng mỗi bang ở cột bên phải.
6. Chuột phải một ô **Grand Total của bang** → **Sort → Largest to Smallest**.
7. Bang đứng đầu là bang dùng ở bước 2. Nếu có bang đồng hạng, thực hiện bước 2 cho từng bang đó.

### 6.2. Tỷ lệ mức 3–4 bằng thao tác Excel

Tỷ lệ = (số vụ mức 3 + số vụ mức 4) / tổng số vụ của chính bang, trong điều kiện đèn giao thông + Night.

1. Ở cột trống ngay bên phải Pivot, gõ tiêu đề **Tỷ lệ mức 3–4**.
2. Tại dòng bang đầu, gõ `=(`, nhấp ô số vụ mức 3, gõ `+`, nhấp ô số vụ mức 4, gõ `)/`, nhấp ô Grand Total của chính dòng đó → Enter.
3. Excel có thể tự tạo GETPIVOTDATA khi nhấp ô. Để kéo công thức xuống theo từng dòng một cách đơn giản, tắt **PivotTable Analyze → Options ▼ → Generate GetPivotData** rồi nhập lại bằng cách nhấp các ô.
4. Ví dụ nếu A là bang; B/C/D/E là mức 1/2/3/4; F là Grand Total; dòng đầu là 5: công thức ở G5 là `=(D5+E5)/F5`.
5. Chọn ô kết quả → **Home → Number → Percentage**, đặt 2 chữ số thập phân; kéo fill handle xuống các dòng bang, dừng trước dòng Grand Total toàn quốc.
6. Nếu cube không có một cột severity vì không có dữ liệu, chọn đúng các ô hiện hữu; mức không có vụ đóng góp 0, không cố dùng vị trí D/E của ví dụ.
7. Sau khi Refresh/sắp xếp lại, kiểm tra công thức còn nằm đúng dòng bang và không bị Pivot mở rộng đè lên.

**Đã kiểm chứng trên cube:** California (**CA**) đứng đầu: **3.046 vụ**, mức 3–4 **258 vụ**, tỷ lệ **8,47%**.

## 7. Câu f, bước 2: City → Street, lọc trên 50 vụ

### 7.1. Kéo các trường trên sheet f_2

| Vùng Pivot | Trường |
|---|---|
| Filters | DIM LOCATION → STATE |
| Filters | DIM TRAFFIC SIGNAL → TRAFFIC SIGNAL |
| Filters | FACT ACCIDENT → SUNRISE SUNSET |
| Rows, đầu tiên | DIM LOCATION → CITY |
| Rows, tiếp theo | DIM LOCATION → STREET |
| Values | FACT ACCIDENT Count |

1. STATE chọn bang đứng đầu ở f_1, ví dụ **CA**.
2. TRAFFIC SIGNAL giữ **True/1**; SUNRISE SUNSET giữ **Night**.
3. Severity giữ tất cả. Không mang lọc Severity 4 từ câu b sang.
4. **Design → Report Layout → Show in Tabular Form → Repeat All Item Labels**.
5. **Design → Subtotals → Do Not Show Subtotals**; tắt Grand Totals nếu chỉ cần danh sách đường.
6. Mở mũi tên **STREET → Value Filters → Greater Than**.
7. Chọn **FACT ACCIDENT Count**, nhập **50** → OK.
8. Lọc đúng field STREET; điều kiện là **> 50**, không phải >= 50 và không đặt ở CITY.

### 7.2. Kết quả rỗng trong file 500.000 dòng là hợp lệ

Trong cube đã kiểm tra ngày 08/10/2026, **không có đường nào ở CA thỏa >50 vụ** dưới đồng thời hai điều kiện Traffic_Signal=True và Sunrise_Sunset=Night. Đường nhiều nhất là **I-5 N, Los Angeles: 11 vụ**.

Nếu cube nạp đúng mẫu đó, sau khi áp dụng >50 Pivot sẽ không còn dòng đường. Chụp lại Pivot với STATE=CA, TRAFFIC SIGNAL=True, SUNRISE SUNSET=Night và bộ lọc >50 để báo cáo:

> California có tổng số vụ cao nhất trong nhóm có đèn giao thông và xảy ra ban đêm. Khi drill-down theo thành phố và đường, không có đường nào có trên 50 vụ trong bộ dữ liệu 500.000 bản ghi, nên bước 2 không trả về dòng kết quả.

Không đổi điều kiện đề để tạo ra kết quả. Nếu cube đang nạp file `Accidents(16-23).csv` hoặc tập dữ liệu khác, số liệu và danh sách đường có thể khác; dùng kết quả của cube thực tế.

## 8. Cách kéo thả tìm giờ nhiều vụ nhất cho mỗi đường

Phần này dùng khi dữ liệu thực tế có đường >50. Với mẫu 500.000 dòng, có thể dùng riêng một đường làm minh họa thao tác; minh họa không thuộc đáp án f bước 2.

### 8.1. Xem một đường, cách dễ nhất

1. Trên sheet **f_hour**, giữ các Filters: STATE, TRAFFIC SIGNAL=True, SUNRISE SUNSET=Night.
2. Kéo thêm **CITY** và **STREET** vào Filters; chọn đúng một cặp city/street từ danh sách f_2.
3. Kéo **ID START TIME → HOUR** vào Rows.
4. Kéo **FACT ACCIDENT Count** vào Values.
5. Chuột phải ô số vụ → **Sort → Largest to Smallest**.
6. Giờ ở đầu có số vụ lớn nhất. Nếu nhiều giờ có cùng số vụ lớn nhất, ghi lại tất cả các giờ đó.
7. Giờ H thể hiện khoảng H:00 đến trước (H+1):00, ví dụ 20 là 20:00–20:59; đây là giờ bắt đầu tai nạn, không phải giờ kết thúc.
8. Lặp lại cho mỗi đường thỏa >50. Ghi City, Street, tổng số vụ từ f_2, giờ cao điểm và số vụ ở giờ đó vào bảng kết luận.

**Minh họa ngoài đáp án f:** lọc CA / Los Angeles / I-5 N / Traffic Signal=True / Night. Tổng 11 vụ; các giờ **02, 05, 20** đồng hạng cao nhất, mỗi giờ **2 vụ**.

### 8.2. Xem nhiều đường cùng lúc

1. Tạo Pivot với Filters giống f_2.
2. Rows: **CITY → STREET**; Columns: **ID START TIME → HOUR**; Values: **FACT ACCIDENT Count**.
3. Chỉ giữ các đường đã xác định thỏa >50 ở f_2. Nếu thêm HOUR làm bộ lọc >50 thay đổi theo giờ đang chọn, dùng danh sách f_2 để chọn các member STREET cần xem, giữ toàn bộ giờ.
4. Bật tổng mỗi dòng; tổng các ô giờ của một đường phải bằng tổng số vụ đường đó ở f_2.
5. Chọn vùng số vụ theo giờ → **Home → Conditional Formatting → Color Scales** để nhìn giờ nổi bật.
6. Đọc ô lớn nhất trên từng dòng STREET và ghi các tiêu đề giờ tương ứng; giữ tất cả giờ đồng hạng. Không lấy dòng subtotal CITY làm kết quả của STREET.
7. Không áp dụng Top 1 chung lên HOUR để tìm giờ cho mọi đường: mỗi đường có giờ cực đại riêng. Cách 8.1 là cách manual dễ kiểm chứng nhất.

## 9. Nội dung nên chụp để đưa vào báo cáo

- **b:** bộ lọc năm 2021, quý 2, severity 4 và bảng City/State có số vụ lớn nhất; giữ tất cả đồng hạng.
- **e:** một Pivot mở đến tháng, có subtotal quý/năm, các cột IS WEEKEND và Day/Night; thêm ảnh thu gọn cấp quý hoặc năm nếu cần minh họa roll-up.
- **f_1:** bộ lọc đèn giao thông + Night, các mức severity, tổng số vụ và tỷ lệ mức 3–4; bang đứng đầu hiện rõ.
- **f_2:** bộ lọc bang đứng đầu + đèn giao thông + Night, STREET >50. Với mẫu đã kiểm tra, ghi nhận kết quả rỗng.
- **f_hour:** chỉ đưa vào đáp án chính khi có đường >50; nếu minh họa đường I-5 N thì ghi rõ đây là minh họa thao tác ngoài tập kết quả.

## 10. Kiểm tra nhanh khi kết quả khác dự kiến

| Hiện tượng | Kiểm tra |
|---|---|
| Không thấy Day/Night | Attribute SUNRISE SUNSET trong FACT ACCIDENT; cube visibility; Deploy/Process; Refresh connection Excel |
| Nhiều dòng 2021 hoặc CA giống nhau | KeyColumns còn chứa cột cấp chi tiết; sửa theo bảng và Process Full |
| HOUR có nhiều member cùng nhãn | HOUR phải chỉ có khóa HOUR; Process lại DIM TIME/cube |
| Quý 2 xuất hiện nhiều lần | Khóa YEAR + QUARTER tạo quý riêng mỗi năm; chọn Q2 dưới năm 2021 |
| Tỷ lệ mức 3–4 thành 100% | Đang lọc chỉ severity 3/4; bỏ lọc đó để giữ mẫu số tất cả severity |
| f_2 rỗng | Có thể đúng: mẫu này đường nhiều nhất chỉ 11 vụ; xác nhận điều kiện và nguồn ETL |
| Số vụ khác CSV | Nguồn nạp khác, ETL xử lý thiếu, fact bị nạp trùng, lọc còn sót, hoặc dùng ngày/giờ kết thúc |

Các số đối chiếu b, e, f ở trên đã được truy vấn trực tiếp trên cube sau khi bạn Deploy/Process thành công ngày 08/10/2026. Các file MDX đã kiểm chứng nằm trong `SSAS/MDX_b_e_f/`; bạn có thể hoàn thành phần kéo thả trước theo hướng dẫn này.

## 11. Tài liệu Microsoft đã kiểm tra

- Khóa ghép quý/tháng trong dimension: https://learn.microsoft.com/en-us/analysis-services/multidimensional-tutorial/lesson-3-4-modifying-the-date-dimension
- Hierarchy và đường dẫn điều hướng: https://learn.microsoft.com/en-us/analysis-services/multidimensional-models-olap-logical-dimension-objects/user-hierarchies
- Pivot với nguồn ngoài, gồm Analysis Services: https://support.microsoft.com/en-gb/excel/create-a-pivottable-with-an-external-data-source
- Bật legacy wizard: https://support.microsoft.com/en-us/excel/data-import-and-analysis-options-in-excel
- Value Filters: https://support.microsoft.com/en-us/excel/get-started/filter-data-in-a-pivottable
- Expand/Collapse: https://support.microsoft.com/en-US/Excel/expand-collapse-or-show-details-in-a-pivottable-or-pivotchart
