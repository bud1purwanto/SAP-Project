*---------------------------------------------------------------------*
*   GEMEINSAME ROUTINEN MIT DER INVENTUR                              *
*---------------------------------------------------------------------*


*---------------------------------------------------------------------*
*       FORM BESTANDSFELDER_PRUEFEN                                   *
*---------------------------------------------------------------------*
*       Lesen der Tabelle T150F.                                      *
*---------------------------------------------------------------------*
FORM BESTANDSFELDER_PRUEFEN USING BSF_BSTAR
                                  BSF_SOBKZ
                                  BSF_XCHAR
                                  BSF_XRUEM
                                  BSF_XRUEJ.

* Nur für zustandsverwaltete Chargen
  IF ( NOT MBEFU-ZUSTD IS INITIAL AND BSF_BSTAR EQ '1' ) OR
     ( NOT BSF_XRUEM   IS INITIAL AND BSF_BSTAR EQ '1' ).
    SELECT SINGLE * FROM T150F WHERE BSTAR = '0'
                               AND   SOBKZ = BSF_SOBKZ
                               AND   KZCHA = BSF_XCHAR
                               AND   XRUEM = BSF_XRUEM
                               AND   XRUEJ = BSF_XRUEJ.

    IF SY-SUBRC IS INITIAL.
      Z150F = T150F.
    ELSE.
      MESSAGE E001 WITH '150F'
                        '0' BSF_SOBKZ BSF_XCHAR.
    ENDIF.
  ELSE.
    CLEAR Z150F.
  ENDIF.

* Ablauf wie bisher
  SELECT SINGLE * FROM T150F WHERE BSTAR = BSF_BSTAR
                             AND   SOBKZ = BSF_SOBKZ
                             AND   KZCHA = BSF_XCHAR
                             AND   XRUEM = BSF_XRUEM
                             AND   XRUEJ = BSF_XRUEJ.

  IF NOT SY-SUBRC IS INITIAL.
    MESSAGE E001 WITH '150F'
                      BSF_BSTAR BSF_SOBKZ BSF_XCHAR.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*   FORM I-SEGMENTE_CHARGEN                                           *
*---------------------------------------------------------------------*
*   Auswertung der Tab. aller chargenpfl. Positionen, damit bei der   *
*   Verbuchung entsprechend geprüft werden kann, ob alle Chargen zu   *
*   einem Material auf dem jeweiligen Werk/Lagerort inventiert sind.  *
*---------------------------------------------------------------------*
FORM I-SEGMENTE_CHARGEN.
  DATA: VGL_MATNR LIKE ISEG-MATNR,
        VGL_BSTAR LIKE ISEG-BSTAR.
  DATA: BEGIN OF YCDEL OCCURS 0,
            MATNR LIKE ISEG-MATNR,
            BSTAR LIKE ISEG-BSTAR,
        END   OF YCDEL.
  SORT YCM07I BY MATNR BSTAR XDIFF.
  LOOP AT YCM07I.
    IF YCM07I-XDIFF IS INITIAL.
      MOVE-CORRESPONDING YCM07I TO YCDEL.
      APPEND YCDEL.
    ENDIF.
  ENDLOOP.
  LOOP AT YCDEL.
    LOOP AT YCM07I.
      IF YCDEL-MATNR = YCM07I-MATNR AND YCDEL-BSTAR = YCM07I-BSTAR.
        DELETE YCM07I.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  REFRESH YCDEL.
  CLEAR: VGL_MATNR,
         VGL_BSTAR,
         YCDEL.
  LOOP AT YCM07I.
    CLEAR VW.
    IF YCM07I-MATNR NE VGL_MATNR.
      VW = X.
    ELSE.
      IF YCM07I-BSTAR NE VGL_BSTAR.
        VW = X.
      ENDIF.
    ENDIF.
    IF VW = X.
      MOVE-CORRESPONDING YCM07I TO XCM07I.
      PERFORM BESTANDSFELDER_PRUEFEN USING XCM07I-BSTAR
                                           IKPF-SOBKZ
                                           SPACE
                                           TM07I-XRUEM
                                           TM07I-XRUEJ.
      XCM07I-AISTA = T150F-ISTAT.
      XCM07I-SEGMU = T150F-SEGMN.
      APPEND XCM07I.
    ENDIF.
    VGL_MATNR = YCM07I-MATNR.
    VGL_BSTAR = YCM07I-BSTAR.
  ENDLOOP.
ENDFORM.
*eject