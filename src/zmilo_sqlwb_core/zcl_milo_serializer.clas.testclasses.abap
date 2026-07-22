*"* use this source file for your ABAP unit test classes
CLASS lcl_ut_serializer DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      test_serializer_escape_json    FOR TESTING,
      test_serializer_fields_json    FOR TESTING.

ENDCLASS.

CLASS lcl_ut_serializer IMPLEMENTATION.

  METHOD test_serializer_escape_json.
    DATA lt_field TYPE zcl_milo_ddic_browser=>tt_field_info.
    APPEND VALUE #( position = 1 fieldname = 'CARRID' rollname = 'S_CARR_ID' datatype = 'CHAR' leng = 3 ddtext = 'Airline "Code"' ) TO lt_field.

    DATA(lv_json) = zcl_milo_serializer=>fields_to_json( lt_field ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS '\"Code\"' ) ).
  ENDMETHOD.

  METHOD test_serializer_fields_json.
    " Test field metadata serialization
  ENDMETHOD.

ENDCLASS.
