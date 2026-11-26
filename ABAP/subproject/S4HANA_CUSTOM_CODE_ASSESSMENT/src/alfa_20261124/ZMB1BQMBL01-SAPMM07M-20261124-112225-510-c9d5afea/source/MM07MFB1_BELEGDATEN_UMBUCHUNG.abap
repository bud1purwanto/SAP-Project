*eject
*----------------------------------------------------------------------*
*               FORM BELEGDATEN_UMBUCHUNG                              *
*----------------------------------------------------------------------*
*    Die Daten für den Beleg bei Transaktion MBSU werden gesetzt.
*----------------------------------------------------------------------*
FORM belegdaten_umbuchung.
  DATA: h_mseg LIKE mseg.
  h_mseg = mseg.
  CLEAR mseg.
  mseg-kzbew = h_mseg-kzbew.
  mseg-bwart = h_mseg-bwart.
  mseg-matnr = h_mseg-matnr.
  mseg-werks = h_mseg-werks.
  IF NOT h_mseg-umwrk IS INITIAL.
    mseg-werks = h_mseg-umwrk.
  ENDIF.
  IF NOT h_mseg-umlgo IS INITIAL.
    mseg-lgort = h_mseg-umlgo.
  ENDIF.
  IF mseg-lgort IS INITIAL.
    mseg-lgort = rm07m-lgort.
  ENDIF.
  mseg-charg = h_mseg-charg.
  IF NOT h_mseg-umcha IS INITIAL.
    mseg-charg = h_mseg-umcha.
  ENDIF.
  mseg-erfmg = h_mseg-erfmg.
  mseg-erfme = h_mseg-erfme.
  mseg-kunnr = h_mseg-kunnr.
  mseg-ebeln = h_mseg-ebeln.
  mseg-ebelp = h_mseg-ebelp.

* In case of 'place in storage'-functionality set
* - SOBKZ
* - LIFNR / KUNNR for
* subcontractor and customer consignment in-transfer stocks
  IF gv_mm_om1_sfws_sc_active = cl_ops_switch_check=>switch_active_true.
    IF fcausw-fcode = fcod-su
     AND t156-bustr = bustr_30c.
      mseg-sobkz = h_mseg-sobkz.
      mseg-lifnr = h_mseg-lifnr.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT BELEGDATEN_UMBUCHUNG_02 SPOTS ES_BELEGDATEN_UMBUCHUNG INCLUDE BOUND .

  IF brazil = 'X'.
*   Take MWSKZ from original doc.   > Will be mapped against
*   table T007_IT later
    mseg-mwskz = h_mseg-mwskz.
  ENDIF.
ENHANCEMENT-POINT BELEGDATEN_UMBUCHUNG_01 SPOTS ES_BELEGDATEN_UMBUCHUNG INCLUDE BOUND.

ENDFORM.                    "BELEGDATEN_UMBUCHUNG