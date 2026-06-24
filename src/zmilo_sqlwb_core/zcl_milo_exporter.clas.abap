CLASS ZCL_milo_EXPORTER DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS table_to_csv
      IMPORTING
        ir_data       TYPE REF TO data
        iv_columns    TYPE string OPTIONAL
      RETURNING
        VALUE(rv_csv) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS escape_csv_value
      IMPORTING
        iv_value        TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.
ENDCLASS.



CLASS ZCL_MILO_EXPORTER IMPLEMENTATION.


  METHOD escape_csv_value.

    rv_value = iv_value.

    REPLACE ALL OCCURRENCES OF '"' IN rv_value WITH '""'.

    IF rv_value CS ','
       OR rv_value CS '"'
       OR rv_value CS cl_abap_char_utilities=>newline
       OR rv_value CS cl_abap_char_utilities=>cr_lf.
      rv_value = '"' && rv_value && '"'.
    ENDIF.

  ENDMETHOD.


  METHOD table_to_csv.

    DATA lt_cols TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_line TYPE string.
    DATA lv_value TYPE string.
    DATA lv_col TYPE string.
    DATA lo_table_descr TYPE REF TO cl_abap_tabledescr.
    DATA lo_line_descr TYPE REF TO cl_abap_structdescr.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.

    FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_row> TYPE any.
    FIELD-SYMBOLS <lv_cell> TYPE any.

    CLEAR rv_csv.

    ASSIGN ir_data->* TO <lt_data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF iv_columns IS INITIAL.
      TRY.
          lo_table_descr ?= cl_abap_typedescr=>describe_by_data_ref( ir_data ).
          lo_line_descr ?= lo_table_descr->get_table_line_type( ).
          lt_components = lo_line_descr->get_components( ).

          LOOP AT lt_components INTO DATA(ls_component).
            APPEND ls_component-name TO lt_cols.
          ENDLOOP.
        CATCH cx_root.
          RETURN.
      ENDTRY.
    ELSE.
      SPLIT iv_columns AT ',' INTO TABLE lt_cols.
    ENDIF.

    LOOP AT lt_cols INTO lv_col.
      lv_col = to_upper( condense( lv_col ) ).
      IF lv_col IS INITIAL.
        CONTINUE.
      ENDIF.

      IF lv_line IS NOT INITIAL.
        lv_line = lv_line && ','.
      ENDIF.
      lv_line = lv_line && escape_csv_value( lv_col ).
    ENDLOOP.

    rv_csv = lv_line.

    LOOP AT <lt_data> ASSIGNING <ls_row>.

      CLEAR lv_line.

      LOOP AT lt_cols INTO lv_col.
        lv_col = to_upper( condense( lv_col ) ).
        IF lv_col IS INITIAL.
          CONTINUE.
        ENDIF.

        ASSIGN COMPONENT lv_col OF STRUCTURE <ls_row> TO <lv_cell>.
        IF sy-subrc = 0.
          lv_value = CONV string( <lv_cell> ).
        ELSE.
          CLEAR lv_value.
        ENDIF.

        IF lv_line IS NOT INITIAL.
          lv_line = lv_line && ','.
        ENDIF.

        lv_line = lv_line && escape_csv_value( lv_value ).
      ENDLOOP.

      rv_csv = rv_csv && cl_abap_char_utilities=>cr_lf && lv_line.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
