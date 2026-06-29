*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_DDIC_BROWSER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmilo_test_ddic_browser.

PARAMETERS p_act  TYPE char8 DEFAULT 'SEARCH'.
PARAMETERS p_prof TYPE zmilo_profile_id DEFAULT 'DEV'.
PARAMETERS p_find TYPE string LOWER CASE DEFAULT 'SP*'.
PARAMETERS p_obj  TYPE zmilo_obj_name DEFAULT 'SPFLI'.
PARAMETERS p_max  TYPE i DEFAULT 50.

START-OF-SELECTION.

  DATA lv_action TYPE string.

  lv_action = to_upper( condense( p_act ) ).

  TRY.

      CASE lv_action.

        WHEN 'SEARCH'.
          DATA(lt_table) = zcl_milo_service=>search_ddic_tables(
            iv_profile_id = p_prof
            iv_search     = p_find
            iv_max_rows   = p_max ).

          IF lt_table IS INITIAL.
            WRITE: / 'NO TABLES FOUND'.
            RETURN.
          ENDIF.

          LOOP AT lt_table INTO DATA(ls_table).
            WRITE: / '--------------------------------'.
            WRITE: / 'TABLE:', ls_table-tabname.
            WRITE: / 'CLASS:', ls_table-tabclass.
            WRITE: / 'TEXT:', ls_table-ddtext.
          ENDLOOP.

        WHEN 'FIELDS'.
          DATA(lt_field) = zcl_milo_service=>get_ddic_fields(
            iv_profile_id = p_prof
            iv_obj_name   = p_obj ).

          IF lt_field IS INITIAL.
            WRITE: / 'NO FIELDS FOUND'.
            RETURN.
          ENDIF.

          LOOP AT lt_field INTO DATA(ls_field).
            WRITE: / '--------------------------------'.
            WRITE: / 'POS:', ls_field-position.
            WRITE: / 'KEY:', ls_field-keyflag.
            WRITE: / 'FIELD:', ls_field-fieldname.
            WRITE: / 'ELEMENT:', ls_field-rollname.
            WRITE: / 'TYPE:', ls_field-datatype.
            WRITE: / 'LENGTH:', ls_field-leng.
            WRITE: / 'DECIMALS:', ls_field-decimals.
            WRITE: / 'TEXT:', ls_field-ddtext.
          ENDLOOP.

        WHEN 'PREVIEW'.
          DATA lv_obj       TYPE zmilo_obj_name.
          DATA lv_row_count TYPE i.
          DATA lv_json      TYPE string.

          zcl_milo_service=>preview_table(
            EXPORTING
              iv_profile_id  = p_prof
              iv_obj_name    = p_obj
              iv_row_limit   = p_max
            IMPORTING
              ev_object_name = lv_obj
              ev_row_count   = lv_row_count
              ev_rows_json   = lv_json ).

          WRITE: / 'OBJECT:', lv_obj.
          WRITE: / 'ROWS:', lv_row_count.
          WRITE: / 'JSON:'.
          WRITE: / lv_json.

        WHEN OTHERS.
          WRITE: / 'UNKNOWN ACTION:', p_act.
          WRITE: / 'VALID ACTIONS: SEARCH, FIELDS, PREVIEW'.

      ENDCASE.

    CATCH zcx_milo_validation INTO DATA(lx_validation).

      WRITE: / 'DDIC BROWSER ERROR'.
      WRITE: / 'REASON:', lx_validation->get_text( ).

  ENDTRY.
