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

    CLASS-METHODS fields_to_json
      IMPORTING
        it_field       TYPE zcl_milo_ddic_browser=>tt_field_info
      RETURNING
        VALUE(rv_json) TYPE string.

    CLASS-METHODS result_columns_to_json
      IMPORTING
        it_column      TYPE zcl_milo_result_repo=>tt_column
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


  METHOD fields_to_json.

    DATA lt_json_rows TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_row_json  TYPE string.
    DATA lv_fieldname TYPE string.
    DATA lv_rollname  TYPE string.
    DATA lv_datatype  TYPE string.
    DATA lv_ddtext    TYPE string.
    DATA lv_json_key  TYPE string.
    DATA lv_position  TYPE string.
    DATA lv_leng      TYPE string.
    DATA lv_decimals  TYPE string.
    DATA lv_position_i TYPE i.
    DATA lv_leng_i     TYPE i.
    DATA lv_decimals_i TYPE i.
    DATA lv_key       TYPE string.
    DATA lv_origin_type TYPE string.
    DATA lv_origin_structure TYPE string.
    DATA lv_include_depth TYPE string.
    DATA lv_include_depth_i TYPE i.

    LOOP AT it_field INTO DATA(ls_field).

      lv_fieldname = ls_field-fieldname.
      lv_rollname  = ls_field-rollname.
      lv_datatype  = ls_field-datatype.
      lv_ddtext    = ls_field-ddtext.
      lv_origin_type = ls_field-origin_type.
      lv_origin_structure = ls_field-origin_structure.
      lv_json_key  = to_lower( lv_fieldname ).
      lv_position_i = ls_field-position.
      lv_leng_i     = ls_field-leng.
      lv_decimals_i = ls_field-decimals.
      lv_include_depth_i = ls_field-include_depth.
      lv_position   = lv_position_i.
      lv_leng       = lv_leng_i.
      lv_decimals   = lv_decimals_i.
      lv_include_depth = lv_include_depth_i.

      lv_fieldname = escape_json_string( lv_fieldname ).
      lv_json_key  = escape_json_string( lv_json_key ).
      lv_rollname  = escape_json_string( lv_rollname ).
      lv_datatype  = escape_json_string( lv_datatype ).
      lv_ddtext    = escape_json_string( lv_ddtext ).
      lv_origin_type = escape_json_string( lv_origin_type ).
      lv_origin_structure = escape_json_string( lv_origin_structure ).


      lv_key = 'false'.
      IF ls_field-keyflag = abap_true OR ls_field-keyflag = 'X'.
        lv_key = 'true'.
      ENDIF.

      lv_row_json =
        '{"position":' && lv_position &&
        ',"fieldName":"' && lv_fieldname &&
        '","jsonKey":"' && lv_json_key &&
        '","element":"' && lv_rollname &&
        '","abapType":"' && lv_datatype &&
        '","length":' && lv_leng &&
        ',"decimals":' && lv_decimals &&
        ',"isKey":' && lv_key &&
                ',"label":"' && lv_ddtext &&
        '","originType":"' && lv_origin_type &&
        '","originStructure":"' && lv_origin_structure &&
        '","includeDepth":' && lv_include_depth && '}'.

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


  METHOD result_columns_to_json.

    DATA lt_json_rows TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_row_json  TYPE string.
    DATA lv_fieldname TYPE string.
    DATA lv_json_key  TYPE string.
    DATA lv_element   TYPE string.
    DATA lv_abap_type TYPE string.
    DATA lv_label     TYPE string.
    DATA lv_position  TYPE string.
    DATA lv_length    TYPE string.
    DATA lv_decimals  TYPE string.
    DATA lv_key       TYPE string.
    DATA lv_position_i TYPE i.
    DATA lv_length_i   TYPE i.
    DATA lv_decimals_i TYPE i.
    DATA lv_origin_type TYPE string.
    DATA lv_origin_structure TYPE string.
    DATA lv_include_depth TYPE string.
    DATA lv_include_depth_i TYPE i.

    LOOP AT it_column INTO DATA(ls_column).

      lv_fieldname = ls_column-field_name.
      lv_json_key  = ls_column-json_key.
      lv_element   = ls_column-element.
      lv_abap_type = ls_column-abap_type.
      lv_label     = ls_column-column_label.
      lv_origin_type = ls_column-origin_type.
      lv_origin_structure = ls_column-origin_structure.
      lv_position_i = ls_column-column_position.
      lv_length_i   = ls_column-length.
      lv_decimals_i = ls_column-decimals.
      lv_include_depth_i = ls_column-include_depth.
      lv_position   = lv_position_i.
      lv_length     = lv_length_i.
      lv_decimals   = lv_decimals_i.
      lv_include_depth = lv_include_depth_i.

      lv_fieldname = escape_json_string( lv_fieldname ).
      lv_json_key  = escape_json_string( lv_json_key ).
      lv_element   = escape_json_string( lv_element ).
      lv_abap_type = escape_json_string( lv_abap_type ).
      lv_label     = escape_json_string( lv_label ).
      lv_origin_type = escape_json_string( lv_origin_type ).
      lv_origin_structure = escape_json_string( lv_origin_structure ).


      lv_key = 'false'.
      IF ls_column-is_key = abap_true OR ls_column-is_key = 'X'.
        lv_key = 'true'.
      ENDIF.

      lv_row_json =
        '{"position":' && lv_position &&
        ',"fieldName":"' && lv_fieldname &&
        '","jsonKey":"' && lv_json_key &&
        '","element":"' && lv_element &&
        '","abapType":"' && lv_abap_type &&
        '","length":' && lv_length &&
        ',"decimals":' && lv_decimals &&
        ',"isKey":' && lv_key &&
                ',"label":"' && lv_label &&
        '","originType":"' && lv_origin_type &&
        '","originStructure":"' && lv_origin_structure &&
        '","includeDepth":' && lv_include_depth && '}'.

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
