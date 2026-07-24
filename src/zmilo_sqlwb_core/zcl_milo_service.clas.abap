CLASS zcl_milo_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES tt_query TYPE zcl_milo_query_repo=>tt_query .
    TYPES tt_log TYPE zcl_milo_log_repo=>tt_log .
    TYPES tt_role  TYPE STANDARD TABLE OF zmilo_role WITH EMPTY KEY.
    TYPES tt_ddic_table TYPE zcl_milo_ddic_browser=>tt_table_info .
    TYPES tt_ddic_field TYPE zcl_milo_ddic_browser=>tt_field_info .
    TYPES:
      BEGIN OF ty_run_result,
        status        TYPE string,
        object_name   TYPE zmilo_obj_name,
        row_count     TYPE i,
        returned_rows TYPE i,
        total_rows    TYPE i,
        max_rows      TYPE i,
        page          TYPE i,
        page_size     TYPE i,
        total_pages   TYPE i,
        truncated     TYPE abap_bool,
        columns_json  TYPE string,
        rows_json     TYPE string,
        csv           TYPE string,
        error_code    TYPE string,
        error_text    TYPE string,
      END OF ty_run_result .

    CLASS-METHODS get_role_profile
      IMPORTING
        !iv_profile_id TYPE zmilo_profile_id
      RETURNING
        VALUE(rs_role) TYPE zmilo_role
      RAISING
        zcx_milo_validation .

    CLASS-METHODS list_user_profiles
      RETURNING
        VALUE(rt_role) TYPE tt_role.

    CLASS-METHODS run_query
      IMPORTING
        !iv_profile_id    TYPE zmilo_profile_id
        !iv_sql           TYPE string
        !iv_page          TYPE i DEFAULT 1
      EXPORTING
        !ev_object_name   TYPE zmilo_obj_name
        !ev_row_count     TYPE i
        !ev_returned_rows TYPE i
        !ev_status        TYPE string
        !ev_max_rows      TYPE i
        !ev_truncated     TYPE abap_bool
        !ev_rows_json     TYPE string
      RAISING
        zcx_milo_validation .

    CLASS-METHODS run_query_result
      IMPORTING
        !iv_profile_id   TYPE zmilo_profile_id
        !iv_sql          TYPE string
        !iv_page         TYPE i DEFAULT 1
      RETURNING
        VALUE(rs_result) TYPE ty_run_result .

    CLASS-METHODS run_saved_query
      IMPORTING
        !iv_profile_id    TYPE zmilo_profile_id
        !iv_query_id      TYPE sysuuid_x16
        !iv_page          TYPE i DEFAULT 1
      EXPORTING
        !ev_object_name   TYPE zmilo_obj_name
        !ev_row_count     TYPE i
        !ev_returned_rows TYPE i
        !ev_status        TYPE string
        !ev_max_rows      TYPE i
        !ev_truncated     TYPE abap_bool
        !ev_rows_json     TYPE string
      RAISING
        zcx_milo_validation .

    CLASS-METHODS run_saved_query_result
      IMPORTING
        !iv_profile_id   TYPE zmilo_profile_id
        !iv_query_id     TYPE sysuuid_x16
        !iv_page         TYPE i DEFAULT 1
      RETURNING
        VALUE(rs_result) TYPE ty_run_result .

    CLASS-METHODS save_query
      IMPORTING
        !iv_profile_id     TYPE zmilo_profile_id
        !iv_query_name     TYPE zmilo_query_name
        !iv_query_text     TYPE string
        !iv_visibility     TYPE zmilo_visibility OPTIONAL
        !iv_tags           TYPE zmilo_tags OPTIONAL
        !iv_description    TYPE zmilo_description OPTIONAL
      RETURNING
        VALUE(rv_query_id) TYPE sysuuid_x16
      RAISING
        zcx_milo_validation .

    CLASS-METHODS update_query
      IMPORTING
        !iv_profile_id  TYPE zmilo_profile_id
        !iv_query_id    TYPE sysuuid_x16
        !iv_query_name  TYPE zmilo_query_name
        !iv_query_text  TYPE string
        !iv_visibility  TYPE zmilo_visibility OPTIONAL
        !iv_tags        TYPE zmilo_tags OPTIONAL
        !iv_description TYPE zmilo_description OPTIONAL
      RAISING
        zcx_milo_validation .

    CLASS-METHODS delete_query
      IMPORTING
        !iv_profile_id TYPE zmilo_profile_id
        !iv_query_id   TYPE sysuuid_x16
      RAISING
        zcx_milo_validation .

    CLASS-METHODS list_queries
      IMPORTING
        !iv_profile_id  TYPE zmilo_profile_id
        !iv_owner_only  TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rt_query) TYPE tt_query
      RAISING
        zcx_milo_validation .

    CLASS-METHODS list_logs
      IMPORTING
        !iv_profile_id TYPE zmilo_profile_id
        !iv_user_only  TYPE abap_bool DEFAULT abap_true
        !iv_status     TYPE zmilo_status OPTIONAL
      RETURNING
        VALUE(rt_log)  TYPE tt_log
      RAISING
        zcx_milo_validation .

    CLASS-METHODS search_ddic_tables
      IMPORTING
        !iv_profile_id  TYPE zmilo_profile_id
        !iv_search      TYPE string
        !iv_max_rows    TYPE i DEFAULT 50
      RETURNING
        VALUE(rt_table) TYPE tt_ddic_table
      RAISING
        zcx_milo_validation .

    CLASS-METHODS get_ddic_fields
      IMPORTING
        !iv_profile_id  TYPE zmilo_profile_id
        !iv_obj_name    TYPE zmilo_obj_name
      RETURNING
        VALUE(rt_field) TYPE tt_ddic_field
      RAISING
        zcx_milo_validation .

    CLASS-METHODS build_result_columns
      IMPORTING
        !iv_profile_id   TYPE zmilo_profile_id
        !iv_sql          TYPE string
        !iv_result_id    TYPE sysuuid_x16 OPTIONAL
      RETURNING
        VALUE(rt_column) TYPE zcl_milo_result_repo=>tt_column
      RAISING
        zcx_milo_validation .

    CLASS-METHODS preview_table
      IMPORTING
        !iv_profile_id  TYPE zmilo_profile_id
        !iv_obj_name    TYPE zmilo_obj_name
        !iv_row_limit   TYPE i DEFAULT 100
        !iv_page        TYPE i DEFAULT 1
      EXPORTING
        !ev_object_name TYPE zmilo_obj_name
        !ev_row_count   TYPE i
        !ev_total_rows  TYPE i
        !ev_rows_json   TYPE string
      RAISING
        zcx_milo_validation .

    CLASS-METHODS preview_table_csv
      IMPORTING
        !iv_profile_id  TYPE zmilo_profile_id
        !iv_obj_name    TYPE zmilo_obj_name
        !iv_row_limit   TYPE i DEFAULT 100
        !iv_page        TYPE i DEFAULT 1
      EXPORTING
        !ev_object_name TYPE zmilo_obj_name
        !ev_row_count   TYPE i
        !ev_total_rows  TYPE i
        !ev_csv         TYPE string
      RAISING
        zcx_milo_validation .

    CLASS-METHODS preview_table_result
      IMPORTING
        !iv_profile_id   TYPE zmilo_profile_id
        !iv_obj_name     TYPE zmilo_obj_name
        !iv_row_limit    TYPE i DEFAULT 100
        !iv_page         TYPE i DEFAULT 1
      RETURNING
        VALUE(rs_result) TYPE ty_run_result .

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS get_active_role
      IMPORTING
        iv_profile_id  TYPE zmilo_profile_id
      RETURNING
        VALUE(rs_role) TYPE zmilo_role
      RAISING
        zcx_milo_validation.

    CLASS-METHODS raise_not_allowed
      IMPORTING
        iv_object_name TYPE zmilo_obj_name
      RAISING
        zcx_milo_validation.

    CLASS-METHODS assert_user_has_pfcg_role
      IMPORTING
        is_role TYPE zmilo_role
      RAISING
        zcx_milo_validation.

    CLASS-METHODS get_validation_error_code
      IMPORTING
        ix_validation        TYPE REF TO zcx_milo_validation
      RETURNING
        VALUE(rv_error_code) TYPE string.

    CLASS-METHODS get_columns_json
      IMPORTING
        iv_profile_id  TYPE zmilo_profile_id
        iv_obj_name    TYPE zmilo_obj_name
      RETURNING
        VALUE(rv_json) TYPE string
      RAISING
        zcx_milo_validation.

ENDCLASS.



CLASS ZCL_MILO_SERVICE IMPLEMENTATION.


  METHOD assert_user_has_pfcg_role.

    DATA lv_object_name TYPE zmilo_obj_name.

    lv_object_name = is_role-profile_id.

    IF is_role-pfcg_role IS INITIAL.
      raise_not_allowed( lv_object_name ).
    ENDIF.

    SELECT SINGLE agr_name
      FROM agr_users
      WHERE uname    = @sy-uname
        AND agr_name = @is_role-pfcg_role
        AND from_dat <= @sy-datum
        AND to_dat   >= @sy-datum
      INTO @DATA(lv_pfcg_role).

    IF sy-subrc <> 0.
      raise_not_allowed( lv_object_name ).
    ENDIF.

  ENDMETHOD.


  METHOD build_result_columns.

    DATA ls_parts TYPE zcl_milo_sql_parser=>ty_query_parts.
    DATA lt_field TYPE tt_ddic_field.
    DATA lv_field_count TYPE i.
    DATA lv_column_position TYPE i.
    DATA lv_source_object TYPE zmilo_obj_name.
    DATA lv_output_field TYPE zmilo_field_name.

    CLEAR rt_column.

    ls_parts = zcl_milo_sql_parser=>parse( iv_sql ).

    IF ls_parts-is_join = abap_true.

      LOOP AT ls_parts-fields INTO DATA(ls_join_field).

        IF ls_join_field-is_aggregate = abap_true.

          lv_column_position = lv_column_position + 1.
          lv_output_field = to_upper( ls_join_field-output_key ).

          APPEND INITIAL LINE TO rt_column ASSIGNING FIELD-SYMBOL(<ls_join_agg_column>).
          <ls_join_agg_column>-result_id       = iv_result_id.
          <ls_join_agg_column>-column_position = lv_column_position.
          <ls_join_agg_column>-field_name      = lv_output_field.
          <ls_join_agg_column>-json_key        = ls_join_field-output_key.
          <ls_join_agg_column>-element         = ''.
          IF ls_join_field-agg_func = 'COUNT'.
            <ls_join_agg_column>-abap_type = 'INT4'.
            <ls_join_agg_column>-length    = 10.
          ELSEIF ls_join_field-agg_func = 'AVG'.
            <ls_join_agg_column>-abap_type = 'DF34_DEC'.
            <ls_join_agg_column>-length    = 34.
          ELSE.
            <ls_join_agg_column>-abap_type = ls_join_field-agg_func.
            <ls_join_agg_column>-length    = 34.
          ENDIF.
          <ls_join_agg_column>-decimals     = 0.
          <ls_join_agg_column>-is_key       = ''.
          <ls_join_agg_column>-column_label = lv_output_field.
          <ls_join_agg_column>-origin_type  = 'CALCULATED'.

          CONTINUE.

        ENDIF.

        lv_source_object = ''.

        LOOP AT ls_parts-sources INTO DATA(ls_source).
          IF ls_source-alias = ls_join_field-source_alias.
            lv_source_object = ls_source-object_name.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lv_source_object IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid = zcx_milo_validation=>invalid_field.
        ENDIF.

        lt_field = get_ddic_fields(
          iv_profile_id = iv_profile_id
          iv_obj_name   = lv_source_object ).

        READ TABLE lt_field INTO DATA(ls_join_ddic_field)
          WITH KEY fieldname = ls_join_field-field_name.

        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>invalid_field
              mv_field_name = ls_join_field-field_name.
        ENDIF.

        lv_column_position = lv_column_position + 1.
        lv_output_field = to_upper( ls_join_field-output_key ).

        APPEND INITIAL LINE TO rt_column ASSIGNING FIELD-SYMBOL(<ls_join_column>).
        <ls_join_column>-result_id       = iv_result_id.
        <ls_join_column>-column_position = lv_column_position.
        <ls_join_column>-field_name      = lv_output_field.
        <ls_join_column>-json_key        = ls_join_field-output_key.
        <ls_join_column>-element         = ls_join_ddic_field-rollname.
        <ls_join_column>-abap_type       = ls_join_ddic_field-datatype.
        <ls_join_column>-length          = ls_join_ddic_field-leng.
        <ls_join_column>-decimals        = ls_join_ddic_field-decimals.
        <ls_join_column>-is_key          = ls_join_ddic_field-keyflag.
        <ls_join_column>-column_label    = ls_join_ddic_field-ddtext.
        <ls_join_column>-origin_type      = ls_join_ddic_field-origin_type.
        <ls_join_column>-origin_structure = ls_join_ddic_field-origin_structure.
        <ls_join_column>-include_depth    = ls_join_ddic_field-include_depth.


      ENDLOOP.

      RETURN.

    ENDIF.

    lt_field = get_ddic_fields(
      iv_profile_id = iv_profile_id
      iv_obj_name   = ls_parts-table_name ).

    IF ls_parts-columns = '*'.

      LOOP AT lt_field INTO DATA(ls_star_field).
        lv_field_count = lv_field_count + 1.
        IF lv_field_count > zcl_milo_config=>c_max_select_fields.
          EXIT.
        ENDIF.

        APPEND INITIAL LINE TO rt_column ASSIGNING FIELD-SYMBOL(<ls_star_column>).
        <ls_star_column>-result_id       = iv_result_id.
        <ls_star_column>-column_position = ls_star_field-position.
        <ls_star_column>-field_name      = ls_star_field-fieldname.
        <ls_star_column>-json_key        = to_lower( ls_star_field-fieldname ).
        <ls_star_column>-element         = ls_star_field-rollname.
        <ls_star_column>-abap_type       = ls_star_field-datatype.
        <ls_star_column>-length          = ls_star_field-leng.
        <ls_star_column>-decimals        = ls_star_field-decimals.
        <ls_star_column>-is_key          = ls_star_field-keyflag.
        <ls_star_column>-column_label    = ls_star_field-ddtext.
        <ls_star_column>-origin_type      = ls_star_field-origin_type.
        <ls_star_column>-origin_structure = ls_star_field-origin_structure.
        <ls_star_column>-include_depth    = ls_star_field-include_depth.

      ENDLOOP.

    ELSE.

      LOOP AT ls_parts-fields INTO DATA(ls_single_field).

        IF ls_single_field-is_aggregate = abap_true.

          lv_column_position = lv_column_position + 1.
          lv_output_field = to_upper( ls_single_field-output_key ).

          APPEND INITIAL LINE TO rt_column ASSIGNING FIELD-SYMBOL(<ls_single_agg_column>).
          <ls_single_agg_column>-result_id       = iv_result_id.
          <ls_single_agg_column>-column_position = lv_column_position.
          <ls_single_agg_column>-field_name      = lv_output_field.
          <ls_single_agg_column>-json_key        = ls_single_field-output_key.
          <ls_single_agg_column>-element         = ''.
          IF ls_single_field-agg_func = 'COUNT'.
            <ls_single_agg_column>-abap_type = 'INT4'.
            <ls_single_agg_column>-length    = 10.
          ELSEIF ls_single_field-agg_func = 'AVG'.
            <ls_single_agg_column>-abap_type = 'DF34_DEC'.
            <ls_single_agg_column>-length    = 34.
          ELSE.
            <ls_single_agg_column>-abap_type = ls_single_field-agg_func.
            <ls_single_agg_column>-length    = 34.
          ENDIF.
          <ls_single_agg_column>-decimals     = 0.
          <ls_single_agg_column>-is_key       = ''.
          <ls_single_agg_column>-column_label = lv_output_field.
          <ls_single_agg_column>-origin_type  = 'CALCULATED'.

          CONTINUE.

        ENDIF.

        READ TABLE lt_field INTO DATA(ls_single_ddic_field)
          WITH KEY fieldname = ls_single_field-field_name.

        IF sy-subrc = 0.
          APPEND INITIAL LINE TO rt_column ASSIGNING FIELD-SYMBOL(<ls_single_column>).
          <ls_single_column>-result_id       = iv_result_id.
          <ls_single_column>-column_position = ls_single_ddic_field-position.
          <ls_single_column>-field_name      = ls_single_ddic_field-fieldname.
          <ls_single_column>-json_key        = to_lower( ls_single_ddic_field-fieldname ).
          <ls_single_column>-element         = ls_single_ddic_field-rollname.
          <ls_single_column>-abap_type       = ls_single_ddic_field-datatype.
          <ls_single_column>-length          = ls_single_ddic_field-leng.
          <ls_single_column>-decimals        = ls_single_ddic_field-decimals.
          <ls_single_column>-is_key          = ls_single_ddic_field-keyflag.
          <ls_single_column>-column_label    = ls_single_ddic_field-ddtext.
          <ls_single_column>-origin_type      = ls_single_ddic_field-origin_type.
          <ls_single_column>-origin_structure = ls_single_ddic_field-origin_structure.
          <ls_single_column>-include_depth    = ls_single_ddic_field-include_depth.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD get_active_role.

    rs_role = zcl_milo_config=>get_role_config( iv_profile_id ).

    IF rs_role-profile_id IS INITIAL.
      DATA lv_object_name TYPE zmilo_obj_name.
      lv_object_name = iv_profile_id.
      raise_not_allowed( lv_object_name ).
    ENDIF.

    assert_user_has_pfcg_role( rs_role ).

  ENDMETHOD.


  METHOD get_columns_json.

    DATA lt_field TYPE tt_ddic_field.

    IF iv_obj_name IS INITIAL.
      rv_json = '[]'.
      RETURN.
    ENDIF.

    lt_field = get_ddic_fields(
      iv_profile_id = iv_profile_id
      iv_obj_name   = iv_obj_name ).

    rv_json = zcl_milo_serializer=>fields_to_json( lt_field ).

  ENDMETHOD.


  METHOD get_ddic_fields.

    DATA ls_role TYPE zmilo_role.
    DATA lv_obj_name TYPE zmilo_obj_name.

    ls_role = get_active_role( iv_profile_id ).
    lv_obj_name = to_upper( iv_obj_name ).

    IF zcl_milo_config=>is_object_allowed(
         iv_wlist_profile_id = ls_role-wlist_profile_id
         iv_obj_name         = lv_obj_name ) <> abap_true.
      raise_not_allowed( lv_obj_name ).
    ENDIF.

    rt_field = zcl_milo_ddic_browser=>get_fields( lv_obj_name ).

  ENDMETHOD.


  METHOD get_role_profile.

    rs_role = get_active_role( iv_profile_id ).

  ENDMETHOD.


  METHOD get_validation_error_code.

    DATA ls_t100key TYPE scx_t100key.

    rv_error_code = 'VALIDATION_ERROR'.

    IF ix_validation IS NOT BOUND.
      RETURN.
    ENDIF.

    ls_t100key = ix_validation->if_t100_message~t100key.

    IF ls_t100key = zcx_milo_validation=>empty_sql.
      rv_error_code = 'EMPTY_SQL'.
    ELSEIF ls_t100key = zcx_milo_validation=>only_select_allowed.
      rv_error_code = 'ONLY_SELECT_ALLOWED'.
    ELSEIF ls_t100key = zcx_milo_validation=>forbidden_syntax.
      rv_error_code = 'FORBIDDEN_SYNTAX'.
    ELSEIF ls_t100key = zcx_milo_validation=>forbidden_keyword.
      rv_error_code = 'FORBIDDEN_KEYWORD'.
    ELSEIF ls_t100key = zcx_milo_validation=>parse_failed.
      rv_error_code = 'PARSE_FAILED'.
    ELSEIF ls_t100key = zcx_milo_validation=>object_not_allowed.
      rv_error_code = 'OBJECT_NOT_ALLOWED'.
    ELSEIF ls_t100key = zcx_milo_validation=>invalid_field.
      rv_error_code = 'INVALID_FIELD'.
    ELSEIF ls_t100key = zcx_milo_validation=>invalid_where.
      rv_error_code = 'INVALID_WHERE'.
    ELSEIF ls_t100key = zcx_milo_validation=>invalid_order_by.
      rv_error_code = 'INVALID_ORDER_BY'.
    ENDIF.

  ENDMETHOD.


  METHOD list_logs.

    DATA ls_role TYPE zmilo_role.

    ls_role = get_active_role( iv_profile_id ).

    rt_log = zcl_milo_log_repo=>list_logs(
      iv_user_only = abap_true
      iv_status    = iv_status ).

  ENDMETHOD.


  METHOD list_queries.

    DATA ls_role TYPE zmilo_role.

    ls_role = get_active_role( iv_profile_id ).

    rt_query = zcl_milo_query_repo=>list_queries(
      iv_profile_id = iv_profile_id
      iv_owner_only = iv_owner_only
      iv_allow_all  = abap_false ).

  ENDMETHOD.


  METHOD preview_table.

    DATA ls_role TYPE zmilo_role.
    DATA lv_start TYPE timestampl.
    DATA lv_end TYPE timestampl.
    DATA lv_dur TYPE i.
    DATA lv_row_limit_eff TYPE i.
    DATA lv_log_text TYPE string.
    DATA lv_log_obj TYPE zmilo_obj_name.

    CLEAR: ev_object_name,
           ev_row_count,
           ev_total_rows,
           ev_rows_json.

    GET TIME STAMP FIELD lv_start.
    lv_log_obj = to_upper( iv_obj_name ).
    lv_log_text = |PREVIEW { lv_log_obj }|.

    lv_row_limit_eff = iv_row_limit.
    IF lv_row_limit_eff IS INITIAL OR lv_row_limit_eff > 100.
      lv_row_limit_eff = 100.
    ENDIF.

    TRY.
        ls_role = get_active_role( iv_profile_id ).

        zcl_milo_ddic_browser=>preview_table(
          EXPORTING
            iv_wlist_profile_id = ls_role-wlist_profile_id
            iv_mask_profile_id  = ls_role-mask_profile_id
            iv_obj_name         = iv_obj_name
            iv_row_limit        = iv_row_limit
            iv_page             = iv_page
          IMPORTING
            ev_object_name      = ev_object_name
            ev_row_count        = ev_row_count
            ev_total_rows       = ev_total_rows
            ev_rows_json        = ev_rows_json ).

        GET TIME STAMP FIELD lv_end.
        lv_dur = cl_abap_tstmp=>subtract(
          tstmp1 = lv_end
          tstmp2 = lv_start ) * 1000.

        zcl_milo_logger=>log_execution(
          iv_sql_text      = lv_log_text
          iv_status        = 'SUCCESS'
          iv_exec_mode     = 'PREVIEW'
          iv_source_obj    = ev_object_name
          iv_row_count     = ev_row_count
          iv_row_limit_req = iv_row_limit
          iv_row_limit_eff = lv_row_limit_eff
          iv_truncated     = xsdbool( ev_total_rows > ev_row_count )
          iv_duration_ms   = lv_dur
          iv_result_bytes  = strlen( ev_rows_json ) ).

      CATCH zcx_milo_validation INTO DATA(lx_validation).
        GET TIME STAMP FIELD lv_end.
        lv_dur = cl_abap_tstmp=>subtract(
          tstmp1 = lv_end
          tstmp2 = lv_start ) * 1000.

        zcl_milo_logger=>log_execution(
          iv_sql_text      = lv_log_text
          iv_status        = 'BLOCKED'
          iv_exec_mode     = 'PREVIEW'
          iv_source_obj    = lv_log_obj
          iv_row_count     = 0
          iv_row_limit_req = iv_row_limit
          iv_row_limit_eff = lv_row_limit_eff
          iv_truncated     = abap_false
          iv_duration_ms   = lv_dur
          iv_result_bytes  = 0
          iv_error_text    = lx_validation->get_text( ) ).

        RAISE EXCEPTION lx_validation.
    ENDTRY.

  ENDMETHOD.


  METHOD preview_table_csv.

    DATA ls_role TYPE zmilo_role.
    DATA lv_start TYPE timestampl.
    DATA lv_end TYPE timestampl.
    DATA lv_dur TYPE i.
    DATA lv_row_limit_eff TYPE i.
    DATA lv_log_text TYPE string.
    DATA lv_log_obj TYPE zmilo_obj_name.

    CLEAR: ev_object_name,
           ev_row_count,
           ev_total_rows,
           ev_csv.

    GET TIME STAMP FIELD lv_start.
    lv_log_obj = to_upper( iv_obj_name ).
    lv_log_text = |EXPORT { lv_log_obj }|.

    lv_row_limit_eff = iv_row_limit.
    IF lv_row_limit_eff IS INITIAL OR lv_row_limit_eff > 100.
      lv_row_limit_eff = 100.
    ENDIF.

    TRY.
        ls_role = get_active_role( iv_profile_id ).

        zcl_milo_ddic_browser=>preview_table_csv(
          EXPORTING
            iv_wlist_profile_id = ls_role-wlist_profile_id
            iv_mask_profile_id  = ls_role-mask_profile_id
            iv_obj_name         = iv_obj_name
            iv_row_limit        = iv_row_limit
            iv_page             = iv_page
          IMPORTING
            ev_object_name      = ev_object_name
            ev_row_count        = ev_row_count
            ev_total_rows       = ev_total_rows
            ev_csv              = ev_csv ).

        GET TIME STAMP FIELD lv_end.
        lv_dur = cl_abap_tstmp=>subtract(
          tstmp1 = lv_end
          tstmp2 = lv_start ) * 1000.

        zcl_milo_logger=>log_execution(
          iv_sql_text      = lv_log_text
          iv_status        = 'SUCCESS'
          iv_exec_mode     = 'EXPORT'
          iv_source_obj    = ev_object_name
          iv_row_count     = ev_row_count
          iv_row_limit_req = iv_row_limit
          iv_row_limit_eff = lv_row_limit_eff
          iv_truncated     = xsdbool( ev_total_rows > ev_row_count )
          iv_duration_ms   = lv_dur
          iv_result_bytes  = strlen( ev_csv ) ).

      CATCH zcx_milo_validation INTO DATA(lx_validation).
        GET TIME STAMP FIELD lv_end.
        lv_dur = cl_abap_tstmp=>subtract(
          tstmp1 = lv_end
          tstmp2 = lv_start ) * 1000.

        zcl_milo_logger=>log_execution(
          iv_sql_text      = lv_log_text
          iv_status        = 'BLOCKED'
          iv_exec_mode     = 'EXPORT'
          iv_source_obj    = lv_log_obj
          iv_row_count     = 0
          iv_row_limit_req = iv_row_limit
          iv_row_limit_eff = lv_row_limit_eff
          iv_truncated     = abap_false
          iv_duration_ms   = lv_dur
          iv_result_bytes  = 0
          iv_error_text    = lx_validation->get_text( ) ).

        RAISE EXCEPTION lx_validation.
    ENDTRY.

  ENDMETHOD.


  METHOD preview_table_result.

    DATA lv_page_size TYPE i.
    DATA lv_page TYPE i.

    CLEAR rs_result.

    TRY.
        preview_table(
          EXPORTING
            iv_profile_id  = iv_profile_id
            iv_obj_name    = iv_obj_name
            iv_row_limit   = iv_row_limit
            iv_page        = iv_page
          IMPORTING
            ev_object_name = rs_result-object_name
            ev_row_count   = rs_result-row_count
            ev_total_rows  = rs_result-total_rows
            ev_rows_json   = rs_result-rows_json ).

        preview_table_csv(
          EXPORTING
            iv_profile_id  = iv_profile_id
            iv_obj_name    = iv_obj_name
            iv_row_limit   = iv_row_limit
            iv_page        = iv_page
          IMPORTING
            ev_csv         = rs_result-csv ).

        rs_result-status = 'SUCCESS'.
        rs_result-returned_rows = rs_result-row_count.
        lv_page_size = iv_row_limit.
        IF lv_page_size IS INITIAL OR lv_page_size > 100.
          lv_page_size = 100.
        ENDIF.
        lv_page = iv_page.
        IF lv_page IS INITIAL OR lv_page < 1.
          lv_page = 1.
        ENDIF.
        rs_result-max_rows = lv_page_size.
        rs_result-page = lv_page.
        rs_result-page_size = lv_page_size.
        IF rs_result-page_size > 0.
          rs_result-total_pages = rs_result-total_rows DIV rs_result-page_size.
          IF rs_result-total_rows MOD rs_result-page_size <> 0.
            rs_result-total_pages = rs_result-total_pages + 1.
          ENDIF.
        ENDIF.
        rs_result-truncated = xsdbool( rs_result-total_rows > rs_result-returned_rows ).
        DATA(lt_field) = get_ddic_fields(
          iv_profile_id = iv_profile_id
          iv_obj_name   = rs_result-object_name ).

        DATA(lt_result_field) = lt_field.

        CLEAR lt_result_field.

        DATA(lv_field_count) = 0.

        LOOP AT lt_field INTO DATA(ls_star_field).
          lv_field_count = lv_field_count + 1.
          IF lv_field_count > zcl_milo_config=>c_max_select_fields.
            EXIT.
          ENDIF.
          APPEND ls_star_field TO lt_result_field.
        ENDLOOP.

        rs_result-columns_json = zcl_milo_serializer=>fields_to_json( lt_result_field ).

      CATCH zcx_milo_validation INTO DATA(lx_validation).
        rs_result-status = 'BLOCKED'.
        rs_result-object_name = to_upper( iv_obj_name ).
        rs_result-error_code = get_validation_error_code( lx_validation ).
        rs_result-error_text = lx_validation->get_text( ).

      CATCH cx_root INTO DATA(lx_error).
        rs_result-status = 'ERROR'.
        rs_result-object_name = to_upper( iv_obj_name ).
        rs_result-error_code = 'SYSTEM_ERROR'.
        rs_result-error_text = lx_error->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD raise_not_allowed.

    RAISE EXCEPTION TYPE zcx_milo_validation
      EXPORTING
        textid         = zcx_milo_validation=>object_not_allowed
        mv_object_name = iv_object_name.

  ENDMETHOD.


  METHOD run_query.

    DATA ls_role TYPE zmilo_role.

    CLEAR: ev_object_name,
           ev_row_count,
           ev_returned_rows,
           ev_status,
           ev_max_rows,
           ev_truncated,
           ev_rows_json.

    ls_role = get_active_role( iv_profile_id ).

    zcl_milo_executor=>execute_select(
      EXPORTING
        iv_sql              = iv_sql
        iv_wlist_profile_id = ls_role-wlist_profile_id
        iv_mask_profile_id  = ls_role-mask_profile_id
        iv_page             = iv_page
      IMPORTING
        ev_object_name      = ev_object_name
        ev_row_count        = ev_row_count
        ev_returned_rows    = ev_returned_rows
        ev_status           = ev_status
        ev_max_rows         = ev_max_rows
        ev_truncated        = ev_truncated
        ev_rows_json        = ev_rows_json ).

  ENDMETHOD.


  METHOD run_query_result.

    DATA lv_page TYPE i.

    CLEAR rs_result.

    TRY.
        run_query(
          EXPORTING
            iv_profile_id  = iv_profile_id
            iv_sql         = iv_sql
            iv_page        = iv_page
          IMPORTING
            ev_object_name = rs_result-object_name
            ev_row_count   = rs_result-row_count
            ev_returned_rows = rs_result-returned_rows
            ev_status      = rs_result-status
            ev_max_rows    = rs_result-max_rows
            ev_truncated   = rs_result-truncated
            ev_rows_json   = rs_result-rows_json ).

        rs_result-total_rows = rs_result-row_count.
        lv_page = iv_page.
        IF lv_page IS INITIAL OR lv_page < 1.
          lv_page = 1.
        ENDIF.
        rs_result-page = lv_page.
        rs_result-page_size = rs_result-max_rows.
        IF rs_result-page_size > 0.
          rs_result-total_pages = rs_result-total_rows DIV rs_result-page_size.
          IF rs_result-total_rows MOD rs_result-page_size <> 0.
            rs_result-total_pages = rs_result-total_pages + 1.
          ENDIF.
        ENDIF.

        IF rs_result-status <> 'SUCCESS'.
          IF rs_result-status = 'ERROR'.
            rs_result-error_code = 'SYSTEM_ERROR'.
            rs_result-error_text = rs_result-rows_json.
            CLEAR rs_result-rows_json.
          ENDIF.
          RETURN.
        ENDIF.

        DATA(lt_query_column) = build_result_columns(
          iv_profile_id = iv_profile_id
          iv_sql        = iv_sql ).

        rs_result-columns_json = zcl_milo_serializer=>result_columns_to_json( lt_query_column ).

      CATCH zcx_milo_validation INTO DATA(lx_validation).
        rs_result-status = 'BLOCKED'.
        rs_result-error_code = get_validation_error_code( lx_validation ).
        rs_result-error_text = lx_validation->get_text( ).

      CATCH cx_root INTO DATA(lx_error).
        rs_result-status = 'ERROR'.
        rs_result-error_code = 'SYSTEM_ERROR'.
        rs_result-error_text = lx_error->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD run_saved_query.

    DATA ls_role TYPE zmilo_role.

    CLEAR: ev_object_name,
           ev_row_count,
           ev_returned_rows,
           ev_status,
           ev_max_rows,
           ev_truncated,
           ev_rows_json.

    ls_role = get_active_role( iv_profile_id ).

    zcl_milo_executor=>execute_saved_query(
      EXPORTING
        iv_query_id         = iv_query_id
        iv_profile_id       = iv_profile_id
        iv_wlist_profile_id = ls_role-wlist_profile_id
        iv_mask_profile_id  = ls_role-mask_profile_id
        iv_page             = iv_page
      IMPORTING
        ev_object_name      = ev_object_name
        ev_row_count        = ev_row_count
        ev_returned_rows    = ev_returned_rows
        ev_status           = ev_status
        ev_max_rows         = ev_max_rows
        ev_truncated        = ev_truncated
        ev_rows_json        = ev_rows_json ).

  ENDMETHOD.


  METHOD run_saved_query_result.

    DATA lv_page TYPE i.

    CLEAR rs_result.
    lv_page = iv_page.
    IF lv_page IS INITIAL OR lv_page < 1.
      lv_page = 1.
    ENDIF.

    TRY.
        run_saved_query(
          EXPORTING
            iv_profile_id  = iv_profile_id
            iv_query_id    = iv_query_id
            iv_page        = lv_page
          IMPORTING
            ev_object_name   = rs_result-object_name
            ev_row_count     = rs_result-row_count
            ev_returned_rows = rs_result-returned_rows
            ev_status        = rs_result-status
            ev_max_rows      = rs_result-max_rows
            ev_truncated     = rs_result-truncated
            ev_rows_json     = rs_result-rows_json ).

        rs_result-total_rows = rs_result-row_count.
        rs_result-page = lv_page.
        rs_result-page_size = rs_result-max_rows.
        IF rs_result-page_size > 0.
          rs_result-total_pages = rs_result-total_rows DIV rs_result-page_size.
          IF rs_result-total_rows MOD rs_result-page_size <> 0.
            rs_result-total_pages = rs_result-total_pages + 1.
          ENDIF.
        ENDIF.

        rs_result-columns_json = get_columns_json(
          iv_profile_id = iv_profile_id
          iv_obj_name   = rs_result-object_name ).

      CATCH zcx_milo_validation INTO DATA(lx_validation).
        rs_result-status = 'BLOCKED'.
        rs_result-error_code = get_validation_error_code( lx_validation ).
        rs_result-error_text = lx_validation->get_text( ).

      CATCH cx_root INTO DATA(lx_error).
        rs_result-status = 'ERROR'.
        rs_result-error_code = 'SYSTEM_ERROR'.
        rs_result-error_text = lx_error->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD save_query.

    DATA ls_role TYPE zmilo_role.
    DATA lv_visibility TYPE zmilo_visibility.

    ls_role = get_active_role( iv_profile_id ).

    lv_visibility = to_upper( condense( iv_visibility ) ).

    IF lv_visibility = 'PROFILE' OR lv_visibility = 'SHARED'.
      lv_visibility = 'PROFILE'.
    ELSE.
      lv_visibility = 'PRIVATE'.
    ENDIF.

    rv_query_id = zcl_milo_query_repo=>save_query(
      iv_query_name       = iv_query_name
      iv_query_text       = iv_query_text
      iv_visibility       = lv_visibility
      iv_profile_id       = iv_profile_id
      iv_tags             = iv_tags
      iv_description      = iv_description ).

  ENDMETHOD.


  METHOD search_ddic_tables.

    DATA ls_role TYPE zmilo_role.
    DATA lv_pattern TYPE string.
    DATA lv_max_rows TYPE i.

    ls_role = get_active_role( iv_profile_id ).

    lv_pattern = to_upper( condense( iv_search ) ).
    IF lv_pattern IS INITIAL.
      lv_pattern = '%'.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '*' IN lv_pattern WITH '%'.

    IF lv_pattern NS '%'.
      lv_pattern = '%' && lv_pattern && '%'.
    ENDIF.

    lv_max_rows = iv_max_rows.
    IF lv_max_rows IS INITIAL OR lv_max_rows > 200.
      lv_max_rows = 50.
    ENDIF.

    SELECT w~obj_name AS tabname,
           l~tabclass,
           t~ddtext
      FROM zmilo_wlist AS w
      INNER JOIN dd02l AS l
        ON l~tabname = w~obj_name
      LEFT OUTER JOIN dd02t AS t
        ON  t~tabname    = w~obj_name
        AND t~ddlanguage = @sy-langu
        AND t~as4local   = 'A'
      WHERE w~wlist_profile_id = @ls_role-wlist_profile_id
        AND w~is_active        = 'X'
        AND l~as4local         = 'A'
        AND ( l~tabclass = 'TRANSP'
           OR l~tabclass = 'VIEW' )
        AND ( w~obj_name LIKE @lv_pattern
           OR t~ddtext   LIKE @lv_pattern )
      ORDER BY w~obj_name
      INTO CORRESPONDING FIELDS OF TABLE @rt_table
      UP TO @lv_max_rows ROWS.

  ENDMETHOD.


  METHOD delete_query.

    DATA ls_role TYPE zmilo_role.
    DATA lv_deleted TYPE abap_bool.

    ls_role = get_active_role( iv_profile_id ).

    lv_deleted = zcl_milo_query_repo=>deactivate_query(
      iv_query_id   = iv_query_id
      iv_profile_id = iv_profile_id ).

    IF lv_deleted <> abap_true.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid         = zcx_milo_validation=>object_not_allowed
          mv_object_name = 'SAVED_QUERY'.
    ENDIF.

  ENDMETHOD.


  METHOD update_query.

    DATA ls_role TYPE zmilo_role.
    DATA lv_visibility TYPE zmilo_visibility.
    DATA lv_updated TYPE abap_bool.

    ls_role = get_active_role( iv_profile_id ).

    lv_visibility = to_upper( condense( iv_visibility ) ).
    IF lv_visibility = 'PROFILE' OR lv_visibility = 'SHARED'.
      lv_visibility = 'PROFILE'.
    ELSE.
      lv_visibility = 'PRIVATE'.
    ENDIF.

    lv_updated = zcl_milo_query_repo=>update_query(
      iv_query_id    = iv_query_id
      iv_profile_id  = iv_profile_id
      iv_query_name  = iv_query_name
      iv_query_text  = iv_query_text
      iv_visibility  = lv_visibility
      iv_tags        = iv_tags
      iv_description = iv_description ).

    IF lv_updated <> abap_true.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid         = zcx_milo_validation=>object_not_allowed
          mv_object_name = 'SAVED_QUERY'.
    ENDIF.

  ENDMETHOD.


  METHOD list_user_profiles.

    SELECT config~profile_id,
           config~pfcg_role,
           config~max_rows,
           config~wlist_profile_id,
           config~mask_profile_id,
           config~description,
           config~created_date,
           config~is_active
      FROM zmilo_role AS config
      INNER JOIN agr_users AS assignment
        ON assignment~agr_name = config~pfcg_role
      WHERE config~is_active = 'X'
        AND assignment~uname = @sy-uname
        AND assignment~from_dat <= @sy-datum
        AND assignment~to_dat >= @sy-datum
      ORDER BY config~profile_id,
               config~pfcg_role
      INTO CORRESPONDING FIELDS OF TABLE @rt_role.

    DELETE ADJACENT DUPLICATES FROM rt_role
      COMPARING profile_id.

  ENDMETHOD.
ENDCLASS.
