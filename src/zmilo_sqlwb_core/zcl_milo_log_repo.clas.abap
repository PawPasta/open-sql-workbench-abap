CLASS zcl_milo_log_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES tt_log TYPE STANDARD TABLE OF zmilo_log WITH EMPTY KEY.

    CLASS-METHODS list_logs
      IMPORTING
        iv_user_only  TYPE abap_bool DEFAULT abap_true
        iv_status     TYPE zmilo_status OPTIONAL
      RETURNING
        VALUE(rt_log) TYPE tt_log.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MILO_LOG_REPO IMPLEMENTATION.


  METHOD list_logs.

    IF iv_user_only = abap_true.

      IF iv_status IS INITIAL.
        SELECT *
          FROM zmilo_log
          WHERE user_name = @sy-uname
          ORDER BY created_date DESCENDING,
                   created_time DESCENDING
          INTO TABLE @rt_log.
      ELSE.
        SELECT *
          FROM zmilo_log
          WHERE user_name = @sy-uname
            AND status    = @iv_status
          ORDER BY created_date DESCENDING,
                   created_time DESCENDING
          INTO TABLE @rt_log.
      ENDIF.

    ELSE.

      IF iv_status IS INITIAL.
        SELECT *
          FROM zmilo_log
          ORDER BY created_date DESCENDING,
                   created_time DESCENDING
          INTO TABLE @rt_log.
      ELSE.
        SELECT *
          FROM zmilo_log
          WHERE status = @iv_status
          ORDER BY created_date DESCENDING,
                   created_time DESCENDING
          INTO TABLE @rt_log.
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
