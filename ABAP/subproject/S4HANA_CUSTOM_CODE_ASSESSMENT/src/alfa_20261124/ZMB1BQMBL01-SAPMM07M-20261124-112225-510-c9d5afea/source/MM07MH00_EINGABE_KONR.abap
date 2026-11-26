*eject
*---------------------------------------------------------------------*
*       MODULE EINGABE_KONR                                           *
*---------------------------------------------------------------------*
*       Aufruf des entsprechenden Reports zu den Reservierungen.      *
*---------------------------------------------------------------------*
MODULE EINGABE_KONR.
  CLEAR SELTAB1.
  REFRESH SELTAB1.
  IF NOT RM07M-RSNUM IS INITIAL.
    MOVE-CORRESPONDING RM07M TO SELTAB1.
    IF NOT SELTAB1-RSPOS IS INITIAL.
      SELTAB1-XEXPL = X.
    ENDIF.
    APPEND SELTAB1.
  ENDIF.
  CHECK RM07M-RSNUM IS INITIAL.
  EXPORT SELTAB1 TO MEMORY ID 'SELTAB1'.
  CLEAR XINIT.
  REFRESH RWERKS.
  IF RM07M-MATNR IS INITIAL
     AND ( ( NOT RM07M-KOSTL IS INITIAL OR NOT RM07M-AUFNR IS INITIAL OR
             NOT RM07M-PROJN IS INITIAL OR NOT RM07M-NPLNR IS INITIAL OR
             NOT RM07M-ANLN1 IS INITIAL OR NOT RM07M-UMWRK IS INITIAL OR
             NOT RM07M-KDAUF IS INITIAL )
            OR NOT RM07M-XKONT IS INITIAL ).
                                           " nur dann macht RM07RKON
                                           " was sinnvolles
    IF NOT RM07M-WERKS IS INITIAL.
      RWERKS-LOW    = RM07M-WERKS.
      RWERKS-SIGN   = 'I'.
      RWERKS-OPTION = 'EQ'.
      APPEND RWERKS.
    ENDIF.
    REFRESH RBDTER.
    IF NOT RM07M-BDTER IS INITIAL.
      RBDTER-LOW    = RM07M-BDTER.
      RBDTER-SIGN   = 'I'.
      PERFORM H_OPTION_SETZEN.
      APPEND RBDTER.
    ENDIF.
    SUBMIT RM07RKON AND RETURN WITH RK_KOSTL INCL RM07M-KOSTL
                               WITH RK_PROJN INCL RM07M-PROJN
                               WITH RK_NPLNR INCL RM07M-NPLNR
                               WITH    VORNR INCL RM07M-VORNR
                               WITH RK_ANLN1 INCL RM07M-ANLN1
                               WITH RK_ANLN2 INCL RM07M-ANLN2
                               WITH RK_UMWRK INCL RM07M-UMWRK
                               WITH RK_UMLGO INCL RM07M-UMLGO
                               WITH RK_AUFNR INCL RM07M-AUFNR
                               WITH RK_KDAUF INCL RM07M-KDAUF
                               WITH RK_KDPOS INCL RM07M-KDPOS
                               WITH RK_KDEIN INCL RM07M-KDEIN
                               WITH RK_XKONT INCL RM07M-XKONT
                               WITH WERKS    IN   RWERKS
                               WITH BDTER    IN   RBDTER
                               WITH XCALL    INCL X
                               WITH KZNEB    INCL AM07M-KZNEB
                               WITH XSTORNO  INCL T063F-XNBWA
                               WITH SOBKZ    INCL RM07M-SOBKZ.
  ELSE.
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
    SUBMIT RM07RMAT AND RETURN WITH RM_MATNR IN   RMATNR
                               WITH RM_WERKS IN   RWERKS
                               WITH RM_BDTER IN   RBDTER
                               WITH KOSTL    INCL RM07M-KOSTL
                               WITH AUFNR    INCL RM07M-AUFNR
                               WITH PROJN    INCL RM07M-PROJN
                               WITH NPLNR    INCL RM07M-NPLNR
                               WITH VORNR    INCL RM07M-VORNR
                               WITH ANLN1    INCL RM07M-ANLN1
                               WITH ANLN2    INCL RM07M-ANLN2
                               WITH UMWRK    INCL RM07M-UMWRK
                               WITH UMLGO    INCL RM07M-UMLGO
                               WITH KDAUF    INCL RM07M-KDAUF
                               WITH KDPOS    INCL RM07M-KDPOS
                               WITH KDEIN    INCL RM07M-KDEIN
                               WITH XKONT    INCL RM07M-XKONT
                               WITH XCALL    INCL X
                               WITH XINIT    INCL XINIT
                               WITH XSTORNO  INCL T063F-XNBWA
                               WITH KZNEB    INCL AM07M-KZNEB
                               WITH SOBKZ    INCL RM07M-SOBKZ.
  ENDIF.
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