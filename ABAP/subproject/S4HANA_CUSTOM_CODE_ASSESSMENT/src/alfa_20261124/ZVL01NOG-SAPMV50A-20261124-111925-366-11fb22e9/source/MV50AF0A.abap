***********************************************************************
*  Unterroutinen RV-Versand alphabetisch sortiert:                    *
*  -----------------------------------------------                    *
*  Buchstabe A:                                                       *
*                                                                     *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM ANLIEFERTERMIN_PRUEFEN                                   *
*---------------------------------------------------------------------*
*       Bei Angabe eines anderen Liefertermins bzw. einer Anliefer-   *
*       zeit, wird geprüft, ob der Kunde an diesem Tag bzw. zu        *
*       der angegebenen Zeit Ware annimmt.                            *
*---------------------------------------------------------------------*
form anliefertermin_pruefen.

  data: da_feiertag,
        da_termin like likp-lfdat,
        da_wochentag,
        da_extdatum1(10),
        da_extdatum(10).

* Lieferdatum in der Vergangenheit?
  if likp-lfdat ne *likp-lfdat and
     likp-lfdat lt syst-datum.
    write likp-lfdat to da_extdatum1 dd/mm/yyyy.
    message w074 with da_extdatum1.
  endif.

* Arbeitstag beim Kunden ?
  if kuwev-knfak ne space.

    call function 'DATE_CONVERT_TO_FACTORYDATE'
      exporting
        correct_option             = '+'
        date                       = likp-lfdat
        factory_calendar_id        = kuwev-knfak
      importing
        date                       = da_termin
        workingday_indicator       = da_feiertag
      exceptions
        date_after_range           = 01
        date_before_range          = 02
        date_invalid               = 03
        factory_calendar_not_found = 04
        others                     = 05.

    case sy-subrc.
      when 1.
        write likp-lfdat to da_extdatum dd/mm/yyyy.
        message e098 with da_extdatum kuwev-knfak.
      when 2.
        write likp-lfdat to da_extdatum dd/mm/yyyy.
        message e097 with da_extdatum kuwev-knfak.
      when 3. message e168 with da_extdatum.
      when 4. message e099 with kuwev-knfak.
      when 5. message e209.
    endcase.


    if da_feiertag ne space.
      write likp-lfdat to da_extdatum1 dd/mm/yyyy.
      write da_termin  to da_extdatum dd/mm/yyyy.
      message w070 with da_extdatum1 da_extdatum.
    endif.

  endif.

* Warenannahmezeit angegeben?

  check likp-lfuhr gt 0.
  if likp-lfdat ne *likp-lfdat.
    perform anlieferzeit_anzeigen.
  endif.

* Warenannahme nur an bestimmten Zeiten vorgesehen ?
  if kuwev-moab1 > 0 or
     kuwev-mobi1 > 0 or
     kuwev-moab2 > 0 or
     kuwev-mobi2 > 0 or
     kuwev-diab1 > 0 or
     kuwev-dibi1 > 0 or
     kuwev-diab2 > 0 or
     kuwev-dibi2 > 0 or
     kuwev-miab1 > 0 or
     kuwev-mibi1 > 0 or
     kuwev-miab2 > 0 or
     kuwev-mibi2 > 0 or
     kuwev-doab1 > 0 or
     kuwev-dobi1 > 0 or
     kuwev-doab2 > 0 or
     kuwev-dobi2 > 0 or
     kuwev-frab1 > 0 or
     kuwev-frbi1 > 0 or
     kuwev-frab2 > 0 or
     kuwev-frbi2 > 0 or
     kuwev-saab1 > 0 or
     kuwev-sabi1 > 0 or
     kuwev-saab2 > 0 or
     kuwev-sabi2 > 0 or
     kuwev-soab1 > 0 or
     kuwev-sobi1 > 0 or
     kuwev-soab2 > 0 or
     kuwev-sobi2 > 0.

* Warenannahme an diesem Tag vorgesehen ?
    call function 'DATE_COMPUTE_DAY'
      exporting
        date = likp-lfdat
      importing
        day  = da_wochentag.

    case da_wochentag.
      when char1.
        perform anlieferzeit_pruefen using likp-lfuhr
                                           kuwev-moab1
                                           kuwev-mobi1
                                           kuwev-moab2
                                           kuwev-mobi2.
      when char2.
        perform anlieferzeit_pruefen using likp-lfuhr
                                           kuwev-diab1
                                           kuwev-dibi1
                                           kuwev-diab2
                                           kuwev-dibi2.
      when char3.
        perform anlieferzeit_pruefen using likp-lfuhr
                                           kuwev-miab1
                                           kuwev-mibi1
                                           kuwev-miab2
                                           kuwev-mibi2.
      when char4.
        perform anlieferzeit_pruefen using likp-lfuhr
                                           kuwev-doab1
                                           kuwev-dobi1
                                           kuwev-doab2
                                           kuwev-dobi2.
      when char5.
        perform anlieferzeit_pruefen using likp-lfuhr
                                           kuwev-frab1
                                           kuwev-frbi1
                                           kuwev-frab2
                                           kuwev-frbi2.
      when char6.
        perform anlieferzeit_pruefen using likp-lfuhr
                                           kuwev-saab1
                                           kuwev-sabi1
                                           kuwev-saab2
                                           kuwev-sabi2.
      when char7.
        perform anlieferzeit_pruefen using likp-lfuhr
                                           kuwev-soab1
                                           kuwev-sobi1
                                           kuwev-soab2
                                           kuwev-sobi2.

    endcase.
  endif.

endform.                    "anliefertermin_pruefen
*eject


*---------------------------------------------------------------------*
*       FORM ANLIEFERZEIT_ANZEIGEN                                    *
*---------------------------------------------------------------------*
*       Gemäß Liefertermin wird die zugehörige Anlieferzeit zur       *
*       Anzeige bestimmt.                                             *
*---------------------------------------------------------------------*
form anlieferzeit_anzeigen.

  data:   da_wochentag.

  check likp-lfdat ne 0.

  call function 'DATE_COMPUTE_DAY'
    exporting
      date = likp-lfdat
    importing
      day  = da_wochentag.

  case da_wochentag.
* Montag
    when char1.
      rv50a-timab1 = kuwev-moab1.
      rv50a-timbi1 = kuwev-mobi1.
      rv50a-timab2 = kuwev-moab2.
      rv50a-timbi2 = kuwev-mobi2.
      rv50a-wochentag = text-020.
* Dienstag
    when char2.
      rv50a-timab1 = kuwev-diab1.
      rv50a-timbi1 = kuwev-dibi1.
      rv50a-timab2 = kuwev-diab2.
      rv50a-timbi2 = kuwev-dibi2.
      rv50a-wochentag = text-021.
* Mittwoch
    when char3.
      rv50a-timab1 = kuwev-miab1.
      rv50a-timbi1 = kuwev-mibi1.
      rv50a-timab2 = kuwev-miab2.
      rv50a-timbi2 = kuwev-mibi2.
      rv50a-wochentag = text-022.
* Donnerstag
    when char4.
      rv50a-timab1 = kuwev-doab1.
      rv50a-timbi1 = kuwev-dobi1.
      rv50a-timab2 = kuwev-doab2.
      rv50a-timbi2 = kuwev-dobi2.
      rv50a-wochentag = text-023.
* Freitag
    when char5.
      rv50a-timab1 = kuwev-frab1.
      rv50a-timbi1 = kuwev-frbi1.
      rv50a-timab2 = kuwev-frab2.
      rv50a-timbi2 = kuwev-frbi2.
      rv50a-wochentag = text-024.
* Samstag
    when char6.
      rv50a-timab1 = kuwev-saab1.
      rv50a-timbi1 = kuwev-sabi1.
      rv50a-timab2 = kuwev-saab2.
      rv50a-timbi2 = kuwev-sabi2.
      rv50a-wochentag = text-025.
* Sonntag
    when char7.
      rv50a-timab1 = kuwev-soab1.
      rv50a-timbi1 = kuwev-sobi1.
      rv50a-timab2 = kuwev-soab2.
      rv50a-timbi2 = kuwev-sobi2.
      rv50a-wochentag = text-026.
  endcase.

endform.                    "anlieferzeit_anzeigen
*eject


*---------------------------------------------------------------------*
*       FORM ANLIEFERZEIT_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Prüfen ob die Anlieferzeit zu den Warenannahmezeiten des      *
*       Warenempfängers passt.                                        *
*       Unterroutine der Form ANLIEFERTERMIN_PRUEFEN.                 *
*---------------------------------------------------------------------*
form anlieferzeit_pruefen using us_ezeit like likp-lfuhr
                                us_ab1   like kuwev-moab1
                                us_bi1   like kuwev-mobi1
                                us_ab2   like kuwev-moab2
                                us_bi2   like kuwev-mobi2.

  data: da_ab1(8),
        da_bi1(8),
        da_ab2(8),
        da_bi2(8).

  write: us_ab1 to da_ab1 using edit mask '__:__:__',
         us_bi1 to da_bi1 using edit mask '__:__:__',
         us_ab2 to da_ab2 using edit mask '__:__:__',
         us_bi2 to da_bi2 using edit mask '__:__:__'.

  if ( us_ezeit < us_ab1 or us_ezeit > us_bi1 ) and
     ( us_ezeit < us_ab2 or us_ezeit > us_bi2 ).
    if ( us_ab1 > 0 or us_bi1 > 0 ) and
       ( us_ab2 > 0 or us_bi2 > 0 ).
      message w071 with da_ab1(5) da_bi1(5)
                        da_ab2(5) da_bi2(5).
    endif.
    if ( us_ab1 > 0 or us_bi1 > 0 ) and
         us_ab2 = 0 and us_bi2 = 0.
      message w072 with da_ab1(5) da_bi1(5).
    endif.
    if ( us_ab2 > 0 or us_bi2 > 0 ) and
         us_ab1 = 0 and us_bi1 = 0.
      message w072 with da_ab2(5) da_bi2(5).
    endif.
    if us_ab2 = 0 and us_bi2 = 0 and
       us_ab1 = 0 and us_bi1 = 0.
      message w073 with da_ab2(5) da_bi2(5).
    endif.
  endif.
endform.                    "anlieferzeit_pruefen
*eject


*---------------------------------------------------------------------*
*       FORM AUFTRAG_Doppelt_referieren                               *
*---------------------------------------------------------------------*
*       Im Falle des Lieferplans ist eine weitere Referenz auf        *
*       denselben Lieferplan nicht zulässig, weil für die Liefer-     *
*       fortschrittszahl die Statistik nicht im Dialog gepflegt       *
*       wird.                                                         *
*---------------------------------------------------------------------*
form auftrag_doppelt_referieren.

  sy-subrc = 0.
* loop at xvbuk where vbeln = lv50c-vbeln.   "DEL zu 30F RM CSP 1225918
*   exit.                                    "DEL zu 30F RM CSP 1225918
* endloop.                                   "DEL zu 30F RM CSP 1225918
* if sy-subrc = 0.                           "DEL zu 30F RM CSP 1225918
  loop at xlips where abart ca abart_abruf and
                      vgbel eq lv50c-vbeln.
    message e454.
    exit.
  endloop.

*    verhindern doppelter uepos-Umsetzungen + Korrelationen
  refresh posnr_umsetzung.
  refresh alips.
  loop at xlips where updkz ne updkz_delete.
    alips-posnr = xlips-posnr.
    append alips.
*   Fill LIKP_DAT to ensure correct determination of deadlines. The
*   current dates of the delivery header are taken as a basis for
*   rescheduling if not scheduling lines are present for the preceding
*   sales order items
    if not xlips-vgbel is initial.                          "470
      read table likp_dat with key vbeln = xlips-vgbel
                                   posnr = xlips-vgpos
                          binary search
                          transporting no fields.
      if sy-subrc ne 0.
        clear likp_dat.
        likp_dat-vbeln_vl = likp-vbeln.
        likp_dat-mandt    = likp-mandt.
        likp_dat-vbeln    = xlips-vgbel.
        likp_dat-posnr    = xlips-vgpos.
        likp_dat-etenr    = '0000'.
        likp_dat-edatu    = likp-lfdat.
        likp_dat-ezeit    = likp-lfuhr.
        likp_dat-mbdat    = likp-kodat.
        likp_dat-mbuhr    = likp-kouhr.
        likp_dat-tddat    = likp-tddat.
        likp_dat-tduhr    = likp-tduhr.
        likp_dat-lddat    = likp-lddat.
        likp_dat-lduhr    = likp-lduhr.
        likp_dat-wadat    = likp-wadat.
        likp_dat-wauhr    = likp-wauhr.
        insert likp_dat index sy-tabix.
      endif.
    endif.
  endloop.
  sort alips.

endform.                    "auftrag_doppelt_referieren
*eject


*---------------------------------------------------------------------*
*       FORM AUFTRAG_ENTSPERREN                                       *
*---------------------------------------------------------------------*
*       Der Auftrag wird komplett entsperrt                           *
*---------------------------------------------------------------------*
form auftrag_entsperren using us_vbeln.

  check: t180-trtyp ne chara,
         not us_vbeln is initial.

  call function 'DEQUEUE_EVVBAKE'
    exporting
      vbeln = us_vbeln.

endform.                    "auftrag_entsperren
*eject


*---------------------------------------------------------------------*
*       FORM AUFTRAG_NEXT_REFERIEREN                                  *
*---------------------------------------------------------------------*
*       Die Lieferung wird um einen weiteren Auftrag ergänzt.         *
*---------------------------------------------------------------------*
form auftrag_next_referieren.

  data: ar_ergebnis like sy-subrc,
        ar_lines_o  like sy-tfill,
        ar_lines_n  like sy-tfill.

  data: lf_get_ship_to type c.                                    "50a
  data: lf_get_vstrm type c,                                  "n_711102
        lf_lines like sy-tfill.

  data: lt_vbap type table of vbapvb with header line.       "v_n_938285
  field-symbols: <ls_vbapvb> type vbapvb,
                 <ls_lipsvb> type lipsvb.                    "^_n_938285

  statics: begin of lt_lock occurs 0,
             vbeln like vbak-vbeln,
           end of lt_lock.

* Processing is terminated by the user
  if   fcode(4) = fcode_abbrechen                           "46A BEY
    or fcode(4) = fcode_ende.
*   Release locks for all orders that have been blocked but not copied
    loop at lt_lock.
      call function 'DEQUEUE_EVVBAKE'
        exporting
          vbeln    = lt_lock-vbeln
          _collect = 'X'.
    endloop.
    if sy-subrc eq 0.
      call function 'FLUSH_ENQUEUE'
        exceptions
          foreign_lock   = 0
          system_failure = 0
          others         = 0.
    endif.
    set screen 0.
    exit.
  endif.
* Error log is displayed while pop up remains active
  if   fcode(4) = fcode_fehlerprotokoll.
    perform fcode_feaz.
    exit.
  endif.
* Auftragsnummer wird eingegeben
  if lv50c-vbeln ne space.

    if lv50c-abpos = space and
       lv50c-bipos = space.
      lv50c-abpos = posnr_low.
      lv50c-bipos = posnr_high.
    elseif lv50c-abpos ne space and                         "46A
           lv50c-bipos eq space.
      lv50c-bipos = posnr_high.
    elseif lv50c-abpos eq space and
           lv50c-bipos ne space.
      lv50c-abpos = posnr_low.
    else.
      if lv50c-abpos > lv50c-bipos .
        message e453 with lv50c-abpos lv50c-bipos.
        exit.
      endif.
    endif.

    if rv50a-spart is initial or                              "50a
       rv50a-vtweg is initial.
      lf_get_ship_to = charx.
    endif.

* leerer Lieferkopf                                          "n_711102
    describe table xlips lines lf_lines.
    if lf_lines = 0.
      lf_get_vstrm = charx.
    endif.

* merken Anzahl Zeilen im existenten Fehlerprotokoll
    describe table cvbfs lines ar_lines_o.

    v50agl-deliver_sales_order = charx.                     "n_546203

    perform xvbuk_pflegen(sapfv50k).
    perform auftrag_doppelt_referieren.

*   Block order only in case it is not yet done
    read table lt_lock with key vbeln = lv50c-vbeln.
    if sy-subrc ne 0.
      perform auftrag_sperren using lv50c-vbeln.
      lt_lock-vbeln = lv50c-vbeln.
      append lt_lock.
    endif.

    perform kopieren_beginn.
    perform kopieren_lesen_referenz(sapfv50c).

    if cvbak-vbeln is initial.                               "50A
      perform kopieren_beenden.                             "n_546203
      message e303 with lv50c-vbeln.
    endif.

    if not lf_get_ship_to is initial.                        "50a
      perform warenempfaenger_bereitstellen.
      clear lf_get_ship_to.
    endif.

    if not lf_get_vstrm is initial and                      "v_n_711102
       not cvbak-auart  is initial.
      perform tvak_select(sapmv50a) using cvbak-auart.
      likpd-vstrm = tvak-vstrm.
      likpd-trtrm = tvak-trtrm.
      xlikp-vstrm = tvak-vstrm.
      xlikp-trtrm = tvak-trtrm.
    endif.                                                  "^_n_711102

    v50agl-sammelgang = space.
    t185f-aktyp = charh.               "Setzen, weil ENT1 nicht änderbar
    perform vorlage_kopieren(sapfv50c) using ar_ergebnis.
*---------------------------------------------------------------------*
*  Das Ergebnis wird interpretiert:                                   *
*     0 : alles ok, es wurden Positionen erzeugt                      *
*     1 : Kopf ist nicht lieferfähig                                  *
*     2 : Kopf ist nicht zusammenführbar                              *
*     3 : keine Position war lieferfähig                              *
*     4 : keine Position paßte zum Rest                               *
*---------------------------------------------------------------------*
    case ar_ergebnis.
      when 0.                          "alles klar
      when 1.                          "Grundsätzlich nicht lieferbar
        perform kopieren_beenden.
        if sy-binpt ne space.                             "v_n_671231
          perform exit_from_batch_input.
          exit.
        endif.                                            "^_n_671231
        message e461.
      when 2.                          "paßt nicht zum Anfang, aufheben
        perform kopieren_beenden.
        if sy-binpt ne space.                             "v_n_671231
          perform exit_from_batch_input.
          MESSAGE i462 WITH tvcpl-auzus.
          exit.
        endif.                                            "^_n_671231
        message e462 with tvcpl-auzus.
      when 3.                  "keine Position lieferbar, Index erledig
        perform kopieren_beenden.
        if sy-binpt ne space.                             "v_n_671231
          perform exit_from_batch_input.
          exit.
        endif.                                            "^_n_671231
        message e067.
      when 4.                          "paßt nicht zum Anfang,
      when 5.                          "no reference header "50A
        perform kopieren_beenden.
        if sy-binpt ne space.                             "v_n_671231
          perform exit_from_batch_input.
          exit.
        endif.                                            "^_n_671231
        message e370.
    endcase.
*---------------------------------------------------------------------*
*    Freigeben Ressourcen
*---------------------------------------------------------------------*
    loop at xvbfa where updkz ne chard       and
                        vbtyp_v ca vbtyp_verk and
                        vbtyp_n = charx.
      exit.
    endloop.
    if sy-subrc = 0.
      loop at xlips assigning <ls_lipsvb>                   "v_n_938285
                     where updkz ne chard.
        read table cvbap assigning <ls_vbapvb> with key
                     vbeln = <ls_lipsvb>-vgbel
                     posnr = <ls_lipsvb>-vgpos.
        if sy-subrc is initial.
          append <ls_vbapvb> to lt_vbap.
        endif.
      endloop.
      PERFORM fcode_verp_gen_hu TABLES lt_vbap.             "^_n_938285
    endif.

    perform kopieren_endrunde.

    free: cvbap,
          cvbep,
          cvbkd,
          cvbpa.
*          CVBPM.

* ggf. Hinweis auf neue Zeilen im Fehlerprotokoll
    describe table cvbfs lines ar_lines_n.
    if ar_lines_n gt ar_lines_o.
      message s016.
    endif.
*    reset sperrtabelle
    refresh alips.

    if tvlk-averp = charx.
      perform automatic_packing_delivery using xlikp.
    endif.

* ein Auftrag muß mindestens angegeben werden
  else.
    if fcode(4) ne fcode_abbrechen.                         "46A BEY
      message e006.
    endif.
  endif.

* Release locks for all orders that could not be delivered successfully.
* The lock for the order that could be copied successfully is released
* during the posting procedure.
  loop at lt_lock where vbeln ne lv50c-vbeln.
    call function 'DEQUEUE_EVVBAKE'
      exporting
        vbeln    = lt_lock-vbeln
        _collect = 'X'.
  endloop.
  if sy-subrc eq 0.
    call function 'FLUSH_ENQUEUE'
      exceptions
        foreign_lock   = 0
        system_failure = 0
        others         = 0.
  endif.
  refresh lt_lock.

* Order items could be copied successfully: leave pop up and go back to
* the overview screen
  set screen 0.

endform.                    "auftrag_next_referieren
*eject


*---------------------------------------------------------------------*
*       FORM AUFTRAG_REFERIEREN                                       *
*---------------------------------------------------------------------*
*       Falls ein Geschäftsbeleg angegeben wird, so wird dieser       *
*        referiert, d.h. alle relevanten daten werden übvernommen     *
*       Ist dies nicht der Fall, wird angenommen, daß eine Stand-     *
*        alone-Lieferung beabsichtigt ist, und auf einem Window       *
*        werden Lieferart etc angefordert                             *
* note 75913 VL01 Abbruchmessage elim., wenn Vorgang nicht belieferbar
*---------------------------------------------------------------------*
form auftrag_referieren.

  data: ar_ergebnis like sy-subrc,
        ar_lines_o  like sy-tfill,
        ar_lines_n  like sy-tfill.
  data: ar_lv50c like lv50c,
        ar_vstel like likp-vstel.

  data: lt_vbap type table of vbapvb with header line.       "v_n_631193
  field-symbols: <ls_vbapvb> type vbapvb,
                 <ls_lipsvb> type lipsvb.                    "^_n_631193

  data: lf_subrc like sy-subrc,                                "n_909051
        lf_xclientind TYPE c.                                  "n_909051

  CHECK fcode(4) NE fcode_fehlerprotokoll   "46A BEY
    and fcode(4) ne fcode_abbrechen
    and fcode(4) ne fcode_ende.
* Auftragsnummer wird eingegeben
  if lv50c-vbeln ne space.

*    Lieferart vorgeben
    if fcode(4) = 'LIAR'.                                   "46A BEY
      call screen 103
           starting at 10 05
           ending   at 65 13.
      if t180-bldgr eq gc_new_dialog_outb
         or t180-bldgr eq gc_new_dialog_inb.
        fcode = 'OVER_T'.
      else.
        fcode = tvlk-uevor.
        if fcode = space.
          fcode = fcode_gleiche_seite.
        endif.
      endif.
    endif.


    if v50agl-sammelgang ne charx.
      refresh cvbfs. clear cvbfs.
    endif.

    if lv50c-abpos = space and
       lv50c-bipos = space.
      lv50c-abpos = posnr_low.
      lv50c-bipos = posnr_high.
    elseif lv50c-abpos ne space and                         "46A
           lv50c-bipos eq space.
      lv50c-bipos = posnr_high.
    elseif lv50c-abpos eq space and
           lv50c-bipos ne space.
      lv50c-abpos = posnr_low.
    else.
      if lv50c-abpos > lv50c-bipos .
        message e453 with lv50c-abpos lv50c-bipos.
        exit.
      endif.
    endif.

    v50agl-no_buffer_refresh = charx.                          "n_527241

    perform auftrag_sperren using lv50c-vbeln.
    perform kopieren_beginn.
    perform kopieren_lesen_referenz(sapfv50c).

ENHANCEMENT-POINT AUFTRAG_REFERIEREN_01 SPOTS ES_SAPMV50A.
    if cvbak-vbeln is initial.                               "50A
      message e303 with lv50c-vbeln.
    endif.
    describe table xlips lines ar_lines_o.
    v50agl-sammelgang = space.
    perform vorlage_kopieren(sapfv50c) using ar_ergebnis.

*---------------------------------------------------------------------*
*  Das Ergebnis wird interpretiert:                                   *
*     0 : alles ok, es wurden Positionen erzeugt                      *
*     1 : Kopf ist nicht lieferfähig                                  *
*     2 : Kopf ist nicht zusammenführbar                              *
*     3 : keine Position war lieferfähig                              *
*     4 : keine Position paßte zum Rest                               *
*---------------------------------------------------------------------*
    case ar_ergebnis.
      when 0.                          "alles klar
      when 1.                          "Grundsätzlich nicht lieferbar
        if ar_lines_o eq 0.
          ar_lv50c = lv50c.
          ar_vstel = likp-vstel.
          perform kopieren_beenden.
          perform text_memory_init.
          perform beleg_daten_init.
          lv50c = ar_lv50c.
          likp-vstel = ar_vstel.
        endif.
        if t180-bldgr eq gc_new_dialog_outb.
          if sy-binpt ne space.                             "v_n_606793
            perform exit_from_batch_input.
            exit.
          endif.
          message s461 display like 'E'.                    "^_n_606793
          if not cvbfs[] is initial.
            fcode = 'FEAZ_T'.
          else.
*           Transaktionsvarianten prüfen                    "v_n_909051
            CALL FUNCTION 'RS_HDSYS_GET_TC_VARIANT'
                 IMPORTING
                   TCVARIANT                     = gf_tcvariant
                   FLAG_CLIENT_INDEPENDENT       = lf_xclientind
                   RC                            = lf_subrc.
            if lf_subrc eq 2.
*          Transaktionsvariante aktiv
              CALL FUNCTION 'RS_HDSYS_CALL_TC_VARIANT'
                   EXPORTING
                     TCODE                           = sy-tcode
                     VARIANT                         = gf_tcvariant
                     I_FLAG_CLIENT_INDEPENDENT       = lf_xclientind
                     CALL_MODE                       = space.
            endif.
*           Ende Transaktionsvarianten prüfen               "^_n_909051
            fcode = fcode_gleiche_seite.
          endif.
          exit.
        else.
          if sy-binpt ne space.                             "v_n_651834
            perform exit_from_batch_input.
            exit.
          endif.                                            "^_n_651834
          message e461.
        endif.
      when 2.                          "paßt nicht zum Anfang, aufheben
        if ar_lines_o eq 0.
          ar_lv50c = lv50c.
          ar_vstel = likp-vstel.
          perform text_memory_init.
          perform beleg_daten_init.
          lv50c = ar_lv50c.
          likp-vstel = ar_vstel.
        endif.
        if t180-bldgr eq gc_new_dialog_outb.
          if sy-binpt ne space.                             "v_n_606793
            message e462 with tvcpl-auzus.
          endif.
          message s462 display like 'E'
                       with tvcpl-auzus.                    "^_n_606793
*         Transaktionsvarianten prüfen                      "v_n_909051
          CALL FUNCTION 'RS_HDSYS_GET_TC_VARIANT'
               IMPORTING
                 TCVARIANT                     = gf_tcvariant
                 FLAG_CLIENT_INDEPENDENT       = lf_xclientind
                 RC                            = lf_subrc.
          if lf_subrc eq 2.
*         Transaktionsvariante aktiv
            CALL FUNCTION 'RS_HDSYS_CALL_TC_VARIANT'
                 EXPORTING
                   TCODE                           = sy-tcode
                   VARIANT                         = gf_tcvariant
                   I_FLAG_CLIENT_INDEPENDENT       = lf_xclientind
                   CALL_MODE                       = space.
          endif.
*         Ende Transaktionsvarianten prüfen                 "^_n_909051
          fcode = fcode_gleiche_seite.
          exit.
        else.
          message e462 with tvcpl-auzus.
        endif.
      when 3.                          "keine Position lieferbar
        if ar_lines_o eq 0.
          ar_lv50c = lv50c.
          ar_vstel = likp-vstel.
          perform kopieren_beenden.
          perform text_memory_init.
          perform beleg_daten_init.
          lv50c = ar_lv50c.
          likp-vstel = ar_vstel.
        endif.
        if t180-bldgr eq gc_new_dialog_outb.
          if sy-binpt ne space.                             "v_n_606793
            perform exit_from_batch_input.
            exit.
          endif.
          message s461 display like 'E'.                    "^_n_606793
          if not cvbfs[] is initial.
            fcode = 'FEAZ_T'.
          else.
*           Transaktionsvarianten prüfen                    "v_n_909051
            CALL FUNCTION 'RS_HDSYS_GET_TC_VARIANT'
                 IMPORTING
                   TCVARIANT                     = gf_tcvariant
                   FLAG_CLIENT_INDEPENDENT       = lf_xclientind
                   RC                            = lf_subrc.
            if lf_subrc eq 2.
*          Transaktionsvariante aktiv
              CALL FUNCTION 'RS_HDSYS_CALL_TC_VARIANT'
                   EXPORTING
                     TCODE                           = sy-tcode
                     VARIANT                         = gf_tcvariant
                     I_FLAG_CLIENT_INDEPENDENT       = lf_xclientind
                     CALL_MODE                       = space.
            endif.
*           Ende Transaktionsvarianten prüfen               "^_n_909051
            fcode = fcode_gleiche_seite.
          endif.
          exit.
        else.
          if sy-binpt ne space.                             "v_n_651834
            perform exit_from_batch_input.
            exit.
          endif.                                            "^_n_651834
          message e067.
        endif.
      when 4.                          "paßt nicht zum Anfang,
        ar_lines_n = 0.
        loop at xlips transporting no fields
                      where updkz ne updkz_delete.
          add 1 to ar_lines_n.
        endloop.
        if ar_lines_n le ar_lines_o.   "neue Pos. erzeugt?
          if ar_lines_o eq 0.
            ar_lv50c = lv50c.
            ar_vstel = likp-vstel.
            perform text_memory_init.
            perform beleg_daten_init.
            lv50c = ar_lv50c.
            likp-vstel = ar_vstel.
            if t180-bldgr eq gc_new_dialog_outb.
              if sy-binpt ne space.                         "v_n_606793
                perform exit_from_batch_input.
                exit.
              endif.
              message s461 display like 'E'.                "^_n_606793
              if not cvbfs[] is initial.
                fcode = 'FEAZ_T'.
              else.
*               Transaktionsvarianten prüfen                "v_n_909051
                CALL FUNCTION 'RS_HDSYS_GET_TC_VARIANT'
                     IMPORTING
                       TCVARIANT                     = gf_tcvariant
                       FLAG_CLIENT_INDEPENDENT       = lf_xclientind
                       RC                            = lf_subrc.
                if lf_subrc eq 2.
*               Transaktionsvariante aktiv
                  CALL FUNCTION 'RS_HDSYS_CALL_TC_VARIANT'
                       EXPORTING
                         TCODE                           = sy-tcode
                         VARIANT                         = gf_tcvariant
                         I_FLAG_CLIENT_INDEPENDENT       = lf_xclientind
                         CALL_MODE                       = space.
                endif.
*               Ende Transaktionsvarianten prüfen           "^_n_909051
                fcode = fcode_gleiche_seite.
              endif.
              exit.
            else.
              if sy-binpt ne space.                         "v_n_651834
                perform exit_from_batch_input.
                exit.
              endif.                                        "^_n_651834
              message e067.
            endif.
          else.
            message w067.
          endif.
        endif.
    endcase.
    loop at xvbfa where updkz ne chard       and
                        vbtyp_v ca vbtyp_verk and
                        vbtyp_n = charx.
      exit.
    endloop.
    if sy-subrc = 0.
      loop at xlips assigning <ls_lipsvb>                   "v_n_631193
                     where updkz ne chard.
        read table cvbap assigning <ls_vbapvb> with key
                     vbeln = <ls_lipsvb>-vgbel
                     posnr = <ls_lipsvb>-vgpos.
        if sy-subrc is initial.
          append <ls_vbapvb> to lt_vbap.
        endif.
      endloop.
      PERFORM fcode_verp_gen_hu TABLES lt_vbap.             "^_n_631193
    endif.
    perform kopieren_endrunde.
*---------------------------------------------------------------------*
*    Freigeben Ressourcen
*---------------------------------------------------------------------*
    FREE:  CVBAP, CVBEP, CVBKD, CVBPA.
    CLEAR: CVBAP, CVBEP, CVBKD, CVBPA.                         "n_726632
*          CVBPM.

*---------------------------------------------------------------------*
*    Hinweis auf eventuell aufgetretene Probleme
*---------------------------------------------------------------------*
    read table cvbfs index 1.
    if sy-subrc eq 0.
      message s016.
    endif.
    if tvlk-averp eq charx.
      perform automatic_packing_delivery using xlikp.
    endif.

* Anlegen ohne Bezug auf Auftrag
  else.
    check fcode(4) ne fcode_lieferart_vorgeben.
    call screen 103
         starting at 10 05
         ending   at 65 13.
  endif.
  r185d-dataloss = charx.

endform.                    "auftrag_referieren
*eject


*---------------------------------------------------------------------*
*       FORM AUFTRAG_SPERREN                                          *
*---------------------------------------------------------------------*
*       Der AUFTRAG wird komplett und exklusiv gesperrt               *
*---------------------------------------------------------------------*
form auftrag_sperren using us_vbeln like vbak-vbeln.

  data: lf_ordernumber(10) type c,
        lf_tcode(5),                                          "n_602290
        lf_enque,                                             "n_602290
        lf_user like sy-msgv1.                                "n_557750

  check: t180-trtyp ne chara,
         not us_vbeln is initial.

* dialog function on del. due list -> do not enque if list is blocked
  IF sy-calld = 'X'.                                        "v_n_602290
    IMPORT d_tcode TO lf_tcode
           enque   TO lf_enque
           FROM MEMORY ID 'CALLING_TCODE'.
    CHECK lf_tcode(4) <> 'VL10' OR lf_enque <> '1'.           "n_651294
  ENDIF.                                                    "^_n_602290

  call function 'SD_SALES_DOCUMENT_ENQUEUE'
    exporting
      vbeln              = us_vbeln
      i_check_scenario_a = charx
    exceptions
      foreign_lock   = 2
      system_failure = 3.

  case sy-subrc.
    when 2.
      write us_vbeln to lf_ordernumber no-zero.
      write sy-msgv1 to lf_user.
      message e045 with lf_ordernumber lf_user.
    when 3.
      message e047.
  endcase.

endform.                    "auftrag_sperren
*eject
*---------------------------------------------------------------------*
*       FORM AUFTRAGGEBER_BEREITSTELLEN                               *
*---------------------------------------------------------------------*
*       Auftraggeber aus Partnertabelle lesen                         *
*       und Namen des Partners zur Verfügung stellen.                 *
*---------------------------------------------------------------------*
form auftraggeber_bereitstellen.

  loop at xvbpa where vbeln eq likp-vbeln
                and   parvw eq parvw_ag
                and updkz ne updkz_delete.
    exit.
  endloop.
  if sy-subrc ne 0.
    clear xvbpa.
    if not likp-kunag is initial.
      xvbpa-kunnr = likp-kunag.
    elseif not likp-kunnr is initial.
      xvbpa-kunnr = likp-kunnr.
    endif.
  endif.
  check not xvbpa-kunnr is initial.
  clear vtcom.
  vtcom-kunnr = xvbpa-kunnr.
  vtcom-vbeln = likp-vbeln.
  vtcom-vkorg = likp-vkorg.
  vtcom-vtweg = rv50a-vtweg.
  vtcom-spart = rv50a-spart.
  vtcom-aland = tvst-aland.                                  "n_671699
  vtcom-lland = kuwev-land1.                                 "n_671699
  vtcom-pargr = tvlk-pargr.
  vtcom-ablad = xvbpa-ablad.
  vtcom-noablad = charx.
  vtcom-msgkz = 'U'.

  call function 'VIEW_KUAG2'
    exporting
      comwa         = vtcom
    importing
      agwa          = kuagv
    exceptions
      error_message = 1
      others        = 2.

  if not xvbpa-adrnr is initial.
    perform auftraggeber_manuell_lesen.
  endif.

endform.                    "auftraggeber_bereitstellen
*---------------------------------------------------------------------*
*       FORM AUFTRAGGEBER_MANUELL_LESEN                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form auftraggeber_manuell_lesen.
  check not xvbpa-adrnr is initial.
* Lesen des entsprechenden manuellen Partners
  read table xvbadr with key xvbpa-adrnr binary search.
  if sy-subrc ne 0.                                         "50A
    perform sadr_select using xvbpa-adrnr
                              xvbpa-adrnp
                              xvbpa-adrda.
  endif.
* Versorgen der Auftraggeberdaten
  kuagv-kunnr = xvbpa-kunnr.                                   "n_875958
  kuagv-name1 = xvbadr-name1.
  kuagv-ort01 = xvbadr-ort01.
  kuagv-stras = xvbadr-stras.
  kuagv-pfach = xvbadr-pfach.
  kuagv-pstlz = xvbadr-pstlz.
  kuagv-pstl2 = xvbadr-pstl2.
  kuagv-spras = xvbadr-spras.
  kuagv-land1 = xvbadr-land1.
  kuagv-telf1 = xvbadr-telf1.
endform.                    "auftraggeber_manuell_lesen
*&---------------------------------------------------------------------*
*&      Form  ALW_NAME_ANZEIGEN
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form alw_name_anzeigen.

* Ist der Routenfahrplan leer, wird der Name gecleart
  if likp-aulwe is initial.
    clear valwt-bezei.
    exit.
  endif.

* Ist er nicht leer, wird der Name hinzugelesen
  call function 'SD_DEL_WAVE_GET_NAME'
    exporting
      alw                   = likp-aulwe
      vstel                 = likp-vstel
    importing
      alw_name              = valwt-bezei
    exceptions
      no_delivery_wave      = 1
      no_delivery_wave_text = 2
      name_not_found        = 3
      others                = 4.

* Hat das Lesen nicht geklappt, wird der Name gecleart
  if sy-subrc <> 0.
    clear valwt-bezei.
  endif.

endform.                               " ALW_NAME_ANZEIGEN

*&---------------------------------------------------------------------*
*&      Form  APPOINTMENT_CHECK
*&---------------------------------------------------------------------*
*       Prüfen ob torbelegungsrelevante Daten geändert wurden.
*       Gegebenenfalls wird eine Meldung ausgegeben, daß die Torbelegung
*       gelöscht wird.
*----------------------------------------------------------------------*
form appointment_check using lgnum like likp-lgnum
                             lgtor like likp-lgtor
                             lfdat like likp-lfdat
                             lfuhr like likp-lfuhr.
  data: flg_change(1).                 "Änderung
* Nur für Lieferavise und Grob-WE's
  check likp-vbtyp ca vbtyp_mmli.
* Nur wenn eine Torbelegung existiert
  check not ylikp-wadat is initial.
* Änderungen ?
* Lieferdatum
  if lfdat ne ylikp-lfdat.
    message i160(w#).
    flg_change = charx.
  endif.
* Anlieferuhrzeit
  if lfuhr ne ylikp-lfuhr.
    message i161(w#).
    flg_change = charx.
  endif.
* Tor
  if lgtor ne ylikp-lgtor.
    message i162(w#).
    flg_change = charx.
  endif.
* Lagernummer
  if lgnum ne ylikp-lgnum.
    message i163(w#).
    flg_change = charx.
  endif.
* Änderung durchgeführt ?
  if flg_change = charx.
    clear: likp-wadat, likp-wauhr.
  else.
* Rücknahme der Änderung
    if not ylikp-wadat is initial and
       likp-wadat is initial.
      likp-wadat = ylikp-wadat.
      likp-wauhr = ylikp-wauhr.
    endif.
  endif.
endform.                               " APPOINTMENT_CHECK

*---------------------------------------------------------------------*
*       FORM AUFRUFER_TRANSPORT                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form aufrufer_transport.
  gs_mhpar-glomd = gc_glomd-background.
  aufrufer = chart.
endform.                    "aufrufer_transport
*&---------------------------------------------------------------------*
*&      Form  assign_icon
*&---------------------------------------------------------------------*
*       Assigns icon with tooltip text to table fields with icons
*----------------------------------------------------------------------*
form assign_icon  using    is_xlips   type lipsvb
                           is_tvpodvb type tvpodvb
                  changing cs_rv50a   type rv50a.

  data: lf_quickinfo like icont-quickinfo.

  if is_xlips-chmult ne space.

*   Create icons for batch split indicator if not yet done
    if gf_icon_batch_plus is initial.
      lf_quickinfo = text-077.
      call function 'ICON_CREATE'
        exporting
          name                  = 'ICON_EXPAND'
          info                  = lf_quickinfo
          add_stdinf            = 'X'
        importing
          result                = gf_icon_batch_plus
        exceptions
          icon_not_found        = 1
          outputfield_too_short = 2
          others                = 3.
      if sy-subrc ne 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    endif.

    if gf_icon_batch_minus is initial.
      lf_quickinfo = text-078.
      call function 'ICON_CREATE'
        exporting
          name                  = 'ICON_COLLAPSE'
          info                  = lf_quickinfo
          add_stdinf            = 'X'
        importing
          result                = gf_icon_batch_minus
        exceptions
          icon_not_found        = 1
          outputfield_too_short = 2
          others                = 3.
      if sy-subrc ne 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    endif.

*   Assign icon to structure RV50A depending on the active view
    case is_xlips-chmult.
      when gc_batch_plus.
        cs_rv50a-chmult = gf_icon_batch_plus.
      when gc_batch_minus.
        cs_rv50a-chmult = gf_icon_batch_minus.
    endcase.
  else.
    cs_rv50a-chmult = space.
  endif.

  if is_tvpodvb-podmul ne space.
    if gf_icon_pod_one_line is initial.
      lf_quickinfo = text-079.
      call function 'ICON_CREATE'
        exporting
          name                  = 'ICON_ENTER_MORE'
          info                  = lf_quickinfo
          add_stdinf            = 'X'
        importing
          result                = gf_icon_pod_one_line
        exceptions
          icon_not_found        = 1
          outputfield_too_short = 2
          others                = 3.
      if sy-subrc ne 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    endif.

    if gf_icon_pod_mul_line is initial.
      lf_quickinfo = text-079.
      call function 'ICON_CREATE'
        exporting
          name                  = 'ICON_DISPLAY_MORE'
          info                  = lf_quickinfo
          add_stdinf            = 'X'
        importing
          result                = gf_icon_pod_mul_line
        exceptions
          icon_not_found        = 1
          outputfield_too_short = 2
          others                = 3.
      if sy-subrc ne 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    endif.

    if gf_icon_quantity_plus is initial.
      lf_quickinfo = text-080.
      call function 'ICON_CREATE'
        exporting
          name                  = 'ICON_POSITIVE'
          info                  = lf_quickinfo
          add_stdinf            = 'X'
        importing
          result                = gf_icon_quantity_plus
        exceptions
          icon_not_found        = 1
          outputfield_too_short = 2
          others                = 3.
      if sy-subrc ne 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    endif.

    if gf_icon_quantity_minus is initial.
      lf_quickinfo = text-081.
      call function 'ICON_CREATE'
        exporting
          name                  = 'ICON_NEGATIVE'
          info                  = lf_quickinfo
          add_stdinf            = 'X'
        importing
          result                = gf_icon_quantity_minus
        exceptions
          icon_not_found        = 1
          outputfield_too_short = 2
          others                = 3.
      if sy-subrc ne 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    endif.
    case is_tvpodvb-podmul.
      when gc_pod_display_more.
        cs_rv50a-podmul = gf_icon_pod_mul_line.
      when gc_pod_enter_more.
        cs_rv50a-podmul = gf_icon_pod_one_line.
      when gc_pod_quantity_plus.
        cs_rv50a-icon_calc = gf_icon_quantity_plus.
      when gc_pod_quantity_minus.
        cs_rv50a-icon_calc = gf_icon_quantity_minus.
    endcase.
  else.
    cs_rv50a-podmul = space.
    cs_rv50a-icon_calc = space.
  endif.

endform.                    " assign_icon