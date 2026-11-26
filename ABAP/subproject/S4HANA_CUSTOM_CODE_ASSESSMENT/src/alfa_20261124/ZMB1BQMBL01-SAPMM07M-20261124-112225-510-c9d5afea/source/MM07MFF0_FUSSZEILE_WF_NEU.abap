*eject
*---------------------------------------------------------------------*
*        FORM FUSSZEILE_WF_NEU                                        *
*---------------------------------------------------------------------*
*        Die Fusszeile für die Transaktion Wareneingang zum           *
*        Fertigungsauftrag bei Neueingabe des Auftrags wird bearbeitet*
*---------------------------------------------------------------------*
FORM fusszeile_wf_neu.
  CHECK t158-trtyp = h.
  CHECK fcausw-xneup NE space OR fcausw-xselp NE space.
  IF NOT rm07m-aufnr IS INITIAL.
    CLEAR dm07m.
    CLEAR vm07m.
    PERFORM bewegungsart_pruefen(sapfm07m) USING rm07m-bwart
                                                 space.
    DATA: lfbja LIKE mseg-lfbja,
          lfbnr LIKE mseg-lfbnr,
          lfpos LIKE mseg-lfpos.
    PERFORM pps_auftrag_pruefen USING rm07m-aufnr
                                      rm07m-aufps
                                      mkpf-budat.
    PERFORM pps_auftrag_uebernehmen USING rm07m-aufnr
                                          rm07m-aufps
                                          rm07m-werks.
  ENDIF.
  CLEAR: rm07m-aufnr, rm07m-aufps.
ENDFORM.