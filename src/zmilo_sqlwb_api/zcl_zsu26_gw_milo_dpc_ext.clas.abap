class ZCL_ZSU26_GW_MILO_DPC_EXT definition
  public
  inheriting from ZCL_ZSU26_GW_MILO_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
protected section.

  methods SQLWBCOLUMNSET_GET_ENTITYSET
    redefinition .
  methods SQLWBPAGECHUNKSE_GET_ENTITYSET
    redefinition .
  methods SQLWBSAVEDQUERYS_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZSU26_GW_MILO_DPC_EXT IMPLEMENTATION.


METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.

  TYPES:
    BEGIN OF ty_run_result,
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
    END OF ty_run_result.

  TYPES:
    BEGIN OF ty_save_query_result,
      queryid   TYPE string,
      status    TYPE string,
      errorcode TYPE string,
      errortext TYPE string,
    END OF ty_save_query_result.

  DATA lv_action_name TYPE string.
  DATA lv_profile_id  TYPE zmilo_profile_id.
  DATA lv_sql_text    TYPE string.
  DATA lv_page        TYPE i.
  DATA lv_search_text TYPE string.
  DATA lv_max_rows    TYPE i.
  DATA lv_object_name TYPE zmilo_obj_name.
  DATA lv_query_id_c32 TYPE string.
  DATA lv_query_id     TYPE sysuuid_x16.
  DATA lv_query_name   TYPE zmilo_query_name.
  DATA lv_visibility   TYPE zmilo_visibility.
  DATA lv_tags         TYPE zmilo_tags.
  DATA lv_description  TYPE zmilo_description.
  DATA lv_saved_sql_text TYPE string.
  DATA lv_result_id   TYPE sysuuid_x16.
  DATA lv_result_c32  TYPE string.
  DATA ls_srv_result  TYPE zcl_milo_service=>ty_run_result.
  DATA ls_head        TYPE zmilo_rhead.
  DATA ls_saved_query TYPE zmilo_query.
  DATA lt_result_field TYPE zcl_milo_service=>tt_ddic_field.
  DATA lt_column      TYPE zcl_milo_result_repo=>tt_column.
  DATA lt_page        TYPE zcl_milo_result_repo=>tt_page.
  DATA ls_response    TYPE ty_run_result.
  DATA ls_save_response TYPE ty_save_query_result.

  FIELD-SYMBOLS <ls_parameter> TYPE /iwbep/s_mgw_name_value_pair.

  lv_action_name = to_upper( iv_action_name ).

  CASE lv_action_name.

    WHEN 'RUNQUERY'.

      LOOP AT it_parameter ASSIGNING <ls_parameter>.
        CASE to_upper( <ls_parameter>-name ).
          WHEN 'PROFILEID'.
            lv_profile_id = <ls_parameter>-value.
          WHEN 'SQLTEXT'.
            lv_sql_text = <ls_parameter>-value.
          WHEN 'PAGE'.
            lv_page = <ls_parameter>-value.
        ENDCASE.
      ENDLOOP.

      IF lv_page IS INITIAL.
        lv_page = 1.
      ENDIF.

      lv_result_id = zcl_milo_result_repo=>create_result_id( ).
      lv_result_c32 = zcl_milo_result_repo=>result_id_to_c32( lv_result_id ).

      ls_srv_result = zcl_milo_service=>run_query_result(
        iv_profile_id = lv_profile_id
        iv_sql        = lv_sql_text
        iv_page       = lv_page ).

      ls_head-result_id     = lv_result_id.
      ls_head-user_name     = sy-uname.
      ls_head-profile_id    = lv_profile_id.
      ls_head-object_name   = ls_srv_result-object_name.
      ls_head-status        = ls_srv_result-status.
      ls_head-row_count     = ls_srv_result-row_count.
      ls_head-returned_rows = ls_srv_result-returned_rows.
      ls_head-total_rows    = ls_srv_result-total_rows.
      ls_head-max_rows      = ls_srv_result-max_rows.
      ls_head-result_page   = ls_srv_result-page.
      ls_head-page_size     = ls_srv_result-page_size.
      ls_head-total_pages   = ls_srv_result-total_pages.
      ls_head-truncated     = ls_srv_result-truncated.
      ls_head-error_code    = ls_srv_result-error_code.
      ls_head-error_text    = ls_srv_result-error_text.
      GET TIME STAMP FIELD ls_head-created_at.

      IF ls_srv_result-status = 'SUCCESS'.

        TRY.
            lt_column = zcl_milo_service=>build_result_columns(
              iv_profile_id = lv_profile_id
              iv_sql        = lv_sql_text
              iv_result_id  = lv_result_id ).

            lt_page = zcl_milo_result_repo=>build_page_chunks(
              iv_result_id = lv_result_id
              iv_page_no   = ls_srv_result-page
              iv_rows_json = ls_srv_result-rows_json ).

          CATCH zcx_milo_validation INTO DATA(lx_validation).
            CLEAR lt_column.
            CLEAR lt_page.
            ls_srv_result-status = 'BLOCKED'.
            ls_srv_result-error_code = 'VALIDATION_ERROR'.
            ls_srv_result-error_text = lx_validation->get_text( ).
            ls_head-status = ls_srv_result-status.
            ls_head-error_code = ls_srv_result-error_code.
            ls_head-error_text = ls_srv_result-error_text.
        ENDTRY.

      ENDIF.

      zcl_milo_result_repo=>save_result(
        is_head   = ls_head
        it_column = lt_column
        it_page   = lt_page ).

      ls_response-resultid     = lv_result_c32.
      ls_response-status       = ls_srv_result-status.
      ls_response-objectname   = ls_srv_result-object_name.
      ls_response-rowcount     = ls_srv_result-row_count.
      ls_response-returnedrows = ls_srv_result-returned_rows.
      ls_response-totalrows    = ls_srv_result-total_rows.
      ls_response-maxrows      = ls_srv_result-max_rows.
      ls_response-page         = ls_srv_result-page.
      ls_response-pagesize     = ls_srv_result-page_size.
      ls_response-totalpages   = ls_srv_result-total_pages.
      ls_response-truncated    = ls_srv_result-truncated.
      ls_response-errorcode    = ls_srv_result-error_code.
      ls_response-errortext    = ls_srv_result-error_text.

      copy_data_to_ref(
        EXPORTING
          is_data = ls_response
        CHANGING
          cr_data = er_data ).

    WHEN 'SAVEQUERY'.

      CLEAR: lv_profile_id,
             lv_query_name,
             lv_sql_text,
             lv_visibility,
             lv_tags,
             lv_description,
             lv_query_id,
             lv_query_id_c32,
             ls_save_response.

      LOOP AT it_parameter ASSIGNING <ls_parameter>.
        CASE to_upper( <ls_parameter>-name ).
          WHEN 'PROFILEID'.
            lv_profile_id = <ls_parameter>-value.
          WHEN 'QUERYNAME'.
            lv_query_name = <ls_parameter>-value.
          WHEN 'QUERYTEXT'.
            lv_sql_text = <ls_parameter>-value.
          WHEN 'VISIBILITY'.
            lv_visibility = <ls_parameter>-value.
          WHEN 'TAGS'.
            lv_tags = <ls_parameter>-value.
          WHEN 'DESCRIPTION'.
            lv_description = <ls_parameter>-value.
        ENDCASE.
      ENDLOOP.

      TRY.
          lv_query_id = zcl_milo_service=>save_query(
            iv_profile_id   = lv_profile_id
            iv_query_name   = lv_query_name
            iv_query_text   = lv_sql_text
            iv_visibility   = lv_visibility
            iv_tags         = lv_tags
            iv_description  = lv_description ).

          lv_query_id_c32 = zcl_milo_result_repo=>result_id_to_c32( lv_query_id ).

          IF lv_query_id IS INITIAL.
            ls_save_response-status = 'ERROR'.
            ls_save_response-errorcode = 'SAVE_FAILED'.
            ls_save_response-errortext = 'Saved query could not be created'.
          ELSE.
            ls_save_response-queryid = lv_query_id_c32.
            ls_save_response-status = 'SUCCESS'.
          ENDIF.

        CATCH zcx_milo_validation INTO DATA(lx_save_validation).
          ls_save_response-status = 'BLOCKED'.
          ls_save_response-errorcode = 'VALIDATION_ERROR'.
          ls_save_response-errortext = lx_save_validation->get_text( ).
        CATCH cx_root INTO DATA(lx_save_error).
          ls_save_response-status = 'ERROR'.
          ls_save_response-errorcode = 'SYSTEM_ERROR'.
          ls_save_response-errortext = lx_save_error->get_text( ).
      ENDTRY.

      copy_data_to_ref(
        EXPORTING
          is_data = ls_save_response
        CHANGING
          cr_data = er_data ).

    WHEN 'RUNSAVEDQUERY'.

      CLEAR: lv_profile_id,
             lv_query_id_c32,
             lv_query_id,
             lv_page,
             lv_result_id,
             lv_result_c32,
             lv_saved_sql_text,
             ls_srv_result,
             ls_head,
             ls_saved_query,
             lt_column,
             lt_page,
             ls_response.

      LOOP AT it_parameter ASSIGNING <ls_parameter>.
        CASE to_upper( <ls_parameter>-name ).
          WHEN 'PROFILEID'.
            lv_profile_id = <ls_parameter>-value.
          WHEN 'QUERYID'.
            lv_query_id_c32 = <ls_parameter>-value.
          WHEN 'PAGE'.
            lv_page = <ls_parameter>-value.
        ENDCASE.
      ENDLOOP.

      IF lv_page IS INITIAL.
        lv_page = 1.
      ENDIF.

      lv_query_id = zcl_milo_result_repo=>result_id_from_c32( lv_query_id_c32 ).

      lv_result_id = zcl_milo_result_repo=>create_result_id( ).
      lv_result_c32 = zcl_milo_result_repo=>result_id_to_c32( lv_result_id ).

      ls_srv_result = zcl_milo_service=>run_saved_query_result(
        iv_profile_id = lv_profile_id
        iv_query_id   = lv_query_id
        iv_page       = lv_page ).

      ls_head-result_id     = lv_result_id.
      ls_head-user_name     = sy-uname.
      ls_head-profile_id    = lv_profile_id.
      ls_head-object_name   = ls_srv_result-object_name.
      ls_head-status        = ls_srv_result-status.
      ls_head-row_count     = ls_srv_result-row_count.
      ls_head-returned_rows = ls_srv_result-returned_rows.
      ls_head-total_rows    = ls_srv_result-total_rows.
      ls_head-max_rows      = ls_srv_result-max_rows.
      ls_head-result_page   = ls_srv_result-page.
      ls_head-page_size     = ls_srv_result-page_size.
      ls_head-total_pages   = ls_srv_result-total_pages.
      ls_head-truncated     = ls_srv_result-truncated.
      ls_head-error_code    = ls_srv_result-error_code.
      ls_head-error_text    = ls_srv_result-error_text.
      GET TIME STAMP FIELD ls_head-created_at.

      IF ls_srv_result-status = 'SUCCESS'.

        TRY.
            ls_saved_query = zcl_milo_query_repo=>get_query(
              iv_query_id   = lv_query_id
              iv_profile_id = lv_profile_id ).
            lv_saved_sql_text = ls_saved_query-query_text.

            lt_column = zcl_milo_service=>build_result_columns(
              iv_profile_id = lv_profile_id
              iv_sql        = lv_saved_sql_text
              iv_result_id  = lv_result_id ).

            lt_page = zcl_milo_result_repo=>build_page_chunks(
              iv_result_id = lv_result_id
              iv_page_no   = ls_srv_result-page
              iv_rows_json = ls_srv_result-rows_json ).

          CATCH zcx_milo_validation INTO DATA(lx_saved_validation).
            CLEAR lt_column.
            CLEAR lt_page.
            ls_srv_result-status = 'BLOCKED'.
            ls_srv_result-error_code = 'VALIDATION_ERROR'.
            ls_srv_result-error_text = lx_saved_validation->get_text( ).
            ls_head-status = ls_srv_result-status.
            ls_head-error_code = ls_srv_result-error_code.
            ls_head-error_text = ls_srv_result-error_text.
          CATCH cx_root INTO DATA(lx_saved_error).
            CLEAR lt_column.
            CLEAR lt_page.
            ls_srv_result-status = 'ERROR'.
            ls_srv_result-error_code = 'SYSTEM_ERROR'.
            ls_srv_result-error_text = lx_saved_error->get_text( ).
            ls_head-status = ls_srv_result-status.
            ls_head-error_code = ls_srv_result-error_code.
            ls_head-error_text = ls_srv_result-error_text.
        ENDTRY.

      ENDIF.

      zcl_milo_result_repo=>save_result(
        is_head   = ls_head
        it_column = lt_column
        it_page   = lt_page ).

      ls_response-resultid     = lv_result_c32.
      ls_response-status       = ls_srv_result-status.
      ls_response-objectname   = ls_srv_result-object_name.
      ls_response-rowcount     = ls_srv_result-row_count.
      ls_response-returnedrows = ls_srv_result-returned_rows.
      ls_response-totalrows    = ls_srv_result-total_rows.
      ls_response-maxrows      = ls_srv_result-max_rows.
      ls_response-page         = ls_srv_result-page.
      ls_response-pagesize     = ls_srv_result-page_size.
      ls_response-totalpages   = ls_srv_result-total_pages.
      ls_response-truncated    = ls_srv_result-truncated.
      ls_response-errorcode    = ls_srv_result-error_code.
      ls_response-errortext    = ls_srv_result-error_text.

      copy_data_to_ref(
        EXPORTING
          is_data = ls_response
        CHANGING
          cr_data = er_data ).

    WHEN 'UPDATESAVEDQUERY'.

      CLEAR: lv_profile_id,
             lv_query_id_c32,
             lv_query_id,
             lv_query_name,
             lv_sql_text,
             lv_visibility,
             lv_tags,
             lv_description,
             ls_save_response.

      LOOP AT it_parameter ASSIGNING <ls_parameter>.
        CASE to_upper( <ls_parameter>-name ).
          WHEN 'PROFILEID'.
            lv_profile_id = <ls_parameter>-value.
          WHEN 'QUERYID'.
            lv_query_id_c32 = <ls_parameter>-value.
          WHEN 'QUERYNAME'.
            lv_query_name = <ls_parameter>-value.
          WHEN 'QUERYTEXT'.
            lv_sql_text = <ls_parameter>-value.
          WHEN 'VISIBILITY'.
            lv_visibility = <ls_parameter>-value.
          WHEN 'TAGS'.
            lv_tags = <ls_parameter>-value.
          WHEN 'DESCRIPTION'.
            lv_description = <ls_parameter>-value.
        ENDCASE.
      ENDLOOP.

      lv_query_id = zcl_milo_result_repo=>result_id_from_c32( lv_query_id_c32 ).

      IF lv_query_id IS INITIAL.
        ls_save_response-status = 'BLOCKED'.
        ls_save_response-errorcode = 'INVALID_QUERY_ID'.
        ls_save_response-errortext = 'QueryId is invalid'.
      ELSE.
        TRY.
            zcl_milo_service=>update_query(
              iv_profile_id  = lv_profile_id
              iv_query_id    = lv_query_id
              iv_query_name  = lv_query_name
              iv_query_text  = lv_sql_text
              iv_visibility  = lv_visibility
              iv_tags        = lv_tags
              iv_description = lv_description ).

            ls_save_response-queryid = lv_query_id_c32.
            ls_save_response-status = 'SUCCESS'.

          CATCH zcx_milo_validation INTO DATA(lx_update_validation).
            ls_save_response-status = 'BLOCKED'.
            ls_save_response-errorcode = 'VALIDATION_ERROR'.
            ls_save_response-errortext = lx_update_validation->get_text( ).
          CATCH cx_root INTO DATA(lx_update_error).
            ls_save_response-status = 'ERROR'.
            ls_save_response-errorcode = 'SYSTEM_ERROR'.
            ls_save_response-errortext = lx_update_error->get_text( ).
        ENDTRY.
      ENDIF.

      copy_data_to_ref(
        EXPORTING
          is_data = ls_save_response
        CHANGING
          cr_data = er_data ).

    WHEN 'DELETESAVEDQUERY'.

      CLEAR: lv_profile_id,
             lv_query_id_c32,
             lv_query_id,
             ls_save_response.

      LOOP AT it_parameter ASSIGNING <ls_parameter>.
        CASE to_upper( <ls_parameter>-name ).
          WHEN 'PROFILEID'.
            lv_profile_id = <ls_parameter>-value.
          WHEN 'QUERYID'.
            lv_query_id_c32 = <ls_parameter>-value.
        ENDCASE.
      ENDLOOP.

      lv_query_id = zcl_milo_result_repo=>result_id_from_c32( lv_query_id_c32 ).

      IF lv_query_id IS INITIAL.
        ls_save_response-status = 'BLOCKED'.
        ls_save_response-errorcode = 'INVALID_QUERY_ID'.
        ls_save_response-errortext = 'QueryId is invalid'.
      ELSE.
        TRY.
            zcl_milo_service=>delete_query(
              iv_profile_id = lv_profile_id
              iv_query_id   = lv_query_id ).

            ls_save_response-queryid = lv_query_id_c32.
            ls_save_response-status = 'SUCCESS'.

          CATCH zcx_milo_validation INTO DATA(lx_delete_validation).
            ls_save_response-status = 'BLOCKED'.
            ls_save_response-errorcode = 'VALIDATION_ERROR'.
            ls_save_response-errortext = lx_delete_validation->get_text( ).
          CATCH cx_root INTO DATA(lx_delete_error).
            ls_save_response-status = 'ERROR'.
            ls_save_response-errorcode = 'SYSTEM_ERROR'.
            ls_save_response-errortext = lx_delete_error->get_text( ).
        ENDTRY.
      ENDIF.

      copy_data_to_ref(
        EXPORTING
          is_data = ls_save_response
        CHANGING
          cr_data = er_data ).

    WHEN 'SEARCHTABLES'.

      CLEAR: lv_profile_id,
             lv_search_text,
             lv_max_rows.

      LOOP AT it_parameter ASSIGNING <ls_parameter>.
        CASE to_upper( <ls_parameter>-name ).
          WHEN 'PROFILEID'.
            lv_profile_id = <ls_parameter>-value.
          WHEN 'SEARCHTEXT'.
            lv_search_text = <ls_parameter>-value.
          WHEN 'MAXROWS'.
            lv_max_rows = <ls_parameter>-value.
        ENDCASE.
      ENDLOOP.

      IF lv_max_rows IS INITIAL.
        lv_max_rows = 50.
      ENDIF.

      DATA lt_table_response TYPE zcl_zsu26_gw_milo_mpc=>tt_sqlwbtable.

      TRY.
          DATA(lt_table) = zcl_milo_service=>search_ddic_tables(
            iv_profile_id = lv_profile_id
            iv_search     = lv_search_text
            iv_max_rows   = lv_max_rows ).

          LOOP AT lt_table INTO DATA(ls_table).
            APPEND INITIAL LINE TO lt_table_response ASSIGNING FIELD-SYMBOL(<ls_table_response>).
            <ls_table_response>-profileid = lv_profile_id.
            <ls_table_response>-objectname = ls_table-tabname.

            CASE ls_table-tabclass.
              WHEN 'TRANSP'.
                <ls_table_response>-objecttype = 'TABLE'.
              WHEN 'VIEW'.
                <ls_table_response>-objecttype = 'VIEW'.
              WHEN OTHERS.
                <ls_table_response>-objecttype = ls_table-tabclass.
            ENDCASE.

            <ls_table_response>-description = ls_table-ddtext.
          ENDLOOP.

        CATCH zcx_milo_validation.
          CLEAR lt_table_response.
        CATCH cx_root.
          CLEAR lt_table_response.
      ENDTRY.

      copy_data_to_ref(
        EXPORTING
          is_data = lt_table_response
        CHANGING
          cr_data = er_data ).

    WHEN 'PREVIEWTABLE'.

      CLEAR: lv_profile_id,
             lv_object_name,
             lv_max_rows,
             lv_page,
             lv_result_id,
             lv_result_c32,
             ls_srv_result,
             ls_head,
             lt_result_field,
             lt_column,
             lt_page,
             ls_response.

      LOOP AT it_parameter ASSIGNING <ls_parameter>.
        CASE to_upper( <ls_parameter>-name ).
          WHEN 'PROFILEID'.
            lv_profile_id = <ls_parameter>-value.
          WHEN 'OBJECTNAME'.
            lv_object_name = <ls_parameter>-value.
          WHEN 'MAXROWS'.
            lv_max_rows = <ls_parameter>-value.
          WHEN 'PAGE'.
            lv_page = <ls_parameter>-value.
        ENDCASE.
      ENDLOOP.

      lv_object_name = to_upper( condense( lv_object_name ) ).

      IF lv_max_rows IS INITIAL.
        lv_max_rows = 100.
      ENDIF.

      IF lv_page IS INITIAL.
        lv_page = 1.
      ENDIF.

      lv_result_id = zcl_milo_result_repo=>create_result_id( ).
      lv_result_c32 = zcl_milo_result_repo=>result_id_to_c32( lv_result_id ).

      ls_srv_result = zcl_milo_service=>preview_table_result(
        iv_profile_id = lv_profile_id
        iv_obj_name   = lv_object_name
        iv_row_limit  = lv_max_rows
        iv_page       = lv_page ).

      ls_head-result_id     = lv_result_id.
      ls_head-user_name     = sy-uname.
      ls_head-profile_id    = lv_profile_id.
      ls_head-object_name   = ls_srv_result-object_name.
      ls_head-status        = ls_srv_result-status.
      ls_head-row_count     = ls_srv_result-row_count.
      ls_head-returned_rows = ls_srv_result-returned_rows.
      ls_head-total_rows    = ls_srv_result-total_rows.
      ls_head-max_rows      = ls_srv_result-max_rows.
      ls_head-result_page   = ls_srv_result-page.
      ls_head-page_size     = ls_srv_result-page_size.
      ls_head-total_pages   = ls_srv_result-total_pages.
      ls_head-truncated     = ls_srv_result-truncated.
      ls_head-error_code    = ls_srv_result-error_code.
      ls_head-error_text    = ls_srv_result-error_text.
      GET TIME STAMP FIELD ls_head-created_at.

      IF ls_srv_result-status = 'SUCCESS'.

        TRY.
            DATA(lt_preview_field) = zcl_milo_service=>get_ddic_fields(
              iv_profile_id = lv_profile_id
              iv_obj_name   = ls_srv_result-object_name ).

            DATA(lv_preview_field_count) = 0.

            LOOP AT lt_preview_field INTO DATA(ls_preview_field).
              lv_preview_field_count = lv_preview_field_count + 1.
              IF lv_preview_field_count > zcl_milo_config=>c_max_select_fields.
                EXIT.
              ENDIF.
              APPEND ls_preview_field TO lt_result_field.
            ENDLOOP.

            LOOP AT lt_result_field INTO DATA(ls_preview_result_field).
              APPEND INITIAL LINE TO lt_column ASSIGNING FIELD-SYMBOL(<ls_preview_column>).
              <ls_preview_column>-result_id       = lv_result_id.
              <ls_preview_column>-column_position = ls_preview_result_field-position.
              <ls_preview_column>-field_name      = ls_preview_result_field-fieldname.
              <ls_preview_column>-json_key        = to_lower( ls_preview_result_field-fieldname ).
              <ls_preview_column>-element         = ls_preview_result_field-rollname.
              <ls_preview_column>-abap_type       = ls_preview_result_field-datatype.
              <ls_preview_column>-length          = ls_preview_result_field-leng.
              <ls_preview_column>-decimals        = ls_preview_result_field-decimals.
              <ls_preview_column>-is_key          = ls_preview_result_field-keyflag.
              <ls_preview_column>-column_label    = ls_preview_result_field-ddtext.
            ENDLOOP.

            lt_page = zcl_milo_result_repo=>build_page_chunks(
              iv_result_id = lv_result_id
              iv_page_no   = ls_srv_result-page
              iv_rows_json = ls_srv_result-rows_json ).

          CATCH zcx_milo_validation INTO DATA(lx_preview_validation).
            CLEAR lt_column.
            CLEAR lt_page.
            ls_srv_result-status = 'BLOCKED'.
            ls_srv_result-error_code = 'VALIDATION_ERROR'.
            ls_srv_result-error_text = lx_preview_validation->get_text( ).
            ls_head-status = ls_srv_result-status.
            ls_head-error_code = ls_srv_result-error_code.
            ls_head-error_text = ls_srv_result-error_text.
        ENDTRY.

      ENDIF.

      zcl_milo_result_repo=>save_result(
        is_head   = ls_head
        it_column = lt_column
        it_page   = lt_page ).

      ls_response-resultid     = lv_result_c32.
      ls_response-status       = ls_srv_result-status.
      ls_response-objectname   = ls_srv_result-object_name.
      ls_response-rowcount     = ls_srv_result-row_count.
      ls_response-returnedrows = ls_srv_result-returned_rows.
      ls_response-totalrows    = ls_srv_result-total_rows.
      ls_response-maxrows      = ls_srv_result-max_rows.
      ls_response-page         = ls_srv_result-page.
      ls_response-pagesize     = ls_srv_result-page_size.
      ls_response-totalpages   = ls_srv_result-total_pages.
      ls_response-truncated    = ls_srv_result-truncated.
      ls_response-errorcode    = ls_srv_result-error_code.
      ls_response-errortext    = ls_srv_result-error_text.

      copy_data_to_ref(
        EXPORTING
          is_data = ls_response
        CHANGING
          cr_data = er_data ).

    WHEN 'GETFIELDS'.

      CLEAR: lv_profile_id,
             lv_object_name.

      LOOP AT it_parameter ASSIGNING <ls_parameter>.
        CASE to_upper( <ls_parameter>-name ).
          WHEN 'PROFILEID'.
            lv_profile_id = <ls_parameter>-value.
          WHEN 'OBJECTNAME'.
            lv_object_name = <ls_parameter>-value.
        ENDCASE.
      ENDLOOP.

      lv_object_name = to_upper( condense( lv_object_name ) ).

      DATA lt_field_response TYPE zcl_zsu26_gw_milo_mpc=>tt_sqlwbfield.

      TRY.
          DATA(lt_get_field) = zcl_milo_service=>get_ddic_fields(
            iv_profile_id = lv_profile_id
            iv_obj_name   = lv_object_name ).

          LOOP AT lt_get_field INTO DATA(ls_ddic_field).
            APPEND INITIAL LINE TO lt_field_response ASSIGNING FIELD-SYMBOL(<ls_field_response>).
            <ls_field_response>-profileid = lv_profile_id.
            <ls_field_response>-objectname = lv_object_name.
            <ls_field_response>-position = ls_ddic_field-position.
            <ls_field_response>-fieldname = ls_ddic_field-fieldname.
            <ls_field_response>-jsonkey = to_lower( ls_ddic_field-fieldname ).
            <ls_field_response>-element = ls_ddic_field-rollname.
            <ls_field_response>-abaptype = ls_ddic_field-datatype.
            <ls_field_response>-length = ls_ddic_field-leng.
            <ls_field_response>-decimals = ls_ddic_field-decimals.
            <ls_field_response>-iskey = xsdbool( ls_ddic_field-keyflag = abap_true OR ls_ddic_field-keyflag = 'X' ).
            <ls_field_response>-label = ls_ddic_field-ddtext.
          ENDLOOP.

        CATCH zcx_milo_validation.
          CLEAR lt_field_response.
        CATCH cx_root.
          CLEAR lt_field_response.
      ENDTRY.

      copy_data_to_ref(
        EXPORTING
          is_data = lt_field_response
        CHANGING
          cr_data = er_data ).

    WHEN OTHERS.
      CALL METHOD super->/iwbep/if_mgw_appl_srv_runtime~execute_action
        EXPORTING
          iv_action_name          = iv_action_name
          it_parameter            = it_parameter
          io_tech_request_context = io_tech_request_context
        IMPORTING
          er_data                 = er_data.

  ENDCASE.

ENDMETHOD.


 METHOD SQLWBcolumnset_get_entityset.

   DATA lv_result_c32 TYPE string.
   DATA lv_result_id  TYPE sysuuid_x16.
   DATA lv_row_no     TYPE i.
   DATA lv_skip       TYPE i.
   DATA lv_top        TYPE i.
   DATA lt_column     TYPE zcl_milo_result_repo=>tt_column.

   LOOP AT it_filter_select_options INTO DATA(ls_filter).
     IF to_upper( ls_filter-property ) = 'RESULTID'.
       READ TABLE ls_filter-select_options INTO DATA(ls_option) INDEX 1.
       IF sy-subrc = 0.
         lv_result_c32 = ls_option-low.
       ENDIF.
     ENDIF.
   ENDLOOP.

   lv_result_id = zcl_milo_result_repo=>result_id_from_c32( lv_result_c32 ).

   IF lv_result_id IS INITIAL.
     RETURN.
   ENDIF.

   lt_column = zcl_milo_result_repo=>list_columns( lv_result_id ).

   lv_skip = is_paging-skip.
   lv_top = is_paging-top.

   LOOP AT lt_column INTO DATA(ls_column).
     lv_row_no = lv_row_no + 1.

     IF lv_row_no <= lv_skip.
       CONTINUE.
     ENDIF.

     IF lv_top > 0 AND lv_row_no > lv_skip + lv_top.
       EXIT.
     ENDIF.

     APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<ls_entity>).
     <ls_entity>-resultid  = lv_result_c32.
     <ls_entity>-position  = ls_column-column_position.
     <ls_entity>-fieldname = ls_column-field_name.
     <ls_entity>-jsonkey   = ls_column-json_key.
     <ls_entity>-element   = ls_column-element.
     <ls_entity>-abaptype  = ls_column-abap_type.
     <ls_entity>-length    = ls_column-length.
     <ls_entity>-decimals  = ls_column-decimals.
     <ls_entity>-iskey     = xsdbool( ls_column-is_key = abap_true OR ls_column-is_key = 'X' ).
     <ls_entity>-label     = ls_column-column_label.
   ENDLOOP.

 ENDMETHOD.


 METHOD sqlwbpagechunkse_get_entityset.

   DATA lv_result_c32 TYPE string.
   DATA lv_result_id  TYPE sysuuid_x16.
   DATA lv_page_no    TYPE i.
   DATA lv_row_no     TYPE i.
   DATA lv_skip       TYPE i.
   DATA lv_top        TYPE i.
   DATA lt_page       TYPE zcl_milo_result_repo=>tt_page.

   LOOP AT it_filter_select_options INTO DATA(ls_filter).
     CASE to_upper( ls_filter-property ).
       WHEN 'RESULTID'.
         READ TABLE ls_filter-select_options INTO DATA(ls_result_option) INDEX 1.
         IF sy-subrc = 0.
           lv_result_c32 = ls_result_option-low.
         ENDIF.
       WHEN 'PAGENO'.
         READ TABLE ls_filter-select_options INTO DATA(ls_page_option) INDEX 1.
         IF sy-subrc = 0.
           lv_page_no = ls_page_option-low.
         ENDIF.
     ENDCASE.
   ENDLOOP.

   IF lv_page_no IS INITIAL.
     lv_page_no = 1.
   ENDIF.

   lv_result_id = zcl_milo_result_repo=>result_id_from_c32( lv_result_c32 ).

   IF lv_result_id IS INITIAL.
     RETURN.
   ENDIF.

   lt_page = zcl_milo_result_repo=>list_page_chunks(
     iv_result_id = lv_result_id
     iv_page_no   = lv_page_no ).

   lv_skip = is_paging-skip.
   lv_top = is_paging-top.

   LOOP AT lt_page INTO DATA(ls_page).
     lv_row_no = lv_row_no + 1.

     IF lv_row_no <= lv_skip.
       CONTINUE.
     ENDIF.

     IF lv_top > 0 AND lv_row_no > lv_skip + lv_top.
       EXIT.
     ENDIF.

     APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<ls_entity>).
     <ls_entity>-resultid     = lv_result_c32.
     <ls_entity>-pageno       = ls_page-page_no.
     <ls_entity>-chunkno      = ls_page-chunk_no.
     <ls_entity>-payloadpart  = ls_page-payload_part.
     <ls_entity>-payloadlen   = ls_page-payload_len.
     <ls_entity>-islastchunk  = xsdbool( ls_page-is_last_chunk = abap_true OR ls_page-is_last_chunk = 'X' ).
   ENDLOOP.

 ENDMETHOD.


  METHOD SQLWBSAVEDQUERYS_GET_ENTITYSET.
* EntitySet: SqlwbSavedQuerySet
* Dán toàn bộ nội dung file này vào method SQLWBSAVEDQUERYS_GET_ENTITYSET
* sau khi redefine trong ZCL_ZSU26_ODATA_DPC_EXT.

    DATA lv_profile_id TYPE zmilo_profile_id.
    DATA lv_owner_only TYPE abap_bool VALUE abap_false.
    DATA lv_row_no     TYPE i.
    DATA lv_skip       TYPE i.
    DATA lv_top        TYPE i.
    DATA lt_query      TYPE zcl_milo_service=>tt_query.

    LOOP AT it_filter_select_options INTO DATA(ls_filter).
      CASE to_upper( ls_filter-property ).
        WHEN 'PROFILEID'.
          READ TABLE ls_filter-select_options INTO DATA(ls_profile_option) INDEX 1.
          IF sy-subrc = 0.
            lv_profile_id = ls_profile_option-low.
          ENDIF.
        WHEN 'OWNERONLY'.
          READ TABLE ls_filter-select_options INTO DATA(ls_owner_option) INDEX 1.
          IF sy-subrc = 0.
            IF to_upper( ls_owner_option-low ) = 'FALSE'
               OR ls_owner_option-low = '0'
               OR ls_owner_option-low IS INITIAL.
              lv_owner_only = abap_false.
            ELSE.
              lv_owner_only = abap_true.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    TRY.
        lt_query = zcl_milo_service=>list_queries(
          iv_profile_id = lv_profile_id
          iv_owner_only = lv_owner_only ).
      CATCH zcx_milo_validation.
        CLEAR lt_query.
      CATCH cx_root.
        CLEAR lt_query.
    ENDTRY.

    lv_skip = is_paging-skip.
    lv_top = is_paging-top.

    LOOP AT lt_query INTO DATA(ls_query).
      lv_row_no = lv_row_no + 1.

      IF lv_row_no <= lv_skip.
        CONTINUE.
      ENDIF.

      IF lv_top > 0 AND lv_row_no > lv_skip + lv_top.
        EXIT.
      ENDIF.

      APPEND INITIAL LINE TO et_entityset ASSIGNING FIELD-SYMBOL(<ls_entity>).
      <ls_entity>-profileid = ls_query-profile_id.
      <ls_entity>-queryid = zcl_milo_result_repo=>result_id_to_c32(
        iv_result_id = ls_query-query_id ).
      <ls_entity>-owner = ls_query-owner.
      <ls_entity>-queryname = ls_query-query_name.
      <ls_entity>-querytext = ls_query-query_text.
      <ls_entity>-visibility = ls_query-visibility.
      <ls_entity>-isactive = xsdbool( ls_query-is_active = abap_true OR ls_query-is_active = 'X' ).
      <ls_entity>-createddate = ls_query-created_date.
      <ls_entity>-createdtime = ls_query-created_time.
      <ls_entity>-tags = ls_query-tags.
      <ls_entity>-description = ls_query-description.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
