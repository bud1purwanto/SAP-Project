*---------------------------------------------------------------------*
*       FORM FCODE_FEWE                                               *
*---------------------------------------------------------------------*
*       Aufruf der Fehlerbehandlungsliste                             *
*---------------------------------------------------------------------*
FORM FCODE_FEWE.

  DATA: EXITFLAG(1) TYPE C.
  CLEAR EXITFLAG.
  DO.
    DESCRIBE TABLE YVBUV LINES YVBUV_LINES.
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
        PERFORM FCODE_BEARBEITEN.
        EXITFLAG = 'X'.
        EXIT.
      ELSE.
        DELETE YVBUV INDEX 1.
      ENDIF.
      IF EXITFLAG = 'X'. EXIT. ENDIF.
    ELSE.
      FCODE = 'FEBA'.
      PERFORM FCODE_BEARBEITEN.
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