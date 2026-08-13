*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_TOP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMILO_TEST_TOP.

PARAMETERS p_prof TYPE zmilo_profile_id DEFAULT 'DEV'.
PARAMETERS p_sql  TYPE string LOWER CASE
  DEFAULT 'SELECT TOP 10 CARRID, CONNID FROM SPFLI ORDER BY CARRID, CONNID'.
PARAMETERS p_page TYPE i DEFAULT 1.

START-OF-SELECTION.

  DATA lv_sql TYPE string.
  DATA ls_role TYPE zmilo_role.
  DATA ls_parts TYPE zcl_milo_sql_parser=>ty_query_parts.
  DATA ls_result TYPE zcl_milo_service=>ty_run_result.

  lv_sql = p_sql.

  WRITE: / 'PROFILE:', p_prof,
         / 'SQL:', lv_sql,
         / 'PAGE:', p_page.

  TRY.
      ls_role = zcl_milo_service=>get_role_profile( p_prof ).
      ls_parts = zcl_milo_sql_parser=>parse( lv_sql ).

      WRITE: / 'PARSED TOP:', ls_parts-top_rows,
             / 'HAS TOP:', ls_parts-has_top,
             / 'OBJECT:', ls_parts-table_name,
             / 'COLUMNS:', ls_parts-columns.

      zcl_milo_validator=>validate_select_sql(
        EXPORTING
          iv_sql              = lv_sql
          iv_wlist_profile_id = ls_role-wlist_profile_id
        IMPORTING
          ev_object_name      = DATA(lv_object_name) ).

      WRITE: / 'VALIDATION: SUCCESS',
             / 'VALIDATED OBJECT:', lv_object_name.

      ls_result = zcl_milo_service=>run_query_result(
        iv_profile_id = p_prof
        iv_sql        = lv_sql
        iv_page       = p_page ).

      WRITE: / 'STATUS:', ls_result-status,
             / 'ERROR CODE:', ls_result-error_code,
             / 'ERROR TEXT:', ls_result-error_text,
             / 'ROW COUNT:', ls_result-row_count,
             / 'RETURNED ROWS:', ls_result-returned_rows,
             / 'PAGE SIZE:', ls_result-page_size,
             / 'TOTAL PAGES:', ls_result-total_pages,
             / 'TRUNCATED:', ls_result-truncated.

    CATCH zcx_milo_validation INTO DATA(lx_validation).
      WRITE: / 'VALIDATION: BLOCKED',
             / 'ERROR CODE:',
               zcl_milo_service=>get_validation_error_code( lx_validation ),
             / 'ERROR TEXT:', lx_validation->get_text( ).
    CATCH cx_root INTO DATA(lx_error).
      WRITE: / 'SYSTEM ERROR:', lx_error->get_text( ).
  ENDTRY.
