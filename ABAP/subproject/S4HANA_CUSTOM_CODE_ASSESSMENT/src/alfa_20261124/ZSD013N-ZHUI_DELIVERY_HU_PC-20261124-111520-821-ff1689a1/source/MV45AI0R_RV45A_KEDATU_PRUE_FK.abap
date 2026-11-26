*----------------------------------------------------------------------*
*   INCLUDE MV45AI0R_RV45A_KEDATU_PRUE_FK                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  RV45A_KEDATU_PRUEFEN_FK  INPUT
*&---------------------------------------------------------------------*
*       Das eingegebene Vorschlagsdatum wird gegen den Fabrikalender
*       des Vorschlagswerks geprüft, sofern dies möglich ist
*----------------------------------------------------------------------*
MODULE RV45A_KEDATU_PRUEFEN_FK INPUT.

  DATA DA_SUBRC_DAT_WERK LIKE SY-SUBRC.

  IF NOT VBAK-VBKLT EQ VBKLT_AUSL_AUFT AND
     NOT VBAK-VBKLT EQ VBKLT_AUSL_AUFT_KORR.
* In Auslieferungsaufträgen wird nicht geprüft
    PERFORM DATUM_PRUEFEN_WERK_FK USING RV45A-DWERK
                                        VBAK-VDATU
                                        CHARX
                                        SPACE
                                  CHANGING DA_SUBRC_DAT_WERK.
  ENDIF.

ENDMODULE.                             " RV45A_KEDATU_PRUEFEN_FK  INPUT