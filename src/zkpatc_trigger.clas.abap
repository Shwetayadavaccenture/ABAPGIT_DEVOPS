class ZKPATC_TRIGGER definition
  public
  final
  create public .

public section.

  types:
* types:
*    BEGIN OF ty_tr,
*        trkorr TYPE zca_t_azuredata-trkorr,
*      END OF ty_tr .
    BEGIN OF lty_summ_struc,
        obj_type  TYPE trobjtype,
        object    TYPE sobj_name,
        atc_prio1 TYPE zartd_de_priority1,
        atc_prio2 TYPE zartd_de_priority2,
        atc_prio3 TYPE zartd_de_priority3,
        atc_prio4 TYPE zartd_de_priority4,
      END OF lty_summ_struc .
  types:
    BEGIN OF lty_include_cls,
        clsname  TYPE seoclsname,
        cpdname  TYPE seocpdname,
        incname  TYPE program,
        obj_name TYPE c LENGTH 120,
      END OF lty_include_cls .
  types:
    BEGIN OF lty_include_fm,
        funcname TYPE rs38l_fnam,
        pname    TYPE pname,
      END OF lty_include_fm .
  types:
    BEGIN OF gty_includes,
        clsname  TYPE seoclsname,
        cpdname  TYPE seocpdname,
        incname  TYPE program,
        obj_name TYPE c LENGTH 120,
      END OF gty_includes .
  types:
    BEGIN OF ty_fail,
        object_name TYPE string,
      END OF ty_fail .
  types:
    BEGIN OF ty_pass,
        object_name TYPE string,
      END OF ty_pass .
  types:
    BEGIN OF gty_funm,
        funcname TYPE rs38l_fnam,
        pname    TYPE pname,
      END OF gty_funm .
  types:
    BEGIN OF lty_func,
        funcname TYPE rs38l_fnam,
        area     TYPE rs38l_area,
      END OF lty_func .
  types:
    BEGIN OF lty_json,
        id      TYPE string,
        state   TYPE string,
        comment TYPE string,
        trid    TYPE string,
      END OF lty_json .
  types:
    tt_cts_atc   TYPE STANDARD TABLE OF zkp_25 .
  types:
    gtt_result  TYPE STANDARD TABLE OF gty_includes .
  types:
    gtt_funm  TYPE STANDARD TABLE OF gty_funm .
  types:
    ty_t_string TYPE STANDARD TABLE OF string WITH DEFAULT KEY .

  constants:
    BEGIN OF mc_fieldname,
        pat      TYPE fieldname VALUE 'PAT' ##NO_TEXT,
        auth     TYPE fieldname VALUE 'AUTH' ##NO_TEXT,
        url      TYPE fieldname VALUE 'URL' ##NO_TEXT,
        workitem TYPE fieldname VALUE 'WORKITEM' ##NO_TEXT,
      END OF mc_fieldname .
  constants MC_AZUREDATA_TAB type TABNAME value 'ZCA_T_AZUREDATA' ##NO_TEXT.
  constants MC_PRD_DEST type RFCDEST value 'PSSCLNT900' ##NO_TEXT.

  methods GET_CLASS_METHOD
    importing
      !IV_CLASS type SEOCLSNAME
    exporting
      !EV_RESULT type GTT_RESULT
    raising
      ZCA_CX_EXCEPTION .
  methods GET_FM_FRM
    importing
      !IV_FGR type RS38L_AREA
    exporting
      !ET_FM type GTT_FUNM
    raising
      ZCA_CX_EXCEPTION .
  methods ATC_CHECK_METHOD
    importing
      !IV_STRKORR type STRKORR
    exporting
      !ET_CTS_ATC type TT_CTS_ATC
      !EV_COMMENT type ty_t_string
    raising
      ZCA_CX_EXCEPTION .
protected section.
private section.
ENDCLASS.



CLASS ZKPATC_TRIGGER IMPLEMENTATION.


METHOD atc_check_method.
* Declarations - all as per your class definition, unchanged
  DATA: ls_result_atc  TYPE trcheckres,
        ls_summary_atc TYPE lty_summ_struc,
        ls_messages   TYPE satc_s_ac__ui_message_header,
        ls_cts_atc    TYPE zkp_25,
        ls_inc_name   TYPE scir_rest,
        ls_include_cls TYPE lty_include_cls,
        ls_include_fm TYPE lty_include_fm,
        ls_e071      TYPE e071,
        ls_e070      TYPE e070,
        ls_fail      TYPE ty_fail,
        ls_pass      TYPE ty_pass,
        ls_data      TYPE zkp_25,
        lt_data      TYPE TABLE OF zkp_25.

  DATA: lt_messages    TYPE satc_t_ac__ui_message_headers,
        lt_summary_atc TYPE STANDARD TABLE OF lty_summ_struc,
        lt_cts_atc     TYPE STANDARD TABLE OF zkp_25,
        lt_e071       TYPE STANDARD TABLE OF e071,
        lt_e070       TYPE STANDARD TABLE OF e070,
        lt_inc_name   TYPE scit_rest,
        lt_fail      TYPE TABLE OF ty_fail,
        lt_pass      TYPE TABLE OF ty_pass,
        lt_include_cls TYPE TABLE OF lty_include_cls,
        lt_include_fm TYPE TABLE OF lty_include_fm.

  DATA: lv_check_id     TYPE char32,
        lv_execid       TYPE satc_d_project_execution_id,
        lv_mode         TYPE trpari-flag,
        lv_display_id   TYPE satc_d_id,
        lv_tr_consol    TYPE string,
        lv_classname    TYPE seoclsname,
        lv_fugrname     TYPE rs38l_area,
        lv_trkorr       TYPE trkorr,
        lv_http_code    TYPE integer,
        lv_http_reason  TYPE string,
        lv_http_response TYPE string,
        lv_priority    TYPE string,
        lv_flag        TYPE string,
        lv_strkorr     TYPE strkorr,
        lv_seperator   TYPE string.

  DATA: strkorr   TYPE char20,
        jira_id   TYPE char20,
        trkorr    TYPE char20,
        obj_type  TYPE char4,
        object    TYPE char40,
        atc_prio1 TYPE int4,
        atc_prio2 TYPE int4,
        atc_prio3 TYPE int4,
        atc_prio4 TYPE int4.

* Reference variables
  DATA: lo_result_atc TYPE REF TO if_transport_check_service,
        lo_model      TYPE REF TO cl_satc_ac__ui_vdct_model_std,
        lo_filter     TYPE REF TO cl_satc_ac__ui_vdct_filter_std,
        lo_excp       TYPE REF TO zca_cx_exception.

* Constants
  CONSTANTS: lc_e  TYPE char1 VALUE 'E',
             lc_w  TYPE char1 VALUE 'W',
             lc_n  TYPE char1 VALUE 'N',
             lc_o  TYPE char1 VALUE 'O',
             lc_r  TYPE char1 VALUE 'R',
             lc_x  TYPE char1 VALUE 'X',
             lc_l  TYPE char4 VALUE 'LIMU',
             lc_c  TYPE char4 VALUE 'CLAS',
             lc_m  TYPE char4 VALUE 'METH',
             lc_f  TYPE char4 VALUE 'FUNC',
             lc_t  TYPE char4 VALUE 'TABD',
             lc_ta TYPE char4 VALUE 'TABL',
             lc_fu TYPE char4 VALUE 'FUGR',
             lc_tt TYPE char4 VALUE 'TABT',
             lc_p1 TYPE char4 VALUE 'P1',
             lc_p2 TYPE char4 VALUE 'P2',
             lc_p3 TYPE char4 VALUE 'P3',
             lc_p4 TYPE char4 VALUE 'P4'.

* Internal table to hold comment lines
  DATA: lt_comment_lines TYPE STANDARD TABLE OF string WITH EMPTY KEY,
        lv_line TYPE string.

* Step 1: Select all subtasks of main transport (excluding main TR)
  SELECT * FROM e070 INTO TABLE lt_e070 WHERE strkorr = iv_strkorr AND trkorr <> iv_strkorr.
  IF sy-subrc <> 0 OR lt_e070 IS INITIAL.
    RAISE EXCEPTION TYPE zca_cx_exception EXPORTING gv_msgv1 = 'No subtasks found for main TR'.
  ENDIF.

  CLEAR ev_comment.
  CLEAR lt_cts_atc.
  CLEAR lt_comment_lines.

* Step 2: Loop through each subtask and run ATC check
  LOOP AT lt_e070 INTO ls_e070.
    lv_trkorr = ls_e070-trkorr.

* Step 3: Get all objects of current subtask
    SELECT * FROM e071 INTO TABLE lt_e071 WHERE trkorr = lv_trkorr.
    IF sy-subrc <> 0 OR lt_e071 IS INITIAL.
      CONTINUE.
    ENDIF.

* Step 4: Run ATC check programmatically for the subtask
    TRY.
      CREATE OBJECT lo_result_atc TYPE cl_satc_ac_transport_check.
      CALL METHOD lo_result_atc->check
        EXPORTING p_it_e071 = lt_e071
        IMPORTING p_result = ls_result_atc.
      CALL METHOD lo_result_atc->get_check_id
        RECEIVING rv_check_id = lv_display_id.
      lv_execid = lv_display_id.
    CATCH cx_root INTO DATA(lx).
      CONTINUE.
    ENDTRY.

    CLEAR lt_pass.
    CLEAR lt_fail.
    CLEAR lt_inc_name.

* Step 5: Fetch ATC results using the execution ID
    CALL FUNCTION 'SATC_CI_GET_RESULT'
      EXPORTING i_result_id = lv_display_id
      IMPORTING e_results  = lt_inc_name
      EXCEPTIONS not_authorized = 1 invalid_result_id = 2 OTHERS = 3.

    IF sy-subrc <> 0.
      CLEAR lt_inc_name.
    ENDIF.

* Step 6: Analyze ATC results per object in subtask
    LOOP AT lt_e071 INTO ls_e071.
      DATA lv_prio1 TYPE i VALUE 0.
      DATA lv_prio2 TYPE i VALUE 0.
      DATA lv_prio3 TYPE i VALUE 0.
      DATA lv_prio4 TYPE i VALUE 0.

      LOOP AT lt_inc_name INTO ls_inc_name WHERE objname = ls_e071-obj_name.
        CASE ls_inc_name-kind.
          WHEN lc_e. lv_prio1 = 1.
          WHEN lc_w. lv_prio2 = 1.
          WHEN lc_n. lv_prio3 = 1.
          WHEN lc_o. lv_prio4 = 1.
        ENDCASE.
      ENDLOOP.

      IF lv_prio1 = 0 AND lv_prio2 = 0 AND lv_prio3 = 0 AND lv_prio4 = 0.
        ls_pass-object_name = ls_e071-obj_name.
        APPEND ls_pass TO lt_pass.
      ELSE.
        lv_priority = ''.
        IF lv_prio1 = 1. CONCATENATE lv_priority lc_p1 INTO lv_priority SEPARATED BY ','. ENDIF.
        IF lv_prio2 = 1. CONCATENATE lv_priority lc_p2 INTO lv_priority SEPARATED BY ','. ENDIF.
        IF lv_prio3 = 1. CONCATENATE lv_priority lc_p3 INTO lv_priority SEPARATED BY ','. ENDIF.
        IF lv_prio4 = 1. CONCATENATE lv_priority lc_p4 INTO lv_priority SEPARATED BY ','. ENDIF.
        CONDENSE lv_priority.
        IF lv_priority CP ',*'. SHIFT lv_priority LEFT DELETING LEADING ','. ENDIF.

        CONCATENATE 'Object:' ls_e071-obj_name ', Error(s):' lv_priority INTO ls_fail-object_name SEPARATED BY space.
        APPEND ls_fail TO lt_fail.
      ENDIF.

* Step 7: Prepare record for ZKP_25 table - key is strkorr+trkorr+object
      CLEAR ls_cts_atc.
      ls_cts_atc-mandt     = sy-mandt.
      ls_cts_atc-strkorr   = iv_strkorr.
      ls_cts_atc-trkorr    = lv_trkorr.
      ls_cts_atc-object    = ls_e071-obj_name.
      ls_cts_atc-obj_type  = ls_e071-object.
      ls_cts_atc-exec_id   = lv_display_id.
      ls_cts_atc-atc_prio1 = lv_prio1.
      ls_cts_atc-atc_prio2 = lv_prio2.
      ls_cts_atc-atc_prio3 = lv_prio3.
      ls_cts_atc-atc_prio4 = lv_prio4.
      ls_cts_atc-as4user   = sy-uname.
      ls_cts_atc-as4date   = sy-datum.
      ls_cts_atc-as4time   = sy-uzeit.

      APPEND ls_cts_atc TO lt_cts_atc.

    ENDLOOP.

* Step 8: Build the multi-line comment summary
    APPEND |<b>TR Task:</b> { lv_trkorr }| TO lt_comment_lines.

    IF lt_pass IS NOT INITIAL.
      APPEND |<b>ATC Successfully Passed for below Objects:</b>| TO lt_comment_lines.
      LOOP AT lt_pass INTO ls_pass.
        APPEND ls_pass-object_name TO lt_comment_lines.
      ENDLOOP.
    ENDIF.

    IF lt_fail IS NOT INITIAL.
      APPEND |<b>ATC Failed for below Objects:</b>| TO lt_comment_lines.
      LOOP AT lt_fail INTO ls_fail.
        APPEND ls_fail-object_name TO lt_comment_lines.
      ENDLOOP.
    ENDIF.

    APPEND '' TO lt_comment_lines.

  ENDLOOP.

* Step 9: Write ZKP_25 entries for ALL records, no deduplication across subtasks/objects
  IF lt_cts_atc IS NOT INITIAL.
    " If needed, only remove exact duplicates, not valid multi-subtask entries!
    SORT lt_cts_atc BY strkorr trkorr object obj_type exec_id.
    DELETE ADJACENT DUPLICATES FROM lt_cts_atc COMPARING strkorr trkorr object obj_type exec_id.
    et_cts_atc = lt_cts_atc.

    MODIFY zkp_25 FROM TABLE lt_cts_atc.
    COMMIT WORK AND WAIT.
  ENDIF.

* Step 10: Set the final comment export parameter
  ev_comment = lt_comment_lines.

ENDMETHOD.


METHOD GET_CLASS_METHOD.

  DATA: mtdkey   TYPE seocpdkey,
        lt_res   TYPE TABLE OF gty_includes,
        ls_res   TYPE gty_includes,
        lv_index TYPE sy-tabix.

* Get all methods and includes in a class.
  CALL METHOD cl_oo_classname_service=>get_all_method_includes
    EXPORTING
      clsname            = iv_class
    RECEIVING
      result             = lt_res
    EXCEPTIONS
      class_not_existing = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE zca_cx_exception
      EXPORTING
        gv_msgv1 = TEXT-005.
  ENDIF.

  LOOP AT lt_res INTO ls_res.
    lv_index = sy-tabix.
    mtdkey-clsname  = ls_res-clsname.
    mtdkey-cpdname  = ls_res-cpdname.
    ls_res-obj_name = mtdkey.
    MODIFY lt_res FROM ls_res INDEX lv_index.
  ENDLOOP.

* Fill Final table.
  ev_result = lt_res.
ENDMETHOD.


    METHOD get_fm_frm.
      DATA : lt_enlfdir TYPE STANDARD TABLE OF gty_funm,
             lt_tlibg   TYPE STANDARD TABLE OF tlibg,
             lt_tfdir   TYPE STANDARD TABLE OF tfdir,
             ls_enlfdir TYPE gty_funm,
             ls_fm      TYPE gty_funm,
             ls_tfdir   TYPE tfdir,
             lv_include TYPE rs38l-include.


* Validate Input Function Group
      SELECT * FROM tlibg
               INTO TABLE lt_tlibg
               WHERE area = iv_fgr.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zca_cx_exception
          EXPORTING
            gv_msgv1 = TEXT-004.
      ENDIF.
*Get Function Modules
      SELECT funcname area FROM enlfdir               "#EC CI_SGLSELECT
                           INTO TABLE lt_enlfdir
                           WHERE area = iv_fgr.
*get include names
      LOOP AT lt_enlfdir INTO ls_enlfdir.
        CALL FUNCTION 'FUNCTION_INCLUDE_INFO'
          CHANGING
            funcname = ls_enlfdir-funcname
*           GROUP    =
            include  = lv_include.


        ls_fm-funcname = ls_enlfdir-funcname.
        ls_fm-pname     = lv_include.
        APPEND ls_fm TO et_fm.
      ENDLOOP.
    ENDMETHOD.
ENDCLASS.
