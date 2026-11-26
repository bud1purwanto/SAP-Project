************************************************************************
*                                                                      *
* PAI Module Kundenauftragsabwicklung                                  *
*     Module alphabetisch geordnet; hier mit "B" beginnend             *
*                                                                      *
************************************************************************

  INCLUDE MV45AI0B_BESTELL_DATEN_ANZEIGE .



*---------------------------------------------------------------------*
*       MODULE BELEG_LESEN                                            *
*---------------------------------------------------------------------*
*       Der Beleg wird gelesen                                        *
*---------------------------------------------------------------------*
MODULE BELEG_LESEN.

  IF I_VBAKKOM IS INITIAL.
    PERFORM BELEG_LESEN.
  ELSE.
    PERFORM BELEG_AUS_CONTAINER.
  ENDIF.

ENHANCEMENT-POINT BELEG_LESEN_20 SPOTS ES_SAPMV45A.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE BELEGKOPF_LESEN                                        *
*---------------------------------------------------------------------*
*       Der Beleg wird gelesen                                        *
*---------------------------------------------------------------------*
MODULE BELEGKOPF_LESEN.

  CALL FUNCTION 'SD_VBAK_SELECT'
       EXPORTING
            I_DOCUMENT_NUMBER = VBAK-VBELN
       IMPORTING
            E_VBAK            = VBAK.

ENDMODULE.