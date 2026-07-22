CLASS lcl_ut_milo_workbench DEFINITION FOR TESTING
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

      "-----------------------------------------------------------------
      " 9. TEST CASES CHO GATEWAY DPC EXTENSION (ZCL_ZSU26_GW_MILO_DPC_EXT)
      "-----------------------------------------------------------------
      test_dpc_ext_run_query_action  FOR TESTING,
      test_dpc_ext_save_query_action FOR TESTING.

ENDCLASS.


CLASS lcl_ut_milo_workbench IMPLEMENTATION.

  METHOD setup.
    " Chuẩn bị dữ liệu Test Profile trong các bảng custom cấu hình
    DATA ls_role TYPE zmilo_role.
    DATA ls_wlist TYPE zmilo_wlist.
    DATA ls_mask TYPE zmilo_mask.

    " 1. Tạo Test Role
    ls_role-profile_id       = c_profile_user.
    ls_role-pfcg_role        = 'Z_TEST_PFCG_ROLE'.
    ls_role-wlist_profile_id = c_wlist_prof.
    ls_role-mask_profile_id  = c_mask_prof.
    ls_role-is_active        = 'X'.
    MODIFY zmilo_role FROM @ls_role.

    " Gán quyền PFCG tạm thời cho user thử nghiệm trong session
    DATA ls_agr TYPE agr_users.
    ls_agr-uname    = sy-uname.
    ls_agr-agr_name = 'Z_TEST_PFCG_ROLE'.
    ls_agr-from_dat = sy-datum - 1.
    ls_agr-to_dat   = sy-datum + 1.
    MODIFY agr_users FROM @ls_agr.

    " 2. Tạo Whitelist cho bảng SPFLI và SFLIGHT
    ls_wlist-wlist_profile_id = c_wlist_prof.
    ls_wlist-obj_name         = 'SPFLI'.
    ls_wlist-is_active        = 'X'.
    ls_wlist-max_rows         = 50.
    MODIFY zmilo_wlist FROM @ls_wlist.

    ls_wlist-obj_name         = 'SFLIGHT'.
    MODIFY zmilo_wlist FROM @ls_wlist.

    " 3. Tạo Masking Rule cho trường CITYFROM của SPFLI
    ls_mask-mask_profile_id = c_mask_prof.
    ls_mask-obj_name        = 'SPFLI'.
    ls_mask-field_name      = 'CITYFROM'.
    ls_mask-mask_type       = 'PARTIAL'.
    ls_mask-is_active       = 'X'.
    MODIFY zmilo_mask FROM @ls_mask.

    COMMIT WORK AND WAIT.
  ENDMETHOD.


  METHOD teardown.
    " Dọn dẹp dữ liệu test sau khi hoàn tất
    DELETE FROM zmilo_role WHERE profile_id = @c_profile_user.
    DELETE FROM zmilo_wlist WHERE wlist_profile_id = @c_wlist_prof.
    DELETE FROM zmilo_mask WHERE mask_profile_id = @c_mask_prof.
    DELETE FROM agr_users WHERE uname = @sy-uname AND agr_name = 'Z_TEST_PFCG_ROLE'.
    DELETE FROM zmilo_query WHERE profile_id = @c_profile_user.
    DELETE FROM zmilo_log WHERE user_name = @sy-uname AND obj_name = 'SPFLI'.
    COMMIT WORK AND WAIT.
  ENDMETHOD.

  "---------------------------------------------------------------------
  " 9. GATEWAY DPC EXTENSION TESTS (ZCL_ZSU26_GW_MILO_DPC_EXT)
  "---------------------------------------------------------------------
  METHOD test_dpc_ext_run_query_action.
    DATA lo_dpc TYPE REF TO zcl_zsu26_gw_milo_dpc_ext.
    DATA lt_params TYPE /iwbep/t_mgw_name_value_pair.
    DATA lr_data TYPE REF TO data.

    CREATE OBJECT lo_dpc.

    APPEND VALUE #( name = 'PROFILEID' value = c_profile_user ) TO lt_params.
    APPEND VALUE #( name = 'SQLTEXT'   value = 'SELECT * FROM SPFLI' ) TO lt_params.
    APPEND VALUE #( name = 'PAGE'      value = '1' ) TO lt_params.

    TRY.
        lo_dpc->/iwbep/if_mgw_appl_srv_runtime~execute_action(
          EXPORTING
            iv_action_name = 'RUNQUERY'
            it_parameter   = lt_params
          IMPORTING
            er_data        = lr_data ).

        cl_abap_unit_assert=>assert_bound( lr_data ).
      CATCH /iwbep/cx_mgw_busi_exception /iwbep/cx_mgw_tech_exception.
        cl_abap_unit_assert=>fail( 'DPC_EXT EXECUTE_ACTION RUNQUERY failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_dpc_ext_save_query_action.
    DATA lo_dpc TYPE REF TO zcl_zsu26_gw_milo_dpc_ext.
    DATA lt_params TYPE /iwbep/t_mgw_name_value_pair.
    DATA lr_data TYPE REF TO data.

    CREATE OBJECT lo_dpc.

    APPEND VALUE #( name = 'PROFILEID' value = c_profile_user ) TO lt_params.
    APPEND VALUE #( name = 'QUERYNAME' value = 'DPC_ACTION_QUERY' ) TO lt_params.
    APPEND VALUE #( name = 'QUERYTEXT' value = 'SELECT CARRID FROM SPFLI' ) TO lt_params.

    TRY.
        lo_dpc->/iwbep/if_mgw_appl_srv_runtime~execute_action(
          EXPORTING
            iv_action_name = 'SAVEQUERY'
            it_parameter   = lt_params
          IMPORTING
            er_data        = lr_data ).

        cl_abap_unit_assert=>assert_bound( lr_data ).
      CATCH /iwbep/cx_mgw_busi_exception /iwbep/cx_mgw_tech_exception.
        cl_abap_unit_assert=>fail( 'DPC_EXT EXECUTE_ACTION SAVEQUERY failed' ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
