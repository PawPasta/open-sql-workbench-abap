*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_JOIN_COLUMNS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMILO_TEST_JOIN_COLUMNS.

PARAMETERS P_PROF TYPE ZMILO_PROFILE_ID DEFAULT 'DEV'.
PARAMETERS P_SQL  TYPE STRING LOWER CASE DEFAULT 'SELECT a~carrid, a~connid, b~carrname FROM spfli AS a INNER JOIN scarr AS b ON a~carrid = b~carrid WHERE a~carrid = ''AA'' ORDER BY a~carrid, a~connid'.

START-OF-SELECTION.

  TRY.

      DATA(LT_COLUMN) = ZCL_MILO_SERVICE=>BUILD_RESULT_COLUMNS(
        IV_PROFILE_ID = P_PROF
        IV_SQL        = P_SQL ).

      IF LT_COLUMN IS INITIAL.
        WRITE: / 'NO COLUMNS'.
        RETURN.
      ENDIF.

      LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
        WRITE: / 'POS:', LS_COLUMN-COLUMN_POSITION.
        WRITE: / 'FIELD:', LS_COLUMN-FIELD_NAME.
        WRITE: / 'JSON KEY:', LS_COLUMN-JSON_KEY.
        WRITE: / 'ELEMENT:', LS_COLUMN-ELEMENT.
        WRITE: / 'TYPE:', LS_COLUMN-ABAP_TYPE.
        WRITE: / 'LENGTH:', LS_COLUMN-LENGTH.
        WRITE: / 'DECIMALS:', LS_COLUMN-DECIMALS.
        WRITE: / 'KEY:', LS_COLUMN-IS_KEY.
        WRITE: / 'LABEL:', LS_COLUMN-COLUMN_LABEL.
        ULINE.
      ENDLOOP.

    CATCH ZCX_MILO_VALIDATION INTO DATA(LX_VALIDATION).

      WRITE: / 'BLOCKED'.
      WRITE: / 'REASON:', LX_VALIDATION->GET_TEXT( ).

  ENDTRY.
