*"* use this source file for your ABAP unit test classes
CLASS lcl_ut_sql_parser DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      test_parser_single_table       FOR TESTING,
      test_parser_join_table         FOR TESTING,
      test_parser_group_by_having    FOR TESTING,
      test_parser_order_by_norm      FOR TESTING,
      test_parser_cnt_dist_norm FOR TESTING,
      test_parser_invalid_sql        FOR TESTING.

ENDCLASS.

CLASS lcl_ut_sql_parser IMPLEMENTATION.

  METHOD test_parser_single_table.
    TRY.
        DATA(ls_parts) = zcl_milo_sql_parser=>parse( 'SELECT CARRID, CONNID FROM SPFLI WHERE CARRID = ''LH''' ).
        cl_abap_unit_assert=>assert_equals( act = ls_parts-table_name exp = 'SPFLI' ).
        cl_abap_unit_assert=>assert_false( ls_parts-is_join ).
        cl_abap_unit_assert=>assert_equals( act = lines( ls_parts-fields ) exp = 2 ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Parsing single table SELECT failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_parser_join_table.
    TRY.
        DATA(ls_parts) = zcl_milo_sql_parser=>parse(
          'SELECT A~CARRID, B~PRICE FROM SPFLI AS A INNER JOIN SFLIGHT AS B ON A~CARRID = B~CARRID' ).
        cl_abap_unit_assert=>assert_true( ls_parts-is_join ).
        cl_abap_unit_assert=>assert_equals( act = lines( ls_parts-sources ) exp = 2 ).
        cl_abap_unit_assert=>assert_equals( act = lines( ls_parts-joins ) exp = 1 ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Parsing JOIN SELECT failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_parser_group_by_having.
    TRY.
        DATA(ls_parts) = zcl_milo_sql_parser=>parse(
          'SELECT CARRID, COUNT( * ) AS TOTAL FROM SPFLI GROUP BY CARRID HAVING COUNT( * ) > 5' ).
        cl_abap_unit_assert=>assert_equals( act = ls_parts-group_sql exp = 'CARRID' ).
        cl_abap_unit_assert=>assert_equals( act = ls_parts-having_sql exp = 'COUNT( * ) > 5' ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Parsing GROUP BY SELECT failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_parser_order_by_norm.
    DATA(lv_order) = zcl_milo_sql_parser=>normalize_order_sql( 'CARRID ASC, CONNID DESC' ).
    cl_abap_unit_assert=>assert_equals( act = lv_order exp = 'CARRID ASCENDING, CONNID DESCENDING' ).
  ENDMETHOD.

  METHOD test_parser_cnt_dist_norm.
    DATA(lv_norm) = zcl_milo_sql_parser=>normalize_count_distinct_sql( 'COUNT(DISTINCT CARRID)' ).
    cl_abap_unit_assert=>assert_equals( act = lv_norm exp = 'COUNT( DISTINCT CARRID )' ).
  ENDMETHOD.

  METHOD test_parser_invalid_sql.
    TRY.
        zcl_milo_sql_parser=>parse( 'INVALID SQL STATEMENT' ).
        cl_abap_unit_assert=>fail( 'Should have raised zcx_milo_validation' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_bound( lx_val ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
