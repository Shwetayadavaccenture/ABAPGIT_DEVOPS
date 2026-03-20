class ZCL_ZATC_TRIGGER_ODATA_DPC_EXT definition
  public
  inheriting from ZCL_ZATC_TRIGGER_ODATA_DPC
  create public .

public section.
protected section.

  methods ZKP_25_ENTITYSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZATC_TRIGGER_ODATA_DPC_EXT IMPLEMENTATION.


  METHOD zkp_25_entityset_get_entityset.
**TRY.
*CALL METHOD SUPER->ZKP_25_ENTITYSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
    DATA: lt_entityset TYPE TABLE OF zkp_25.

    " Fetch all rows from your table
    SELECT * FROM zkp_25 INTO TABLE lt_entityset.

    " Pass the data to the OData response
    LOOP AT lt_entityset INTO DATA(ls_entity).
      APPEND VALUE #(
        Mandt      = ls_entity-mandt
        Strkorr    = ls_entity-strkorr
        Jira_Id     = ls_entity-jira_id
        Trkorr     = ls_entity-trkorr
        Obj_Type    = ls_entity-obj_type
        Object     = ls_entity-object
        Exec_Id     = ls_entity-exec_id
        Atc_Prio1   = ls_entity-atc_prio1
        Atc_Prio2   = ls_entity-atc_prio2
        Atc_Prio3   = ls_entity-atc_prio3
        Atc_Prio4   = ls_entity-atc_prio4
        As4user    = ls_entity-as4user
        As4date    = ls_entity-as4date
        As4time    = ls_entity-as4time
        Trkorrs    = ls_entity-trkorrs
      ) TO et_entityset.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
