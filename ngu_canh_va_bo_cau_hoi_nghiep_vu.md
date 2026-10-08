# TÀI LIỆU NGỮ CẢNH DỰ ÁN VÀ BỘ CÂU HỎI NGHIỆP VỤ PHÂN TÍCH
**Cơ sở dữ liệu:** `[US_Accidents_DW]`  
**Mô hình kho dữ liệu:** Sơ đồ hình sao (Star Schema) — 7 bảng chiều + 1 bảng sự kiện  
**Quy mô dữ liệu:** 500.000 bản ghi (2016 – 2023)  

---

## 1. CẤU TRÚC KHO DỮ LIỆU

### 1.1. Bảng Sự kiện: `FACT_ACCIDENT`
- **Khóa chính:** `ID_FACT` (INT IDENTITY — tự tăng)
- **Mã vụ tai nạn gốc:** `ACCIDENT_ID` (NVARCHAR(50))
- **9 Khóa ngoại:**
  - `ID_START_DATE` (INT) → DIM_DATE — Ngày bắt đầu tai nạn
  - `ID_START_TIME` (INT) → DIM_TIME — Giờ bắt đầu tai nạn
  - `ID_END_DATE` (INT) → DIM_DATE — Ngày kết thúc tai nạn
  - `ID_END_TIME` (INT) → DIM_TIME — Giờ kết thúc tai nạn
  - `ID_LOCATION` (INT) → DIM_LOCATION
  - `ID_ROAD_STRUCTURE` (INT) → DIM_ROAD_STRUCTURE
  - `ID_TRAFFIC_SIGNAL` (INT) → DIM_TRAFFIC_SIGNAL
  - `ID_SEVERITY` (INT) → DIM_SEVERITY
  - `ID_WEATHER` (INT) → DIM_WEATHER
- **7 Chỉ số đo lường (Measures):**
  1. `DISTANCE` (Float — Chiều dài đoạn đường bị ảnh hưởng / dặm)
  2. `TEMPERATURE` (Float — Nhiệt độ môi trường / °F)
  3. `HUMIDITY` (Float — Độ ẩm tương đối / %)
  4. `PRESSURE` (Float — Áp suất khí quyển / inch Hg)
  5. `VISIBILITY` (Float — Tầm nhìn xa / dặm)
  6. `WIND_SPEED` (Float — Tốc độ gió / mph)
  7. `PRECIPITATION` (Float — Lượng mưa / inch)
- **Thuộc tính phân loại (Degenerate Dimension):**
  - `SUNRISE_SUNSET` (NVARCHAR(10) — Day / Night)

---

### 1.2. Các Bảng Chiều:

1. **`DIM_DATE`** (8 thuộc tính)
   - `ID_DATE` (PK, INT — dạng YYYYMMDD)
   - `FULL_DATE` (DATE)
   - `DAY` (INT), `MONTH` (INT), `QUARTER` (INT), `YEAR` (INT)
   - `DAY_OF_WEEK` (INT — 1: Chủ Nhật → 7: Thứ Bảy)
   - `IS_WEEKEND` (BIT — 0: Ngày thường, 1: Cuối tuần)

2. **`DIM_TIME`** (5 thuộc tính)
   - `ID_TIME` (PK, INT — dạng HHMMSS)
   - `FULL_TIME` (TIME(0))
   - `HOUR` (INT), `MINUTE` (INT), `SECOND` (INT)

3. **`DIM_LOCATION`** (6 thuộc tính)
   - `ID_LOCATION` (PK, INT IDENTITY)
   - `STREET` (NVARCHAR(255))
   - `CITY` (NVARCHAR(100))
   - `COUNTY` (NVARCHAR(100))
   - `STATE` (NVARCHAR(10))
   - `TIMEZONE` (NVARCHAR(50))

4. **`DIM_ROAD_STRUCTURE`** (8 thuộc tính)
   - `ID_ROAD_STRUCTURE` (PK, INT IDENTITY)
   - `AMENITY` (BIT) — Có tiện ích công cộng
   - `BUMP` (BIT) — Có gờ giảm tốc
   - `JUNCTION` (BIT) — Thuộc nút giao thông
   - `NO_EXIT` (BIT) — Đường cụt
   - `RAILWAY` (BIT) — Có đường ray xe lửa
   - `ROUNDABOUT` (BIT) — Thuộc vòng xoay
   - `STATION` (BIT) — Có trạm xe buýt / trạm trung chuyển

5. **`DIM_TRAFFIC_SIGNAL`** (6 thuộc tính)
   - `ID_TRAFFIC_SIGNAL` (PK, INT IDENTITY)
   - `CROSSING` (BIT) — Có vạch kẻ đường cho người đi bộ
   - `GIVE_WAY` (BIT) — Có biển báo nhường đường
   - `STOP_SIGN` (BIT) — Có biển báo dừng lại (STOP)
   - `TRAFFIC_CALMING` (BIT) — Có thiết bị cưỡng chế giảm tốc
   - `TRAFFIC_SIGNAL` (BIT) — Có hệ thống đèn tín hiệu giao thông

6. **`DIM_SEVERITY`** (2 thuộc tính)
   - `ID_SEVERITY` (PK, INT) — Mức độ 1, 2, 3, 4
   - `SEVERITY_DESC` (NVARCHAR(100)) — Diễn giải mô tả

7. **`DIM_WEATHER`** (3 thuộc tính)
   - `ID_WEATHER` (PK, INT IDENTITY)
   - `WEATHER_CONDITION` (NVARCHAR(100))
   - `WIND_DIRECTION` (NVARCHAR(50))

---

### 1.3. Các cột dataset gốc đã loại bỏ (không đưa vào kho dữ liệu):

| Cột gốc | Lý do loại bỏ |
|----------|---------------|
| `Start_Lat`, `Start_Lng`, `End_Lat`, `End_Lng` | Tọa độ GPS chỉ có ý nghĩa khi sử dụng với công cụ GIS (bản đồ), không phù hợp cho truy vấn thống kê SQL thuần túy trong mô hình OLAP |
| `Turning_Loop` | Giá trị gần như toàn bộ là FALSE (0) trong dataset gốc, không có ý nghĩa phân biệt thống kê |

---

## 2. BỘ CÂU HỎI NGHIỆP VỤ PHÂN TÍCH (15 CÂU)
*Toàn bộ 15 câu hỏi dưới đây chỉ sử dụng đúng các cột và measures sẵn có ở trên, không phát sinh bất kỳ thuộc tính nào ngoài CSDL.*

### Hierarchy dùng cho Roll-Up / Drill-Down:
- **Thời gian:** Năm → Quý → Tháng → Ngày
- **Vị trí:** Toàn quốc → State → County → City → Street
- **Mức độ:** ALL Severity → Từng mức (1, 2, 3, 4)
- **Thời tiết:** Nhóm lớn (Mưa/Tuyết/Sương mù/Khác) → Weather_Condition chi tiết

---

**a) 🔽 Drill-Down Location: Toàn quốc → State**
Theo từng năm, thống kê tổng số vụ tai nạn **toàn quốc** cho từng điều kiện hạ tầng: giao lộ (Junction = 1), vòng xoay (Roundabout = 1), đường sắt (Railway = 1) và đèn giao thông (Traffic_Signal = 1). Sau đó, drill-down vào bang California (State = 'CA') để so sánh xu hướng riêng của bang này với xu hướng cả nước. Sắp xếp theo năm tăng dần.
> *Ý nghĩa:* Nhìn trend toàn quốc trước → zoom vào CA (bang đông dân nhất) xem loại hạ tầng nào đang tăng/giảm tai nạn.

**b)** Cho biết thành phố (City, State) có tổng số vụ tai nạn ở mức độ cực kỳ nghiêm trọng (ID_SEVERITY = 4) cao nhất trong quý 2 năm 2021. Nếu có nhiều thành phố đồng hạng, hiển thị tất cả.
> *Ý nghĩa:* Tập trung Q2/2021 (hậu COVID, lưu lượng phục hồi mạnh) → xác định điểm nóng cần ưu tiên can thiệp.

**c)** Liệt kê các thành phố tại bang Texas (State = 'TX') có tổng số vụ tai nạn giao thông lớn hơn 1.000 vụ, kèm theo số vụ tai nạn và khoảng cách ảnh hưởng trung bình (Distance) của từng thành phố. Sắp xếp kết quả theo số vụ tai nạn giảm dần.
> *Ý nghĩa:* Texas là bang lớn nhất về diện tích đường bộ → xác định siêu đô thị tập trung tai nạn để phân bổ ngân sách tuần tra.

**d)** Với từng bang, tính tỷ lệ phần trăm số vụ tai nạn xảy ra trong điều kiện sương mù (Weather_Condition LIKE '%Fog%') trên tổng số vụ tai nạn của chính bang đó trong năm 2022. Chỉ hiển thị các bang có tỷ lệ sương mù trên 5%, sắp xếp giảm dần.
> *Ý nghĩa:* Lọc ngưỡng 5% giúp tập trung vào bang chịu tác động nặng nhất → đề xuất lắp biển cảnh báo sương mù tự động.

**e) 🔼 Roll-Up Time: Tháng → Quý → Năm (dùng ROLLUP)**
Thống kê số vụ tai nạn xảy ra ban ngày (Sunrise_Sunset = 'Day') và ban đêm (Sunrise_Sunset = 'Night') ở 3 mức tổng hợp: theo **tháng**, roll-up lên **quý**, và roll-up lên **năm**. Hiển thị cả 3 mức trong cùng kết quả, phân biệt ngày thường (IS_WEEKEND = 0) và cuối tuần (IS_WEEKEND = 1).
> *Ý nghĩa:* Cùng 1 truy vấn cho 3 góc nhìn (tháng/quý/năm) — ứng dụng điển hình của `ROLLUP` trong OLAP. Xem trend Day/Night từ chi tiết đến tổng quát.

**f) 🔽 Drill-Down Location: State → City → Street**
**Bước 1 (tổng quan):** Thống kê tổng số vụ tai nạn tại nơi có đèn giao thông (Traffic_Signal = 1) và xảy ra vào ban đêm (Sunrise_Sunset = 'Night') theo **từng bang**, kèm tỷ lệ tai nạn mức 3–4.
**Bước 2 (drill-down):** Với bang có số vụ cao nhất, liệt kê **các con đường (Street, City)** có trên 50 vụ, kèm tổng số vụ và khung giờ (Hour) có nhiều vụ nhất.
> *Ý nghĩa:* Đi từ tổng thể (bang nào tệ nhất?) → chi tiết (con đường nào cần sửa đèn?). Mô phỏng hành vi phân tích thực tế của người dùng OLAP.

**g) 🔼🔽 Roll-Up + Drill-Down Time: Năm ↔ Quý (dùng ROLLUP)**
Theo từng năm và quý từ 2019 đến 2022, thống kê tổng số vụ tai nạn; phần trăm tăng/giảm so với cùng quý năm trước (YoY%); tỷ lệ vụ mức 3–4 (ID_SEVERITY IN (3, 4)); và tỷ lệ vụ ban đêm (Sunrise_Sunset = 'Night'). Dùng `ROLLUP(YEAR, QUARTER)` để hiển thị **cả tổng theo năm và chi tiết theo quý** trong cùng kết quả.
> *Ý nghĩa:* Roll-up nhìn tổng năm thấy COVID impact → drill-down vào quý thấy Q2/2020 (giãn cách) giảm bao nhiêu vs Q3/2020 (nới lỏng) phục hồi thế nào.

**h) 🔽 Drill-Down Location: State → City**
Trong năm 2021, xếp hạng TOP 5 bang có tổng Distance lớn nhất, kèm tổng số vụ và Distance trung bình mỗi vụ. Với **bang đứng đầu**, drill-down xuống liệt kê **TOP 3 thành phố** có Distance lớn nhất trong bang đó.
> *Ý nghĩa:* Tìm bang tê liệt nhất → zoom vào thành phố nào gây ra tình trạng đó. Phát hiện điểm nghẽn cứu hộ cụ thể.

**i) 🔼 Roll-Up Severity: Detail → Tổng (dùng ROLLUP)**
Theo từng mức độ nghiêm trọng (SEVERITY_DESC), tính thời gian xử lý tai nạn trung bình (chênh lệch End_Date/End_Time − Start_Date/Start_Time theo phút), tổng số vụ, tổng Distance, Visibility trung bình và tỷ lệ phần trăm số vụ trên toàn bộ dữ liệu. Thêm **1 dòng roll-up tổng** (ALL severity) ở cuối để so sánh từng mức với trung bình chung. Sắp xếp theo thời gian xử lý giảm dần.
> *Ý nghĩa:* Dòng tổng giúp nhận ra: severity 2 chiếm 80% số vụ nhưng chỉ 30% Distance, còn severity 4 chiếm 2% số vụ nhưng 25% Distance.

**j)** Cho biết bang (State) có tổng số vụ tai nạn cao nhất và thấp nhất trong toàn bộ dữ liệu, kèm tổng Distance và tỷ lệ tai nạn mức 3–4, nhiệt độ trung bình (Temperature), độ ẩm trung bình (Humidity) và áp suất trung bình (Pressure). Trả về tất cả bang đồng hạng ở hai đầu.
> *Ý nghĩa:* So sánh: bang nhiều vụ nhất có phải cũng nghiêm trọng nhất không? Hay bang ít vụ nhưng mỗi vụ đều nặng?

**k)** Với mỗi quận (County) thuộc bang California (State = 'CA'), đưa ra 3 thành phố (City) có tổng số vụ tai nạn cao nhất kèm tầm nhìn trung bình (Visibility) và tốc độ gió trung bình (Wind_Speed). Nếu có các thành phố đồng hạng, hiển thị tất cả.
> *Ý nghĩa:* Drill-down tự nhiên State → County → City trong phạm vi CA.

**l) 🔼 Roll-Up Weather: Detail → Nhóm lớn**
Với từng điều kiện thời tiết (Weather_Condition) không bị thiếu, thống kê số vụ, nhiệt độ trung bình, lượng mưa trung bình và Distance trung bình. **Thêm roll-up:** gom Weather_Condition chứa "Rain" thành **nhóm Mưa**, chứa "Snow" thành **nhóm Tuyết**, chứa "Fog" thành **nhóm Sương mù**, còn lại là **nhóm Khác**, và thống kê tổng theo từng nhóm.
> *Ý nghĩa:* Weather_Condition có hàng chục giá trị (Light Rain, Heavy Rain...). Roll-up thành nhóm lớn giúp nhìn tổng quan: Mưa vs Tuyết vs Sương mù — nhóm nào nguy hiểm nhất?

**m)** Theo từng loại đặc điểm hạ tầng, thống kê tổng số vụ, số vụ severity 4 (ID_SEVERITY = 4) và tỷ lệ phần trăm severity 4. Xét tất cả đặc điểm hạ tầng đường bộ (Amenity, Bump, Junction, No_Exit, Railway, Roundabout, Station) và tín hiệu giao thông (Crossing, Give_Way, Stop_Sign, Traffic_Calming, Traffic_Signal). Sắp xếp theo tỷ lệ giảm dần.
> *Ý nghĩa:* So sánh toàn bộ loại hạ tầng — loại nào có tỷ lệ tai nạn chết người cao nhất?

**n)** Tại New York (State = 'NY'), liệt kê 5 điều kiện thời tiết (không rỗng, không thiếu) có số vụ cao nhất, kèm số vụ, Distance trung bình, Visibility trung bình và tỷ lệ tai nạn ban đêm (Sunrise_Sunset = 'Night').
> *Ý nghĩa:* Tìm điều kiện thời tiết nguy hiểm nhất tại NY (mùa đông khắc nghiệt) để cảnh báo tài xế.

**o)** Trong năm 2022, đưa ra TOP 5 bang có số vụ severity 3–4 cao nhất, với thời tiết chứa "Rain" hoặc "Fog" và tai nạn tại giao lộ (Junction = 1) hoặc nơi có đèn giao thông (Traffic_Signal = 1). Với mỗi bang hiển thị số vụ, Distance trung bình và Visibility trung bình; mỗi vụ chỉ tính một lần.
> *Ý nghĩa:* Phân tích đa chiều phức tạp nhất — kết hợp thời gian + thời tiết + hạ tầng + severity.
