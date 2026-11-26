*---------------------------------------------------------------------*
*       MODULE AUFTRAG_WA_SUCHEN                                      *
*---------------------------------------------------------------------*
*       Bei Eingabe von Material wird der Auftrag gesucht.            *
*---------------------------------------------------------------------*
MODULE AUFTRAG_WA_SUCHEN.
  IF NOT XAKTIV IS INITIAL.
    CLEAR XAKTIV.
    PERFORM SUCHFELDER_INIT.
    EXIT.
  ENDIF.
  IF RM07M-WERKS IS INITIAL AND RM07M-MATNR IS INITIAL
     AND XAKTIV IS INITIAL.
    MESSAGE E017.
  ENDIF.
  CLEAR SELTAB1.
  REFRESH SELTAB1.
  EXPORT SELTAB1 TO MEMORY ID 'SELTAB1'.
  CLEAR XINIT.
  IF RM07M-WERKS IS INITIAL.
    XINIT = X.
  ENDIF.
  REFRESH RWERKS.
  IF NOT RM07M-WERKS IS INITIAL.
    RWERKS-LOW    = RM07M-WERKS.
    RWERKS-SIGN   = 'I'.
    RWERKS-OPTION = 'EQ'.
    APPEND RWERKS.
  ENDIF.
  REFRESH RMATNR.
  IF NOT RM07M-MATNR IS INITIAL.
    RMATNR-LOW    = RM07M-MATNR.
    RMATNR-SIGN   = 'I'.
    RMATNR-OPTION = 'EQ'.
    APPEND RMATNR.
  ENDIF.
  REFRESH RBDTER.
  IF NOT RM07M-BDTER IS INITIAL.
    RBDTER-LOW    = RM07M-BDTER.
    RBDTER-SIGN   = 'I'.
    PERFORM H_OPTION_SETZEN.
    APPEND RBDTER.
  ENDIF.
  SUBMIT RM07RMAT AND RETURN WITH RM_MATNR  IN   RMATNR
                             WITH RM_WERKS  IN   RWERKS
                             WITH RM_BDTER  IN   RBDTER
                             WITH XINIT     INCL XINIT
                             WITH XCALL     INCL X
                             WITH KZNEB     INCL AM07M-KZNEB
                             WITH XSTORNO   INCL T063F-XNBWA
                             WITH XAUFNR    INCL X.
  IF NOT ABBRECHEN IS INITIAL.
    PERFORM ABBRECHEN.
  ENDIF.
  IMPORT SELTAB1 FROM MEMORY ID 'SELTAB1'.
  DESCRIBE TABLE SELTAB1 LINES INDEX_Z.
  IF INDEX_Z IS INITIAL.
    MESSAGE E083.
  ENDIF.
  SORT SELTAB1 BY RSNUM RSPOS.
* PERFORM SUCHFELDER_INIT.
ENDMODULE.