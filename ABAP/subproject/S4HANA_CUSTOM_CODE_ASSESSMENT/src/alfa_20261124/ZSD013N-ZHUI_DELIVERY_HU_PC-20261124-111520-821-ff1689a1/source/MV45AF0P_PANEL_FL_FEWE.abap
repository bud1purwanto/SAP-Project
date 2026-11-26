*---------------------------------------------------------------------*
*       FORM PANEL_FL_FEWE                                            *
*---------------------------------------------------------------------*
*       CModul, Aufruf aus Folgebildsteuerung im Verarbeitungsort     *
*       FL/FEWE (Bildgruppe/Panel)                                    *
*---------------------------------------------------------------------*
*       Aufruf der Fehlerbehandlungsliste                             *
*---------------------------------------------------------------------*
FORM PANEL_FL_FEWE USING H185F STRUCTURE T185F
                         H185  STRUCTURE T185
                         H185V STRUCTURE T185V.

  DATA: EXITFLAG(1) TYPE C.
  CLEAR EXITFLAG.
  DO.
* Unvollständigkeit Partner-Subscreen - Fehlerflags zurücksetzen
    clear: fehler_kpar_sub,
           fehler_ppar_sub.
    describe table yvbuv lines yvbuv_lines.
    IF YVBUV_LINES > 0.
      READ TABLE YVBUV INDEX 1.
      READ TABLE XVBUV WITH KEY YVBUV(89).
      IF SY-SUBRC = 0.
        IF XVBUV-FCODE IS INITIAL.
          MESSAGE I003(VU) WITH XVBUV-TBNAM XVBUV-FDNAM XVBUV-FEHGR.
          DELETE YVBUV INDEX 1.
          CONTINUE.
        ENDIF.
        CONCATENATE XVBUV-TBNAM XVBUV-FDNAM
          INTO FEHLERFELD SEPARATED BY '-'.
        DELETE YVBUV INDEX 1.
        PERFORM FEHLERBEHANDLUNG.
        H185F-FCODE = FCODE.
        EXITFLAG = 'X'.
        EXIT.
      ELSE.
        DELETE YVBUV INDEX 1.
      ENDIF.
      IF EXITFLAG = 'X'. EXIT. ENDIF.
    ELSE.
      FCODE = 'FEBA'.
      H185F-FCODE = FCODE.
      EXIT.
    ENDIF.
  ENDDO.

  IF SY-CALLD = ' '.
*   Aufruf aus VAx1, VAx2, VAx3
    LEAVE.
  ELSE.
*   Aufruf aus VAx5
    EXIT.
  ENDIF.
ENDFORM.