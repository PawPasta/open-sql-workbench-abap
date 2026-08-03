CLASS zcl_milo_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS validate_select_sql
      IMPORTING
        iv_sql              TYPE string
        iv_wlist_profile_id TYPE zmilo_wlist_profile_id
      EXPORTING
        ev_object_name      TYPE zmilo_obj_name
      RAISING
        zcx_milo_validation.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES tt_string TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    CLASS-METHODS validate_column_list
      IMPORTING
        iv_sql      TYPE string
        iv_obj_name TYPE zmilo_obj_name
      RAISING
        zcx_milo_validation.

    CLASS-METHODS validate_where_clause
      IMPORTING
        iv_sql      TYPE string
        iv_obj_name TYPE zmilo_obj_name
      RAISING
        zcx_milo_validation.

    CLASS-METHODS validate_order_by
      IMPORTING
        iv_sql      TYPE string
        iv_obj_name TYPE zmilo_obj_name
      RAISING
        zcx_milo_validation.

    CLASS-METHODS validate_join_sql
      IMPORTING
        is_parts            TYPE zcl_milo_sql_parser=>ty_query_parts
        iv_wlist_profile_id TYPE zmilo_wlist_profile_id
      RAISING
        zcx_milo_validation.

    CLASS-METHODS get_join_source_object
      IMPORTING
        is_parts              TYPE zcl_milo_sql_parser=>ty_query_parts
        iv_alias              TYPE string
      RETURNING
        VALUE(rv_object_name) TYPE zmilo_obj_name.

    CLASS-METHODS validate_join_field
      IMPORTING
        is_parts      TYPE zcl_milo_sql_parser=>ty_query_parts
        iv_alias      TYPE string
        iv_field_name TYPE zmilo_field_name
      RAISING
        zcx_milo_validation.

    CLASS-METHODS validate_join_on
      IMPORTING
        is_parts TYPE zcl_milo_sql_parser=>ty_query_parts
      RAISING
        zcx_milo_validation.

    CLASS-METHODS validate_join_where
      IMPORTING
        is_parts TYPE zcl_milo_sql_parser=>ty_query_parts
      RAISING
        zcx_milo_validation.

    CLASS-METHODS validate_join_order
      IMPORTING
        is_parts TYPE zcl_milo_sql_parser=>ty_query_parts
      RAISING
        zcx_milo_validation.

    CLASS-METHODS validate_group_by
      IMPORTING
        is_parts TYPE zcl_milo_sql_parser=>ty_query_parts
      RAISING
        zcx_milo_validation.

    CLASS-METHODS validate_group_order
      IMPORTING
        is_parts TYPE zcl_milo_sql_parser=>ty_query_parts
      RAISING
        zcx_milo_validation.

    CLASS-METHODS validate_group_having
      IMPORTING
        is_parts TYPE zcl_milo_sql_parser=>ty_query_parts
      RAISING
        zcx_milo_validation.

    CLASS-METHODS validate_aggregate_argument
      IMPORTING
        is_parts      TYPE zcl_milo_sql_parser=>ty_query_parts
        iv_func       TYPE string
        iv_alias      TYPE string
        iv_field_name TYPE zmilo_field_name
      RAISING
        zcx_milo_validation.

    CLASS-METHODS split_where_conditions
      IMPORTING
        iv_where            TYPE string
      RETURNING
        VALUE(rt_condition) TYPE tt_string
      RAISING
        zcx_milo_validation.

    CLASS-METHODS is_where_literal_valid
      IMPORTING
        iv_value        TYPE string
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

ENDCLASS.



CLASS ZCL_MILO_VALIDATOR IMPLEMENTATION.


  METHOD get_join_source_object.

    DATA lv_alias TYPE string.

    lv_alias = to_upper( condense( iv_alias ) ).
    CLEAR rv_object_name.

    LOOP AT is_parts-sources INTO DATA(ls_source).
      IF ls_source-alias = lv_alias.
        rv_object_name = ls_source-object_name.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD split_where_conditions.

    DATA lt_token TYPE tt_string.
    DATA lv_token TYPE string.
    DATA lv_token_upper TYPE string.
    DATA lv_current TYPE string.
    DATA lv_wait_between_and TYPE abap_bool.
    DATA lv_in_literal TYPE abap_bool.
    DATA lv_quote_count TYPE i.
    DATA lv_where TYPE string.

    lv_where = condense( iv_where ).

    IF lv_where IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>where_expression_missing.
    ENDIF.

    SPLIT lv_where AT space INTO TABLE lt_token.

    LOOP AT lt_token INTO lv_token.

      IF lv_token IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_token_upper = to_upper( lv_token ).

      IF lv_in_literal <> abap_true
         AND lv_token_upper = 'OR'.
        IF lv_wait_between_and = abap_true.
          READ TABLE lt_token INTO lv_token INDEX 1.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>between_syntax_invalid
              mv_field_name = CONV zmilo_field_name( to_upper( lv_token ) ).
        ENDIF.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>logical_operator_invalid
            mv_value_1 = 'OR'.
      ENDIF.

      IF lv_in_literal <> abap_true
         AND lv_token_upper = 'AND'.

        IF lv_wait_between_and = abap_true.
          IF lv_current IS INITIAL.
            lv_current = lv_token.
          ELSE.
            lv_current = |{ lv_current } { lv_token }|.
          ENDIF.
          lv_wait_between_and = abap_false.
          CONTINUE.
        ENDIF.

        IF lv_current IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid     = zcx_milo_validation=>logical_operator_invalid
              mv_value_1 = 'AND'.
        ENDIF.

        APPEND lv_current TO rt_condition.
        CLEAR lv_current.
        CONTINUE.

      ENDIF.

      IF lv_current IS INITIAL.
        lv_current = lv_token.
      ELSE.
        lv_current = |{ lv_current } { lv_token }|.
      ENDIF.

      IF lv_in_literal <> abap_true
         AND lv_token_upper = 'BETWEEN'.
        lv_wait_between_and = abap_true.
      ENDIF.

      CLEAR lv_quote_count.
      FIND ALL OCCURRENCES OF ''''
        IN lv_token
        MATCH COUNT lv_quote_count.

      IF lv_quote_count MOD 2 <> 0.
        lv_in_literal = xsdbool( lv_in_literal <> abap_true ).
      ENDIF.

    ENDLOOP.

    IF lv_wait_between_and = abap_true.
      READ TABLE lt_token INTO lv_token INDEX 1.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid        = zcx_milo_validation=>between_syntax_invalid
          mv_field_name = CONV zmilo_field_name( to_upper( lv_token ) ).
    ENDIF.

    IF lv_current IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid     = zcx_milo_validation=>logical_operator_invalid
          mv_value_1 = 'AND'.
    ENDIF.

    APPEND lv_current TO rt_condition.

  ENDMETHOD.


  METHOD validate_column_list.

    DATA lv_cols       TYPE string.
    DATA lv_field_name TYPE zmilo_field_name.

    FIND PCRE '^SELECT\s+(.+?)\s+FROM\s+'
      IN iv_sql
      SUBMATCHES lv_cols.

    IF sy-subrc <> 0 OR lv_cols IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>parse_failed.
    ENDIF.

    IF lv_cols = '*'.
      RETURN.
    ENDIF.

    IF lv_cols CS '(' OR lv_cols CS ')' OR lv_cols CS '.'.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>invalid_field.
    ENDIF.

    SPLIT lv_cols AT ',' INTO TABLE DATA(lt_cols).

    IF lines( lt_cols ) > zcl_milo_config=>c_max_select_fields.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid     = zcx_milo_validation=>field_limit_exceeded
          mv_value_1 = CONV string( lines( lt_cols ) )
          mv_value_2 = CONV string( zcl_milo_config=>c_max_select_fields ).
    ENDIF.

    LOOP AT lt_cols INTO DATA(lv_col).

      lv_col = condense( lv_col ).
      lv_col = to_upper( lv_col ).

      IF lv_col IS INITIAL.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>invalid_field.
      ENDIF.

      lv_field_name = lv_col.

      IF zcl_milo_config=>is_field_exists(
           iv_obj_name   = iv_obj_name
           iv_field_name = lv_field_name ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid         = zcx_milo_validation=>field_not_found
            mv_field_name  = lv_field_name
            mv_object_name = iv_obj_name.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validate_group_by.

    DATA lt_group TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_group_item TYPE string.
    DATA lv_group_normal TYPE string.
    DATA lv_field_normal TYPE string.
    DATA lv_found TYPE abap_bool.
    DATA lv_group_alias TYPE string.
    DATA lv_group_field TYPE string.
    DATA lv_group_field_name TYPE zmilo_field_name.

    IF is_parts-group_sql IS INITIAL.
      RETURN.
    ENDIF.

    IF lines( is_parts-fields ) = 0.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>group_by_invalid.
    ENDIF.

    IF lines( is_parts-fields ) > zcl_milo_config=>c_max_select_fields.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid     = zcx_milo_validation=>field_limit_exceeded
          mv_value_1 = CONV string( lines( is_parts-fields ) )
          mv_value_2 = CONV string( zcl_milo_config=>c_max_select_fields ).
    ENDIF.

    SPLIT is_parts-group_sql AT ',' INTO TABLE lt_group.

    LOOP AT lt_group INTO lv_group_item.

      lv_group_item = to_upper( condense( lv_group_item ) ).
      CLEAR: lv_group_alias,
             lv_group_field,
             lv_group_field_name.

      IF lv_group_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>group_by_invalid.
      ENDIF.

      IF is_parts-is_join = abap_true.
        FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)$'
          IN lv_group_item
          SUBMATCHES lv_group_alias lv_group_field.

        IF sy-subrc <> 0 OR lv_group_alias IS INITIAL OR lv_group_field IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid = zcx_milo_validation=>group_by_invalid.
        ENDIF.

        validate_join_field(
          is_parts      = is_parts
          iv_alias      = lv_group_alias
          iv_field_name = CONV zmilo_field_name( lv_group_field ) ).

        lv_group_field_name = lv_group_field.
        lv_field_normal = to_upper( lv_group_alias && '~' && lv_group_field ).

      ELSE.
        IF lv_group_item CS '~'
           OR lv_group_item CS '('
           OR lv_group_item CS ')'.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid = zcx_milo_validation=>group_by_invalid.
        ENDIF.

        IF zcl_milo_config=>is_field_exists(
             iv_obj_name   = is_parts-table_name
             iv_field_name = CONV zmilo_field_name( lv_group_item ) ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid         = zcx_milo_validation=>field_not_found
              mv_field_name  = CONV zmilo_field_name( lv_group_item )
              mv_object_name = is_parts-table_name.
        ENDIF.

        lv_group_field_name = lv_group_item.
        lv_field_normal = lv_group_item.

      ENDIF.

      CLEAR lv_found.

      LOOP AT is_parts-fields INTO DATA(ls_selected_field).
        IF ls_selected_field-is_aggregate = abap_true.
          CONTINUE.
        ENDIF.

        IF is_parts-is_join = abap_true.
          lv_group_normal = to_upper(
            ls_selected_field-source_alias && '~' &&
            ls_selected_field-field_name ).
        ELSE.
          lv_group_normal = to_upper(
            CONV string( ls_selected_field-field_name ) ).
        ENDIF.

        IF lv_group_normal = lv_field_normal.
          lv_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_found <> abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>group_field_not_selected
            mv_field_name = lv_group_field_name.
      ENDIF.

    ENDLOOP.

    LOOP AT is_parts-fields INTO DATA(ls_field).

      IF ls_field-is_aggregate = abap_true.

        IF ls_field-agg_func = 'COUNT' AND ls_field-field_name = '*'.
          CONTINUE.
        ENDIF.

        validate_aggregate_argument(
          is_parts      = is_parts
          iv_func       = ls_field-agg_func
          iv_alias      = ls_field-source_alias
          iv_field_name = ls_field-field_name ).

        CONTINUE.

      ENDIF.

      IF is_parts-is_join = abap_true.
        validate_join_field(
          is_parts      = is_parts
          iv_alias      = ls_field-source_alias
          iv_field_name = ls_field-field_name ).
        lv_field_normal = to_upper( ls_field-source_alias && '~' && ls_field-field_name ).
      ELSE.
        IF zcl_milo_config=>is_field_exists(
             iv_obj_name   = is_parts-table_name
             iv_field_name = ls_field-field_name ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>invalid_field
              mv_field_name = ls_field-field_name.
        ENDIF.
        lv_field_normal = to_upper( CONV string( ls_field-field_name ) ).
      ENDIF.

      CLEAR lv_found.

      LOOP AT lt_group INTO lv_group_normal.
        lv_group_normal = to_upper( condense( lv_group_normal ) ).
        IF lv_group_normal = lv_field_normal.
          lv_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_found <> abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>select_field_not_grouped
            mv_field_name = ls_field-field_name.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validate_group_having.

    DATA lt_condition TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_condition TYPE string.
    DATA lv_func TYPE string.
    DATA lv_distinct TYPE string.
    DATA lv_field TYPE string.
    DATA lv_alias TYPE string.
    DATA lv_field_name TYPE string.
    DATA lv_op TYPE string.
    DATA lv_value TYPE string.

    IF is_parts-having_sql IS INITIAL.
      RETURN.
    ENDIF.

    IF is_parts-group_sql IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>having_without_group.
    ENDIF.

    SPLIT is_parts-having_sql AT ' AND ' INTO TABLE lt_condition.

    LOOP AT lt_condition INTO lv_condition.

      lv_condition = to_upper( condense( lv_condition ) ).

      IF lv_condition IS INITIAL OR lv_condition CS ' OR '.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>having_invalid.
      ENDIF.

      CLEAR: lv_func,
             lv_distinct,
             lv_field,
             lv_op,
             lv_value.

      FIND PCRE '^(COUNT|SUM|AVG|MIN|MAX)\s*\(\s*(DISTINCT\s+)?([A-Z0-9_~*]+)\s*\)\s*(=|<>|>=|<=|>|<)\s*([+-]?[0-9]+(?:[.][0-9]+)?)$'
        IN lv_condition
        SUBMATCHES lv_func lv_distinct lv_field lv_op lv_value.

      IF sy-subrc <> 0
         OR lv_func IS INITIAL
         OR lv_field IS INITIAL
         OR lv_op IS INITIAL
         OR lv_value IS INITIAL.

        CLEAR lv_func.
        FIND PCRE '^([A-Z0-9_]+)\s*\('
          IN lv_condition
          SUBMATCHES lv_func.

        IF sy-subrc <> 0 OR lv_func IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid = zcx_milo_validation=>having_invalid.
        ENDIF.

        IF lv_func <> 'COUNT'
           AND lv_func <> 'SUM'
           AND lv_func <> 'AVG'
           AND lv_func <> 'MIN'
           AND lv_func <> 'MAX'.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid     = zcx_milo_validation=>aggregate_not_supported
              mv_value_1 = lv_func.
        ENDIF.

        IF lv_condition CS 'DISTINCT'.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid     = zcx_milo_validation=>distinct_aggregate_invalid
              mv_value_1 = lv_condition.
        ENDIF.

        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>having_aggregate_invalid
            mv_value_1 = lv_condition.
      ENDIF.

      IF lv_distinct IS NOT INITIAL
         AND ( lv_func <> 'COUNT' OR lv_field = '*' ).
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>distinct_aggregate_invalid
            mv_value_1 = lv_condition.
      ENDIF.

      IF lv_field = '*'.
        IF lv_func <> 'COUNT'.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid     = zcx_milo_validation=>having_aggregate_invalid
              mv_value_1 = lv_condition.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF is_parts-is_join = abap_true.

        FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)$'
          IN lv_field
          SUBMATCHES lv_alias lv_field_name.

        IF sy-subrc <> 0 OR lv_alias IS INITIAL OR lv_field_name IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid     = zcx_milo_validation=>having_aggregate_invalid
              mv_value_1 = lv_condition.
        ENDIF.

        validate_aggregate_argument(
          is_parts      = is_parts
          iv_func       = lv_func
          iv_alias      = lv_alias
          iv_field_name = CONV zmilo_field_name( lv_field_name ) ).

      ELSE.

        IF lv_field CS '~'.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid     = zcx_milo_validation=>having_aggregate_invalid
              mv_value_1 = lv_condition.
        ENDIF.

        validate_aggregate_argument(
          is_parts      = is_parts
          iv_func       = lv_func
          iv_alias      = ''
          iv_field_name = CONV zmilo_field_name( lv_field ) ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validate_group_order.

    DATA lt_order TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lt_group TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_order_item TYPE string.
    DATA lv_order_key TYPE string.
    DATA lv_dir TYPE string.
    DATA lv_group_item TYPE string.
    DATA lv_allowed TYPE abap_bool.
    DATA lv_invalid_dir TYPE string.
    DATA lt_seen_key TYPE SORTED TABLE OF string
      WITH UNIQUE KEY table_line.

    IF is_parts-order_sql IS INITIAL.
      RETURN.
    ENDIF.

    SPLIT is_parts-order_sql AT ',' INTO TABLE lt_order.
    SPLIT is_parts-group_sql AT ',' INTO TABLE lt_group.

    LOOP AT lt_order INTO lv_order_item.

      CLEAR: lv_order_key,
             lv_dir,
             lv_invalid_dir.
      lv_order_item = to_upper( condense( lv_order_item ) ).

      FIND PCRE '^([A-Z0-9_~]+)(?:\s+(ASC|DESC|ASCENDING|DESCENDING))?$'
        IN lv_order_item
        SUBMATCHES lv_order_key lv_dir.

      IF sy-subrc <> 0 OR lv_order_key IS INITIAL.
        FIND PCRE '^([A-Z0-9_~]+)\s+([A-Z0-9_]+)$'
          IN lv_order_item
          SUBMATCHES lv_order_key lv_invalid_dir.

        IF sy-subrc = 0 AND lv_invalid_dir IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid     = zcx_milo_validation=>order_direction_invalid
              mv_value_1 = lv_invalid_dir.
        ENDIF.

        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>order_expression_not_supported
            mv_value_1 = lv_order_item.
      ENDIF.

      INSERT lv_order_key INTO TABLE lt_seen_key.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>order_field_duplicated
            mv_field_name = CONV zmilo_field_name( lv_order_key ).
      ENDIF.

      CLEAR lv_allowed.

      LOOP AT lt_group INTO lv_group_item.
        lv_group_item = to_upper( condense( lv_group_item ) ).
        IF lv_order_key = lv_group_item.
          lv_allowed = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_allowed <> abap_true.
        LOOP AT is_parts-fields INTO DATA(ls_field).
          IF lv_order_key = to_upper( ls_field-output_key ).
            lv_allowed = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF lv_allowed <> abap_true.
        IF lv_order_key NS '~'
           AND ( is_parts-is_join = abap_true
                 OR zcl_milo_config=>is_field_exists(
                      iv_obj_name   = is_parts-table_name
                      iv_field_name = CONV zmilo_field_name( lv_order_key ) ) <> abap_true ).
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid     = zcx_milo_validation=>order_alias_not_found
              mv_value_1 = lv_order_key.
        ENDIF.

        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>order_field_invalid
            mv_field_name = CONV zmilo_field_name( lv_order_key ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validate_join_field.

    DATA lv_alias TYPE string.
    DATA lv_field TYPE zmilo_field_name.
    DATA lv_object_name TYPE zmilo_obj_name.
    DATA lv_other_source_has_field TYPE abap_bool.

    lv_alias = to_upper( condense( iv_alias ) ).
    lv_field = to_upper( condense( iv_field_name ) ).

    lv_object_name = get_join_source_object(
      is_parts = is_parts
      iv_alias = lv_alias ).

    IF lv_object_name IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid        = zcx_milo_validation=>field_alias_not_found
          mv_value_1    = lv_alias
          mv_field_name = lv_field.
    ENDIF.

    IF zcl_milo_config=>is_field_exists(
         iv_obj_name   = lv_object_name
         iv_field_name = lv_field ) <> abap_true.
      LOOP AT is_parts-sources INTO DATA(ls_other_source).
        IF ls_other_source-alias = lv_alias.
          CONTINUE.
        ENDIF.

        IF zcl_milo_config=>is_field_exists(
             iv_obj_name   = ls_other_source-object_name
             iv_field_name = lv_field ) = abap_true.
          lv_other_source_has_field = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_other_source_has_field = abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>join_field_source_invalid
            mv_field_name = lv_field
            mv_value_1    = lv_alias.
      ENDIF.

      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid         = zcx_milo_validation=>field_not_found
          mv_field_name  = lv_field
          mv_object_name = lv_object_name.
    ENDIF.

  ENDMETHOD.


  METHOD validate_join_on.

    DATA lt_condition TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_condition TYPE string.
    DATA lv_on TYPE string.
    DATA lv_left_alias TYPE string.
    DATA lv_left_field TYPE string.
    DATA lv_right_alias TYPE string.
    DATA lv_right_field TYPE string.
    DATA lv_left_object TYPE zmilo_obj_name.
    DATA lv_right_object TYPE zmilo_obj_name.
    DATA ls_left_ddic TYPE dd03l.
    DATA ls_right_ddic TYPE dd03l.
    DATA lv_left_type_group TYPE string.
    DATA lv_right_type_group TYPE string.

    LOOP AT is_parts-joins INTO DATA(ls_join).

      IF ls_join-on_sql IS INITIAL.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid         = zcx_milo_validation=>join_on_missing
            mv_object_name = ls_join-right_object.
      ENDIF.

      lv_on = condense( ls_join-on_sql ).

      SPLIT lv_on AT ' AND ' INTO TABLE lt_condition.

      LOOP AT lt_condition INTO lv_condition.

        lv_condition = condense( lv_condition ).

        FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)\s*=\s*([A-Z0-9_]+)~([A-Z0-9_]+)$'
          IN lv_condition
          SUBMATCHES lv_left_alias lv_left_field lv_right_alias lv_right_field.

        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid = zcx_milo_validation=>join_on_invalid.
        ENDIF.

        validate_join_field(
          is_parts      = is_parts
          iv_alias      = lv_left_alias
          iv_field_name = CONV zmilo_field_name( lv_left_field ) ).

        validate_join_field(
          is_parts      = is_parts
          iv_alias      = lv_right_alias
          iv_field_name = CONV zmilo_field_name( lv_right_field ) ).

        lv_left_object = get_join_source_object(
          is_parts = is_parts
          iv_alias = lv_left_alias ).

        lv_right_object = get_join_source_object(
          is_parts = is_parts
          iv_alias = lv_right_alias ).

        CLEAR: ls_left_ddic,
               ls_right_ddic.

        SELECT SINGLE datatype
          FROM dd03l
          WHERE tabname   = @lv_left_object
            AND fieldname = @lv_left_field
            AND as4local  = 'A'
          INTO CORRESPONDING FIELDS OF @ls_left_ddic.

        SELECT SINGLE datatype
          FROM dd03l
          WHERE tabname   = @lv_right_object
            AND fieldname = @lv_right_field
            AND as4local  = 'A'
          INTO CORRESPONDING FIELDS OF @ls_right_ddic.

        CLEAR: lv_left_type_group,
               lv_right_type_group.

        CASE ls_left_ddic-datatype.
          WHEN 'CHAR' OR 'NUMC' OR 'CLNT' OR 'LANG'
            OR 'STRING' OR 'SSTRING'.
            lv_left_type_group = 'CHARACTER'.
          WHEN 'INT1' OR 'INT2' OR 'INT4' OR 'INT8'
            OR 'DEC' OR 'CURR' OR 'QUAN' OR 'FLTP'
            OR 'DECFLOAT16' OR 'DECFLOAT34'.
            lv_left_type_group = 'NUMERIC'.
          WHEN 'DATS'.
            lv_left_type_group = 'DATE'.
          WHEN 'TIMS'.
            lv_left_type_group = 'TIME'.
          WHEN 'RAW' OR 'LRAW' OR 'RAWSTRING'.
            lv_left_type_group = 'BINARY'.
          WHEN OTHERS.
            lv_left_type_group = ls_left_ddic-datatype.
        ENDCASE.

        CASE ls_right_ddic-datatype.
          WHEN 'CHAR' OR 'NUMC' OR 'CLNT' OR 'LANG'
            OR 'STRING' OR 'SSTRING'.
            lv_right_type_group = 'CHARACTER'.
          WHEN 'INT1' OR 'INT2' OR 'INT4' OR 'INT8'
            OR 'DEC' OR 'CURR' OR 'QUAN' OR 'FLTP'
            OR 'DECFLOAT16' OR 'DECFLOAT34'.
            lv_right_type_group = 'NUMERIC'.
          WHEN 'DATS'.
            lv_right_type_group = 'DATE'.
          WHEN 'TIMS'.
            lv_right_type_group = 'TIME'.
          WHEN 'RAW' OR 'LRAW' OR 'RAWSTRING'.
            lv_right_type_group = 'BINARY'.
          WHEN OTHERS.
            lv_right_type_group = ls_right_ddic-datatype.
        ENDCASE.

        IF lv_left_type_group <> lv_right_type_group.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>join_comparison_type_mismatch
              mv_field_name = CONV zmilo_field_name( lv_left_field )
              mv_value_1    = |{ lv_right_alias }~{ lv_right_field }|.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD validate_join_order.

    DATA lt_order TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_order_item TYPE string.
    DATA lv_alias TYPE string.
    DATA lv_field TYPE string.
    DATA lv_dir TYPE string.
    DATA lv_invalid_dir TYPE string.
    DATA lv_order_key TYPE string.
    DATA lt_seen_key TYPE SORTED TABLE OF string
      WITH UNIQUE KEY table_line.

    IF is_parts-order_sql IS INITIAL.
      RETURN.
    ENDIF.

    SPLIT is_parts-order_sql AT ',' INTO TABLE lt_order.

    LOOP AT lt_order INTO lv_order_item.

      CLEAR: lv_alias,
             lv_field,
             lv_dir,
             lv_invalid_dir,
             lv_order_key.
      lv_order_item = condense( lv_order_item ).

      FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)(?:\s+(ASC|DESC|ASCENDING|DESCENDING))?$'
        IN lv_order_item
        SUBMATCHES lv_alias lv_field lv_dir.

      IF sy-subrc <> 0 OR lv_alias IS INITIAL OR lv_field IS INITIAL.
        FIND PCRE '^([A-Z0-9_]+~[A-Z0-9_]+)\s+([A-Z0-9_]+)$'
          IN lv_order_item
          SUBMATCHES lv_order_key lv_invalid_dir.

        IF sy-subrc = 0 AND lv_invalid_dir IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid     = zcx_milo_validation=>order_direction_invalid
              mv_value_1 = lv_invalid_dir.
        ENDIF.

        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>order_expression_not_supported
            mv_value_1 = lv_order_item.
      ENDIF.

      lv_order_key = lv_alias && '~' && lv_field.
      INSERT lv_order_key INTO TABLE lt_seen_key.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>order_field_duplicated
            mv_field_name = CONV zmilo_field_name( lv_order_key ).
      ENDIF.

      validate_join_field(
        is_parts      = is_parts
        iv_alias      = lv_alias
        iv_field_name = CONV zmilo_field_name( lv_field ) ).

    ENDLOOP.

  ENDMETHOD.


  METHOD validate_join_sql.

    DATA lv_expected_join_count TYPE i.

    lv_expected_join_count = lines( is_parts-sources ) - 1.

    IF lines( is_parts-sources ) > zcl_milo_config=>c_max_join_sources.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid     = zcx_milo_validation=>join_source_limit_exceeded
          mv_value_1 = CONV string( lines( is_parts-sources ) )
          mv_value_2 = CONV string( zcl_milo_config=>c_max_join_sources ).
    ENDIF.

    IF lines( is_parts-sources ) < 2.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>forbidden_keyword.
    ENDIF.

    IF lines( is_parts-joins ) <> lv_expected_join_count.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>join_on_missing.
    ENDIF.

    IF lines( is_parts-fields ) > zcl_milo_config=>c_max_select_fields.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid     = zcx_milo_validation=>field_limit_exceeded
          mv_value_1 = CONV string( lines( is_parts-fields ) )
          mv_value_2 = CONV string( zcl_milo_config=>c_max_select_fields ).
    ENDIF.

    IF is_parts-columns = '*' OR lines( is_parts-fields ) = 0.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>invalid_field.
    ENDIF.

    LOOP AT is_parts-sources INTO DATA(ls_source).

      IF ls_source-object_name IS INITIAL OR ls_source-alias IS INITIAL.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid         = zcx_milo_validation=>join_alias_required
            mv_object_name = ls_source-object_name.
      ENDIF.

      DATA(lv_source_type) =
        zcl_milo_config=>get_object_type( ls_source-object_name ).

      IF lv_source_type IS INITIAL.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid         = zcx_milo_validation=>object_not_found
            mv_object_name = ls_source-object_name.
      ELSEIF lv_source_type <> 'TRANSP' AND lv_source_type <> 'VIEW'.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid         = zcx_milo_validation=>unsupported_ddic_object_type
            mv_object_name = ls_source-object_name
            mv_value_1     = CONV string( lv_source_type ).
      ENDIF.

      IF zcl_milo_config=>is_object_allowed(
           iv_wlist_profile_id = iv_wlist_profile_id
           iv_obj_name         = ls_source-object_name ) <> abap_true.
        IF zcl_milo_config=>is_object_exists( ls_source-object_name ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid         = zcx_milo_validation=>object_not_found
              mv_object_name = ls_source-object_name.
        ENDIF.

        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid         = zcx_milo_validation=>join_source_not_whitelisted
            mv_object_name = ls_source-object_name
            mv_value_1     = CONV string( iv_wlist_profile_id ).
      ENDIF.

    ENDLOOP.

    LOOP AT is_parts-joins INTO DATA(ls_join).
      IF ls_join-join_type <> 'INNER'
         AND ls_join-join_type <> 'LEFT_OUTER'.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>join_type_not_supported
            mv_value_1 = ls_join-join_type.
      ENDIF.
    ENDLOOP.

    LOOP AT is_parts-fields INTO DATA(ls_field).
      IF ls_field-is_aggregate = abap_true.
        IF ls_field-agg_func = 'COUNT' AND ls_field-field_name = '*'.
          CONTINUE.
        ENDIF.
      ENDIF.
      validate_join_field(
        is_parts      = is_parts
        iv_alias      = ls_field-source_alias
        iv_field_name = ls_field-field_name ).
    ENDLOOP.

    validate_group_by(
      is_parts = is_parts ).

    validate_group_having(
      is_parts = is_parts ).

    validate_join_on(
      is_parts = is_parts ).

    validate_join_where(
      is_parts = is_parts ).

    IF is_parts-group_sql IS NOT INITIAL.
      validate_group_order(
        is_parts = is_parts ).
    ELSE.
      validate_join_order(
        is_parts = is_parts ).
    ENDIF.

  ENDMETHOD.


  METHOD validate_join_where.

    DATA lt_condition TYPE tt_string.
    DATA lv_condition TYPE string.
    DATA lv_where TYPE string.
    DATA lv_alias TYPE string.
    DATA lv_field TYPE string.
    DATA lv_op TYPE string.
    DATA lv_value TYPE string.
    DATA lv_low TYPE string.
    DATA lv_high TYPE string.
    DATA lv_field_expr TYPE string.
    DATA lt_between_token TYPE tt_string.
    DATA lv_token TYPE string.
    DATA lt_in_value TYPE tt_string.
    DATA lv_in_value TYPE string.

    IF is_parts-where_sql IS INITIAL.
      RETURN.
    ENDIF.

    lv_where = condense( is_parts-where_sql ).

    IF lv_where IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>where_expression_missing.
    ENDIF.

    lt_condition = split_where_conditions( iv_where = lv_where ).

    LOOP AT lt_condition INTO lv_condition.

      lv_condition = condense( lv_condition ).

      CLEAR: lv_alias,
             lv_field,
             lv_low,
             lv_high,
             lv_field_expr,
             lv_token,
             lt_between_token.

      SPLIT lv_condition AT space INTO TABLE lt_between_token.

      READ TABLE lt_between_token INTO lv_token INDEX 2.

      IF sy-subrc = 0 AND to_upper( lv_token ) = 'BETWEEN'.

        READ TABLE lt_between_token INTO lv_field_expr INDEX 1.
        SPLIT lv_field_expr AT '~' INTO lv_alias lv_field.

        IF lines( lt_between_token ) <> 5.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>between_syntax_invalid
              mv_field_name = CONV zmilo_field_name( lv_field ).
        ENDIF.

        READ TABLE lt_between_token INTO lv_low INDEX 3.
        READ TABLE lt_between_token INTO lv_token INDEX 4.
        READ TABLE lt_between_token INTO lv_high INDEX 5.

        IF lv_alias IS INITIAL
           OR lv_field IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>between_syntax_invalid
              mv_field_name = CONV zmilo_field_name( lv_field ).
        ENDIF.

        IF to_upper( lv_token ) <> 'AND'.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>between_syntax_invalid
              mv_field_name = CONV zmilo_field_name( lv_field ).
        ENDIF.

        lv_low = condense( lv_low ).
        lv_high = condense( lv_high ).

        IF lv_low IS INITIAL
           OR lv_high IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>between_syntax_invalid
              mv_field_name = CONV zmilo_field_name( lv_field ).
        ENDIF.

        validate_join_field(
          is_parts      = is_parts
          iv_alias      = lv_alias
          iv_field_name = CONV zmilo_field_name( lv_field ) ).

        lv_low = condense( lv_low ).
        lv_high = condense( lv_high ).

        IF is_where_literal_valid( lv_low ) <> abap_true
           OR is_where_literal_valid( lv_high ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>between_syntax_invalid
              mv_field_name = CONV zmilo_field_name( lv_field ).
        ENDIF.

        CONTINUE.

      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)[[:space:]]+LIKE[[:space:]]+(.+)$'
        IN lv_condition
        SUBMATCHES lv_alias lv_field lv_value.

      IF sy-subrc = 0.

        IF lv_alias IS INITIAL
           OR lv_field IS INITIAL
           OR lv_value IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>like_pattern_invalid
              mv_field_name = CONV zmilo_field_name( lv_field ).
        ENDIF.

        validate_join_field(
          is_parts      = is_parts
          iv_alias      = lv_alias
          iv_field_name = CONV zmilo_field_name( lv_field ) ).

        lv_value = condense( lv_value ).

        IF is_where_literal_valid( lv_value ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>like_pattern_invalid
              mv_field_name = CONV zmilo_field_name( lv_field ).
        ENDIF.

        CONTINUE.

      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)[[:space:]]+IN[[:space:]]*\((.+)\)$'
        IN lv_condition
        SUBMATCHES lv_alias lv_field lv_value.

      IF sy-subrc = 0.

        IF lv_alias IS INITIAL
           OR lv_field IS INITIAL
           OR lv_value IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>in_list_invalid
              mv_field_name = CONV zmilo_field_name( lv_field ).
        ENDIF.

        validate_join_field(
          is_parts      = is_parts
          iv_alias      = lv_alias
          iv_field_name = CONV zmilo_field_name( lv_field ) ).

        lv_value = condense( lv_value ).

        IF lv_value CS '('
           OR lv_value CS ')'
           OR lv_value CS ' SELECT '
           OR lv_value CS ' FROM '
           OR lv_value CP ',*'
           OR lv_value CP '*,'
           OR lv_value CS ', ,'.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>in_list_invalid
              mv_field_name = CONV zmilo_field_name( lv_field ).
        ENDIF.

        CLEAR lt_in_value.
        SPLIT lv_value AT ',' INTO TABLE lt_in_value.

        LOOP AT lt_in_value INTO lv_in_value.
          lv_in_value = condense( lv_in_value ).
          IF is_where_literal_valid( lv_in_value ) <> abap_true.
            RAISE EXCEPTION TYPE zcx_milo_validation
              EXPORTING
                textid        = zcx_milo_validation=>in_list_invalid
                mv_field_name = CONV zmilo_field_name( lv_field ).
          ENDIF.
        ENDLOOP.

        CONTINUE.

      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)[[:space:]]+(IS|IS[[:space:]]+NOT)[[:space:]]+NULL$'
        IN lv_condition
        SUBMATCHES lv_alias lv_field lv_op.

      IF sy-subrc = 0.
        validate_join_field(
          is_parts      = is_parts
          iv_alias      = lv_alias
          iv_field_name = CONV zmilo_field_name( lv_field ) ).

        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>null_comparison_invalid
            mv_field_name = CONV zmilo_field_name( lv_field ).
      ENDIF.

      IF lv_condition CS '!='.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>where_operator_not_supported
            mv_value_1 = '!='.
      ELSEIF lv_condition CS '=='.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>where_operator_not_supported
            mv_value_1 = '=='.
      ELSEIF lv_condition CS ' NOT LIKE '.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>where_operator_not_supported
            mv_value_1 = 'NOT LIKE'.
      ELSEIF lv_condition CS ' NOT IN '.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>where_operator_not_supported
            mv_value_1 = 'NOT IN'.
      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)[[:space:]]+IN(?:[[:space:]]|$)'
        IN lv_condition
        SUBMATCHES lv_alias lv_field.

      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>in_list_invalid
            mv_field_name = CONV zmilo_field_name( lv_field ).
      ENDIF.

      IF lv_condition CS '(' OR lv_condition CS ')'.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>where_parentheses_invalid.
      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)[[:space:]]+LIKE(?:[[:space:]]|$)'
        IN lv_condition
        SUBMATCHES lv_alias lv_field.

      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>like_pattern_invalid
            mv_field_name = CONV zmilo_field_name( lv_field ).
      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)\s*(=|<>|>=|<=|>|<)\s*(.+)$'
        IN lv_condition
        SUBMATCHES lv_alias lv_field lv_op lv_value.

      IF sy-subrc <> 0.
        READ TABLE lt_between_token INTO lv_token INDEX 2.
        IF sy-subrc <> 0.
          lv_token = lv_condition.
        ENDIF.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>where_operator_not_supported
            mv_value_1 = lv_token.
      ENDIF.

      validate_join_field(
        is_parts      = is_parts
        iv_alias      = lv_alias
        iv_field_name = CONV zmilo_field_name( lv_field ) ).

      lv_value = condense( lv_value ).

      IF to_upper( lv_value ) = 'NULL'.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>null_comparison_invalid
            mv_field_name = CONV zmilo_field_name( lv_field ).
      ENDIF.

      IF is_where_literal_valid( lv_value ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>where_value_invalid
            mv_field_name = CONV zmilo_field_name( lv_field )
            mv_value_1    = lv_value.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validate_order_by.

    DATA lv_order TYPE string.
    DATA lt_order_item TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_order_item TYPE string.
    DATA lv_field TYPE zmilo_field_name.
    DATA lv_dir   TYPE string.
    DATA lv_dir_part TYPE string.
    DATA lv_invalid_dir TYPE string.
    DATA lv_field_key TYPE string.
    DATA lt_seen_field TYPE SORTED TABLE OF string
      WITH UNIQUE KEY table_line.

    FIND PCRE '[[:space:]]ORDER[[:space:]]+BY[[:space:]]+(.+)$'
      IN iv_sql
      SUBMATCHES lv_order.

    IF sy-subrc <> 0.
      IF iv_sql CS ' ORDER BY '.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>invalid_order_by.
      ENDIF.
      RETURN.
    ENDIF.

    lv_order = condense( lv_order ).

    IF lv_order IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>invalid_order_by.
    ENDIF.

    IF lv_order CS '('
       OR lv_order CS ')'
       OR lv_order CS '~'
       OR lv_order CS '.'.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid     = zcx_milo_validation=>order_expression_not_supported
          mv_value_1 = lv_order.
    ENDIF.

    SPLIT lv_order AT ',' INTO TABLE lt_order_item.

    LOOP AT lt_order_item INTO lv_order_item.

      CLEAR: lv_field,
             lv_dir,
             lv_dir_part,
             lv_invalid_dir,
             lv_field_key.

      lv_order_item = to_upper( condense( lv_order_item ) ).

      IF lv_order_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>order_expression_not_supported
            mv_value_1 = lv_order.
      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)([[:space:]]+(ASC|DESC|ASCENDING|DESCENDING))?$'
        IN lv_order_item
        SUBMATCHES lv_field lv_dir_part lv_dir.

      IF sy-subrc <> 0 OR lv_field IS INITIAL.
        FIND PCRE '^([A-Z0-9_]+)[[:space:]]+([A-Z0-9_]+)$'
          IN lv_order_item
          SUBMATCHES lv_field lv_invalid_dir.

        IF sy-subrc = 0 AND lv_invalid_dir IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid     = zcx_milo_validation=>order_direction_invalid
              mv_value_1 = lv_invalid_dir.
        ENDIF.

        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>order_expression_not_supported
            mv_value_1 = lv_order_item.
      ENDIF.

      lv_field = to_upper( condense( lv_field ) ).

      lv_field_key = lv_field.
      INSERT lv_field_key INTO TABLE lt_seen_field.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>order_field_duplicated
            mv_field_name = lv_field.
      ENDIF.

      IF zcl_milo_config=>is_field_exists(
           iv_obj_name   = iv_obj_name
           iv_field_name = lv_field ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>order_field_invalid
            mv_field_name = lv_field.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validate_select_sql.

    DATA lv_sql TYPE string.

    DATA ls_parts TYPE zcl_milo_sql_parser=>ty_query_parts.

    CLEAR ev_object_name.

    lv_sql = condense( iv_sql ).
    lv_sql = zcl_milo_sql_parser=>uppercase_outside_literals( lv_sql ).

    IF lv_sql IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>empty_sql.
    ENDIF.

    IF lv_sql NP 'SELECT*'.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>only_select_allowed.
    ENDIF.

    IF lv_sql CS ';'.
      FIND PCRE ';[[:space:]]*[^[:space:]]'
        IN lv_sql.

      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>multiple_sql_not_allowed.
      ENDIF.

      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>forbidden_syntax.
    ENDIF.

    IF lv_sql CS '--'
       OR lv_sql CS '/*'
       OR lv_sql CS '*/'.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>sql_comment_not_allowed.
    ENDIF.

    IF lv_sql CS ' DELETE '
       OR lv_sql CS ' UPDATE '
       OR lv_sql CS ' INSERT '
       OR lv_sql CS ' MODIFY '
       OR lv_sql CS ' DROP '
       OR lv_sql CS ' ALTER '
       OR lv_sql CS ' CREATE '
       OR lv_sql CS ' TRUNCATE '
       OR lv_sql CS ' EXEC '
       OR lv_sql CS ' CALL '
       OR lv_sql CS ' MERGE '
       OR lv_sql CS ' UNION '
       OR lv_sql CS ' SUBMIT '.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>forbidden_keyword.
    ENDIF.

    IF lv_sql CP 'SELECT DISTINCT *'.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>forbidden_keyword.
    ENDIF.

    "========================
    " PARSE SQL
    "========================

    ls_parts = zcl_milo_sql_parser=>parse( lv_sql ).

    ev_object_name = ls_parts-table_name.

    IF ev_object_name IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>parse_failed.
    ENDIF.

    IF ls_parts-is_join = abap_true.

      validate_join_sql(
        is_parts           = ls_parts
        iv_wlist_profile_id = iv_wlist_profile_id ).

      RETURN.

    ENDIF.

    "========================
    " WHITELIST CHECK
    "========================

    DATA(lv_object_type) = zcl_milo_config=>get_object_type( ev_object_name ).

    IF lv_object_type IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid         = zcx_milo_validation=>object_not_found
          mv_object_name = ev_object_name.
    ELSEIF lv_object_type <> 'TRANSP' AND lv_object_type <> 'VIEW'.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid         = zcx_milo_validation=>unsupported_ddic_object_type
          mv_object_name = ev_object_name
          mv_value_1     = CONV string( lv_object_type ).
    ENDIF.

    IF zcl_milo_config=>is_object_allowed(
         iv_wlist_profile_id = iv_wlist_profile_id
         iv_obj_name         = ev_object_name ) <> abap_true.
      IF zcl_milo_config=>is_object_exists( ev_object_name ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid         = zcx_milo_validation=>object_not_found
            mv_object_name = ev_object_name.
      ENDIF.

      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid         = zcx_milo_validation=>object_not_whitelisted
          mv_object_name = ev_object_name
          mv_value_1     = CONV string( iv_wlist_profile_id ).
    ENDIF.

    "========================
    " FIELD VALIDATION
    "========================

    IF ls_parts-group_sql IS NOT INITIAL.

      validate_group_by(
        is_parts = ls_parts ).

      validate_group_having(
        is_parts = ls_parts ).

    ELSE.

      IF ls_parts-having_sql IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>having_without_group.
      ENDIF.

      validate_column_list(
        iv_sql      = lv_sql
        iv_obj_name = ev_object_name ).

    ENDIF.

    validate_where_clause(
      iv_sql      = lv_sql
      iv_obj_name = ev_object_name ).

    IF ls_parts-group_sql IS NOT INITIAL.

      validate_group_order(
        is_parts = ls_parts ).

    ELSE.

      validate_order_by(
        iv_sql      = lv_sql
        iv_obj_name = ev_object_name ).

    ENDIF.

  ENDMETHOD.


  METHOD validate_where_clause.

    DATA lt_condition TYPE tt_string.
    DATA lv_condition TYPE string.
    DATA lv_where TYPE string.
    DATA lv_field TYPE zmilo_field_name.
    DATA lv_op    TYPE string.
    DATA lv_value TYPE string.
    DATA lv_low TYPE string.
    DATA lv_high TYPE string.
    DATA lt_between_token TYPE tt_string.
    DATA lv_token TYPE string.
    DATA lt_in_value TYPE tt_string.
    DATA lv_in_value TYPE string.

    FIND PCRE '\sWHERE\s+(.+?)(\sGROUP\s+BY\s+|\sHAVING\s+|\sORDER\s+BY\s+|$)'
      IN iv_sql
      SUBMATCHES lv_where.

    IF sy-subrc <> 0.
      IF iv_sql CP '* WHERE'
         OR iv_sql CS ' WHERE GROUP BY '
         OR iv_sql CS ' WHERE HAVING '
         OR iv_sql CS ' WHERE ORDER BY '.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>where_expression_missing.
      ENDIF.
      RETURN.
    ENDIF.

    lv_where = condense( lv_where ).

    IF lv_where IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>where_expression_missing.
    ENDIF.

    lt_condition = split_where_conditions( iv_where = lv_where ).

    LOOP AT lt_condition INTO lv_condition.

      lv_condition = condense( lv_condition ).

      CLEAR: lv_field,
             lv_low,
             lv_high,
             lv_token,
             lt_between_token.

      SPLIT lv_condition AT space INTO TABLE lt_between_token.

      READ TABLE lt_between_token INTO lv_token INDEX 2.

      IF sy-subrc = 0 AND to_upper( lv_token ) = 'BETWEEN'.

        READ TABLE lt_between_token INTO lv_field INDEX 1.
        lv_field = to_upper( condense( lv_field ) ).

        IF lines( lt_between_token ) <> 5.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>between_syntax_invalid
              mv_field_name = lv_field.
        ENDIF.

        READ TABLE lt_between_token INTO lv_low INDEX 3.
        READ TABLE lt_between_token INTO lv_token INDEX 4.
        READ TABLE lt_between_token INTO lv_high INDEX 5.

        IF to_upper( lv_token ) <> 'AND'.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>between_syntax_invalid
              mv_field_name = lv_field.
        ENDIF.

        lv_low = condense( lv_low ).
        lv_high = condense( lv_high ).

        IF lv_field IS INITIAL
           OR lv_low IS INITIAL
           OR lv_high IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>between_syntax_invalid
              mv_field_name = lv_field.
        ENDIF.

        IF zcl_milo_config=>is_field_exists(
             iv_obj_name   = iv_obj_name
             iv_field_name = lv_field ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>where_field_invalid
              mv_field_name = lv_field.
        ENDIF.

        IF is_where_literal_valid( lv_low ) <> abap_true
           OR is_where_literal_valid( lv_high ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>between_syntax_invalid
              mv_field_name = lv_field.
        ENDIF.

        CONTINUE.

      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)[[:space:]]+LIKE[[:space:]]+(.+)$'
        IN lv_condition
        SUBMATCHES lv_field lv_value.

      IF sy-subrc = 0.

        lv_field = to_upper( condense( lv_field ) ).
        lv_value = condense( lv_value ).

        IF lv_field IS INITIAL
           OR lv_value IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>like_pattern_invalid
              mv_field_name = lv_field.
        ENDIF.

        IF zcl_milo_config=>is_field_exists(
             iv_obj_name   = iv_obj_name
             iv_field_name = lv_field ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>where_field_invalid
              mv_field_name = lv_field.
        ENDIF.

        IF is_where_literal_valid( lv_value ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>like_pattern_invalid
              mv_field_name = lv_field.
        ENDIF.

        CONTINUE.

      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)[[:space:]]+IN[[:space:]]*\((.+)\)$'
        IN lv_condition
        SUBMATCHES lv_field lv_value.

      IF sy-subrc = 0.

        lv_field = to_upper( condense( lv_field ) ).
        lv_value = condense( lv_value ).

        IF lv_field IS INITIAL
           OR lv_value IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>in_list_invalid
              mv_field_name = lv_field.
        ENDIF.

        IF zcl_milo_config=>is_field_exists(
             iv_obj_name   = iv_obj_name
             iv_field_name = lv_field ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>where_field_invalid
              mv_field_name = lv_field.
        ENDIF.

        IF lv_value CS '('
           OR lv_value CS ')'
           OR lv_value CS ' SELECT '
           OR lv_value CS ' FROM '
           OR lv_value CP ',*'
           OR lv_value CP '*,'
           OR lv_value CS ', ,'.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>in_list_invalid
              mv_field_name = lv_field.
        ENDIF.

        CLEAR lt_in_value.
        SPLIT lv_value AT ',' INTO TABLE lt_in_value.

        LOOP AT lt_in_value INTO lv_in_value.
          lv_in_value = condense( lv_in_value ).
          IF is_where_literal_valid( lv_in_value ) <> abap_true.
            RAISE EXCEPTION TYPE zcx_milo_validation
              EXPORTING
                textid        = zcx_milo_validation=>in_list_invalid
                mv_field_name = lv_field.
          ENDIF.
        ENDLOOP.

        CONTINUE.

      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)[[:space:]]+(IS|IS[[:space:]]+NOT)[[:space:]]+NULL$'
        IN lv_condition
        SUBMATCHES lv_field lv_op.

      IF sy-subrc = 0.
        lv_field = to_upper( condense( lv_field ) ).

        IF zcl_milo_config=>is_field_exists(
             iv_obj_name   = iv_obj_name
             iv_field_name = lv_field ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid        = zcx_milo_validation=>where_field_invalid
              mv_field_name = lv_field.
        ENDIF.

        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>null_comparison_invalid
            mv_field_name = lv_field.
      ENDIF.

      IF lv_condition CS '!='.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>where_operator_not_supported
            mv_value_1 = '!='.
      ELSEIF lv_condition CS '=='.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>where_operator_not_supported
            mv_value_1 = '=='.
      ELSEIF lv_condition CS ' NOT LIKE '.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>where_operator_not_supported
            mv_value_1 = 'NOT LIKE'.
      ELSEIF lv_condition CS ' NOT IN '.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>where_operator_not_supported
            mv_value_1 = 'NOT IN'.
      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)[[:space:]]+IN(?:[[:space:]]|$)'
        IN lv_condition
        SUBMATCHES lv_field.

      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>in_list_invalid
            mv_field_name = lv_field.
      ENDIF.

      IF lv_condition CS '(' OR lv_condition CS ')'.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>where_parentheses_invalid.
      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)[[:space:]]+LIKE(?:[[:space:]]|$)'
        IN lv_condition
        SUBMATCHES lv_field.

      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>like_pattern_invalid
            mv_field_name = lv_field.
      ENDIF.

      FIND PCRE '^([A-Z0-9_]+)\s*(=|<>|>=|<=|>|<)\s*(.+)$'
        IN lv_condition
        SUBMATCHES lv_field lv_op lv_value.

      IF sy-subrc <> 0.
        READ TABLE lt_between_token INTO lv_token INDEX 2.
        IF sy-subrc <> 0.
          lv_token = lv_condition.
        ENDIF.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid     = zcx_milo_validation=>where_operator_not_supported
            mv_value_1 = lv_token.
      ENDIF.

      lv_field = to_upper( condense( lv_field ) ).
      lv_value = condense( lv_value ).

      IF zcl_milo_config=>is_field_exists(
           iv_obj_name   = iv_obj_name
           iv_field_name = lv_field ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>where_field_invalid
            mv_field_name = lv_field.
      ENDIF.

      IF to_upper( lv_value ) = 'NULL'.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>null_comparison_invalid
            mv_field_name = lv_field.
      ENDIF.

      IF is_where_literal_valid( lv_value ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid        = zcx_milo_validation=>where_value_invalid
            mv_field_name = lv_field
            mv_value_1    = lv_value.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD is_where_literal_valid.

    DATA lv_value TYPE string.

    rv_valid = abap_false.
    lv_value = condense( iv_value ).

    IF lv_value IS INITIAL.
      RETURN.
    ENDIF.

    FIND PCRE '^[+-]?[0-9]+([.][0-9]+)?$'
      IN lv_value.

    IF sy-subrc = 0.
      rv_valid = abap_true.
      RETURN.
    ENDIF.

    FIND PCRE `^'([^']|'')*'$`
      IN lv_value.

    IF sy-subrc = 0.
      rv_valid = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD validate_aggregate_argument.

    DATA lv_object_name TYPE zmilo_obj_name.
    DATA lv_datatype TYPE dd03l-datatype.
    DATA lv_argument TYPE string.

    lv_argument = |{ iv_func }({ iv_field_name })|.

    IF iv_field_name = '*'.
      IF iv_func = 'COUNT'.
        RETURN.
      ENDIF.

      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid     = zcx_milo_validation=>aggregate_argument_invalid
          mv_value_1 = lv_argument.
    ENDIF.

    IF is_parts-is_join = abap_true.
      validate_join_field(
        is_parts      = is_parts
        iv_alias      = iv_alias
        iv_field_name = iv_field_name ).

      lv_object_name = get_join_source_object(
        is_parts = is_parts
        iv_alias = iv_alias ).
    ELSE.
      lv_object_name = is_parts-table_name.

      IF zcl_milo_config=>is_field_exists(
           iv_obj_name   = lv_object_name
           iv_field_name = iv_field_name ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid         = zcx_milo_validation=>field_not_found
            mv_field_name  = iv_field_name
            mv_object_name = lv_object_name.
      ENDIF.
    ENDIF.

    IF iv_func = 'COUNT'.
      RETURN.
    ENDIF.

    SELECT SINGLE datatype
      FROM dd03l
      WHERE tabname   = @lv_object_name
        AND fieldname = @iv_field_name
        AND as4local  = 'A'
      INTO @lv_datatype.

    IF sy-subrc <> 0
       OR ( lv_datatype <> 'INT1'
            AND lv_datatype <> 'INT2'
            AND lv_datatype <> 'INT4'
            AND lv_datatype <> 'INT8'
            AND lv_datatype <> 'DEC'
            AND lv_datatype <> 'CURR'
            AND lv_datatype <> 'QUAN'
            AND lv_datatype <> 'FLTP'
            AND lv_datatype <> 'DECFLOAT16'
            AND lv_datatype <> 'DECFLOAT34' ).
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid     = zcx_milo_validation=>aggregate_argument_invalid
          mv_value_1 = lv_argument.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
