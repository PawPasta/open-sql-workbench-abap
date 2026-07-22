*"* use this source file for your ABAP unit test classes

CLASS lcl_ut_config DEFINITION FOR TESTING
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
      test_config_get_role_config    FOR TESTING,
      test_config_is_object_allowed   FOR TESTING,
      test_config_get_mask_rules      FOR TESTING,
      test_config_get_max_rows        FOR TESTING,
      test_config_is_field_exists     FOR TESTING.

ENDCLASS.

CLASS lcl_ut_config IMPLEMENTATION.

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

  METHOD test_config_get_role_config.
    DATA(ls_role) = zcl_milo_config=>get_role_config( c_profile_user ).
    cl_abap_unit_assert=>assert_equals( act = ls_role-profile_id exp = c_profile_user ).

    DATA(ls_empty) = zcl_milo_config=>get_role_config( 'NON_EXISTENT' ).
    cl_abap_unit_assert=>assert_initial( ls_empty-profile_id ).
  ENDMETHOD.

  METHOD test_config_is_object_allowed.
    DATA(lv_allowed) = zcl_milo_config=>is_object_allowed(
      iv_wlist_profile_id = c_wlist_prof
      iv_obj_name         = 'SPFLI' ).
    cl_abap_unit_assert=>assert_true( lv_allowed ).

    DATA(lv_forbidden) = zcl_milo_config=>is_object_allowed(
      iv_wlist_profile_id = c_wlist_prof
      iv_obj_name         = 'USR02' ).
    cl_abap_unit_assert=>assert_false( lv_forbidden ).
  ENDMETHOD.

  METHOD test_config_get_mask_rules.
    DATA(lt_mask) = zcl_milo_config=>get_mask_rules(
      iv_mask_profile_id = c_mask_prof
      iv_obj_name        = 'SPFLI' ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_mask ) exp = 1 ).
  ENDMETHOD.

  METHOD test_config_get_max_rows.
    DATA(lv_rows) = zcl_milo_config=>get_object_max_rows(
      iv_wlist_profile_id = c_wlist_prof
      iv_obj_name         = 'SPFLI' ).
    cl_abap_unit_assert=>assert_equals( act = lv_rows exp = 50 ).

    DATA(lv_default) = zcl_milo_config=>get_object_max_rows(
      iv_wlist_profile_id = c_wlist_prof
      iv_obj_name         = 'UNKNOWN_TABLE' ).
    cl_abap_unit_assert=>assert_equals( act = lv_default exp = 100 ).
  ENDMETHOD.

  METHOD test_config_is_field_exists.
    DATA(lv_exists) = zcl_milo_config=>is_field_exists(
      iv_obj_name   = 'SPFLI'
      iv_field_name = 'CARRID' ).
    cl_abap_unit_assert=>assert_true( lv_exists ).

    DATA(lv_not_exists) = zcl_milo_config=>is_field_exists(
      iv_obj_name   = 'SPFLI'
      iv_field_name = 'INVALID_COL' ).
    cl_abap_unit_assert=>assert_false( lv_not_exists ).
  ENDMETHOD.

ENDCLASS.
