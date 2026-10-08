# DW-OLAP

Dự án kho dữ liệu và phân tích OLAP cho dữ liệu US Accidents, sử dụng SQL Server, SSIS, SSAS Multidimensional và Excel PivotTable.

## Mở nhanh

- **Pivot Excel:** [Câu a (tạo theo hướng dẫn)](Tai_lieu/Huong_dan_bao_cao_cau_a.md) · [Câu b](Pivot_Excel/Pivot_b.xlsx) · [Câu e](Pivot_Excel/Pivot_e.xlsx) · [Cách mở và lưu workbook](Pivot_Excel/README.md)
- **Đề bài:** [Ngữ cảnh và 15 câu hỏi nghiệp vụ](Tai_lieu/ngu_canh_va_bo_cau_hoi_nghiep_vu.md)
- **Hướng dẫn:** [Câu a: Cube Browser, Pivot Excel, MDX và cách chụp ảnh báo cáo](Tai_lieu/Huong_dan_bao_cao_cau_a.md) · [Manual và Pivot câu b, e, f](Tai_lieu/Huong_dan_manual_b_e_f.md) · [Câu f: Top 5 đường ở California](Tai_lieu/Huong_dan_cau_f_Top5.md)
- **Báo cáo:** [Báo cáo SSIS](Tai_lieu/Bao_cao/24520814_24521985_SSIS.docx) · [Kế hoạch triển khai](Tai_lieu/Bao_cao/Plan_trien_khai_Chuong_5_US_Accidents.docx)

## Cấu trúc thư mục

```text
DW-OLAP/
├── Pivot_Excel/          # Workbook kết quả câu b, e; lưu câu f tại đây khi hoàn thành
├── Tai_lieu/            # Đề bài và hướng dẫn thao tác
│   └── Bao_cao/          # Báo cáo Word và kế hoạch triển khai
├── SQL/                 # Script kho dữ liệu
├── SSIS/                # Project ETL
├── SSAS/                # Project cube, truy vấn MDX và bản sao cấu hình
├── archive/             # Dữ liệu CSV qua Git LFS
├── tools/               # Script hỗ trợ
└── README.md
```

| Đường dẫn | Nội dung |
|---|---|
| `SSIS/` | Solution và package ETL |
| `SSAS/SSAS/` | Project SSAS, data source, DSV, dimensions và cube |
| `SSAS/MDX_a/` | Truy vấn MDX câu a, so sánh toàn quốc và California theo năm |
| `SSAS/MDX_b_e_f/` | Truy vấn MDX b, e, f đã chạy kiểm chứng trên cube |
| `SSAS/backups/` | Bản sao cấu hình và kết quả kiểm chứng |
| `archive/Accidents_500.csv` | Dữ liệu mẫu 500.000 dòng |
| `archive/Accidents(16-23).csv` | File dữ liệu nguồn lớn |
| `tools/` | Script hỗ trợ chỉnh cấu hình, deploy và kiểm chứng |
| [Pivot_Excel/](Pivot_Excel/) | Workbook PivotTable và hướng dẫn mở, lưu kết quả |
| [Tai_lieu/](Tai_lieu/) | Ngữ cảnh, 15 câu hỏi và hướng dẫn manual/Pivot |
| [Tai_lieu/Bao_cao/](Tai_lieu/Bao_cao/) | Báo cáo Word và kế hoạch triển khai |
| [SQL/QueryProject.sql](SQL/QueryProject.sql) | Script cấu trúc và thao tác kho dữ liệu |

## Tải đầy đủ dữ liệu bằng Git LFS

Hai file CSV được lưu qua Git LFS. Cài Git LFS rồi chạy:

```powershell
git lfs install
git clone https://github.com/TanVi3001/DW-OLAP.git
cd DW-OLAP
git lfs pull
```

## Mở project

- SSIS: mở `SSIS/SSIS.slnx` trong Visual Studio có extension Integration Services Projects; nếu phiên bản không hỗ trợ `.slnx`, mở project `.dtproj` trong thư mục `SSIS/SSIS/`.
- SSAS: mở `SSAS/SSAS.slnx` trong Visual Studio có extension Analysis Services Projects; nếu phiên bản không hỗ trợ `.slnx`, mở `SSAS/SSAS/SSAS.dwproj`.
- Điều chỉnh connection string và server deployment theo máy chạy. Cấu hình hiện tại dùng SQL database `US_Accidents_DW`, SSAS database `SSAS`, cube `US Accidents DW`.

`SQL/QueryProject.sql` có các lệnh DROP/TRUNCATE: đọc và chọn đúng phần cần chạy khi sử dụng kho dữ liệu đã có.

Cache Visual Studio, file thiết lập người dùng và thư mục build tự sinh không được đưa vào Git. Các báo cáo, dữ liệu, project, hướng dẫn và truy vấn được lưu trong repo.
