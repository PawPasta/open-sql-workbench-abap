CLASS zcl_milo_result_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS c_chunk_size TYPE i VALUE 900.
    TYPES tt_head   TYPE STANDARD TABLE OF zmilo_rhead WITH EMPTY KEY.
    TYPES tt_column TYPE STANDARD TABLE OF zmilo_rcol WITH EMPTY KEY.
    TYPES tt_page   TYPE STANDARD TABLE OF zmilo_rpage WITH EMPTY KEY.

    CLASS-METHODS create_result_id
      RETURNING
        VALUE(rv_result_id) TYPE sysuuid_x16.

    CLASS-METHODS result_id_to_c32
      IMPORTING
        iv_result_id        TYPE sysuuid_x16
      RETURNING
        VALUE(rv_result_id) TYPE string.

    CLASS-METHODS result_id_from_c32
      IMPORTING
        iv_result_id        TYPE string
      RETURNING
        VALUE(rv_result_id) TYPE sysuuid_x16.

    CLASS-METHODS save_result
      IMPORTING
        is_head   TYPE zmilo_rhead
        it_column TYPE tt_column
        it_page   TYPE tt_page.

    CLASS-METHODS build_page_chunks
      IMPORTING
        iv_result_id   TYPE sysuuid_x16
        iv_page_no     TYPE i
        iv_rows_json   TYPE string
      RETURNING
        VALUE(rt_page) TYPE tt_page.

    CLASS-METHODS get_head
      IMPORTING
        iv_result_id   TYPE sysuuid_x16
      RETURNING
        VALUE(rs_head) TYPE zmilo_rhead.

    CLASS-METHODS list_columns
      IMPORTING
        iv_result_id     TYPE sysuuid_x16
      RETURNING
        VALUE(rt_column) TYPE tt_column.

    CLASS-METHODS list_page_chunks
      IMPORTING
        iv_result_id   TYPE sysuuid_x16
        iv_page_no     TYPE i
      RETURNING
        VALUE(rt_page) TYPE tt_page.

    CLASS-METHODS delete_result
      IMPORTING
        iv_result_id TYPE sysuuid_x16.

    CLASS-METHODS cleanup_expired.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS is_result_visible
      IMPORTING
        iv_result_id      TYPE sysuuid_x16
      RETURNING
        VALUE(rv_visible) TYPE abap_bool.

ENDCLASS.



CLASS ZCL_MILO_RESULT_REPO IMPLEMENTATION.


  METHOD build_page_chunks.

    DATA lv_offset       TYPE i.
    DATA lv_length       TYPE i.
    DATA lv_remaining    TYPE i.
    DATA lv_take         TYPE i.
    DATA lv_chunk_no     TYPE i.
    DATA lv_payload_part TYPE string.
    DATA ls_page         TYPE zmilo_rpage.
    DATA lv_created_at   TYPE timestampl.

    lv_length = strlen( iv_rows_json ).

    IF lv_length = 0.
      RETURN.
    ENDIF.

    GET TIME STAMP FIELD lv_created_at.

    WHILE lv_offset < lv_length.

      lv_chunk_no = lv_chunk_no + 1.
      lv_remaining = lv_length - lv_offset.
      lv_take = c_chunk_size.

      IF lv_remaining < lv_take.
        lv_take = lv_remaining.
      ENDIF.

      lv_payload_part = iv_rows_json+lv_offset(lv_take).

      CLEAR ls_page.
      ls_page-mandt = sy-mandt.
      ls_page-result_id = iv_result_id.
      ls_page-page_no = iv_page_no.
      ls_page-chunk_no = lv_chunk_no.
      ls_page-payload_part = lv_payload_part.
      ls_page-payload_len = strlen( lv_payload_part ).
      ls_page-created_at = lv_created_at.

      lv_offset = lv_offset + lv_take.

      IF lv_offset >= lv_length.
        ls_page-is_last_chunk = abap_true.
      ENDIF.

      APPEND ls_page TO rt_page.

    ENDWHILE.

  ENDMETHOD.


  METHOD cleanup_expired.

    DATA lv_now  TYPE timestampl.
    DATA lt_head TYPE tt_head.

    GET TIME STAMP FIELD lv_now.

    SELECT *
      FROM zmilo_rhead
      INTO TABLE @lt_head.

    LOOP AT lt_head INTO DATA(ls_head).

      TRY.

          IF ( ls_head-expires_at IS NOT INITIAL
               AND ls_head-expires_at <= lv_now ).

            delete_result( ls_head-result_id ).

          ENDIF.

        CATCH cx_root.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.


  METHOD create_result_id.

    CLEAR rv_result_id.

    TRY.
        rv_result_id = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        CLEAR rv_result_id.
    ENDTRY.

  ENDMETHOD.


  METHOD delete_result.

    DELETE FROM zmilo_rpage
      WHERE result_id = @iv_result_id.

    DELETE FROM zmilo_rcol
      WHERE result_id = @iv_result_id.

    DELETE FROM zmilo_rhead
      WHERE result_id = @iv_result_id.

    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD get_head.

    SELECT SINGLE *
      FROM zmilo_rhead
      WHERE result_id = @iv_result_id
        AND user_name = @sy-uname
      INTO @rs_head.

  ENDMETHOD.


  METHOD is_result_visible.

    DATA ls_head TYPE zmilo_rhead.

    ls_head = get_head( iv_result_id ).
    rv_visible = xsdbool( ls_head-result_id IS NOT INITIAL ).

  ENDMETHOD.


  METHOD list_columns.

    IF is_result_visible( iv_result_id ) <> abap_true.
      RETURN.
    ENDIF.

    SELECT *
      FROM zmilo_rcol
      WHERE result_id = @iv_result_id
      ORDER BY column_position
      INTO TABLE @rt_column.

  ENDMETHOD.


  METHOD list_page_chunks.

    IF is_result_visible( iv_result_id ) <> abap_true.
      RETURN.
    ENDIF.

    SELECT *
      FROM zmilo_rpage
      WHERE result_id = @iv_result_id
        AND page_no   = @iv_page_no
      ORDER BY chunk_no
      INTO TABLE @rt_page.

  ENDMETHOD.


  METHOD result_id_from_c32.

    DATA lv_uuid_c32 TYPE sysuuid_c32.

    CLEAR rv_result_id.
    lv_uuid_c32 = iv_result_id.
    TRANSLATE lv_uuid_c32 TO UPPER CASE.

    TRY.
        CALL METHOD cl_system_uuid=>convert_uuid_c32_static
          EXPORTING
            uuid     = lv_uuid_c32
          IMPORTING
            uuid_x16 = rv_result_id.
      CATCH cx_uuid_error.
        CLEAR rv_result_id.
    ENDTRY.

  ENDMETHOD.


  METHOD result_id_to_c32.

    DATA lv_uuid_c32 TYPE sysuuid_c32.

    CLEAR rv_result_id.

    TRY.
        CALL METHOD cl_system_uuid=>convert_uuid_x16_static
          EXPORTING
            uuid     = iv_result_id
          IMPORTING
            uuid_c32 = lv_uuid_c32.
        rv_result_id = lv_uuid_c32.
      CATCH cx_uuid_error.
        CLEAR rv_result_id.
    ENDTRY.

  ENDMETHOD.


  METHOD save_result.

    DATA ls_head   TYPE zmilo_rhead.
    DATA lt_column TYPE tt_column.
    DATA lt_page   TYPE tt_page.

    ls_head   = is_head.
    lt_column = it_column.
    lt_page   = it_page.

    IF ls_head-result_id IS INITIAL.
      RETURN.
    ENDIF.

    ls_head-mandt = sy-mandt.
    IF ls_head-user_name IS INITIAL.
      ls_head-user_name = sy-uname.
    ENDIF.
    IF ls_head-created_at IS INITIAL.
      GET TIME STAMP FIELD ls_head-created_at.
    ENDIF.

    DELETE FROM zmilo_rpage
      WHERE result_id = @ls_head-result_id.

    DELETE FROM zmilo_rcol
      WHERE result_id = @ls_head-result_id.

    DELETE FROM zmilo_rhead
      WHERE result_id = @ls_head-result_id.

    LOOP AT lt_column ASSIGNING FIELD-SYMBOL(<ls_column>).
      <ls_column>-mandt = sy-mandt.
      <ls_column>-result_id = ls_head-result_id.
    ENDLOOP.

    LOOP AT lt_page ASSIGNING FIELD-SYMBOL(<ls_page>).
      <ls_page>-mandt = sy-mandt.
      <ls_page>-result_id = ls_head-result_id.
    ENDLOOP.

    INSERT zmilo_rhead FROM @ls_head.

    IF lt_column IS NOT INITIAL.
      INSERT zmilo_rcol FROM TABLE @lt_column.
    ENDIF.

    IF lt_page IS NOT INITIAL.
      INSERT zmilo_rpage FROM TABLE @lt_page.
    ENDIF.

    COMMIT WORK AND WAIT.

  ENDMETHOD.
ENDCLASS.
