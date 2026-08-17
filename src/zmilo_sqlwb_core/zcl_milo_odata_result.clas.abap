CLASS zcl_milo_odata_result DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS c_metadata_query   TYPE string VALUE 'QUERY'.
    CONSTANTS c_metadata_preview TYPE string VALUE 'PREVIEW'.

    TYPES:
      BEGIN OF ty_run_response,
        resultid     TYPE string,
        status       TYPE string,
        objectname   TYPE zmilo_obj_name,
        rowcount     TYPE i,
        returnedrows TYPE i,
        totalrows    TYPE i,
        maxrows      TYPE i,
        page         TYPE i,
        pagesize     TYPE i,
        totalpages   TYPE i,
        truncated    TYPE abap_bool,
        errorcode    TYPE string,
        errortext    TYPE string,
      END OF ty_run_response.

    CLASS-METHODS finalize_result
      IMPORTING
        iv_result_id     TYPE sysuuid_x16
        iv_profile_id    TYPE zmilo_profile_id
        iv_metadata_mode TYPE string
      EXPORTING
        es_response      TYPE ty_run_response
      CHANGING
        cs_result        TYPE zcl_milo_service=>ty_run_result.

    CLASS-METHODS initialize_result
      EXPORTING
        ev_result_id TYPE sysuuid_x16
        es_response  TYPE ty_run_response.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS build_preview_columns
      IMPORTING
        iv_result_id     TYPE sysuuid_x16
        iv_profile_id    TYPE zmilo_profile_id
        iv_object_name   TYPE zmilo_obj_name
      RETURNING
        VALUE(rt_column) TYPE zcl_milo_result_repo=>tt_column
      RAISING
        zcx_milo_validation.

    CLASS-METHODS build_head
      IMPORTING
        iv_result_id   TYPE sysuuid_x16
        iv_profile_id  TYPE zmilo_profile_id
        is_result      TYPE zcl_milo_service=>ty_run_result
      RETURNING
        VALUE(rs_head) TYPE zmilo_rhead.

    CLASS-METHODS map_response
      IMPORTING
        iv_result_c32     TYPE string
        is_result         TYPE zcl_milo_service=>ty_run_result
      RETURNING
        VALUE(rs_response) TYPE ty_run_response.

    CLASS-METHODS set_internal_error
      CHANGING
        cs_result TYPE zcl_milo_service=>ty_run_result.

    CLASS-METHODS set_validation_error
      IMPORTING
        ix_validation TYPE REF TO zcx_milo_validation
      CHANGING
        cs_result     TYPE zcl_milo_service=>ty_run_result.

ENDCLASS.



CLASS ZCL_MILO_ODATA_RESULT IMPLEMENTATION.


  METHOD build_head.

    rs_head-result_id     = iv_result_id.
    rs_head-user_name     = sy-uname.
    rs_head-profile_id    = iv_profile_id.
    rs_head-object_name   = is_result-object_name.
    rs_head-status        = is_result-status.
    rs_head-row_count     = is_result-row_count.
    rs_head-returned_rows = is_result-returned_rows.
    rs_head-total_rows    = is_result-total_rows.
    rs_head-max_rows      = is_result-max_rows.
    rs_head-result_page   = is_result-page.
    rs_head-page_size     = is_result-page_size.
    rs_head-total_pages   = is_result-total_pages.
    rs_head-truncated     = is_result-truncated.
    rs_head-error_code    = is_result-error_code.
    rs_head-error_text    = is_result-error_text.
    GET TIME STAMP FIELD rs_head-created_at.

  ENDMETHOD.


  METHOD build_preview_columns.

    DATA(lt_field) = zcl_milo_service=>get_ddic_fields(
      iv_profile_id = iv_profile_id
      iv_obj_name   = iv_object_name ).

    LOOP AT lt_field INTO DATA(ls_field).
      IF sy-tabix > zcl_milo_config=>c_max_select_fields.
        EXIT.
      ENDIF.

      APPEND INITIAL LINE TO rt_column ASSIGNING FIELD-SYMBOL(<ls_column>).
      <ls_column>-result_id        = iv_result_id.
      <ls_column>-column_position  = ls_field-position.
      <ls_column>-field_name       = ls_field-fieldname.
      <ls_column>-json_key         = to_lower( ls_field-fieldname ).
      <ls_column>-element          = ls_field-rollname.
      <ls_column>-abap_type        = ls_field-datatype.
      <ls_column>-length           = ls_field-leng.
      <ls_column>-decimals         = ls_field-decimals.
      <ls_column>-is_key           = ls_field-keyflag.
      <ls_column>-column_label     = ls_field-ddtext.
      <ls_column>-origin_type      = ls_field-origin_type.
      <ls_column>-origin_structure = ls_field-origin_structure.
      <ls_column>-include_depth    = ls_field-include_depth.
    ENDLOOP.

  ENDMETHOD.


  METHOD finalize_result.

    DATA lt_column     TYPE zcl_milo_result_repo=>tt_column.
    DATA lt_page       TYPE zcl_milo_result_repo=>tt_page.
    DATA lv_result_c32 TYPE string.
    DATA lv_saved      TYPE abap_bool.

    CLEAR es_response.
    lv_result_c32 = zcl_milo_result_repo=>result_id_to_c32( iv_result_id ).

    IF cs_result-status = 'SUCCESS'.
      TRY.
          CASE iv_metadata_mode.
            WHEN c_metadata_query.
              lt_column = zcl_milo_service=>build_result_columns(
                iv_profile_id = iv_profile_id
                iv_result_id  = iv_result_id
                is_parts      = cs_result-query_parts ).
            WHEN c_metadata_preview.
              lt_column = build_preview_columns(
                iv_result_id   = iv_result_id
                iv_profile_id  = iv_profile_id
                iv_object_name = cs_result-object_name ).
            WHEN OTHERS.
              set_internal_error( CHANGING cs_result = cs_result ).
          ENDCASE.

          IF cs_result-status = 'SUCCESS'.
            lt_page = zcl_milo_result_repo=>build_page_chunks(
              iv_result_id = iv_result_id
              iv_page_no   = cs_result-page
              iv_rows_json = cs_result-rows_json ).
          ENDIF.

        CATCH zcx_milo_validation INTO DATA(lx_validation).
          CLEAR: lt_column, lt_page.
          set_validation_error(
            EXPORTING
              ix_validation = lx_validation
            CHANGING
              cs_result     = cs_result ).
        CATCH cx_root.
          CLEAR: lt_column, lt_page.
          set_internal_error( CHANGING cs_result = cs_result ).
      ENDTRY.
    ENDIF.

    DATA(ls_head) = build_head(
      iv_result_id  = iv_result_id
      iv_profile_id = iv_profile_id
      is_result     = cs_result ).

    lv_saved = zcl_milo_result_repo=>save_result(
      is_head   = ls_head
      it_column = lt_column
      it_page   = lt_page ).

    IF lv_saved <> abap_true.
      cs_result-status = 'ERROR'.
      cs_result-error_code = 'RESULT_STORAGE_FAILED'.
      cs_result-error_text =
        zcl_milo_error_mapper=>get_safe_technical_text(
          'RESULT_STORAGE_FAILED' ).
      CLEAR lv_result_c32.
    ENDIF.

    es_response = map_response(
      iv_result_c32 = lv_result_c32
      is_result     = cs_result ).

  ENDMETHOD.


  METHOD initialize_result.

    CLEAR: ev_result_id, es_response.
    ev_result_id = zcl_milo_result_repo=>create_result_id( ).

    IF ev_result_id IS INITIAL.
      es_response-status = 'ERROR'.
      es_response-errorcode = 'UUID_GENERATION_FAILED'.
      es_response-errortext =
        zcl_milo_error_mapper=>get_safe_technical_text(
          'UUID_GENERATION_FAILED' ).
    ENDIF.

  ENDMETHOD.


  METHOD map_response.

    rs_response-resultid     = iv_result_c32.
    rs_response-status       = is_result-status.
    rs_response-objectname   = is_result-object_name.
    rs_response-rowcount     = is_result-row_count.
    rs_response-returnedrows = is_result-returned_rows.
    rs_response-totalrows    = is_result-total_rows.
    rs_response-maxrows      = is_result-max_rows.
    rs_response-page         = is_result-page.
    rs_response-pagesize     = is_result-page_size.
    rs_response-totalpages   = is_result-total_pages.
    rs_response-truncated    = is_result-truncated.
    rs_response-errorcode    = is_result-error_code.
    rs_response-errortext    = is_result-error_text.

  ENDMETHOD.


  METHOD set_internal_error.

    cs_result-status = 'ERROR'.
    cs_result-error_code = 'INTERNAL_ERROR'.
    cs_result-error_text =
      zcl_milo_error_mapper=>get_safe_technical_text(
        'INTERNAL_ERROR' ).

  ENDMETHOD.


  METHOD set_validation_error.

    cs_result-error_code =
      zcl_milo_service=>get_validation_error_code( ix_validation ).

    IF zcl_milo_error_mapper=>is_technical_error_code(
         cs_result-error_code ) = abap_true.
      cs_result-status = 'ERROR'.
      cs_result-error_text =
        zcl_milo_error_mapper=>get_safe_technical_text(
          cs_result-error_code ).
    ELSE.
      cs_result-status = 'BLOCKED'.
      cs_result-error_text = ix_validation->get_text( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
