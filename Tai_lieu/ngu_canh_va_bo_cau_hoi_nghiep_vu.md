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
- **Thời tiết:** Weather_Condition và WIND_DIRECTION

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

**f) 🔽 Drill-Down Location: California → City → Street**
Liệt kê **Top 5 cặp đường và thành phố** tại California (`State = 'CA'`) có số vụ tai nạn cao nhất, chỉ tính các vụ xảy ra ban đêm (`Sunrise_Sunset = 'Night'`) tại nơi có đèn giao thông (`Traffic_Signal = 1`), kèm số vụ của từng địa điểm và lấy cả các địa điểm đồng hạng ở vị trí thứ 5.
> *Ý nghĩa:* Xác định các đường tập trung nhiều vụ tai nạn ban đêm tại nơi có đèn giao thông trong California để ưu tiên khảo sát.

**g) 🔼🔽 Roll-Up + Drill-Down Time: Năm ↔ Quý (dùng ROLLUP)**
Theo từng năm và quý từ 2019 đến 2022, thống kê tổng số vụ tai nạn; phần trăm tăng/giảm so với cùng quý năm trước (YoY%); tỷ lệ vụ mức 3–4 (ID_SEVERITY IN (3, 4)); và tỷ lệ vụ ban đêm (Sunrise_Sunset = 'Night'). Dùng `ROLLUP(YEAR, QUARTER)` để hiển thị **cả tổng theo năm và chi tiết theo quý** trong cùng kết quả.
> *Ý nghĩa:* Roll-up nhìn tổng năm thấy COVID impact → drill-down vào quý thấy Q2/2020 (giãn cách) giảm bao nhiêu vs Q3/2020 (nới lỏng) phục hồi thế nào.

**h) 🔽 Drill-Down Location: State → City**
Trong năm 2021, xếp hạng TOP 5 bang có tổng Distance lớn nhất, kèm tổng số vụ và Distance trung bình mỗi vụ. Với **bang đứng đầu**, drill-down xuống liệt kê **TOP 3 thành phố** có Distance lớn nhất trong bang đó.
> *Ý nghĩa:* Tìm bang tê liệt nhất → zoom vào thành phố nào gây ra tình trạng đó. Phát hiện điểm nghẽn cứu hộ cụ thể.

**i) 🔼 Roll-Up Severity: Detail → Tổng (dùng ROLLUP)**
Theo từng mức độ nghiêm trọng (SEVERITY_DESC), thống kê tổng số vụ tai nạn, tỷ lệ số vụ trên toàn bộ dữ liệu, tổng Distance và Visibility trung bình. Thêm **một dòng tổng hợp tất cả mức độ** ở cuối để đối chiếu; sắp xếp theo tổng số vụ giảm dần.
> *Ý nghĩa:* So sánh mức độ phổ biến và mức ảnh hưởng của các vụ tai nạn giữa các nhóm severity.

**j)** Cho biết bang (State) có tổng số vụ tai nạn cao nhất và thấp nhất trong toàn bộ dữ liệu, kèm tổng Distance và tỷ lệ tai nạn mức 3–4, nhiệt độ trung bình (Temperature), độ ẩm trung bình (Humidity) và áp suất trung bình (Pressure). Trả về tất cả bang đồng hạng ở hai đầu.
> *Ý nghĩa:* So sánh: bang nhiều vụ nhất có phải cũng nghiêm trọng nhất không? Hay bang ít vụ nhưng mỗi vụ đều nặng?

**k)** Với mỗi quận (County) tại California (State = 'CA'), thống kê số vụ tai nạn, tầm nhìn trung bình (Visibility) và tốc độ gió trung bình (Wind_Speed) theo từng thành phố (City). Sắp xếp kết quả theo tổng số vụ giảm dần.
> *Ý nghĩa:* So sánh tình hình tai nạn và điều kiện quan sát giữa các thành phố thuộc từng quận của California.

**l) Weather Condition × Wind Direction**
Với từng tổ hợp điều kiện thời tiết (Weather_Condition) không bị thiếu và hướng gió (WIND_DIRECTION), thống kê số vụ tai nạn, nhiệt độ trung bình (Temperature), lượng mưa trung bình (Precipitation) và Distance trung bình.
> *Ý nghĩa:* Xem điều kiện thời tiết và hướng gió nào thường đi cùng nhiều vụ tai nạn hơn.

**m)** Với từng thuộc tính hạ tầng và tín hiệu giao thông hiện có (AMENITY, BUMP, JUNCTION, NO_EXIT, RAILWAY, ROUNDABOUT, STATION, CROSSING, GIVE_WAY, STOP_SIGN, TRAFFIC_CALMING, TRAFFIC_SIGNAL), so sánh hai nhóm có (True) và không có (False) thuộc tính đó. Thống kê số vụ tai nạn, số vụ severity 4 và tỷ lệ severity 4 trên tổng số vụ của từng nhóm; trình bày riêng kết quả cho từng thuộc tính.
> *Ý nghĩa:* Đánh giá mối liên hệ giữa sự hiện diện của từng đặc điểm hạ tầng và mức độ nghiêm trọng của tai nạn. Mỗi cờ được phân tích riêng theo đúng cấu trúc hiện tại của mô hình.

**n)** Tại New York (State = 'NY'), liệt kê 5 điều kiện thời tiết (không rỗng, không thiếu) có số vụ cao nhất, kèm số vụ, Distance trung bình, Visibility trung bình và tỷ lệ tai nạn ban đêm (Sunrise_Sunset = 'Night').
> *Ý nghĩa:* Tìm điều kiện thời tiết nguy hiểm nhất tại NY (mùa đông khắc nghiệt) để cảnh báo tài xế.

**o)** Trong năm 2022, tìm Top 5 bang có nhiều vụ severity 3–4 nhất trong điều kiện thời tiết chứa "Rain" hoặc "Fog", đồng thời xảy ra tại giao lộ (Junction = 1) hoặc nơi có đèn giao thông (Traffic_Signal = 1). Kèm số vụ, Distance trung bình và Visibility trung bình của mỗi bang. Nếu một vụ thỏa cả Junction = 1 lẫn Traffic_Signal = 1, chỉ tính vụ đó một lần.
> *Ý nghĩa:* Xác định các bang có nhiều vụ nghiêm trọng nhất trong điều kiện mưa hoặc sương mù tại các vị trí có đặc điểm hạ tầng liên quan.
