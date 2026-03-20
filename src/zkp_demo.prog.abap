*&---------------------------------------------------------------------*
*& Report ZKP_DEMO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZKP_DEMO.
DATA: lv_input  TYPE string,
      lv_output TYPE string.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    input  = lv_input
  IMPORTING
    output = lv_output.
