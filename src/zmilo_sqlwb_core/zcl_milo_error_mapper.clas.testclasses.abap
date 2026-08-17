CLASS lcl_ut_error_mapper DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      test_maps_ex FOR TESTING,
      test_unbound_ex FOR TESTING,
      test_classfield_ex FOR TESTING,
      test_safe_text FOR TESTING.
ENDCLASS.

CLASS lcl_ut_error_mapper IMPLEMENTATION.

  METHOD test_maps_ex.
    DATA(lx_validation) = NEW zcx_milo_validation(
      textid = zcx_milo_validation=>top_limit_exceeded ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_milo_error_mapper=>get_validation_error_code( lx_validation )
      exp = 'TOP_LIMIT_EXCEEDED' ).
  ENDMETHOD.

  METHOD test_unbound_ex.
    DATA lx_validation TYPE REF TO zcx_milo_validation.
    DATA lx_error TYPE REF TO cx_root.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_milo_error_mapper=>get_validation_error_code( lx_validation )
      exp = 'VALIDATION_ERROR' ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_milo_error_mapper=>get_technical_error_code( lx_error )
      exp = 'QUERY_EXECUTION_FAILED' ).
  ENDMETHOD.

  METHOD test_classfield_ex.
    cl_abap_unit_assert=>assert_true(
      zcl_milo_error_mapper=>is_technical_error_code( 'RESULT_STORAGE_FAILED' ) ).
    cl_abap_unit_assert=>assert_false(
      zcl_milo_error_mapper=>is_technical_error_code( 'INVALID_FIELD' ) ).
  ENDMETHOD.

  METHOD test_safe_text.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_milo_error_mapper=>get_safe_technical_text( 'LOG_WRITE_FAILED' )
      exp = 'Execution log could not be written' ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_milo_error_mapper=>get_safe_technical_text( 'INVALID_FIELD' )
      exp = 'Query execution failed; review the request log' ).
  ENDMETHOD.
ENDCLASS.
