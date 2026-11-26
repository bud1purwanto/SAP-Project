*eject
*---------------------------------------------------------------------*
*       FORM BESTELLUNG_BWA_RETOURE                                   *
*---------------------------------------------------------------------*
*       Die Retourenbewegungsart wird ermittelt.                      *
*---------------------------------------------------------------------*
  FORM bestellung_bwa_retoure.
    IF NOT xebefu-retpo IS INITIAL.
      IF NOT t156n-fcode = fcod-were OR NOT t156n-bwart = t156-bwart.  "1408687
        SELECT SINGLE * FROM t156n WHERE fcode = fcod-were
                                    AND  bwart = t156-bwart.
      ELSE.
        CLEAR sy-subrc.
      ENDIF.
      CHECK sy-subrc IS INITIAL.
      PERFORM bewegungsart_pruefen(sapfm07m) USING t156n-bwart_next
                                                   space.
    ENDIF.
  ENDFORM.                    "BESTELLUNG_BWA_RETOURE