# HƯỚNG DẪN THỰC HIỆN VÀ VIẾT CHƯƠNG 4

## Khai thác và trực quan hóa dữ liệu US Accidents

Tài liệu này hướng dẫn setup môi trường, tạo báo cáo bằng Cube Browser, PivotTable Excel và MDX, đồng thời trình bày cách chụp hình và viết từng mục trong Chương 4 của báo cáo dự án `US Accidents`.

> **Lưu ý:** Các ảnh trong báo cáo phải là ảnh chụp thật từ project SSAS, Excel và SSMS của nhóm.

---

## 1. Mục tiêu của Chương 4

Chương 4 trình bày quá trình khai thác dữ liệu từ kho dữ liệu `US_Accidents_DW` thông qua cube `US Accidents DW`.

Nội dung gồm:

- Kết nối và kiểm tra cube SSAS.
- Tạo báo cáo bằng Cube Browser trong Visual Studio.
- Tạo PivotTable trong Microsoft Excel.
- Kiểm tra và đối chiếu kết quả bằng truy vấn MDX.
- Trình bày kết quả bằng bảng, hình ảnh và nhận xét nghiệp vụ.

Có thể dùng đoạn mở đầu sau trong báo cáo:

> Chương này trình bày quá trình khai thác dữ liệu từ kho dữ liệu `US_Accidents_DW` thông qua mô hình cube `US Accidents DW`. Các báo cáo được thực hiện bằng ba phương pháp: Cube Browser trong Visual Studio, PivotTable trong Microsoft Excel và truy vấn MDX trong SQL Server Management Studio. Kết quả của các phương pháp được đối chiếu nhằm đảm bảo tính chính xác và thống nhất của số liệu.

---

## 2. Chuẩn bị môi trường

### 2.1. Phần mềm cần sử dụng

1. SQL Server.
2. SQL Server Analysis Services – Multidimensional.
3. Visual Studio.
4. Extension **Microsoft Analysis Services Projects**.
5. Extension **Integration Services Projects** nếu cần kiểm tra SSIS.
6. Microsoft Excel desktop cho Windows.
7. SQL Server Management Studio – SSMS.

VS Code chỉ dùng để đọc và chỉnh sửa file tài liệu. Các màn hình Cube Designer và Cube Browser cần thực hiện trong Visual Studio.

### 2.2. Các file chính trong dự án

| Thành phần | Đường dẫn |
|---|---|
| Solution SSAS | `D:\OLAP\Pro\SSAS\SSAS.slnx` |
| Project SSAS | `D:\OLAP\Pro\SSAS\SSAS\SSAS.dwproj` |
| Cube | `D:\OLAP\Pro\SSAS\SSAS\US Accidents DW.cube` |
| Data Source | `D:\OLAP\Pro\SSAS\SSAS\US Accidents DW.ds` |
| Data Source View | `D:\OLAP\Pro\SSAS\SSAS\US Accidents DW.dsv` |
| MDX câu a | `D:\OLAP\Pro\SSAS\MDX_a\a.mdx` |
| MDX câu b, e, f | `D:\OLAP\Pro\SSAS\MDX_b_e_f\` |
| Excel câu a | `D:\OLAP\Pro\Pivot_Excel\Pivot_a.xlsx` |
| Excel câu b | `D:\OLAP\Pro\Pivot_Excel\Pivot_b.xlsx` |
| Excel câu e | `D:\OLAP\Pro\Pivot_Excel\Pivot_e.xlsx` |
| Thư mục lưu ảnh | `D:\OLAP\Pro\Tai_lieu\Bao_cao\Hinh_Chuong_4\` |

---

## 3. Kiểm tra và triển khai cube

### 3.1. Mở project

1. Mở Visual Studio.
2. Chọn **File → Open → Project/Solution**.
3. Mở `D:\OLAP\Pro\SSAS\SSAS.slnx`.
4. Nếu không hỗ trợ `.slnx`, mở `D:\OLAP\Pro\SSAS\SSAS\SSAS.dwproj`.

### 3.2. Kiểm tra Data Source

Trong Solution Explorer:

1. Mở **Data Sources**.
2. Nhấp đúp `US Accidents DW.ds`.
3. Chọn **Edit** ở phần Connection String.
4. Kiểm tra server SQL Server và database `US_Accidents_DW`.
5. Chọn **Test Connection**.
6. Nếu kết nối thành công, nhấn **OK**.

Nếu server trên máy khác với server trong project, đổi connection string sang server thực tế.

### 3.3. Kiểm tra cấu trúc cube

Mở `SSAS → SSAS → Cubes → US Accidents DW.cube`.

Kiểm tra:

- Measure Group: `FACT ACCIDENT`.
- Measure: `FACT ACCIDENT Count`.
- Measures: `DISTANCE`, `TEMPERATURE`, `HUMIDITY`, `PRESSURE`, `VISIBILITY`, `WIND SPEED`, `PRECIPITATION`.
- Dimensions: `DIM DATE`, `DIM TIME`, `DIM LOCATION`, `DIM ROAD STRUCTURE`, `DIM TRAFFIC SIGNAL`, `DIM SEVERITY`, `DIM WEATHER`.

### 3.4. Deploy và Process cube

Nếu cube đã Deploy và Process thành công thì không cần làm lại. Khi cần:

1. Chuột phải project SSAS → **Build**.
2. Chọn **Deploy**.
3. Mở tab **Browser** của cube.
4. Chọn **Process** nếu dữ liệu chưa cập nhật.
5. Chọn **Process Full** và chờ hoàn tất.

### 3.5. Ảnh cần chụp

- **Hình 4.1. Cấu hình Data Source kết nối đến cơ sở dữ liệu US_Accidents_DW**.
- **Hình 4.2. Các measure và dimension trong cube US Accidents DW**.
- **Hình 4.3. Kết quả Deploy và Process cube thành công**.

Ảnh cần thể hiện rõ tên server, database, cube hoặc thông báo thành công.

---

## 4. Quy tắc chụp hình và chèn ảnh vào Word

Mỗi bước nên thực hiện theo thứ tự:

1. Thực hiện thao tác.
2. Chụp màn hình ngay sau thao tác.
3. Lưu ảnh PNG.
4. Chèn ảnh vào Word.
5. Thêm chú thích hình.
6. Viết nhận xét ngắn.
7. Chuyển sang bước tiếp theo.

Lưu ảnh tại `D:\OLAP\Pro\Tai_lieu\Bao_cao\Hinh_Chuong_4\`.

Tên ảnh nên đặt như sau:

```text
Hinh_4_1_DataSource.png
Hinh_4_2_CubeDesigner.png
Hinh_4_3_DeploySuccess.png
Hinh_4_4_CubeBrowser_Junction_US.png
```

Khi chụp ảnh:

- Dùng `Win + Shift + S`.
- Phóng to Visual Studio hoặc Excel.
- Kéo rộng cột để không bị rút gọn số.
- Đảm bảo ảnh thấy được filter và measure.
- Không để con trỏ che kết quả.
- Không cắt mất tên cube hoặc tên trường.

Khi chèn vào Word, căn giữa ảnh, không để ảnh vượt lề và giữ ảnh cùng chú thích gần nhau.

Mẫu chú thích:

> **Hình 4.x. [Mô tả ngắn gọn nội dung hình]**

---

## 5. Tạo báo cáo bằng Cube Browser

### 5.1. Mở Cube Browser

1. Mở `US Accidents DW.cube`.
2. Chọn tab **Browser**.
3. Chọn measure group `FACT ACCIDENT`.
4. Xóa filter của câu trước nếu có.
5. Thêm measure `FACT ACCIDENT Count`.
6. Kéo các dimension cần phân tích vào vùng kết quả.
7. Chọn **Execute** hoặc nút `!`.

### 5.2. Cấu trúc chung của một câu báo cáo

```text
4.x. Tên câu hỏi nghiệp vụ

4.x.1. Mục tiêu
4.x.2. Dữ liệu và bộ lọc
4.x.3. Các bước thực hiện
4.x.4. Kết quả
4.x.5. Nhận xét
```

Mẫu mở đầu:

> Mục tiêu của câu hỏi là thống kê số vụ tai nạn theo từng năm, đồng thời phân tích sự khác biệt giữa toàn quốc và bang California trong các điều kiện hạ tầng khác nhau.

---

# 6. Câu a – Phân tích hạ tầng giao thông theo năm

## 6.1. Nội dung câu a

Thống kê số vụ tai nạn theo từng năm tại:

- Giao lộ: `JUNCTION = 1`.
- Vòng xoay: `ROUNDABOUT = 1`.
- Đường sắt: `RAILWAY = 1`.
- Đèn giao thông: `TRAFFIC_SIGNAL = 1`.

Kết quả cần thực hiện ở hai phạm vi: toàn quốc và California (`STATE = CA`). Trong cube, giá trị `BIT` hiển thị thành `True/False`, nên `JUNCTION = 1` tương ứng với `JUNCTION = True`.

Một vụ tai nạn có thể đồng thời thỏa nhiều điều kiện hạ tầng. Không được cộng bốn nhóm kết quả để gọi là tổng số vụ tai nạn.

## 6.2. Thiết lập chung

- Rows: `DIM DATE → YEAR`.
- Measure: `FACT ACCIDENT Count`.
- Filter: một trong các thuộc tính `JUNCTION`, `ROUNDABOUT`, `RAILWAY`, `TRAFFIC SIGNAL`.
- Filter bổ sung khi cần: `DIM LOCATION → STATE = CA`.

## 6.3. Junction toàn quốc

1. Xóa filter cũ.
2. Kéo `YEAR` vào vùng kết quả.
3. Thêm `FACT ACCIDENT Count`.
4. Kéo `DIM ROAD STRUCTURE → JUNCTION` vào Filter.
5. Chọn `JUNCTION = True`.
6. Để `STATE = All`.
7. Execute.

Ảnh: **Hình 4.4. Thiết lập bộ lọc Junction bằng True trên toàn quốc**.

Mô tả mẫu:

> Đầu tiên, nhóm chọn measure `FACT ACCIDENT Count` và thuộc tính `YEAR` để thống kê số vụ tai nạn theo năm. Điều kiện `JUNCTION = True` được thiết lập trong vùng Filter.

Nhận xét mẫu:

> Kết quả tại Hình 4.4 thể hiện số vụ tai nạn theo từng năm tại các vị trí có giao lộ trên toàn quốc. Measure được sử dụng là `FACT ACCIDENT Count`, còn thuộc tính `YEAR` được lấy từ dimension ngày bắt đầu xảy ra tai nạn.

## 6.4. Junction tại California

Giữ `JUNCTION = True`, thêm `DIM LOCATION → STATE = CA`, sau đó Execute.

Ảnh: **Hình 4.5. Số vụ tai nạn tại giao lộ ở bang California theo năm**.

> Sau khi thêm điều kiện `STATE = CA`, kết quả chỉ phản ánh các vụ tai nạn xảy ra tại bang California. Kết quả này được sử dụng để so sánh xu hướng của California với xu hướng toàn quốc.

## 6.5. Roundabout

Thay filter bằng `ROUNDABOUT = True`, thực hiện hai lần: toàn quốc và California.

- **Hình 4.6. Số vụ Roundabout trên toàn quốc**.
- **Hình 4.7. Số vụ Roundabout tại California**.

## 6.6. Railway

Thay filter bằng `RAILWAY = True`, thực hiện hai lần: toàn quốc và California.

- **Hình 4.8. Số vụ Railway trên toàn quốc**.
- **Hình 4.9. Số vụ Railway tại California**.

## 6.7. Traffic Signal

Thay filter bằng `TRAFFIC SIGNAL = True`, thực hiện hai lần: toàn quốc và California.

- **Hình 4.10. Số vụ tại nơi có đèn giao thông trên toàn quốc**.
- **Hình 4.11. Số vụ tại nơi có đèn giao thông ở California**.

## 6.8. Bảng tổng hợp câu a

| Điều kiện | Phạm vi | Năm cao nhất | Số vụ cao nhất |
|---|---|---:|---:|
| Junction | Toàn quốc | 2022 | 7.378 |
| Junction | California | 2020 | 2.202 |
| Railway | Toàn quốc | 2021 | 830 |
| Railway | California | 2021 | 213 |
| Traffic Signal | Toàn quốc | 2020 | 13.336 |
| Traffic Signal | California | 2020 | 1.564 |

Các giá trị trong bảng phải được đối chiếu lại với kết quả thực tế trước khi nộp.

> Kết quả cho thấy số vụ tại nơi có đèn giao thông cao hơn đáng kể so với các nhóm hạ tầng còn lại. Điều này có thể xuất phát từ việc đèn giao thông thường được lắp đặt tại các giao lộ lớn, nơi mật độ phương tiện cao. Tuy nhiên, kết quả chỉ phản ánh số vụ tai nạn có xuất hiện thuộc tính tương ứng, không đủ để kết luận rằng hạ tầng đó là nguyên nhân gây ra tai nạn.

---

# 7. Câu b – Severity 4 theo thành phố và bang

## 7.1. Nội dung

Phân tích các vụ tai nạn có `SEVERITY = 4`, `YEAR = 2021`, `QUARTER = Q2`, theo bang và thành phố.

## 7.2. Thiết lập Cube Browser

Filter:

```text
YEAR = 2021
QUARTER = Q2
SEVERITY = 4
```

Rows:

```text
DIM LOCATION → STATE
DIM LOCATION → CITY
```

Measure: `FACT ACCIDENT Count`.

Ảnh:

- **Hình 4.12. Thiết lập bộ lọc năm 2021, quý 2 và Severity 4**.
- **Hình 4.13. Kết quả thống kê Severity 4 theo bang và thành phố**.

> Kết quả cho thấy số vụ tai nạn Severity 4 tập trung không đồng đều giữa các bang và thành phố. Việc phân tích theo cấp bang trước, sau đó drill-down xuống thành phố, giúp xác định các khu vực có số vụ nghiêm trọng cao nhất.

Nếu có thành phố đứng đầu:

> Thành phố có số vụ Severity 4 cao nhất trong điều kiện lọc hiện tại là `[tên thành phố]`, với `[số vụ]` vụ.

---

# 8. Câu e – Roll-up thời gian và phân tích ngày/cuối tuần

## 8.1. Nội dung

Phân tích theo cấu trúc thời gian `Month → Quarter → Year`, đồng thời phân biệt `IS_WEEKEND` và `SUNRISE_SUNSET`.

## 8.2. Cấu hình Cube Browser

Rows:

```text
YEAR
QUARTER
MONTH
```

Columns hoặc Filters:

```text
IS_WEEKEND
SUNRISE_SUNSET
```

Measure: `FACT ACCIDENT Count`.

Ảnh:

- **Hình 4.14. Phân tích số vụ tai nạn theo tháng, quý và năm**.
- **Hình 4.15. Phân biệt số vụ giữa ngày thường và cuối tuần**.
- **Hình 4.16. Phân biệt số vụ giữa ban ngày và ban đêm**.

> Báo cáo sử dụng cấu trúc phân cấp thời gian để thực hiện thao tác drill-down từ năm xuống quý và tháng. Người dùng có thể xem tổng số vụ ở cấp năm, sau đó mở rộng từng năm để quan sát biến động theo quý và tháng.

> Ngược lại, thao tác roll-up cho phép tổng hợp dữ liệu từ cấp tháng lên cấp quý và cấp năm.

> Số vụ tai nạn có sự khác biệt giữa ngày thường và cuối tuần. Việc phân loại theo Day/Night cho phép nhận biết thời điểm xảy ra nhiều tai nạn hơn. Tuy nhiên, cần xem xét thêm lưu lượng phương tiện, điều kiện thời tiết và độ đầy đủ của dữ liệu trước khi đưa ra kết luận nguyên nhân.

---

# 9. Câu f – Top 5 cặp đường và thành phố tại California

## 9.1. Nội dung

Điều kiện lọc:

```text
STATE = CA
TRAFFIC_SIGNAL = True
SUNRISE_SUNSET = Night
```

Thống kê theo `CITY` và `STREET`, sử dụng measure `FACT ACCIDENT Count`.

## 9.2. Các bước thực hiện

1. Mở `US Accidents DW.cube` → **Browser**.
2. Xóa trường và filter của câu trước.
3. Đặt ba bộ lọc: `STATE = CA`, `TRAFFIC SIGNAL = True`, `SUNRISE SUNSET = Night`.
4. Kéo `CITY`, `STREET` và `FACT ACCIDENT Count` vào vùng kết quả.
5. Execute.
6. Xác định thứ hạng theo số vụ.
7. Xác định giá trị tại vị trí thứ 5, gọi là `M`.
8. Giữ tất cả địa điểm có số vụ lớn hơn hoặc bằng `M`.

Cần xác định Top 5 trên danh sách đường trước khi thêm thành phố. Không đặt Top 5 riêng cho từng thành phố.

## 9.3. Kết quả tham khảo

| Thành phố | Đường | Số vụ |
|---|---|---:|
| Los Angeles | I-5 N | 11 |
| Los Angeles | I-10 E | 10 |
| Los Angeles | Harbor Fwy S | 9 |
| Culver City | I-405 N | 8 |
| Los Angeles | E Imperial Hwy | 8 |
| Los Angeles | E Olympic Blvd | 8 |

Vị trí thứ 5 có số vụ bằng 8 và có nhiều địa điểm đồng hạng, vì vậy kết quả gồm 6 dòng thay vì đúng 5 dòng. Cần xác nhận lại nếu dữ liệu hoặc cube thay đổi.

## 9.4. Các ảnh cần chụp

- **Hình 4.17. Thiết lập ba bộ lọc cho câu f**.
- **Hình 4.18. Xếp hạng các tuyến đường theo số vụ tai nạn**.
- **Hình 4.19. Kết quả Top 5 đường–thành phố tại California, bao gồm các trường hợp đồng hạng**.

> Kết quả cho thấy tuyến I-5 N có số vụ cao nhất với 11 vụ, tiếp theo là I-10 E với 10 vụ và Harbor Fwy S với 9 vụ. Có ba địa điểm cùng đạt 8 vụ tại vị trí thứ 5, vì vậy kết quả cuối cùng bao gồm 6 địa điểm.

---

# 10. Tạo PivotTable trong Excel

## 10.1. Kết nối Excel với SSAS

1. Mở Excel desktop.
2. Chọn **Data → Get Data → Legacy Wizards → From Data Connection Wizard**.
3. Hoặc chọn **Data → From Other Sources → From Analysis Services**.
4. Nhập server Analysis Services, ví dụ `LAPTOP-40H784NV\\SSASMD`.
5. Chọn database `SSAS`.
6. Chọn cube `US Accidents DW`.
7. Chọn **PivotTable Report** → **New Worksheet**.

Ảnh:

- **Hình 4.20. Kết nối Excel với Analysis Services**.
- **Hình 4.21. Chọn database SSAS và cube US Accidents DW**.

## 10.2. PivotTable câu a

| Vùng Excel | Trường |
|---|---|
| Rows | `YEAR` |
| Values | `FACT ACCIDENT Count` |
| Filters | `JUNCTION`, `ROUNDABOUT`, `RAILWAY`, `TRAFFIC SIGNAL` |
| Filters | `STATE` |

Nên tạo bốn sheet: `Junction`, `Roundabout`, `Railway`, `Traffic Signal`. Mỗi sheet có thể trình bày hai bảng: toàn quốc và California.

Ảnh:

- **Hình 4.22. PivotTable câu a – Junction**.
- **Hình 4.23. PivotTable câu a – Roundabout**.
- **Hình 4.24. PivotTable câu a – Railway**.
- **Hình 4.25. PivotTable câu a – Traffic Signal**.

## 10.3. PivotTable câu b

| Vùng | Trường |
|---|---|
| Rows | State, City |
| Values | FACT ACCIDENT Count |
| Filters | Year = 2021 |
| Filters | Quarter = Q2 |
| Filters | Severity = 4 |

## 10.4. PivotTable câu e

| Vùng | Trường |
|---|---|
| Rows | Year, Quarter, Month |
| Columns | IS_WEEKEND hoặc SUNRISE_SUNSET |
| Values | FACT ACCIDENT Count |

Chọn **Design → Report Layout → Show in Tabular Form** và **Design → Repeat All Item Labels** để bảng dễ đọc.

## 10.5. PivotTable câu f

Filters: `STATE = CA`, `TRAFFIC SIGNAL = True`, `SUNRISE SUNSET = Night`.

Rows ban đầu: `STREET`.

Values: `FACT ACCIDENT Count`.

1. Sort từ lớn đến nhỏ.
2. Xác định giá trị ở dòng thứ 5.
3. Chọn **Value Filters → Greater Than Or Equal To**.
4. Nhập giá trị ngưỡng.
5. Thêm `CITY` phía trên `STREET`.
6. Tắt subtotal nếu cần.
7. Lưu tại `D:\OLAP\Pro\Pivot_Excel\Pivot_f.xlsx`.

---

# 11. Kiểm tra kết quả bằng MDX

## 11.1. Mục đích

MDX được dùng để kiểm tra kết quả Cube Browser, đối chiếu với Excel, tạo bảng số liệu chính xác và phát hiện filter bị thiếu hoặc bị giữ lại từ câu trước.

## 11.2. Thực hiện

1. Mở SSMS.
2. Kết nối đến Analysis Services.
3. Chọn database `SSAS`.
4. Chọn cube `US Accidents DW`.
5. Mở các file MDX trong `D:\OLAP\Pro\SSAS\MDX_a\` và `D:\OLAP\Pro\SSAS\MDX_b_e_f\`.
6. Chạy truy vấn.
7. So sánh với Cube Browser và Excel.

Ảnh cần chụp:

- **Hình 4.26. Truy vấn MDX thực hiện câu hỏi nghiệp vụ**.
- **Hình 4.27. Kết quả trả về từ truy vấn MDX**.

Ảnh truy vấn cần thấy tên database, cube, measure và điều kiện filter. Ảnh kết quả cần thấy đầy đủ cột và số liệu.

---

# 12. Danh sách hình ảnh đề xuất

| Số hình | Nội dung |
|---|---|
| Hình 4.1 | Cấu hình Data Source |
| Hình 4.2 | Cấu trúc cube |
| Hình 4.3 | Deploy/Process thành công |
| Hình 4.4–4.11 | Cube Browser câu a |
| Hình 4.12–4.13 | Câu b |
| Hình 4.14–4.16 | Câu e |
| Hình 4.17–4.19 | Câu f |
| Hình 4.20–4.21 | Kết nối Excel |
| Hình 4.22–4.25 | PivotTable câu a |
| Hình 4.26–4.27 | MDX và kết quả MDX |

Nếu báo cáo chính có cách đánh số khác, đánh số liên tục theo toàn bộ báo cáo thay vì bắt buộc giữ số `4.x`.

---

# 13. Mẫu viết một mục báo cáo

```text
4.x. Tên câu hỏi nghiệp vụ

4.x.1. Mục tiêu

Mục tiêu của câu hỏi là ...

4.x.2. Dữ liệu và bộ lọc

Measure sử dụng là FACT ACCIDENT Count.
Các dimension được sử dụng gồm ...
Bộ lọc gồm ...

4.x.3. Thực hiện trên Cube Browser

Đầu tiên, nhóm mở cube US Accidents DW và chuyển sang tab Browser.
Sau đó, nhóm thêm các trường ... vào vùng kết quả.
Các điều kiện ... được thiết lập trong vùng Filter.

[Chèn hình tại đây]

Hình 4.x. ...

4.x.4. Kết quả

Bảng kết quả thu được như sau:

[Chèn bảng số liệu]

4.x.5. Nhận xét

Kết quả cho thấy ...
So sánh giữa ... cho thấy ...
Tuy nhiên, kết quả chỉ thể hiện mối liên hệ thống kê, không khẳng định quan hệ nhân quả.
```

Đặt ảnh ngay sau đoạn mô tả thao tác tương ứng, không gom tất cả ảnh xuống cuối mục.

---

# 14. Những lỗi cần tránh

1. Dùng nhầm `ID_START_DATE` và `ID_END_DATE`.
2. Để sót filter của câu trước.
3. Chọn `YEAR` nhưng không kiểm tra hierarchy.
4. Chọn đồng thời cả năm 2021 và Q2 riêng biệt khiến kết quả bị trùng.
5. Cộng các nhóm Junction, Railway, Roundabout và Traffic Signal với nhau.
6. Chụp ảnh không thấy filter hoặc tên measure.
7. Không giữ đồng hạng trong câu f.
8. Đặt Top 5 riêng cho từng thành phố.
9. Kết luận năm 2023 giảm mạnh mà không kiểm tra dữ liệu có đủ cả năm hay không.
10. Sử dụng ảnh minh họa không phải kết quả thực tế.
11. Không đối chiếu Cube Browser, Excel và MDX.
12. Không lưu workbook sau khi thay đổi filter hoặc bố cục.
13. Không kiểm tra báo cáo ở chế độ Print Layout.

---

# 15. Thứ tự thực hiện đề xuất

1. Kiểm tra kết nối và cube.
2. Deploy/Process nếu cần.
3. Làm câu a trên Cube Browser và chụp ảnh.
4. Làm câu b và chụp ảnh.
5. Làm câu e và chụp ảnh.
6. Làm câu f và chụp ảnh.
7. Mở hoặc tạo các workbook Excel.
8. Refresh và chụp ảnh PivotTable.
9. Chạy MDX kiểm tra.
10. Đối chiếu số liệu.
11. Viết nội dung Word.
12. Đánh số hình và bảng.
13. Kiểm tra toàn bộ báo cáo ở chế độ Print Layout.

---

# 16. Đoạn tổng kết Chương 4

> Qua quá trình khai thác cube bằng Cube Browser, PivotTable và MDX, nhóm đã xây dựng được các báo cáo phục vụ phân tích số vụ tai nạn theo thời gian, vị trí, mức độ nghiêm trọng và đặc điểm hạ tầng giao thông. Kết quả giữa các công cụ có sự thống nhất khi sử dụng cùng measure và điều kiện lọc. Các báo cáo giúp người dùng quan sát xu hướng tai nạn ở nhiều cấp độ khác nhau và hỗ trợ xác định những khu vực hoặc điều kiện cần được phân tích chuyên sâu hơn.

> Các kết quả thống kê trong chương chỉ phản ánh mối liên hệ giữa số vụ tai nạn và các thuộc tính được phân tích. Không nên sử dụng các kết quả này để khẳng định trực tiếp quan hệ nhân quả nếu chưa có thêm các biến giải thích như lưu lượng phương tiện, dân số, chất lượng hạ tầng hoặc điều kiện thời tiết.

---

## Tài liệu liên quan

- `D:\OLAP\Pro\README.md`
- `D:\OLAP\Pro\Tai_lieu\Huong_dan_bao_cao_cau_a.md`
- `D:\OLAP\Pro\Tai_lieu\Huong_dan_manual_b_e_f.md`
- `D:\OLAP\Pro\Tai_lieu\Huong_dan_cau_f_Top5.md`
- `D:\OLAP\Pro\Tai_lieu\ngu_canh_va_bo_cau_hoi_nghiep_vu.md`
- `D:\OLAP\Pro\Pivot_Excel\README.md`
- `D:\OLAP\Pro\SSAS\MDX_a\a.mdx`
- `D:\OLAP\Pro\SSAS\MDX_b_e_f\`

> Trước khi nộp báo cáo, thay toàn bộ vị trí ảnh bằng screenshot thật, kiểm tra lại tên database/cube, filter, tiêu đề, số liệu và số thứ tự hình.
