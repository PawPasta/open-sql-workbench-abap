*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_EXPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZMILO_TEST_EXPORT.

PARAMETERS P_PROF TYPE ZMILO_PROFILE_ID DEFAULT 'DEV'.
PARAMETERS P_OBJ  TYPE ZMILO_OBJ_NAME DEFAULT 'SPFLI'.
PARAMETERS P_MAX  TYPE I DEFAULT 20.

START-OF-SELECTION.

  TRY.

      DATA LV_OBJ TYPE ZMILO_OBJ_NAME.
      DATA LV_ROWS TYPE I.
      DATA LV_CSV TYPE STRING.

      ZCL_MILO_SERVICE=>PREVIEW_TABLE_CSV(
        EXPORTING
          IV_PROFILE_ID  = P_PROF
          IV_OBJ_NAME    = P_OBJ
          IV_ROW_LIMIT   = P_MAX
        IMPORTING
          EV_OBJECT_NAME = LV_OBJ
          EV_ROW_COUNT   = LV_ROWS
          EV_CSV         = LV_CSV ).

      WRITE: / 'OBJECT:', LV_OBJ.
      WRITE: / 'ROWS:', LV_ROWS.
      WRITE: / 'CSV:'.
      WRITE: / LV_CSV.

    CATCH ZCX_MILO_VALIDATION INTO DATA(LX_VALIDATION).

      WRITE: / 'EXPORT ERROR'.
      WRITE: / 'REASON:', LX_VALIDATION->GET_TEXT( ).

  ENDTRY.
