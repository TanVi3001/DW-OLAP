# DW-OLAP — US Accidents Data Warehouse & OLAP

## 1. Giới thiệu đề tài

Đề tài xây dựng **kho dữ liệu và hệ thống phân tích OLAP cho dữ liệu tai nạn giao thông US Accidents**. Mục tiêu là chuyển dữ liệu tai nạn dạng phẳng thành mô hình kho dữ liệu có cấu trúc, sau đó khai thác bằng SQL, SSAS Multidimensional, MDX, Excel PivotTable và Power BI.

Dữ liệu gồm khoảng **500.000 bản ghi tai nạn trong giai đoạn 2016–2023**. Hệ thống cho phép phân tích theo thời gian, địa điểm, thời tiết, mức độ nghiêm trọng và đặc điểm hạ tầng giao thông.

> Đây là đồ án môn **Kho dữ liệu và OLAP**, tập trung vào pipeline dữ liệu, mô hình chiều, truy vấn phân tích và trực quan hóa kết quả.

## 2. Mục tiêu đề tài

### Mục tiêu dự kiến

1. Làm sạch và chuẩn hóa dữ liệu US Accidents.
2. Thiết kế kho dữ liệu theo mô hình sao.
3. Xây dựng quy trình ETL để nạp dữ liệu nguồn.
4. Xây dựng cube OLAP trên SQL Server Analysis Services.
5. Tạo measure, calculated member và named set phục vụ phân tích.
6. Giải quyết 15 câu hỏi nghiệp vụ bằng SQL/MDX, Cube Browser và Excel PivotTable.
7. Xây dựng báo cáo trực quan bằng Power BI.
8. Chuẩn bị nền tảng cho các phân tích Data Mining ở giai đoạn tiếp theo.

### Phạm vi phân tích

Các câu hỏi nghiệp vụ tập trung vào:

- Xu hướng tai nạn theo năm, quý, tháng, ngày và giờ;
- So sánh bang, quận, thành phố và tuyến đường;
- Điều kiện thời tiết, hướng gió, nhiệt độ, lượng mưa và tầm nhìn;
- Phân bố mức độ nghiêm trọng của tai nạn;
- Ảnh hưởng của junction, railway, roundabout, traffic signal và các thuộc tính hạ tầng;
- Các thao tác roll-up, drill-down, filter, ranking và so sánh.

Danh sách đầy đủ 15 câu hỏi: [Tai_lieu/ngu_canh_va_bo_cau_hoi_nghiep_vu.md](Tai_lieu/ngu_canh_va_bo_cau_hoi_nghiep_vu.md).

## 3. Kiến trúc và mô hình dữ liệu

Kho dữ liệu sử dụng mô hình **Star Schema**, gồm:

- `FACT_ACCIDENT`: lưu vụ tai nạn và các measure `DISTANCE`, `TEMPERATURE`, `HUMIDITY`, `PRESSURE`, `VISIBILITY`, `WIND_SPEED`, `PRECIPITATION`.
- `DIM_DATE`: ngày, tháng, quý, năm, thứ trong tuần và cuối tuần.
- `DIM_TIME`: giờ, phút và giây.
- `DIM_LOCATION`: street, city, county, state và timezone.
- `DIM_ROAD_STRUCTURE`: junction, railway, roundabout, bump, station và các thuộc tính hạ tầng.
- `DIM_TRAFFIC_SIGNAL`: traffic signal, crossing, stop sign, give way và các tín hiệu giao thông.
- `DIM_SEVERITY`: mức độ nghiêm trọng từ 1 đến 4.
- `DIM_WEATHER`: weather condition và wind direction.

## 4. Những phần đã thực hiện

### 4.1. SQL và kho dữ liệu

- Đã xây dựng script SQL cho cơ sở dữ liệu `US_Accidents_DW`.
- Đã tổ chức bảng fact, dimension, khóa chính, khóa ngoại và measure.
- Đã chuẩn bị dữ liệu mẫu và dữ liệu nguồn lớn trong `archive/`.

### 4.2. ETL bằng SSIS

- Đã tạo project SSIS và package ETL.
- Đã thực hiện đọc dữ liệu nguồn, làm sạch, biến đổi và nạp vào bảng dimension/fact.
- Project và package nằm trong [`SSIS/`](SSIS/).

### 4.3. Cube OLAP bằng SSAS

- Đã tạo data source, data source view, dimensions, measure group và cube `US Accidents DW`.
- Đã triển khai cube trên SQL Server Analysis Services.
- Đã tạo calculated members về junction, railway, roundabout, traffic signal, YoY growth, average distance và fog accident rate.
- Đã tạo named sets, tiêu biểu là Top 5 street tại California trong điều kiện ban đêm và có đèn giao thông.

### 4.4. Truy vấn MDX và PivotTable

- Đã thực hiện các truy vấn MDX cho các câu hỏi nghiệp vụ trong thư mục [`SSAS/`](SSAS/).
- Đã kiểm tra kết quả bằng Cube Browser.
- Đã tạo workbook Excel PivotTable tương ứng trong [`Pivot_Excel/`](Pivot_Excel/).
- Các phân tích gồm xu hướng theo năm, so sánh toàn quốc với California, top địa điểm, thời tiết, severity và hạ tầng giao thông.

### 4.5. Power BI

- Đã tạo báo cáo Power BI tại [`PowerBI/3_PBi.pbix`](PowerBI/3_PBi.pbix).
- Báo cáo sử dụng dữ liệu từ mô hình/cube để trực quan hóa kết quả các câu hỏi nghiệp vụ.
- Có thể phát triển dashboard theo các nhóm: hạ tầng giao thông, thời tiết và severity, địa lý, xu hướng thời gian và khu vực rủi ro cao.

### 4.6. Data Mining — phạm vi dự kiến

Thư mục [`DataMining/`](DataMining/) được tạo để lưu notebook, script, mô hình và kết quả phân tích dự đoán trong giai đoạn tiếp theo. Hiện tại phần chính của đồ án tập trung vào Data Warehouse và OLAP; các mô hình classification, clustering hoặc prediction chưa được xem là hoàn thành nếu chưa có file kết quả tương ứng.

## 5. Cấu trúc repository

```text
DW-OLAP/
├── archive/              # Dữ liệu CSV; một số file lớn dùng Git LFS
├── DataMining/           # Khu vực dành cho mô hình và kết quả Data Mining
├── images/               # Danh sách và yêu cầu hình ảnh báo cáo
├── Pivot_Excel/          # Workbook PivotTable
├── PowerBI/              # Báo cáo Power BI (.pbix)
├── SQL/                  # Script kho dữ liệu
├── SSAS/                 # Cube, dimensions, partitions và MDX
├── SSIS/                 # Project và package ETL
├── Tai_lieu/             # Đề bài, hướng dẫn và báo cáo
├── tools/                # Script deploy và kiểm chứng
└── README.md
```

| Đường dẫn | Nội dung |
|---|---|
| [`SQL/QueryProject.sql`](SQL/QueryProject.sql) | Script SQL của kho dữ liệu |
| [`SSIS/`](SSIS/) | Quy trình ETL |
| [`SSAS/SSAS/`](SSAS/SSAS/) | Cube, dimensions, data source và partitions |
| [`SSAS/MDX_a/`](SSAS/MDX_a/) đến `SSAS/MDX_g/` | Các truy vấn MDX |
| [`Pivot_Excel/`](Pivot_Excel/) | Kết quả phân tích bằng Excel PivotTable |
| [`PowerBI/`](PowerBI/) | Báo cáo trực quan Power BI |
| [`DataMining/`](DataMining/) | Khu vực chuẩn bị cho Data Mining |
| [`Tai_lieu/`](Tai_lieu/) | Ngữ cảnh, 15 câu hỏi và hướng dẫn |

## 6. Cách mở và sử dụng

### Clone repository

```powershell
git lfs install
git clone https://github.com/TanVi3001/DW-OLAP.git
cd DW-OLAP
git lfs pull
```

### Mở SSIS

Mở `SSIS/SSIS.slnx` bằng Visual Studio có extension **Integration Services Projects**. Nếu không hỗ trợ `.slnx`, mở `SSIS/SSIS/SSIS.dtproj`.

### Mở SSAS

Mở `SSAS/SSAS.slnx` bằng Visual Studio có extension **Analysis Services Projects**. Nếu không hỗ trợ `.slnx`, mở `SSAS/SSAS/SSAS.dwproj`.

### Mở Power BI

Mở [`PowerBI/3_PBi.pbix`](PowerBI/3_PBi.pbix) bằng Power BI Desktop. Khi dùng trên máy khác, kiểm tra lại server, database, connection mode và quyền truy cập SSAS/SQL Server.

### Lưu ý

- Điều chỉnh connection string và deployment target theo môi trường thực tế.
- Cấu hình hiện tại dùng database `US_Accidents_DW`, SSAS database `SSAS` và cube `US Accidents DW`.
- `SQL/QueryProject.sql` có thể chứa lệnh `DROP` hoặc `TRUNCATE`; cần đọc kỹ trước khi chạy.
- File CSV lớn được quản lý bằng Git LFS.

## 7. Kết quả và hướng phát triển

Đề tài đã hoàn thành nền tảng của hệ thống phân tích OLAP: dữ liệu nguồn, kho dữ liệu, ETL, cube SSAS, truy vấn MDX, PivotTable và báo cáo Power BI. Hệ thống cho phép phân tích tai nạn theo nhiều chiều, thực hiện roll-up, drill-down, lọc, xếp hạng và so sánh.

Hướng phát triển tiếp theo:

- Hoàn thiện dashboard Power BI cho toàn bộ 15 câu hỏi.
- Bổ sung Data Mining để dự đoán severity hoặc phân nhóm khu vực rủi ro cao.
- Bổ sung kiểm thử tự động cho ETL và truy vấn MDX.
- Tối ưu partition, aggregation và hiệu năng khi dùng toàn bộ dữ liệu.
- Hoàn thiện tài liệu triển khai để có thể dựng lại hệ thống từ đầu.

## 8. Tài liệu tham khảo trong repository

- [Ngữ cảnh và 15 câu hỏi nghiệp vụ](Tai_lieu/ngu_canh_va_bo_cau_hoi_nghiep_vu.md)
- [Hướng dẫn câu a: Cube Browser, Pivot Excel và MDX](Tai_lieu/Huong_dan_bao_cao_cau_a.md)
- [Hướng dẫn câu f: Top 5 street tại California](Tai_lieu/Huong_dan_cau_f_Top5.md)
- [Báo cáo SSIS](Tai_lieu/Bao_cao/24520814_24521985_SSIS.docx)
- [Kế hoạch triển khai](Tai_lieu/Bao_cao/Plan_trien_khai_Chuong_5_US_Accidents.docx)
- [Báo cáo PDF mẫu](%5B6%5D_IS217Q11_23520009_23520753.pdf)

---

**Môn học:** Kho dữ liệu và OLAP
**Đề tài:** US Accidents Data Warehouse & OLAP
**Repository:** [TanVi3001/DW-OLAP](https://github.com/TanVi3001/DW-OLAP)

