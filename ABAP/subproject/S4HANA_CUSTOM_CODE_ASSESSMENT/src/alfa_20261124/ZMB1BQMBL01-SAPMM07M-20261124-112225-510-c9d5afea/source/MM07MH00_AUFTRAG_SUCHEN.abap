*---------------------------------------------------------------------*
*        PAI-Module zum Modulpool SAPMM07M für Eingabehilfen          *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       MODULE AUFTRAG_SUCHEN                                         *
*---------------------------------------------------------------------*
*       Bei Eingabe von Material wird der Auftrag gesucht.            *
*---------------------------------------------------------------------*
MODULE AUFTRAG_SUCHEN.
  IF NOT XAKTIV IS INITIAL.
    CLEAR XAKTIV.
    PERFORM SUCHFELDER_INIT.
    EXIT.
  ENDIF.
  IF AM07M-MATNV IS INITIAL AND
     AM07M-WERKV IS INITIAL AND XAKTIV IS INITIAL.
    MESSAGE E017.
  ENDIF.
  CLEAR FUEB.
  REFRESH FUEB.
  FUEB-NRCFD = X.
  EXPORT FUEB-NRCFD FUEB TO MEMORY ID FUEB-ID.
  IF NOT AM07M-MATNV IS INITIAL OR NOT AM07M-WERKV IS INITIAL.
    SUBMIT PPCOWE00 AND RETURN WITH P_MATNR EQ   AM07M-MATNV
                               WITH P_WERKS EQ   AM07M-WERKV
                               WITH P_SHKZG EQ   T156-SHKZG.
  ENDIF.
  IMPORT FUEB-NRCFD FUEB FROM MEMORY ID FUEB-ID.
  DESCRIBE TABLE FUEB LINES INDEX_Z.
  IF INDEX_Z IS INITIAL.
    MESSAGE E083.
  ENDIF.
  SORT FUEB BY AUFNR POSNR.
* PERFORM SUCHFELDER_INIT.
  LOOP AT FUEB.
    RM07M-AUFNR = FUEB-AUFNR.
    RM07M-AUFPS = FUEB-POSNR.
    PERFORM STEUERFLAGS_INITIALISIEREN(SAPFM07M).
    PERFORM FUSSZEILE_WF_NEU.
  ENDLOOP.
  CLEAR: RM07M-AUFNR,
         RM07M-AUFPS.
  FREE MEMORY ID FUEB-ID.
ENDMODULE.