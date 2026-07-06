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
- **OData Integration**: Exposes functionalities via an SAP Gateway OData Service (`ZCL_ZSU26_GƯ_MILO_DPC_EXT`), facilitating seamless frontend integrations.

## Architecture
The application is structured into the following layers:
1. **DDIC (`ZMILO_SQLWB_DDIC`)**: Contains the table definitions, data elements, and domains storing configuration, logs, masks, and user roles.
2. **Core Logic (`ZSQLWB_CORE`)**:
   - `ZCL_MILO_SERVICE`: The main facade and entry point for all operations.
   - `ZCL_MILO_EXECUTOR`: The execution engine handling dynamic Open SQL statements.
   - `ZCL_MILO_VALIDATOR` & `ZCL_SQLWB_SQL_PARSER`: Ensures the executed SQL is safe, structurally sound, and doesn't violate access rules.
   - Utilities for logging, serialization, data masking, and configuration management.
3. **API (`ZMILO_SQLWB_API`)**: Gateway DPC Extension classes handling the OData HTTP requests and mapping them to the Core Logic.
4. **Tests (`ZMILO_SQLWB_TEST`)**: Comprehensive ABAP Unit tests ensuring stability across core functionalities.

---