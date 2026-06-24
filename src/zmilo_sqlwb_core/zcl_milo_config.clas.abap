class ZCL_MILO_CONFIG definition
  public
  final
  create public .

public section.

  types:
    tt_mask TYPE STANDARD TABLE OF zmilo_mask WITH EMPTY KEY .

  constants C_MAX_SELECT_FIELDS type I value 50 ##NO_TEXT.
  constants C_MAX_JOIN_SOURCES type I value 5 ##NO_TEXT.

  class-methods GET_ROLE_CONFIG
    importing
      !IV_PROFILE_ID type ZMILO_PROFILE_ID
    returning
      value(RS_ROLE) type ZMILO_ROLE .
  class-methods IS_OBJECT_ALLOWED
    importing
      !IV_WLIST_PROFILE_ID type ZMILO_WLIST_PROFILE_ID
      !IV_OBJ_NAME type ZMILO_OBJ_NAME
    returning
      value(RV_ALLOWED) type ABAP_BOOL .
  class-methods GET_MASK_RULES
    importing
      !IV_MASK_PROFILE_ID type ZMILO_MASK_PROFILE_ID
      !IV_OBJ_NAME type ZMILO_OBJ_NAME
    returning
      value(RT_MASK) type TT_MASK .
  class-methods GET_OBJECT_MAX_ROWS
    importing
      !IV_WLIST_PROFILE_ID type ZMILO_WLIST_PROFILE_ID
      !IV_OBJ_NAME type ZMILO_OBJ_NAME
    returning
      value(RV_MAX_ROWS) type I .
  class-methods IS_FIELD_EXISTS
    importing
      !IV_OBJ_NAME type ZMILO_OBJ_NAME
      !IV_FIELD_NAME type ZMILO_FIELD_NAME
    returning
      value(RV_EXISTS) type ABAP_BOOL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MILO_CONFIG IMPLEMENTATION.


  METHOD get_mask_rules.

    DATA lv_obj_name TYPE zmilo_obj_name.

    lv_obj_name = to_upper( iv_obj_name ).

    SELECT *
      FROM zmilo_mask
      WHERE mask_profile_id = @iv_mask_profile_id
        AND obj_name        = @lv_obj_name
        AND is_active       = 'X'
      INTO TABLE @rt_mask.

  ENDMETHOD.


  METHOD get_object_max_rows.

    DATA lv_obj_name TYPE zmilo_obj_name.

    lv_obj_name = to_upper( iv_obj_name ).

    SELECT SINGLE max_rows
      FROM zmilo_wlist
      WHERE wlist_profile_id = @iv_wlist_profile_id
        AND obj_name         = @lv_obj_name
        AND is_active        = 'X'
      INTO @rv_max_rows.

    IF sy-subrc <> 0 OR rv_max_rows IS INITIAL.
      rv_max_rows = 100.
    ENDIF.

  ENDMETHOD.


  METHOD get_role_config.

    SELECT SINGLE *
      FROM zmilo_role
      WHERE profile_id = @iv_profile_id
        AND is_active  = 'X'
      INTO @rs_role.
  ENDMETHOD.


  METHOD is_field_exists.

    DATA lv_obj_name   TYPE dd03l-tabname.
    DATA lv_field_name TYPE dd03l-fieldname.

    lv_obj_name   = to_upper( iv_obj_name ).
    lv_field_name = to_upper( iv_field_name ).

    SELECT SINGLE fieldname
      FROM dd03l
      WHERE tabname   = @lv_obj_name
        AND fieldname = @lv_field_name
        AND as4local  = 'A'
      INTO @DATA(lv_found).

    rv_exists = xsdbool( sy-subrc = 0 ).

  ENDMETHOD.


  METHOD is_object_allowed.

    DATA lv_obj_name TYPE zmilo_obj_name.

    lv_obj_name = to_upper( iv_obj_name ).

    SELECT SINGLE obj_name
      FROM zmilo_wlist
      WHERE wlist_profile_id = @iv_wlist_profile_id
        AND obj_name         = @lv_obj_name
        AND is_active        = 'X'
      INTO @DATA(lv_found).

    rv_allowed = xsdbool( sy-subrc = 0 ).

  ENDMETHOD.
ENDCLASS.
