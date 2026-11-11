# Hướng dẫn chạy notebook Chương 5 trên Kaggle

Hướng dẫn setup môi trường, xử lý lỗi không thấy CSV, chọn accelerator và bố cục báo cáo: [SETUP_CHAPTER5.md](SETUP_CHAPTER5.md).

## Các notebook

Mỗi thuật toán có notebook độc lập để đọc phương pháp, cấu hình, huấn luyện và phân tích riêng:

| Notebook | Phương pháp | Nội dung chính |
|---|---|---|
| `notebooks/Chapter5_XGBoost_Kaggle.ipynb` | XGBoost | Gradient/Hessian, regularization cây, đa lớp, early stopping |
| `notebooks/Chapter5_WCFR_XGBoost_Kaggle.ipynb` | WCFR–XGBoost | MI/CMI, score WCFR gốc Eq. (13), chọn Top-k rồi phân loại |
| `notebooks/Chapter5_FT_Transformer_Kaggle.ipynb` | FT-Transformer | Token theo cột, CLS, self-attention và CrossEntropy từ logits |
| `notebooks/Chapter5_TabM_Kaggle.ipynb` | TabM | MLP song song, loss theo từng member, trung bình xác suất khi inference |

Notebook tổng hợp `notebooks/Chapter5_US_Accidents_4Models_Kaggle.ipynb` vẫn được giữ để chạy các nhánh trên cùng một lần chạy và xem bảng so sánh trực tiếp. Bốn notebook riêng chạy đúng một pipeline mỗi lần.

## 1. Upload và thêm dữ liệu

1. Mở Kaggle Notebooks, tạo notebook mới rồi upload notebook muốn chạy.
2. Chọn **Add Input**, tìm dataset “Accidents in US” của dybuao và thêm `Accidents_500.csv`.
3. Notebook tự tìm đúng tên file trong `/kaggle/input`. Nếu có nhiều file cùng tên, đặt `DATA_PATH` trong CONFIG theo đường dẫn chính xác được in ra.
4. Không cần chép CSV vào `/kaggle/working`.

Dataset tham chiếu: https://www.kaggle.com/datasets/dybuao/accidents-in-us?select=Accidents_500.csv

## 2. Cấu hình và ngân sách

Ở cell CONFIG gần đầu notebook:

- `MODE="FULL"` là mặc định trong cả bốn notebook, dùng toàn bộ dòng sau khi loại duplicate chính xác (CSV hiện tại có khoảng 500.000 dòng). `MODE="DEMO"` lấy mẫu phân tầng tối đa 30.000 dòng với seed 217 để kiểm tra nhanh.
- `DATA_PATH=None` bật tìm file tự động; gán đường dẫn nếu cần chỉ định thủ công.
- Có thể giảm `DEMO_N` để smoke test, nhưng split vẫn yêu cầu đủ số dòng từng lớp.
- XGBoost: `XGB_TREES`, `XGB_EARLY_STOPPING_ROUNDS`, `XGB_VERBOSE_EVAL` (mặc định in validation log mỗi 25 vòng).
- WCFR–XGBoost: `WCFR_TOP_K`, `WCFR_MAX_TRAIN_ROWS`, `WCFR_NUMERIC_BINS`, `WCFR_MAX_CATEGORIES`.
- FT-Transformer và TabM: `NEURAL_EPOCHS`, `NEURAL_PATIENCE`, `BATCH_SIZE`, `LEARNING_RATE`, `WEIGHT_DECAY`; TabM còn có `TABM_K`. Tiến độ in loss theo batch mỗi `TRAIN_LOG_EVERY_STEPS` bước, cùng loss và validation Macro-F1 từng epoch.

Chạy cell theo thứ tự từ đầu và chạy từng notebook riêng. Mỗi notebook chỉ huấn luyện phương pháp được ghi trong tên và CONFIG. Các cấu hình dùng chung—seed, feature và split—được giữ giống nhau để thuận tiện đối chiếu; output mỗi lần chạy nằm trong thư mục riêng. XGBoost dừng sớm theo validation; neural models dừng theo validation Macro-F1 và patience nên số vòng thực tế có thể thấp hơn mức tối đa.

## 3. Accelerator, Internet và dependency

- Chọn GPU trong Notebook settings cho FT-Transformer/TabM với FULL. CPU vẫn chạy được nhưng có thể chậm đáng kể. Kaggle hiện cung cấp cấu hình T4x2; các model neural trong notebook dùng GPU đầu tiên, không chia model qua hai GPU.
- XGBoost tự chọn CUDA nếu build/runtime hỗ trợ, nếu không sẽ train CPU và in log mỗi 25 cây. Thiết bị thực tế được ghi trong `environment.json`.
- Theo tài liệu Kaggle đang công bố, mỗi phiên notebook CPU/GPU có giới hạn tối đa 12 giờ; GPU quota thường tối đa 30 giờ/tuần nhưng Kaggle ghi quota có thể cao hơn tùy tài nguyên. Hãy xem quota đang có trong Notebook settings trước khi chạy bốn notebook; thời lượng thực tế phụ thuộc accelerator và tải hệ thống. Thông tin: [Notebook sessions](https://www.kaggle.com/docs/notebooks), [GPU usage](https://www.kaggle.com/docs/efficient-gpu-usage).
- Bật Internet nếu package chính thức của mô hình được chọn chưa có trong runtime. Notebook chỉ cài package thiếu: `xgboost==3.4.1`, `rtdl_revisiting_models==0.0.2` hoặc `tabm==0.0.3` tùy nhánh; không nâng cấp hàng loạt thư viện.
- Phiên bản thực tế, Python, scikit-learn, phần cứng, GPU và thiết bị train/inference được lưu trong `environment.json`. Kaggle chưa được xác nhận chỉ từ kết quả chạy local.

## 4. Dữ liệu, feature và split

Severity 1–4 biểu thị mức ảnh hưởng tới giao thông. Notebook mã hóa nhãn thành 0–3 trong code và đổi lại nhãn gốc trong báo cáo. Feature chốt tại thời điểm bắt đầu tai nạn; loại ID khỏi X, Severity, các cột End_*, Description, Distance(mi), cùng các proxy/định danh đã ghi trong notebook. Weather chỉ dùng khi timestamp không sau Start_Time và tuổi quan sát tối đa 120 phút.

Split nhóm phân tầng xấp xỉ 64/16/20 theo chữ ký Start_Time và tọa độ bắt đầu làm tròn 5 chữ số, vì CSV không có event ID riêng. Mỗi notebook lưu `split_ids.csv`, seed và checksum. Đây là split ngẫu nhiên có nhóm gần đúng, không phải temporal holdout. Nếu lớp hiếm dưới ngưỡng split, dùng FULL hoặc tăng `DEMO_N`; notebook không tự bỏ lớp.

Median, scaler, category vocabulary, one-hot encoder, class weights và WCFR discretization chỉ fit trên train. XGBoost dùng sparse one-hot; neural networks dùng numerical values đã scale cộng missing indicators và categorical integer codes. Các kiến trúc có biểu diễn riêng nhưng dùng cùng feature hợp lệ.

## 5. Output và tải về

Mỗi lần chạy tạo thư mục mới:

- Kaggle: `/kaggle/working/outputs/<run_id>/`
- Local: `outputs/<run_id>/`

Output gồm config/checksum, versions/phần cứng, split IDs, mapping nhãn, metric tổng hợp và theo lớp, trạng thái, dự đoán/xác suất test, confusion matrix. XGBoost lưu `xgboost_validation_curve.csv`; neural notebooks lưu loss/metric theo epoch và các mốc loss theo batch trong `training_progress_<model>.csv`. WCFR notebook có thứ tự feature, score, cấu hình selector và thời gian chọn. Cell cuối tạo ZIP có tên `Chapter5_<model>_<run_id>.zip`. Trên Kaggle, tải ZIP từ Output/Files sau khi chạy.

Macro-F1 là metric chính; Accuracy, Weighted-F1, Balanced Accuracy, QWK và metric từng lớp được báo thêm. QWK xem nhãn có thứ tự, nhưng không đo số người bị thương/tử vong. Chỉ mô hình thành công mới có metric; xem `model_status.csv` nếu có lỗi. Kết quả FULL vẫn chỉ mô tả CSV/split và ngân sách đã chạy, không phải kết luận tổng quát.

## 6. Cách đọc từng notebook

- XGBoost: validation `mlogloss` quyết định early stopping; Macro-F1 test dùng báo cáo cuối.
- WCFR–XGBoost: selector fit trên tối đa 10.000 dòng train có seed, sau đó XGBoost học trên toàn bộ train split; K=10 cố định. Notebook tổng hợp dùng khi cần so trực tiếp với XGBoost đầy đủ trên cùng run.
- FT-Transformer: kiểm tra logits `B × 4`; CrossEntropy nhận logits thô.
- TabM: kiểm tra logits `B × K × 4`; training trung bình loss từng member, inference trung bình softmax probabilities.

Paper benchmarks không phải kết quả của CSV nhóm. Ghi chú nguồn, công thức và quyết định triển khai nằm trong `PAPER_IMPLEMENTATION_NOTES.md`.

## 7. Lỗi thường gặp và giới hạn

- Không tìm thấy CSV: kiểm tra Add Input hoặc chỉ định `DATA_PATH`.
- Nhiều CSV cùng tên: chọn một file bằng `DATA_PATH`.
- Thiếu package/không có Internet: cài dependency đã nêu hoặc chạy nhánh có sẵn package; trạng thái lỗi được ghi vào output.
- GPU unavailable/OOM: xem log; có thể giảm `BATCH_SIZE` hoặc ngân sách và ghi lại thay đổi. Notebook không tự đổi kiến trúc.
- Lớp hiếm không đủ trong DEMO/split nhóm: tăng `DEMO_N` hoặc chọn FULL; không xóa lớp.
- Chữ ký event gần đúng có thể gộp tai nạn trùng thời điểm/vị trí; weather cutoff 120 phút là giả định cần trình bày trong báo cáo.
- Local smoke test không xác nhận runtime, GPU hoặc quota Kaggle.
