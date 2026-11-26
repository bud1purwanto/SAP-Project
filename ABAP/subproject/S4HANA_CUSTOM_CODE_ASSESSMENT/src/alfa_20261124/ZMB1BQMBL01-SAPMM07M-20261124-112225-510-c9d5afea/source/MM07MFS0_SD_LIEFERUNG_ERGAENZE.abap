*----------------------------------------------------------------------*
*       Form  SD_LIEFERUNG_ERGAENZEN_IM
*----------------------------------------------------------------------*
*       Weitere Daten zur Erzeugung einer Lieferung:
*       Hier werden nur Felder gefüllt, die für den Fall Bestandsführung
*       OHNE Komponente relevant sind.
*----------------------------------------------------------------------*
form sd_lieferung_ergaenzen_im changing l_xlk03 like komdlgn.

  data: ptext like dfies-scrtext_m,
        vsbed like knvv-vsbed.

*-------- Lieferant und Kunde/Warenempfänger ermitteln ----------------*
  if not t001w-werks = xmseg-werks.
    perform werk_name_lesen(sapfm07m) using mseg-werks.
  endif.
  l_xlk03-werks = xmseg-werks.                             "note 159512
* Lieferant:
  l_xlk03-lifnr = xmseg-lifnr.         "1.Stufe: Extern eingegeben
  if l_xlk03-lifnr is initial.
    l_xlk03-lifnr = xvm07m-sdlif.      "2.Stufe: Aus der T001L
  endif.
  if l_xlk03-lifnr is initial.
    l_xlk03-lifnr = t001w-lifnr.       "3.Stufe: Aus der T001W
  endif.
  if l_xlk03-lifnr is initial.
    perform get_field using 'KNA1' 'LIFNR' ptext.
    message e279 with ptext.
  endif.

  if not vm07m-ekorg is initial.                           "v_n_1030821
    CALL FUNCTION 'VENDOR_MASTER_DATA_SELECT_12'
         EXPORTING
              PI_LIFNR       = l_xlk03-lifnr
              PI_EKORG       = vm07m-ekorg
         IMPORTING
              PE_LFM1        = lfm1
         EXCEPTIONS
              NO_ENTRY_FOUND = 1
              OTHERS         = 2.

    if sy-subrc = 0.
      l_xlk03-vsbed = lfm1-vsbed.
    endif.
  endif.                                                   "^_n_1030821

  if l_xlk03-dlvtp = 'ID'.                                 "v_n_1149708
    clear l_xlk03-vkorg.
    clear l_xlk03-vtweg.
    clear l_xlk03-spart.
    l_xlk03-kzazu = 'X'.                                     "n_1257743
  endif.                                                   "^_n_1149708

* In case of 'Inbound Delivery':
* Only LIFNR is obligatory to create the delivery. The other fields are
* obligatory for an 'Outbound Delivery' ( delivery type: RL, TP or OD).
  check l_xlk03-dlvtp <> 'ID'.

* Kunde:
  IF vm07m-xstor = '1'.            " for Return delivery 1129317
    l_xlk03-kunwe = vm07m-kunwe.   " PO is checked first 1129317
    IF l_xlk03-kunwe IS initial.                        "1129317
      l_xlk03-kunwe = xmseg-kunnr.                      "1129317
    ENDIF.                                              "1129317
    IF xmseg-ebeln IS INITIAL OR NOT                   "v1641106
       dm07m-reswk IS INITIAL. "only if no PO or if STO involved
      IF l_xlk03-kunwe IS INITIAL.
         l_xlk03-kunwe = xvm07m-sdkun.    "3.Stufe: Aus der T001L
      ENDIF.
      IF l_xlk03-kunwe IS INITIAL.
         l_xlk03-kunwe = t001w-kunnr.     "4.Stufe: Aus der T001W
      ENDIF.
    ENDIF.                                             "^1641106
  ELSE.                                                 "1129317
    l_xlk03-kunwe = xmseg-kunnr.       "1.Stufe: Extern eingegeben
  if l_xlk03-kunwe is initial.
    l_xlk03-kunwe = vm07m-kunwe.            "2.Stufe: Aus der Bestellung
  ENDIF.                                    "         (->MBRL ohne HUM)
"   shifted into else to avoid conflicts                "v1641106
    IF l_xlk03-kunwe IS INITIAL.
    l_xlk03-kunwe = xvm07m-sdkun.           "3.Stufe: Aus der T001L
  ENDIF.
  IF l_xlk03-kunwe IS INITIAL.
    l_xlk03-kunwe = t001w-kunnr.            "4.Stufe: Aus der T001W
    ENDIF.                                             "^1641106
  ENDIF.                                                "1129317
  if l_xlk03-kunwe is initial.
    perform get_field using 'LFA1' 'KUNNR' ptext.
    message e279 with ptext.
  endif.


*-------- Vertriebsorganisationsdaten ---------------------------------*
* Verkaufsorganisation
  l_xlk03-vkorg = xvm07m-vkorg.        "1.Stufe: Aus der T001L
  if l_xlk03-vkorg is initial.
    l_xlk03-vkorg = t001w-vkorg.       "2.Stufe: Aus der T001W
  endif.
  if l_xlk03-vkorg is initial.
    perform get_field using 'VM07M' 'VKORG' ptext.
    message e279 with ptext.
  endif.
* Vertriebsweg
  l_xlk03-vtweg = xvm07m-vtweg.        "1.Stufe: Aus der T001L
  if l_xlk03-vtweg is initial.
    l_xlk03-vtweg = t001w-vtweg.       "2.Stufe: Aus der T001W
  endif.
  if l_xlk03-vtweg is initial.
    perform get_field using 'VM07M' 'VTWEG' ptext.
    message e279 with ptext.
  endif.
* Sparte
  l_xlk03-spart = old_spart.           "1.Stufe: Aus der T001L
* l_xlk03-spart = xvm07m-spart.       "alte Logik (Sparte aus Mat.stamm)
  if l_xlk03-spart is initial.
    l_xlk03-spart = t001w-spart.       "2.Stufe: Aus der T001W
  endif.
  if l_xlk03-spart is initial.         "3.Stufe: Aus Mat.stamm
    l_xlk03-spart = xvm07m-spart.
  endif.
  if l_xlk03-spart is initial.
    perform get_field using 'KNVV' 'SPART' ptext.
    message e279 with ptext.
  endif.
* Versandbedingungen
  if not l_xlk03-kunwe = knvv-kunnr.   "1.Stufe: Aus Kundenstamm
* start insert note 159512
* get common division and distribution channel if there are any
    if l_xlk03-vkorg ne tvta-vkorg or
       l_xlk03-vtweg ne tvta-vtweg or
       l_xlk03-spart ne tvta-spart.
      move: l_xlk03-vkorg to tvta-vkorg,
            l_xlk03-vtweg to tvta-vtweg,
            l_xlk03-spart to tvta-spart.
      select single * from tvta where vkorg eq tvta-vkorg
                                and   vtweg eq tvta-vtweg
                                and   spart eq tvta-spart.
      if sy-subrc ne 0.
* no common division and distr. channel defined; take over original ones
        tvta-vtwku = l_xlk03-vtweg.
        tvta-spaku = l_xlk03-spart.
      endif.
    endif.
    select single vsbed
                  into vsbed    from knvv
                  where kunnr = l_xlk03-kunwe
                  and   vkorg = l_xlk03-vkorg
                  and   vtweg = tvta-vtwku
                  and   spart = tvta-spaku.
* end insert note 159512
*   SELECT SINGLE vsbed                                 "note 159512
*                 INTO vsbed    FROM knvv               "note 159512
*                 WHERE kunnr = l_xlk03-kunwe           "note 159512
*                 AND   vkorg = l_xlk03-vkorg           "note 159512
*                 AND   vtweg = l_xlk03-vtweg           "note 159512
*                 AND   spart = l_xlk03-spart.          "note 159512
    if not sy-subrc is initial.
      perform get_field using 'LFA1' 'KUNNR' ptext.
      message e279 with ptext.
    endif.
    knvv-vsbed = vsbed.
  endif.

  l_xlk03-vsbed = knvv-vsbed.                                  "n_603349

  call function 'VERSANDSTELLE_ERMITTELN'
       exporting
            ladgr   = xvm07m-ladgr
            lgort   = space
            vsbed   = knvv-vsbed
            vstel_i = space
            werks   = l_xlk03-werks
       importing
            vstel   = l_xlk03-vstel
       exceptions
            others  = 4.

  if not sy-subrc is initial.
    if xvm07m-ladgr is initial.
      perform get_field using 'VM07M' 'LADGR' ptext.
      message e279 with ptext.
    elseif knvv-vsbed is initial.
      if knvv-vsbed is initial.
        perform get_field using 'KNVV' 'VSBED' ptext.
        message e279 with ptext.
      endif.
    endif.
  endif.

  if l_xlk03-vstel is initial.
    l_xlk03-vstel = xvm07m-vstel.      "2.Stufe: Aus der T001L
  endif.
  if l_xlk03-vstel is initial.
    l_xlk03-vstel = t001w-vstel.       "3.Stufe: Aus der T001W
  endif.
  if l_xlk03-vstel is initial.
    perform get_field using 'TVST' 'VSTEL' ptext.
    message e279 with ptext.
  endif.

* Not necessary anymore:
*  * ----- Wird Bezug auf eine WE-relevante Anlieferung genommen?---
*  if not zdm07m-vbeln_vl is initial and t156n-fcode ne fcod-rl.
*    upd_anlief = x.
*  endif.

endform.                               " SD_LIEFERUNG_ERGAENZEN_IM