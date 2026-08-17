CLASS lcl_ut_result_repo DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      test_result_id_roundtrip FOR TESTING,
      test_invalid_result_id FOR TESTING,
      test_build_page_chunks FOR TESTING,
      test_empty_page_has_no_chunks FOR TESTING.
ENDCLASS.

CLASS lcl_ut_result_repo IMPLEMENTATION.

  METHOD test_result_id_roundtrip.
    DATA(lv_result_id) = zcl_milo_result_repo=>create_result_id( ).
    DATA(lv_c32) = zcl_milo_result_repo=>result_id_to_c32( lv_result_id ).

    cl_abap_unit_assert=>assert_not_initial( lv_result_id ).
    cl_abap_unit_assert=>assert_equals( act = strlen( lv_c32 ) exp = 32 ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_milo_result_repo=>result_id_from_c32( to_lower( lv_c32 ) )
      exp = lv_result_id ).
  ENDMETHOD.

  METHOD test_invalid_result_id.
    cl_abap_unit_assert=>assert_initial(
      zcl_milo_result_repo=>result_id_from_c32( 'INVALID_UUID' ) ).
  ENDMETHOD.

  METHOD test_build_page_chunks.
    DATA(lv_payload) = repeat( val = `X` occ = zcl_milo_result_repo=>c_chunk_size + 1 ).
    DATA(lv_result_id) = zcl_milo_result_repo=>create_result_id( ).
    DATA(lt_page) = zcl_milo_result_repo=>build_page_chunks(
      iv_result_id = lv_result_id
      iv_page_no   = 2
      iv_rows_json = lv_payload ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_page ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_page[ 1 ]-chunk_no exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_page[ 1 ]-payload_len exp = zcl_milo_result_repo=>c_chunk_size ).
    cl_abap_unit_assert=>assert_true( lt_page[ 2 ]-is_last_chunk ).
  ENDMETHOD.

  METHOD test_empty_page_has_no_chunks.
    DATA(lt_page) = zcl_milo_result_repo=>build_page_chunks(
      iv_result_id = zcl_milo_result_repo=>create_result_id( )
      iv_page_no   = 1
      iv_rows_json = '' ).

    cl_abap_unit_assert=>assert_initial( lt_page ).
  ENDMETHOD.
ENDCLASS.
