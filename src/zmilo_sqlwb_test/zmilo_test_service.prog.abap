*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_SERVICE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmilo_test_service.
PARAMETERS p_act  TYPE char8 DEFAULT 'RUN'.
PARAMETERS p_prof TYPE zmilo_profile_id DEFAULT 'DEV'.
PARAMETERS p_sql  TYPE string LOWER CASE.
PARAMETERS p_name TYPE zmilo_query_name.
PARAMETERS p_vis  TYPE zmilo_visibility DEFAULT 'PRIVATE'.
PARAMETERS p_tags TYPE zmilo_tags LOWER CASE.
PARAMETERS p_desc TYPE zmilo_description LOWER CASE.
PARAMETERS p_qid  TYPE sysuuid_x16.
PARAMETERS p_all  AS CHECKBOX.
PARAMETERS p_stat TYPE zmilo_status.

START-OF-SELECTION.

  DATA lv_action TYPE string.

  lv_action = to_upper( condense( p_act ) ).

  TRY.

      CASE lv_action.

        WHEN 'ROLE'.
          DATA(ls_role) = zcl_milo_service=>get_role_profile( p_prof ).

          WRITE: / 'PROFILE:', ls_role-profile_id.
          WRITE: / 'PFCG ROLE:', ls_role-pfcg_role.
          WRITE: / 'MAX ROWS:', ls_role-max_rows.
          WRITE: / 'WLIST:', ls_role-wlist_profile_id.
          WRITE: / 'MASK:', ls_role-mask_profile_id.

        WHEN 'RUN'.
          DATA lv_obj       TYPE zmilo_obj_name.
          DATA lv_count     TYPE i.
          DATA lv_status    TYPE string.
          DATA lv_max_rows  TYPE i.
          DATA lv_truncated TYPE abap_bool.
          DATA lv_json      TYPE string.

          zcl_milo_service=>run_query(
            EXPORTING
              iv_profile_id  = p_prof
              iv_sql         = p_sql
            IMPORTING
              ev_object_name = lv_obj
              ev_row_count   = lv_count
              ev_status      = lv_status
              ev_max_rows    = lv_max_rows
              ev_truncated   = lv_truncated
              ev_rows_json   = lv_json ).

          WRITE: / 'STATUS:', lv_status.
          WRITE: / 'OBJECT:', lv_obj.
          WRITE: / 'ROWS:', lv_count.
          WRITE: / 'MAX ROWS:', lv_max_rows.
          WRITE: / 'TRUNCATED:', lv_truncated.
          WRITE: / 'JSON:'.
          WRITE: / lv_json.

        WHEN 'SAVE'.
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

        WHEN 'RUNSAVED'.
          DATA lv_saved_obj    TYPE zmilo_obj_name.
          DATA lv_saved_count  TYPE i.
          DATA lv_saved_status TYPE string.
          DATA lv_saved_json   TYPE string.

          zcl_milo_service=>run_saved_query(
            EXPORTING
              iv_profile_id  = p_prof
              iv_query_id    = p_qid
            IMPORTING
              ev_object_name = lv_saved_obj
              ev_row_count   = lv_saved_count
              ev_status      = lv_saved_status
              ev_rows_json   = lv_saved_json ).

          WRITE: / 'STATUS:', lv_saved_status.
          WRITE: / 'OBJECT:', lv_saved_obj.
          WRITE: / 'ROWS:', lv_saved_count.
          WRITE: / 'JSON:'.
          WRITE: / lv_saved_json.

        WHEN 'LISTQ'.
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
            WRITE: / 'SQL:', ls_query-query_text.
            WRITE: / 'CREATED DATE:', ls_query-created_date.
            WRITE: / 'CREATED TIME:', ls_query-created_time.
          ENDLOOP.

        WHEN 'LISTLOG'.
          DATA(lt_log) = zcl_milo_service=>list_logs(
            iv_profile_id = p_prof
            iv_user_only  = xsdbool( p_all <> abap_true )
            iv_status     = p_stat ).

          IF lt_log IS INITIAL.
            WRITE: / 'NO LOGS FOUND'.
            RETURN.
          ENDIF.

          LOOP AT lt_log INTO DATA(ls_log).
            WRITE: / '--------------------------------'.
            WRITE: / 'LOG ID:', ls_log-log_id.
            WRITE: / 'USER:', ls_log-user_name.
            WRITE: / 'STATUS:', ls_log-status.
            WRITE: / 'MODE:', ls_log-exec_mode.
            WRITE: / 'OBJECT:', ls_log-obj_name.
            WRITE: / 'ROWS:', ls_log-row_count.
            WRITE: / 'CREATED DATE:', ls_log-created_date.
            WRITE: / 'CREATED TIME:', ls_log-created_time.
            WRITE: / 'SQL:', ls_log-sql_text.
            IF ls_log-error_text IS NOT INITIAL.
              WRITE: / 'ERROR:', ls_log-error_text.
            ENDIF.
          ENDLOOP.

        WHEN OTHERS.
          WRITE: / 'UNKNOWN ACTION:', p_act.
          WRITE: / 'VALID ACTIONS: ROLE, RUN, SAVE, RUNSAVED, LISTQ, LISTLOG'.

      ENDCASE.

    CATCH zcx_milo_validation INTO DATA(lx_validation).

      WRITE: / 'SERVICE ERROR'.
      WRITE: / 'REASON:', lx_validation->get_text( ).

  ENDTRY.
