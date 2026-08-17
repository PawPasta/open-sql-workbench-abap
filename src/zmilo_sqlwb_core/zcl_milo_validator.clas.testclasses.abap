*"* use this source file for your ABAP unit test classes
CLASS lcl_ut_validator DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL DANGEROUS.

  PRIVATE SECTION.
    CONSTANTS:
      c_wlist_prof TYPE zmilo_wlist_profile_id VALUE 'UT_WLIST_PROF'.

    METHODS:
      setup,
      teardown,
      test_val_empty_sql             FOR TESTING,
      test_val_non_select            FOR TESTING,
      test_val_forbidden_syntax      FOR TESTING,
      test_val_forbidden_keyword     FOR TESTING,
      test_val_unwhitelisted_table   FOR TESTING,
      test_val_invalid_field         FOR TESTING,
      test_val_where_between_like_in FOR TESTING,
      test_val_where_subquery_block  FOR TESTING,
      test_val_group_having_valid    FOR TESTING,
      test_val_group_having_invalid  FOR TESTING,
      test_val_order_by_valid        FOR TESTING,
      test_val_order_by_invalid      FOR TESTING,
      test_val_top_limit             FOR TESTING.

ENDCLASS.

CLASS lcl_ut_validator IMPLEMENTATION.

  METHOD setup.
    DATA ls_wlist TYPE zmilo_wlist.

    ls_wlist-wlist_profile_id = c_wlist_prof.
    ls_wlist-obj_name         = 'SPFLI'.
    ls_wlist-is_active        = 'X'.
    ls_wlist-max_rows         = 50.
    MODIFY zmilo_wlist FROM @ls_wlist.

    ls_wlist-obj_name         = 'SFLIGHT'.
    MODIFY zmilo_wlist FROM @ls_wlist.

    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD teardown.
    DELETE FROM zmilo_wlist WHERE wlist_profile_id = @c_wlist_prof.
    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD test_val_empty_sql.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = ''
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Empty SQL check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>empty_sql ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_non_select.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'DELETE FROM SPFLI WHERE CARRID = ''LH'''
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Non-SELECT check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_true( xsdbool(
          lx_val->if_t100_message~t100key = zcx_milo_validation=>only_select_allowed OR
          lx_val->if_t100_message~t100key = zcx_milo_validation=>forbidden_keyword ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_forbidden_syntax.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT * FROM SPFLI; DROP TABLE SPFLI;'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Semicolon check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val1).
        cl_abap_unit_assert=>assert_equals( act = lx_val1->if_t100_message~t100key exp = zcx_milo_validation=>forbidden_syntax ).
    ENDTRY.

    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT * FROM SPFLI -- comment'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Comment check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val2).
        cl_abap_unit_assert=>assert_equals( act = lx_val2->if_t100_message~t100key exp = zcx_milo_validation=>forbidden_syntax ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_forbidden_keyword.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT DISTINCT CARRID FROM SPFLI'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Standalone DISTINCT check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>forbidden_keyword ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_unwhitelisted_table.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT * FROM USR02'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Unwhitelisted table check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>object_not_whitelisted ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_invalid_field.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT NON_EXISTENT_COLUMN FROM SPFLI'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Invalid field check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>invalid_field ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_where_between_like_in.
    TRY.
        DATA lv_obj TYPE zmilo_obj_name.
        zcl_milo_validator=>validate_select_sql(
          EXPORTING
            iv_sql              = 'SELECT CARRID, CONNID FROM SPFLI WHERE CONNID BETWEEN 0001 AND 9999 AND CITYFROM LIKE ''FRANK%'' AND CARRID IN ( ''LH'', ''AA'' )'
            iv_wlist_profile_id = c_wlist_prof
          IMPORTING
            ev_object_name      = lv_obj ).
        cl_abap_unit_assert=>assert_equals( act = lv_obj exp = 'SPFLI' ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Complex WHERE validation failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_where_subquery_block.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT CARRID FROM SPFLI WHERE CARRID IN ( SELECT CARRID FROM SFLIGHT )'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Subquery in WHERE check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>invalid_where ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_group_having_valid.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT CARRID, COUNT( * ) AS TOTAL FROM SPFLI GROUP BY CARRID HAVING COUNT( * ) > 2'
          iv_wlist_profile_id = c_wlist_prof ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Valid GROUP BY HAVING failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_group_having_invalid.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT CARRID, CITYFROM FROM SPFLI GROUP BY CARRID'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Unaggregated field check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>invalid_field ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_order_by_valid.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT CARRID, CONNID FROM SPFLI ORDER BY CARRID ASC, CONNID DESC'
          iv_wlist_profile_id = c_wlist_prof ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Valid ORDER BY failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_order_by_invalid.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT CARRID FROM SPFLI ORDER BY INVALID_COL'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Invalid ORDER BY check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>invalid_field ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_top_limit.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT TOP 51 CARRID FROM SPFLI'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'TOP must not exceed the configured maximum' ).
      CATCH zcx_milo_validation INTO DATA(lx_validation).
        cl_abap_unit_assert=>assert_equals(
          act = lx_validation->if_t100_message~t100key
          exp = zcx_milo_validation=>top_limit_exceeded ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
