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
    DATA lt_field TYPE zcl_milo_ddic_browser=>tt_field_info.

    APPEND VALUE #( position = 1
                    keyflag = 'X'
                    fieldname = 'CARRID'
                    rollname = 'S_CARR_ID'
                    datatype = 'CHAR'
                    leng = 3
                    decimals = 0
                    ddtext = 'Airline Code'
                    origin_type = 'TABLE'
                    origin_structure = 'SPFLI'
                    include_depth = 0 ) TO lt_field.

    APPEND VALUE #( position = 2
                    keyflag = ''
                    fieldname = 'CONNID'
                    rollname = 'S_CONN_ID'
                    datatype = 'NUMC'
                    leng = 4
                    decimals = 0
                    ddtext = 'Flight Number'
                    origin_type = 'TABLE'
                    origin_structure = 'SPFLI'
                    include_depth = 0 ) TO lt_field.

    DATA(lv_json) = zcl_milo_serializer=>fields_to_json( lt_field ).

    DATA(lv_expected) = '[{"position":1,"fieldName":"CARRID","jsonKey":"carrid","element":"S_CARR_ID","abapType":"CHAR","length":3,"decimals":0,"isKey":true,"label":"Airline Code","originType":"TABLE","originStructure":"SPFLI","includeDepth":0},' &&
                        '{"position":2,"fieldName":"CONNID","jsonKey":"connid","element":"S_CONN_ID","abapType":"NUMC","length":4,"decimals":0,"isKey":false,"label":"Flight Number","originType":"TABLE","originStructure":"SPFLI","includeDepth":0}]'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_json
      exp = lv_expected
      msg = 'Generated JSON string accurately represents field objects array' ).
  ENDMETHOD.
ENDCLASS.
