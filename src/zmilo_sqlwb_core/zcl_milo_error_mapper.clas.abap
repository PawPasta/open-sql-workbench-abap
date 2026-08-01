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
    ELSEIF ls_t100key = zcx_milo_validation=>order_required_for_paging.
      rv_error_code = 'ORDER_REQUIRED_FOR_PAGING'.
    ELSEIF ls_t100key = zcx_milo_validation=>saved_query_not_found.
      rv_error_code = 'SAVED_QUERY_NOT_FOUND'.
    ELSEIF ls_t100key = zcx_milo_validation=>saved_query_not_owner.
      rv_error_code = 'SAVED_QUERY_NOT_OWNER'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
