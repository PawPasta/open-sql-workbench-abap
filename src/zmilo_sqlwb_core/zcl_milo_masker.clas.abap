CLASS zcl_milo_masker DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS apply_mask
      IMPORTING
        iv_mask_profile_id TYPE zmilo_mask_profile_id
        iv_obj_name        TYPE zmilo_obj_name
        ir_data            TYPE REF TO data.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS mask_value
      IMPORTING
        iv_value        TYPE string
        iv_mask_type    TYPE zmilo_mask_type
        iv_mask_value   TYPE zmilo_mask_value
      RETURNING
        VALUE(rv_value) TYPE string.

ENDCLASS.



CLASS ZCL_MILO_MASKER IMPLEMENTATION.


  METHOD apply_mask.

    DATA lt_mask TYPE zcl_milo_config=>tt_mask.

    FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_row>  TYPE any.
    FIELD-SYMBOLS <lv_cell> TYPE any.

    lt_mask = zcl_milo_config=>get_mask_rules(
      iv_mask_profile_id = iv_mask_profile_id
      iv_obj_name        = iv_obj_name ).

    IF lt_mask IS INITIAL.
      RETURN.
    ENDIF.

    ASSIGN ir_data->* TO <lt_data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT <lt_data> ASSIGNING <ls_row>.
      LOOP AT lt_mask ASSIGNING FIELD-SYMBOL(<ls_mask>).

        ASSIGN COMPONENT <ls_mask>-field_name OF STRUCTURE <ls_row> TO <lv_cell>.
        IF sy-subrc = 0.

          DATA(lv_string) = CONV string( <lv_cell> ).

          lv_string = mask_value(
            iv_value      = lv_string
            iv_mask_type  = <ls_mask>-mask_type
            iv_mask_value = <ls_mask>-mask_value ).

          <lv_cell> = lv_string.

        ENDIF.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD mask_value.

    DATA lv_len TYPE i.

    rv_value = iv_value.

    CASE iv_mask_type.

      WHEN 'FULL'.
        IF iv_mask_value IS NOT INITIAL.
          rv_value = iv_mask_value.
        ELSE.
          rv_value = '[HIDDEN]'.
        ENDIF.

      WHEN 'REPLACE'.
        rv_value = iv_mask_value.

      WHEN 'PARTIAL'.
        lv_len = strlen( iv_value ).

        IF lv_len <= 3.
          rv_value = '***'.
        ELSE.
          rv_value = iv_value+0(3) && '***'.
        ENDIF.

      WHEN OTHERS.
        rv_value = iv_value.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
