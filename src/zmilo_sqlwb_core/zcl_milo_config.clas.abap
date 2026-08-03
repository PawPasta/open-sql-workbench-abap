CLASS ZCL_milo_CONFIG DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS c_max_select_fields TYPE i VALUE 50.
    CONSTANTS c_max_join_sources TYPE i VALUE 5.

    TYPES tt_mask TYPE STANDARD TABLE OF zmilo_mask WITH EMPTY KEY.

    CLASS-METHODS get_role_config

      IMPORTING
        iv_profile_id  TYPE zmilo_profile_id
      RETURNING
        VALUE(rs_role) TYPE zmilo_role.

    CLASS-METHODS get_role_config_any
      IMPORTING
        iv_profile_id  TYPE zmilo_profile_id
      RETURNING
        VALUE(rs_role) TYPE zmilo_role.

    CLASS-METHODS is_object_exists
      IMPORTING
        iv_obj_name      TYPE zmilo_obj_name
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.

    CLASS-METHODS is_object_allowed
      IMPORTING
        iv_wlist_profile_id TYPE zmilo_wlist_profile_id
        iv_obj_name         TYPE zmilo_obj_name
      RETURNING
        VALUE(rv_allowed)   TYPE abap_bool.

    CLASS-METHODS get_mask_rules
      IMPORTING
        iv_mask_profile_id TYPE zmilo_mask_profile_id
        iv_obj_name        TYPE zmilo_obj_name
      RETURNING
        VALUE(rt_mask)     TYPE tt_mask
      RAISING
        zcx_milo_validation.

    CLASS-METHODS get_object_max_rows
      IMPORTING
        iv_wlist_profile_id TYPE zmilo_wlist_profile_id
        iv_obj_name         TYPE zmilo_obj_name
      RETURNING
        VALUE(rv_max_rows)  TYPE i
      RAISING
        zcx_milo_validation.

    CLASS-METHODS get_object_type
      IMPORTING
        iv_obj_name           TYPE zmilo_obj_name
      RETURNING
        VALUE(rv_object_type) TYPE dd02l-tabclass.

    CLASS-METHODS is_field_exists
      IMPORTING
        iv_obj_name      TYPE zmilo_obj_name
        iv_field_name    TYPE zmilo_field_name
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.

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

    LOOP AT rt_mask INTO DATA(ls_mask).
      IF ( ls_mask-mask_type <> 'FULL'
           AND ls_mask-mask_type <> 'REPLACE'
           AND ls_mask-mask_type <> 'PARTIAL' )
         OR is_field_exists(
              iv_obj_name   = lv_obj_name
              iv_field_name = ls_mask-field_name ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_milo_validation
          EXPORTING
            textid         = zcx_milo_validation=>mask_rule_invalid
            mv_field_name  = ls_mask-field_name
            mv_object_name = lv_obj_name.
      ENDIF.
    ENDLOOP.

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

    IF sy-subrc <> 0.
      rv_max_rows = 100.
    ELSEIF rv_max_rows <= 0.
      RAISE EXCEPTION TYPE zcx_milo_validation
        EXPORTING
          textid         = zcx_milo_validation=>max_rows_config_invalid
          mv_object_name = lv_obj_name.
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


  METHOD get_role_config_any.

    SELECT SINGLE *
      FROM zmilo_role
      WHERE profile_id = @iv_profile_id
      INTO @rs_role.

  ENDMETHOD.


  METHOD is_object_exists.

    DATA lv_obj_name TYPE dd02l-tabname.

    lv_obj_name = to_upper( condense( iv_obj_name ) ).

    SELECT SINGLE tabname
      FROM dd02l
      WHERE tabname  = @lv_obj_name
        AND as4local = 'A'
      INTO @DATA(lv_found).

    rv_exists = xsdbool( sy-subrc = 0 ).

  ENDMETHOD.


  METHOD get_object_type.

    DATA lv_obj_name TYPE dd02l-tabname.

    lv_obj_name = to_upper( condense( iv_obj_name ) ).

    SELECT SINGLE tabclass
      FROM dd02l
      WHERE tabname  = @lv_obj_name
        AND as4local = 'A'
      INTO @rv_object_type.

  ENDMETHOD.
ENDCLASS.
