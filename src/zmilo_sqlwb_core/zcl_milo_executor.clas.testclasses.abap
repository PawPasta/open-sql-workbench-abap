*"* use this source file for your ABAP unit test classes
CLASS lcl_ut_executor DEFINITION FOR TESTING
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
      test_exec_single_select        FOR TESTING,
      test_exec_join_select          FOR TESTING,
      test_exec_group_select         FOR TESTING,
      test_exec_blocked_sql          FOR TESTING.

ENDCLASS.

CLASS lcl_ut_executor IMPLEMENTATION.

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

  METHOD test_exec_single_select.
    DATA lv_obj TYPE zmilo_obj_name.
    DATA lv_rows TYPE i.
    DATA lv_returned TYPE i.
    DATA lv_status TYPE string.
    DATA lv_max TYPE i.
    DATA lv_trunc TYPE abap_bool.
    DATA lv_json TYPE string.

    TRY.
        zcl_milo_executor=>execute_select(
          EXPORTING
            iv_sql              = 'SELECT CARRID, CONNID, CITYFROM FROM SPFLI'
            iv_wlist_profile_id = c_wlist_prof
            iv_mask_profile_id  = c_mask_prof
          IMPORTING
            ev_object_name      = lv_obj
            ev_row_count        = lv_rows
            ev_returned_rows    = lv_returned
            ev_status           = lv_status
            ev_max_rows         = lv_max
            ev_truncated        = lv_trunc
            ev_rows_json        = lv_json ).

        cl_abap_unit_assert=>assert_equals( act = lv_status exp = 'SUCCESS' ).
        cl_abap_unit_assert=>assert_equals( act = lv_obj exp = 'SPFLI' ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Single SELECT execution failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_exec_join_select.
    DATA lv_status TYPE string.
    DATA lv_json TYPE string.

    TRY.
        zcl_milo_executor=>execute_select(
          EXPORTING
            iv_sql              = 'SELECT A~CARRID, B~PRICE FROM SPFLI AS A INNER JOIN SFLIGHT AS B ON A~CARRID = B~CARRID'
            iv_wlist_profile_id = c_wlist_prof
          IMPORTING
            ev_status           = lv_status
            ev_rows_json        = lv_json ).

        cl_abap_unit_assert=>assert_equals( act = lv_status exp = 'SUCCESS' ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'JOIN SELECT execution failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_exec_group_select.
    DATA lv_status TYPE string.

    TRY.
        zcl_milo_executor=>execute_select(
          EXPORTING
            iv_sql              = 'SELECT CARRID, COUNT( * ) AS TOTAL FROM SPFLI GROUP BY CARRID'
            iv_wlist_profile_id = c_wlist_prof
          IMPORTING
            ev_status           = lv_status ).

        cl_abap_unit_assert=>assert_equals( act = lv_status exp = 'SUCCESS' ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'GROUP BY SELECT execution failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_exec_blocked_sql.
    TRY.
        zcl_milo_executor=>execute_select(
          iv_sql              = 'DELETE FROM SPFLI'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Blocked SQL did not raise exception' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_bound( lx_val ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
