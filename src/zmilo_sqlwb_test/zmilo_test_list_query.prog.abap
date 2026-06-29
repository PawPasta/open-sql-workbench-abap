*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_LIST_QUERY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMILO_TEST_LIST_QUERY.

PARAMETERS P_ALL AS CHECKBOX.

START-OF-SELECTION.

  DATA LT_QUERY TYPE ZCL_MILO_QUERY_REPO=>TT_QUERY.

  LT_QUERY = ZCL_MILO_QUERY_REPO=>LIST_QUERIES(
    IV_OWNER_ONLY = XSDBOOL( P_ALL <> ABAP_TRUE )
    IV_ALLOW_ALL  = P_ALL ).

  IF LT_QUERY IS INITIAL.
    WRITE: / 'NO SAVED QUERIES FOUND'.
    RETURN.
  ENDIF.

  LOOP AT LT_QUERY INTO DATA(LS_QUERY).
    WRITE: / '--------------------------------'.
    WRITE: / 'QUERY ID:', LS_QUERY-QUERY_ID.
    WRITE: / 'OWNER:', LS_QUERY-OWNER.
    WRITE: / 'NAME:', LS_QUERY-QUERY_NAME.
    WRITE: / 'VISIBILITY:', LS_QUERY-VISIBILITY.
    WRITE: / 'SQL:', LS_QUERY-QUERY_TEXT.
    WRITE: / 'CREATED DATE:', LS_QUERY-CREATED_DATE.
    WRITE: / 'CREATED TIME:', LS_QUERY-CREATED_TIME.
  ENDLOOP.
