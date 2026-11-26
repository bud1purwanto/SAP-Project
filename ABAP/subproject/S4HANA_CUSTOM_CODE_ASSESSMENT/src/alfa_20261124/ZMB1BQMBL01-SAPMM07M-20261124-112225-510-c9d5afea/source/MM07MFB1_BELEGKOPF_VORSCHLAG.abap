*eject
*---------------------------------------------------------------------*
*       MODULE BELEGKOPF_VORSCHLAG                                    *
*---------------------------------------------------------------------*
*       Für den Belegkopf werden Vorschlagswerte gesetzt.             *
*---------------------------------------------------------------------*
FORM BELEGKOPF_VORSCHLAG.

  CHECK T158-TRTYP = H.
  MKPF-VGART = VGART.
  MKPF-MANDT = SY-MANDT.
  IF XMBWL IS INITIAL.
    MKPF-BUDAT = SY-DATLO.
    MKPF-BLDAT = SY-DATLO.
  ENDIF.
  CHECK NOT T158-BLART IS INITIAL.
  CHECK NOT ( XCANC = 'X' AND T158-KZBEW = 'L' ).  "1275185
  IF NOT T158-BLA2D IS INITIAL.
    SELECT SINGLE * FROM T003 WHERE BLART = T158-BLA2D.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH '003' T158-BLA2D.
    ENDIF.
  ENDIF.
  SELECT SINGLE * FROM T003 WHERE BLART = T158-BLAUM.
  IF NOT SY-SUBRC IS INITIAL.
    MESSAGE E001 WITH '003' T158-BLAUM.
  ENDIF.
  SELECT SINGLE * FROM T003 WHERE BLART = T158-BLART.
  IF NOT SY-SUBRC IS INITIAL.
    MESSAGE E001 WITH '003' T158-BLART.
  ENDIF.
  IF MKPF-VGART = VGART_WA.
    GET PARAMETER ID 'BWA' FIELD RM07M-BWART.
    IF NOT RM07M-BWART IS INITIAL.
      SELECT SINGLE * FROM T158B WHERE TCODE = SY-TCODE
                                AND   BWART = RM07M-BWART.
      IF NOT SY-SUBRC IS INITIAL.
        CLEAR RM07M-BWART.
        SET PARAMETER ID 'BWA' FIELD RM07M-BWART.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.