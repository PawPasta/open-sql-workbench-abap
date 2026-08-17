*"* use this source file for your ABAP unit test classes
CLASS lcl_ut_masker DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL DANGEROUS.

  PRIVATE SECTION.
    CONSTANTS:
      c_mask_prof    TYPE zmilo_mask_profile_id VALUE 'UT_MASK_PROF'.

    METHODS:
      setup,
      teardown,
      test_masker_full_mask          FOR TESTING,
      test_masker_replace_mask       FOR TESTING,
      test_masker_partial_mask       FOR TESTING,
      test_masker_selected_columns   FOR TESTING.

ENDCLASS.

CLASS lcl_ut_masker IMPLEMENTATION.

  METHOD setup.
    DATA ls_mask TYPE zmilo_mask.

    ls_mask-mask_profile_id = c_mask_prof.
    ls_mask-obj_name        = 'SPFLI'.
    ls_mask-field_name      = 'CITYFROM'.
    ls_mask-mask_type       = 'PARTIAL'.
    ls_mask-is_active       = 'X'.
    MODIFY zmilo_mask FROM @ls_mask.

    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD teardown.
    DELETE FROM zmilo_mask WHERE mask_profile_id = @c_mask_prof.
    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD test_masker_full_mask.
    DATA ls_mask TYPE zmilo_mask.
    ls_mask-mask_profile_id = c_mask_prof.
    ls_mask-obj_name        = 'SPFLI'.
    ls_mask-field_name      = 'CITYFROM'.
    ls_mask-mask_type       = 'FULL'.
    ls_mask-is_active       = 'X'.
    MODIFY zmilo_mask FROM @ls_mask.
    COMMIT WORK AND WAIT.

    DATA lt_spfli TYPE STANDARD TABLE OF spfli.
    APPEND VALUE #( carrid = 'LH' connid = '0400' cityfrom = 'FRANKFURT' ) TO lt_spfli.
    DATA(lr_data) = REF #( lt_spfli ).

    zcl_milo_masker=>apply_mask(
      iv_mask_profile_id = c_mask_prof
      iv_obj_name        = 'SPFLI'
      ir_data            = lr_data ).

    READ TABLE lt_spfli ASSIGNING FIELD-SYMBOL(<ls_row>) INDEX 1.
    cl_abap_unit_assert=>assert_equals( act = <ls_row>-cityfrom exp = '[HIDDEN]' ).
  ENDMETHOD.

  METHOD test_masker_replace_mask.
    DATA ls_mask TYPE zmilo_mask.
    ls_mask-mask_profile_id = c_mask_prof.
    ls_mask-obj_name        = 'SPFLI'.
    ls_mask-field_name      = 'CITYFROM'.
    ls_mask-mask_type       = 'REPLACE'.
    ls_mask-mask_value      = 'REPLACED_CITY'.
    ls_mask-is_active       = 'X'.
    MODIFY zmilo_mask FROM @ls_mask.
    COMMIT WORK AND WAIT.

    DATA lt_spfli TYPE STANDARD TABLE OF spfli.
    APPEND VALUE #( carrid = 'LH' connid = '0400' cityfrom = 'FRANKFURT' ) TO lt_spfli.
    DATA(lr_data) = REF #( lt_spfli ).

    zcl_milo_masker=>apply_mask(
      iv_mask_profile_id = c_mask_prof
      iv_obj_name        = 'SPFLI'
      ir_data            = lr_data ).

    READ TABLE lt_spfli ASSIGNING FIELD-SYMBOL(<ls_row>) INDEX 1.
    cl_abap_unit_assert=>assert_equals( act = <ls_row>-cityfrom exp = 'REPLACED_CITY' ).
  ENDMETHOD.

  METHOD test_masker_partial_mask.
    DATA ls_mask TYPE zmilo_mask.
    ls_mask-mask_profile_id = c_mask_prof.
    ls_mask-obj_name        = 'SPFLI'.
    ls_mask-field_name      = 'CITYFROM'.
    ls_mask-mask_type       = 'PARTIAL'.
    ls_mask-is_active       = 'X'.
    MODIFY zmilo_mask FROM @ls_mask.
    COMMIT WORK AND WAIT.

    DATA lt_spfli TYPE STANDARD TABLE OF spfli.
    APPEND VALUE #( carrid = 'LH' connid = '0400' cityfrom = 'FRANKFURT' ) TO lt_spfli.
    APPEND VALUE #( carrid = 'AA' connid = '0017' cityfrom = 'NYC' ) TO lt_spfli.
    DATA(lr_data) = REF #( lt_spfli ).

    zcl_milo_masker=>apply_mask(
      iv_mask_profile_id = c_mask_prof
      iv_obj_name        = 'SPFLI'
      ir_data            = lr_data ).

    READ TABLE lt_spfli ASSIGNING FIELD-SYMBOL(<ls_row1>) INDEX 1.
    cl_abap_unit_assert=>assert_equals( act = <ls_row1>-cityfrom exp = 'FRA***' ).

    READ TABLE lt_spfli ASSIGNING FIELD-SYMBOL(<ls_row2>) INDEX 2.
    cl_abap_unit_assert=>assert_equals( act = <ls_row2>-cityfrom exp = '***' ).
  ENDMETHOD.

  METHOD test_masker_selected_columns.
    DATA lt_spfli TYPE STANDARD TABLE OF spfli.
    APPEND VALUE #( carrid = 'LH' connid = '0400' cityfrom = 'FRANKFURT' ) TO lt_spfli.
    DATA(lr_data) = REF #( lt_spfli ).

    zcl_milo_masker=>apply_mask(
      iv_mask_profile_id = c_mask_prof
      iv_obj_name        = 'SPFLI'
      ir_data            = lr_data
      iv_columns         = 'CARRID' ).

    cl_abap_unit_assert=>assert_equals( act = lt_spfli[ 1 ]-cityfrom exp = 'FRANKFURT' ).
  ENDMETHOD.

ENDCLASS.
