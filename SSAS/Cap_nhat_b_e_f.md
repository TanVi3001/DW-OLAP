# Trạng thái cập nhật trực tiếp project SSAS

Đã sửa các file trong `SSAS/SSAS`:

- `DIM TIME.dim`: HOUR dùng khóa HOUR; MINUTE dùng HOUR + MINUTE; SECOND dùng HOUR + MINUTE + SECOND. Quan hệ ID TIME → SECOND → MINUTE → HOUR; hierarchy vẫn HOUR → MINUTE → SECOND.
- `DIM LOCATION.dim`: STATE dùng khóa STATE; CITY dùng STATE + CITY; STREET dùng STATE + CITY + STREET; COUNTY dùng STATE + COUNTY. Quan hệ ID LOCATION → STREET → CITY → STATE, nhánh COUNTY → STATE. Hierarchy `Location_BEF` là STATE → CITY → STREET.
- `FACT ACCIDENT.dim`: thêm thuộc tính SUNRISE SUNSET để lọc Day/Night. Khóa thiếu được ánh xạ về member trống; khi làm e/f chỉ chọn Day hoặc Night.
- `US Accidents DW.cube`: đưa SUNRISE SUNSET vào danh sách thuộc tính của cube.

DIM DATE đã được người dùng sửa đúng và được giữ nguyên.

## Kiểm tra đã hoàn tất

- Các file XML đọc được.
- Mọi attribute đều có đường quan hệ từ khóa gốc dimension.
- Mỗi cấp con trong hierarchy có quan hệ đi tới cấp cha.
- Bản sao lưu trước khi sửa: `backups/bef_20261007_231746/`.

## Deploy/Process chưa hoàn tất

Đã kết nối SSAS `localhost\SSASMD`, database `SSAS`, và thử cập nhật bằng batch XMLA có transaction kèm Process Full.

SQL Server bị timeout cả khi đọc thông tin hệ thống và qua kết nối quản trị DAC. Process không tiếp tục đọc dữ liệu trong nhiều phút. Đã gửi yêu cầu hủy riêng session xử lý do agent tạo (SPID 74182); chưa có lần commit thành công.

Lần kiểm tra sau yêu cầu hủy cho thấy database/cube đã triển khai trước đó vẫn ở trạng thái Processed, khóa HOUR trên server vẫn có 3 cột và SUNRISE SUNSET chưa có trên server. Do đó các thay đổi hiện nằm trong file project; chưa thể tuyên bố kết quả cube mới đã được kiểm chứng.

## Mở lại trong Visual Studio

1. Nếu Visual Studio báo file đã thay đổi ngoài IDE, chọn Reload. Nếu không có thông báo, đóng các tab designer đã sửa và mở lại; nếu vẫn hiện cấu hình cũ, mở lại project. Không lưu cấu hình cũ từ designer đè lên các file sửa.
2. Kiểm tra DIM TIME và DIM LOCATION theo cấu hình trên.
3. Sau khi SQL Server trả lời truy vấn bình thường, Deploy và Process lại. Có thể dùng Visual Studio hoặc `tools/deploy_ssas_bef.ps1` từ thư mục dự án.
4. Sau khi Process thành công, chạy `tools/verify_ssas_bef.ps1` để đối chiếu b/e/f trên cube; kết quả được lưu vào `SSAS/backups/bef_verification.json`.
5. Browser chọn Reconnect. Excel Pivot chọn Refresh khi đã kết nối đúng server `LAPTOP-40H784NV\SSASMD`/database `SSAS`/cube `US Accidents DW`.

Phiên làm việc chưa có Excel document session kết nối, nên agent chưa trực tiếp kéo thả Pivot trong Excel.
