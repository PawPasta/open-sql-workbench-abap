CLASS zcl_milo_ddic_browser DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_table_info,
        tabname  TYPE dd02l-tabname,
        tabclass TYPE dd02l-tabclass,
        ddtext   TYPE dd02t-ddtext,
      END OF ty_table_info.

    TYPES tt_table_info TYPE STANDARD TABLE OF ty_table_info WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_field_info,
        position         TYPE dd03l-position,
        keyflag          TYPE dd03l-keyflag,
        fieldname        TYPE dd03l-fieldname,
        rollname         TYPE dd03l-rollname,
        datatype         TYPE dd03l-datatype,
        leng             TYPE dd03l-leng,
        decimals         TYPE dd03l-decimals,
        ddtext           TYPE dd03t-ddtext,
        origin_type      TYPE c LENGTH 10,
        origin_structure TYPE dd03l-precfield,
        include_depth    TYPE dd03l-adminfield,
      END OF ty_field_info.

    TYPES tt_field_info TYPE STANDARD TABLE OF ty_field_info WITH EMPTY KEY.

    CLASS-METHODS search_tables
      IMPORTING
        iv_search       TYPE string
        iv_max_rows     TYPE i DEFAULT 50
      RETURNING
        VALUE(rt_table) TYPE tt_table_info.

    CLASS-METHODS get_fields
      IMPORTING
        iv_obj_name     TYPE zmilo_obj_name
      RETURNING
        VALUE(rt_field) TYPE tt_field_info
      RAISING
        zcx_milo_validation.

    CLASS-METHODS preview_table
      IMPORTING
        iv_wlist_profile_id TYPE zmilo_wlist_profile_id
        iv_mask_profile_id  TYPE zmilo_mask_profile_id OPTIONAL
        iv_obj_name         TYPE zmilo_obj_name
        iv_row_limit        TYPE i DEFAULT 100
        iv_page             TYPE i DEFAULT 1
      EXPORTING
        ev_object_name      TYPE zmilo_obj_name
        ev_row_count        TYPE i
        ev_total_rows       TYPE i
        ev_rows_json        TYPE string
      RAISING
        zcx_milo_validation.

    CLASS-METHODS preview_table_csv
      IMPORTING
        iv_wlist_profile_id TYPE zmilo_wlist_profile_id
        iv_mask_profile_id  TYPE zmilo_mask_profile_id OPTIONAL
        iv_obj_name         TYPE zmilo_obj_name
        iv_row_limit        TYPE i DEFAULT 100
        iv_page             TYPE i DEFAULT 1
      EXPORTING
        ev_object_name      TYPE zmilo_obj_name
        ev_row_count        TYPE i
        ev_total_rows       TYPE i
        ev_csv              TYPE string
      RAISING
        zcx_milo_validation.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MILO_DDIC_BROWSER IMPLEMENTATION.


  METHOD get_fields.

    DATA lv_obj_name TYPE zmilo_obj_name.
    DATA lv_depth TYPE i.
    DATA lv_child_depth TYPE i.

    TYPES:
      BEGIN OF ty_ddic_entry,
        position   TYPE dd03l-position,
        keyflag    TYPE dd03l-keyflag,
        fieldname  TYPE dd03l-fieldname,
        rollname   TYPE dd03l-rollname,
        datatype   TYPE dd03l-datatype,
        leng       TYPE dd03l-leng,
        decimals   TYPE dd03l-decimals,
        precfield  TYPE dd03l-precfield,
        adminfield TYPE dd03l-adminfield,
      END OF ty_ddic_entry.

    TYPES:
      BEGIN OF ty_include_context,
        depth            TYPE i,
        origin_type      TYPE c LENGTH 10,
        origin_structure TYPE dd03l-precfield,
      END OF ty_include_context.

    DATA lt_ddic_entry TYPE STANDARD TABLE OF ty_ddic_entry
          WITH EMPTY KEY.
    DATA lt_include_context TYPE STANDARD TABLE OF ty_include_context
      WITH EMPTY KEY.

    lv_obj_name = to_upper( iv_obj_name ).

    IF lv_obj_name IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>parse_failed.
    ENDIF.

    SELECT position,
           keyflag,
           fieldname,
           rollname,
           datatype,
           leng,
                      decimals,
           precfield,
           adminfield
      FROM dd03l
      WHERE tabname  = @lv_obj_name
        AND as4local = 'A'
      ORDER BY position
      INTO CORRESPONDING FIELDS OF TABLE @lt_ddic_entry.

    IF lt_ddic_entry IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid         = zcx_milo_validation=>object_not_allowed
          mv_object_name = lv_obj_name.
    ENDIF.

    LOOP AT lt_ddic_entry INTO DATA(ls_ddic_entry).
      lv_depth = ls_ddic_entry-adminfield.

      IF ls_ddic_entry-fieldname CP '.INCLU*'.
        lv_child_depth = lv_depth + 1.

        DELETE lt_include_context
          WHERE depth >= lv_child_depth.

        DATA(ls_include_context) = VALUE ty_include_context(
          depth            = lv_child_depth
          origin_structure = ls_ddic_entry-precfield
          origin_type      = 'INCLUDE' ).

        IF ls_ddic_entry-fieldname CP '.INCLU--AP*'.
          ls_include_context-origin_type = 'APPEND'.
        ELSEIF lv_depth > 0.
          READ TABLE lt_include_context INTO DATA(ls_parent_context)
            WITH KEY depth = lv_depth.
          IF sy-subrc = 0 AND ls_parent_context-origin_type = 'APPEND'.
            ls_include_context-origin_type = 'APPEND'.
          ENDIF.
        ENDIF.

        APPEND ls_include_context TO lt_include_context.
        CONTINUE.
      ENDIF.

      APPEND INITIAL LINE TO rt_field ASSIGNING FIELD-SYMBOL(<ls_field>).
      <ls_field>-position      = ls_ddic_entry-position.
      <ls_field>-keyflag       = ls_ddic_entry-keyflag.
      <ls_field>-fieldname     = ls_ddic_entry-fieldname.
      <ls_field>-rollname      = ls_ddic_entry-rollname.
      <ls_field>-datatype      = ls_ddic_entry-datatype.
      <ls_field>-leng          = ls_ddic_entry-leng.
      <ls_field>-decimals      = ls_ddic_entry-decimals.
      <ls_field>-include_depth = ls_ddic_entry-adminfield.


      IF lv_depth = 0.
        <ls_field>-origin_type = 'DIRECT'.

      ELSE.
        READ TABLE lt_include_context INTO ls_include_context
          WITH KEY depth = lv_depth.

        IF sy-subrc = 0.
          <ls_field>-origin_type = ls_include_context-origin_type.
          <ls_field>-origin_structure =
            ls_include_context-origin_structure.
        ELSE.
          <ls_field>-origin_type = 'INCLUDE'.
        ENDIF.
      ENDIF.

      SELECT SINGLE ddtext
        FROM dd03t
        WHERE tabname    = @lv_obj_name
          AND fieldname  = @<ls_field>-fieldname
          AND ddlanguage = @sy-langu
          AND as4local   = 'A'
        INTO @<ls_field>-ddtext.
    ENDLOOP.

  ENDMETHOD.


  METHOD preview_table.

    DATA lr_table   TYPE REF TO data.
    DATA lv_obj_name TYPE zmilo_obj_name.
    DATA lv_row_limit TYPE i.
    DATA lv_page TYPE i.
    DATA lv_offset TYPE i.
    DATA lv_columns TYPE string.
    DATA lv_field_count TYPE i.
    DATA lt_field TYPE tt_field_info.
    DATA lt_result_field TYPE tt_field_info.

    FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.

    CLEAR: ev_object_name,
           ev_row_count,
           ev_total_rows,
           ev_rows_json.

    lv_obj_name = to_upper( iv_obj_name ).

    IF lv_obj_name IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>parse_failed.
    ENDIF.

    IF zcl_milo_config=>is_object_allowed(
         iv_wlist_profile_id = iv_wlist_profile_id
         iv_obj_name         = lv_obj_name ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid         = zcx_milo_validation=>object_not_allowed
          mv_object_name = lv_obj_name.
    ENDIF.

    lv_row_limit = iv_row_limit.
    IF lv_row_limit IS INITIAL OR lv_row_limit > 100.
      lv_row_limit = 100.
    ENDIF.

    lv_page = iv_page.
    IF lv_page IS INITIAL OR lv_page < 1.
      lv_page = 1.
    ENDIF.
    lv_offset = ( lv_page - 1 ) * lv_row_limit.

    ev_object_name = lv_obj_name.

    CREATE DATA lr_table TYPE STANDARD TABLE OF (lv_obj_name).
    ASSIGN lr_table->* TO <lt_data>.

    SELECT COUNT(*)
      FROM (lv_obj_name)
      INTO @ev_total_rows.

    SELECT *
      FROM (lv_obj_name)
      ORDER BY PRIMARY KEY
      INTO TABLE @<lt_data>
      UP TO @lv_row_limit ROWS
      OFFSET @lv_offset.

    ev_row_count = lines( <lt_data> ).

    IF iv_mask_profile_id IS NOT INITIAL.
      zcl_milo_masker=>apply_mask(
        iv_mask_profile_id = iv_mask_profile_id
        iv_obj_name        = lv_obj_name
        ir_data            = lr_table ).
    ENDIF.

    lt_field = get_fields( lv_obj_name ).

    LOOP AT lt_field INTO DATA(ls_field).
      lv_field_count = lv_field_count + 1.
      IF lv_field_count > zcl_milo_config=>c_max_select_fields.
        EXIT.
      ENDIF.
      APPEND ls_field TO lt_result_field.
    ENDLOOP.

    LOOP AT lt_result_field INTO DATA(ls_result_field).
      IF lv_columns IS INITIAL.
        lv_columns = ls_result_field-fieldname.
      ELSE.
        lv_columns = lv_columns && ',' && ls_result_field-fieldname.
      ENDIF.
    ENDLOOP.

    IF lv_columns IS INITIAL.
      ev_rows_json = zcl_milo_serializer=>table_to_json( lr_table ).
    ELSE.
      ev_rows_json = zcl_milo_serializer=>table_to_json_selected(
        ir_data    = lr_table
        iv_columns = lv_columns ).
    ENDIF.

  ENDMETHOD.


  METHOD preview_table_csv.

    DATA lr_table TYPE REF TO data.
    DATA lv_obj_name TYPE zmilo_obj_name.
    DATA lv_row_limit TYPE i.
    DATA lv_page TYPE i.
    DATA lv_offset TYPE i.

    FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.

    CLEAR: ev_object_name,
           ev_row_count,
           ev_total_rows,
           ev_csv.

    lv_obj_name = to_upper( iv_obj_name ).

    IF lv_obj_name IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>parse_failed.
    ENDIF.

    IF zcl_milo_config=>is_object_allowed(
         iv_wlist_profile_id = iv_wlist_profile_id
         iv_obj_name         = lv_obj_name ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid         = zcx_milo_validation=>object_not_allowed
          mv_object_name = lv_obj_name.
    ENDIF.

    lv_row_limit = iv_row_limit.
    IF lv_row_limit IS INITIAL OR lv_row_limit > 100.
      lv_row_limit = 100.
    ENDIF.

    lv_page = iv_page.
    IF lv_page IS INITIAL OR lv_page < 1.
      lv_page = 1.
    ENDIF.
    lv_offset = ( lv_page - 1 ) * lv_row_limit.

    ev_object_name = lv_obj_name.

    CREATE DATA lr_table TYPE STANDARD TABLE OF (lv_obj_name).
    ASSIGN lr_table->* TO <lt_data>.

    SELECT COUNT(*)
      FROM (lv_obj_name)
      INTO @ev_total_rows.

    SELECT *
      FROM (lv_obj_name)
      ORDER BY PRIMARY KEY
      INTO TABLE @<lt_data>
      UP TO @lv_row_limit ROWS
      OFFSET @lv_offset.

    ev_row_count = lines( <lt_data> ).

    IF iv_mask_profile_id IS NOT INITIAL.
      zcl_milo_masker=>apply_mask(
        iv_mask_profile_id = iv_mask_profile_id
        iv_obj_name        = lv_obj_name
        ir_data            = lr_table ).
    ENDIF.

    ev_csv = zcl_milo_exporter=>table_to_csv( lr_table ).

  ENDMETHOD.


  METHOD search_tables.

    DATA lv_pattern TYPE string.
    DATA lv_max_rows TYPE i.

    lv_pattern = to_upper( condense( iv_search ) ).

    IF lv_pattern IS INITIAL.
      lv_pattern = '%'.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '*' IN lv_pattern WITH '%'.

    IF lv_pattern NS '%'.
      lv_pattern = '%' && lv_pattern && '%'.
    ENDIF.

    lv_max_rows = iv_max_rows.
    IF lv_max_rows IS INITIAL OR lv_max_rows > 200.
      lv_max_rows = 50.
    ENDIF.

    SELECT l~tabname,
           l~tabclass,
           t~ddtext
      FROM dd02l AS l
      LEFT OUTER JOIN dd02t AS t
        ON  t~tabname    = l~tabname
        AND t~ddlanguage = @sy-langu
        AND t~as4local   = 'A'
      WHERE l~as4local = 'A'
        AND ( l~tabclass = 'TRANSP'
           OR l~tabclass = 'VIEW' )
        AND ( l~tabname LIKE @lv_pattern
           OR t~ddtext  LIKE @lv_pattern )
      ORDER BY l~tabname
      INTO TABLE @rt_table
      UP TO @lv_max_rows ROWS.

  ENDMETHOD.
ENDCLASS.
