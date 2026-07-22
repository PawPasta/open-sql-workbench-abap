*"* use this source file for your ABAP unit test classes
CLASS lcl_ut_ddic_browser DEFINITION FOR TESTING
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
      test_browser_search_tables     FOR TESTING,
      test_browser_get_fields        FOR TESTING,
      test_browser_preview_table     FOR TESTING.

ENDCLASS.

CLASS lcl_ut_ddic_browser IMPLEMENTATION.

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

  METHOD test_browser_search_tables.
    DATA(lt_tables) = zcl_milo_ddic_browser=>search_tables( iv_search = 'SPFLI' ).
    cl_abap_unit_assert=>assert_true( xsdbool( lines( lt_tables ) > 0 ) ).
  ENDMETHOD.

  METHOD test_browser_get_fields.
    TRY.
        DATA(lt_fields) = zcl_milo_ddic_browser=>get_fields( 'SPFLI' ).
        cl_abap_unit_assert=>assert_true( xsdbool( lines( lt_fields ) > 0 ) ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'get_fields failed for SPFLI' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_browser_preview_table.
    DATA lv_obj TYPE zmilo_obj_name.
    DATA lv_rows TYPE i.
    DATA lv_total TYPE i.
    DATA lv_json TYPE string.

    TRY.
        zcl_milo_ddic_browser=>preview_table(
          EXPORTING
            iv_wlist_profile_id = c_wlist_prof
            iv_obj_name         = 'SPFLI'
            iv_row_limit        = 10
          IMPORTING
            ev_object_name      = lv_obj
            ev_row_count        = lv_rows
            ev_total_rows       = lv_total
            ev_rows_json        = lv_json ).
        cl_abap_unit_assert=>assert_equals( act = lv_obj exp = 'SPFLI' ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'preview_table failed' ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
