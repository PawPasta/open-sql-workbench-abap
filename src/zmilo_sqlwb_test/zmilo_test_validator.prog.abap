*&---------------------------------------------------------------------*
*& Report Zmilo_TEST_VALIDATOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmilo_test_validator.

PARAMETERS p_wlist TYPE zmilo_wlist_profile_id DEFAULT 'DEV_SAFE'.
PARAMETERS p_sql TYPE string LOWER CASE.

START-OF-SELECTION.

  TRY.

      DATA lv_obj TYPE zmilo_obj_name.

      zcl_milo_validator=>validate_select_sql(
        EXPORTING
          iv_sql              = p_sql
          iv_wlist_profile_id = p_wlist
        IMPORTING
          ev_object_name      = lv_obj ).

      WRITE: / 'VALID SQL'.
      WRITE: / 'OBJECT:', lv_obj.

    CATCH zcx_milo_validation INTO DATA(lx_validation).

      WRITE: / 'BLOCKED SQL'.
      WRITE: / 'ERROR CODE:',
        zcl_milo_error_mapper=>get_validation_error_code( lx_validation ).
      WRITE: / 'REASON:', lx_validation->get_text( ).

  ENDTRY.
