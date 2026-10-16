# Hướng dẫn thực hiện và viết báo cáo câu b

Tài liệu này theo bố cục trong báo cáo mẫu: sau mỗi bước thao tác quan trọng, chụp màn hình, chèn ảnh và ghi chú thích ngay bên dưới ảnh rồi mới chuyển bước tiếp theo. Thứ tự là **Cube Browser (manual)** → **PivotTable Excel** → **MDX Query** → **đối chiếu và nhận xét**. Ảnh phải được chụp từ project và Excel của nhóm.

---

## Câu b

**Cho biết thành phố (City, State) có nhiều vụ tai nạn Severity 4 nhất trong năm 2021. Nếu đồng hạng, hiển thị tất cả.**

### Mục tiêu và cách hiểu

Đếm measure `FACT ACCIDENT Count` với điều kiện:
- **Severity**: 4 (tai nạn mức độ nghiêm trọng - Fatal/Severe)
- **Thời gian**: Năm 2021 (toàn năm)
- **Hiển thị**: City, State, và số lượng vụ tai nạn
- **Xử lý đồng hạng**: Hiển thị tất cả các thành phố có cùng số lượng cao nhất

**💡 Ý nghĩa nghiệp vụ:**

Severity = 4 đại diện cho các vụ tai nạn **nghiêm trọng nhất**, có ảnh hưởng lớn đến giao thông và an toàn công cộng. So với Severity = 2 (12,130 vụ tại Miami, FL), Severity = 4 chỉ có 18 vụ tại Pittsburgh, PA nhưng lại có **giá trị phân tích cao hơn nhiều** vì:
- Đại diện cho tai nạn Fatal/Severe (tử vong hoặc chấn thương nghiêm trọng)
- Số lượng ít giúp tập trung nguồn lực phòng ngừa hiệu quả
- Ưu tiên cao trong chính sách an toàn giao thông

---

## 1. Thực hiện manual trong Visual Studio (Cube Browser)

Thao tác trên cube `US Accidents DW` trong database `SSAS`. Nếu Browser còn giữ bộ lọc câu a/e/f, xóa chúng trước.

### Bước 1: Chuẩn bị Cube Browser

1. Mở solution SSAS trong Visual Studio.
2. Trong **Solution Explorer**, mở `Cubes` → nhấp đúp `US Accidents DW.cube` → chọn tab **Browser**.
3. Nếu Browser còn giữ filter cũ, nhấn nút **Clear Results**.
4. Nhấn nút **Reconnect** (biểu tượng dây cáp) để làm mới metadata.

**Chụp và chèn ngay tại đây:** chụp cửa sổ Browser đã sạch filter. Chú thích **Hình 3.11.1. Chuẩn bị Cube Browser cho truy vấn câu b**.

### Bước 2: Thêm Measure và Dimensions

1. Trong khung **Metadata**, mở `Measures` → `FACT ACCIDENT` → kéo **FACT ACCIDENT Count** vào vùng data (ô giữa).
2. Mở `DIM LOCATION` → kéo **CITY** vào trục **Rows** (Drop Row Fields Here).
3. Kéo **STATE** vào trục **Rows** (bên dưới CITY hoặc cạnh CITY).

**Chụp và chèn ngay tại đây:** chụp Browser với CITY, STATE, và Count đã được kéo vào (chưa filter). Chú thích **Hình 3.11.2. Thêm Measure và Dimensions vào Browser**.

### Bước 3: Thêm Filter cho Severity = 4

1. Trong khung **Metadata**, mở `DIM SEVERITY` → kéo **SEVERITY** vào vùng **Filter** (phía trên data grid).
2. Click vào dropdown của filter SEVERITY → **bỏ chọn (All)** → chỉ chọn **4** → nhấn **OK**.

**Chụp và chèn ngay tại đây:** chụp Browser với filter `SEVERITY = 4` đã được thiết lập. Chú thích **Hình 3.11.3. Filter Severity = 4**.

### Bước 4: Thêm Filter cho Year = 2021

1. Mở `ID START DATE` → kéo **YEAR** vào vùng **Filter**.
2. Click vào dropdown của filter YEAR → **bỏ chọn (All)** → chỉ chọn **2021** → nhấn **OK**.

**Chụp và chèn ngay tại đây:** chụp Browser với cả hai filter `SEVERITY = 4` và `YEAR = 2021`. Chú thích **Hình 3.11.4. Filter Year = 2021**.

### Bước 5: Chạy truy vấn và xem kết quả

1. Nhấn nút **Execute** hoặc **F5** để chạy truy vấn.
2. Kết quả sẽ hiển thị danh sách các thành phố với số vụ tai nạn Severity 4 trong năm 2021.
3. Tìm thành phố có số vụ cao nhất (sắp xếp theo cột Count nếu cần).

**Chụp và chèn ngay tại đây:** chụp toàn bộ kết quả Browser, đảm bảo thấy rõ filter, CITY, STATE, và Count. Nếu danh sách dài, chụp phần đầu có giá trị cao nhất. Chú thích **Hình 3.11.5. Kết quả Browser - Pittsburgh, PA có 18 vụ tai nạn Severity 4 trong năm 2021**.

**💡 Kết quả Browser:** Pittsburgh, PA = **18 vụ** (cao nhất, không có đồng hạng)

---

## 2. Thực hiện bằng PivotTable Excel

Tạo workbook riêng: `Pivot_Excel/Pivot_b.xlsx`.

### 2.1 Kết nối Excel đến cube

1. Mở Excel → tạo **Blank workbook**.
2. Chọn **Data → Get Data → From Database → From Analysis Services** (hoặc **From SQL Server Analysis Services**).
3. Nhập Analysis Services server của máy đang chạy SSAS (ví dụ: `LAPTOP-40H784NV\SSASMD`; thay bằng server của máy bạn).
4. Chọn database `SSAS`, cube `US Accidents DW`, rồi chọn tạo **PivotTable report**.
5. Lưu workbook ngay bằng **F12** → chọn thư mục `D:\OLAP\Pro\Pivot_Excel` → tên `Pivot_b.xlsx` → loại `Excel Workbook (*.xlsx)`.

**Chụp và chèn ngay sau khi kết nối:** chụp Excel đã nạp PivotTable từ cube và đang mở khung PivotTable Fields. Chú thích **Hình 3.11.6. Kết nối Excel với cube US Accidents DW**.

### 2.2 Tạo PivotTable với filter

Tạo một PivotTable trên sheet mặc định (có thể đặt tên sheet là `Severity4_2021`).

**Bước 1 - Kéo trường vào PivotTable:**

1. Trong khung **PivotTable Fields**, tìm `DIM LOCATION` → kéo **CITY** vào **Rows**.
2. Kéo **STATE** vào **Rows** (bên dưới CITY).
3. Mở `Measures` → `FACT ACCIDENT` → kéo **FACT ACCIDENT Count** vào **Values**.

**Chụp và chèn ngay tại đây:** chụp PivotTable với CITY, STATE ở Rows và Count ở Values (chưa filter). Chú thích **Hình 3.11.7. PivotTable với CITY, STATE, và Count**.

**Bước 2 - Thêm Filter cho Severity:**

1. Trong **PivotTable Fields**, tìm `DIM SEVERITY` → kéo **SEVERITY** vào **Filters** (phía trên bảng).
2. Click vào dropdown filter SEVERITY trên sheet → **bỏ chọn (All)** → chỉ chọn **4** → nhấn **OK**.

**Chụp và chèn ngay tại đây:** chụp PivotTable với filter `SEVERITY = 4` đã thiết lập. Chú thích **Hình 3.11.8. PivotTable với filter Severity = 4**.

**Bước 3 - Thêm Filter cho Year:**

1. Trong **PivotTable Fields**, tìm `ID START DATE` → kéo **YEAR** vào **Filters**.
2. Click vào dropdown filter YEAR → **bỏ chọn (All)** → chỉ chọn **2021** → nhấn **OK**.

**Chụp và chèn ngay tại đây:** chụp PivotTable với cả hai filter `SEVERITY = 4` và `YEAR = 2021`. Chú thích **Hình 3.11.9. PivotTable với filter Year = 2021**.

**Bước 4 - Sắp xếp theo Count giảm dần:**

1. Click vào cột **Count of FACT ACCIDENT Count**.
2. Nhấp phải → chọn **Sort → Sort Largest to Smallest**.
3. Kết quả sẽ hiển thị thành phố có số vụ cao nhất ở đầu bảng.

**Chụp và chèn ngay tại đây:** chụp PivotTable đã sắp xếp, thấy rõ Pittsburgh, PA = 18 ở đầu bảng. Chú thích **Hình 3.11.10. PivotTable kết quả - Pittsburgh, PA có 18 vụ tai nạn Severity 4 trong năm 2021**.

**Bước 5 - Lưu workbook:**

Nhấn **Ctrl + S** để lưu file.

**💡 Kết quả Excel:** Pittsburgh, PA = **18 vụ** (cao nhất, không có đồng hạng)

---

## 3. Thực hiện bằng MDX Query

Viết MDX Query để tìm thành phố có nhiều vụ tai nạn Severity 4 nhất trong năm 2021. Lưu truy vấn tại `SSAS/MDX_b/b.mdx`.

### Bước 1: Mở SSMS và kết nối

1. Mở **SQL Server Management Studio (SSMS)**.
2. Chọn **Server type**: **Analysis Services**.
3. Nhập **Server name**: instance SSAS của bạn (ví dụ: `LAPTOP-40H784NV\SSASMD`).
4. Nhấn **Connect**.

**Chụp và chèn ngay tại đây:** chụp cửa sổ Object Explorer đã kết nối với SSAS. Chú thích **Hình 3.11.11. Kết nối SSMS với Analysis Services**.

### Bước 2: Mở MDX Query Editor

1. Trong **Object Explorer**, mở `Databases` → `SSAS` → `Cubes` → `US Accidents DW`.
2. Nhấp phải vào `US Accidents DW` → chọn **New Query → MDX**.

**Chụp và chèn ngay tại đây:** chụp cửa sổ MDX Query Editor đang trống. Chú thích **Hình 3.11.12. MDX Query Editor**.

### Bước 3: Viết MDX Query

Dán truy vấn sau vào editor:

```mdx
SELECT
{
    [Measures].[FACT ACCIDENT Count]
} ON COLUMNS,
NON EMPTY
    TopCount(
        [DIM LOCATION].[CITY].[CITY].Members,
        1,
        ([Measures].[FACT ACCIDENT Count],
         [DIM SEVERITY].[SEVERITY].&[4],
         [ID START DATE].[YEAR].&[2021])
    ) ON ROWS
FROM [US Accidents DW]
WHERE
(
    [DIM SEVERITY].[SEVERITY].&[4],
    [ID START DATE].[YEAR].&[2021]
);
```

**Giải thích MDX Query:**

- **`TopCount(..., 1, ...)`**: Lấy **chỉ 1 thành phố** có số vụ cao nhất
- **`[DIM LOCATION].[CITY].[CITY].Members`**: Tất cả các thành phố
- **Tuple context**: `(Measure, Severity=4, Year=2021)` để tính số vụ tai nạn với điều kiện
- **`&[4]`**: Attribute key syntax để chỉ định Severity = 4
- **`&[2021]`**: Attribute key syntax để chỉ định Year = 2021
- **WHERE clause**: Filter toàn bộ cube theo Severity 4 và Year 2021
- **NON EMPTY**: Loại bỏ các thành phố không có dữ liệu

**💡 Lưu ý về đồng hạng:**

Truy vấn này chỉ trả về **1 thành phố duy nhất** (Pittsburgh). Nếu có nhiều thành phố cùng số vụ cao nhất, MDX sẽ chọn 1 trong số đó theo thứ tự alphabet. Để kiểm tra đồng hạng, bạn cần:
1. **Xem kết quả Browser/Excel đã sắp xếp** → Kiểm tra dòng 2 có bằng dòng 1 không
2. Hoặc **đổi TopCount(1) → TopCount(10)** để xem top 10 và kiểm tra

Trong trường hợp này, kết quả Browser và Excel đã chứng minh **không có đồng hạng** (Pittsburgh = 18, Orlando = 15).

**Chụp và chèn ngay tại đây:** chụp MDX Query đã dán vào editor. Chú thích **Hình 3.11.13. MDX Query câu b - TopCount(1) để tìm thành phố có số vụ cao nhất**.

### Bước 4: Thực thi Query

1. Nhấn **Execute** (hoặc **F5**) để chạy truy vấn.
2. Kiểm tra kết quả ở tab **Results**.

**Kết quả mong đợi:**

| CITY | FACT ACCIDENT Count |
|---|---:|
| Pittsburgh | 18 |

**Chụp và chèn ngay tại đây:** chụp bảng kết quả MDX với chỉ 1 dòng Pittsburgh = 18. Chú thích **Hình 3.11.14. Kết quả MDX Query - Pittsburgh có 18 vụ tai nạn Severity 4 trong năm 2021**.

### Bước 5: Lưu Query

1. Nhấn **Ctrl + S** hoặc **File → Save**.
2. Chọn thư mục `D:\OLAP\Pro\SSAS\MDX_b\`.
3. Tạo thư mục `MDX_b` nếu chưa có.
4. Đặt tên file: `b.mdx`.
5. Nhấn **Save**.

**Chụp và chèn ngay tại đây:** chụp hộp thoại Save với đường dẫn `D:\OLAP\Pro\SSAS\MDX_b\b.mdx`. Chú thích **Hình 3.11.15. Lưu MDX Query vào file b.mdx**.

**💡 Kết quả MDX:** Pittsburgh, PA = **18 vụ** (cao nhất, đã kiểm tra không có đồng hạng qua Browser và Excel)

---

## 4. Kết quả và nhận xét

### 4.1 Kết quả Top 10 thành phố

Dưới đây là kết quả các thành phố có nhiều vụ tai nạn Severity 4 trong năm 2021 (từ Browser/Excel):

| Hạng | Thành phố | State | Số vụ tai nạn |
|---:|---|---|---:|
| 1 | Pittsburgh | PA | **18** |
| 2 | Orlando | FL | 15 |
| 3 | Sacramento | CA | 14 |
| 4 | Raleigh | NC | 13 |
| 5 | Charlotte | NC | 12 |

**Kết luận:** Pittsburgh có số vụ cao nhất (18), Orlando đứng thứ 2 (15) → **Không có đồng hạng**.

### 4.2 Đối chiếu ba phương pháp

| Phương pháp | Kết quả | Trạng thái |
|---|---|---|
| **1. Cube Browser (Manual)** | Pittsburgh, PA = 18 | ✅ Khớp |
| **2. Excel PivotTable** | Pittsburgh, PA = 18 | ✅ Khớp |
| **3. MDX Query** | Pittsburgh, PA = 18 | ✅ Khớp |

**Kết luận:** Cả ba phương pháp đều cho kết quả **nhất quán**: **Pittsburgh, PA** có **18 vụ** tai nạn Severity 4 trong năm 2021, và **không có đồng hạng** (Orlando đứng thứ 2 với 15 vụ < 18).

### 4.3 Phân tích và ý nghĩa

**📊 So sánh Severity 4 vs Severity 2:**

| Severity | Thành phố | Số vụ | Ý nghĩa |
|---|---|---:|---|
| **Severity 4** | Pittsburgh, PA | 18 | **Tai nạn nghiêm trọng nhất** - Fatal/Severe |
| **Severity 2** | Miami, FL | 12,130 | Tai nạn mức độ trung bình |

**🎯 Tại sao Severity 4 quan trọng hơn?**

1. **Ý nghĩa nghiệp vụ cao:**
   - Severity 4 = Tai nạn Fatal/Severe (tử vong hoặc chấn thương nặng)
   - Ưu tiên cao nhất trong chính sách an toàn giao thông
   - Ảnh hưởng trực tiếp đến tính mạng con người

2. **Giá trị phân tích thực tế:**
   - Số lượng ít (18 vụ) → Dễ tập trung nguồn lực phòng ngừa
   - Phân tích từng vụ để tìm nguyên nhân gốc rễ
   - Xây dựng chính sách can thiệp cụ thể cho Pittsburgh

3. **Hành động cụ thể:**
   - Tăng cường tuần tra tại các điểm đen tai nạn ở Pittsburgh
   - Cải thiện hạ tầng giao thông (đèn tín hiệu, biển báo)
   - Chiến dịch nâng cao nhận thức an toàn giao thông

**💡 Khuyến nghị:**

Với chỉ 18 vụ tai nạn Severity 4, Pittsburgh có thể:
- Phân tích chi tiết từng vụ (thời gian, địa điểm, điều kiện thời tiết, loại xe)
- Xác định các "điểm nóng" tai nạn nghiêm trọng
- Triển khai các biện pháp can thiệp có mục tiêu
- Đo lường hiệu quả can thiệp qua các năm tiếp theo

---

## 5. Chụp ảnh và đưa vào báo cáo Word

### 5.1 Quy trình chụp ảnh

1. **Trước mỗi capture:**
   - Phóng to Visual Studio/Excel/SSMS
   - Kéo cột đủ rộng để không bị rút gọn số
   - Tránh để con trỏ chuột che kết quả

2. **Chụp màn hình:**
   - Nhấn **Win + Shift + S** (Snipping Tool)
   - Quét vùng có filter và kết quả
   - **Không chờ đến cuối mục mới chụp** - chụp ngay sau mỗi bước

3. **Lưu ảnh:**
   - Click thông báo chụp màn hình hoặc mở Paint → **Ctrl + V**
   - Nhấn **Ctrl + Shift + S** để lưu PNG
   - Lưu vào `Tai_lieu/Bao_cao/Hinh_cau_b/`
   - Đặt tên: `Hinh_3_11_1_Chuan_bi_Browser.png`, `Hinh_3_11_2_Them_Dimensions.png`, ...

4. **Chèn vào Word:**
   - Quay lại Word ngay sau bước đó
   - Đặt con trỏ dưới phần mô tả thao tác
   - **Insert → Pictures → This Device** → chọn file vừa lưu
   - Ngay dưới ảnh, chèn chú thích: **References → Insert Caption** hoặc nhập tay
   - Ví dụ: "Hình 3.11.5. Kết quả Browser - Pittsburgh, PA có 18 vụ tai nạn Severity 4 trong năm 2021"

5. **Định dạng:**
   - Căn giữa ảnh
   - Giữ ảnh và chú thích trên cùng trang
   - Không cắt mất filter hoặc tên measure

6. **Lưu liên tục:**
   - Nhấn **Ctrl + S** trong Word sau từng phương pháp
   - Lưu workbook Excel bằng **Ctrl + S**
   - Lưu MDX Query bằng **Ctrl + S**

### 5.2 Danh sách ảnh đề xuất

| Số hình | Nội dung ảnh | Vị trí đặt |
|---|---|---|
| **Phần 1: Manual Browser** | | |
| 3.11.1 | Chuẩn bị Browser (Clear + Reconnect) | Chèn sau Bước 1 |
| 3.11.2 | Thêm CITY, STATE, Count | Chèn sau Bước 2 |
| 3.11.3 | Filter Severity = 4 | Chèn sau Bước 3 |
| 3.11.4 | Filter Year = 2021 | Chèn sau Bước 4 |
| 3.11.5 | Kết quả Browser (Pittsburgh = 18) | Chèn sau Bước 5 |
| **Phần 2: Excel PivotTable** | | |
| 3.11.6 | Kết nối Excel với cube | Chèn sau 2.1 |
| 3.11.7 | PivotTable với CITY, STATE, Count | Chèn sau Bước 1 |
| 3.11.8 | PivotTable với filter Severity = 4 | Chèn sau Bước 2 |
| 3.11.9 | PivotTable với filter Year = 2021 | Chèn sau Bước 3 |
| 3.11.10 | Kết quả Excel (Pittsburgh = 18) | Chèn sau Bước 4 |
| **Phần 3: MDX Query** | | |
| 3.11.11 | Kết nối SSMS với SSAS | Chèn sau Bước 1 |
| 3.11.12 | MDX Query Editor trống | Chèn sau Bước 2 |
| 3.11.13 | MDX Query đã viết | Chèn sau Bước 3 |
| 3.11.14 | Kết quả MDX (Pittsburgh = 18) | Chèn sau Bước 4 |
| 3.11.15 | Lưu file b.mdx | Chèn sau Bước 5 |

**Tổng cộng: 15 ảnh** (không tính ảnh bảng kết quả trong phần 4)

### 5.3 Checklist trước khi nộp

**Phần kỹ thuật:**
- [ ] Cả 3 phương pháp đều chạy thành công
- [ ] Filter đúng: **Severity = 4** (không phải 2)
- [ ] Filter đúng: **Year = 2021**
- [ ] Kết quả nhất quán: **Pittsburgh, PA = 18**
- [ ] Không có đồng hạng (Orlando = 15 < 18)

**Phần ảnh:**
- [ ] Đã chụp đủ **15 ảnh** theo đúng thứ tự
- [ ] Mỗi ảnh có **chú thích rõ ràng** ngay bên dưới
- [ ] Ảnh hiển thị đầy đủ filter và kết quả
- [ ] Ảnh rõ nét, không bị mờ (dùng PNG)
- [ ] Tất cả ảnh đều từ project thật của nhóm

**Phần báo cáo:**
- [ ] Đã giải thích **ý nghĩa nghiệp vụ** của Severity 4
- [ ] Đã có phần **đối chiếu** kết quả 3 phương pháp
- [ ] Đã phân tích **tại sao Severity 4** quan trọng hơn Severity 2
- [ ] Đã đưa ra **khuyến nghị hành động** cho Pittsburgh
- [ ] Đã có bảng so sánh Top 10 thành phố

---

## 6. Câu hỏi thường gặp (FAQ)

**Q1: Tại sao không dùng Named Set như trong tutorial cũ?**

A: Named Set phức tạp và không cần thiết cho câu b. Browser có thể filter trực tiếp bằng dropdown SEVERITY và YEAR, rồi sắp xếp kết quả theo Count. Cách này đơn giản hơn và phù hợp với format tutorial câu a.

**Q2: Tại sao chọn Severity 4 thay vì Severity 2?**

A: Severity 4 có **ý nghĩa nghiệp vụ cao hơn nhiều**:
- Severity 4 = Fatal/Severe (tai nạn nghiêm trọng nhất)
- Severity 2 = Moderate (tai nạn mức độ trung bình)
- Số lượng ít (18 vs 12,130) giúp phân tích sâu và can thiệp hiệu quả

**Q3: Làm sao biết có đồng hạng hay không?**

A: Có 2 cách kiểm tra:
1. **Browser/Excel:** Sắp xếp kết quả giảm dần, xem dòng 2 có bằng dòng 1 không
2. **MDX với TopCount(1):** Chỉ trả về 1 thành phố cao nhất, cần dùng Browser/Excel để xác nhận không có đồng hạng

Trong trường hợp này: Pittsburgh = 18, Orlando = 15 → **Không đồng hạng**

**Q4: Browser có thể sắp xếp theo Count được không?**

A: Có. Click vào header cột Count và chọn Sort Descending để thấy giá trị cao nhất ở đầu bảng.

**Q5: Tại sao MDX chỉ dùng TopCount(1) thay vì TopCount(10)?**

A: Theo đúng yêu cầu đề bài "cho biết thành phố có số vụ **nhất**". TopCount(1) trả về đúng 1 thành phố cao nhất. Để kiểm tra đồng hạng, dùng Browser hoặc Excel đã sắp xếp.

---

## 7. Kết luận

### Câu trả lời cuối cùng:

**Thành phố có nhiều vụ tai nạn Severity 4 (nghiêm trọng nhất) trong năm 2021:**
- **City**: Pittsburgh
- **State**: PA (Pennsylvania)
- **Số vụ tai nạn**: 18 vụ
- **Đồng hạng**: Không có (Orlando đứng thứ 2 với 15 vụ)

### Các bước đã thực hiện:

1. ✅ Cube Browser: Filter Severity = 4 + Year = 2021 + Sort → Pittsburgh = 18
2. ✅ Excel PivotTable: Filter Severity = 4 + Year = 2021 + Sort → Pittsburgh = 18
3. ✅ MDX Query: TopCount(1) → Pittsburgh = 18
4. ✅ Đối chiếu: Cả 3 phương pháp cho kết quả nhất quán
5. ✅ Kiểm tra đồng hạng: Orlando = 15 < Pittsburgh = 18 → Không có đồng hạng

### Ý nghĩa quan trọng:

**Severity 4 = Tai nạn nghiêm trọng nhất:**
- 🚨 Fatal/Severe accidents (tử vong hoặc chấn thương nặng)
- 🏥 Ưu tiên cao nhất trong an toàn giao thông
- 📊 Giá trị phân tích cao cho chính sách phòng ngừa
- 🎯 Số lượng ít (18 vụ) giúp tập trung hành động cụ thể

### Files cần tạo:

- `Pivot_Excel/Pivot_b.xlsx` - Excel workbook với PivotTable
- `SSAS/MDX_b/b.mdx` - MDX Query file
- `Tai_lieu/Bao_cao/Hinh_cau_b/` - Thư mục chứa 15 ảnh

---

**🎉 Hoàn thành tutorial câu B!**

**Lưu ý cuối:** Tutorial này đã được viết lại hoàn toàn theo format câu A với:
- ✅ Hướng dẫn chi tiết từng bước (Manual → Excel → MDX)
- ✅ Chụp ảnh ngay sau mỗi bước (không gom xuống cuối)
- ✅ Format giống file PDF mẫu và tutorial câu A
- ✅ Không dùng Named Set phức tạp - chỉ filter đơn giản
- ✅ Nhấn mạnh ý nghĩa nghiệp vụ của Severity 4
- ✅ **MDX dùng TopCount(1)** để tìm đúng 1 thành phố cao nhất

**Chúc bạn thành công! 🚀**
