*&---------------------------------------------------------------------*
*& Report ZKP_DEMO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZKP_DEMO.
*& we are testing abapgit and pushing the code from github to s8h.
DATA: lv_input  TYPE string,
      lv_output TYPE string.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    input  = lv_input
  IMPORTING
    output = lv_output.
