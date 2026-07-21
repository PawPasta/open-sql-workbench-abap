CLASS zcl_milo_query_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS save_query
      IMPORTING
        iv_query_name      TYPE zmilo_query_name
        iv_query_text      TYPE string
        iv_visibility      TYPE zmilo_visibility OPTIONAL
        iv_profile_id      TYPE zmilo_profile_id
        iv_tags            TYPE zmilo_tags OPTIONAL
        iv_description     TYPE zmilo_description OPTIONAL
      RETURNING
        VALUE(rv_query_id) TYPE sysuuid_x16.

    CLASS-METHODS get_query
      IMPORTING
        iv_query_id     TYPE sysuuid_x16
        iv_profile_id   TYPE zmilo_profile_id
      RETURNING
        VALUE(rs_query) TYPE zmilo_query.

    CLASS-METHODS update_query
      IMPORTING
        iv_query_id       TYPE sysuuid_x16
        iv_profile_id     TYPE zmilo_profile_id
        iv_query_name     TYPE zmilo_query_name
        iv_query_text     TYPE string
        iv_visibility     TYPE zmilo_visibility
        iv_tags           TYPE zmilo_tags OPTIONAL
        iv_description    TYPE zmilo_description OPTIONAL
      RETURNING
        VALUE(rv_updated) TYPE abap_bool.

    CLASS-METHODS deactivate_query
      IMPORTING
        iv_query_id       TYPE sysuuid_x16
        iv_profile_id     TYPE zmilo_profile_id
      RETURNING
        VALUE(rv_deleted) TYPE abap_bool.

    TYPES tt_query TYPE STANDARD TABLE OF zmilo_query WITH EMPTY KEY.

    CLASS-METHODS list_queries
      IMPORTING
        iv_profile_id   TYPE zmilo_profile_id
        iv_owner_only   TYPE abap_bool DEFAULT abap_true
        iv_allow_all    TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_query) TYPE tt_query.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MILO_QUERY_REPO IMPLEMENTATION.


  METHOD get_query.

    SELECT SINGLE *
      FROM zmilo_query
      WHERE query_id = @iv_query_id
        AND is_active = 'X'
        AND ( owner = @sy-uname
              OR ( visibility = 'PROFILE'
                   AND profile_id = @iv_profile_id ) )
      INTO @rs_query.

  ENDMETHOD.


  METHOD list_queries.

    IF iv_allow_all = abap_true.

      SELECT *
        FROM zmilo_query
        WHERE is_active = 'X'
        ORDER BY created_date DESCENDING,
                 created_time DESCENDING
        INTO TABLE @rt_query.

    ELSEIF iv_owner_only = abap_true.

      SELECT *
        FROM zmilo_query
        WHERE is_active = 'X'
          AND owner     = @sy-uname
        ORDER BY created_date DESCENDING,
                 created_time DESCENDING
        INTO TABLE @rt_query.

    ELSE.

      SELECT *
        FROM zmilo_query
        WHERE is_active = 'X'
          AND ( owner = @sy-uname
                OR ( visibility = 'PROFILE'
                     AND profile_id = @iv_profile_id ) )
        ORDER BY created_date DESCENDING,
                 created_time DESCENDING
        INTO TABLE @rt_query.

    ENDIF.

  ENDMETHOD.


  METHOD save_query.

    DATA ls_query TYPE zmilo_query.
    DATA lv_visibility TYPE zmilo_visibility.

    CLEAR rv_query_id.

    TRY.
        rv_query_id = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        CLEAR rv_query_id.
    ENDTRY.

    ls_query-mandt            = sy-mandt.
    ls_query-query_id         = rv_query_id.
    ls_query-owner            = sy-uname.
    ls_query-query_name       = iv_query_name.
    ls_query-query_text       = iv_query_text.
    ls_query-param_schema_json = ''.

    lv_visibility = to_upper( condense( iv_visibility ) ).

    IF lv_visibility = 'PROFILE' OR lv_visibility = 'SHARED'.
      ls_query-visibility = 'PROFILE'.
    ELSE.
      ls_query-visibility = 'PRIVATE'.
    ENDIF.

    ls_query-profile_id = iv_profile_id.

    ls_query-is_active   = abap_true.
    ls_query-tags        = iv_tags.
    ls_query-description = iv_description.
    ls_query-created_date = sy-datum.
    ls_query-created_time = sy-uzeit.

    INSERT zmilo_query FROM @ls_query.

    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD deactivate_query.

    DATA lv_inactive TYPE abap_bool.

    CLEAR rv_deleted.

    UPDATE zmilo_query
      SET is_active = @lv_inactive
      WHERE query_id  = @iv_query_id
        AND owner     = @sy-uname
        AND profile_id = @iv_profile_id
        AND is_active = 'X'.

    IF sy-subrc = 0.
      rv_deleted = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD update_query.

    DATA lv_visibility TYPE zmilo_visibility.

    CLEAR rv_updated.

    lv_visibility = to_upper( condense( iv_visibility ) ).
    IF lv_visibility = 'PROFILE' OR lv_visibility = 'SHARED'.
      lv_visibility = 'PROFILE'.
    ELSE.
      lv_visibility = 'PRIVATE'.
    ENDIF.

    UPDATE zmilo_query
      SET query_name  = @iv_query_name,
          query_text  = @iv_query_text,
          visibility  = @lv_visibility,
          tags        = @iv_tags,
          description = @iv_description
      WHERE query_id  = @iv_query_id
        AND owner     = @sy-uname
        AND profile_id = @iv_profile_id
        AND is_active = 'X'.

    IF sy-subrc = 0.
      rv_updated = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
