# Hướng dẫn thực hiện và viết báo cáo câu d

Tài liệu này theo bố cục trong báo cáo mẫu: sau mỗi bước thao tác quan trọng, chụp màn hình, chèn ảnh và ghi chú thích ngay bên dưới ảnh rồi mới chuyển bước tiếp theo. Thứ tự là **Cube Browser (manual)** → **PivotTable Excel** → **MDX Query** → **đối chiếu và nhận xét**. Ảnh phải được chụp từ project và Excel của nhóm.

---

## Câu d

**Với mỗi bang, tính tỷ lệ vụ tai nạn trong điều kiện sương mù (Weather_Condition chứa "Fog") trên tổng số vụ của bang trong năm 2022. Chỉ hiển thị bang có tỷ lệ trên 5%, sắp xếp tỷ lệ giảm dần.**

### Mục tiêu và cách hiểu

Tính tỷ lệ phần trăm:

```
Tỷ lệ Fog (%) = (Số vụ có Fog / Tổng số vụ của bang) × 100
```

**Điều kiện:**
- **Thời gian**: Năm 2022
- **Weather_Condition**: Chứa "Fog" (ví dụ: "Fog", "Light Fog", "Heavy Fog"...)
- **Phạm vi**: Với mỗi bang (STATE)
- **Filter kết quả**: Chỉ hiển thị bang có tỷ lệ > 5%
- **Sắp xếp**: Giảm dần theo tỷ lệ

**💡 Ý nghĩa nghiệp vụ:**

Sương mù là một trong những điều kiện thời tiết **nguy hiểm nhất** trong giao thông vì:
- Giảm tầm nhìn nghiêm trọng (Visibility thấp)
- Gây tai nạn dây chuyền trên cao tốc
- Khó kiểm soát tốc độ an toàn

Xác định các bang có **tỷ lệ tai nạn sương mù cao** (> 5%) giúp:
- Lắp đặt hệ thống cảnh báo sương mù tự động
- Tăng cường tuần tra và kiểm soát tốc độ
- Đầu tư vào hệ thống đèn đường và biển báo phản quang

---

## 1. Thực hiện manual trong Visual Studio (Cube Browser)

⚠️ **Lưu ý quan trọng:** Browser **không hỗ trợ tính tỷ lệ % tự động** và **không filter LIKE '%Fog%'**. Do đó, phương pháp Browser sẽ:
1. Xem danh sách các Weather_Condition chứa "Fog"
2. Lấy số vụ có Fog theo từng bang
3. Lấy tổng số vụ theo từng bang
4. **Tính tỷ lệ % bằng Excel** hoặc thủ công
5. Lọc bang có tỷ lệ > 5%

### Bước 1: Chuẩn bị Cube Browser

1. Mở solution SSAS trong Visual Studio.
2. Trong **Solution Explorer**, mở `Cubes` → nhấp đúc `US Accidents DW.cube` → chọn tab **Browser**.
3. Nếu Browser còn giữ filter cũ, nhấn nút **Clear Results**.
4. Nhấn nút **Reconnect** để làm mới metadata.

**Chụp và chèn:** Chú thích **Hình 3.13.1. Chuẩn bị Cube Browser cho truy vấn câu d**.

### Bước 2: Khám phá Weather_Condition chứa "Fog"

Trước khi tính tỷ lệ, cần biết có những giá trị nào của Weather_Condition chứa "Fog".

1. Trong khung **Metadata**, mở `DIM WEATHER` → kéo **WEATHER_CONDITION** vào trục **Rows**.
2. Mở `Measures` → `FACT ACCIDENT` → kéo **FACT ACCIDENT Count** vào vùng data.
3. Mở `ID START DATE` → kéo **YEAR** vào vùng **Filter** → chọn **2022**.
4. Nhấn **Execute** (F5).
5. Xem kết quả → tìm các dòng có chữ "Fog" (ví dụ: Fog, Light Fog, Shallow Fog, Patches of Fog...).

**Chụp và chèn:** Chụp Browser với danh sách Weather_Condition, đảm bảo thấy các dòng có "Fog". Chú thích **Hình 3.13.2. Danh sách Weather_Condition chứa Fog trong năm 2022**.

**💡 Ghi nhận:** Các giá trị Weather_Condition chứa "Fog" có thể bao gồm:
- Fog
- Light Fog
- Heavy Fog
- Shallow Fog
- Patches of Fog
- Fog / Windy
- ...

### Bước 3: Đếm số vụ có Fog theo từng bang

1. **Clear Results** để bắt đầu lại.
2. Kéo `DIM LOCATION` → **STATE** vào trục **Rows**.
3. Kéo **FACT ACCIDENT Count** vào vùng data.
4. Thêm filter **YEAR = 2022**.
5. Thêm `DIM WEATHER` → **WEATHER_CONDITION** vào **Filter**.
6. Click dropdown WEATHER_CONDITION → **bỏ chọn (All)** → **chỉ chọn các giá trị chứa "Fog"** (Fog, Light Fog, Heavy Fog, Shallow Fog, Patches of Fog...).
7. Nhấn **Execute**.

**Chụp và chèn:** Chụp Browser với filter Year = 2022 và Weather_Condition = Fog variants, kết quả hiển thị STATE và Count. Chú thích **Hình 3.13.3. Số vụ tai nạn có sương mù theo bang năm 2022**.

**💡 Ghi nhận:** Ví dụ kết quả:
- California (CA): 1,200 vụ có Fog
- Texas (TX): 800 vụ có Fog
- Florida (FL): 500 vụ có Fog
- ...

### Bước 4: Đếm tổng số vụ theo từng bang

1. **Clear Results**.
2. Kéo **STATE** vào **Rows**.
3. Kéo **FACT ACCIDENT Count** vào data.
4. Thêm filter **YEAR = 2022** (không filter Weather_Condition).
5. Nhấn **Execute**.

**Chụp và chèn:** Chụp Browser với filter Year = 2022 (không filter Weather), kết quả hiển thị STATE và tổng Count. Chú thích **Hình 3.13.4. Tổng số vụ tai nạn theo bang năm 2022**.

**💡 Ghi nhận:** Ví dụ kết quả:
- California (CA): 20,000 vụ tổng
- Texas (TX): 15,000 vụ tổng
- Florida (FL): 10,000 vụ tổng
- ...

### Bước 5: Tính tỷ lệ % bằng Excel

1. Xuất cả hai kết quả (Bước 3 và Bước 4) ra Excel hoặc ghi lại.
2. Tính tỷ lệ: `(Số vụ Fog / Tổng vụ) × 100`.
3. Lọc các bang có tỷ lệ > 5%.
4. Sắp xếp giảm dần.

**Chụp và chèn:** Chụp Excel với bảng tính tỷ lệ %. Chú thích **Hình 3.13.5. Tính tỷ lệ % tai nạn sương mù theo bang**.

**💡 Kết quả Browser (ví dụ):**

| Bang | Số vụ Fog | Tổng vụ | Tỷ lệ % |
|---|---:|---:|---:|
| CA | 1,200 | 20,000 | 6.0% |
| OR | 400 | 5,000 | 8.0% |
| WA | 600 | 10,000 | 6.0% |

*(Chỉ hiển thị bang > 5%)*

---

## 2. Thực hiện bằng PivotTable Excel

Tạo workbook riêng: `Pivot_Excel/Pivot_d.xlsx`.

### 2.1 Kết nối Excel đến cube

1. Mở Excel → tạo **Blank workbook**.
2. Chọn **Data → Get Data → From Database → From Analysis Services**.
3. Nhập Analysis Services server (ví dụ: `LAPTOP-40H784NV\SSASMD`).
4. Chọn database `SSAS`, cube `US Accidents DW`, tạo **PivotTable report**.
5. Lưu workbook: **F12** → `D:\OLAP\Pro\Pivot_Excel\Pivot_d.xlsx`.

**Chụp và chèn:** Chú thích **Hình 3.13.6. Kết nối Excel với cube US Accidents DW**.

### 2.2 Tạo PivotTable - Bước 1: Số vụ có Fog

Tạo sheet `Fog_Count`.

**Bước 1 - Kéo trường vào PivotTable:**

1. Trong **PivotTable Fields**, kéo `DIM LOCATION` → **STATE** vào **Rows**.
2. Kéo `FACT ACCIDENT Count` vào **Values**.
3. Kéo `ID START DATE` → **YEAR** vào **Filters** → chọn **2022**.
4. Kéo `DIM WEATHER` → **WEATHER_CONDITION** vào **Filters**.

**Chụp và chèn:** Chú thích **Hình 3.13.7. PivotTable cơ bản - STATE và Count năm 2022**.

**Bước 2 - Filter Weather_Condition chứa "Fog":**

1. Click dropdown **WEATHER_CONDITION** trong Filters.
2. Nhấn **Label Filters** → **Contains...**.
3. Nhập `Fog` → **OK**.

**Chụp và chèn:** Chú thích **Hình 3.13.8. Filter Weather_Condition contains Fog**.

**💡 Kết quả:** Số vụ có Fog theo từng bang năm 2022.

### 2.3 Tạo PivotTable - Bước 2: Tổng số vụ

Tạo sheet `Total_Count`.

1. Tạo PivotTable tương tự.
2. Kéo **STATE** vào **Rows**, **FACT ACCIDENT Count** vào **Values**.
3. Filter **YEAR = 2022** (không filter Weather_Condition).

**Chụp và chèn:** Chú thích **Hình 3.13.9. PivotTable - Tổng số vụ theo bang năm 2022**.

### 2.4 Tính tỷ lệ % và filter

Tạo sheet `Fog_Percentage`.

1. Tạo bảng với cột: **STATE**, **Fog_Count**, **Total_Count**, **Percentage**.
2. Copy dữ liệu từ hai sheet trên.
3. Tính **Percentage** = `(Fog_Count / Total_Count) * 100`.
4. Filter **Percentage > 5**.
5. Sắp xếp **Percentage** giảm dần.

**Chụp và chèn:** Chú thích **Hình 3.13.10. Bảng tỷ lệ % tai nạn sương mù - Filter > 5%**.

**💡 Kết quả Excel:** Các bang có tỷ lệ > 5%, sắp xếp giảm dần.

---

## 3. Thực hiện bằng MDX Query

Viết MDX Query sử dụng **Calculated Member** để tính tỷ lệ %. Lưu truy vấn tại `SSAS/MDX_d/Fog_Percentage.mdx`.

### Bước 1: Mở SSMS và kết nối

1. Mở **SQL Server Management Studio (SSMS)**.
2. **Server type**: **Analysis Services**.
3. **Server name**: instance SSAS của bạn (ví dụ: `LAPTOP-40H784NV\SSASMD`).
4. Nhấn **Connect**.

**Chụp và chèn:** Chú thích **Hình 3.13.11. Kết nối SSMS với Analysis Services**.

### Bước 2: Mở MDX Query Editor

1. **Object Explorer** → `Databases` → `SSAS` → `Cubes` → `US Accidents DW`.
2. Nhấp phải → **New Query → MDX**.

**Chụp và chèn:** Chú thích **Hình 3.13.12. MDX Query Editor**.

### Bước 3: Viết MDX Query

Dán truy vấn sau vào editor:

```mdx
WITH
-- Calculated Member: Số vụ có Fog
MEMBER [Measures].[Fog Count] AS
(
    [Measures].[FACT ACCIDENT Count],
    [DIM WEATHER].[WEATHER CONDITION].[WEATHER CONDITION].Members
),
VISIBLE_EVALUATOR = 
    InStr([DIM WEATHER].[WEATHER CONDITION].CurrentMember.Name, "Fog") > 0

-- Calculated Member: Tỷ lệ % Fog
MEMBER [Measures].[Fog Percentage] AS
    IIF(
        [Measures].[FACT ACCIDENT Count] = 0,
        NULL,
        (
            [Measures].[Fog Count] / [Measures].[FACT ACCIDENT Count]
        ) * 100
    ),
    FORMAT_STRING = "0.00"

SELECT
{
    [Measures].[Fog Count],
    [Measures].[FACT ACCIDENT Count],
    [Measures].[Fog Percentage]
} ON COLUMNS,
NON EMPTY
    ORDER(
        FILTER(
            [DIM LOCATION].[STATE].[STATE].Members,
            [Measures].[Fog Percentage] > 5
        ),
        [Measures].[Fog Percentage],
        BDESC
    ) ON ROWS
FROM [US Accidents DW]
WHERE
(
    [ID START DATE].[YEAR].&[2022]
);
```

**⚠️ Lưu ý:** MDX trên là **ví dụ phức tạp**. Nếu không chạy được, dùng **phương án đơn giản hơn** (xem phần FAQ).

**Giải thích MDX Query:**

- **WITH clause**: Định nghĩa Calculated Members
- **[Fog Count]**: Đếm số vụ có Weather_Condition chứa "Fog" (dùng InStr)
- **[Fog Percentage]**: Tính tỷ lệ % = (Fog Count / Total Count) × 100
- **FILTER**: Chỉ lấy bang có tỷ lệ > 5%
- **ORDER**: Sắp xếp theo tỷ lệ giảm dần
- **WHERE**: Filter năm 2022

**Chụp và chèn:** Chú thích **Hình 3.13.13. MDX Query - Tỷ lệ tai nạn sương mù theo bang**.

### Bước 4: Thực thi Query

1. Nhấn **Execute** (F5).
2. Kiểm tra kết quả ở tab **Results**.

**Kết quả mong đợi:**

| STATE | Fog Count | FACT ACCIDENT Count | Fog Percentage |
|---|---:|---:|---:|
| OR | 400 | 5,000 | 8.00% |
| WA | 600 | 10,000 | 6.00% |
| CA | 1,200 | 20,000 | 6.00% |

**Chụp và chèn:** Chú thích **Hình 3.13.14. Kết quả MDX Query**.

### Bước 5: Lưu Query

1. **Ctrl + S** hoặc **File → Save**.
2. Chọn thư mục `D:\OLAP\Pro\SSAS\MDX_d\` (tạo thư mục nếu chưa có).
3. Tên file: `Fog_Percentage.mdx`.
4. Nhấn **Save**.

**Chụp và chèn:** Chú thích **Hình 3.13.15. Lưu MDX Query vào file**.

**💡 Kết quả MDX:** Danh sách bang có tỷ lệ Fog > 5%, sắp xếp giảm dần.

---

## 4. Kết quả và nhận xét

### 4.1 Bảng tóm tắt kết quả

Các bang có tỷ lệ tai nạn sương mù > 5% năm 2022:

| Bang | Số vụ Fog | Tổng vụ | Tỷ lệ % |
|---|---:|---:|---:|
| Oregon (OR) | 400 | 5,000 | 8.00% |
| Washington (WA) | 600 | 10,000 | 6.00% |
| California (CA) | 1,200 | 20,000 | 6.00% |

*(Thay số liệu bằng kết quả thực tế từ cube của bạn)*

### 4.2 Đối chiếu 3 phương pháp

| Phương pháp | Kết quả | Trạng thái |
|---|---|---|
| **1. Cube Browser** | OR = 8%, WA = 6%, CA = 6% | ✅ Khớp |
| **2. Excel PivotTable** | OR = 8%, WA = 6%, CA = 6% | ✅ Khớp |
| **3. MDX Query** | OR = 8%, WA = 6%, CA = 6% | ✅ Khớp |

**Kết luận:** Cả ba phương pháp đều cho kết quả **nhất quán**.

### 4.3 Phân tích

**📊 Nhận xét:**

1. **Oregon có tỷ lệ cao nhất** (8%) - Vùng Tây Bắc Thái Bình Dương thường xuyên có sương mù
2. **Washington và California** cũng có tỷ lệ đáng kể (6%)
3. **Tỷ lệ > 5% là ngưỡng đáng lo ngại** - cần có biện pháp can thiệp

**💡 Khuyến nghị:**

- Lắp đặt **hệ thống cảnh báo sương mù tự động** tại OR, WA, CA
- Tăng cường **biển báo phản quang** và **đèn đường LED**
- Giảm **tốc độ tối đa** trên cao tốc khi có sương mù
- Triển khai **radar cảnh báo khoảng cách** cho xe tải

**🌫️ Mối liên hệ với Visibility:**

Sương mù thường đi kèm với Visibility thấp (< 1 mile). Cần phân tích sâu hơn về:
- Severity của tai nạn trong sương mù
- Distance bị ảnh hưởng
- Thời điểm trong ngày (sáng sớm thường có sương mù nhiều hơn)

---

## 5. Hướng dẫn chụp ảnh

### Danh sách 15 ảnh cần chụp

**Phần 1: Browser (5 ảnh)**
1. Hình 3.13.1 - Chuẩn bị Browser
2. Hình 3.13.2 - Danh sách Weather_Condition có Fog
3. Hình 3.13.3 - Số vụ Fog theo bang
4. Hình 3.13.4 - Tổng số vụ theo bang
5. Hình 3.13.5 - Tính tỷ lệ % bằng Excel

**Phần 2: Excel (5 ảnh)**
6. Hình 3.13.6 - Kết nối cube
7. Hình 3.13.7 - PivotTable cơ bản
8. Hình 3.13.8 - Filter Weather contains Fog
9. Hình 3.13.9 - Tổng số vụ
10. Hình 3.13.10 - Bảng tỷ lệ % với filter > 5%

**Phần 3: MDX (5 ảnh)**
11. Hình 3.13.11 - Kết nối SSMS
12. Hình 3.13.12 - MDX Editor trống
13. Hình 3.13.13 - MDX Query với Calculated Member
14. Hình 3.13.14 - Kết quả MDX
15. Hình 3.13.15 - Lưu file Fog_Percentage.mdx

### Quy trình chụp và chèn

1. **Windows + Shift + S** để chụp màn hình.
2. Lưu vào `D:\OLAP\Pro\Tai_lieu\Bao_cao\Hinh_cau_d\` với tên `Hinh_3.13.1.png`, `Hinh_3.13.2.png`...
3. Chèn vào Word ngay sau bước tương ứng.
4. Thêm chú thích in nghiêng bên dưới ảnh.

### Checklist trước khi nộp

- [ ] Đã chụp đủ 15 ảnh rõ nét (PNG)
- [ ] Đã chèn ảnh vào Word đúng vị trí
- [ ] Đã thêm chú thích cho tất cả ảnh
- [ ] Filter YEAR = 2022 rõ ràng
- [ ] Filter Weather_Condition contains Fog
- [ ] Đã tính tỷ lệ % chính xác
- [ ] Chỉ hiển thị bang > 5%
- [ ] Sắp xếp giảm dần theo tỷ lệ
- [ ] MDX Query có Calculated Member
- [ ] Đã lưu `Pivot_d.xlsx`
- [ ] Đã lưu `Fog_Percentage.mdx`
- [ ] Báo cáo có phần phân tích và khuyến nghị

---

## 6. FAQ

**Q1: Browser có thể filter Weather_Condition LIKE '%Fog%' không?**

A: Không. Browser chỉ hỗ trợ filter theo danh sách giá trị cụ thể. Bạn phải **chọn thủ công** từng giá trị chứa "Fog" (Fog, Light Fog, Heavy Fog...).

**Q2: Browser có thể tính tỷ lệ % tự động không?**

A: Không. Browser không hỗ trợ Calculated Member. Bạn phải:
1. Lấy số vụ Fog (với filter Weather)
2. Lấy tổng số vụ (không filter Weather)
3. Tính tỷ lệ bằng Excel: `(Fog / Total) * 100`

**Q3: Excel có thể filter LIKE '%Fog%' không?**

A: Có! Dùng **Label Filters → Contains → Fog**. Excel sẽ tự động lọc tất cả giá trị có chứa "Fog".

**Q4: MDX Query có chạy được không?**

A: MDX trong tutorial này **phức tạp** vì dùng Calculated Member với InStr. Nếu gặp lỗi, dùng **phương án đơn giản**:

**Phương án 1: Dùng Subselect (đơn giản hơn)**

```mdx
SELECT
{
    [Measures].[FACT ACCIDENT Count]
} ON COLUMNS,
NON EMPTY
    [DIM LOCATION].[STATE].[STATE].Members ON ROWS
FROM
(
    SELECT
        {[ID START DATE].[YEAR].&[2022]} ON COLUMNS
    FROM
    (
        SELECT
            Filter(
                [DIM WEATHER].[WEATHER CONDITION].[WEATHER CONDITION].Members,
                InStr([DIM WEATHER].[WEATHER CONDITION].CurrentMember.Name, "Fog") > 0
            ) ON COLUMNS
        FROM [US Accidents DW]
    )
);
```

Sau đó tính tỷ lệ % bằng Excel.

**Phương án 2: Tạo Calculated Member trong Cube (khuyến nghị)**

Nếu bạn có quyền sửa cube, thêm Calculated Member vào cube definition:

```xml
<CalculatedMember>
  <Name>Fog Percentage</Name>
  <Expression>
    IIF([Measures].[FACT ACCIDENT Count] = 0, NULL,
        (Sum(Filter([DIM WEATHER].[WEATHER CONDITION].Members, 
                    InStr([DIM WEATHER].[WEATHER CONDITION].CurrentMember.Name, "Fog") > 0),
             [Measures].[FACT ACCIDENT Count])
        / [Measures].[FACT ACCIDENT Count]) * 100)
  </Expression>
</CalculatedMember>
```

**Q5: Tại sao phải filter tỷ lệ > 5%?**

A: Đây là **ngưỡng có ý nghĩa** trong phân tích:
- < 5%: Tỷ lệ thấp, không cần ưu tiên
- \> 5%: Tỷ lệ cao, cần có biện pháp can thiệp
- Giúp tập trung nguồn lực vào bang chịu ảnh hưởng nặng nhất

**Q6: Có những giá trị Weather_Condition nào chứa "Fog"?**

A: Tùy vào dữ liệu, thường có:
- Fog
- Light Fog
- Heavy Fog
- Shallow Fog
- Patches of Fog
- Fog / Windy
- Haze / Fog (cũng có thể coi là Fog)

Bạn cần kiểm tra dữ liệu thực tế trong cube (Bước 2 của Browser).

**Q7: Làm sao để verify kết quả?**

A: Chọn **1 bang bất kỳ**, ví dụ California:
1. Đếm số vụ CA có Fog năm 2022: Ví dụ = 1,200
2. Đếm tổng vụ CA năm 2022: Ví dụ = 20,000
3. Tính: (1,200 / 20,000) × 100 = 6.0%
4. Kiểm tra xem kết quả MDX/Excel có khớp không

---

## 7. Kết luận

**Câu trả lời:**

Các bang có tỷ lệ tai nạn sương mù > 5% trong năm 2022 (sắp xếp giảm dần):

1. **Oregon (OR)** - 8.00% (400 vụ Fog / 5,000 tổng vụ)
2. **Washington (WA)** - 6.00% (600 vụ Fog / 10,000 tổng vụ)
3. **California (CA)** - 6.00% (1,200 vụ Fog / 20,000 tổng vụ)

*(Thay số liệu bằng kết quả thực tế từ cube của bạn)*

**Các bước đã thực hiện:**

1. ✅ Browser: Khám phá Weather_Condition chứa "Fog" → Đếm số vụ Fog → Đếm tổng vụ → Tính tỷ lệ % bằng Excel
2. ✅ Excel: Filter Weather contains "Fog" → Tạo 2 PivotTable → Tính tỷ lệ % → Filter > 5% → Sort giảm dần
3. ✅ MDX: Calculated Member [Fog Count] + [Fog Percentage] → FILTER > 5% → ORDER giảm dần
4. ✅ Đối chiếu: 3 phương pháp nhất quán
5. ✅ Phân tích: OR, WA, CA là 3 bang có tỷ lệ cao nhất → Khuyến nghị lắp hệ thống cảnh báo

**Files cần tạo:**

- `Pivot_Excel/Pivot_d.xlsx` (3 sheets: Fog_Count, Total_Count, Fog_Percentage)
- `SSAS/MDX_d/Fog_Percentage.mdx`
- `Tai_lieu/Bao_cao/Hinh_cau_d/` (15 ảnh)

**Điểm đặc biệt của câu d:**

- ⚠️ **Phức tạp nhất** trong các câu vì cần tính tỷ lệ %
- 🔍 Filter LIKE '%Fog%' (không phải equal)
- 📊 Calculated Member trong MDX
- 🎯 Filter kết quả theo ngưỡng (> 5%)

**Ý nghĩa nghiệp vụ:**

Sương mù là nguyên nhân gây tai nạn nghiêm trọng, đặc biệt tại vùng Tây Bắc Thái Bình Dương (OR, WA) và California. Tỷ lệ > 5% cho thấy cần:
- Đầu tư hệ thống cảnh báo thời tiết
- Cải thiện hạ tầng đường bộ (đèn, biển báo)
- Tăng cường kiểm soát tốc độ

---

**🎉 Hoàn thành tutorial câu d!**

**Lưu ý quan trọng:**
- MDX phức tạp → Nếu không chạy được, dùng phương án đơn giản (xem FAQ Q4)
- Browser không tự động tính tỷ lệ → Phải dùng Excel
- Excel là phương pháp dễ nhất cho câu này

**Chúc bạn thành công! 🚀**

