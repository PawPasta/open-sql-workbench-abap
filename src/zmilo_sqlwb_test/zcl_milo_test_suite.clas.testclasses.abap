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
      " 1. TEST CASES CHO ZCL_MILO_CONFIG
      "-----------------------------------------------------------------
      test_config_get_role_config    FOR TESTING,
      test_config_is_object_allowed   FOR TESTING,
      test_config_get_mask_rules      FOR TESTING,
      test_config_get_max_rows        FOR TESTING,
      test_config_is_field_exists     FOR TESTING,

      "-----------------------------------------------------------------
      " 2. TEST CASES CHO ZCL_MILO_SQL_PARSER
      "-----------------------------------------------------------------
      test_parser_single_table       FOR TESTING,
      test_parser_join_table         FOR TESTING,
      test_parser_group_by_having    FOR TESTING,
      test_parser_order_by_norm      FOR TESTING,
      test_parser_cnt_dist_norm FOR TESTING,
      test_parser_invalid_sql        FOR TESTING,

      "-----------------------------------------------------------------
      " 3. TEST CASES CHO ZCL_MILO_VALIDATOR (BẢO MẬT & AN TOÀN SQL)
      "-----------------------------------------------------------------
      test_val_empty_sql             FOR TESTING,
      test_val_non_select            FOR TESTING,
      test_val_forbidden_syntax      FOR TESTING,
      test_val_forbidden_keyword     FOR TESTING,
      test_val_unwhitelisted_table   FOR TESTING,
      test_val_invalid_field         FOR TESTING,
      test_val_where_between_like_in FOR TESTING,
      test_val_where_subquery_block  FOR TESTING,
      test_val_group_having_valid    FOR TESTING,
      test_val_group_having_invalid  FOR TESTING,
      test_val_order_by_valid        FOR TESTING,
      test_val_order_by_invalid      FOR TESTING,

      "-----------------------------------------------------------------
      " 4. TEST CASES CHO ZCL_MILO_MASKER
      "-----------------------------------------------------------------
      test_masker_full_mask          FOR TESTING,
      test_masker_replace_mask       FOR TESTING,
      test_masker_partial_mask       FOR TESTING,

      "-----------------------------------------------------------------
      " 5. TEST CASES CHO ZCL_MILO_SERIALIZER
      "-----------------------------------------------------------------
      test_serializer_escape_json    FOR TESTING,
      test_serializer_fields_json    FOR TESTING,

      "-----------------------------------------------------------------
      " 6. TEST CASES CHO ZCL_MILO_DDIC_BROWSER
      "-----------------------------------------------------------------
      test_browser_search_tables     FOR TESTING,
      test_browser_get_fields        FOR TESTING,
      test_browser_preview_table     FOR TESTING,

      "-----------------------------------------------------------------
      " 7. TEST CASES CHO ZCL_MILO_EXECUTOR
      "-----------------------------------------------------------------
      test_exec_single_select        FOR TESTING,
      test_exec_join_select          FOR TESTING,
      test_exec_group_select         FOR TESTING,
      test_exec_blocked_sql          FOR TESTING,

      "-----------------------------------------------------------------
      " 8. TEST CASES CHO ZCL_MILO_SERVICE & SAVED QUERIES
      "-----------------------------------------------------------------
      test_service_saved_query_crud  FOR TESTING,
      test_service_preview_table_res FOR TESTING,

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
  " 1. ZCL_MILO_CONFIG TESTS
  "---------------------------------------------------------------------
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


  "---------------------------------------------------------------------
  " 2. ZCL_MILO_SQL_PARSER TESTS
  "---------------------------------------------------------------------
  METHOD test_parser_single_table.
    TRY.
        DATA(ls_parts) = zcl_milo_sql_parser=>parse( 'SELECT CARRID, CONNID FROM SPFLI WHERE CARRID = ''LH''' ).
        cl_abap_unit_assert=>assert_equals( act = ls_parts-table_name exp = 'SPFLI' ).
        cl_abap_unit_assert=>assert_false( ls_parts-is_join ).
        cl_abap_unit_assert=>assert_equals( act = lines( ls_parts-fields ) exp = 2 ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Parsing single table SELECT failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_parser_join_table.
    TRY.
        DATA(ls_parts) = zcl_milo_sql_parser=>parse(
          'SELECT A~CARRID, B~PRICE FROM SPFLI AS A INNER JOIN SFLIGHT AS B ON A~CARRID = B~CARRID' ).
        cl_abap_unit_assert=>assert_true( ls_parts-is_join ).
        cl_abap_unit_assert=>assert_equals( act = lines( ls_parts-sources ) exp = 2 ).
        cl_abap_unit_assert=>assert_equals( act = lines( ls_parts-joins ) exp = 1 ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Parsing JOIN SELECT failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_parser_group_by_having.
    TRY.
        DATA(ls_parts) = zcl_milo_sql_parser=>parse(
          'SELECT CARRID, COUNT( * ) AS TOTAL FROM SPFLI GROUP BY CARRID HAVING COUNT( * ) > 5' ).
        cl_abap_unit_assert=>assert_equals( act = ls_parts-group_sql exp = 'CARRID' ).
        cl_abap_unit_assert=>assert_equals( act = ls_parts-having_sql exp = 'COUNT( * ) > 5' ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Parsing GROUP BY SELECT failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_parser_order_by_norm.
    DATA(lv_order) = zcl_milo_sql_parser=>normalize_order_sql( 'CARRID ASC, CONNID DESC' ).
    cl_abap_unit_assert=>assert_equals( act = lv_order exp = 'CARRID ASCENDING, CONNID DESCENDING' ).
  ENDMETHOD.

  METHOD test_parser_cnt_dist_norm.
    DATA(lv_norm) = zcl_milo_sql_parser=>normalize_count_distinct_sql( 'COUNT(DISTINCT CARRID)' ).
    cl_abap_unit_assert=>assert_equals( act = lv_norm exp = 'COUNT( DISTINCT CARRID )' ).
  ENDMETHOD.

  METHOD test_parser_invalid_sql.
    TRY.
        zcl_milo_sql_parser=>parse( 'INVALID SQL STATEMENT' ).
        cl_abap_unit_assert=>fail( 'Should have raised zcx_milo_validation' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_bound( lx_val ).
    ENDTRY.
  ENDMETHOD.


  "---------------------------------------------------------------------
  " 3. ZCL_MILO_VALIDATOR TESTS (SECURITY & SYNTAX VALIDATION)
  "---------------------------------------------------------------------
  METHOD test_val_empty_sql.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = ''
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Empty SQL check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>empty_sql ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_non_select.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'DELETE FROM SPFLI WHERE CARRID = ''LH'''
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Non-SELECT check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_true( xsdbool(
          lx_val->if_t100_message~t100key = zcx_milo_validation=>only_select_allowed OR
          lx_val->if_t100_message~t100key = zcx_milo_validation=>forbidden_keyword ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_forbidden_syntax.
    " Test Semicolon (Multi-statement)
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT * FROM SPFLI; DROP TABLE SPFLI;'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Semicolon check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val1).
        cl_abap_unit_assert=>assert_equals( act = lx_val1->if_t100_message~t100key exp = zcx_milo_validation=>forbidden_syntax ).
    ENDTRY.

    " Test Comment --
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT * FROM SPFLI -- comment'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Comment check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val2).
        cl_abap_unit_assert=>assert_equals( act = lx_val2->if_t100_message~t100key exp = zcx_milo_validation=>forbidden_syntax ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_forbidden_keyword.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT DISTINCT CARRID FROM SPFLI'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Standalone DISTINCT check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>forbidden_keyword ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_unwhitelisted_table.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT * FROM USR02'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Unwhitelisted table check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>object_not_allowed ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_invalid_field.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT NON_EXISTENT_COLUMN FROM SPFLI'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Invalid field check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>invalid_field ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_where_between_like_in.
    TRY.
        DATA lv_obj TYPE zmilo_obj_name.
        zcl_milo_validator=>validate_select_sql(
          EXPORTING
            iv_sql              = 'SELECT CARRID, CONNID FROM SPFLI WHERE CONNID BETWEEN 0001 AND 9999 AND CITYFROM LIKE ''FRANK%'' AND CARRID IN ( ''LH'', ''AA'' )'
            iv_wlist_profile_id = c_wlist_prof
          IMPORTING
            ev_object_name      = lv_obj ).
        cl_abap_unit_assert=>assert_equals( act = lv_obj exp = 'SPFLI' ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Complex WHERE validation failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_where_subquery_block.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT CARRID FROM SPFLI WHERE CARRID IN ( SELECT CARRID FROM SFLIGHT )'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Subquery in WHERE check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>invalid_where ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_group_having_valid.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT CARRID, COUNT( * ) AS TOTAL FROM SPFLI GROUP BY CARRID HAVING COUNT( * ) > 2'
          iv_wlist_profile_id = c_wlist_prof ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Valid GROUP BY HAVING failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_group_having_invalid.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT CARRID, CITYFROM FROM SPFLI GROUP BY CARRID'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Unaggregated field check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>invalid_field ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_order_by_valid.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT CARRID, CONNID FROM SPFLI ORDER BY CARRID ASC, CONNID DESC'
          iv_wlist_profile_id = c_wlist_prof ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Valid ORDER BY failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_val_order_by_invalid.
    TRY.
        zcl_milo_validator=>validate_select_sql(
          iv_sql              = 'SELECT CARRID FROM SPFLI ORDER BY INVALID_COL'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Invalid ORDER BY check failed' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_equals( act = lx_val->if_t100_message~t100key exp = zcx_milo_validation=>invalid_field ).
    ENDTRY.
  ENDMETHOD.


  "---------------------------------------------------------------------
  " 4. ZCL_MILO_MASKER TESTS
  "---------------------------------------------------------------------
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


  "---------------------------------------------------------------------
  " 5. ZCL_MILO_SERIALIZER TESTS
  "---------------------------------------------------------------------
  METHOD test_serializer_escape_json.
    DATA lt_field TYPE zcl_milo_ddic_browser=>tt_field_info.
    APPEND VALUE #( position = 1 fieldname = 'CARRID' rollname = 'S_CARR_ID' datatype = 'CHAR' leng = 3 ddtext = 'Airline "Code"' ) TO lt_field.

    DATA(lv_json) = zcl_milo_serializer=>fields_to_json( lt_field ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_json CS '\"Code\"' ) ).
  ENDMETHOD.

  METHOD test_serializer_fields_json.
    " Test field metadata serialization
  ENDMETHOD.


  "---------------------------------------------------------------------
  " 6. ZCL_MILO_DDIC_BROWSER TESTS
  "---------------------------------------------------------------------
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


  "---------------------------------------------------------------------
  " 7. ZCL_MILO_EXECUTOR TESTS
  "---------------------------------------------------------------------
  METHOD test_exec_single_select.
    DATA lv_obj TYPE zmilo_obj_name.
    DATA lv_rows TYPE i.
    DATA lv_returned TYPE i.
    DATA lv_status TYPE string.
    DATA lv_max TYPE i.
    DATA lv_trunc TYPE abap_bool.
    DATA lv_json TYPE string.

    TRY.
        zcl_milo_executor=>execute_select(
          EXPORTING
            iv_sql              = 'SELECT CARRID, CONNID, CITYFROM FROM SPFLI'
            iv_wlist_profile_id = c_wlist_prof
            iv_mask_profile_id  = c_mask_prof
          IMPORTING
            ev_object_name      = lv_obj
            ev_row_count        = lv_rows
            ev_returned_rows    = lv_returned
            ev_status           = lv_status
            ev_max_rows         = lv_max
            ev_truncated        = lv_trunc
            ev_rows_json        = lv_json ).

        cl_abap_unit_assert=>assert_equals( act = lv_status exp = 'SUCCESS' ).
        cl_abap_unit_assert=>assert_equals( act = lv_obj exp = 'SPFLI' ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'Single SELECT execution failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_exec_join_select.
    DATA lv_status TYPE string.
    DATA lv_json TYPE string.

    TRY.
        zcl_milo_executor=>execute_select(
          EXPORTING
            iv_sql              = 'SELECT A~CARRID, B~PRICE FROM SPFLI AS A INNER JOIN SFLIGHT AS B ON A~CARRID = B~CARRID'
            iv_wlist_profile_id = c_wlist_prof
          IMPORTING
            ev_status           = lv_status
            ev_rows_json        = lv_json ).

        cl_abap_unit_assert=>assert_equals( act = lv_status exp = 'SUCCESS' ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'JOIN SELECT execution failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_exec_group_select.
    DATA lv_status TYPE string.

    TRY.
        zcl_milo_executor=>execute_select(
          EXPORTING
            iv_sql              = 'SELECT CARRID, COUNT( * ) AS TOTAL FROM SPFLI GROUP BY CARRID'
            iv_wlist_profile_id = c_wlist_prof
          IMPORTING
            ev_status           = lv_status ).

        cl_abap_unit_assert=>assert_equals( act = lv_status exp = 'SUCCESS' ).
      CATCH zcx_milo_validation.
        cl_abap_unit_assert=>fail( 'GROUP BY SELECT execution failed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_exec_blocked_sql.
    TRY.
        zcl_milo_executor=>execute_select(
          iv_sql              = 'DELETE FROM SPFLI'
          iv_wlist_profile_id = c_wlist_prof ).
        cl_abap_unit_assert=>fail( 'Blocked SQL did not raise exception' ).
      CATCH zcx_milo_validation INTO DATA(lx_val).
        cl_abap_unit_assert=>assert_bound( lx_val ).
    ENDTRY.
  ENDMETHOD.


  "---------------------------------------------------------------------
  " 8. ZCL_MILO_SERVICE & SAVED QUERIES TESTS
  "---------------------------------------------------------------------
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
