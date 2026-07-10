CLASS zcl_milo_sql_parser DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_source,
        object_name TYPE zmilo_obj_name,
        alias       TYPE string,
      END OF ty_source.

    TYPES tt_source TYPE STANDARD TABLE OF ty_source WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_join,
        join_type    TYPE string,
        left_alias   TYPE string,
        right_alias  TYPE string,
        right_object TYPE zmilo_obj_name,
        on_sql       TYPE string,
      END OF ty_join.

    TYPES tt_join TYPE STANDARD TABLE OF ty_join WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_select_field,
        source_alias TYPE string,
        field_name   TYPE zmilo_field_name,
        output_key   TYPE string,
        is_aggregate TYPE abap_bool,
        agg_func     TYPE string,
        is_distinct  TYPE abap_bool,
      END OF ty_select_field.

    TYPES tt_select_field TYPE STANDARD TABLE OF ty_select_field WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_query_parts,
        table_name TYPE zmilo_obj_name,
        columns    TYPE string,
        from_sql   TYPE string,
        where_sql  TYPE string,
        group_sql  TYPE string,
        having_sql TYPE string,
        order_sql  TYPE string,
        is_join    TYPE abap_bool,
        sources    TYPE tt_source,
        joins      TYPE tt_join,
        fields     TYPE tt_select_field,
      END OF ty_query_parts.

    CLASS-METHODS parse
      IMPORTING
        iv_sql          TYPE string
      RETURNING
        VALUE(rs_parts) TYPE ty_query_parts
      RAISING
        zcx_milo_validation.

    CLASS-METHODS normalize_order_sql
      IMPORTING
        iv_order        TYPE string
      RETURNING
        VALUE(rv_order) TYPE string.

    CLASS-METHODS normalize_count_distinct_sql
      IMPORTING
        iv_sql        TYPE string
      RETURNING
        VALUE(rv_sql) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS parse_join_sources
      IMPORTING
        iv_from_sql      TYPE string
      CHANGING
        cs_parts         TYPE ty_query_parts
      RAISING
        zcx_milo_validation.

    CLASS-METHODS parse_select_fields
      IMPORTING
        iv_columns       TYPE string
        iv_join_mode     TYPE abap_bool
      RETURNING
        VALUE(rt_field)  TYPE tt_select_field
      RAISING
        zcx_milo_validation.
ENDCLASS.



CLASS ZCL_MILO_SQL_PARSER IMPLEMENTATION.


  METHOD normalize_order_sql.

    rv_order = to_upper( condense( iv_order ) ).

    REPLACE ALL OCCURRENCES OF ' ASC' IN rv_order WITH ' ASCENDING'.
    REPLACE ALL OCCURRENCES OF ' DESC' IN rv_order WITH ' DESCENDING'.

  ENDMETHOD.


  METHOD parse.

    DATA lv_sql TYPE string.
    DATA lv_cols TYPE string.
    DATA lv_table TYPE zmilo_obj_name.
    DATA lv_from TYPE string.
    DATA lv_where TYPE string.
    DATA lv_group TYPE string.
    DATA lv_having TYPE string.
    DATA lv_order TYPE string.

    lv_sql = iv_sql.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_sql WITH space.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN lv_sql WITH space.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>horizontal_tab IN lv_sql WITH space.
    REPLACE ALL OCCURRENCES OF '\r\n' IN lv_sql WITH space.
    REPLACE ALL OCCURRENCES OF '\n' IN lv_sql WITH space.
    REPLACE ALL OCCURRENCES OF '\r' IN lv_sql WITH space.
    REPLACE ALL OCCURRENCES OF '%0D%0A' IN lv_sql WITH space.
    REPLACE ALL OCCURRENCES OF '%0d%0a' IN lv_sql WITH space.
    REPLACE ALL OCCURRENCES OF '%0A' IN lv_sql WITH space.
    REPLACE ALL OCCURRENCES OF '%0a' IN lv_sql WITH space.
    REPLACE ALL OCCURRENCES OF '%0D' IN lv_sql WITH space.
    REPLACE ALL OCCURRENCES OF '%0d' IN lv_sql WITH space.
    lv_sql = condense( lv_sql ).
    lv_sql = to_upper( lv_sql ).

    CLEAR rs_parts.

    "SELECT columns FROM source clause
    FIND PCRE '^SELECT[[:space:]]+(.+?)[[:space:]]+FROM[[:space:]]+(.+?)([[:space:]]+WHERE[[:space:]]+|[[:space:]]+GROUP[[:space:]]+BY[[:space:]]+|[[:space:]]+HAVING[[:space:]]+|[[:space:]]+ORDER[[:space:]]+BY[[:space:]]+|$)'
      IN lv_sql
      SUBMATCHES lv_cols lv_from.

    IF sy-subrc <> 0 OR lv_cols IS INITIAL OR lv_from IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>parse_failed.
    ENDIF.

    rs_parts-columns    = condense( lv_cols ).
    rs_parts-from_sql   = condense( lv_from ).
    REPLACE ALL OCCURRENCES OF ' LEFT JOIN ' IN rs_parts-from_sql WITH ' LEFT OUTER JOIN '.

    IF rs_parts-from_sql CS ' JOIN '.

      rs_parts-is_join = abap_true.

      parse_join_sources(
        EXPORTING
          iv_from_sql = rs_parts-from_sql
        CHANGING
          cs_parts    = rs_parts ).

    ELSE.

      FIND PCRE '^([A-Z0-9_]+)$'
        IN rs_parts-from_sql
        SUBMATCHES lv_table.

      IF sy-subrc <> 0 OR lv_table IS INITIAL.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>parse_failed.
      ENDIF.

      rs_parts-table_name = lv_table.
      APPEND VALUE ty_source(
        object_name = lv_table
        alias       = '' ) TO rs_parts-sources.

    ENDIF.

    rs_parts-fields = parse_select_fields(
      iv_columns   = rs_parts-columns
      iv_join_mode = rs_parts-is_join ).

    "WHERE ... before GROUP BY, HAVING, ORDER BY or end
    FIND PCRE '[[:space:]]+WHERE[[:space:]]+(.+?)([[:space:]]+GROUP[[:space:]]+BY[[:space:]]+|[[:space:]]+HAVING[[:space:]]+|[[:space:]]+ORDER[[:space:]]+BY[[:space:]]+|$)'
      IN lv_sql
      SUBMATCHES lv_where.

    IF sy-subrc = 0.
      rs_parts-where_sql = condense( lv_where ).
    ENDIF.

    "GROUP BY ... before HAVING, ORDER BY or end
    FIND PCRE '[[:space:]]+GROUP[[:space:]]+BY[[:space:]]+(.+?)([[:space:]]+HAVING[[:space:]]+|[[:space:]]+ORDER[[:space:]]+BY[[:space:]]+|$)'
      IN lv_sql
      SUBMATCHES lv_group.

    IF sy-subrc = 0.
      rs_parts-group_sql = condense( lv_group ).
    ENDIF.

    "HAVING ... before ORDER BY or end
    FIND PCRE '[[:space:]]+HAVING[[:space:]]+(.+?)([[:space:]]+ORDER[[:space:]]+BY[[:space:]]+|$)'
      IN lv_sql
      SUBMATCHES lv_having.

    IF sy-subrc = 0.
      rs_parts-having_sql = normalize_count_distinct_sql( lv_having ).
    ENDIF.

    "ORDER BY field ASC/DESC
    FIND PCRE '[[:space:]]+ORDER[[:space:]]+BY[[:space:]]+(.+)$'
      IN lv_sql
      SUBMATCHES lv_order.

    IF sy-subrc = 0.
      rs_parts-order_sql = normalize_order_sql( lv_order ).
    ENDIF.

  ENDMETHOD.


  METHOD parse_join_sources.

    DATA lv_left_object TYPE zmilo_obj_name.
    DATA lv_left_alias TYPE string.
    DATA lv_right_object TYPE zmilo_obj_name.
    DATA lv_right_alias TYPE string.
    DATA lv_on_sql TYPE string.
    DATA lv_rest TYPE string.
    DATA lv_join_type TYPE string.
    DATA lv_match_len TYPE i.

    FIND PCRE '^([A-Z0-9_]+)\s+AS\s+([A-Z0-9_]+)\s+(.+)$'
      IN iv_from_sql
      SUBMATCHES lv_left_object lv_left_alias lv_rest.

    IF sy-subrc <> 0
       OR lv_left_object IS INITIAL
       OR lv_left_alias IS INITIAL
       OR lv_rest IS INITIAL.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>parse_failed.
    ENDIF.

    cs_parts-table_name = lv_left_object.

    APPEND VALUE ty_source(
      object_name = lv_left_object
      alias       = lv_left_alias ) TO cs_parts-sources.

    lv_rest = condense( lv_rest ).

    WHILE lv_rest IS NOT INITIAL.

      CLEAR: lv_right_object,
             lv_right_alias,
             lv_on_sql,
             lv_join_type,
             lv_match_len.

      FIND PCRE '^((?:INNER)|(?:LEFT[[:space:]]+OUTER))[[:space:]]+JOIN[[:space:]]+([A-Z0-9_]+)[[:space:]]+AS[[:space:]]+([A-Z0-9_]+)[[:space:]]+ON[[:space:]]+(.+?)(?=[[:space:]]+(?:INNER|LEFT[[:space:]]+OUTER)[[:space:]]+JOIN[[:space:]]+|$)'
        IN lv_rest
        MATCH LENGTH lv_match_len
        SUBMATCHES lv_join_type lv_right_object lv_right_alias lv_on_sql.

      IF sy-subrc <> 0
         OR lv_match_len IS INITIAL
         OR lv_join_type IS INITIAL
         OR lv_right_object IS INITIAL
         OR lv_right_alias IS INITIAL
         OR lv_on_sql IS INITIAL.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>parse_failed.
      ENDIF.

      LOOP AT cs_parts-sources INTO DATA(ls_existing_source).
        IF ls_existing_source-alias = lv_right_alias.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid = zcx_milo_validation=>parse_failed.
        ENDIF.
      ENDLOOP.

      APPEND VALUE ty_source(
        object_name = lv_right_object
        alias       = lv_right_alias ) TO cs_parts-sources.

      APPEND VALUE ty_join(
        join_type    = COND string(
                         WHEN lv_join_type = 'INNER' THEN 'INNER'
                         ELSE 'LEFT_OUTER' )
        left_alias   = ''
        right_alias  = lv_right_alias
        right_object = lv_right_object
        on_sql       = condense( lv_on_sql ) ) TO cs_parts-joins.

      IF lv_match_len >= strlen( lv_rest ).
        CLEAR lv_rest.
      ELSE.
        lv_rest = substring(
          val = lv_rest
          off = lv_match_len ).
        lv_rest = condense( lv_rest ).
      ENDIF.

    ENDWHILE.

    IF lines( cs_parts-joins ) = 0.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid = zcx_milo_validation=>parse_failed.
    ENDIF.

  ENDMETHOD.


  METHOD parse_select_fields.

    DATA lt_column TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_column TYPE string.
    DATA lv_alias TYPE string.
    DATA lv_field TYPE string.
    DATA lv_func TYPE string.
    DATA lv_distinct TYPE string.
    DATA lv_output TYPE string.

    IF iv_columns = '*'.
      IF iv_join_mode = abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>parse_failed.
      ENDIF.
      RETURN.
    ENDIF.

    SPLIT iv_columns AT ',' INTO TABLE lt_column.

    LOOP AT lt_column INTO lv_column.

      lv_column = condense( lv_column ).

      FIND PCRE '^(COUNT|SUM|AVG|MIN|MAX)\s*\(\s*(DISTINCT\s+)?([A-Z0-9_~*]+)\s*\)\s+AS\s+([A-Z0-9_]+)$'
        IN lv_column
        SUBMATCHES lv_func lv_distinct lv_field lv_output.

      IF sy-subrc = 0
         AND lv_func IS NOT INITIAL
         AND lv_field IS NOT INITIAL
         AND lv_output IS NOT INITIAL.

        CLEAR lv_alias.

        IF lv_distinct IS NOT INITIAL
           AND ( lv_func <> 'COUNT' OR lv_field = '*' ).
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid = zcx_milo_validation=>parse_failed.
        ENDIF.

        IF lv_field <> '*'.
          IF iv_join_mode = abap_true.
            FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)$'
              IN lv_field
              SUBMATCHES lv_alias lv_field.

            IF sy-subrc <> 0 OR lv_alias IS INITIAL OR lv_field IS INITIAL.
              RAISE EXCEPTION TYPE zcx_milo_validation
                EXPORTING
                  textid = zcx_milo_validation=>parse_failed.
            ENDIF.
          ELSE.
            FIND PCRE '^([A-Z0-9_]+)$'
              IN lv_field
              SUBMATCHES lv_field.

            IF sy-subrc <> 0 OR lv_field IS INITIAL.
              RAISE EXCEPTION TYPE zcx_milo_validation
                EXPORTING
                  textid = zcx_milo_validation=>parse_failed.
            ENDIF.
          ENDIF.
        ENDIF.

        APPEND VALUE ty_select_field(
          source_alias = lv_alias
          field_name   = CONV zmilo_field_name( lv_field )
          output_key   = to_lower( lv_output )
          is_aggregate = abap_true
          agg_func     = lv_func
          is_distinct  = xsdbool( lv_distinct IS NOT INITIAL ) ) TO rt_field.

        CONTINUE.

      ENDIF.

      IF lv_column CS '(' OR lv_column CS ')'.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid = zcx_milo_validation=>parse_failed.
      ENDIF.

      IF iv_join_mode = abap_true.

        FIND PCRE '^([A-Z0-9_]+)~([A-Z0-9_]+)$'
          IN lv_column
          SUBMATCHES lv_alias lv_field.

        IF sy-subrc <> 0 OR lv_alias IS INITIAL OR lv_field IS INITIAL.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid = zcx_milo_validation=>parse_failed.
        ENDIF.

        APPEND VALUE ty_select_field(
          source_alias = lv_alias
          field_name   = CONV zmilo_field_name( lv_field )
          output_key   = to_lower( lv_alias && '_' && lv_field ) ) TO rt_field.

      ELSE.

        FIND PCRE '^([A-Z0-9_]+)$'
          IN lv_column
          SUBMATCHES lv_field.

        IF sy-subrc = 0 AND lv_field IS NOT INITIAL.
          APPEND VALUE ty_select_field(
            source_alias = ''
            field_name   = CONV zmilo_field_name( lv_field )
            output_key   = to_lower( lv_field ) ) TO rt_field.
        ELSE.
          RAISE EXCEPTION TYPE zcx_milo_validation
            EXPORTING
              textid = zcx_milo_validation=>parse_failed.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD normalize_count_distinct_sql.

    DATA lv_offset TYPE i.
    DATA lv_length TYPE i.
    DATA lv_after_offset TYPE i.
    DATA lv_close_offset TYPE i.
    DATA lv_prefix TYPE string.
    DATA lv_suffix TYPE string.
    DATA lv_rest TYPE string.
    DATA lv_field TYPE string.

    rv_sql = condense( iv_sql ).

    DO.

      CLEAR: lv_offset,
             lv_length,
             lv_after_offset,
             lv_close_offset,
             lv_prefix,
             lv_suffix,
             lv_rest,
             lv_field.

      FIND 'COUNT(DISTINCT '
        IN rv_sql
        MATCH OFFSET lv_offset
        MATCH LENGTH lv_length.

      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      lv_after_offset = lv_offset + lv_length.

      lv_prefix = substring(
        val = rv_sql
        off = 0
        len = lv_offset ).

      lv_rest = substring(
        val = rv_sql
        off = lv_after_offset ).

      FIND ')'
        IN lv_rest
        MATCH OFFSET lv_close_offset.

      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      lv_field = substring(
        val = lv_rest
        off = 0
        len = lv_close_offset ).

      lv_field = condense( lv_field ).

      lv_after_offset = lv_close_offset + 1.
      lv_suffix = substring(
        val = lv_rest
        off = lv_after_offset ).

      rv_sql = |{ lv_prefix }COUNT( DISTINCT { lv_field } ){ lv_suffix }|.

    ENDDO.

  ENDMETHOD.
ENDCLASS.
