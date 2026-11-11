# Hướng dẫn setup môi trường và triển khai Chương 5

## 1. Phạm vi và cách dùng tài liệu mẫu

Tài liệu này hướng dẫn chuẩn bị môi trường, dữ liệu và cách chạy bốn pipeline của đồ án IS217 trên U.S. Accidents. PDF đồ án mẫu được dùng để tham khảo **bố cục trình bày Chương 5**: mô tả dữ liệu, tiền xử lý, chuẩn bị tập train/test, trình bày từng mô hình, báo cáo kết quả/biểu đồ và cuối cùng so sánh. Nội dung trong PDF về Student Depression, biến Depression, mã hóa, thuật toán khác và số liệu của nhóm mẫu **không phải yêu cầu cho đồ án này** và không được chép thành kết quả của nhóm.

Hướng dẫn setup cụ thể lấy từ `README_KAGGLE.md` và các notebook hiện có. Severity trong U.S. Accidents là **mức ảnh hưởng tới giao thông**, không phải số người chết hoặc bị thương.

## 2. Thành phần cần chuẩn bị

Trong workspace hiện có:

| Thành phần | Vai trò |
|---|---|
| `Accidents_500.csv` | Dữ liệu đầu vào; bản local đã kiểm tra có 500.000 dòng × 46 cột. |
| `notebooks/Chapter5_XGBoost_Kaggle.ipynb` | Pipeline XGBoost đa lớp. |
| `notebooks/Chapter5_WCFR_XGBoost_Kaggle.ipynb` | WCFR chọn đặc trưng, sau đó XGBoost phân loại. |
| `notebooks/Chapter5_FT_Transformer_Kaggle.ipynb` | FT-Transformer dùng implementation `rtdl_revisiting_models`. |
| `notebooks/Chapter5_TabM_Kaggle.ipynb` | TabM chuẩn, dùng implementation package `tabm`. |
| `notebooks/Chapter5_US_Accidents_4Models_Kaggle.ipynb` | Chạy/so sánh các nhánh theo một cấu hình chung. |
| `PAPER_IMPLEMENTATION_NOTES.md` | Nguồn paper, công thức và lựa chọn triển khai. |

Bản CSV local có phân bố Severity đã khảo sát: Severity 1 = 4.274, 2 = 398.142, 3 = 84.520, 4 = 13.064; không có dòng trùng nguyên bản và ID duy nhất. Notebook vẫn tự tính lại thống kê từ CSV bạn gắn vào Kaggle. Nếu dữ liệu trên Kaggle khác checksum hoặc bản local, hãy dùng thống kê notebook in ra cho đúng lần chạy.

## 3. Cách được khuyến nghị: chạy trên Kaggle

### 3.1. Mở notebook

1. Mở Kaggle và tạo notebook Python mới, hoặc import notebook `.ipynb` tương ứng từ thư mục `notebooks/`.
2. Tạo/lưu một bản trong tài khoản Kaggle của bạn để các thiết lập input và accelerator gắn với notebook đó.
3. Chạy riêng từng notebook model. Không cần chạy notebook tổng hợp nếu mục tiêu hiện tại là xem quá trình train riêng từng thuật toán.

### 3.2. Gắn đúng CSV vào Input

Trong panel **Input**, chọn **Add Input** rồi thêm dataset `Accidents in US` của `dybuao`, có file `Accidents_500.csv`:

https://www.kaggle.com/datasets/dybuao/accidents-in-us?select=Accidents_500.csv

Notebook tìm đúng basename `Accidents_500.csv` bên trong `/kaggle/input`. Không cần chép CSV vào `/kaggle/working`. Sau khi thêm Input, chạy cell kiểm tra dữ liệu. Nếu notebook báo `FileNotFoundError`, lỗi này có nghĩa là kernel chưa thấy file theo đường dẫn dự kiến; model chưa bắt đầu train.

Để xem Kaggle đang mount file nào, chạy cell chẩn đoán:

```python
from pathlib import Path

matches = sorted(Path("/kaggle/input").rglob("*.csv"))
for path in matches:
    print(path)
```

- Nếu danh sách rỗng: mở **Input → Add Input**, thêm dataset, rồi khởi động lại phiên hoặc chạy lại từ đầu.
- Nếu thấy `Accidents_500.csv` đúng một lần: để `DATA_PATH=None` cho notebook tự tìm, hoặc copy đường dẫn đó vào `CONFIG["DATA_PATH"]`.
- Nếu có nhiều file cùng basename: chọn đúng đường dẫn `Accidents_500.csv` của dataset đã thêm và gán vào `DATA_PATH`. Notebook cố ý dừng khi có nhiều bản trùng tên để tránh chạy nhầm dữ liệu.

Ví dụ gán đường dẫn (thay bằng kết quả thật của cell trên):

```python
CONFIG["DATA_PATH"] = "/kaggle/input/<dataset-folder>/Accidents_500.csv"
```

### 3.3. Chọn Accelerator và Internet

Trong **Session options/Settings** của Kaggle:

- **FT-Transformer và TabM:** chọn GPU để train FULL. Notebook dùng PyTorch và lấy GPU đầu tiên mà runtime báo khả dụng; code hiện chưa chia mô hình qua cả hai card T4x2.
- **XGBoost và WCFR–XGBoost:** có thể chạy CPU; nếu bật GPU, XGBoost tự chọn CUDA khi package/runtime hỗ trợ. Phần chọn WCFR vẫn là tính toán CPU.
- **Internet:** bật khi notebook cần cài package model còn thiếu. Notebook chỉ cài package cần cho model đang chạy, không nâng cấp hàng loạt thư viện.
- Trước khi chạy dài, kiểm tra quota accelerator đang hiển thị trong tài khoản và phiên bản phần cứng Kaggle hiện cấp. Theo thông báo Kaggle ngày 2026-09-15, P100 đã được thay bằng lựa chọn T4x2; phần cứng/quota có thể thay đổi theo tài khoản và thời điểm. Kaggle ghi phiên notebook CPU/GPU có thể chạy tối đa 12 giờ mỗi phiên. Đây là giới hạn nền tảng, không phải đảm bảo notebook sẽ hoàn tất trong khoảng thời gian đó.

Nguồn chính thức (kiểm tra ngày 2026-11-11): [Notebook sessions và giới hạn phiên](https://www.kaggle.com/docs/notebooks), [hướng dẫn dùng GPU/quota](https://www.kaggle.com/docs/efficient-gpu-usage), [thông báo chuyển từ P100 sang T4x2](https://www.kaggle.com/discussions/product-announcements/735239).

### 3.4. Thư viện

Kaggle cung cấp sẵn Python environment và các thư viện khoa học dữ liệu phổ biến. Notebook sẽ dùng thư viện sẵn có; nếu thiếu implementation của nhánh đang chạy, cell cài đặt chỉ cài package cần thiết:

| Nhánh | Package được yêu cầu khi thiếu |
|---|---|
| XGBoost | `xgboost==3.4.1` |
| WCFR–XGBoost | `xgboost==3.4.1` sau bước selector WCFR |
| FT-Transformer | `rtdl_revisiting_models==0.0.2` |
| TabM | `tabm==0.0.3` |

PyTorch và các thư viện tiền xử lý/đánh giá phải có trong image runtime. Notebook ghi phiên bản thực tế vào `environment.json`. Nếu pip báo không tải được package, bật Internet trong Settings rồi chạy lại cell cài đặt hoặc khởi động phiên mới. Không cần tự cài tất cả ba package model cho mỗi notebook.

### 3.5. Kiểm tra nhanh runtime trước khi train

Ở cell kiểm tra môi trường, xác nhận đường dẫn CSV được in đúng. Khi chọn GPU, có thể kiểm tra thêm:

```python
import torch
print("CUDA available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name(0))
```

Không bật FULL nếu `CUDA available` là `False` cho hai notebook neural, trừ khi bạn chấp nhận thời gian CPU có thể lâu. XGBoost vẫn có thể chạy CPU.

## 4. Cấu hình chạy bốn mô hình

Bốn notebook chuyên sâu hiện để `MODE="FULL"` mặc định, tức dùng toàn bộ các dòng sau khi bỏ duplicate nguyên bản. Đây **chỉ là chạy trên toàn bộ CSV**, không phải tái lập benchmark của paper. Mỗi lần chạy vẫn chia train/validation/test xấp xỉ 64/16/20; test không được dùng để fit hoặc chọn checkpoint.

Chạy từng notebook theo thứ tự cell từ trên xuống. Seed mặc định là 217. Nếu muốn xác nhận Input/dependency trước, chuyển `MODE="DEMO"` và dùng mẫu tối đa 30.000 dòng; sau khi setup ổn mới chuyển về FULL.

| Notebook | Training mặc định | Tiến độ quan sát |
|---|---|---|
| XGBoost | Tối đa 250 vòng boosting; early stopping 20 vòng theo validation mlogloss. | In validation mlogloss mỗi 25 vòng; lưu `xgboost_validation_curve.csv`. |
| WCFR–XGBoost | Selector fit trên tối đa 10.000 dòng train; cố định Top-10; XGBoost fit trên toàn bộ train split. | In tên/score của từng feature được chọn; tiếp theo in validation log của XGBoost. |
| FT-Transformer | Tối đa 8 epoch, batch 512, patience 3; checkpoint chọn bằng validation Macro-F1. | In weighted cross-entropy theo batch mỗi 100 bước và ở batch đầu/cuối, cùng metric theo epoch. |
| TabM | TabM chuẩn, K=8; tối đa 8 epoch, batch 512, patience 3. | In loss trung bình theo member theo batch/epoch và validation Macro-F1. |

Các mức trên là cấu hình khởi đầu của project, không phải tuning tối ưu hay benchmark paper. Nếu runtime chậm/OOM, giảm `BATCH_SIZE`, `NEURAL_EPOCHS`, `XGB_TREES` hoặc `WCFR_MAX_TRAIN_ROWS` có chủ đích và ghi lại giá trị mới. Thay đổi batch/epochs/trees làm thay đổi ngân sách thực nghiệm, nên giữ nguyên nếu cần so sánh công bằng giữa các model.

**Lưu ý về resume:** hiện notebook ghi learning curve sau khi train xong; chưa có checkpoint để tiếp tục từ giữa epoch nếu phiên Kaggle bị ngắt. Nếu phiên dừng giữa chừng, chạy lại từ đầu sẽ khởi động lại training. Vì thế hãy chạy từng model riêng, theo dõi thời gian/quota và tránh mở nhiều session GPU không cần thiết.

## 5. Quy trình chạy đề xuất

1. Chọn một notebook model, gắn `Accidents_500.csv` trong Input.
2. Chọn Accelerator phù hợp; bật Internet nếu môi trường thiếu package.
3. Kiểm tra `MODE`, `SEED`, `DATA_PATH` và giới hạn train trong CONFIG.
4. Chạy cell đầu để kiểm tra versions, hardware, Input path và thư mục output.
5. Chạy toàn bộ notebook từ đầu theo thứ tự. Không chạy cell train trước cell tạo split/preprocessing.
6. Quan sát logs theo batch/epoch hoặc boosting iteration. Nếu lỗi, đọc traceback đầu tiên và `model_status.csv`; không coi một bảng không có metric là điểm số 0.
7. Khi kết thúc, kiểm tra Macro-F1, metrics theo Severity, confusion matrix, thời gian và `environment.json`.
8. Tải ZIP trong Kaggle **Output/Files** hoặc tải thư mục output cần thiết.
9. Lặp lại với notebook tiếp theo. Giữ chung seed, feature/split protocol và không đổi test set để so sánh.

## 6. Output của mỗi lần chạy

Notebook lưu vào:

- Kaggle: `/kaggle/working/outputs/<run_id>/`
- Local: `outputs/<run_id>/`

Thông thường có `config.json`, `environment.json`, `split_ids.csv`, `class_mapping.json`, `metrics.csv`, `class_metrics.csv`, `model_status.csv`, `predictions.csv` và confusion matrix. Nhánh XGBoost có validation curve; các nhánh neural có learning curve và log tiến độ; WCFR có thứ tự/score feature, cấu hình selector và thời gian chọn. Cell cuối tạo file ZIP `Chapter5_<model>_<run_id>.zip`.

Macro-F1 là metric chính do phân bố nhãn lệch mạnh. Xem Precision/Recall/F1/support từng lớp để đánh giá lớp hiếm; Accuracy đơn lẻ có thể che khuất việc bỏ sót Severity 1 hoặc 4. Severity biểu diễn mức ảnh hưởng giao thông. Không diễn giải metric thành số thương vong.

## 7. Nếu chạy trên máy local

Kaggle là môi trường được khuyến nghị để có GPU dễ cấu hình. Nếu chạy local bằng Python/Jupyter:

1. Cài Python phù hợp với các package trong runtime bạn chọn; tạo virtual environment riêng cho project.
2. Cài nhóm thư viện cơ bản còn thiếu. Ví dụ PowerShell:

```powershell
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install pandas numpy scipy scikit-learn matplotlib nbformat
```

3. Cài model package cần dùng, hoặc để cell trong notebook tự cài bản đã ghim ở mục 3.4:

```powershell
# Chỉ cho XGBoost hoặc WCFR–XGBoost
python -m pip install xgboost==3.4.1

# Chỉ cho FT-Transformer
python -m pip install rtdl_revisiting_models==0.0.2

# Chỉ cho TabM
python -m pip install tabm==0.0.3
```

4. FT-Transformer/TabM cần PyTorch. Kiểm tra `import torch` thành công trong runtime Kaggle; nếu thiếu, cài bản phù hợp. Nếu dùng GPU local, cài đúng build CUDA/driver theo [hướng dẫn cài PyTorch](https://pytorch.org/get-started/locally/); tránh chọn một wheel CUDA bất kỳ. Notebook ghi phiên bản PyTorch thực tế.
5. Đặt `CONFIG["DATA_PATH"]` thành đường dẫn đầy đủ tới `Accidents_500.csv` hoặc đặt CSV tại thư mục làm việc.
6. Nếu package chưa có và để notebook tự cài, máy cần kết nối Internet.
7. Chạy notebook từ trên xuống và kiểm tra `outputs/<run_id>`.

Không hardcode đường dẫn `D:\...` trong notebook gửi lên Kaggle. Đường dẫn Kaggle và local khác nhau; dùng `DATA_PATH=None` để tự tìm hoặc đặt đường dẫn trong cấu hình môi trường đang chạy.

## 8. Cấu trúc đề xuất cho báo cáo Chương 5

Theo bố cục PDF tham khảo, có thể trình bày Chương 5 theo thứ tự sau nhưng thay toàn bộ nội dung cho đúng dữ liệu và thực nghiệm U.S. Accidents:

### 5.1. Mô tả dữ liệu

- Nguồn và phạm vi CSV; grain một dòng trên một bản ghi tai nạn theo dataset.
- Kích thước thực tế, ý nghĩa Severity, phân bố 4 lớp, kiểu dữ liệu/missing/duplicate.
- Ghi rõ dữ liệu đã được khảo sát trong workspace hay tải từ Kaggle; không khẳng định xuất từ DW nếu không có SQL/export evidence.

### 5.2. Kiểm tra, chống leakage và tiền xử lý

- Chốt thời điểm dự đoán tại lúc bắt đầu/ghi nhận sự cố.
- Giải thích feature giữ/bỏ; loại ID và thông tin hậu nghiệm như End_Time, End_Lat/End_Lng, Description, Distance(mi).
- Trình bày quy tắc thời tiết, missing/category encoding và việc fit preprocessing chỉ trên train.
- Nêu mapping Severity 1–4 sang code 0–3 trong training và đổi lại khi báo cáo.

### 5.3. Chuẩn bị thực nghiệm

- Mô tả split phân tầng có nhóm xấp xỉ 64/16/20, seed 217 và lý do nhóm theo chữ ký sự kiện gần đúng.
- Nêu train dùng để fit; validation chọn checkpoint/early stopping/Top-k; test chỉ đánh giá sau khi chốt.
- Giải thích Macro-F1 là metric chính; báo thêm Accuracy, Weighted-F1, Balanced Accuracy, QWK và bảng theo lớp.

### 5.4. Xây dựng và đánh giá mô hình

Với mỗi mô hình, theo mẫu chung: **cơ sở thuật toán và paper → cơ chế/công thức → cấu hình thực nghiệm → quá trình train → dự đoán/inference → metrics/biểu đồ → nhận xét có căn cứ từ kết quả đã chạy**.

- 5.4.1 XGBoost.
- 5.4.2 WCFR–XGBoost: ghi rõ WCFR là selector và classifier sau selector là XGBoost; công thức gốc WCFR khác bài ứng dụng.
- 5.4.3 FT-Transformer.
- 5.4.4 TabM.
- 5.4.5 Bảng/biểu đồ so sánh trên cùng test split.
- 5.4.6 Thảo luận giới hạn, lớp bị nhầm, ngân sách, phần cứng và split.

Chỉ đưa số liệu từ `metrics.csv` và `class_metrics.csv` của đúng run. Đánh dấu kết quả DEMO/FULL, seed, số dòng, thời gian, phần cứng và cấu hình. Không dùng điểm paper làm điểm của nhóm và không viết trước mô hình thắng.

## 9. Nguồn dự án

- Hướng dẫn Kaggle: `README_KAGGLE.md`.
- Nguồn paper và khác biệt triển khai: `PAPER_IMPLEMENTATION_NOTES.md`.
- Dataset tham chiếu: [Accidents in US - Accidents_500.csv](https://www.kaggle.com/datasets/dybuao/accidents-in-us?select=Accidents_500.csv).
- PDF mẫu `[6]_IS217Q11_23520009_23520753.pdf`: chỉ tham khảo cách chia mục Chương 5; xem trang in 365–388. Dữ liệu, biến mục tiêu và kết quả trong PDF thuộc project khác.
