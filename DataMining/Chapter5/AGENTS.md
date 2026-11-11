# AGENTS.md — IS217 / U.S. Accidents / Chương 5

## 1. Phạm vi và cách làm việc

File này hướng dẫn coding agent làm việc trong thư mục project và các thư mục con. Đặt tại thư mục gốc, dự kiến `D:\OLAP\paper_Chapter5\AGENTS.md`. Đây là quy ước project, không thay thế yêu cầu hiện tại của người dùng hoặc hướng dẫn có mức ưu tiên cao hơn.

- Giao tiếp, Markdown notebook và hướng dẫn sử dụng bằng tiếng Việt; tên biến/hàm Python bằng tiếng Anh rõ nghĩa.
- Mục tiêu: so sánh XGBoost, WCFR–XGBoost, FT-Transformer và TabM trong phân loại Severity 1–4.
- Severity là mức ảnh hưởng tới giao thông; không diễn giải thành số người chết/bị thương.
- Ưu tiên demo đúng phương pháp, dễ hiểu và tái lập trước khi tuning lớn.
- Không mặc định phương pháp mới hơn sẽ tốt hơn. Không tự mở rộng sang thuật toán thứ năm, time-series forecasting, web app hoặc deployment.
- Khi được yêu cầu triển khai: kiểm tra hiện trạng, nêu kế hoạch ngắn, tạo/sửa file, kiểm tra rồi bàn giao; không chỉ đưa pseudo-code.
- Khi được yêu cầu giải thích hoặc review: đọc và trả lời; không tự sửa file hay chạy huấn luyện ngoài phạm vi yêu cầu.
- Tự quyết định các chi tiết kỹ thuật thông thường; chỉ hỏi khi thông tin thiếu thực sự ảnh hưởng bài toán hoặc có mâu thuẫn nguồn không thể giải quyết.

## 2. Khảo sát workspace trước khi sửa

1. Liệt kê file thực tế, đọc các hướng dẫn project hiện có và kiểm tra thay đổi chưa commit nếu là git repository.
2. Không suy ra tên đầy đủ từ tên bị rút gọn trong ảnh. Không coi file chưa thấy là đã tồn tại.
3. Kiểm tra CSV: số dòng/cột, kiểu dữ liệu, missing, duplicate, khoảng thời gian và phân bố nhãn. Không đoán kích thước từ tên file.
4. Đọc PDF liên quan trước khi triển khai thuật toán. Nếu có đồ án mẫu, tham khảo Chương 5; nếu không, dùng bố cục tại mục 5 và nói rõ.
5. Giữ nguyên dữ liệu nguồn, PDF, ghi chú và code không liên quan. Không xóa hoặc ghi đè thay đổi người dùng để làm sạch workspace.

## 3. Nguồn học thuật và tính trung thực

Các file dự kiến, cần xác nhận tên thực tế:

- `Accidents_500.csv`.
- `rfp0697-chenAemb.pdf`: XGBoost.
- `electronics-15-01308-v2.pdf`: WCFR trên U.S. Accidents.
- `j_aci_2019_12_003.pdf`: WCFR gốc.
- PDF NeurIPS 2021 về Revisiting Deep Learning Models for Tabular Data.
- PDF ICLR 2025 về TabM.

Nguồn đối chiếu:

| Phương pháp | Paper | Code chính thức |
|---|---|---|
| XGBoost | https://doi.org/10.1145/2939672.2939785 | https://github.com/dmlc/xgboost |
| WCFR gốc | https://doi.org/10.1016/j.aci.2019.12.003 | Chưa xác minh; không tự nhận repository bất kỳ là chính thức |
| WCFR ứng dụng | https://doi.org/10.3390/electronics15061308 | Kiểm tra trong paper |
| FT-Transformer | https://arxiv.org/abs/2106.11959 | https://github.com/yandex-research/rtdl-revisiting-models |
| TabM | https://arxiv.org/abs/2410.24210 | https://github.com/yandex-research/tabm |

- Ghi paper, phiên bản, mục/trang/công thức dùng để triển khai trong `PAPER_IMPLEMENTATION_NOTES.md`.
- Phân biệt: nội dung theo paper / lựa chọn của nhóm / điểm chưa xác minh.
- Không giả lập trích dẫn, công thức, kết quả, code tác giả hoặc trạng thái đã kiểm thử.
- Năm 2026 là paper ứng dụng WCFR; không gọi WCFR là thuật toán mới ra đời năm 2026.
- Kết quả benchmark paper không phải kết quả trên file CSV của nhóm.
- Khi cần API/dependency, đọc tài liệu hoặc source của phiên bản dùng. Ghi phiên bản/commit; không đoán chữ ký hàm.
- Nếu cần lấy code bên ngoài, giữ thông tin nguồn và giấy phép phù hợp.

## 4. Cấu trúc đầu ra

```text
paper_Chapter5/
  AGENTS.md
  Accidents_500.csv
  <paper PDFs>
  notebooks/
    Chapter5_US_Accidents_4Models_Kaggle.ipynb
    Chapter5_XGBoost_Kaggle.ipynb
    Chapter5_WCFR_XGBoost_Kaggle.ipynb
    Chapter5_FT_Transformer_Kaggle.ipynb
    Chapter5_TabM_Kaggle.ipynb
  README_KAGGLE.md
  PAPER_IMPLEMENTATION_NOTES.md
  outputs/
    <run_id>/
```

- Notebook chính ưu tiên tự chứa code và chạy độc lập khi upload lên Kaggle.
- Chỉ tách module nếu thực sự hữu ích; khi đó phải hướng dẫn đưa module lên Kaggle và kiểm tra import.
- README ghi setup, đường dẫn input, accelerator, Internet nếu cần, chạy DEMO/FULL, chạy riêng mô hình và tải kết quả.
- Tránh xây framework nặng hoặc quá nhiều file cho đồ án sinh viên.
- Không commit dữ liệu lớn, credentials hoặc checkpoint lớn nếu chưa có yêu cầu.

## 5. Chuẩn trình bày notebook

1. Giới thiệu bài toán và bốn phương pháp.
2. Mô tả và khảo sát dữ liệu.
3. Chọn feature, chống leakage và chia dữ liệu.
4. Tiền xử lý, cấu hình thực nghiệm và metrics.
5. XGBoost.
6. WCFR–XGBoost.
7. FT-Transformer.
8. TabM.
9. So sánh, biểu đồ và hướng dẫn nhận xét.
10. Lưu kết quả, hạn chế và bước tiếp theo.

Trước mỗi code cell quan trọng, viết Markdown giải thích mục đích, lý do, input/output, tham số chính và điều cần quan sát. Không chỉ dịch tên hàm hoặc comment từng dòng.

Mỗi phương pháp cần có: description paper + link → cơ chế → công thức/ký hiệu → cấu hình → train → predict → evaluate → hướng dẫn diễn giải. Phân biệt training với inference, loss với metric. Các nhận xét tự động chỉ dựa trên kết quả đã có, không viết sẵn mô hình thắng.

## 6. Cấu hình và dữ liệu

- Có CONFIG đầu notebook: mode, seed, DATA_PATH, output directory, mô hình cần chạy, sample size, batch size, epochs/trees và giới hạn tài nguyên.
- Notebook tổng hợp mặc định DEMO: lấy mẫu phân tầng có seed và kiểm tra đủ mẫu từng lớp; in kích thước thực tế. Theo yêu cầu người dùng ngày 2026-09-30, bốn notebook chuyên sâu theo model đặt MODE=FULL mặc định để dùng toàn bộ dữ liệu; có thể đổi về DEMO để chạy nhanh. Không tự bật FULL cho notebook/artifact khác.
- Tìm đúng `Accidents_500.csv` dưới `/kaggle/input`; hỗ trợ DATA_PATH thủ công và đường chạy local. Nếu có nhiều file khớp, yêu cầu chỉ định.
- Dataset tham chiếu: https://www.kaggle.com/datasets/dybuao/accidents-in-us?select=Accidents_500.csv
- Không hardcode đường dẫn Windows vào luồng Kaggle. Ghi kết quả vào `/kaggle/working` trên Kaggle và `outputs/<run_id>` ở local.
- Mapping nhãn dự kiến: 1–4 thành 0–3 trong code; lưu mapping và dùng nhãn gốc trong biểu đồ.
- Kiểm tra giá trị nhãn thực tế; không âm thầm bỏ/gộp lớp không mong đợi.

## 7. Chống leakage và so sánh công bằng

- Chốt thời điểm dự đoán; chỉ dùng thông tin có sẵn ở thời điểm đó.
- Lập bảng giữ/bỏ feature và lý do; kiểm tra ID, surrogate keys, End_Time, duration, End_Lat/End_Lng, Description, Distance(mi), thời tiết tương lai và mọi dẫn xuất từ Severity.
- Không giữ feature hậu nghiệm chỉ vì tăng Accuracy. Không đưa nhãn hoặc bản sao nhãn vào X.
- Loại trùng hợp lý trước split. Nếu nhiều bản ghi cùng sự kiện, tránh chia cùng sự kiện qua các tập.
- Dùng cùng bản ghi train/validation/test cho cả bốn phương pháp; mặc định đề xuất 64/16/20 phân tầng nếu phù hợp dữ liệu.
- Lưu split IDs, seed và checksum dữ liệu. Temporal holdout là phân tích riêng nếu mục tiêu là triển khai tương lai.
- Fit imputer, scaler, encoder, vocabulary, discretization, class weights và WCFR chỉ trên train.
- Validation chọn hyperparameter, Top-k và early stopping; không dùng test cho lựa chọn này.
- Khi dùng cross-validation, fit lại mọi bước học từ dữ liệu trong từng training fold.
- Cho phép encoding riêng theo kiến trúc nhưng giữ cùng thông tin đầu vào hợp lệ; WCFR là nhánh thí nghiệm chọn subset.
- Xử lý category chưa gặp và feature hằng. Tránh ép categorical thành thứ tự số không có ý nghĩa.
- Demo chưa cần SMOTE. Nếu dùng class weights, tính từ train và áp dụng theo giao thức thống nhất; ghi rõ loss và reduction.
- Tuning lớn chỉ khi được yêu cầu, với ngân sách có thể so sánh. Báo số trial và thời gian thực tế.
- Nếu lấy dữ liệu từ DW, giữ grain một tai nạn/một dòng, kiểm tra join không nhân dòng, lưu SQL export. Không tự nhận CSV đã được xuất từ DW.

## 8. Yêu cầu đúng phương pháp

### 8.1 XGBoost

- Dùng classifier đa lớp, xuất xác suất bốn lớp; giải thích boosting, gradient/Hessian và regularization.
- Kiểm tra API objective, early stopping và CPU/GPU theo phiên bản dùng.
- Không dùng `scale_pos_weight` như giải pháp mặc định cho đa lớp; nếu cần, dùng trọng số mẫu phù hợp.

### 8.2 WCFR–XGBoost

- WCFR là feature selection, XGBoost là classifier.
- Đối chiếu paper gốc với bản ứng dụng; ghi chính xác phiên bản công thức triển khai và mọi khác biệt.
- Không thay WCFR bằng Pearson, SelectKBest, MI đơn biến hoặc XGBoost importance rồi giữ tên WCFR.
- Giải thích MI/CMI estimator, discretization, trọng số, khởi tạo tập rỗng, tiêu chí dừng và Top-k.
- Xử lý feature hằng, xác suất bằng 0 và số mẫu nhỏ; có kiểm tra phù hợp cho phần tự cài.
- Nếu cần lấy mẫu để tính WCFR, lấy trong train, lưu seed và công bố giới hạn.
- Fit bộ chọn trên train; chọn k bằng validation hoặc ghi rõ k cố định cho demo.
- Demo so với XGBoost full-feature bằng cấu hình classifier giống nhau để quan sát tác động chọn feature.
- Báo danh sách và thứ tự feature, số feature, thời gian chọn feature riêng.
- Nếu không đủ nguồn để triển khai trung thực: báo blocked với lý do cụ thể, hoàn thành các nhánh khác; không bịa phương pháp thay thế.

### 8.3 FT-Transformer

- Ưu tiên implementation chính thức/có nguồn rõ ràng; có feature tokenizer, Transformer blocks, CLS và prediction head.
- Không gọi Transformer chung thiếu cấu trúc tương ứng là FT-Transformer.
- Giải thích tensor shapes, numerical/categorical tokenizer và attention giữa feature tokens.
- Head trả logits bốn lớp. CrossEntropyLoss nhận logits, tránh softmax hai lần.
- Không tạo sliding windows chỉ vì có timestamp.

### 8.4 TabM

- Dùng implementation đúng nguồn; ghi variant, package version/commit và cấu hình.
- Không thay TabM bằng MLP thường hoặc ensemble tùy ý.
- Giải thích shared weights và tham số riêng; kiểm tra logits có dạng B × k × 4.
- Training: loss riêng từng nhánh rồi trung bình loss. Inference classification: softmax từng nhánh rồi trung bình xác suất.
- Không thay training objective bằng loss trên dự đoán đã trung bình.
- Weighted loss phải được áp dụng theo từng nhánh với reduction được ghi rõ.

## 9. Đánh giá và lưu kết quả

- Metric chính: Macro-F1.
- Bổ sung: Accuracy, Weighted-F1, Balanced Accuracy, Precision/Recall/F1/support từng lớp và confusion matrix thứ tự cố định 1–4.
- QWK là metric bổ sung cho thứ tự nhãn; giải thích giả định trọng số, không gọi nó là thước đo thương vong.
- Dùng hàm đánh giá chung trên cùng test; chỉ đánh giá sau khi chốt cấu hình theo validation.
- Lưu thời gian preprocessing, feature selection, training và inference; ghi hardware, batch size và số mẫu.
- Nếu đo GPU latency, đồng bộ phù hợp và ghi quy trình đo; không so sánh thời gian khác phần cứng như kết luận tuyệt đối.
- Lưu config, môi trường/versions, split IDs, mapping, metrics CSV, prediction CSV và figures.
- Kết quả demo phải có nhãn DEMO. Mô hình lỗi/chưa chạy ghi trạng thái, không điền điểm 0 để xếp hạng.
- Không tạo số liệu giả hoặc dùng kết quả paper thay cho kết quả nhóm.
- Chỉ kết luận trong phạm vi dữ liệu, split và ngân sách đang dùng; không suy ra mô hình luôn tốt nhất.

## 10. Kaggle, môi trường và chi phí

- Kiểm tra dependency trước khi cài; cài tối thiểu, tránh nâng cấp hàng loạt thư viện có sẵn.
- Ghi phiên bản đã thực sự kiểm tra; không tự tạo version pin chưa xác minh.
- Hiển thị Python/library versions và tình trạng GPU; hỗ trợ CPU cho smoke test nhỏ khi khả thi.
- Code không phụ thuộc trạng thái cell chạy ngoài thứ tự. Có thể chạy lại mà không âm thầm cộng dồn kết quả cũ.
- Giải phóng model và GPU memory giữa các mô hình khi không còn dùng.
- Khi OOM, báo rõ; chỉ giảm batch size/cấu hình nếu ghi lại thay đổi. Không tự đổi kiến trúc.
- Không tự chạy FULL, tuning dài hoặc tải dữ liệu lớn khi người dùng mới yêu cầu tạo notebook/demo.
- Không tự đăng notebook công khai, upload dữ liệu lên dịch vụ khác, gửi thông tin hoặc sử dụng dịch vụ trả phí.

## 11. Kiểm tra trước khi bàn giao

- Validate notebook bằng nbformat và kiểm tra cú pháp cell code.
- Smoke test preprocessing và train/forward/predict trên tập nhỏ khi môi trường cho phép.
- Kiểm tra feature không chứa target, split không trùng định danh theo grain đã chốt, mapping nhãn đúng.
- Kiểm tra shape, logits/xác suất hữu hạn, xác suất tổng xấp xỉ 1 và số output đúng.
- Kiểm tra WCFR chỉ trả feature hợp lệ, không lặp, không dùng validation/test để fit.
- Kiểm tra TabM có đúng training loss và inference aggregation.
- Kiểm tra metrics/plot dùng nhãn cố định và không nhầm score train với test.
- Kiểm tra file output được ghi đúng đường dẫn và có thể truy xuất.
- Nếu thiếu tài nguyên hoặc dependency: ghi chính xác kiểm tra nào chưa làm. Local smoke test không đồng nghĩa đã chạy thành công trên Kaggle.
- Dừng kiểm tra khi đủ giải quyết rủi ro thực tế; không thêm test chỉ lặp lại implementation hoặc chạy benchmark tốn kém không cần thiết.

## 12. Bàn giao mỗi lần thay đổi

Thông báo ngắn gọn:

1. File đã tạo/sửa và lý do.
2. Phần đã kiểm tra, môi trường kiểm tra và phần chưa kiểm tra.
3. Khác biệt so với paper hoặc cấu hình trước.
4. Lỗi/giới hạn còn lại nếu có.
5. Bước tiếp theo cụ thể cho người dùng trên Kaggle.

Định nghĩa hoàn thành bản demo: bốn phương pháp có implementation đúng nguồn và notebook có thể chạy từ trên xuống trong môi trường đã nêu; mọi phần chưa chạy hoặc blocked được ghi rõ. Không gọi cả bốn đã hoàn tất nếu một nhánh mới là placeholder.
