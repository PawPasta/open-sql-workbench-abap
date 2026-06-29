*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_LIST_LOG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMILO_TEST_LIST_LOG.

PARAMETERS P_ALL AS CHECKBOX.
PARAMETERS P_STAT TYPE ZMILO_STATUS.

START-OF-SELECTION.

  DATA LT_LOG TYPE ZCL_MILO_LOG_REPO=>TT_LOG.

  LT_LOG = ZCL_MILO_LOG_REPO=>LIST_LOGS(
    IV_USER_ONLY = XSDBOOL( P_ALL <> ABAP_TRUE )
    IV_STATUS    = P_STAT ).

  IF LT_LOG IS INITIAL.
    WRITE: / 'NO LOGS FOUND'.
    RETURN.
  ENDIF.

  LOOP AT LT_LOG INTO DATA(LS_LOG).
    WRITE: / '--------------------------------'.
    WRITE: / 'LOG ID:', LS_LOG-LOG_ID.
    WRITE: / 'USER:', LS_LOG-USER_NAME.
    WRITE: / 'STATUS:', LS_LOG-STATUS.
    WRITE: / 'MODE:', LS_LOG-EXEC_MODE.
    WRITE: / 'OBJECT:', LS_LOG-OBJ_NAME.
    WRITE: / 'ROWS:', LS_LOG-ROW_COUNT.
    WRITE: / 'CREATED DATE:', LS_LOG-CREATED_DATE.
    WRITE: / 'CREATED TIME:', LS_LOG-CREATED_TIME.
    WRITE: / 'SQL:', LS_LOG-SQL_TEXT.
    IF LS_LOG-ERROR_TEXT IS NOT INITIAL.
      WRITE: / 'ERROR:', LS_LOG-ERROR_TEXT.
    ENDIF.
  ENDLOOP.
