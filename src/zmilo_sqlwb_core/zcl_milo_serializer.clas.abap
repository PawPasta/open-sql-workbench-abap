CLASS zcl_milo_serializer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS table_to_json
      IMPORTING
        ir_data        TYPE REF TO data
      RETURNING
        VALUE(rv_json) TYPE string.

    CLASS-METHODS table_to_json_selected
      IMPORTING
        ir_data        TYPE REF TO data
        iv_columns     TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS escape_json_string
      IMPORTING
        iv_value        TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.
ENDCLASS.



CLASS ZCL_MILO_SERIALIZER IMPLEMENTATION.


  METHOD escape_json_string.

    rv_value = iv_value.

    REPLACE ALL OCCURRENCES OF '\' IN rv_value WITH '\\'.
    REPLACE ALL OCCURRENCES OF '"' IN rv_value WITH '\"'.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN rv_value WITH '\n'.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN rv_value WITH '\n'.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>horizontal_tab IN rv_value WITH '\t'.

  ENDMETHOD.


  METHOD table_to_json.

    rv_json = /ui2/cl_json=>serialize(
      data        = ir_data
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

  ENDMETHOD.


  METHOD table_to_json_selected.

    DATA lt_json_rows TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_row_json  TYPE string.
    DATA lv_cell_json TYPE string.
    DATA lv_value     TYPE string.
    DATA lt_cols      TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_row>  TYPE any.
    FIELD-SYMBOLS <lv_cell> TYPE any.

    ASSIGN ir_data->* TO <lt_data>.
    IF sy-subrc <> 0.
      rv_json = '[]'.
      RETURN.
    ENDIF.

    SPLIT iv_columns AT ',' INTO TABLE lt_cols.

    LOOP AT <lt_data> ASSIGNING <ls_row>.

      CLEAR lv_row_json.
      lv_row_json = '{'.

      LOOP AT lt_cols INTO DATA(lv_col).

        lv_col = to_upper( condense( lv_col ) ).

        ASSIGN COMPONENT lv_col OF STRUCTURE <ls_row> TO <lv_cell>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        lv_value = CONV string( <lv_cell> ).

        lv_value = escape_json_string( lv_value ).

        IF lv_row_json <> '{'.
          lv_row_json = lv_row_json && ','.
        ENDIF.

        lv_cell_json = |"{ to_lower( lv_col ) }":"{ lv_value }"|.
        lv_row_json = lv_row_json && lv_cell_json.

      ENDLOOP.

      lv_row_json = lv_row_json && '}'.
      APPEND lv_row_json TO lt_json_rows.

    ENDLOOP.

    rv_json = '['.

    LOOP AT lt_json_rows INTO DATA(lv_json_row).
      IF rv_json <> '['.
        rv_json = rv_json && ','.
      ENDIF.
      rv_json = rv_json && lv_json_row.
    ENDLOOP.

    rv_json = rv_json && ']'.

  ENDMETHOD.
ENDCLASS.
