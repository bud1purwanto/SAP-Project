*eject
*---------------------------------------------------------------------*
*       FORM BUCHEN_VORBEREITEN                                       *
*---------------------------------------------------------------------*
*       Die zu buchenden Segmente werden zusammengestellt.            *
*---------------------------------------------------------------------*
FORM BUCHEN_VORBEREITEN USING B-UPDAT TYPE C.

  CLEAR B-UPDAT.
  REFRESH XMKPF.
  IF NOT XMKPF = MKPF.
    XMKPF = MKPF.
    B-UPDAT = X.
  ENDIF.
  MSEG_KEY-MANDT = XMKPF-MANDT.
  MSEG_KEY-MBLNR = XMKPF-MBLNR.
  MSEG_KEY-MJAHR = XMKPF-MJAHR.
  LOOP AT YMSEG.
    MSEG_KEY-ZEILE = YMSEG-ZEILE.
    YMSEG-XBLNR_MKPF = XMKPF-XBLNR.                       "n1679885
    READ TABLE XMSEG WITH KEY MSEG_KEY BINARY SEARCH.
    CASE SY-SUBRC.
      WHEN 0.
        IF XMSEG = YMSEG.
          DELETE XMSEG INDEX SY-TABIX.
        ELSE.
          XMSEG = YMSEG.
          MODIFY XMSEG INDEX SY-TABIX.
          B-UPDAT = X.
        ENDIF.
      WHEN 4.
        XMSEG = YMSEG.
        INSERT XMSEG INDEX SY-TABIX.
      WHEN 8.
        XMSEG = YMSEG.
        APPEND XMSEG.
    ENDCASE.
  ENDLOOP.
  IF NOT B-UPDAT IS INITIAL.
    XMKPF-AEDAT = SY-DATUM.
    APPEND XMKPF.
  ENDIF.
  IF NOT UPD_NAST IS INITIAL.
    B-UPDAT = X.
  ENDIF.
  IF B-UPDAT IS INITIAL.
    MESSAGE S724.
  ELSE.
    MESSAGE S070 WITH MKPF-MBLNR.
  ENDIF.
ENDFORM.