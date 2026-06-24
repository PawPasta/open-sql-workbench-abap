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
  data MV_OBJECT_NAME type ZMILO_OBJ_NAME .
  data MV_FIELD_NAME type ZMILO_FIELD_NAME .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MV_OBJECT_NAME type ZMILO_OBJ_NAME optional
      !MV_FIELD_NAME type ZMILO_FIELD_NAME optional .
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
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
