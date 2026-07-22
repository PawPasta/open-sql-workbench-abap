*"* use this source file for your ABAP unit test classes
CLASS lcl_ut_validator DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS:
      c_profile_user TYPE zmilo_profile_id VALUE 'UT_USER_PROF',
      c_wlist_prof   TYPE zmilo_wlist_profile_id VALUE 'UT_WLIST_PROF',
      c_mask_prof    TYPE zmilo_mask_profile_id VALUE 'UT_MASK_PROF'.

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
      test_val_order_by_invalid      FOR TESTING.

ENDCLASS.

CLASS lcl_ut_validator IMPLEMENTATION.

  METHOD setup.
    DATA ls_role TYPE zmilo_role.
    DATA ls_wlist TYPE zmilo_wlist.
    DATA ls_mask TYPE zmilo_mask.

    ls_role-profile_id       = c_profile_user.
    ls_role-pfcg_role        = 'Z_TEST_PFCG_ROLE'.
    ls_role-wlist_profile_id = c_wlist_prof.
    ls_role-mask_profile_id  = c_mask_prof.
    ls_role-is_active        = 'X'.
    MODIFY zmilo_role FROM @ls_role.

    DATA ls_agr TYPE agr_users.
    ls_agr-uname    = sy-uname.
    ls_agr-agr_name = 'Z_TEST_PFCG_ROLE'.
    ls_agr-from_dat = sy-datum - 1.
    ls_agr-to_dat   = sy-datum + 1.
    MODIFY agr_users FROM @ls_agr.

    ls_wlist-wlist_profile_id = c_wlist_prof.
    ls_wlist-obj_name         = 'SPFLI'.
    ls_wlist-is_active        = 'X'.
    ls_wlist-max_rows         = 50.
    MODIFY zmilo_wlist FROM @ls_wlist.

    ls_wlist-obj_name         = 'SFLIGHT'.
    MODIFY zmilo_wlist FROM @ls_wlist.

    ls_mask-mask_profile_id = c_mask_prof.
    ls_mask-obj_name        = 'SPFLI'.
    ls_mask-field_name      = 'CITYFROM'.
    ls_mask-mask_type       = 'PARTIAL'.
    ls_mask-is_active       = 'X'.
    MODIFY zmilo_mask FROM @ls_mask.

    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD teardown.
    DELETE FROM zmilo_role WHERE profile_id = @c_profile_user.
    DELETE FROM zmilo_wlist WHERE wlist_profile_id = @c_wlist_prof.
    DELETE FROM zmilo_mask WHERE mask_profile_id = @c_mask_prof.
    DELETE FROM agr_users WHERE uname = @sy-uname AND agr_name = 'Z_TEST_PFCG_ROLE'.
    DELETE FROM zmilo_query WHERE profile_id = @c_profile_user.
    DELETE FROM zmilo_log WHERE user_name = @sy-uname AND obj_name = 'SPFLI'.
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
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>object_not_allowed ).
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

ENDCLASS.
