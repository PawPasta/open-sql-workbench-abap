# Interactive ABAP SQL Workbench Tool

## Functional Requirements

- Xây dựng trình soạn thảo ABAP Open SQL tương tác có tô màu cú pháp, tự động gợi ý tên bảng/trường và kiểm tra lỗi cú pháp.
- Hỗ trợ lưu và quản lý các câu truy vấn hay dùng.
- Thực thi truy vấn qua RFC/BAPI hoặc OData service trả về kết quả dạng bảng phân trang.

- Hiển thị kết quả truy vấn dưới dạng bảng dữ liệu động có:
  - Phân trang
  - Sắp xếp
  - Tìm kiếm theo cột

- Hỗ trợ xuất kết quả sang Excel hoặc CSV bằng một thao tác.
- Cung cấp xem trước dữ liệu nhanh (top 100 bản ghi) cho bất kỳ bảng nào.

- Cung cấp trình duyệt từ điển dữ liệu tích hợp:
  - Tìm kiếm bảng theo tên hoặc mô tả
  - Xem định nghĩa field (tên, kiểu, độ dài, nhãn)
  - Kiểm tra các khóa ngoại
  - Liên kết tới bảng liên quan
  - Hiển thị số lượng bản ghi ước tính cho mỗi bảng

- Lưu lịch sử thực thi truy vấn với:
  - Dấu thời gian
  - ID người dùng
  - Thời gian thực thi

- Hỗ trợ đặt tên và chia sẻ câu truy vấn giữa người dùng:
  - Trong nhóm
  - Toàn hệ thống

- Ghi nhật ký hoạt động để kiểm toán tuân thủ.

---

## Technical

- ABAP
- OData v2
