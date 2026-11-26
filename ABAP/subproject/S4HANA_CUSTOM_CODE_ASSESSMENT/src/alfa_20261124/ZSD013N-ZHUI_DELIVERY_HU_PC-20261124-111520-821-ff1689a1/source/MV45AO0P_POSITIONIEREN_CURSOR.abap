*----------------------------------------------------------------------*
***INCLUDE MV45AO0P_POSITIONIEREN_CURSOR .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  POSITIONIEREN_CURSOR  OUTPUT
*&---------------------------------------------------------------------*
*       Wenn nicht gerade ein neuer Abruf angelegt wird, wird der
*       Cursor auf die erste Einteilung positioniert.
*----------------------------------------------------------------------*
MODULE POSITIONIEREN_CURSOR OUTPUT.
  IF NOT VBLB-LABNK IS INITIAL AND
     NOT VBLB-ABRDT IS INITIAL.
    SET CURSOR FIELD 'RV45A-ETDAT' LINE 1.
  ENDIF.
ENDMODULE.                 " POSITIONIEREN_CURSOR  OUTPUT