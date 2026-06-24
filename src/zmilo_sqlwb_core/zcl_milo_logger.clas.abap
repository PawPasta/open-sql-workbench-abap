CLASS zcl_milo_logger DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS log_execution
      IMPORTING
        iv_sql_text      TYPE string
        iv_status        TYPE zmilo_status
        iv_exec_mode     TYPE zmilo_exec_mode
        iv_source_obj    TYPE zmilo_obj_name OPTIONAL
        iv_row_count     TYPE i OPTIONAL
        iv_error_text    TYPE string OPTIONAL
        iv_row_limit_req TYPE i OPTIONAL
        iv_row_limit_eff TYPE i OPTIONAL
        iv_truncated     TYPE abap_bool OPTIONAL
        iv_duration_ms   TYPE i OPTIONAL
        iv_result_bytes  TYPE i OPTIONAL
      RETURNING
        VALUE(rv_log_id) TYPE sysuuid_x16.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MILO_LOGGER IMPLEMENTATION.


  METHOD log_execution.
    DATA ls_log TYPE zmilo_log.

    CLEAR rv_log_id.

    TRY.
        rv_log_id         = cl_system_uuid=>create_uuid_x16_static( ).
        ls_log-request_id = cl_system_uuid=>create_uuid_c36_static( ).
      CATCH cx_uuid_error.
        CLEAR: rv_log_id, ls_log-request_id.
    ENDTRY.

    ls_log-mandt       = sy-mandt.
    ls_log-log_id      = rv_log_id.
    ls_log-user_name   = sy-uname.
    ls_log-created_date = sy-datum.
    ls_log-created_time = sy-uzeit.

    ls_log-status      = iv_status.
    ls_log-exec_mode   = iv_exec_mode.
    ls_log-sql_text    = iv_sql_text.
    ls_log-obj_name    = iv_source_obj.
    ls_log-row_count   = iv_row_count.
    ls_log-error_text  = iv_error_text.

    ls_log-row_limit_req = iv_row_limit_req.
    ls_log-row_limit_eff = iv_row_limit_eff.
    ls_log-truncated     = iv_truncated.
    ls_log-duration_ms  = iv_duration_ms.
    ls_log-result_bytes = iv_result_bytes.

    CASE iv_status.
      WHEN 'BLOCKED'.
        ls_log-error_code = 'VALIDATION'.
      WHEN 'ERROR'.
        ls_log-error_code = 'ERROR'.
      WHEN OTHERS.
        CLEAR ls_log-error_code.
    ENDCASE.

    CLEAR rv_log_id.

    INSERT zmilo_log FROM @ls_log.

    IF sy-subrc <> 0.
      CLEAR rv_log_id.
    ELSE.
      rv_log_id = ls_log-log_id.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
