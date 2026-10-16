# Hướng dẫn thực hiện và viết báo cáo - Truy vấn Texas

Tài liệu này theo bố cục trong báo cáo mẫu: sau mỗi bước thao tác quan trọng, chụp màn hình, chèn ảnh và ghi chú thích ngay bên dưới ảnh. Thứ tự: **Cube Browser** → **PivotTable Excel** → **MDX Query** → **đối chiếu**.

---

## Nội dung truy vấn

**Liệt kê các thành phố ở Texas (State = 'TX') có trên 1.000 vụ tai nạn, kèm số vụ và Distance trung bình; sắp xếp số vụ giảm dần.**

### Mục tiêu

- **Dimension**: City (từ DIM LOCATION)
- **Filter 1**: State = 'TX' (Texas)
- **Filter 2**: FACT ACCIDENT Count > 1,000
- **Measure 1**: `FACT ACCIDENT Count` (số vụ tai nạn)
- **Measure 2**: `AVG Distance` (khoảng cách trung bình bị ảnh hưởng)
- **Sắp xếp**: Theo số vụ giảm dần

**💡 Ý nghĩa nghiệp vụ:**

Texas là bang lớn với giao thông phức tạp. Phân tích các thành phố có **trên 1,000 vụ** giúp xác định điểm nóng tai nạn và ưu tiên nguồn lực.

---

## 1. Thực hiện manual trong Visual Studio (Cube Browser)

### Bước 1: Chuẩn bị Cube Browser

1. Mở `SSAS` → `Cubes` → `US Accidents DW.cube`
2. Chọn tab **Browser**
3. Nhấn **Reconnect** để reset filter cũ

**Chụp và chèn:** Chú thích **Hình 3.X.1. Chuẩn bị Cube Browser**

### Bước 2: Thêm Dimensions và Measures

1. Kéo `CITY` (DIM LOCATION) vào **Drop Row Fields Here**
2. Kéo `STATE` (DIM LOCATION) vào **Drop Row Fields Here**
3. Kéo `FACT ACCIDENT Count` vào **Drop Totals**
4. Kéo `AVG Distance` vào vùng measure

**Chụp và chèn:** Chú thích **Hình 3.X.2. Thêm CITY, STATE, Count và AVG Distance**

### Bước 3: Filter State = TX

1. Kéo `STATE` vào **Drop Filter Fields Here**
2. Dropdown: bỏ chọn **(All)**, chỉ chọn **TX**
3. Nhấn **OK**

**Chụp và chèn:** Chú thích **Hình 3.X.3. Filter State = TX**

### Bước 4: Xem kết quả

1. Nhấn **Execute** (F5)
2. Click header **FACT ACCIDENT Count** → **Sort Descending**
3. Xác định các thành phố có Count > 1,000

**Chụp và chèn:** Chú thích **Hình 3.X.4. Kết quả Browser - Thành phố Texas > 1,000 vụ**

**💡 Kết quả:** Houston (~8,000), Dallas (~6,500), San Antonio (~3,200), Austin (~2,800)...

---

## 2. Thực hiện bằng PivotTable Excel

Tạo workbook riêng: `Pivot_Excel/Pivot_Texas.xlsx`.

### 2.1 Kết nối Excel đến cube

1. Mở Excel → **Blank workbook**
2. **Data → Get Data → From Database → From Analysis Services**
3. Nhập server SSAS (ví dụ: `LAPTOP-40H784NV\SSASMD`)
4. Chọn database `SSAS`, cube `US Accidents DW`, tạo **PivotTable report**
5. Lưu workbook: **F12** → `D:\OLAP\Pro\Pivot_Excel\Pivot_Texas.xlsx`

**Chụp và chèn:** Chú thích **Hình 3.X.5. Kết nối Excel với cube**

### 2.2 Tạo PivotTable với filter

**Bước 1: Kéo trường vào PivotTable**

1. Kéo `CITY` (DIM LOCATION) vào **Rows**
2. Kéo `STATE` (DIM LOCATION) vào **Rows**
3. Kéo `FACT ACCIDENT Count` vào **Values**
4. Kéo `AVG Distance` vào **Values**

**Chụp và chèn:** Chú thích **Hình 3.X.6. PivotTable cơ bản**

**Bước 2: Filter State = TX**

1. Kéo `STATE` vào **Filters** (phía trên PivotTable)
2. Click dropdown filter STATE → chọn **TX**
3. Nhấn **OK**

**Chụp và chèn:** Chú thích **Hình 3.X.7. Filter State = TX**

**Bước 3: Filter Count > 1,000**

1. Click phải vào PivotTable → **Filter → Value Filters → Greater Than...**
2. Chọn measure: `FACT ACCIDENT Count`
3. Điều kiện: **is greater than** → Giá trị: `1000`
4. Nhấn **OK**

**Chụp và chèn:** Chú thích **Hình 3.X.8. Filter Count > 1,000**

**Bước 4: Sắp xếp và xem kết quả**

1. Click phải cột **FACT ACCIDENT Count** → **Sort → Largest to Smallest**
2. Kết quả hiển thị các thành phố Texas có > 1,000 vụ, sắp xếp giảm dần

**Chụp và chèn:** Chú thích **Hình 3.X.9. Kết quả Excel - Thành phố Texas > 1,000 vụ**

**Bước 5: Lưu file** - Nhấn **Ctrl + S**

**💡 Kết quả Excel:** Houston, Dallas, San Antonio, Austin... với Count > 1,000 và AVG Distance

---

## 3. Thực hiện bằng MDX Query

Viết MDX Query để lấy các thành phố Texas có > 1,000 vụ tai nạn, kèm AVG Distance. Lưu truy vấn tại `SSAS/MDX_Texas/Texas.mdx`.

### Bước 1: Mở SSMS và kết nối

1. Mở **SQL Server Management Studio (SSMS)**
2. **Server type**: **Analysis Services**
3. **Server name**: instance SSAS của bạn (ví dụ: `LAPTOP-40H784NV\SSASMD`)
4. Nhấn **Connect**

**Chụp và chèn:** Chú thích **Hình 3.X.10. Kết nối SSMS với Analysis Services**

### Bước 2: Mở MDX Query Editor

1. **Object Explorer** → `Databases` → `SSAS` → `Cubes` → `US Accidents DW`
2. Nhấp phải → **New Query → MDX**

**Chụp và chèn:** Chú thích **Hình 3.X.11. MDX Query Editor**

### Bước 3: Viết MDX Query

Dán truy vấn sau vào editor:

```mdx
SELECT
{
    [Measures].[FACT ACCIDENT Count],
    [Measures].[AVG Distance]
} ON COLUMNS,
NON EMPTY
    ORDER(
        FILTER(
            [DIM LOCATION].[CITY].[CITY].Members,
            [Measures].[FACT ACCIDENT Count] > 1000
        ),
        [Measures].[FACT ACCIDENT Count],
        BDESC
    ) ON ROWS
FROM [US Accidents DW]
WHERE
(
    [DIM LOCATION].[STATE].&[TX]
);
```

**Giải thích MDX Query:**

- **`FILTER(..., Count > 1000)`**: Chỉ lấy thành phố có số vụ > 1,000
- **`ORDER(..., Count, BDESC)`**: Sắp xếp theo Count giảm dần (Break hierarchy Descending)
- **`WHERE [STATE].&[TX]`**: Filter toàn bộ cube chỉ lấy Texas
- **Measures**: FACT ACCIDENT Count và AVG Distance
- **NON EMPTY**: Loại bỏ thành phố không có dữ liệu

**Chụp và chèn:** Chú thích **Hình 3.X.12. MDX Query - Thành phố Texas > 1,000 vụ**

### Bước 4: Thực thi Query

1. Nhấn **Execute** (F5)
2. Kiểm tra kết quả ở tab **Results**

**Kết quả mong đợi:**

| CITY | FACT ACCIDENT Count | AVG Distance |
|---|---:|---:|
| Houston | ~8,000 | ~1.2 |
| Dallas | ~6,500 | ~1.1 |
| San Antonio | ~3,200 | ~1.0 |
| Austin | ~2,800 | ~1.1 |

**Chụp và chèn:** Chú thích **Hình 3.X.13. Kết quả MDX Query**

### Bước 5: Lưu Query

1. **Ctrl + S** hoặc **File → Save**
2. Chọn thư mục `D:\OLAP\Pro\SSAS\MDX_Texas\` (tạo thư mục nếu chưa có)
3. Tên file: `Texas.mdx`
4. Nhấn **Save**

**Chụp và chèn:** Chú thích **Hình 3.X.14. Lưu MDX Query vào file Texas.mdx**

**💡 Kết quả MDX:** Danh sách thành phố Texas có > 1,000 vụ, sắp xếp giảm dần, kèm AVG Distance

---

## 4. Kết quả và nhận xét

### 4.1 Bảng tóm tắt kết quả

Các thành phố Texas có > 1,000 vụ tai nạn:

| Thành phố | Count | AVG Distance (miles) |
|---|---:|---:|
| Houston | 8,000+ | 1.2 |
| Dallas | 6,500+ | 1.1 |
| San Antonio | 3,200+ | 1.0 |
| Austin | 2,800+ | 1.1 |
| Fort Worth | 2,000+ | 1.0 |

*(Thay số liệu bằng kết quả thực tế từ cube của bạn)*

### 4.2 Đối chiếu 3 phương pháp

| Phương pháp | Kết quả | Trạng thái |
|---|---|---|
| **1. Cube Browser** | Houston = 8,000+, Dallas = 6,500+... | ✅ Khớp |
| **2. Excel PivotTable** | Houston = 8,000+, Dallas = 6,500+... | ✅ Khớp |
| **3. MDX Query** | Houston = 8,000+, Dallas = 6,500+... | ✅ Khớp |

**Kết luận:** Cả ba phương pháp đều cho kết quả **nhất quán**.

### 4.3 Phân tích

**📊 Nhận xét:**

1. **Houston là điểm nóng tai nạn nhất Texas** (8,000+ vụ)
2. **AVG Distance tương đối đồng đều** (~1.0-1.2 miles) giữa các thành phố
3. **Các thành phố lớn chiếm ưu thế** do mật độ giao thông cao

**💡 Khuyến nghị:**

- Tập trung nguồn lực vào Houston và Dallas
- Phân tích sâu nguyên nhân tại các thành phố có nhiều vụ nhất
- Kết hợp với Severity để ưu tiên can thiệp

---

## 5. Hướng dẫn chụp ảnh

### Danh sách 14 ảnh cần chụp

**Phần 1: Browser (4 ảnh)**
1. Hình 3.X.1 - Chuẩn bị Browser
2. Hình 3.X.2 - Thêm CITY, STATE, Count, AVG Distance
3. Hình 3.X.3 - Filter State = TX
4. Hình 3.X.4 - Kết quả Browser

**Phần 2: Excel (5 ảnh)**
5. Hình 3.X.5 - Kết nối cube
6. Hình 3.X.6 - PivotTable cơ bản
7. Hình 3.X.7 - Filter State = TX
8. Hình 3.X.8 - Filter Count > 1,000
9. Hình 3.X.9 - Kết quả Excel

**Phần 3: MDX (5 ảnh)**
10. Hình 3.X.10 - Kết nối SSMS
11. Hình 3.X.11 - MDX Editor trống
12. Hình 3.X.12 - MDX Query
13. Hình 3.X.13 - Kết quả MDX
14. Hình 3.X.14 - Lưu file Texas.mdx

### Quy trình chụp và chèn

1. **Windows + Shift + S** để chụp màn hình
2. Lưu vào `D:\OLAP\Pro\Tai_lieu\Bao_cao\Hinh_Texas\` với tên `Hinh_3.X.1.png`, `Hinh_3.X.2.png`...
3. Chèn vào Word ngay sau bước tương ứng
4. Thêm chú thích in nghiêng bên dưới ảnh

### Checklist trước khi nộp

- [ ] Đã chụp đủ 14 ảnh rõ nét (PNG)
- [ ] Đã chèn ảnh vào Word đúng vị trí
- [ ] Đã thêm chú thích cho tất cả ảnh
- [ ] Filter STATE = TX rõ ràng
- [ ] Filter Count > 1,000 rõ ràng (Excel)
- [ ] Kết quả hiển thị Houston, Dallas, San Antonio...
- [ ] MDX Query có ORDER và FILTER
- [ ] Đã lưu `Pivot_Texas.xlsx`
- [ ] Đã lưu `Texas.mdx`
- [ ] Báo cáo có phần phân tích và nhận xét

---

## 6. FAQ

**Q1: Browser có thể filter Count > 1,000 tự động không?**

A: Không. Browser không hỗ trợ filter theo measure. Bạn cần xem toàn bộ kết quả, sắp xếp theo Count, rồi tự xác định các dòng > 1,000.

**Q2: Excel có thể filter Count > 1,000 không?**

A: Có! Dùng **Value Filters → Greater Than** như hướng dẫn.

**Q3: Tại sao MDX dùng FILTER và WHERE?**

A: 
- **WHERE**: Filter dimension (State = TX)
- **FILTER**: Filter measure (Count > 1,000)
- Cần kết hợp cả 2

**Q4: AVG Distance là gì?**

A: Khoảng cách trung bình (miles) bị ảnh hưởng bởi tai nạn (đóng làn, tắc nghẽn). Giá trị cao → ảnh hưởng rộng.

**Q5: Cần ORDER trong MDX không?**

A: Có! `ORDER(..., Count, BDESC)` để sắp xếp giảm dần. Không có ORDER → kết quả theo alphabet.

---

## 7. Kết luận

**Câu trả lời:**

Các thành phố Texas có trên 1,000 vụ tai nạn (sắp xếp giảm dần):

1. **Houston, TX** - ~8,000 vụ, AVG Distance ~1.2 miles
2. **Dallas, TX** - ~6,500 vụ, AVG Distance ~1.1 miles
3. **San Antonio, TX** - ~3,200 vụ, AVG Distance ~1.0 miles
4. **Austin, TX** - ~2,800 vụ, AVG Distance ~1.1 miles
5. **Fort Worth, TX** - ~2,000 vụ, AVG Distance ~1.0 miles

*(Thay số liệu bằng kết quả thực tế)*

**Các bước đã thực hiện:**

1. ✅ Browser: Filter State = TX + Sort → Xác định thành phố > 1,000 vụ
2. ✅ Excel: Filter State = TX + Filter Count > 1,000 + Sort
3. ✅ MDX: FILTER + WHERE + ORDER
4. ✅ Đối chiếu: 3 phương pháp nhất quán
5. ✅ Phân tích: Houston là điểm nóng nhất

**Files cần tạo:**

- `Pivot_Excel/Pivot_Texas.xlsx`
- `SSAS/MDX_Texas/Texas.mdx`
- `Tai_lieu/Bao_cao/Hinh_Texas/` (14 ảnh)

---

**🎉 Hoàn thành tutorial Texas Query!**

**Chúc bạn thành công! 🚀**

