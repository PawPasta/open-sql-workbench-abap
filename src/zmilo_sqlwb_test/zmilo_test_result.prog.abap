*&---------------------------------------------------------------------*
*& Report ZMILO_TEST_RESULT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmilo_test_result.

PARAMETERS p_act  TYPE char8 DEFAULT 'RUN'.
PARAMETERS p_sql  TYPE string LOWER CASE DEFAULT 'SELECT CARRID, CONNID FROM SPFLI'.
PARAMETERS p_obj  TYPE zmilo_obj_name DEFAULT 'SPFLI'.
PARAMETERS p_max  TYPE i DEFAULT 20.
PARAMETERS p_page TYPE i DEFAULT 1.

START-OF-SELECTION.

  TYPES:
    BEGIN OF ty_user_profile,
      profile_id       TYPE zmilo_profile_id,
      pfcg_role        TYPE zmilo_pfcg_role,
      wlist_profile_id TYPE zmilo_wlist_profile_id,
    END OF ty_user_profile.

  DATA lv_action     TYPE string.
  DATA lv_obj_name   TYPE zmilo_obj_name.
  DATA lv_profile_id TYPE zmilo_profile_id.
  DATA lt_profile    TYPE STANDARD TABLE OF ty_user_profile.
  DATA ls_profile    TYPE ty_user_profile.
  DATA ls_result     TYPE zcl_milo_service=>ty_run_result.

  lv_action = to_upper( condense( p_act ) ).

  CASE lv_action.
    WHEN 'RUN'.
      TRY.
          DATA(ls_parts) = zcl_milo_sql_parser=>parse( p_sql ).
          lv_obj_name = ls_parts-table_name.
        CATCH zcx_milo_validation.
          CLEAR lv_obj_name.
      ENDTRY.
    WHEN 'PREVIEW'.
      lv_obj_name = to_upper( p_obj ).
  ENDCASE.

  SELECT r~profile_id,
         r~pfcg_role,
         r~wlist_profile_id
    FROM zmilo_role AS r
    INNER JOIN agr_users AS a
      ON a~agr_name = r~pfcg_role
    WHERE a~uname    = @sy-uname
      AND a~from_dat <= @sy-datum
      AND a~to_dat   >= @sy-datum
      AND r~is_active = @abap_true
    INTO TABLE @lt_profile.

  IF lt_profile IS INITIAL.
    WRITE: / 'NO milo PROFILE FOUND FOR USER:', sy-uname.
    WRITE: / 'CHECK Zmilo_ROLE-PFCG_ROLE AND PFCG ASSIGNMENT IN AGR_USERS.'.
    RETURN.
  ENDIF.

  SORT lt_profile BY profile_id.
  DELETE ADJACENT DUPLICATES FROM lt_profile COMPARING profile_id pfcg_role wlist_profile_id.

  IF lv_obj_name IS NOT INITIAL.
    LOOP AT lt_profile INTO ls_profile.
      IF zcl_milo_config=>is_object_allowed(
           iv_wlist_profile_id = ls_profile-wlist_profile_id
           iv_obj_name         = lv_obj_name ) = abap_true.
        EXIT.
      ENDIF.
      CLEAR ls_profile.
    ENDLOOP.
  ENDIF.

  IF ls_profile-profile_id IS INITIAL.
    READ TABLE lt_profile INTO ls_profile INDEX 1.
  ENDIF.

  lv_profile_id = ls_profile-profile_id.

  WRITE: / 'USER:', sy-uname.
  WRITE: / 'PROFILE:', lv_profile_id.
  WRITE: / 'PFCG ROLE:', ls_profile-pfcg_role.
  WRITE: / 'WLIST:', ls_profile-wlist_profile_id.

  IF lv_obj_name IS NOT INITIAL.
    WRITE: / 'TARGET OBJECT:', lv_obj_name.
  ENDIF.

  IF lines( lt_profile ) > 1.
    WRITE: / 'INFO: MULTIPLE milo PROFILES FOUND. USING PROFILE ALLOWED FOR TARGET OBJECT.'.
  ENDIF.

  CASE lv_action.

    WHEN 'RUN'.
      ls_result = zcl_milo_service=>run_query_result(
        iv_profile_id = lv_profile_id
        iv_sql        = p_sql
        iv_page       = p_page ).

    WHEN 'PREVIEW'.
      ls_result = zcl_milo_service=>preview_table_result(
        iv_profile_id = lv_profile_id
        iv_obj_name   = p_obj
        iv_row_limit  = p_max
        iv_page       = p_page ).

    WHEN OTHERS.
      WRITE: / 'UNKNOWN ACTION:', p_act.
      WRITE: / 'VALID ACTIONS: RUN, PREVIEW'.
      RETURN.

  ENDCASE.

  WRITE: / 'STATUS:', ls_result-status.
  WRITE: / 'OBJECT:', ls_result-object_name.
  WRITE: / 'ROW_COUNT:', ls_result-row_count.
  WRITE: / 'RETURNED ROWS:', ls_result-returned_rows.
  WRITE: / 'TOTAL ROWS:', ls_result-total_rows.
  WRITE: / 'MAX ROWS:', ls_result-max_rows.
  WRITE: / 'PAGE:', ls_result-page.
  WRITE: / 'PAGE SIZE:', ls_result-page_size.
  WRITE: / 'TOTAL PAGES:', ls_result-total_pages.
  WRITE: / 'TRUNCATED:', ls_result-truncated.
  WRITE: / 'ERROR CODE:', ls_result-error_code.

  IF ls_result-error_text IS NOT INITIAL.
    WRITE: / 'ERROR:', ls_result-error_text.
  ENDIF.

  IF ls_result-columns_json IS NOT INITIAL.
    WRITE: / 'COLUMNS JSON:'.
    WRITE: / ls_result-columns_json.
  ENDIF.

  IF ls_result-rows_json IS NOT INITIAL.
    WRITE: / 'ROWS JSON:'.
    WRITE: / ls_result-rows_json.
  ENDIF.

  IF ls_result-csv IS NOT INITIAL.
    WRITE: / 'CSV:'.
    WRITE: / ls_result-csv.
      ENDIF.
