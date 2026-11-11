# Hướng dẫn viết báo cáo Chương 5 — Khai phá dữ liệu

> Tài liệu hướng dẫn biên soạn Chương 5 cho đồ án **Phân tích dữ liệu về các vụ tai nạn giao thông tại Mỹ (US)**, dùng cùng bộ dữ liệu U.S. Accidents và bốn phương pháp XGBoost, WCFR–XGBoost, FT-Transformer, TabM. Nội dung hiện tại là khung viết và quy tắc lấy kết quả; hãy điền số liệu từ lần chạy Kaggle thực tế của nhóm, không dùng số minh họa hay kết quả trong paper làm kết quả thực nghiệm của nhóm.

## 1. Cách dùng hướng dẫn này

Báo cáo nhóm hiện có các chương về tổng quan dữ liệu, tích hợp dữ liệu bằng SSIS, phân tích kho bằng SSAS và lập báo biểu bằng Power BI/Looker. Chèn Chương 5 sau Chương 4, giữ nguyên tên đồ án và quy cách đánh số/định dạng heading đang dùng trong Google Doc. Có thể dùng tiêu đề:

**CHƯƠNG 5: KHAI PHÁ DỮ LIỆU VÀ PHÂN LOẠI MỨC ĐỘ NGHIÊM TRỌNG TAI NẠN**

PDF đồ án mẫu được dùng để tham khảo cách trình bày tuần tự: mô tả dữ liệu → tiền xử lý → chia tập → thuật toán → kết quả → so sánh. Không sao chép dữ liệu, mô hình, số liệu hay kết luận của đề tài mẫu. Chương này phải mô tả pipeline hiện có trong các notebook của nhóm, không giả định CSV đã được xuất từ Data Warehouse nếu nhóm chưa có bằng chứng/SQL export cho luồng đó.

### Phạm vi thực nghiệm

- Dataset đưa vào notebook là `Accidents_500.csv` từ bộ Kaggle *Accidents in US*. Chế độ `FULL` dùng toàn bộ các dòng trong **file 500.000 dòng này** sau bước loại bản ghi trùng chính xác; không được gọi đây là toàn bộ mọi tai nạn trong dữ liệu U.S. Accidents gốc.
- Nhãn đích là `Severity` gồm các mức 1–4, biểu thị **mức ảnh hưởng tới giao thông**. Không diễn giải thành số người chết hoặc bị thương.
- Bốn phương pháp: XGBoost, WCFR–XGBoost, FT-Transformer và TabM. WCFR là bước chọn đặc trưng; XGBoost là bộ phân loại phía sau.
- Notebook tổng hợp và bốn notebook chuyên sâu nằm trong `notebooks/`. Bốn notebook chuyên sâu đặt `MODE="FULL"` mặc định; `DEMO` chỉ phục vụ kiểm tra nhanh, không lấy làm kết quả báo cáo chính.

## 2. Bố cục đề nghị cho Chương 5

Bố cục sau giữ mạch trình bày giống PDF mẫu nhưng đổi toàn bộ nội dung sang project của nhóm. Nếu quy định của giảng viên dùng cách đánh số khác, giữ nguyên nội dung và đổi số mục cho khớp mục lục hiện tại.

1. **5.1 Khảo sát dữ liệu và xác định bài toán**
2. **5.2 Tiền xử lý dữ liệu và xây dựng đặc trưng**
3. **5.3 Thiết kế thực nghiệm và chia tập dữ liệu**
4. **5.4 Các thước đo đánh giá**
5. **5.5 Huấn luyện và đánh giá các mô hình**
   - 5.5.1 XGBoost
   - 5.5.2 WCFR–XGBoost
   - 5.5.3 FT-Transformer
   - 5.5.4 TabM
6. **5.6 So sánh, thảo luận kết quả**
7. **5.7 Kết luận chương và hạn chế**

Với mỗi mô hình, trình bày theo cùng một nhịp: nguồn phương pháp → cơ chế hoạt động → cấu hình trong notebook → cách huấn luyện → kết quả trên test → nhận xét. Việc này giúp người đọc so sánh được bốn nhánh mà không nhầm loss huấn luyện với metric đánh giá.

## 3. Nội dung cần viết theo từng mục

### 5.1 Khảo sát dữ liệu và xác định bài toán

Nêu nguồn, tên file, số dòng/cột và đơn vị quan sát. Một dòng trong CSV là một bản ghi tai nạn. Thống kê local hiện tại của file trong workspace là 500.000 dòng × 46 cột, không có dòng trùng toàn bộ và `ID` duy nhất; hãy để notebook tính lại các thống kê khi chạy trên file được gắn vào Kaggle và dùng kết quả của chính run đó trong báo cáo.

Phân bố `Severity` đã khảo sát trong file hiện tại:

| Severity | Số bản ghi | Tỷ lệ xấp xỉ |
|---:|---:|---:|
| 1 | 4.274 | 0,85% |
| 2 | 398.142 | 79,63% |
| 3 | 84.520 | 16,90% |
| 4 | 13.064 | 2,61% |
| **Tổng** | **500.000** | **100%** |

Dùng bảng/biểu đồ phân bố nhãn để giải thích mất cân bằng lớp: Severity 2 chiếm đa số, Severity 1 và 4 ít hơn. Không suy ra mô hình tốt chỉ từ Accuracy; một mô hình đoán tốt lớp đa số vẫn có thể bỏ sót lớp ít.

**Đoạn mở đầu có thể biên tập lại:**

> Chương này xây dựng bài toán phân loại đa lớp nhằm dự đoán mức Severity của một bản ghi tai nạn giao thông trong bộ dữ liệu U.S. Accidents. Severity gồm bốn mức và được hiểu là mức ảnh hưởng tới giao thông. Thực nghiệm sử dụng `Accidents_500.csv`, gồm [số dòng thực tế] dòng và [số cột thực tế] cột. Do phân bố nhãn không đồng đều, nhóm đánh giá bằng Macro-F1 làm thước đo chính, đồng thời trình bày các metric tổng hợp và kết quả riêng từng lớp.

**Bảng/ảnh nên đặt:** thông tin bộ dữ liệu; bảng tần suất Severity; biểu đồ cột bốn lớp. Ghi rõ các con số được tính từ file đầu vào, không lấy từ bài báo tham khảo.

### 5.2 Tiền xử lý dữ liệu và xây dựng đặc trưng

Mô tả theo đúng pipeline trong notebook:

1. Đọc đúng `Accidents_500.csv`, kiểm tra schema, kiểu dữ liệu, giá trị thiếu, nhãn và bản ghi trùng.
2. Tách `Severity` khỏi ma trận đặc trưng `X`; mã hóa nhãn 1–4 thành 0–3 cho thư viện huấn luyện và đổi về nhãn gốc 1–4 ở bảng/biểu đồ báo cáo.
3. Chốt thời điểm dự đoán là thời điểm bắt đầu tai nạn. Chỉ dùng thông tin có thể có tại hoặc trước thời điểm này.
4. Fit imputer, scaler, category vocabulary/encoder, trọng số lớp và discretization của WCFR trên train; sau đó áp dụng lên validation/test mà không fit lại.
5. Ghi riêng biểu diễn đầu vào từng kiến trúc. One-hot cho XGBoost và mã hóa số cho mạng neural có thể khác nhau, nhưng cùng xuất phát từ tập đặc trưng hợp lệ đã chốt.

Dùng một bảng giải thích quyết định giữ/bỏ cột. Không cần chép toàn bộ 46 cột nếu bảng quá dài; có thể chia nhóm và dẫn tới phụ lục.

| Nhóm cột | Quyết định theo notebook | Lý do cần nêu |
|---|---|---|
| `Severity` | Nhãn `y`, không đưa vào `X` | Đây là biến cần dự đoán |
| `ID` | Loại khỏi đặc trưng | Mã định danh, có thể gây học thuộc bản ghi |
| `End_Time`, `End_Lat`, `End_Lng` và thông tin kết thúc | Loại khỏi `X` | Chỉ có sau khi sự kiện đã diễn ra/được ghi nhận; có nguy cơ rò rỉ thông tin tương lai |
| `Description` | Loại khỏi `X` theo pipeline hiện tại | Văn bản có thể chứa thông tin hậu nghiệm; notebook hiện không xây nhánh NLP |
| `Distance(mi)` | Loại khỏi `X` theo giao thức hiện tại | Tránh dùng biến có thể phản ánh thời lượng/phạm vi sau sự kiện |
| `Weather_Timestamp` | Dùng để kiểm tra độ mới của quan sát, không dùng trực tiếp làm predictor | Không để timestamp thời tiết sau thời điểm dự đoán đi vào mô hình |
| Thời tiết và điều kiện đường bộ | Chỉ giữ giá trị hợp lệ tại/trước `Start_Time`; thời tiết phải không quá 120 phút tuổi | Mô phỏng thông tin có thể quan sát khi dự đoán |
| Thời gian, vị trí, điều kiện môi trường hợp lệ | Giữ/xây dựng theo danh sách trong notebook | Ghi tên feature và phép biến đổi thật sự đã chạy |

Không viết “đã loại mọi leakage” như một sự đảm bảo tuyệt đối. Nêu đây là giao thức chọn feature nhằm giảm rò rỉ, cùng các giả định còn lại. Có thể đặt bảng feature đầy đủ trong phụ lục hoặc đưa ra tóm tắt số đặc trưng thô và số cột sau encoding. Hai số này khác nhau; ghi rõ đang báo số nào.

### 5.3 Thiết kế thực nghiệm và chia tập dữ liệu

Bốn nhánh cần dùng cùng seed, giao thức đặc trưng và cùng các bản ghi train/validation/test. Notebook dùng seed 217 và chia xấp xỉ 64%/16%/20% theo nhóm phân tầng. Nhóm gần đúng được tạo từ `Start_Time` và tọa độ bắt đầu làm tròn 5 chữ số vì CSV không có event ID chuyên biệt. Do chia theo nhóm, tỷ lệ và số dòng thực tế có thể lệch nhẹ so với tỷ lệ danh nghĩa.

Báo cáo cần ghi:

- Chế độ chạy (`FULL` hoặc `DEMO`), số dòng sau làm sạch và số dòng của từng split.
- Seed, tỷ lệ mục tiêu và cách tạo nhóm; đính kèm hoặc lưu `split_ids.csv` để tái lập.
- Số bản ghi mỗi lớp trong từng split. Không tự bỏ lớp hiếm nếu split báo thiếu lớp; dùng `FULL` theo thiết kế hoặc điều tra cấu hình trước khi báo cáo.
- Validation dùng để chọn checkpoint/early stopping; test chỉ dùng đánh giá cuối sau khi đã chốt mô hình. Không chọn `Top-k`, ngưỡng hay hyperparameter dựa trên điểm test.
- Trọng số lớp được tính từ train. Validation/test không tham gia fit preprocessing hay class weights.

> Ghi chú diễn giải: đây là phép chia ngẫu nhiên có ràng buộc nhóm gần đúng, không phải kiểm tra khả năng dự báo ở một giai đoạn tương lai. Do đó, kết luận chỉ áp dụng cho split và cấu hình thực nghiệm đã chạy.

### 5.4 Các thước đo đánh giá

Chọn **Macro-F1 làm metric chính** để mỗi lớp có trọng số ngang nhau khi lấy trung bình. Định nghĩa và ý nghĩa của metric phải được giải thích ngắn gọn, đặc biệt vì nhãn mất cân bằng.

| Metric | Cách dùng trong báo cáo |
|---|---|
| Macro-F1 | Trung bình F1 của bốn lớp, không tính trọng số theo support; metric chính để so sánh |
| Accuracy | Tỷ lệ dự đoán đúng tổng thể; cần đọc cùng phân bố nhãn |
| Weighted-F1 | F1 từng lớp lấy trung bình có trọng số theo support; lớp phổ biến ảnh hưởng nhiều hơn |
| Balanced Accuracy | Trung bình recall theo lớp; hỗ trợ đọc hiệu quả trên lớp ít |
| Precision/Recall/F1 theo Severity | Cho biết loại lỗi theo từng mức 1, 2, 3, 4; luôn báo support |
| Confusion matrix | Chỉ rõ mức thật bị dự đoán thành mức nào; trục và thứ tự lớp phải cố định 1, 2, 3, 4 |
| QWK | Metric bổ sung có trọng số cho khoảng cách giữa nhãn thứ tự; không phải số đo thương vong và không thay thế Macro-F1 |

Dùng cùng test set và cùng hàm đánh giá cho cả bốn mô hình. Neural training có thể báo Cross-Entropy loss theo batch/epoch; đó là mục tiêu tối ưu, không phải metric so sánh cuối. XGBoost dùng validation `mlogloss` cho early stopping; điểm cuối trong bảng so sánh vẫn là Macro-F1 và các metric tính trên test.

### 5.5 Huấn luyện và đánh giá các mô hình

#### 5.5.1 XGBoost

**Cần giải thích:** XGBoost cộng dần các cây quyết định; mỗi bước tối ưu objective gồm loss đa lớp và penalty độ phức tạp cây. Xấp xỉ bậc hai dùng gradient/Hessian để ước lượng mức cải thiện khi thêm nhánh. Trình bày ý tưởng và trích dẫn paper gốc, không cần suy diễn công thức thành cấu hình chưa có trong code.

**Cấu hình đang dùng:** `XGBClassifier` đa lớp với objective `multi:softprob`, 4 lớp, tối đa 250 cây, `mlogloss` trên validation và early stopping 20 vòng; class sample weights được tính từ train. Notebook in tiến trình validation mỗi 25 vòng. Số cây cuối có thể ít hơn tối đa do dừng sớm; báo số vòng/best iteration thực tế từ run.

**Kết quả nên đưa:** một đoạn validation learning curve (hoặc hình learning curve), metric test tổng hợp, metric từng Severity và confusion matrix. Nêu model đạt dừng ở vòng nào, validation được dùng ra sao, sau đó đọc lỗi ở lớp hiếm. Không dùng điểm trên train để xếp hạng.

#### 5.5.2 WCFR–XGBoost

**Cần giải thích:** WCFR là bộ lọc chọn đặc trưng dựa trên weighted conditional mutual information, còn XGBoost thực hiện phân loại. Theo WCFR gốc, với tập đã chọn `S`, điểm ứng viên `f` được notebook triển khai theo dạng:

\[
J(f;S)=(1-\delta_1)\sum_{s\in S} I(f;Y\mid s)
 -(1-\delta_2)\sum_{s\in S}\left[I(f;s)-I(f;s\mid Y)\right],
\]

trong đó thành phần đầu thưởng cho quan hệ có ích với nhãn có điều kiện theo đặc trưng đã chọn; thành phần sau điều chỉnh trùng lặp. `δ₁` và `δ₂` được tính từ độ phân tán của các dãy thành phần relevance/redundancy tương ứng theo công thức paper. Mô tả đây là **WCFR gốc, Eq. (13)**; không gộp với công thức khác trong bài ứng dụng U.S. Accidents năm 2026.

**Lựa chọn triển khai nhóm cần công khai:** MI/CMI plug-in trên biến rời rạc; numerical bins tối đa 5 quantile bins; category hiếm được gom theo cấu hình; feature hằng bị loại; selector lấy mẫu train phân tầng tối đa 10.000 dòng với seed cố định; chọn greedy forward Top-10 cố định. Sau chọn, XGBoost phía sau học trên toàn bộ train split với cấu hình classifier tương ứng XGBoost đầy đủ đặc trưng. Nêu rõ khởi tạo tập chọn và lý do nhóm chọn cách đó; đây là quyết định triển khai, không khẳng định paper chỉ định mọi chi tiết cho CSV này.

**Kết quả cần báo:** danh sách và thứ tự 10 feature được chọn, score, thời gian chọn feature, số feature ban đầu/sau chọn, thời gian train classifier và metric test. So với XGBoost đầy đủ đặc trưng trên cùng split để đánh giá lợi ích/chi phí của bước chọn feature. Không khẳng định WCFR “tốt hơn” chỉ vì giảm số cột; hãy xem Macro-F1 và class-level metrics cùng lúc.

#### 5.5.3 FT-Transformer

**Cần giải thích:** numerical và categorical feature được mã hóa thành các feature token; token CLS được đưa qua các Transformer block để học tương tác giữa cột; prediction head trả logits cho bốn lớp. Nêu khác biệt giữa tokenization của cột và tạo chuỗi thời gian: notebook không tạo sliding windows từ timestamp.

Pipeline notebook xử lý numerical/categorical riêng; missing indicators được ghép với numerical input. Ghi số cột numerical/categorical sau preprocessing theo `config.json`/log của chính lần chạy. Tensor đầu ra classifier có dạng `B × 4`; `CrossEntropyLoss` nhận logits thô, không softmax trước loss. Notebook dùng tối đa 8 epoch, batch size 512, AdamW với learning rate `0.0005` và weight decay `0.0001`; checkpoint/early stopping theo Macro-F1 validation và patience cấu hình. Ghi epoch tốt nhất thực tế thay vì mặc định ghi đủ 8.

Đưa bảng loss/validation theo epoch hoặc hình learning curve, rồi metric test và confusion matrix. Nhấn mạnh loss là quá trình học; metric test là đánh giá sau khi chốt checkpoint.

#### 5.5.4 TabM

**Cần giải thích:** TabM dùng nhiều member MLP với cấu trúc chia sẻ tham số hiệu quả. Nhóm dùng biến thể TabM chuẩn theo implementation chính thức, `K=8` member và cấu hình hai block như notebook; không gọi đây là MLP đơn thông thường hoặc TabM-mini.

Nếu logits có dạng `B × K × 4`, loss train được tính theo từng member rồi lấy trung bình:

\[
L=\frac{1}{K}\sum_{k=1}^{K}\operatorname{CE}(z_k,y).
\]

Khi dự đoán, lấy softmax riêng từng member rồi trung bình xác suất:

\[
p(y\mid x)=\frac{1}{K}\sum_{k=1}^{K}\operatorname{softmax}(z_k).
\]

Notebook dùng weighted loss theo train, batch size 512, tối đa 8 epoch và theo dõi validation Macro-F1 để chọn checkpoint. Ghi rõ loss trung bình theo member khi huấn luyện và trung bình xác suất lúc inference; không mô tả nhầm thành loss trên logits đã trung bình.

Đưa tiến trình loss/validation, metric test và confusion matrix; nêu thời gian huấn luyện/inference trên phần cứng thực tế đã ghi trong environment.

### 5.6 So sánh và thảo luận kết quả

Tạo một bảng chung từ `metrics.csv`; chỉ ghép những dòng `status=success` trong `model_status.csv`. Không điền 0 cho notebook lỗi/chưa chạy. Đánh dấu rõ run là `FULL` hay `DEMO` và đảm bảo bốn kết quả thuộc cùng protocol/split, cùng seed, cùng dataset checksum. Nếu `split_ids.csv` không trùng, chưa so sánh như một benchmark công bằng.

| Model | Đặc trưng đầu vào/được chọn | Macro-F1 | Accuracy | Weighted-F1 | Balanced Acc. | QWK | Train (s) | Inference (s) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| XGBoost | [điền từ run] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| WCFR–XGBoost | [Top-10; ghi tên/đếm] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| FT-Transformer | [đếm theo config] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| TabM | [đếm theo config] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

Thêm bảng class-wise precision/recall/F1/support và confusion matrix cho mỗi model hoặc một figure 2×2. Thảo luận theo thứ tự:

1. Mô hình nào có Macro-F1 cao hơn trên test trong run này; khoảng cách là bao nhiêu.
2. Model nào nhận diện tốt/xấu các lớp Severity 1 và 4, vốn ít mẫu hơn; đối chiếu recall và confusion matrix.
3. Accuracy/Weighted-F1 có thể phản ánh chủ yếu lớp Severity 2; giải thích nếu thứ hạng khác Macro-F1.
4. WCFR giảm còn Top-10 feature có làm thay đổi chất lượng và thời gian không.
5. Training/inference time phụ thuộc accelerator, batch size, phiên bản thư viện và runtime Kaggle; chỉ so thời gian như đo được trên phần cứng đã ghi.

**Khung nhận xét để điền số liệu thật:**

> Trên test split của chế độ [FULL/DEMO], [model] đạt Macro-F1 [giá trị], cao/thấp hơn [model khác] [chênh lệch]. Xem theo từng lớp, recall của Severity [mức] là [giá trị], trong khi support là [số mẫu]. Confusion matrix cho thấy các trường hợp lỗi thường chuyển từ Severity [thật] sang [dự đoán]. Vì lớp Severity 2 chiếm [tỷ lệ], Accuracy/Weighted-F1 cần được đọc cùng Macro-F1 và chỉ số riêng từng lớp. Kết quả này mô tả split và cấu hình đã chạy; chưa đủ để kết luận model luôn tốt hơn trên các khoảng thời gian hoặc bộ dữ liệu khác.

Không ghi sẵn mô hình chiến thắng. Không lấy kết quả benchmark paper làm kết quả nhóm. Nếu bốn notebook có run khác ngày, cần đối chiếu `config.json`, checksum, `split_ids.csv`, phiên bản môi trường và trạng thái trước khi ghép.

### 5.7 Kết luận chương và hạn chế

Kết luận ngắn gọn về quy trình và những gì nhóm đo được: data protocol, bốn thuật toán, metric chính, điểm mạnh/yếu theo lớp, kết quả WCFR chọn đặc trưng và giới hạn. Không chỉ nêu tên model có điểm cao nhất.

Các giới hạn nên xem xét và diễn đạt theo thực tế run:

- File dùng là `Accidents_500.csv` với 500.000 dòng; không đại diện toàn bộ mọi tai nạn tại Mỹ.
- Phân bố Severity mất cân bằng, đặc biệt các mức ít mẫu; hiệu quả dự đoán các lớp này còn cần cải thiện/kiểm chứng.
- Chia ngẫu nhiên theo chữ ký `Start_Time` và tọa độ làm tròn là thay thế gần đúng vì không có event ID; chữ ký có thể gộp các sự kiện gần nhau hoặc không thể hiện chính xác ranh giới sự kiện.
- Split không phải temporal holdout; chưa chứng minh khái quát sang tương lai.
- Ngưỡng 120 phút cho dữ liệu thời tiết, danh sách feature và Top-10 WCFR là các lựa chọn của nhóm, cần ghi nhận khi diễn giải.
- Cấu hình hiện tại là baseline/khởi điểm có ngân sách giới hạn, chưa phải tuning đầy đủ hay tái lập toàn bộ benchmark paper.
- Kaggle runtime/GPU khác nhau; ghi môi trường thực tế và không so thời gian tuyệt đối giữa phần cứng khác nhau.

## 4. Tệp kết quả Kaggle cần lưu và đưa vào báo cáo

Mỗi run tạo thư mục `outputs/<run_id>/` (trên Kaggle là `/kaggle/working/outputs/<run_id>/`). Lấy số liệu từ cùng một thư mục run, tải ZIP output của từng notebook và lưu bản gốc cùng phụ lục/Drive của nhóm.

| Tệp đầu ra | Dùng vào phần nào |
|---|---|
| `config.json` | Mode, seed, hyperparameter, cấu hình thực nghiệm |
| `environment.json` | Python, package, phần cứng/accelerator thực tế |
| `split_ids.csv` | Chứng minh và tái lập các bản ghi trong từng split |
| `metrics.csv` | Bảng so sánh metric tổng hợp |
| `class_metrics.csv` | Bảng metric theo Severity và support |
| `model_status.csv` | Xác nhận model thành công hay lỗi; không xem model lỗi là điểm 0 |
| `predictions.csv` | Dự đoán/probability trên test để phân tích lỗi |
| `confusion_*.png` | Hình confusion matrix theo model |
| `xgboost_validation_curve.csv` | Quá trình validation/early stopping của XGBoost backend |
| `learning_curve_*.csv`, `training_progress_*.csv` | Loss/metric qua epoch và các mốc batch của mạng neural |
| `wcfr_selected_features.csv` (hoặc tệp selector tương ứng trong run) | Danh sách, thứ tự, score và thông tin lựa chọn feature WCFR |
| `test_macro_f1.png`, `learning_curves.png` | Hình tổng hợp xuất từ notebook; kiểm tra nhãn DEMO/FULL trước khi dùng |

Ảnh Kaggle có thể minh họa notebook chạy, nhưng bảng CSV và config là nguồn chuẩn để chép số. Hình chụp cần có tiêu đề/caption, nguồn `Kaggle Notebook, run_id: ...`, mode và metric; không cắt mất nhãn trục/đơn vị. Chỉ đưa log train để minh họa quá trình; không dùng ảnh log thay bảng kết quả test.

## 5. Cách trích dẫn paper và ghi chú phương pháp

Trong thân bài, trích dẫn paper ngay khi giải thích thuật toán; danh mục tài liệu cuối báo cáo ghi đủ tác giả, năm, tên bài, hội nghị/tạp chí và DOI/URL. Dùng `PAPER_IMPLEMENTATION_NOTES.md` trong workspace làm checklist đối chiếu paper, công thức và lựa chọn triển khai.

- XGBoost: Chen & Guestrin, *XGBoost: A Scalable Tree Boosting System* (KDD 2016), [DOI 10.1145/2939672.2939785](https://doi.org/10.1145/2939672.2939785).
- WCFR gốc: Zhou, Wang & Zhang, *Feature selection based on weighted conditional mutual information* (Applied Computing and Informatics, 2019), [DOI 10.1016/j.aci.2019.12.003](https://doi.org/10.1016/j.aci.2019.12.003), mục 3.1, Eqs. (11)–(17), đặc biệt Eq. (13). Bài ứng dụng U.S. Accidents năm 2026 là nguồn đối chiếu bối cảnh/Top-k, không phải định nghĩa thay thế cho WCFR gốc: [Electronics 15(6), 1308](https://doi.org/10.3390/electronics15061308).
- FT-Transformer: Gorishniy et al., *Revisiting Deep Learning Models for Tabular Data* (NeurIPS 2021), [paper](https://arxiv.org/abs/2106.11959), [repository được khuyến nghị](https://github.com/yandex-research/rtdl-revisiting-models).
- TabM: Gorishniy et al., *TabM: Advancing Tabular Deep Learning With Parameter-Efficient Ensembling* (ICLR 2025), [paper](https://arxiv.org/abs/2410.24210), [repository chính thức](https://github.com/yandex-research/tabm).
- Dữ liệu: [Accidents in US — Kaggle](https://www.kaggle.com/datasets/dybuao/accidents-in-us?select=Accidents_500.csv). Nêu đúng file cụ thể `Accidents_500.csv` và nguồn tải.

Khi ghi package/version, phân biệt version pin mà notebook dự kiến cài với version Kaggle thực sự dùng; chép version thực tế từ `environment.json`. Không tuyên bố đã chạy Kaggle nếu nhóm chỉ mới smoke test local.

## 6. Checklist trước khi hoàn thiện báo cáo

- [ ] Chương 5 nối tiếp chương 4 và khớp mục lục/định dạng hiện hành.
- [ ] Dataset, row count, label counts lấy từ đúng run `FULL`; không nhầm với toàn bộ U.S. Accidents gốc.
- [ ] Giải thích Severity là mức ảnh hưởng tới giao thông.
- [ ] Mô tả rõ feature bị loại/giữ, thời điểm dự đoán và giới hạn leakage.
- [ ] Cả bốn model dùng cùng checksum, seed, split IDs và test set.
- [ ] Có validation riêng; test không dùng để chọn cấu hình/Top-k/checkpoint.
- [ ] XGBoost, WCFR–XGBoost, FT-Transformer, TabM được mô tả theo implementation thật, không thay bằng thuật toán tương tự.
- [ ] WCFR ghi đúng Eq. (13) bản gốc, lựa chọn discretization, selector sample, Top-10 và danh sách feature.
- [ ] TabM ghi đúng loss theo member và trung bình xác suất lúc inference.
- [ ] Có Macro-F1, Accuracy, Weighted-F1, Balanced Accuracy, QWK, metric từng lớp, support và confusion matrix.
- [ ] Không ghi kết quả cho model lỗi/chưa chạy; phân biệt DEMO/FULL.
- [ ] Bảng kết quả có thời gian đo, hardware, versions và `run_id`.
- [ ] Nhận xét dựa trên output thực tế; không điền sẵn model thắng và không lấy số paper thay cho số nhóm.
- [ ] Hạn chế nói rõ random grouped split không chứng minh dự báo tương lai.

## 7. Nguồn trong project được dùng để soạn hướng dẫn

- Báo cáo nhóm trên Google Docs: [24520814_24521985_v5.docx](https://docs.google.com/document/d/1bUMDX4sEpxA-H9lH4VqxCt-eGHKi4VE9/edit) — dùng để khớp tên đồ án và mạch bốn chương hiện có; tài liệu này không được chỉnh sửa.
- PDF đồ án mẫu: `[6]_IS217Q11_23520009_23520753.pdf` — chỉ tham khảo bố cục Chương 5.
- Cấu hình/nguồn paper: [PAPER_IMPLEMENTATION_NOTES.md](PAPER_IMPLEMENTATION_NOTES.md), [README_KAGGLE.md](README_KAGGLE.md), cùng bốn notebook chuyên sâu trong `notebooks/`.
