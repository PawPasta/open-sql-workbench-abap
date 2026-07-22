*"* use this source file for your ABAP unit test classes
CLASS lcl_ut_service DEFINITION FOR TESTING
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
      test_service_saved_query_crud  FOR TESTING,
      test_service_preview_table_res FOR TESTING.

ENDCLASS.

CLASS lcl_ut_service IMPLEMENTATION.

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

  METHOD test_service_saved_query_crud.
    TRY.
        " 1. Save Query
        DATA(lv_query_id) = zcl_milo_service=>save_query(
          iv_profile_id  = c_profile_user
          iv_query_name  = 'UT_SAVED_QUERY'
          iv_query_text  = 'SELECT * FROM SPFLI'
          iv_visibility  = 'PRIVATE'
          iv_description = 'Unit Test Query' ).

        cl_abap_unit_assert=>assert_not_initial( lv_query_id ).

        " 2. Update Query
        zcl_milo_service=>update_query(
          iv_profile_id = c_profile_user
          iv_query_id   = lv_query_id
          iv_query_name = 'UT_SAVED_QUERY_UPDATED'
          iv_query_text = 'SELECT CARRID, CONNID FROM SPFLI' ).

        " 3. List Queries
        DATA(lt_queries) = zcl_milo_service=>list_queries(
          iv_profile_id = c_profile_user
          iv_owner_only = abap_true ).
        cl_abap_unit_assert=>assert_true( xsdbool( lines( lt_queries ) > 0 ) ).

        " 4. Run Saved Query
        DATA(ls_res) = zcl_milo_service=>run_saved_query_result(
          iv_profile_id = c_profile_user
          iv_query_id   = lv_query_id ).
        cl_abap_unit_assert=>assert_equals( act = ls_res-status exp = 'SUCCESS' ).

        " 5. Delete Query
        zcl_milo_service=>delete_query(
          iv_profile_id = c_profile_user
          iv_query_id   = lv_query_id ).

      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Saved Query CRUD lifecycle failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_service_preview_table_res.
    DATA(ls_res) = zcl_milo_service=>preview_table_result(
      iv_profile_id = c_profile_user
      iv_obj_name   = 'SPFLI'
      iv_row_limit  = 10 ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-status exp = 'SUCCESS' ).
    cl_abap_unit_assert=>assert_not_initial( ls_res-csv ).
  ENDMETHOD.

ENDCLASS.
