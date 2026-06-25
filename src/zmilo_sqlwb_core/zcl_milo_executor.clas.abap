CLASS zcl_milo_executor DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS execute_select
      IMPORTING
        iv_sql              TYPE string
        iv_wlist_profile_id TYPE zmilo_wlist_profile_id
        iv_mask_profile_id  TYPE zmilo_mask_profile_id OPTIONAL
        iv_page             TYPE i DEFAULT 1
      EXPORTING
        ev_object_name      TYPE zmilo_obj_name
        ev_row_count        TYPE i
        ev_returned_rows    TYPE i
        ev_status           TYPE string
        ev_max_rows         TYPE i
        ev_truncated        TYPE abap_bool
        ev_rows_json        TYPE string
      RAISING
        zcx_milo_validation.

    CLASS-METHODS execute_saved_query
      IMPORTING
        iv_query_id         TYPE sysuuid_x16
        iv_wlist_profile_id TYPE zmilo_wlist_profile_id
        iv_mask_profile_id  TYPE zmilo_mask_profile_id OPTIONAL
        iv_page             TYPE i DEFAULT 1
      EXPORTING
        ev_object_name      TYPE zmilo_obj_name
        ev_row_count        TYPE i
        ev_returned_rows    TYPE i
        ev_status           TYPE string
        ev_max_rows         TYPE i
        ev_truncated        TYPE abap_bool
        ev_rows_json        TYPE string
      RAISING
        zcx_milo_validation.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS execute_join_select
      IMPORTING
        is_parts            TYPE zcl_milo_sql_parser=>ty_query_parts
        iv_wlist_profile_id TYPE zmilo_wlist_profile_id
        iv_mask_profile_id  TYPE zmilo_mask_profile_id OPTIONAL
        iv_page             TYPE i
      EXPORTING
        ev_object_name      TYPE zmilo_obj_name
        ev_row_count        TYPE i
        ev_returned_rows    TYPE i
        ev_max_rows         TYPE i
        ev_truncated        TYPE abap_bool
        ev_rows_json        TYPE string
      RAISING
        zcx_milo_validation
        cx_sy_dynamic_osql_syntax
        cx_sy_dynamic_osql_semantics.

    CLASS-METHODS execute_group_select
      IMPORTING
        is_parts            TYPE zcl_milo_sql_parser=>ty_query_parts
        iv_wlist_profile_id TYPE zmilo_wlist_profile_id
        iv_page             TYPE i
      EXPORTING
        ev_object_name      TYPE zmilo_obj_name
        ev_row_count        TYPE i
        ev_returned_rows    TYPE i
        ev_max_rows         TYPE i
        ev_truncated        TYPE abap_bool
        ev_rows_json        TYPE string
      RAISING
        zcx_milo_validation
        cx_sy_dynamic_osql_syntax
        cx_sy_dynamic_osql_semantics.

    CLASS-METHODS apply_join_mask
      IMPORTING
        is_parts           TYPE zcl_milo_sql_parser=>ty_query_parts
        iv_mask_profile_id TYPE zmilo_mask_profile_id
        ir_data            TYPE REF TO data.

    CLASS-METHODS get_join_field_type
      IMPORTING
        is_parts        TYPE zcl_milo_sql_parser=>ty_query_parts
        iv_source_alias TYPE string
        iv_field_name   TYPE zmilo_field_name
      RETURNING
        VALUE(ro_type)  TYPE REF TO cl_abap_datadescr
      RAISING
        zcx_milo_validation.

    CLASS-METHODS get_object_field_type
      IMPORTING
        iv_object_name TYPE zmilo_obj_name
        iv_field_name  TYPE zmilo_field_name
      RETURNING
        VALUE(ro_type) TYPE REF TO cl_abap_datadescr
      RAISING
        zcx_milo_validation.

    CLASS-METHODS mask_join_value
      IMPORTING
        iv_value        TYPE string
        iv_mask_type    TYPE zmilo_mask_type
        iv_mask_value   TYPE zmilo_mask_value
      RETURNING
        VALUE(rv_value) TYPE string.
ENDCLASS.



CLASS ZCL_MILO_EXECUTOR IMPLEMENTATION.


  METHOD apply_join_mask.

    DATA lt_mask TYPE zcl_milo_config=>tt_mask.
    DATA lv_source_object TYPE zmilo_obj_name.
    DATA lv_component TYPE string.
    DATA lv_value TYPE string.

    FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_row> TYPE any.
    FIELD-SYMBOLS <lv_cell> TYPE any.

    IF iv_mask_profile_id IS INITIAL.
      RETURN.
    ENDIF.

    ASSIGN ir_data->* TO <lt_data>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT is_parts-fields INTO DATA(ls_field).

      CLEAR lv_source_object.

      LOOP AT is_parts-sources INTO DATA(ls_source).
        IF ls_source-alias = ls_field-source_alias.
          lv_source_object = ls_source-object_name.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_source_object IS INITIAL.
        CONTINUE.
      ENDIF.

      lt_mask = zcl_milo_config=>get_mask_rules(
        iv_mask_profile_id = iv_mask_profile_id
        iv_obj_name        = lv_source_object ).

      READ TABLE lt_mask INTO DATA(ls_mask)
        WITH KEY field_name = ls_field-field_name.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      lv_component = to_upper( ls_field-output_key ).

      LOOP AT <lt_data> ASSIGNING <ls_row>.
        ASSIGN COMPONENT lv_component OF STRUCTURE <ls_row> TO <lv_cell>.
        IF sy-subrc = 0.
          lv_value = CONV string( <lv_cell> ).
          lv_value = mask_join_value(
            iv_value      = lv_value
            iv_mask_type  = ls_mask-mask_type
            iv_mask_value = ls_mask-mask_value ).
          <lv_cell> = lv_value.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD execute_group_select.

    DATA lr_table TYPE REF TO data.
    DATA lv_page TYPE i.
    DATA lv_offset TYPE i.
    DATA lv_from TYPE string.
    DATA lv_select TYPE string.
    DATA lv_json_columns TYPE string.
    DATA lv_component TYPE string.
    DATA lv_select_part TYPE string.
    DATA lv_select_field TYPE string.
    DATA lo_field_type TYPE REF TO cl_abap_datadescr.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA ls_component LIKE LINE OF lt_components.
    DATA lo_struct_descr TYPE REF TO cl_abap_structdescr.
    DATA lo_table_descr TYPE REF TO cl_abap_tabledescr.

    FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.

    CLEAR: ev_object_name,
           ev_row_count,
           ev_returned_rows,
           ev_max_rows,
           ev_truncated,
           ev_rows_json.

    ev_object_name = is_parts-table_name.

    ev_max_rows = zcl_milo_config=>get_object_max_rows(
      iv_wlist_profile_id = iv_wlist_profile_id
      iv_obj_name         = ev_object_name ).

    lv_page = iv_page.
    IF lv_page IS INITIAL OR lv_page < 1.
      lv_page = 1.
    ENDIF.

    IF lv_page > 1 AND is_parts-order_sql IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>invalid_order_by.
    ENDIF.

    lv_offset = ( lv_page - 1 ) * ev_max_rows.

    IF is_parts-is_join = abap_true.
      lv_from = is_parts-from_sql.
    ELSE.
      lv_from = is_parts-table_name.
    ENDIF.

    LOOP AT is_parts-fields INTO DATA(ls_field).

      lv_component = to_upper( ls_field-output_key ).

      IF ls_field-is_aggregate = abap_true.

        IF ls_field-agg_func = 'COUNT' AND ls_field-field_name = '*'.
          lv_select_part = |COUNT( * ) AS { lv_component }|.
          lo_field_type = cl_abap_elemdescr=>get_i( ).
        ELSE.
          lv_select_field = condense( CONV string( ls_field-field_name ) ).
          IF ls_field-is_distinct = abap_true.
            IF is_parts-is_join = abap_true.
              lv_select_part = |COUNT( DISTINCT { ls_field-source_alias }~{ lv_select_field } ) AS { lv_component }|.
            ELSE.
              lv_select_part = |COUNT( DISTINCT { lv_select_field } ) AS { lv_component }|.
            ENDIF.
          ELSEIF is_parts-is_join = abap_true.
            lv_select_part = |{ ls_field-agg_func }( { ls_field-source_alias }~{ lv_select_field } ) AS { lv_component }|.
          ELSE.
            lv_select_part = |{ ls_field-agg_func }( { lv_select_field } ) AS { lv_component }|.
          ENDIF.

          IF ls_field-agg_func = 'COUNT'.
            lo_field_type = cl_abap_elemdescr=>get_i( ).
          ELSEIF ls_field-agg_func = 'AVG'.
            lo_field_type = cl_abap_elemdescr=>get_decfloat34( ).
          ELSEIF is_parts-is_join = abap_true.
            lo_field_type = get_join_field_type(
              is_parts        = is_parts
              iv_source_alias = ls_field-source_alias
              iv_field_name   = ls_field-field_name ).
          ELSE.
            lo_field_type = get_object_field_type(
              iv_object_name = is_parts-table_name
              iv_field_name  = ls_field-field_name ).
          ENDIF.
        ENDIF.

      ELSE.

        lv_select_field = condense( CONV string( ls_field-field_name ) ).
        IF is_parts-is_join = abap_true.
          lv_select_part = |{ ls_field-source_alias }~{ lv_select_field } AS { lv_component }|.
          lo_field_type = get_join_field_type(
            is_parts        = is_parts
            iv_source_alias = ls_field-source_alias
            iv_field_name   = ls_field-field_name ).
        ELSE.
          lv_select_part = |{ lv_select_field } AS { lv_component }|.
          lo_field_type = get_object_field_type(
            iv_object_name = is_parts-table_name
            iv_field_name  = ls_field-field_name ).
        ENDIF.

      ENDIF.

      IF lv_select IS INITIAL.
        lv_select = lv_select_part.
        lv_json_columns = lv_component.
      ELSE.
        lv_select = lv_select && |, { lv_select_part }|.
        lv_json_columns = lv_json_columns && ',' && lv_component.
      ENDIF.

      CLEAR ls_component.
      ls_component-name = lv_component.
      ls_component-type = lo_field_type.
      APPEND ls_component TO lt_components.

    ENDLOOP.

    IF lv_select IS INITIAL OR lt_components IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>invalid_field.
    ENDIF.

    lo_struct_descr = cl_abap_structdescr=>create( lt_components ).
    lo_table_descr = cl_abap_tabledescr=>create( lo_struct_descr ).
    CREATE DATA lr_table TYPE HANDLE lo_table_descr.
    ASSIGN lr_table->* TO <lt_data>.

    IF is_parts-where_sql IS INITIAL
       AND is_parts-having_sql IS INITIAL
       AND is_parts-order_sql IS INITIAL.

      SELECT (lv_select)
        FROM (lv_from)
        GROUP BY (is_parts-group_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS.

    ELSEIF is_parts-where_sql IS NOT INITIAL
       AND is_parts-having_sql IS INITIAL
       AND is_parts-order_sql IS INITIAL.

      SELECT (lv_select)
        FROM (lv_from)
        WHERE (is_parts-where_sql)
        GROUP BY (is_parts-group_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS.

    ELSEIF is_parts-where_sql IS INITIAL
       AND is_parts-having_sql IS NOT INITIAL
       AND is_parts-order_sql IS INITIAL.

      SELECT (lv_select)
        FROM (lv_from)
        GROUP BY (is_parts-group_sql)
        HAVING (is_parts-having_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS.

    ELSEIF is_parts-where_sql IS NOT INITIAL
       AND is_parts-having_sql IS NOT INITIAL
       AND is_parts-order_sql IS INITIAL.

      SELECT (lv_select)
        FROM (lv_from)
        WHERE (is_parts-where_sql)
        GROUP BY (is_parts-group_sql)
        HAVING (is_parts-having_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS.

    ELSEIF is_parts-where_sql IS INITIAL
       AND is_parts-having_sql IS INITIAL
       AND is_parts-order_sql IS NOT INITIAL
       AND lv_page = 1.

      SELECT (lv_select)
        FROM (lv_from)
        GROUP BY (is_parts-group_sql)
        ORDER BY (is_parts-order_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS.

    ELSEIF is_parts-where_sql IS INITIAL
       AND is_parts-having_sql IS INITIAL
       AND is_parts-order_sql IS NOT INITIAL.

      SELECT (lv_select)
        FROM (lv_from)
        GROUP BY (is_parts-group_sql)
        ORDER BY (is_parts-order_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS
        OFFSET @lv_offset.

    ELSEIF is_parts-where_sql IS INITIAL
       AND is_parts-having_sql IS NOT INITIAL
       AND is_parts-order_sql IS NOT INITIAL
       AND lv_page = 1.

      SELECT (lv_select)
        FROM (lv_from)
        GROUP BY (is_parts-group_sql)
        HAVING (is_parts-having_sql)
        ORDER BY (is_parts-order_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS.

    ELSEIF is_parts-where_sql IS INITIAL
       AND is_parts-having_sql IS NOT INITIAL
       AND is_parts-order_sql IS NOT INITIAL.

      SELECT (lv_select)
        FROM (lv_from)
        GROUP BY (is_parts-group_sql)
        HAVING (is_parts-having_sql)
        ORDER BY (is_parts-order_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS
        OFFSET @lv_offset.

    ELSEIF lv_page = 1.

      IF is_parts-having_sql IS INITIAL.

        SELECT (lv_select)
          FROM (lv_from)
          WHERE (is_parts-where_sql)
          GROUP BY (is_parts-group_sql)
          ORDER BY (is_parts-order_sql)
          INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
          UP TO @ev_max_rows ROWS.

      ELSE.

        SELECT (lv_select)
          FROM (lv_from)
          WHERE (is_parts-where_sql)
          GROUP BY (is_parts-group_sql)
          HAVING (is_parts-having_sql)
          ORDER BY (is_parts-order_sql)
          INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
          UP TO @ev_max_rows ROWS.

      ENDIF.

    ELSE.

      IF is_parts-having_sql IS INITIAL.

        SELECT (lv_select)
          FROM (lv_from)
          WHERE (is_parts-where_sql)
          GROUP BY (is_parts-group_sql)
          ORDER BY (is_parts-order_sql)
          INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
          UP TO @ev_max_rows ROWS
          OFFSET @lv_offset.

      ELSE.

        SELECT (lv_select)
          FROM (lv_from)
          WHERE (is_parts-where_sql)
          GROUP BY (is_parts-group_sql)
          HAVING (is_parts-having_sql)
          ORDER BY (is_parts-order_sql)
          INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
          UP TO @ev_max_rows ROWS
          OFFSET @lv_offset.

      ENDIF.

    ENDIF.

    ev_returned_rows = lines( <lt_data> ).
    ev_row_count = ev_returned_rows.
    ev_truncated = xsdbool( ev_returned_rows >= ev_max_rows ).

    ev_rows_json = zcl_milo_serializer=>table_to_json_selected(
      ir_data    = lr_table
      iv_columns = lv_json_columns ).

  ENDMETHOD.


  METHOD execute_join_select.

    DATA lr_table TYPE REF TO data.
    DATA lv_page TYPE i.
    DATA lv_offset TYPE i.
    DATA lv_from TYPE string.
    DATA lv_select TYPE string.
    DATA lv_json_columns TYPE string.
    DATA lv_component TYPE string.
    DATA lv_select_field TYPE string.
    DATA lo_field_type TYPE REF TO cl_abap_datadescr.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA ls_component LIKE LINE OF lt_components.
    DATA lo_struct_descr TYPE REF TO cl_abap_structdescr.
    DATA lo_table_descr TYPE REF TO cl_abap_tabledescr.

    FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.

    CLEAR: ev_object_name,
           ev_row_count,
           ev_returned_rows,
           ev_max_rows,
           ev_truncated,
           ev_rows_json.

    ev_object_name = is_parts-table_name.

    ev_max_rows = zcl_milo_config=>get_object_max_rows(
      iv_wlist_profile_id = iv_wlist_profile_id
      iv_obj_name         = ev_object_name ).

    lv_page = iv_page.
    IF lv_page IS INITIAL OR lv_page < 1.
      lv_page = 1.
    ENDIF.

    IF lv_page > 1 AND is_parts-order_sql IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>invalid_order_by.
    ENDIF.

    lv_offset = ( lv_page - 1 ) * ev_max_rows.
    lv_from = is_parts-from_sql.

    LOOP AT is_parts-fields INTO DATA(ls_field).

      lv_component = to_upper( ls_field-output_key ).
      lv_select_field = condense( CONV string( ls_field-field_name ) ).

      IF lv_select IS INITIAL.
        lv_select = |{ ls_field-source_alias }~{ lv_select_field } AS { lv_component }|.
        lv_json_columns = lv_component.
      ELSE.
        lv_select = lv_select && |, { ls_field-source_alias }~{ lv_select_field } AS { lv_component }|.
        lv_json_columns = lv_json_columns && ',' && lv_component.
      ENDIF.

      CLEAR ls_component.
      ls_component-name = lv_component.
      lo_field_type = get_join_field_type(
        is_parts        = is_parts
        iv_source_alias = ls_field-source_alias
        iv_field_name   = ls_field-field_name ).
      ls_component-type = lo_field_type.
      APPEND ls_component TO lt_components.

    ENDLOOP.

    IF lv_select IS INITIAL OR lt_components IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>invalid_field.
    ENDIF.

    lo_struct_descr = cl_abap_structdescr=>create( lt_components ).
    lo_table_descr = cl_abap_tabledescr=>create( lo_struct_descr ).
    CREATE DATA lr_table TYPE HANDLE lo_table_descr.
    ASSIGN lr_table->* TO <lt_data>.

    IF is_parts-where_sql IS INITIAL.
      SELECT COUNT(*)
        FROM (lv_from)
        INTO @ev_row_count.
    ELSE.
      SELECT COUNT(*)
        FROM (lv_from)
        WHERE (is_parts-where_sql)
        INTO @ev_row_count.
    ENDIF.

    ev_truncated = xsdbool( ev_row_count > ev_max_rows ).

    IF is_parts-where_sql IS INITIAL
       AND is_parts-order_sql IS INITIAL.

      SELECT (lv_select)
        FROM (lv_from)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS.

    ELSEIF is_parts-where_sql IS NOT INITIAL
       AND is_parts-order_sql IS INITIAL.

      SELECT (lv_select)
        FROM (lv_from)
        WHERE (is_parts-where_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS.

    ELSEIF is_parts-where_sql IS INITIAL
       AND is_parts-order_sql IS NOT INITIAL
       AND lv_page = 1.

      SELECT (lv_select)
        FROM (lv_from)
        ORDER BY (is_parts-order_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS.

    ELSEIF is_parts-where_sql IS INITIAL
       AND is_parts-order_sql IS NOT INITIAL.

      SELECT (lv_select)
        FROM (lv_from)
        ORDER BY (is_parts-order_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS
        OFFSET @lv_offset.

    ELSEIF lv_page = 1.

      SELECT (lv_select)
        FROM (lv_from)
        WHERE (is_parts-where_sql)
        ORDER BY (is_parts-order_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS.

    ELSE.

      SELECT (lv_select)
        FROM (lv_from)
        WHERE (is_parts-where_sql)
        ORDER BY (is_parts-order_sql)
        INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
        UP TO @ev_max_rows ROWS
        OFFSET @lv_offset.

    ENDIF.

    ev_returned_rows = lines( <lt_data> ).

    apply_join_mask(
      is_parts           = is_parts
      iv_mask_profile_id = iv_mask_profile_id
      ir_data            = lr_table ).

    ev_rows_json = zcl_milo_serializer=>table_to_json_selected(
      ir_data    = lr_table
      iv_columns = lv_json_columns ).

  ENDMETHOD.


  METHOD execute_saved_query.

    DATA ls_query TYPE zmilo_query.
    DATA lv_sql   TYPE string.

    ls_query = zcl_milo_query_repo=>get_query( iv_query_id ).

    IF ls_query-query_id IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid         = zcx_milo_validation=>object_not_allowed
          mv_object_name = 'SAVED_QUERY'.
    ENDIF.

    lv_sql = CONV string( ls_query-query_text ).

    execute_select(
      EXPORTING
        iv_sql              = lv_sql
        iv_wlist_profile_id = iv_wlist_profile_id
        iv_mask_profile_id  = iv_mask_profile_id
        iv_page             = iv_page
      IMPORTING
        ev_object_name      = ev_object_name
        ev_row_count        = ev_row_count
        ev_returned_rows    = ev_returned_rows
        ev_status           = ev_status
        ev_max_rows         = ev_max_rows
        ev_truncated        = ev_truncated
        ev_rows_json        = ev_rows_json ).

  ENDMETHOD.


  METHOD execute_select.

    DATA lr_table TYPE REF TO data.
    DATA ls_parts TYPE zcl_milo_sql_parser=>ty_query_parts.
    DATA lv_start TYPE timestampl.
    DATA lv_end   TYPE timestampl.
    DATA lv_dur   TYPE i.
    DATA lv_page   TYPE i.
    DATA lv_offset TYPE i.
    DATA lv_select_columns TYPE string.
    DATA lv_field_count TYPE i.

    GET TIME STAMP FIELD lv_start.

    FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.

    TRY.

        CLEAR: ev_object_name,
               ev_row_count,
               ev_returned_rows,
               ev_status,
               ev_max_rows,
               ev_truncated,
               ev_rows_json.

        zcl_milo_validator=>validate_select_sql(
          EXPORTING
            iv_sql              = iv_sql
            iv_wlist_profile_id = iv_wlist_profile_id
          IMPORTING
            ev_object_name      = ev_object_name ).

        ls_parts = zcl_milo_sql_parser=>parse( iv_sql ).

        IF ls_parts-group_sql IS NOT INITIAL.

          execute_group_select(
            EXPORTING
              is_parts            = ls_parts
              iv_wlist_profile_id = iv_wlist_profile_id
              iv_page             = iv_page
            IMPORTING
              ev_object_name      = ev_object_name
              ev_row_count        = ev_row_count
              ev_returned_rows    = ev_returned_rows
              ev_max_rows         = ev_max_rows
              ev_truncated        = ev_truncated
              ev_rows_json        = ev_rows_json ).

          ev_status = 'SUCCESS'.
          GET TIME STAMP FIELD lv_end.

          lv_dur = cl_abap_tstmp=>subtract(
            tstmp1 = lv_end
            tstmp2 = lv_start ) * 1000.

          DATA lv_group_result_bytes TYPE i.
          lv_group_result_bytes = strlen( ev_rows_json ).

          zcl_milo_logger=>log_execution(
            iv_sql_text      = iv_sql
            iv_status        = 'SUCCESS'
            iv_exec_mode     = 'SYNC'
            iv_source_obj    = ev_object_name
            iv_row_count     = ev_row_count
            iv_row_limit_req = ev_max_rows
            iv_row_limit_eff = ev_max_rows
            iv_truncated     = ev_truncated
            iv_duration_ms   = lv_dur
            iv_result_bytes  = lv_group_result_bytes ).

          RETURN.

        ENDIF.

        IF ls_parts-is_join = abap_true.

          execute_join_select(
            EXPORTING
              is_parts            = ls_parts
              iv_wlist_profile_id = iv_wlist_profile_id
              iv_mask_profile_id  = iv_mask_profile_id
              iv_page             = iv_page
            IMPORTING
              ev_object_name      = ev_object_name
              ev_row_count        = ev_row_count
              ev_returned_rows    = ev_returned_rows
              ev_max_rows         = ev_max_rows
              ev_truncated        = ev_truncated
              ev_rows_json        = ev_rows_json ).

          ev_status = 'SUCCESS'.
          GET TIME STAMP FIELD lv_end.

          lv_dur = cl_abap_tstmp=>subtract(
            tstmp1 = lv_end
            tstmp2 = lv_start ) * 1000.

          DATA lv_join_result_bytes TYPE i.
          lv_join_result_bytes = strlen( ev_rows_json ).

          zcl_milo_logger=>log_execution(
            iv_sql_text      = iv_sql
            iv_status        = 'SUCCESS'
            iv_exec_mode     = 'SYNC'
            iv_source_obj    = ev_object_name
            iv_row_count     = ev_row_count
            iv_row_limit_req = ev_max_rows
            iv_row_limit_eff = ev_max_rows
            iv_truncated     = ev_truncated
            iv_duration_ms   = lv_dur
            iv_result_bytes  = lv_join_result_bytes ).

          RETURN.

        ENDIF.

        ev_max_rows = zcl_milo_config=>get_object_max_rows(
          iv_wlist_profile_id = iv_wlist_profile_id
          iv_obj_name         = ev_object_name ).

        lv_page = iv_page.
        IF lv_page IS INITIAL OR lv_page < 1.
          lv_page = 1.
        ENDIF.

        IF lv_page > 1 AND ls_parts-order_sql IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid = zcx_milo_validation=>invalid_order_by.
        ENDIF.

        lv_offset = ( lv_page - 1 ) * ev_max_rows.

        IF ls_parts-where_sql IS INITIAL.

          SELECT COUNT(*)
            FROM (ev_object_name)
            INTO @ev_row_count.

        ELSE.

          SELECT COUNT(*)
            FROM (ev_object_name)
            WHERE (ls_parts-where_sql)
            INTO @ev_row_count.

        ENDIF.

        ev_truncated = xsdbool( ev_row_count > ev_max_rows ).

        CREATE DATA lr_table TYPE STANDARD TABLE OF (ev_object_name).
        ASSIGN lr_table->* TO <lt_data>.

        lv_select_columns = ls_parts-columns.

        IF lv_select_columns = '*'.

          DATA(lt_field) = zcl_milo_ddic_browser=>get_fields( ev_object_name ).

          CLEAR lv_select_columns.
          LOOP AT lt_field INTO DATA(ls_field).
            lv_field_count = lv_field_count + 1.
            IF lv_field_count > zcl_milo_config=>c_max_select_fields.
              EXIT.
            ENDIF.

            IF lv_select_columns IS INITIAL.
              lv_select_columns = ls_field-fieldname.
            ELSE.
              lv_select_columns = lv_select_columns && ',' && ls_field-fieldname.
            ENDIF.
          ENDLOOP.

          ls_parts-columns = lv_select_columns.

        ENDIF.

        IF ls_parts-columns = '*'.

          IF ls_parts-where_sql IS INITIAL
             AND ls_parts-order_sql IS INITIAL.

            SELECT *
              FROM (ev_object_name)
              INTO TABLE @<lt_data>
              UP TO @ev_max_rows ROWS.

          ELSEIF ls_parts-where_sql IS NOT INITIAL
             AND ls_parts-order_sql IS INITIAL.

            SELECT *
              FROM (ev_object_name)
              WHERE (ls_parts-where_sql)
              INTO TABLE @<lt_data>
              UP TO @ev_max_rows ROWS.

          ELSEIF ls_parts-where_sql IS INITIAL
             AND ls_parts-order_sql IS NOT INITIAL
             AND lv_page = 1.

            SELECT *
              FROM (ev_object_name)
              ORDER BY (ls_parts-order_sql)
              INTO TABLE @<lt_data>
              UP TO @ev_max_rows ROWS.

          ELSEIF ls_parts-where_sql IS INITIAL
             AND ls_parts-order_sql IS NOT INITIAL.

            SELECT *
              FROM (ev_object_name)
              ORDER BY (ls_parts-order_sql)
              INTO TABLE @<lt_data>
              UP TO @ev_max_rows ROWS
              OFFSET @lv_offset.

          ELSEIF lv_page = 1.

            SELECT *
              FROM (ev_object_name)
              WHERE (ls_parts-where_sql)
              ORDER BY (ls_parts-order_sql)
              INTO TABLE @<lt_data>
              UP TO @ev_max_rows ROWS.

          ELSE.

            SELECT *
              FROM (ev_object_name)
              WHERE (ls_parts-where_sql)
              ORDER BY (ls_parts-order_sql)
              INTO TABLE @<lt_data>
              UP TO @ev_max_rows ROWS
              OFFSET @lv_offset.

          ENDIF.

        ELSE.

          IF ls_parts-where_sql IS INITIAL
             AND ls_parts-order_sql IS INITIAL.

            SELECT (ls_parts-columns)
              FROM (ev_object_name)
              INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
              UP TO @ev_max_rows ROWS.

          ELSEIF ls_parts-where_sql IS NOT INITIAL
             AND ls_parts-order_sql IS INITIAL.

            SELECT (ls_parts-columns)
              FROM (ev_object_name)
              WHERE (ls_parts-where_sql)
              INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
              UP TO @ev_max_rows ROWS.

          ELSEIF ls_parts-where_sql IS INITIAL
             AND ls_parts-order_sql IS NOT INITIAL
             AND lv_page = 1.

            SELECT (ls_parts-columns)
              FROM (ev_object_name)
              ORDER BY (ls_parts-order_sql)
              INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
              UP TO @ev_max_rows ROWS.

          ELSEIF ls_parts-where_sql IS INITIAL
             AND ls_parts-order_sql IS NOT INITIAL.

            SELECT (ls_parts-columns)
              FROM (ev_object_name)
              ORDER BY (ls_parts-order_sql)
              INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
              UP TO @ev_max_rows ROWS
              OFFSET @lv_offset.

          ELSEIF lv_page = 1.

            SELECT (ls_parts-columns)
              FROM (ev_object_name)
              WHERE (ls_parts-where_sql)
              ORDER BY (ls_parts-order_sql)
              INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
              UP TO @ev_max_rows ROWS.

          ELSE.

            SELECT (ls_parts-columns)
              FROM (ev_object_name)
              WHERE (ls_parts-where_sql)
              ORDER BY (ls_parts-order_sql)
              INTO CORRESPONDING FIELDS OF TABLE @<lt_data>
              UP TO @ev_max_rows ROWS
              OFFSET @lv_offset.

          ENDIF.

        ENDIF.

        ev_returned_rows = lines( <lt_data> ).

        IF iv_mask_profile_id IS NOT INITIAL.

          zcl_milo_masker=>apply_mask(
            iv_mask_profile_id = iv_mask_profile_id
            iv_obj_name        = ev_object_name
            ir_data            = lr_table ).

        ENDIF.

        IF ls_parts-columns = '*'.
          ev_rows_json = zcl_milo_serializer=>table_to_json( lr_table ).
        ELSE.
          ev_rows_json = zcl_milo_serializer=>table_to_json_selected(
            ir_data    = lr_table
            iv_columns = ls_parts-columns ).
        ENDIF.

        ev_status = 'SUCCESS'.
        GET TIME STAMP FIELD lv_end.

        lv_dur = cl_abap_tstmp=>subtract(
          tstmp1 = lv_end
          tstmp2 = lv_start ) * 1000.
        DATA lv_result_bytes TYPE i.

        lv_result_bytes = strlen( ev_rows_json ).

        zcl_milo_logger=>log_execution(
          iv_sql_text      = iv_sql
          iv_status        = 'SUCCESS'
          iv_exec_mode     = 'SYNC'
          iv_source_obj    = ev_object_name
          iv_row_count     = ev_row_count
          iv_row_limit_req = ev_max_rows
          iv_row_limit_eff = ev_max_rows
          iv_truncated     = ev_truncated
          iv_duration_ms   = lv_dur
          iv_result_bytes  = lv_result_bytes ).

      CATCH zcx_milo_validation INTO DATA(lx_validation).

        GET TIME STAMP FIELD lv_end.

        lv_dur = cl_abap_tstmp=>subtract(
          tstmp1 = lv_end
          tstmp2 = lv_start ) * 1000.

        ev_status = 'BLOCKED'.

        IF ev_object_name IS INITIAL.
          TRY.
              ls_parts = zcl_milo_sql_parser=>parse( iv_sql ).
              ev_object_name = ls_parts-table_name.
            CATCH zcx_milo_validation.
              CLEAR ev_object_name.
          ENDTRY.
        ENDIF.

        zcl_milo_logger=>log_execution(
          iv_sql_text      = iv_sql
          iv_status        = 'BLOCKED'
          iv_exec_mode     = 'SYNC'
          iv_source_obj    = ev_object_name
          iv_row_count     = 0
          iv_row_limit_req = ev_max_rows
          iv_row_limit_eff = ev_max_rows
          iv_truncated     = abap_false
          iv_duration_ms   = lv_dur
          iv_result_bytes  = 0
          iv_error_text    = lx_validation->get_text( ) ).

        RAISE EXCEPTION lx_validation.

      CATCH cx_root INTO DATA(lx_error).

        GET TIME STAMP FIELD lv_end.

        lv_dur = cl_abap_tstmp=>subtract(
          tstmp1 = lv_end
          tstmp2 = lv_start ) * 1000.

        ev_status = 'ERROR'.
        ev_rows_json = lx_error->get_text( ).

        zcl_milo_logger=>log_execution(
          iv_sql_text      = iv_sql
          iv_status        = 'ERROR'
          iv_exec_mode     = 'SYNC'
          iv_source_obj    = ev_object_name
          iv_row_count     = ev_row_count
          iv_row_limit_req = ev_max_rows
          iv_row_limit_eff = ev_max_rows
          iv_truncated     = ev_truncated
          iv_duration_ms   = lv_dur
          iv_result_bytes  = 0
          iv_error_text    = lx_error->get_text( ) ).

    ENDTRY.

  ENDMETHOD.


  METHOD get_join_field_type.

    DATA lv_source_object TYPE zmilo_obj_name.
    DATA lv_field_name TYPE string.
    DATA lr_line TYPE REF TO data.
    DATA lo_struct_descr TYPE REF TO cl_abap_structdescr.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA ls_component LIKE LINE OF lt_components.

    FIELD-SYMBOLS <ls_line> TYPE any.

    CLEAR ro_type.

    LOOP AT is_parts-sources INTO DATA(ls_source).
      IF ls_source-alias = iv_source_alias.
        lv_source_object = ls_source-object_name.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_source_object IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid        = zcx_milo_validation=>invalid_field
          mv_field_name = iv_field_name.
    ENDIF.

    lv_field_name = to_upper( CONV string( iv_field_name ) ).

    CREATE DATA lr_line TYPE (lv_source_object).
    ASSIGN lr_line->* TO <ls_line>.

    lo_struct_descr ?= cl_abap_typedescr=>describe_by_data( <ls_line> ).
    lt_components = lo_struct_descr->get_components( ).

    READ TABLE lt_components INTO ls_component WITH KEY name = lv_field_name.
    IF sy-subrc <> 0 OR ls_component-type IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid        = zcx_milo_validation=>invalid_field
          mv_field_name = iv_field_name.
    ENDIF.

    ro_type = ls_component-type.

  ENDMETHOD.


  METHOD get_object_field_type.

    DATA lr_line TYPE REF TO data.
    DATA lo_struct_descr TYPE REF TO cl_abap_structdescr.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA ls_component LIKE LINE OF lt_components.
    DATA lv_field_name TYPE string.

    FIELD-SYMBOLS <ls_line> TYPE any.

    lv_field_name = to_upper( CONV string( iv_field_name ) ).

    CREATE DATA lr_line TYPE (iv_object_name).
    ASSIGN lr_line->* TO <ls_line>.

    lo_struct_descr ?= cl_abap_typedescr=>describe_by_data( <ls_line> ).
    lt_components = lo_struct_descr->get_components( ).

    READ TABLE lt_components INTO ls_component WITH KEY name = lv_field_name.
    IF sy-subrc <> 0 OR ls_component-type IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid        = zcx_milo_validation=>invalid_field
          mv_field_name = iv_field_name.
    ENDIF.

    ro_type = ls_component-type.

  ENDMETHOD.


  METHOD mask_join_value.

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
