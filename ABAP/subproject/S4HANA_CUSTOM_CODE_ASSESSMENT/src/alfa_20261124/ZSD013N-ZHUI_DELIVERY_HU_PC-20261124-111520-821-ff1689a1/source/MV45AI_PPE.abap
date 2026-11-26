*&---------------------------------------------------------------------*
*&  Include           MV45AI_PPE
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  MODULE koein_fill_ppe INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE koein_fill_ppe INPUT.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ende_ohne_pruefung USING space
                             CHANGING leave_without_check.
  CHECK leave_without_check IS INITIAL.

  PERFORM koein_fill_ppe(sapfv45p).

ENDMODULE.                    "KOEIN_FILL_PPE INPUT

*----------------------------------------------------------------------*
*  MODULE KOMV_process_ppe INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE komv_process_ppe INPUT.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  PERFORM ende_ohne_pruefung USING space
                             CHANGING leave_without_check.
  CHECK leave_without_check IS INITIAL.

  CHECK vbap-posnr NE '000000'.
  PERFORM komv_process_ppe(sapfv45p).

ENDMODULE.                    "komv_process_ppe INPUT