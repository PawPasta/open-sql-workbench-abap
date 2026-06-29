*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_RESULT_CLEANUP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmilo_test_result_cleanup.

PARAMETERS p_run TYPE abap_bool DEFAULT abap_false.
PARAMETERS p_all TYPE abap_bool DEFAULT abap_false.

START-OF-SELECTION.

  DATA lv_head_before TYPE i.
  DATA lv_col_before  TYPE i.
  DATA lv_page_before TYPE i.
  DATA lv_head_after  TYPE i.
  DATA lv_col_after   TYPE i.
  DATA lv_page_after  TYPE i.
  DATA lv_head_deleted TYPE i.
  DATA lv_col_deleted  TYPE i.
  DATA lv_page_deleted TYPE i.

  SELECT COUNT( * ) FROM zmilo_rhead INTO @lv_head_before.
  SELECT COUNT( * ) FROM zmilo_rcol  INTO @lv_col_before.
  SELECT COUNT( * ) FROM zmilo_rpage INTO @lv_page_before.

  WRITE: / 'BEFORE RHEAD:', lv_head_before.
  WRITE: / 'BEFORE RCOL :', lv_col_before.
  WRITE: / 'BEFORE RPAGE:', lv_page_before.

  IF p_run = abap_true AND p_all = abap_true.
    DELETE FROM zmilo_rpage.
    DELETE FROM zmilo_rcol.
    DELETE FROM zmilo_rhead.
    COMMIT WORK AND WAIT.
    WRITE: / 'FULL RESULT CACHE CLEANUP EXECUTED.'.
  ELSEIF p_run = abap_true.
    zcl_milo_result_repo=>cleanup_expired( ).
    WRITE: / 'EXPIRED RESULT CACHE CLEANUP EXECUTED.'.
  ELSE.
    WRITE: / 'DRY RUN ONLY. SET P_RUN = X TO EXECUTE CLEANUP.'.
    WRITE: / 'SET P_ALL = X ONLY IF YOU WANT TO DELETE ALL RESULT CACHE.'.
  ENDIF.

  SELECT COUNT( * ) FROM zmilo_rhead INTO @lv_head_after.
  SELECT COUNT( * ) FROM zmilo_rcol  INTO @lv_col_after.
  SELECT COUNT( * ) FROM zmilo_rpage INTO @lv_page_after.

  lv_head_deleted = lv_head_before - lv_head_after.
  lv_col_deleted  = lv_col_before  - lv_col_after.
  lv_page_deleted = lv_page_before - lv_page_after.

  WRITE: / 'AFTER RHEAD:', lv_head_after.
  WRITE: / 'AFTER RCOL :', lv_col_after.
  WRITE: / 'AFTER RPAGE:', lv_page_after.

  WRITE: / 'DELETED RHEAD:', lv_head_deleted.
  WRITE: / 'DELETED RCOL :', lv_col_deleted.
  WRITE: / 'DELETED RPAGE:', lv_page_deleted.
