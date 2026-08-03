CLASS zcl_milo_error_mapper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_validation_error_code
      IMPORTING
        ix_validation        TYPE REF TO zcx_milo_validation
      RETURNING
        VALUE(rv_error_code) TYPE zmilo_error_code.

    CLASS-METHODS get_technical_error_code
      IMPORTING
        ix_error             TYPE REF TO cx_root
      RETURNING
        VALUE(rv_error_code) TYPE zmilo_error_code.

    CLASS-METHODS get_safe_technical_text
      IMPORTING
        iv_error_code        TYPE zmilo_error_code
      RETURNING
        VALUE(rv_error_text) TYPE string.

    CLASS-METHODS is_technical_error_code
      IMPORTING
        iv_error_code       TYPE zmilo_error_code
      RETURNING
        VALUE(rv_technical) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MILO_ERROR_MAPPER IMPLEMENTATION.


  METHOD get_validation_error_code.

    DATA ls_t100key TYPE scx_t100key.

    rv_error_code = 'VALIDATION_ERROR'.

    IF ix_validation IS NOT BOUND.
      RETURN.
    ENDIF.

    ls_t100key = ix_validation->if_t100_message~t100key.

    IF ls_t100key = zcx_milo_validation=>empty_sql.
      rv_error_code = 'EMPTY_SQL'.
    ELSEIF ls_t100key = zcx_milo_validation=>only_select_allowed.
      rv_error_code = 'ONLY_SELECT_ALLOWED'.
    ELSEIF ls_t100key = zcx_milo_validation=>forbidden_syntax.
      rv_error_code = 'FORBIDDEN_SYNTAX'.
    ELSEIF ls_t100key = zcx_milo_validation=>forbidden_keyword.
      rv_error_code = 'FORBIDDEN_KEYWORD'.
    ELSEIF ls_t100key = zcx_milo_validation=>parse_failed.
      rv_error_code = 'PARSE_FAILED'.
    ELSEIF ls_t100key = zcx_milo_validation=>multiple_sql_not_allowed.
      rv_error_code = 'MULTIPLE_SQL_NOT_ALLOWED'.
    ELSEIF ls_t100key = zcx_milo_validation=>sql_comment_not_allowed.
      rv_error_code = 'SQL_COMMENT_NOT_ALLOWED'.
    ELSEIF ls_t100key = zcx_milo_validation=>select_list_missing.
      rv_error_code = 'SELECT_LIST_MISSING'.
    ELSEIF ls_t100key = zcx_milo_validation=>from_clause_missing.
      rv_error_code = 'FROM_CLAUSE_MISSING'.
    ELSEIF ls_t100key = zcx_milo_validation=>source_object_missing.
      rv_error_code = 'SOURCE_OBJECT_MISSING'.
    ELSEIF ls_t100key = zcx_milo_validation=>unbalanced_parentheses.
      rv_error_code = 'UNBALANCED_PARENTHESES'.
    ELSEIF ls_t100key = zcx_milo_validation=>unterminated_string_literal.
      rv_error_code = 'UNTERMINATED_STRING_LITERAL'.
    ELSEIF ls_t100key = zcx_milo_validation=>unsupported_sql_clause.
      rv_error_code = 'UNSUPPORTED_SQL_CLAUSE'.
    ELSEIF ls_t100key = zcx_milo_validation=>duplicate_clause.
      rv_error_code = 'DUPLICATE_CLAUSE'.
    ELSEIF ls_t100key = zcx_milo_validation=>invalid_alias.
      rv_error_code = 'INVALID_ALIAS'.
    ELSEIF ls_t100key = zcx_milo_validation=>object_not_allowed.
      rv_error_code = 'OBJECT_NOT_ALLOWED'.
    ELSEIF ls_t100key = zcx_milo_validation=>invalid_field.
      rv_error_code = 'INVALID_FIELD'.
    ELSEIF ls_t100key = zcx_milo_validation=>invalid_where.
      rv_error_code = 'INVALID_WHERE'.
    ELSEIF ls_t100key = zcx_milo_validation=>invalid_order_by.
      rv_error_code = 'INVALID_ORDER_BY'.
    ELSEIF ls_t100key = zcx_milo_validation=>profile_required.
      rv_error_code = 'PROFILE_REQUIRED'.
    ELSEIF ls_t100key = zcx_milo_validation=>profile_not_found.
      rv_error_code = 'PROFILE_NOT_FOUND'.
    ELSEIF ls_t100key = zcx_milo_validation=>profile_inactive.
      rv_error_code = 'PROFILE_INACTIVE'.
    ELSEIF ls_t100key = zcx_milo_validation=>pfcg_role_not_configured.
      rv_error_code = 'PFCG_ROLE_NOT_CONFIGURED'.
    ELSEIF ls_t100key = zcx_milo_validation=>user_role_missing.
      rv_error_code = 'USER_ROLE_MISSING'.
    ELSEIF ls_t100key = zcx_milo_validation=>invalid_page_number.
      rv_error_code = 'INVALID_PAGE_NUMBER'.
    ELSEIF ls_t100key = zcx_milo_validation=>object_not_found.
      rv_error_code = 'OBJECT_NOT_FOUND'.
    ELSEIF ls_t100key = zcx_milo_validation=>object_not_whitelisted.
      rv_error_code = 'OBJECT_NOT_WHITELISTED'.
    ELSEIF ls_t100key = zcx_milo_validation=>field_not_found.
      rv_error_code = 'FIELD_NOT_FOUND'.
    ELSEIF ls_t100key = zcx_milo_validation=>field_not_allowed.
      rv_error_code = 'FIELD_NOT_ALLOWED'.
    ELSEIF ls_t100key = zcx_milo_validation=>field_ambiguous.
      rv_error_code = 'FIELD_AMBIGUOUS'.
    ELSEIF ls_t100key = zcx_milo_validation=>field_alias_not_found.
      rv_error_code = 'FIELD_ALIAS_NOT_FOUND'.
    ELSEIF ls_t100key = zcx_milo_validation=>duplicate_output_field.
      rv_error_code = 'DUPLICATE_OUTPUT_FIELD'.
    ELSEIF ls_t100key = zcx_milo_validation=>field_limit_exceeded.
      rv_error_code = 'FIELD_LIMIT_EXCEEDED'.
    ELSEIF ls_t100key = zcx_milo_validation=>unsupported_field_type.
      rv_error_code = 'UNSUPPORTED_FIELD_TYPE'.
    ELSEIF ls_t100key = zcx_milo_validation=>join_type_not_supported.
      rv_error_code = 'JOIN_TYPE_NOT_SUPPORTED'.
    ELSEIF ls_t100key = zcx_milo_validation=>join_source_limit_exceeded.
      rv_error_code = 'JOIN_SOURCE_LIMIT_EXCEEDED'.
    ELSEIF ls_t100key = zcx_milo_validation=>join_alias_required.
      rv_error_code = 'JOIN_ALIAS_REQUIRED'.
    ELSEIF ls_t100key = zcx_milo_validation=>duplicate_source_alias.
      rv_error_code = 'DUPLICATE_SOURCE_ALIAS'.
    ELSEIF ls_t100key = zcx_milo_validation=>join_on_missing.
      rv_error_code = 'JOIN_ON_MISSING'.
    ELSEIF ls_t100key = zcx_milo_validation=>join_on_invalid.
      rv_error_code = 'JOIN_ON_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>join_field_source_invalid.
      rv_error_code = 'JOIN_FIELD_SOURCE_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>join_comparison_type_mismatch.
      rv_error_code = 'JOIN_COMPARISON_TYPE_MISMATCH'.
    ELSEIF ls_t100key = zcx_milo_validation=>join_source_not_whitelisted.
      rv_error_code = 'JOIN_SOURCE_NOT_WHITELISTED'.
    ELSEIF ls_t100key = zcx_milo_validation=>join_parse_failed.
      rv_error_code = 'JOIN_PARSE_FAILED'.
    ELSEIF ls_t100key = zcx_milo_validation=>where_expression_missing.
      rv_error_code = 'WHERE_EXPRESSION_MISSING'.
    ELSEIF ls_t100key = zcx_milo_validation=>where_operator_not_supported.
      rv_error_code = 'WHERE_OPERATOR_NOT_SUPPORTED'.
    ELSEIF ls_t100key = zcx_milo_validation=>where_field_invalid.
      rv_error_code = 'WHERE_FIELD_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>where_value_invalid.
      rv_error_code = 'WHERE_VALUE_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>between_syntax_invalid.
      rv_error_code = 'BETWEEN_SYNTAX_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>in_list_invalid.
      rv_error_code = 'IN_LIST_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>like_pattern_invalid.
      rv_error_code = 'LIKE_PATTERN_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>null_comparison_invalid.
      rv_error_code = 'NULL_COMPARISON_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>logical_operator_invalid.
      rv_error_code = 'LOGICAL_OPERATOR_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>where_parentheses_invalid.
      rv_error_code = 'WHERE_PARENTHESES_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>aggregate_not_supported.
      rv_error_code = 'AGGREGATE_NOT_SUPPORTED'.
    ELSEIF ls_t100key = zcx_milo_validation=>aggregate_argument_invalid.
      rv_error_code = 'AGGREGATE_ARGUMENT_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>aggregate_alias_required.
      rv_error_code = 'AGGREGATE_ALIAS_REQUIRED'.
    ELSEIF ls_t100key = zcx_milo_validation=>group_by_invalid.
      rv_error_code = 'GROUP_BY_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>group_field_not_selected.
      rv_error_code = 'GROUP_FIELD_NOT_SELECTED'.
    ELSEIF ls_t100key = zcx_milo_validation=>select_field_not_grouped.
      rv_error_code = 'SELECT_FIELD_NOT_GROUPED'.
    ELSEIF ls_t100key = zcx_milo_validation=>having_without_group.
      rv_error_code = 'HAVING_WITHOUT_GROUP'.
    ELSEIF ls_t100key = zcx_milo_validation=>having_invalid.
      rv_error_code = 'HAVING_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>having_aggregate_invalid.
      rv_error_code = 'HAVING_AGGREGATE_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>distinct_aggregate_invalid.
      rv_error_code = 'DISTINCT_AGGREGATE_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>order_field_invalid.
      rv_error_code = 'ORDER_FIELD_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>order_direction_invalid.
      rv_error_code = 'ORDER_DIRECTION_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>order_expression_not_supported.
      rv_error_code = 'ORDER_EXPRESSION_NOT_SUPPORTED'.
    ELSEIF ls_t100key = zcx_milo_validation=>order_alias_not_found.
      rv_error_code = 'ORDER_ALIAS_NOT_FOUND'.
    ELSEIF ls_t100key = zcx_milo_validation=>order_field_duplicated.
      rv_error_code = 'ORDER_FIELD_DUPLICATED'.
    ELSEIF ls_t100key = zcx_milo_validation=>order_required_for_paging.
      rv_error_code = 'ORDER_REQUIRED_FOR_PAGING'.
    ELSEIF ls_t100key = zcx_milo_validation=>page_out_of_range.
      rv_error_code = 'PAGE_OUT_OF_RANGE'.
    ELSEIF ls_t100key = zcx_milo_validation=>page_size_invalid.
      rv_error_code = 'PAGE_SIZE_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>paging_offset_overflow.
      rv_error_code = 'PAGING_OFFSET_OVERFLOW'.
    ELSEIF ls_t100key = zcx_milo_validation=>query_id_invalid.
      rv_error_code = 'QUERY_ID_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>saved_query_not_found.
      rv_error_code = 'SAVED_QUERY_NOT_FOUND'.
    ELSEIF ls_t100key = zcx_milo_validation=>saved_query_inactive.
      rv_error_code = 'SAVED_QUERY_INACTIVE'.
    ELSEIF ls_t100key = zcx_milo_validation=>saved_query_access_denied.
      rv_error_code = 'SAVED_QUERY_ACCESS_DENIED'.
    ELSEIF ls_t100key = zcx_milo_validation=>saved_query_not_owner.
      rv_error_code = 'SAVED_QUERY_NOT_OWNER'.
    ELSEIF ls_t100key = zcx_milo_validation=>query_name_required.
      rv_error_code = 'QUERY_NAME_REQUIRED'.
    ELSEIF ls_t100key = zcx_milo_validation=>query_visibility_invalid.
      rv_error_code = 'QUERY_VISIBILITY_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>result_id_invalid.
      rv_error_code = 'RESULT_ID_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>result_not_found_or_expired.
      rv_error_code = 'RESULT_NOT_FOUND_OR_EXPIRED'.
    ELSEIF ls_t100key = zcx_milo_validation=>result_access_denied.
      rv_error_code = 'RESULT_ACCESS_DENIED'.
    ELSEIF ls_t100key = zcx_milo_validation=>ddic_metadata_not_found.
      rv_error_code = 'DDIC_METADATA_NOT_FOUND'.
    ELSEIF ls_t100key = zcx_milo_validation=>ddic_field_metadata_not_found.
      rv_error_code = 'DDIC_FIELD_METADATA_NOT_FOUND'.
    ELSEIF ls_t100key = zcx_milo_validation=>whitelist_profile_not_found.
      rv_error_code = 'WHITELIST_PROFILE_NOT_FOUND'.
    ELSEIF ls_t100key = zcx_milo_validation=>mask_profile_not_found.
      rv_error_code = 'MASK_PROFILE_NOT_FOUND'.
    ELSEIF ls_t100key = zcx_milo_validation=>mask_rule_invalid.
      rv_error_code = 'MASK_RULE_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>max_rows_config_invalid.
      rv_error_code = 'MAX_ROWS_CONFIG_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>role_config_ambiguous.
      rv_error_code = 'ROLE_CONFIG_AMBIGUOUS'.
    ELSEIF ls_t100key = zcx_milo_validation=>result_config_invalid.
      rv_error_code = 'RESULT_CONFIG_INVALID'.
    ELSEIF ls_t100key = zcx_milo_validation=>unsupported_ddic_object_type.
      rv_error_code = 'UNSUPPORTED_DDIC_OBJECT_TYPE'.
    ELSEIF ls_t100key = zcx_milo_validation=>configuration_error.
      rv_error_code = 'CONFIGURATION_ERROR'.
    ELSEIF ls_t100key = zcx_milo_validation=>query_execution_failed.
      rv_error_code = 'QUERY_EXECUTION_FAILED'.
    ELSEIF ls_t100key = zcx_milo_validation=>dynamic_sql_syntax_error.
      rv_error_code = 'DYNAMIC_SQL_SYNTAX_ERROR'.
    ELSEIF ls_t100key = zcx_milo_validation=>data_type_mismatch.
      rv_error_code = 'DATA_TYPE_MISMATCH'.
    ELSEIF ls_t100key = zcx_milo_validation=>numeric_overflow.
      rv_error_code = 'NUMERIC_OVERFLOW'.
    ELSEIF ls_t100key = zcx_milo_validation=>result_serialization_failed.
      rv_error_code = 'RESULT_SERIALIZATION_FAILED'.
    ELSEIF ls_t100key = zcx_milo_validation=>result_storage_failed.
      rv_error_code = 'RESULT_STORAGE_FAILED'.
    ELSEIF ls_t100key = zcx_milo_validation=>query_storage_failed.
      rv_error_code = 'QUERY_STORAGE_FAILED'.
    ELSEIF ls_t100key = zcx_milo_validation=>log_write_failed.
      rv_error_code = 'LOG_WRITE_FAILED'.
    ELSEIF ls_t100key = zcx_milo_validation=>uuid_generation_failed.
      rv_error_code = 'UUID_GENERATION_FAILED'.
    ELSEIF ls_t100key = zcx_milo_validation=>internal_error.
      rv_error_code = 'INTERNAL_ERROR'.
    ENDIF.

  ENDMETHOD.


  METHOD get_safe_technical_text.

    CASE iv_error_code.
      WHEN 'DYNAMIC_SQL_SYNTAX_ERROR'.
        rv_error_text = 'Generated Open SQL could not be executed'.
      WHEN 'DATA_TYPE_MISMATCH'.
        rv_error_text = 'Query result contains an incompatible data type'.
      WHEN 'NUMERIC_OVERFLOW'.
        rv_error_text = 'Numeric overflow occurred while processing the query'.
      WHEN 'RESULT_SERIALIZATION_FAILED'.
        rv_error_text = 'Query result could not be serialized'.
      WHEN 'RESULT_STORAGE_FAILED'.
        rv_error_text = 'Query result could not be stored'.
      WHEN 'QUERY_STORAGE_FAILED'.
        rv_error_text = 'Saved query could not be stored or updated'.
      WHEN 'LOG_WRITE_FAILED'.
        rv_error_text = 'Execution log could not be written'.
      WHEN 'UUID_GENERATION_FAILED'.
        rv_error_text = 'A technical identifier could not be generated'.
      WHEN 'INTERNAL_ERROR'.
        rv_error_text = 'An unexpected internal error occurred'.
      WHEN 'WHITELIST_PROFILE_NOT_FOUND'.
        rv_error_text = 'Whitelist profile configuration was not found'.
      WHEN 'MASK_PROFILE_NOT_FOUND'.
        rv_error_text = 'Mask profile configuration was not found'.
      WHEN 'MASK_RULE_INVALID'.
        rv_error_text = 'A field masking rule is invalid'.
      WHEN 'MAX_ROWS_CONFIG_INVALID'.
        rv_error_text = 'Maximum row configuration is invalid'.
      WHEN 'ROLE_CONFIG_AMBIGUOUS'.
        rv_error_text = 'More than one active role configuration was found'.
      WHEN 'RESULT_CONFIG_INVALID'.
        rv_error_text = 'Result storage configuration is invalid'.
      WHEN 'CONFIGURATION_ERROR'.
        rv_error_text = 'SQL Workbench configuration is incomplete'.
      WHEN OTHERS.
        rv_error_text = 'Query execution failed; review the request log'.
    ENDCASE.

  ENDMETHOD.


  METHOD get_technical_error_code.

    rv_error_code = 'QUERY_EXECUTION_FAILED'.

    IF ix_error IS NOT BOUND.
      RETURN.
    ENDIF.

    IF ix_error IS INSTANCE OF cx_sy_dynamic_osql_syntax
       OR ix_error IS INSTANCE OF cx_sy_dynamic_osql_semantics.
      rv_error_code = 'DYNAMIC_SQL_SYNTAX_ERROR'.
    ELSEIF ix_error IS INSTANCE OF cx_sy_conversion_overflow
       OR ix_error IS INSTANCE OF cx_sy_arithmetic_overflow.
      rv_error_code = 'NUMERIC_OVERFLOW'.
    ELSEIF ix_error IS INSTANCE OF cx_sy_move_cast_error
       OR ix_error IS INSTANCE OF cx_sy_conversion_no_number.
      rv_error_code = 'DATA_TYPE_MISMATCH'.
    ENDIF.

  ENDMETHOD.


  METHOD is_technical_error_code.

    CASE iv_error_code.
      WHEN 'QUERY_EXECUTION_FAILED'
        OR 'DYNAMIC_SQL_SYNTAX_ERROR'
        OR 'DATA_TYPE_MISMATCH'
        OR 'NUMERIC_OVERFLOW'
        OR 'RESULT_SERIALIZATION_FAILED'
        OR 'RESULT_STORAGE_FAILED'
        OR 'QUERY_STORAGE_FAILED'
        OR 'LOG_WRITE_FAILED'
        OR 'UUID_GENERATION_FAILED'
        OR 'INTERNAL_ERROR'.
        rv_technical = abap_true.
      WHEN 'WHITELIST_PROFILE_NOT_FOUND'
        OR 'MASK_PROFILE_NOT_FOUND'
        OR 'MASK_RULE_INVALID'
        OR 'MAX_ROWS_CONFIG_INVALID'
        OR 'ROLE_CONFIG_AMBIGUOUS'
        OR 'RESULT_CONFIG_INVALID'
        OR 'CONFIGURATION_ERROR'.
        rv_technical = abap_true.
      WHEN OTHERS.
        rv_technical = abap_false.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
