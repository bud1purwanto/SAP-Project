*&---------------------------------------------------------------------*
*&      Module  T042Z_SELECT  OUTPUT
*&---------------------------------------------------------------------*
*       Lesen Langtext zum Zahlungsschlüssel
*----------------------------------------------------------------------*
MODULE T042Z_SELECT OUTPUT.

 PERFORM T042Z_SELECT USING VBKD-ZLSCH
                            RV45A-BUKRSL
                            SPACE
                            SY-SUBRC.


ENDMODULE.                 " T042Z_SELECT  OUTPUT