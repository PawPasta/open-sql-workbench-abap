*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_SAVE_QUERY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmilo_test_save_query.

PARAMETERS p_name TYPE zmilo_query_name.
PARAMETERS p_sql  TYPE string LOWER CASE.
PARAMETERS p_vis  TYPE zmilo_visibility DEFAULT 'PRIVATE'.
PARAMETERS p_tags TYPE zmilo_tags LOWER CASE.
PARAMETERS p_desc TYPE zmilo_description LOWER CASE.

START-OF-SELECTION.

  DATA lv_id TYPE sysuuid_x16.

  lv_id = zcl_milo_query_repo=>save_query(
    iv_query_name       = p_name
    iv_query_text       = p_sql
    iv_visibility       = p_vis
    iv_tags             = p_tags
    iv_description      = p_desc ).

  IF lv_id IS INITIAL.
    WRITE: / 'SAVE FAILED'.
  ELSE.
    WRITE: / 'SAVED QUERY ID:', lv_id.
  ENDIF.
