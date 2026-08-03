*&---------------------------------------------------------------------*
*& Report Zmilo_TEST_SAVED_QUERY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmilo_test_saved_query.

PARAMETERS p_act  TYPE char8 DEFAULT 'SAVE'.
PARAMETERS p_prof TYPE zmilo_profile_id DEFAULT 'DEV'.
PARAMETERS p_name TYPE zmilo_query_name DEFAULT 'TEST_QUERY'.
PARAMETERS p_sql  TYPE string LOWER CASE DEFAULT 'SELECT * FROM SPFLI ORDER BY CARRID'.
PARAMETERS p_vis  TYPE zmilo_visibility DEFAULT 'PRIVATE'.
PARAMETERS p_tags TYPE zmilo_tags LOWER CASE.
PARAMETERS p_desc TYPE zmilo_description LOWER CASE.
PARAMETERS p_qid  TYPE sysuuid_x16.
PARAMETERS p_page TYPE i DEFAULT 1.
PARAMETERS p_all  AS CHECKBOX.

START-OF-SELECTION.

  DATA lv_action TYPE string.
  DATA ls_result TYPE zcl_milo_service=>ty_run_result.

  lv_action = to_upper( condense( p_act ) ).

  CASE lv_action.

    WHEN 'SAVE'.
      TRY.
          DATA(lv_query_id) = zcl_milo_service=>save_query(
            iv_profile_id       = p_prof
            iv_query_name       = p_name
            iv_query_text       = p_sql
            iv_visibility       = p_vis
            iv_tags             = p_tags
            iv_description      = p_desc ).

          IF lv_query_id IS INITIAL.
            WRITE: / 'SAVE FAILED'.
          ELSE.
            WRITE: / 'SAVED QUERY ID:', lv_query_id.
          ENDIF.

        CATCH zcx_milo_validation INTO DATA(lx_save).
          DATA(lv_save_error_code) =
            zcl_milo_error_mapper=>get_validation_error_code( lx_save ).
          IF zcl_milo_error_mapper=>is_technical_error_code(
               lv_save_error_code ) = abap_true.
            DATA(lv_save_safe_text) =
              zcl_milo_error_mapper=>get_safe_technical_text(
                lv_save_error_code ).
            WRITE: / 'STATUS: ERROR'.
            WRITE: / 'ERROR:', lv_save_safe_text.
          ELSE.
            WRITE: / 'STATUS: BLOCKED'.
            WRITE: / 'ERROR:', lx_save->get_text( ).
          ENDIF.
          WRITE: / 'ERROR CODE:', lv_save_error_code.
      ENDTRY.

    WHEN 'LIST'.
      TRY.
          DATA(lt_query) = zcl_milo_service=>list_queries(
            iv_profile_id = p_prof
            iv_owner_only = xsdbool( p_all <> abap_true ) ).

          IF lt_query IS INITIAL.
            WRITE: / 'NO SAVED QUERIES FOUND'.
            RETURN.
          ENDIF.

          LOOP AT lt_query INTO DATA(ls_query).
            WRITE: / '--------------------------------'.
            WRITE: / 'QUERY ID:', ls_query-query_id.
            WRITE: / 'OWNER:', ls_query-owner.
            WRITE: / 'NAME:', ls_query-query_name.
            WRITE: / 'VISIBILITY:', ls_query-visibility.
            WRITE: / 'PROFILE:', ls_query-profile_id.
            WRITE: / 'TAGS:', ls_query-tags.
            WRITE: / 'DESCRIPTION:', ls_query-description.
            WRITE: / 'CREATED DATE:', ls_query-created_date.
            WRITE: / 'CREATED TIME:', ls_query-created_time.
            WRITE: / 'SQL:', ls_query-query_text.
          ENDLOOP.

        CATCH zcx_milo_validation INTO DATA(lx_list).
          WRITE: / 'STATUS: BLOCKED'.
          WRITE: / 'ERROR:', lx_list->get_text( ).
      ENDTRY.

    WHEN 'RUN'.
      ls_result = zcl_milo_service=>run_saved_query_result(
        iv_profile_id = p_prof
        iv_query_id   = p_qid
        iv_page       = p_page ).

      WRITE: / 'STATUS:', ls_result-status.
      WRITE: / 'OBJECT:', ls_result-object_name.
      WRITE: / 'ROW_COUNT:', ls_result-row_count.
      WRITE: / 'RETURNED ROWS:', ls_result-returned_rows.
      WRITE: / 'TOTAL ROWS:', ls_result-total_rows.
      WRITE: / 'MAX ROWS:', ls_result-max_rows.
      WRITE: / 'PAGE:', ls_result-page.
      WRITE: / 'PAGE SIZE:', ls_result-page_size.
      WRITE: / 'TOTAL PAGES:', ls_result-total_pages.
      WRITE: / 'TRUNCATED:', ls_result-truncated.
      WRITE: / 'ERROR CODE:', ls_result-error_code.

      IF ls_result-error_text IS NOT INITIAL.
        WRITE: / 'ERROR:', ls_result-error_text.
      ENDIF.

      IF ls_result-rows_json IS NOT INITIAL.
        WRITE: / 'ROWS JSON:'.
        WRITE: / ls_result-rows_json.
      ENDIF.

    WHEN 'UPDATE'.
      TRY.
          zcl_milo_service=>update_query(
            iv_profile_id  = p_prof
            iv_query_id    = p_qid
            iv_query_name  = p_name
            iv_query_text  = p_sql
            iv_visibility  = p_vis
            iv_tags        = p_tags
            iv_description = p_desc ).

          WRITE: / 'UPDATED QUERY ID:', p_qid.

        CATCH zcx_milo_validation INTO DATA(lx_update).
          DATA(lv_update_error_code) =
            zcl_milo_error_mapper=>get_validation_error_code( lx_update ).
          IF zcl_milo_error_mapper=>is_technical_error_code(
               lv_update_error_code ) = abap_true.
            DATA(lv_update_safe_text) =
              zcl_milo_error_mapper=>get_safe_technical_text(
                lv_update_error_code ).
            WRITE: / 'STATUS: ERROR'.
            WRITE: / 'ERROR:', lv_update_safe_text.
          ELSE.
            WRITE: / 'STATUS: BLOCKED'.
            WRITE: / 'ERROR:', lx_update->get_text( ).
          ENDIF.
          WRITE: / 'ERROR CODE:', lv_update_error_code.
      ENDTRY.

    WHEN 'DELETE'.
      TRY.
          zcl_milo_service=>delete_query(
            iv_profile_id = p_prof
            iv_query_id   = p_qid ).

          WRITE: / 'DEACTIVATED QUERY ID:', p_qid.

        CATCH zcx_milo_validation INTO DATA(lx_delete).
          DATA(lv_delete_error_code) =
            zcl_milo_error_mapper=>get_validation_error_code( lx_delete ).
          IF zcl_milo_error_mapper=>is_technical_error_code(
               lv_delete_error_code ) = abap_true.
            DATA(lv_delete_safe_text) =
              zcl_milo_error_mapper=>get_safe_technical_text(
                lv_delete_error_code ).
            WRITE: / 'STATUS: ERROR'.
            WRITE: / 'ERROR:', lv_delete_safe_text.
          ELSE.
            WRITE: / 'STATUS: BLOCKED'.
            WRITE: / 'ERROR:', lx_delete->get_text( ).
          ENDIF.
          WRITE: / 'ERROR CODE:', lv_delete_error_code.
      ENDTRY.

    WHEN OTHERS.
      WRITE: / 'UNKNOWN ACTION:', p_act.
      WRITE: / 'VALID ACTIONS: SAVE, LIST, RUN, UPDATE, DELETE'.

  ENDCASE.
