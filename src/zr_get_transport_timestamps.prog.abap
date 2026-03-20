REPORT zr_get_transport_timestamps.

TYPES: BEGIN OF ty_tr_info,
         trkorr      TYPE trkorr,       "Transport Request number
         as4date     TYPE as4date,      "Release date
         as4time     TYPE as4time,      "Release time
       END OF ty_tr_info.

DATA: lt_tr_data   TYPE TABLE OF ty_tr_info,
      ls_tr_data   TYPE ty_tr_info,
      lt_e070      TYPE TABLE OF e070,
      ls_e070      TYPE e070,
      lv_date_from TYPE sy-datum,
      lt_fieldcat  TYPE slis_t_fieldcat_alv,
      ls_fieldcat  TYPE slis_fieldcat_alv,
      ls_layout    TYPE slis_layout_alv.

* Calculate date 6 months ago from today
lv_date_from = sy-datum - 180.

* Select released transport requests in last 6 months from E070
SELECT trkorr as4date as4time
  FROM e070
  INTO CORRESPONDING FIELDS OF TABLE lt_e070
  WHERE trstatus = 'R'           " Released status
    AND as4date >= lv_date_from  " Last 6 months
  ORDER BY as4date DESCENDING.

IF lt_e070 IS INITIAL.
  MESSAGE 'No released transport requests found in the last 6 months.' TYPE 'I'.
  EXIT.
ENDIF.

* Populate internal table for display
LOOP AT lt_e070 INTO ls_e070.
  CLEAR ls_tr_data.
  ls_tr_data-trkorr = ls_e070-trkorr.
  ls_tr_data-as4date = ls_e070-as4date.
  ls_tr_data-as4time = ls_e070-as4time.
  APPEND ls_tr_data TO lt_tr_data.
ENDLOOP.

* Build field catalog for ALV display
CLEAR ls_fieldcat.
ls_fieldcat-fieldname = 'TRKORR'.
ls_fieldcat-seltext_l = 'Transport Request'.
ls_fieldcat-seltext_m = 'TR Number'.
ls_fieldcat-seltext_s = 'TR No.'.
ls_fieldcat-outputlen = 20.
APPEND ls_fieldcat TO lt_fieldcat.

CLEAR ls_fieldcat.
ls_fieldcat-fieldname = 'AS4DATE'.
ls_fieldcat-seltext_l = 'Release Date'.
ls_fieldcat-seltext_m = 'Rel. Date'.
ls_fieldcat-seltext_s = 'Date'.
ls_fieldcat-outputlen = 10.
APPEND ls_fieldcat TO lt_fieldcat.

CLEAR ls_fieldcat.
ls_fieldcat-fieldname = 'AS4TIME'.
ls_fieldcat-seltext_l = 'Release Time'.
ls_fieldcat-seltext_m = 'Rel. Time'.
ls_fieldcat-seltext_s = 'Time'.
ls_fieldcat-outputlen = 8.
APPEND ls_fieldcat TO lt_fieldcat.

* Set layout options
ls_layout-colwidth_optimize = 'X'.  " Optimize column width
ls_layout-zebra = 'X'.              " Alternate row colors

* Display ALV Grid
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = sy-repid
    is_layout          = ls_layout
    it_fieldcat        = lt_fieldcat
  TABLES
    t_outtab           = lt_tr_data
  EXCEPTIONS
    program_error      = 1
    OTHERS             = 2.

IF sy-subrc <> 0.
  MESSAGE 'Error displaying ALV grid' TYPE 'E'.
ENDIF.
