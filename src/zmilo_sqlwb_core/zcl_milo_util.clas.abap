class ZCL_MILO_UTIL definition
  public
  final
  create public .

public section.

  class-methods GET_SQL_HASH
    importing
      !IV_SQL type STRING
    returning
      value(RV_HASH) type ZMILO_SQL_HASH .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MILO_UTIL IMPLEMENTATION.


  METHOD get_sql_hash.

    DATA lv_hash_raw TYPE xstring.

    TRY.
        cl_abap_message_digest=>calculate_hash_for_char(
          EXPORTING
            if_algorithm = 'SHA256'
            if_data      = iv_sql
          IMPORTING
            ef_hashxstring = lv_hash_raw ).

        rv_hash = lv_hash_raw.

      CATCH cx_root.
        CLEAR rv_hash.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
