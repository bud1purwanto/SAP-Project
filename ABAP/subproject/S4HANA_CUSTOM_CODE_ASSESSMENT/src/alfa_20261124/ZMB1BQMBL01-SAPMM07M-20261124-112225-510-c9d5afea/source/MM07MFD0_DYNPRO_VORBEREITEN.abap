*eject
*---------------------------------------------------------------------*
*       FORM DYNPRO_VORBEREITEN                                       *
*---------------------------------------------------------------------*
*       Das Folgedynpro wird vorbereitet.                             *
*---------------------------------------------------------------------*
FORM DYNPRO_VORBEREITEN.
  CLEAR FUSS.
  CLEAR: XPAUS, XFUSS.
  IF ( FCAUSW-XSELP IS INITIAL OR
     FCODE = FCOD-SP  OR FCODE = FCOD-SS  OR
     FCODE = FCOD-SUU OR
     FCODE = FCOD-SSF OR FCODE = FCOD-SSR OR
     FCODE = FCOD-SLNV OR NOT XBACK IS INITIAL OR
     S_ZEILE > 0  OR T063O-AUSWA = U ) AND
     ( NOT FCODE = FCOD-SLNV OR PCODE_NEXT IS INITIAL ).
    DATA: XSTOR LIKE VM07M-XSTOR,
          EBELN LIKE MSEG-EBELN,
          EBELP LIKE MSEG-EBELP.
    CLEAR: SY-SUBRC, XSTOR, EBELN, EBELP.
    WHILE SY-SUBRC IS INITIAL AND FUSS-XSELK IS INITIAL.
      READ TABLE FUSS INDEX 1.
      IF SY-SUBRC IS INITIAL.
        CLEAR RC.
        IF NOT FUSS-XLAUS IS INITIAL.
          LOOP AT YLGORT WHERE ZEILE = FUSS-ZEILE
                           AND XSELP NE SPACE.
            RC = 4.
            CLEAR YLGORT-XSELP.
            MODIFY YLGORT.
            DATA: LIFNR LIKE MSEG-LIFNR.
            LIFNR = FUSS-LIFNR.
            MOVE-CORRESPONDING YLGORT TO FUSS.
            IF FUSS-FCODE = FCOD-SLNV.
              FUSS-FCODE = FCOD-NP.
            ENDIF.
            PERFORM BILDAUSWAHL_PRUEFEN(SAPFM07M) USING FUSS-BWART
                                                        FUSS-SOBKZ.
            FUSS-FAUSW = DM07M-FAUSW.
            FUSS-CHSMM = DM07M-CHSMM.
            FUSS-UMCHS = DM07M-UMCHS.
            FUSS-KZCHP = DM07M-KZCHP.
            FUSS-RULES = DM07M-RULES.
            IF FUSS-LIFNR IS INITIAL.
              FUSS-LIFNR = LIFNR.
            ENDIF.
            CLEAR LIFNR.
            MODIFY FUSS INDEX 1.
            BCODE-BWART = FUSS-BWART.
            BCODE-SOBKZ = FUSS-SOBKZ.
            EXIT.
          ENDLOOP.
          CLEAR SY-SUBRC.
        ELSE.
          REFRESH YLGORT.
        ENDIF.
        IF RC IS INITIAL.
          IF FUSS-FCODE IS INITIAL.
            CLEAR FUSS-XSELK.
* Bei MB04 wird zwar XSELK gelöscht, aber mit fuss weitergearbeitet
* -> Fehler beim Lesen des FCODE = Initial.
            IF T158-KZBEW = O.
              MODIFY FUSS INDEX 1.
            ENDIF.
          ELSE.
            PERFORM FCODE_LESEN USING FUSS-FCODE.
            IF NOT FCAUSW-XSELP IS INITIAL.
              DATA ZEILE LIKE MSEG-ZEILE.
              CLEAR ZEILE.
              DATA: BEGIN OF FUDEL OCCURS 5,
                      TABIX LIKE SY-TABIX,
                    END OF FUDEL.
              REFRESH FUDEL.
              LOOP AT FUSS.
                IF FUSS-XSELK IS INITIAL.
                  FUDEL-TABIX = SY-TABIX.
                  APPEND FUDEL.
                ELSE.
                  ZEILE = ZEILE + 1.
                  FUSS-ZEILE = ZEILE.
                  MODIFY FUSS.
                ENDIF.
              ENDLOOP.
              T_INDEX = 0.
              LOOP AT FUDEL.
                TABIX = FUDEL-TABIX - T_INDEX.
*##ngr-saanf
                PERFORM DELETE_FUSS USING TABIX.
*               delete fuss index tabix.
*##ngr-saend
                F_ZEILE = F_ZEILE - 1.
                IF NOT S_ZEILE IS INITIAL.
                  S_ZEILE = S_ZEILE - 1.
                ENDIF.
                T_INDEX = T_INDEX + 1.
              ENDLOOP.
              IF SY-SUBRC IS INITIAL.
                CLEAR FUSS-XSELK.
                CHECK A = B.
              ENDIF.
              READ TABLE FUSS INDEX 1.
              CLEAR FUSS-ZEILE.
              EXIT.
            ENDIF.
            IF NOT FCAUSW-XNEUP IS INITIAL AND
               NOT VM07M-XSTOR IS INITIAL AND VM07M-PSTYP = DREI.
              IF FUSS-KZBEW IS INITIAL.                     "204573
                IF EBELN = FUSS-EBELN AND EBELP = FUSS-EBELP AND
                   NOT FUSS-EBELN IS INITIAL.
                  CLEAR FUSS-XSELK.
                ENDIF.
              ELSE.
                EBELN = FUSS-EBELN.
                EBELP = FUSS-EBELP.
              ENDIF.
            ENDIF.
          ENDIF.
          IF NOT XBACK IS INITIAL.
            CLEAR XBACK.
            IF NOT FUSS-XLAUS IS INITIAL.
*##ngr-saanf
              PERFORM DELETE_FUSS USING 1.
*               delete fuss index 1.
*##ngr-saend
              F_ZEILE = F_ZEILE - 1.
              IF NOT S_ZEILE IS INITIAL.
                S_ZEILE = S_ZEILE - 1.
              ENDIF.
            ENDIF.
            SY-SUBRC = 8.
          ELSE.
*##ngr-saanf
            PERFORM DELETE_FUSS USING 1.
*           delete fuss index 1.
*##ngr-saend
            F_ZEILE = F_ZEILE - 1.
            IF NOT S_ZEILE IS INITIAL.
              S_ZEILE = S_ZEILE - 1.
            ENDIF.
            IF NOT FUSS-XLAUS IS INITIAL OR
               ( FUSS-XSELP IS INITIAL AND FCODE NE FUSS-FCODE ).
              CLEAR FUSS-XSELK.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDWHILE.
    IF SY-SUBRC IS INITIAL.
      XFUSS = X.
      FCODE = FUSS-FCODE.
      MOVE-CORRESPONDING FUSS TO DM07M.
      MOVE-CORRESPONDING FUSS TO VM07M.
      MOVE-CORRESPONDING FUSS TO MSEG.
      HELL = FUSS-XHELL.
*##ngr-saanf
      MATRIX = FUSS-XMATRIX.
*##ngr-saend
      PERFORM ANZAHL_WESCHEIN.
      IF NOT MSEG-WEANZ IS INITIAL AND DM07M-XWESC IS INITIAL.
        WANZM = MSEG-WEANZ.
      ENDIF.
      IF NOT XSELE IS INITIAL.
        HELL = X.
      ENDIF.
    ELSE.
      FREE YLGORT.
      LOOP AT FUSS.
* Sammelartikel, die defakto bereits in ymseg stehen, werden in fuss
* ans Ende gehaengt, um die Mengenkorrelation hinzubekommen;
* bei diesen darf fuss-zeile nicht mehr geaendert werden
        IF NOT ( FUSS-ATTYP = ATTYP-SAM
             AND FUSS-ZEILE <= M_ZEILE ).
          FUSS-ZEILE = SY-TABIX + M_ZEILE.
          MODIFY FUSS.
        ENDIF.
      ENDLOOP.
      DESCRIBE TABLE FUSS LINES F_ZEILE.
      CLEAR XSELE.
      CLEAR XBACK.
      IF NEXT_XKZBEW = EINS.
        READ TABLE FUSS INDEX 1.
        IF NOT SY-SUBRC IS INITIAL.
          CLEAR MSEG-KZBEW.
        ENDIF.
        CLEAR: RM07M-KZBEW.
        NEXT_XKZBEW = X.
      ELSEIF NEXT_XKZBEW = DREI OR NEXT_XKZBEW = VIER.
        RM07M-KZBEW = MSEG-KZBEW = B.
        NEXT_XKZBEW = X.
      ENDIF.
      PERFORM NEUE_POSITION.
      IF ( FCODE_NEXT = FCOD-NL AND M_ZEILE >= MAX_ZEILE ) OR
         FCODE_NEXT = FCOD-SLNV.
        FCODE_NEXT = FCOD-AB.
      ENDIF.
      ECODE = FCODE = FCODE_NEXT.
      PCODE = PCODE_NEXT.
      CLEAR: PCODE_NEXT, KREUZ, FUSS.
    ENDIF.
    IF FCODE_NEXT = FCOD-SP  OR FCODE_NEXT = FCOD-SS OR
       FCODE_NEXT = FCOD-SUU OR
       FCODE_NEXT = FCOD-SSF OR FCODE_NEXT = FCOD-SSR.
      FCODE_NEXT = FCOD-AB.
    ENDIF.
  ELSE.
    ECODE = FCODE.
    PCODE = PCODE_NEXT.
    CLEAR PCODE_NEXT.
  ENDIF.
  IF FCODE_NEXT = FCOD-BU.
    READ TABLE YMSEG INDEX 1.
    IF NOT SY-SUBRC IS INITIAL.
      DESCRIBE TABLE FUSS LINES INDEX_Z.
      IF INDEX_Z IS INITIAL AND FUSS-ZEILE IS INITIAL.
        FCODE_NEXT = FCODE = OLD_FCODE.
        XKZBEW     = OLD_XKZBEW.
        MESSAGE W061.
      ENDIF.
      CLEAR INDEX_Z.
    ENDIF.
  ENDIF.
  PERFORM FCODE_LESEN USING FCODE.
  IF NOT FCAUSW-XBEAP IS INITIAL.
    PERFORM ZEILE_SETZEN.
    CLEAR XKONT.
    PERFORM SEGMENT_UEBERNEHMEN USING I.
    IF NEXT_XKZBEW = X AND RC IS INITIAL.
      RM07M-KZBEW = MSEG-KZBEW.
      IF RM07M-KZBEW = B AND FCODE = FCOD-KL.
        FCODE_NEXT = FCODE = FCOD-NG.
      ELSEIF RM07M-KZBEW IS INITIAL AND FCODE = FCOD-NG.    "204573
        FCODE_NEXT = FCODE = FCOD-KL.
      ENDIF.
    ENDIF.
*   IF NOT YDM07M-FAUSW IS INITIAL AND FCAUSW-XNEUP IS INITIAL.
*     MOVE-CORRESPONDING YDM07M TO DM07M.
*   ENDIF.
  ENDIF.
  IF NOT FCAUSW-XBEAP IS INITIAL AND FCAUSW-XLIST IS INITIAL.
    RM07M-KZBEW = MSEG-KZBEW.
    IF NOT FCAUSW-XAENP IS INITIAL.
      YDM07M-XEXIT = DM07M-XEXIT.
    ENDIF.
  ELSEIF NEXT_XKZBEW IS INITIAL.
    RM07M-KZBEW = T158-KZBEW.
  ELSEIF NEXT_XKZBEW = X.
    CLEAR NEXT_XKZBEW.
  ENDIF.
  IF NOT FCAUSW-XNEUP IS INITIAL AND RM07M-KZBEW IS INITIAL AND
  XFUSS IS INITIAL.                                         "204573
    PERFORM ANHANG_BEREINIGEN.
  ENDIF.
  CLEAR: RM07M-MATNR,
         RM07M-CHARG,
         RM07M-EBELN,
         RM07M-EBELP,
         RM07M-MBLNR,
         RM07M-RSNUM,
         RM07M-RSPOS.
  CLEAR: ANF_BILD,
         INDEX_L,
         NEUE_POS,
         OLD_FCODE,
         OLD_FCAUSW,
         OLD_XKZBEW,
         PCODE,
         T063C,
         T063O,
         XPF02,
         XKZBEW.
ENDFORM.