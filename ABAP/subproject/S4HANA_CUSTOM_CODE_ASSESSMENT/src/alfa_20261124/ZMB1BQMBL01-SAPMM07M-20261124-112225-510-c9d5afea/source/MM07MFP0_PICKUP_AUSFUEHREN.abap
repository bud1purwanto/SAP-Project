*eject
*---------------------------------------------------------------------*
*       FORM PICKUP_AUSFUEHREN                                        *
*---------------------------------------------------------------------*
*       Der gewuenschte Transaktionsaufruf wird ausgefuehrt.          *
*---------------------------------------------------------------------*
FORM pickup_ausfuehren.

  CHECK xpf02 = x OR xpf02 = m.
  CHECK ccode NE ccod-nser.
  IF aufsetzen IS INITIAL.
    aufsetzen = mseg-zeile.
  ENDIF.
  MOVE-CORRESPONDING mseg  TO old.
  old-maktx = dm07m-maktx.
  old-xselk = rm07m-xselk.
  APPEND old.
  IF index_l = index_z.
    DATA: xcall.
    CLEAR xcall.
    IF NOT fcausw-xselp IS INITIAL.
      READ TABLE fuss INDEX index_l.
      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING fuss TO mseg.
        vm07m-ekorg = fuss-ekorg.
      ELSE.
        xcall = n.
      ENDIF.
    ELSE.
      READ TABLE ymseg INDEX index_l.
      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING ymseg TO mseg.
      ELSE.
        IF mseg-matnr IS INITIAL.
          xcall = n.
        ENDIF.
      ENDIF.
    ENDIF.
    CASE ccode.
      WHEN ccod-clas.
        DATA : loc_feld(11).                               "note 129198
        PERFORM chargen_klassifizieren USING aktyp         "note 129198
                                             loc_feld.     "note 129198
      WHEN ccod-konb.
        IF dm07m-knttp IS INITIAL.
          xcall = n.
          MESSAGE w081 WITH mseg-ebeln mseg-ebelp.
        ELSE.
          IF NOT dm07m-mulko IS INITIAL AND mseg-maa_urzei IS INITIAL."MAA2
            xcall = n.
*---------- MAA-DEV
            CALL FUNCTION 'MB_MAA_DISPLAY'    "seems to be obsolete "MAA2
              EXPORTING
                i_mseg  = mseg
                i_vm07m = vm07m
                i_dm07m = dm07m.
*---------- MAA-DEV
          ENDIF.
        ENDIF.
      WHEN ccod-vers.
        xcall = n.
        IF mseg-evers IS INITIAL.
          MESSAGE w091 WITH mseg-zeile.
        ELSE.
          PERFORM versandvorschrift_pruefen.
        ENDIF.
      WHEN ccod-nach.
        PERFORM nachrichten_pflege.
*     WHEN CCOD-NSER.
*       PERFORM SERIALNUMMERN_PFLEGEN.
      WHEN ccod-qins.
        PERFORM qss_los_show.
      WHEN ccod-arch.
        PERFORM nachricht_archive.
      WHEN ccod-arzu.
        PERFORM nachricht_archive_zuordnen.
*##ngr-saanf
      WHEN ccod-matr.
        xcall = n.
        matrix_kopf = mseg-zeile.
*##ngr-saend
      WHEN ccod-reac.                  " PPF 20.04.98
        xcall = n.                     " PPF 20.04.98
        matrix_kopf = mseg-zeile.      " PPF 20.04.98
        vareac = x.                    " PPF 20.04.98
    ENDCASE.
    IF xcall IS INITIAL.
      CLEAR vw.
      IF NOT t063o-tcode IS INITIAL.
        PERFORM transaktion_aufrufen.
      ENDIF.
      IF NOT ccode IS INITIAL.
        SELECT SINGLE * FROM t063c WHERE ccode = ccode.
        IF sy-subrc IS INITIAL.
          CHECK t063c-ccode NE ccod-verf.
          CALL SCREEN t063c-dynnr STARTING AT t063c-winx1 t063c-winy1
                                  ENDING   AT t063c-winx2 t063c-winy2.
        ENDIF.
      ENDIF.
    ENDIF.
    IF ccode NE ccod-verf AND
*##ngr-saanf
*      CCODE NE CCOD-MATR.                               " PPF 20.04.98
       ccode NE ccod-matr AND          " PPF 20.04.98
       ccode NE ccod-reac.             " PPF 20.04.98
*##ngr-saend
      CLEAR: t063c, t063o, ccode.
    ENDIF.
  ENDIF.
  index_z = index_z + 1.

ENDFORM.