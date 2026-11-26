************************************************************************
*                                                                      *
* PAI Module Versand                                                   *
*     Module alphabetisch geordnet; hier mit "V" beginnend             *
*                                                                      *
************************************************************************
*---------------------------------------------------------------------*
*       MODULE VERTRIEBSBEREICH_PR                                    *
*---------------------------------------------------------------------*
*       Eingabeprüfung: Vertriebsbereich                              *
*---------------------------------------------------------------------*
MODULE VERTRIEBSBEREICH_PR.

  CHECK FCODE(4) NE FCODE_ABBRECHEN    "46A BEY
    AND FCODE(4) NE FCODE_ENDE.

  PERFORM TVTA_SELECT USING LIKP-VKORG
                            RV50A-VTWEG
                            RV50A-SPART.

ENDMODULE.

*---------------------------------------------------------------------*
*       FORM VERSANDST_PRUEFEN                                        *
*---------------------------------------------------------------------*
*       Die Angabe der Versandstelle ist obligatorisch und wird       *
*       gegen Tabelle VST verprobt                                    *
*---------------------------------------------------------------------*
MODULE VERSANDST_PRUEFEN INPUT.

ENHANCEMENT-SECTION     VERSANDST_PRUEFEN_01 SPOTS ES_SAPMV50A.
  IF LIKP-VSTEL IS INITIAL
     OR LIKP-VSTEL = '?'.
    SET CURSOR FIELD LIKP-VSTEL.
    MESSAGE E113.
  ELSE.
    PERFORM TVST_SELECT USING LIKP-VSTEL
                              CHARX
                              SY-SUBRC.
  ENDIF.
END-ENHANCEMENT-SECTION.

ENDMODULE.
*eject
ENHANCEMENT-POINT MV50AI0V_01 SPOTS ES_SAPMV50A STATIC.