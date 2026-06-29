*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_SQL_PARSER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmilo_test_sql_parser.

PARAMETERS p_sql TYPE string LOWER CASE DEFAULT 'SELECT a~carrid, a~connid, b~carrname FROM spfli AS a INNER JOIN scarr AS b ON a~carrid = b~carrid WHERE a~carrid = ''AA'' ORDER BY a~carrid, a~connid'.

START-OF-SELECTION.

  TRY.

      DATA(ls_parts) = zcl_milo_sql_parser=>parse( p_sql ).

      WRITE: / 'PARSE STATUS: SUCCESS'.
      WRITE: / 'IS JOIN:', ls_parts-is_join.
      WRITE: / 'TABLE NAME:', ls_parts-table_name.
      WRITE: / 'COLUMNS:', ls_parts-columns.
      WRITE: / 'FROM SQL:', ls_parts-from_sql.
      WRITE: / 'WHERE SQL:', ls_parts-where_sql.
      WRITE: / 'GROUP SQL:', ls_parts-group_sql.
      WRITE: / 'HAVING SQL:', ls_parts-having_sql.
      WRITE: / 'ORDER SQL:', ls_parts-order_sql.

      SKIP.
      WRITE: / 'SOURCES:'.

      IF ls_parts-sources IS INITIAL.
        WRITE: / '  <none>'.
      ELSE.
        LOOP AT ls_parts-sources INTO DATA(ls_source).
          WRITE: / '  OBJECT:', ls_source-object_name,
                   'ALIAS:', ls_source-alias.
        ENDLOOP.
      ENDIF.

      SKIP.
      WRITE: / 'JOINS:'.

      IF ls_parts-joins IS INITIAL.
        WRITE: / '  <none>'.
      ELSE.
        LOOP AT ls_parts-joins INTO DATA(ls_join).
          WRITE: / '  TYPE:', ls_join-join_type,
                   'LEFT:', ls_join-left_alias,
                   'RIGHT:', ls_join-right_alias,
                   'RIGHT OBJECT:', ls_join-right_object.
          WRITE: / '  ON:', ls_join-on_sql.
        ENDLOOP.
      ENDIF.

      SKIP.
      WRITE: / 'FIELDS:'.

      IF ls_parts-fields IS INITIAL.
        WRITE: / '  <none>'.
      ELSE.
        LOOP AT ls_parts-fields INTO DATA(ls_field).
          WRITE: / '  ALIAS:', ls_field-source_alias,
                   'FIELD:', ls_field-field_name,
                   'JSON KEY:', ls_field-output_key,
                   'AGG:', ls_field-is_aggregate,
                   'FUNC:', ls_field-agg_func.
        ENDLOOP.
      ENDIF.

    CATCH zcx_milo_validation INTO DATA(lx_validation).

      WRITE: / 'PARSE STATUS: BLOCKED'.
      WRITE: / 'REASON:', lx_validation->get_text( ).

  ENDTRY.
