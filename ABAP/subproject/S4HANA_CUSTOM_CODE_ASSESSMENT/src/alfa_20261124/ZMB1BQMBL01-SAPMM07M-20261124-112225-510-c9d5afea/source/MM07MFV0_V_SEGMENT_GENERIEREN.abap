*---------------------------------------------------------------------*
*       FORM V-SEGMENT_GENERIEREN                                     *
*---------------------------------------------------------------------*
*       Aus der Tabelle XMSEG werden die Eintraege ermittelt, die     *
*       eine Verbrauchsfortschreibung im Materialstammsatz bewirken.  *
*       Dabei wird unterschieden, ob es sich um geplante oder unge-   *
*       plante Verbräuche handelt. Bei einem ungeplanten Verbrauch    *
*       muss sowohl der ungeplante als auch der gesamte Verbrauch     *
*       fortgeschrieben werden. Bei einem geplanten Verbrauch wird    *
*       nur der gesamte Verbrauch fortgeschrieben.                    *
*---------------------------------------------------------------------*
FORM v-segment_generieren.

  CHECK NOT xmseg-matnr IS INITIAL.
  CLEAR xvstat.
* No consumption update for inventory adjustment.
  CHECK inventur IS INITIAL.                                     "402711
  CHECK NOT zdm07m-kzvbu IS INITIAL.
  CHECK ( NOT zdm07m-kzvbl IS INITIAL AND NOT xmseg-xauto = x )
  OR ( NOT zdm07m-umkzv IS INITIAL AND xmseg-xauto = x ).
  CASE zdm07m-kzvbu.
    WHEN g.
      xvstat-gsvbr = xmseg-menge.
    WHEN r.
      DATA: refe1 TYPE f.
      xvstat-gsvbr = xmseg-menge.
      IF xmseg-rspos IS INITIAL.
        xvstat-unvbr = xmseg-menge.
      ELSE.
        xmres_key-rsnum = xmseg-rsnum.
        xmres_key-rspos = xmseg-rspos.
        xmres_key-rsart = xmseg-rsart.
        READ TABLE xmres WITH KEY xmres_key BINARY SEARCH.
        IF NOT sy-subrc IS INITIAL.
          MESSAGE e001 WITH 'XMRES' xmres_key.
        ENDIF.
        IF xmseg-shkzg = zdm07m-rshkz.
          refe1 = xmseg-menge + xmres-vnmng.
* Neuer Verbrauch ist größer reservierte Menge
          IF zdm07m-bdmng LT refe1.
* Alter Verbrauch war größer/gleich reservierte Menge
            IF zdm07m-bdmng LE xmres-vnmng .
              xvstat-unvbr = xmseg-menge.
* Alter Verbrauch war kleiner reservierte Menge
            ELSE.
              xvstat-unvbr = refe1 - zdm07m-bdmng.
            ENDIF.
* Keine Fortschreibung des ungeplanten Verbrauchs
          ELSE.
            xvstat-unvbr = 0.
          ENDIF.
          IF xmseg-shkzg = h.
            xmres-vnmng = xmres-vnmng + xmseg-menge.
          ELSE.
            xmres-vnmng = xmres-vnmng - xmseg-menge.
          ENDIF.
        ELSE.
          refe1 = xmres-vnmng - xmseg-menge.
* Der neue Verbrauch ist größer als die reservierte Menge, d.h. alles
* wird in den ungeplanten Verbrauch gebucht
          IF zdm07m-bdmng LT refe1.
            xvstat-unvbr = xmseg-menge.
          ELSE.
            DATA: refe2 TYPE f.
            refe2 = xmres-vnmng - zdm07m-bdmng.
* Der (alte) Verbrauch war größer als die reservierte Menge und wird
* aus dem ungeplanten Verbrauch voll ausgebucht
            IF refe2 GT 0.
              xvstat-unvbr = refe2.
* Der ungeplante Verbrauch  wird nicht fortgeschreiben
            ELSE.
              xvstat-unvbr = 0.
            ENDIF.
          ENDIF.
          IF xmseg-shkzg = h.
            xmres-vnmng = xmres-vnmng + xmseg-menge.
          ELSE.
            xmres-vnmng = xmres-vnmng - xmseg-menge.
          ENDIF.
        ENDIF.
        MODIFY xmres INDEX sy-tabix.
      ENDIF.
    WHEN u.
      xvstat-gsvbr = xmseg-menge.
      xvstat-unvbr = xmseg-menge.
  ENDCASE.
  IF xmseg-shkzg = s.
    xvstat-gsvbr = 0 - xvstat-gsvbr.
    xvstat-unvbr = 0 - xvstat-unvbr.
  ENDIF.
  IF ( zdm07m-kzvbl = minus AND NOT xmseg-xauto = x ) OR
     ( zdm07m-umkzv = minus AND xmseg-xauto = x ).
    xvstat-gsvbr = 0 - xvstat-gsvbr.
    xvstat-unvbr = 0 - xvstat-unvbr.
  ENDIF.
  xvstat-matnr = xmseg-matnr.
  xvstat-werks = xmseg-werks.
  xvstat-datum = xmkpf-budat.
  xvstat-perkz = zdm07m-perkz.
  xvstat-perim = zdm07m-perim.
  xvstat-lgort = xmseg-lgort.                               "ALRK090490
  xvstat-sobkz = xmseg-sobkz.                               "ALRK090490
  xvstat-emlif = xmseg-emlif.                               "ALRK090490
  APPEND xvstat.
  xvm07m-gsvbr = xvstat-gsvbr.
  xvm07m-unvbr = xvstat-unvbr.
  MODIFY xvm07m INDEX xmseg-zeile.

ENDFORM.