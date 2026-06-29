*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_RUN_QUERY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmilo_test_run_query.

PARAMETERS p_prof TYPE zmilo_profile_id DEFAULT 'DEV'.
PARAMETERS p_qid  TYPE sysuuid_x16.

START-OF-SELECTION.

  TRY.

      DATA ls_role   TYPE zmilo_role.
      DATA lv_obj    TYPE zmilo_obj_name.
      DATA lv_count  TYPE i.
      DATA lv_status TYPE string.
      DATA lv_json   TYPE string.

      ls_role = zcl_milo_config=>get_role_config( p_prof ).

      IF ls_role-profile_id IS INITIAL.
        WRITE: / 'PROFILE NOT FOUND'.
        RETURN.
      ENDIF.

      zcl_milo_executor=>execute_saved_query(
        EXPORTING
          iv_query_id         = p_qid
          iv_wlist_profile_id = ls_role-wlist_profile_id
          iv_mask_profile_id  = ls_role-mask_profile_id
        IMPORTING
          ev_object_name      = lv_obj
          ev_row_count        = lv_count
          ev_status           = lv_status
          ev_rows_json        = lv_json ).

      WRITE: / 'STATUS:', lv_status.
      WRITE: / 'OBJECT:', lv_obj.
      WRITE: / 'ROWS:', lv_count.
      WRITE: / 'JSON:'.
      WRITE: / lv_json.

    CATCH zcx_milo_validation INTO DATA(lx_validation).

      WRITE: / 'FAILED TO EXECUTE SAVED QUERY'.
      WRITE: / 'REASON:', lx_validation->get_text( ).

  ENDTRY.
