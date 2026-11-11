# Ghi chú paper và triển khai — Chương 5

Các file PDF được đọc trong workspace: rfp0697-chenAemb.pdf; j_aci_2019_12_003.pdf; electronics-15-01308-v2.pdf; NeurIPS-2021-revisiting-deep-learning-models-for-tabular-data-Paper.pdf; ICLR-2025-tabm-advancing-tabular-deep-learning-with-parameter-efficient-ensembling-Paper-Conference.pdf. Không tìm thấy đồ án mẫu trong workspace nên notebook dùng bố cục trong AGENTS.md.

Notebook chuyên sâu theo từng phương pháp: `notebooks/Chapter5_XGBoost_Kaggle.ipynb`, `notebooks/Chapter5_WCFR_XGBoost_Kaggle.ipynb`, `notebooks/Chapter5_FT_Transformer_Kaggle.ipynb`, `notebooks/Chapter5_TabM_Kaggle.ipynb`. Notebook tổng hợp `notebooks/Chapter5_US_Accidents_4Models_Kaggle.ipynb` vẫn dùng để chạy và so sánh các nhánh trong một lần chạy. Các notebook riêng dùng cùng seed, feature protocol và split; kiến trúc và hyperparameter model giữ như nhánh tương ứng trong notebook tổng hợp.

Bốn notebook riêng hiện đặt `MODE="FULL"` mặc định theo yêu cầu chạy toàn bộ CSV. XGBoost in validation mlogloss mỗi 25 vòng và lưu learning curve; FT-Transformer/TabM in loss theo batch mỗi 100 bước (thêm batch đầu/cuối) và theo epoch. Đây là thay đổi chế độ chạy và quan sát tiến độ; không thay đổi định nghĩa thuật toán. Chạy từng notebook riêng, ưu tiên GPU cho hai mạng neural.

## Bảng ánh xạ phương pháp

| Phương pháp | Paper/nguồn | Vị trí/công thức | Cách dùng trong notebook |
|---|---|---|---|
| XGBoost | Chen & Guestrin, “XGBoost: A Scalable Tree Boosting System” (2016), https://doi.org/10.1145/2939672.2939785 | Mục 2.1–2.3: objective chính quy hóa, xấp xỉ Taylor bậc hai, gradient/Hessian, cấu trúc cây và shrinkage | XGBClassifier đa lớp softprob; class weights tính trên train; mlogloss trên validation cho early stopping; softmax probabilities 4 lớp. Notebook riêng chạy FULL, tối đa 250 cây, in validation log mỗi 25 cây. Đây là cấu hình khởi điểm, không tái lập benchmark paper. |
| WCFR gốc → XGBoost | Zhou, Wang & Zhang, “Feature selection based on weighted conditional mutual information”, https://doi.org/10.1016/j.aci.2019.12.003 | Mục 3.1, Eqs. (11)–(17), bản PDF trang tạp chí 57–59; score WCFR Eq. (13), pseudo-code Table 1 | WCFR là filter chọn feature. Triển khai score Eq. (13), sau đó XGBoost được cấu hình giống nhánh đầy đủ feature. Cài đặt MI rời rạc và khởi tạo được mô tả bên dưới. |
| WCFR trong bài ứng dụng | “Explainable Machine Learning for Accident Severity Prediction…”, Electronics 15 (2026), 1308, https://doi.org/10.3390/electronics15061308 | Mục 2.2.6, Eqs. (10)–(12), PDF trang 7–8/20; Top-10 và phân tích Top-5/10/15 trong phần kết quả | Dùng làm đối chiếu bối cảnh U.S. Accidents và tham khảo lựa chọn Top-10 cố định cho lần chạy. Không dùng score Eqs. (10)–(11) của bài này trong implementation WCFR gốc. Các con số trong paper không phải kết quả trên CSV của nhóm. |
| FT-Transformer | Gorishniy et al., “Revisiting Deep Learning Models for Tabular Data” (NeurIPS 2021), https://arxiv.org/abs/2106.11959 | Mục 3.3 và Figure 1: feature tokenizer, CLS, Transformer blocks, prediction head | Dùng FTTransformer từ package chính thức được repo Yandex Research khuyến nghị: https://github.com/yandex-research/rtdl-revisiting-models. Numerical/categorical đi riêng; đầu ra logits B×4, CrossEntropyLoss nhận logits. |
| TabM | Gorishniy et al., “TabM: Advancing Tabular Deep Learning With Parameter-Efficient Ensembling” (ICLR 2025), https://arxiv.org/abs/2410.24210 | Mục 3.2–3.3 và phần loss/inference: ensemble thành viên song song, chia sẻ trọng số, member-wise objective | Dùng package TabM chính thức https://github.com/yandex-research/tabm, variant TabM chuẩn (không phải TabM-mini/TabM†), k=8. Train mean các loss từng member; inference mean các xác suất từng member. |

## WCFR: phiên bản paper và lựa chọn triển khai

### WCFR gốc, Zhou et al.

Paper gốc đặt relevance của feature f so với class Y theo các conditional mutual information theo từng feature s trong tập đã chọn S; redundancy dùng I(f;s) − I(f;s|Y). Score Eq. (13) có dạng:

J(f;S) = (1 − δ1) Σ[s∈S] I(f;Y|s) − (1 − δ2) Σ[s∈S] ( I(f;s) − I(f;s|Y) )

δ1 là độ lệch chuẩn tổng thể của dãy relevance; δ2 là độ lệch chuẩn tổng thể của dãy redundancy. Pseudo-code Table 1 có bước khởi tạo tập chọn; notebook khởi tạo bằng argmax I(f;Y), một lựa chọn của nhóm được ghi rõ vì CSV dị thể cần cách biểu diễn rời rạc cụ thể.

Triển khai nhóm dùng plug-in empirical entropy trên natural logarithm (đơn vị nat): MI/CMI tính từ bảng tần suất rời rạc; xác suất bằng 0 không đóng góp vào entropy; giá trị âm rất nhỏ do sai số số học được clip về 0. Numerical features được chia thành tối đa 5 quantile bins từ mẫu train WCFR; duplicate quantile edges được gộp. Categorical values hiếm được gom về mã 0; category map chỉ fit trên mẫu train. Feature hằng trên mẫu selector bị bỏ. Chọn greedy forward Top-10 cố định cho lần chạy. Mẫu selector tối đa 10.000 dòng, phân tầng và seed cố định, chỉ lấy từ train; classifier phía sau được fit trên toàn bộ train split. Số hàng thực tế được ghi trong output. Đây là implementation minh bạch của score gốc, không tuyên bố tái tạo chính xác một estimator cụ thể mà paper không quy định cho CSV này.

### Khác biệt với Electronics 2026

Bài Electronics 2026 viết score J(f;S) = α_f I(f;Y|S) − (1−α_f) average_s I(f;s), với α_f = 1 / (1 + sd(f)/median_j sd(f_j)). Cách viết này conditioning trên cả S và dùng trọng số dispersion của từng feature; WCFR gốc Eq. (13) dùng standard deviation của các số hạng relevance/redundancy theo từng s. Hai công thức không được xem là tương đương đại số. Notebook chọn WCFR gốc vì đó là định nghĩa method gốc, và công khai dùng bài 2026 làm ứng dụng tham khảo/Top-k chứ không trộn công thức.

## API, dependency và môi trường

- XGBoost: https://xgboost.readthedocs.io/en/stable/python/python_api.html. Notebook xử lý API device theo major/minor version: XGBoost từ 2.x dùng tree_method=hist và device=cuda; bản cũ dùng gpu_hist. Early stopping được đặt ở constructor từ 1.6; bản cũ truyền khi fit. Với SciPy sparse input nằm trên CPU, version 2.x+ chuyển predictor sang CPU sau khi fit để inference không phát cảnh báo lệch device. Thiết bị train/inference và version được lưu riêng.
- FT-Transformer: dùng rtdl_revisiting_models từ README chính thức; package được repo công bố là implementation được khuyến nghị. Runtime ghi version thực cài, cùng torch và scikit-learn.
- TabM: dùng tabm từ README chính thức; gọi TabM.make và kiểm tra shape B×k×4 trước training. Runtime ghi version thực cài.
- Phiên bản đã smoke test trên local: xgboost 3.4.1, rtdl_revisiting_models 0.0.2, tabm 0.0.3, torch 2.11.0+cu128, pandas 3.0.5, NumPy 2.5.2, scikit-learn 1.9.0, Python 3.12.10. Notebook chỉ cài package thiếu, với version cài đặt được ghim ở ba package model đã smoke test; nếu package đã có sẵn thì notebook ghi và dùng version hiện tại. Không nâng cấp hàng loạt. Cần Internet trên Kaggle chỉ khi package cần thiết chưa có.
- Chưa kiểm tra notebook trong Kaggle và chưa đo runtime GPU. Smoke tests thực hiện trước bàn giao được liệt kê trong phản hồi cuối.

## Thông tin dữ liệu và giới hạn

CSV khảo sát local: 500.000 dòng × 46 cột; Severity: 1=4.274, 2=398.142, 3=84.520, 4=13.064; duplicate toàn dòng 0; ID duy nhất 500.000; Start_Time từ 2016-01-14 đến 2023-03-31. Các thống kê này cần được notebook tính lại từ file người dùng upload.

Target là Severity mức ảnh hưởng giao thông, không phải số người chết/bị thương. Cột End_*, Description, Distance(mi), ID và các proxy/định danh bị loại khỏi X. Weather_Timestamp chỉ dùng để kiểm tra tuổi quan sát, không dùng như feature. Do CSV không có event ID, chia nhóm dùng gần đúng Start_Time + tọa độ bắt đầu làm tròn 5 chữ số. Local khảo sát thấy 2.159 chữ ký lặp, tối đa 5 dòng/nhóm; 177 nhóm có hơn một nhãn Severity. Quy tắc nhóm tránh giao cắt split nhưng có thể gộp các sự cố trùng thời gian/vị trí.

Không tìm thấy SQL export hay bằng chứng CSV được trích từ DW; không đưa ra nhận định nguồn gốc DW. Smoke test local trước đó dùng 12.000 dòng và ngân sách rút gọn để xác nhận train/predict; chưa train FULL trên 500.000 dòng, chưa làm temporal holdout/tái lập benchmark/tuning dài và chưa chạy Kaggle.
