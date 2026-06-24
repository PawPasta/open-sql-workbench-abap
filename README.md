# Interactive ABAP SQL Workbench Tool

## Overview
The Interactive ABAP SQL Workbench Tool is a custom SAP ABAP solution designed to provide a secure, interactive, and feature-rich environment for executing SQL queries directly within SAP. It exposes its functionalities through an OData service, making it easy to integrate with modern web frontends (like SAP Fiori / UI5).

## Key Features
- **Dynamic SQL Execution**: Supports running `SELECT` queries with advanced clauses including `JOIN`, `GROUP BY`, `WHERE`, and `ORDER BY`.
- **Data Dictionary (DDIC) Browser**: Enables exploring SAP tables and fields directly to assist in query building.
- **Data Masking**: Automatically masks sensitive data columns based on predefined configurations, ensuring data privacy and security.
- **Whitelist Profiles**: Controls which database tables can be queried by specific user profiles, preventing unauthorized access to critical tables.
- **Execution Logging**: Keeps an audit trail of executed queries, execution times, and returned row counts.
- **Query Management**: Allows users to save, manage, and reuse their frequent SQL queries.
- **Export Capabilities**: Supports exporting query results to CSV formats.
- **OData Integration**: Exposes functionalities via an SAP Gateway OData Service (`ZCL_ZSQLWB_ODATA_DPC_EXT`), facilitating seamless frontend integrations.

## Architecture
The application is structured into the following layers:
1. **DDIC (`ZSQLWB_DDIC`)**: Contains the table definitions, data elements, and domains storing configuration, logs, masks, and user roles.
2. **Core Logic (`ZSQLWB_CORE`)**:
   - `ZCL_SQLWB_SERVICE`: The main facade and entry point for all operations.
   - `ZCL_SQLWB_EXECUTOR`: The execution engine handling dynamic Open SQL statements.
   - `ZCL_SQLWB_VALIDATOR` & `ZCL_SQLWB_SQL_PARSER`: Ensures the executed SQL is safe, structurally sound, and doesn't violate access rules.
   - Utilities for logging, serialization, data masking, and configuration management.
3. **API (`ZSQLWB_API`)**: Gateway DPC Extension classes handling the OData HTTP requests and mapping them to the Core Logic.
4. **Tests (`ZSQLWB_TEST`)**: Comprehensive ABAP Unit tests ensuring stability across core functionalities.

---

# Công Cụ Interactive ABAP SQL Workbench

## Tổng Quan
Interactive ABAP SQL Workbench Tool là một giải pháp SAP ABAP tùy chỉnh, được thiết kế nhằm cung cấp một môi trường an toàn, tương tác và đa tính năng để thực thi các truy vấn SQL trực tiếp trong SAP. Công cụ này cung cấp các tính năng thông qua dịch vụ OData, giúp dễ dàng tích hợp với các giao diện web hiện đại (như SAP Fiori / UI5).

## Tính Năng Chính
- **Thực Thi SQL Động**: Hỗ trợ chạy các câu lệnh `SELECT` phức tạp bao gồm các mệnh đề `JOIN`, `GROUP BY`, `WHERE`, và `ORDER BY`.
- **Duyệt Data Dictionary (DDIC)**: Cho phép khám phá các bảng và trường trong SAP để hỗ trợ việc xây dựng câu truy vấn.
- **Che Dữ Liệu (Data Masking)**: Tự động che giấu các cột dữ liệu nhạy cảm dựa trên cấu hình thiết lập trước, đảm bảo an toàn và bảo mật dữ liệu.
- **Hồ Sơ Danh Sách Trắng (Whitelist Profiles)**: Kiểm soát những bảng cơ sở dữ liệu nào được phép truy vấn bởi các tài khoản người dùng cụ thể, ngăn chặn truy cập trái phép vào các bảng quan trọng.
- **Lịch Sử Thực Thi (Logging)**: Lưu trữ nhật ký kiểm toán về các câu truy vấn đã chạy, thời gian thực thi, và số lượng bản ghi trả về.
- **Quản Lý Truy Vấn**: Cho phép người dùng lưu, quản lý và tái sử dụng các câu truy vấn SQL thường dùng.
- **Tính Năng Xuất Dữ Liệu**: Hỗ trợ xuất kết quả truy vấn ra định dạng CSV.
- **Tích Hợp OData**: Cung cấp các chức năng thông qua SAP Gateway OData Service (`ZCL_ZSQLWB_ODATA_DPC_EXT`), tạo điều kiện thuận lợi cho việc tích hợp frontend.

## Kiến Trúc
Ứng dụng được cấu trúc thành các lớp sau:
1. **DDIC (`ZSQLWB_DDIC`)**: Chứa các định nghĩa bảng, phần tử dữ liệu (data elements) và miền (domains) dùng để lưu trữ cấu hình, nhật ký, quy tắc che dữ liệu và phân quyền người dùng.
2. **Logic Cốt Lõi (`ZSQLWB_CORE`)**:
   - `ZCL_SQLWB_SERVICE`: Lớp mặt tiền (facade) và điểm vào chính cho tất cả các hoạt động.
   - `ZCL_SQLWB_EXECUTOR`: Động cơ thực thi xử lý các câu lệnh Open SQL động.
   - `ZCL_SQLWB_VALIDATOR` & `ZCL_SQLWB_SQL_PARSER`: Đảm bảo câu lệnh SQL an toàn, đúng cấu trúc và không vi phạm quy tắc truy cập.
   - Các tiện ích về ghi nhật ký (logging), tuần tự hóa JSON (serialization), che dữ liệu, và quản lý cấu hình.
3. **API (`ZSQLWB_API`)**: Các lớp mở rộng DPC (DPC Extension) của Gateway xử lý các yêu cầu HTTP OData và ánh xạ chúng tới Logic cốt lõi.
4. **Kiểm Thử (`ZSQLWB_TEST`)**: Các bài kiểm thử ABAP Unit toàn diện đảm bảo tính ổn định của các chức năng cốt lõi.
