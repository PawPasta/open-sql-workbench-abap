*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_EXECUTOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmilo_test_executor.

PARAMETERS p_prof TYPE zmilo_profile_id DEFAULT 'DEV'.
PARAMETERS p_sql  TYPE string LOWER CASE.

START-OF-SELECTION.

  TRY.
      DATA ls_role      TYPE zmilo_role.
      DATA lv_obj       TYPE zmilo_obj_name.
      DATA lv_count     TYPE i.
      DATA lv_status    TYPE string.
      DATA lv_max_rows  TYPE i.
      DATA lv_truncated TYPE abap_bool.
      DATA lv_json TYPE string.

      ls_role = zcl_milo_config=>get_role_config( p_prof ).

      IF ls_role-profile_id IS INITIAL.
        WRITE: / 'PROFILE NOT FOUND OR INACTIVE:', p_prof.
        RETURN.
      ENDIF.

      zcl_milo_executor=>execute_select(
        EXPORTING
          iv_sql              = p_sql
          iv_wlist_profile_id = ls_role-wlist_profile_id
          iv_mask_profile_id = ls_role-mask_profile_id
        IMPORTING
          ev_object_name      = lv_obj
          ev_row_count        = lv_count
          ev_status           = lv_status
          ev_max_rows         = lv_max_rows
          ev_truncated        = lv_truncated
          ev_rows_json        = lv_json ).

      WRITE: / 'PROFILE:', p_prof.
      WRITE: / 'WLIST:', ls_role-wlist_profile_id.
      WRITE: / 'MASK:', ls_role-mask_profile_id.
      WRITE: / 'STATUS:', lv_status.
      WRITE: / 'OBJECT:', lv_obj.
      WRITE: / 'ROWS:', lv_count.
      WRITE: / 'MAX ROWS:', lv_max_rows.
      WRITE: / 'TRUNCATED:', lv_truncated.
      WRITE: / 'JSON:'.
      WRITE: / lv_json.

    CATCH zcx_milo_validation INTO DATA(lx_validation).

      WRITE: / 'BLOCKED SQL'.
      WRITE: / 'REASON:', lx_validation->get_text( ).

  ENDTRY.
