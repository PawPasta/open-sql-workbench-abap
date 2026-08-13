class ZCX_MILO_VALIDATION definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_MESSAGE .
  interfaces IF_T100_DYN_MSG .

  constants:
    begin of EMPTY_SQL,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '000',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EMPTY_SQL .
  constants:
    begin of ONLY_SELECT_ALLOWED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '001',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ONLY_SELECT_ALLOWED .
  constants:
    begin of FORBIDDEN_SYNTAX,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '002',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FORBIDDEN_SYNTAX .
  constants:
    begin of FORBIDDEN_KEYWORD,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '003',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FORBIDDEN_KEYWORD .
  constants:
    begin of PARSE_FAILED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '004',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PARSE_FAILED .
  constants:
    begin of INVALID_FIELD,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '006',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INVALID_FIELD .
  constants:
    begin of INVALID_ORDER_BY,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '008',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INVALID_ORDER_BY .
  constants:
    begin of INVALID_WHERE,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '007',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INVALID_WHERE .
  constants:
    begin of OBJECT_NOT_ALLOWED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '005',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of OBJECT_NOT_ALLOWED .
  constants:
    begin of REQUIRED_PARAMETER_MISSING,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '010',
      attr1 type scx_attrname value 'MV_PARAMETER_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of REQUIRED_PARAMETER_MISSING .
  constants:
    begin of INVALID_PARAMETER_VALUE,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '011',
      attr1 type scx_attrname value 'MV_PARAMETER_NAME',
      attr2 type scx_attrname value 'MV_VALUE_1',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INVALID_PARAMETER_VALUE .
  constants:
    begin of PROFILE_REQUIRED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '012',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PROFILE_REQUIRED .
  constants:
    begin of PROFILE_NOT_FOUND,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '013',
      attr1 type scx_attrname value 'MV_PROFILE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PROFILE_NOT_FOUND .
  constants:
    begin of PROFILE_INACTIVE,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '014',
      attr1 type scx_attrname value 'MV_PROFILE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PROFILE_INACTIVE .
  constants:
    begin of PFCG_ROLE_NOT_CONFIGURED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '015',
      attr1 type scx_attrname value 'MV_PROFILE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PFCG_ROLE_NOT_CONFIGURED .
  constants:
    begin of USER_ROLE_MISSING,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '016',
      attr1 type scx_attrname value 'MV_PROFILE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of USER_ROLE_MISSING .
  constants:
    begin of USER_ROLE_EXPIRED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '017',
      attr1 type scx_attrname value 'MV_PROFILE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of USER_ROLE_EXPIRED .
  constants:
    begin of INVALID_PAGE_NUMBER,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '018',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INVALID_PAGE_NUMBER .
  constants:
    begin of INVALID_ROW_LIMIT,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '019',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INVALID_ROW_LIMIT .
  constants:
    begin of MULTIPLE_SQL_NOT_ALLOWED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '020',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of MULTIPLE_SQL_NOT_ALLOWED .
  constants:
    begin of SQL_COMMENT_NOT_ALLOWED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '021',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of SQL_COMMENT_NOT_ALLOWED .
  constants:
    begin of SELECT_LIST_MISSING,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '022',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of SELECT_LIST_MISSING .
  constants:
    begin of FROM_CLAUSE_MISSING,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '023',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FROM_CLAUSE_MISSING .
  constants:
    begin of SOURCE_OBJECT_MISSING,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '024',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of SOURCE_OBJECT_MISSING .
  constants:
    begin of UNBALANCED_PARENTHESES,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '025',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of UNBALANCED_PARENTHESES .
  constants:
    begin of UNTERMINATED_STRING_LITERAL,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '026',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of UNTERMINATED_STRING_LITERAL .
  constants:
    begin of UNSUPPORTED_SQL_CLAUSE,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '027',
      attr1 type scx_attrname value 'MV_CLAUSE_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of UNSUPPORTED_SQL_CLAUSE .
  constants:
    begin of DUPLICATE_CLAUSE,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '028',
      attr1 type scx_attrname value 'MV_CLAUSE_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of DUPLICATE_CLAUSE .
  constants:
    begin of INVALID_ALIAS,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '029',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INVALID_ALIAS .
  constants:
    begin of OBJECT_NOT_FOUND,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '030',
      attr1 type scx_attrname value 'MV_OBJECT_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of OBJECT_NOT_FOUND .
  constants:
    begin of OBJECT_NOT_WHITELISTED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '031',
      attr1 type scx_attrname value 'MV_OBJECT_NAME',
      attr2 type scx_attrname value 'MV_VALUE_1',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of OBJECT_NOT_WHITELISTED .
  constants:
    begin of FIELD_NOT_FOUND,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '032',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value 'MV_OBJECT_NAME',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FIELD_NOT_FOUND .
  constants:
    begin of FIELD_NOT_ALLOWED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '033',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value 'MV_OBJECT_NAME',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FIELD_NOT_ALLOWED .
  constants:
    begin of FIELD_AMBIGUOUS,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '034',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FIELD_AMBIGUOUS .
  constants:
    begin of FIELD_ALIAS_NOT_FOUND,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '035',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value 'MV_FIELD_NAME',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FIELD_ALIAS_NOT_FOUND .
  constants:
    begin of DUPLICATE_OUTPUT_FIELD,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '036',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of DUPLICATE_OUTPUT_FIELD .
  constants:
    begin of FIELD_LIMIT_EXCEEDED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '037',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value 'MV_VALUE_2',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FIELD_LIMIT_EXCEEDED .
  constants:
    begin of STAR_EXPANSION_LIMITED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '038',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of STAR_EXPANSION_LIMITED .
  constants:
    begin of UNSUPPORTED_FIELD_TYPE,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '039',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value 'MV_VALUE_1',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of UNSUPPORTED_FIELD_TYPE .
  constants:
    begin of JOIN_TYPE_NOT_SUPPORTED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '040',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of JOIN_TYPE_NOT_SUPPORTED .
  constants:
    begin of JOIN_SOURCE_LIMIT_EXCEEDED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '041',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value 'MV_VALUE_2',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of JOIN_SOURCE_LIMIT_EXCEEDED .
  constants:
    begin of JOIN_ALIAS_REQUIRED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '043',
      attr1 type scx_attrname value 'MV_OBJECT_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of JOIN_ALIAS_REQUIRED .
  constants:
    begin of DUPLICATE_SOURCE_ALIAS,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '043',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of DUPLICATE_SOURCE_ALIAS .
  constants:
    begin of JOIN_ON_MISSING,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '044',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of JOIN_ON_MISSING .
  constants:
    begin of JOIN_ON_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '045',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of JOIN_ON_INVALID .
  constants:
    begin of JOIN_FIELD_SOURCE_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '046',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value 'MV_VALUE_1',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of JOIN_FIELD_SOURCE_INVALID .
  constants:
    begin of JOIN_COMPARISON_TYPE_MISMATCH,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '047',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value 'MV_VALUE_1',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of JOIN_COMPARISON_TYPE_MISMATCH .
  constants:
    begin of JOIN_SOURCE_NOT_WHITELISTED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '048',
      attr1 type scx_attrname value 'MV_OBJECT_NAME',
      attr2 type scx_attrname value 'MV_VALUE_1',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of JOIN_SOURCE_NOT_WHITELISTED .
  constants:
    begin of JOIN_PARSE_FAILED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '049',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of JOIN_PARSE_FAILED .
  constants:
    begin of WHERE_EXPRESSION_MISSING,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '050',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of WHERE_EXPRESSION_MISSING .
  constants:
    begin of WHERE_OPERATOR_NOT_SUPPORTED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '051',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of WHERE_OPERATOR_NOT_SUPPORTED .
  constants:
    begin of WHERE_FIELD_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '052',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of WHERE_FIELD_INVALID .
  constants:
    begin of WHERE_VALUE_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '053',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value 'MV_VALUE_1',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of WHERE_VALUE_INVALID .
  constants:
    begin of BETWEEN_SYNTAX_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '054',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of BETWEEN_SYNTAX_INVALID .
  constants:
    begin of IN_LIST_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '055',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of IN_LIST_INVALID .
  constants:
    begin of LIKE_PATTERN_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '056',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of LIKE_PATTERN_INVALID .
  constants:
    begin of NULL_COMPARISON_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '057',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NULL_COMPARISON_INVALID .
  constants:
    begin of LOGICAL_OPERATOR_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '058',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of LOGICAL_OPERATOR_INVALID .
  constants:
    begin of WHERE_PARENTHESES_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '059',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of WHERE_PARENTHESES_INVALID .
  constants:
    begin of AGGREGATE_NOT_SUPPORTED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '060',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of AGGREGATE_NOT_SUPPORTED .
  constants:
    begin of AGGREGATE_ARGUMENT_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '061',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of AGGREGATE_ARGUMENT_INVALID .
  constants:
    begin of AGGREGATE_ALIAS_REQUIRED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '062',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of AGGREGATE_ALIAS_REQUIRED .
  constants:
    begin of GROUP_BY_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '063',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of GROUP_BY_INVALID .
  constants:
    begin of GROUP_FIELD_NOT_SELECTED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '064',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of GROUP_FIELD_NOT_SELECTED .
  constants:
    begin of SELECT_FIELD_NOT_GROUPED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '065',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of SELECT_FIELD_NOT_GROUPED .
  constants:
    begin of HAVING_WITHOUT_GROUP,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '066',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of HAVING_WITHOUT_GROUP .
  constants:
    begin of HAVING_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '067',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of HAVING_INVALID .
  constants:
    begin of HAVING_AGGREGATE_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '068',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of HAVING_AGGREGATE_INVALID .
  constants:
    begin of DISTINCT_AGGREGATE_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '069',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of DISTINCT_AGGREGATE_INVALID .
  constants:
    begin of ORDER_FIELD_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '070',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ORDER_FIELD_INVALID .
  constants:
    begin of ORDER_DIRECTION_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '071',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ORDER_DIRECTION_INVALID .
  constants:
    begin of ORDER_EXPRESSION_NOT_SUPPORTED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '072',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ORDER_EXPRESSION_NOT_SUPPORTED .
  constants:
    begin of ORDER_ALIAS_NOT_FOUND,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '073',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ORDER_ALIAS_NOT_FOUND .
  constants:
    begin of ORDER_FIELD_DUPLICATED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '074',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ORDER_FIELD_DUPLICATED .
  constants:
    begin of ORDER_REQUIRED_FOR_PAGING,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '075',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ORDER_REQUIRED_FOR_PAGING .
  constants:
    begin of PAGE_OUT_OF_RANGE,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '076',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value 'MV_VALUE_2',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PAGE_OUT_OF_RANGE .
  constants:
    begin of PAGE_SIZE_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '077',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PAGE_SIZE_INVALID .
  constants:
    begin of PAGING_OFFSET_OVERFLOW,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '078',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of PAGING_OFFSET_OVERFLOW .
  constants:
    begin of ORDER_NOT_DETERMINISTIC,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '079',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ORDER_NOT_DETERMINISTIC .
  constants:
    begin of QUERY_ID_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '080',
      attr1 type scx_attrname value 'MV_REFERENCE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of QUERY_ID_INVALID .
  constants:
    begin of SAVED_QUERY_NOT_FOUND,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '081',
      attr1 type scx_attrname value 'MV_REFERENCE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of SAVED_QUERY_NOT_FOUND .
  constants:
    begin of SAVED_QUERY_INACTIVE,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '082',
      attr1 type scx_attrname value 'MV_REFERENCE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of SAVED_QUERY_INACTIVE .
  constants:
    begin of SAVED_QUERY_ACCESS_DENIED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '083',
      attr1 type scx_attrname value 'MV_REFERENCE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of SAVED_QUERY_ACCESS_DENIED .
  constants:
    begin of SAVED_QUERY_NOT_OWNER,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '084',
      attr1 type scx_attrname value 'MV_REFERENCE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of SAVED_QUERY_NOT_OWNER .
  constants:
    begin of QUERY_NAME_REQUIRED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '085',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of QUERY_NAME_REQUIRED .
  constants:
    begin of QUERY_VISIBILITY_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '086',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of QUERY_VISIBILITY_INVALID .
  constants:
    begin of RESULT_ID_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '087',
      attr1 type scx_attrname value 'MV_REFERENCE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of RESULT_ID_INVALID .
  constants:
    begin of RESULT_NOT_FOUND_OR_EXPIRED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '088',
      attr1 type scx_attrname value 'MV_REFERENCE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of RESULT_NOT_FOUND_OR_EXPIRED .
  constants:
    begin of RESULT_ACCESS_DENIED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '089',
      attr1 type scx_attrname value 'MV_REFERENCE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of RESULT_ACCESS_DENIED .
  constants:
    begin of DDIC_METADATA_NOT_FOUND,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '090',
      attr1 type scx_attrname value 'MV_OBJECT_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of DDIC_METADATA_NOT_FOUND .
  constants:
    begin of DDIC_FIELD_METADATA_NOT_FOUND,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '091',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value 'MV_OBJECT_NAME',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of DDIC_FIELD_METADATA_NOT_FOUND .
  constants:
    begin of WHITELIST_PROFILE_NOT_FOUND,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '092',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of WHITELIST_PROFILE_NOT_FOUND .
  constants:
    begin of MASK_PROFILE_NOT_FOUND,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '093',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of MASK_PROFILE_NOT_FOUND .
  constants:
    begin of MASK_RULE_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '094',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value 'MV_OBJECT_NAME',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of MASK_RULE_INVALID .
  constants:
    begin of MAX_ROWS_CONFIG_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '095',
      attr1 type scx_attrname value 'MV_OBJECT_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of MAX_ROWS_CONFIG_INVALID .
  constants:
    begin of ROLE_CONFIG_AMBIGUOUS,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '096',
      attr1 type scx_attrname value 'MV_PROFILE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ROLE_CONFIG_AMBIGUOUS .
  constants:
    begin of RESULT_CONFIG_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '097',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of RESULT_CONFIG_INVALID .
  constants:
    begin of UNSUPPORTED_DDIC_OBJECT_TYPE,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '098',
      attr1 type scx_attrname value 'MV_OBJECT_NAME',
      attr2 type scx_attrname value 'MV_VALUE_1',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of UNSUPPORTED_DDIC_OBJECT_TYPE .
  constants:
    begin of CONFIGURATION_ERROR,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '099',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of CONFIGURATION_ERROR .
  constants:
    begin of QUERY_EXECUTION_FAILED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '100',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of QUERY_EXECUTION_FAILED .
  constants:
    begin of DYNAMIC_SQL_SYNTAX_ERROR,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '101',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of DYNAMIC_SQL_SYNTAX_ERROR .
  constants:
    begin of DATA_TYPE_MISMATCH,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '102',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of DATA_TYPE_MISMATCH .
  constants:
    begin of NUMERIC_OVERFLOW,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '103',
      attr1 type scx_attrname value 'MV_FIELD_NAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NUMERIC_OVERFLOW .
  constants:
    begin of RESULT_SERIALIZATION_FAILED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '104',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of RESULT_SERIALIZATION_FAILED .
  constants:
    begin of RESULT_STORAGE_FAILED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '105',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of RESULT_STORAGE_FAILED .
  constants:
    begin of UUID_GENERATION_FAILED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '106',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of UUID_GENERATION_FAILED .
  constants:
    begin of INTERNAL_ERROR,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '107',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INTERNAL_ERROR .
  constants:
    begin of QUERY_STORAGE_FAILED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '108',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of QUERY_STORAGE_FAILED .
  constants:
    begin of LOG_WRITE_FAILED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '109',
      attr1 type scx_attrname value 'MV_REFERENCE_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of LOG_WRITE_FAILED .
  constants:
    begin of TOP_VALUE_INVALID,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '110',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of TOP_VALUE_INVALID .
  constants:
    begin of TOP_LIMIT_EXCEEDED,
      msgid type symsgid value 'ZMIILO_MSG',
      msgno type symsgno value '111',
      attr1 type scx_attrname value 'MV_VALUE_1',
      attr2 type scx_attrname value 'MV_VALUE_2',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of TOP_LIMIT_EXCEEDED .
  data MV_OBJECT_NAME type ZMILO_OBJ_NAME .
  data MV_FIELD_NAME type ZMILO_FIELD_NAME .
  data MV_PROFILE_ID type ZMILO_PROFILE_ID .
  data MV_VALUE_1 type STRING .
  data MV_VALUE_2 type STRING .
  data MV_REFERENCE_ID type STRING .
  data MV_CLAUSE_NAME type STRING .
  data MV_PARAMETER_NAME type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MV_OBJECT_NAME type ZMILO_OBJ_NAME optional
      !MV_FIELD_NAME type ZMILO_FIELD_NAME optional
      !MV_PROFILE_ID type ZMILO_PROFILE_ID optional
      !MV_VALUE_1 type STRING optional
      !MV_VALUE_2 type STRING optional
      !MV_REFERENCE_ID type STRING optional
      !MV_CLAUSE_NAME type STRING optional
      !MV_PARAMETER_NAME type STRING optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_MILO_VALIDATION IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MV_OBJECT_NAME = MV_OBJECT_NAME .
me->MV_FIELD_NAME = MV_FIELD_NAME .
me->MV_PROFILE_ID = MV_PROFILE_ID .
me->MV_VALUE_1 = MV_VALUE_1 .
me->MV_VALUE_2 = MV_VALUE_2 .
me->MV_REFERENCE_ID = MV_REFERENCE_ID .
me->MV_CLAUSE_NAME = MV_CLAUSE_NAME .
me->MV_PARAMETER_NAME = MV_PARAMETER_NAME .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
