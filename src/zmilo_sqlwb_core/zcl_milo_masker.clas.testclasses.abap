*"* use this source file for your ABAP unit test classes
CLASS lcl_ut_masker DEFINITION FOR TESTING
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
      test_masker_full_mask          FOR TESTING,
      test_masker_replace_mask       FOR TESTING,
      test_masker_partial_mask       FOR TESTING.

ENDCLASS.

CLASS lcl_ut_masker IMPLEMENTATION.

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

  METHOD test_masker_full_mask.
    " Masking test via ZCL_MILO_EXECUTOR / ZCL_MILO_MASKER
    DATA lt_spfli TYPE STANDARD TABLE OF spfli.
    APPEND VALUE #( carrid = 'LH' connid = '0400' cityfrom = 'FRANKFURT' ) TO lt_spfli.
    DATA(lr_data) = REF #( lt_spfli ).

    zcl_milo_masker=>apply_mask(
      iv_mask_profile_id = c_mask_prof
      iv_obj_name        = 'SPFLI'
      ir_data            = lr_data ).

    READ TABLE lt_spfli ASSIGNING FIELD-SYMBOL(<ls_row>) INDEX 1.
    cl_abap_unit_assert=>assert_equals( act = <ls_row>-cityfrom exp = 'FRA***' ).
  ENDMETHOD.

  METHOD test_masker_replace_mask.
    " Masking REPLACE test logic
  ENDMETHOD.

  METHOD test_masker_partial_mask.
    " Masking PARTIAL test logic
  ENDMETHOD.

ENDCLASS.
