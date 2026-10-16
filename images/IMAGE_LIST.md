# Danh sách hình ảnh cần chụp cho Tutorial Câu B

Tất cả các hình ảnh cần được lưu vào thư mục `d:\OLAP\Pro\images\` với tên file chính xác.

## PHƯƠNG PHÁP 1: Named Set trong Browser (12 hình)

### Tạo Named Set
1. **b_step1_1_script_view.png** - Click vào "Script View" trong tab Calculations
2. **b_step1_2_paste_code.png** - Dán code Named Set `Top_City_Severity2_Year2021` vào cuối Script View
3. **b_step1_3_save.png** - Lưu thay đổi trong Cube (Ctrl+S)
4. **b_step1_4_form.png** - (Tùy chọn) Form Named Set Properties

### Deploy Cube
5. **b_step1_5_deploy.png** - Menu Deploy trong Solution Explorer
6. **b_step1_6_output.png** - Output window hiển thị "Deploy complete"

### Sử dụng Named Set
7. **b_step1_7_reconnect.png** - Nhấn Reconnect trong Browser
8. **b_step1_8_sets_list.png** - Named Set `Top_City_Severity2_Year2021` xuất hiện trong mục Sets
9. **b_step1_9_drag_set.png** - Kéo Named Set vào vùng Rows
10. **b_step1_10_drag_measure.png** - Kéo FACT ACCIDENT Count vào Data
11. **b_step1_11_result.png** - Kết quả cuối cùng: Miami, FL với 10,977 vụ tai nạn
12. **b_step1_12_copy.png** - Menu Copy để xuất kết quả

## PHƯƠNG PHÁP 2: MDX Query trong SSMS (5 hình)

13. **b_step2_1_connect.png** - Dialog Connect to Analysis Services
14. **b_step2_2_new_query.png** - Menu New Query > MDX
15. **b_step2_3_query.png** - MDX Query hoàn chỉnh với Severity 2, Year 2021
16. **b_step2_4_result.png** - Kết quả: Miami, FL - 10,977 vụ
17. **b_step2_5_copy.png** - Menu Copy Results

## PHƯƠNG PHÁP 3: SQL Query (2 hình)

18. **b_step3_1_sql.png** - SQL Query với CTE (Severity=2, Year=2021)
19. **b_step3_2_sql_result.png** - Kết quả SQL: Miami, FL - 10,977 vụ

---

**Tổng cộng: 19 hình ảnh**

**Lưu ý:**
- Format: PNG hoặc JPG
- Tên file phải chính xác như trên
- Đảm bảo text trong ảnh đọc được rõ
- **Kết quả mẫu**: Miami, FL với 10,977 vụ tai nạn Severity 2 trong năm 2021
- Ưu tiên chụp Phương pháp 1 (Named Set) vì được khuyên dùng nhất

**Thay đổi từ phiên bản cũ:**
- ✅ Severity 4 → Severity 2
- ✅ Q2 2021 → Year 2021 (toàn năm)
- ✅ Named Set: `Top_City_Severity4_Q2_2021` → `Top_City_Severity2_Year2021`
- ✅ Cú pháp Year: `[ID START DATE].[YEAR].&[2021]` (có dấu `&`)
