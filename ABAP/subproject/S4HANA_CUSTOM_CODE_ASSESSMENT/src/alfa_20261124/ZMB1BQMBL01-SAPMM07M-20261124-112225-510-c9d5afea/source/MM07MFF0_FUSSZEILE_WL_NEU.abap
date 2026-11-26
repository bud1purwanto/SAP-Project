*eject
*---------------------------------------------------------------------*
*        FORM FUSSZEILE_WL_NEU                                        *
*---------------------------------------------------------------------*
*        Positionen ohne Bestellung werden WE gebucht:                *
*        zum Lieferschein (alte VL07 ...) 15.07.96                    *
*---------------------------------------------------------------------*
FORM fusszeile_wl_neu.
  CHECK fcausw-xneup NE space OR fcausw-xselp NE space.
  CLEAR fuss.
  MOVE-CORRESPONDING wueb TO fuss.
  DATA: kzbew LIKE rm07m-kzbew.
  kzbew = rm07m-kzbew.
  rm07m-kzbew = fuss-kzbew.
  MOVE-CORRESPONDING fuss TO mseg.
  MOVE-CORRESPONDING fuss TO vm07m.
  MOVE-CORRESPONDING fuss TO dm07m.
  PERFORM fusszeile_bew_pruefen.
  MOVE-CORRESPONDING mseg TO fuss.
  MOVE-CORRESPONDING vm07m TO fuss.
  MOVE-CORRESPONDING dm07m TO fuss.
  rm07m-kzbew = kzbew.
  IF fuss-lgort IS INITIAL.
    fuss-lgort = rm07m-lgort.
  ENDIF.
  fuss-xlort = x.
  fuss-xchar = x.
  fuss-fcode = fcod-np.
  fuss-xselp = fcausw-xselp.
  fuss-xsels = fcausw-xselp.
  IF fcausw-xlist IS INITIAL.
    fuss-xselk = x.
    fuss-xhell = x.
  ELSE.
    fuss-xselk = t158-xsele.
  ENDIF.
  f_zeile = f_zeile + 1.
  fuss-zeile = f_zeile + m_zeile.
  APPEND fuss.
ENDFORM.