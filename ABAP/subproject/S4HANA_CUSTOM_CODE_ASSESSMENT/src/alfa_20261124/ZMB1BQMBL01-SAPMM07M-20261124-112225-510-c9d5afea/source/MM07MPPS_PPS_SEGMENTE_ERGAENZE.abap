*eject
*---------------------------------------------------------------------*
*       FORM PPS_SEGMENTE_ERGAENZEN                                   *
*---------------------------------------------------------------------*
*       Die Tabelle zum Fortschreiben des PPS-Auftrages wird ergaenzt.*
*---------------------------------------------------------------------*
FORM PPS_SEGMENTE_ERGAENZEN.

*------ Aufträge (ohne Wert für CO )----------------------------------*
  READ TABLE ZFABE INDEX 1.
  IF SY-SUBRC IS INITIAL.
    CALL FUNCTION 'CO_DOCUMENT_QUANTITIES_PROJECT'
         EXPORTING
              MBLNR  = XMKPF-MBLNR
              MJAHR  = XMKPF-MJAHR
         TABLES
              T_FABE = ZFABE.
  ENDIF.

ENDFORM.