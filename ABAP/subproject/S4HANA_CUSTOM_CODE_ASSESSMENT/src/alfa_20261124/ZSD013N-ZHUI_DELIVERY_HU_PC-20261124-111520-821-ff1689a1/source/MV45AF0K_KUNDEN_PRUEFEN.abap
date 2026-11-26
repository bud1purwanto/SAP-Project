*&---------------------------------------------------------------------*
*&      Form  KUNDEN_PRUEFEN
*&---------------------------------------------------------------------*
form kunden_pruefen.

  data: da_vkorg like vbak-vkorg,
        da_vtweg like vbak-vtweg,
        da_spart like vbak-spart,
        da_vkorg_u like vbak-vkorg,
        da_vtweg_u like vbak-vtweg,
        da_spart_u like vbak-spart,
        da_kna1  like kna1,
        da_default_ok,
        da_objtyp like sweinstcou-objtype,
        da_typeid like sweinstcou-objkey,
        da_action_done,
        da_subrc like sy-subrc,
        da_default_vkorg like vbak-vkorg,
        da_sdorgdata like sdorgdata.

  data: begin of da_xvbpa occurs 0.
          include structure vbpav.
  data: end of da_xvbpa.
  data: begin of da_yvbpa occurs 0.
          include structure vbpav.
  data: end of da_yvbpa.
  data: begin of da_xvbadr occurs 5.
          include structure sadrvb.
  data: end of da_xvbadr.
  data: begin of da_yvbadr occurs 5.
          include structure sadrvb.
  data: end of da_yvbadr.
  data: begin of da_xvbuv occurs 0.
          include structure vbuvvb.
  data: end of da_xvbuv.
  data: begin of da_hvbuv occurs 0.
          include structure vbuvvb.
  data: end of da_hvbuv.
  data: da_error_messages type i.

  data: insert_we type c.

  clear kunnr_upd_check.
  clear vkgrp_clear.

* übergebene Verkaufsorganisation merken zur Prüfung, ob TVKO_SELECT
* notwendig ist
  da_default_vkorg = vbak-vkorg.

* Auftraggeber anlegen
  perform auftraggeber_anlegen.

  if kuagv-kunnr is initial.
* Ist der Auftraggeber Pflicht ?
    if fcode ne fcode_kopieren_faktura and
       fcode ne fcode_kopieren_anfrage and
       fcode ne fcode_kopieren_angebot and
       fcode ne fcode_kopieren_kontrakt and
       fcode ne fcode_kopieren_auftrag.
      perform tpaer_select using tvak-pargr
                                 'AG'
                                 space
                                 sy-subrc.
      if tpaer-papfl is initial.
* Auftraggeber ist nicht Pflicht
        exit.
      endif.
    endif.
  endif.

* Rausnehmen des Auftraggebers ist nicht erlaubt.
  if not vbak-kunnr is initial and
     kuagv-kunnr is initial.
    message e368.
  endif.

* Rausnehmen des Warenempfängers ist nicht erlaubt.
  IF  ( NOT save-we IS INITIAL AND save-we NE '0000000000' ) AND
     kuwev-kunnr is initial AND
     xvbak-agupda is initial.
    set cursor field 'KUWEV-KUNNR'.
    message e837.
  endif.

  check svbak-tabix eq 0 or
        kuagv-kunnr ne vbak-kunnr or
        not prf_ag is initial and kuagv-kunnr ne prf_ag or
        kuwev-kunnr ne save-we or
        not prf_we is initial and kuwev-kunnr ne prf_we.

* Prf_ag enthält den zuletzt eingegebenen Auftraggeber.
* Das ist wichtig, wenn man von A auf B und nach Fehlermeldung
* zurück auf A ändert. Diese Änderung wird sonst nicht erkannt

  if kuagv-kunnr ne vbak-kunnr and
     not vbak-kunnr is initial or
     not prf_ag is initial and kuagv-kunnr ne prf_ag or
     kuagv-kunnr is initial and not vbak-kunnr is initial.
    kunnr_upd_check = charx.
* Primäre AG-Prüfungen, bevor Daten geändert werden.
    perform ag_pruefen using charx
                             sy-subrc.
    if sy-subrc eq 0.
      default_vkorg = vbak-vkorg.
      default_vtweg = vbak-vtweg.
      default_spart = vbak-spart.
    endif.

    clear kunnr_upd_check.
    rv02p-agupd = charx.
* XVBAK-AGUPDA soll gesetzt werden, wenn RV02P-AGUPD gesetzt ist,
* wird aber erst viel später wieder zurückgesetzt.
    xvbak-agupda = charx.
    prf_ag = kuagv-kunnr.
* CLEAR nur dann, wenn der WE nicht manuell eingegeben wurde
    if kuwev-kunnr eq save-we.
      clear kuwev.
    endif.
  endif.

  if not kuwev-kunnr is initial and
     save-we is initial and
     svbak-tabix = 1.
    read table xvbpa with key posnr = '000000'
                              parvw = 'WE'
                              kunnr = '0000000000'.
    if sy-subrc ne 0.
      insert_we = charx.
    endif.
  endif.

  if not kuwev-kunnr is initial and
     ( kuwev-kunnr ne save-we and
     not save-we is initial or
     not prf_we is initial and kuwev-kunnr ne prf_we or
     kuwev-kunnr is initial and not save-we is initial or
     insert_we = charx ).
* Primäre WE-Prüfungen, bevor Daten geändert werden.
    perform we_pruefen using charx
                             sy-subrc.
    rv02p-weupd = charx.
* XVBAK-WEUPDA soll gesetzt werden, wenn RV02P-WEUPD gesetzt ist,
* wird aber erst später zurückgenommen.
    xvbak-weupda = charx.
    prf_we = kuwev-kunnr.
* Zuweisung relevanter Daten
    da_objtyp = businessobjekt.
    da_typeid = vbak-vbeln.
    da_xvbpa[] = xvbpa[].
    da_yvbpa[] = yvbpa[].
    da_xvbuv[] = xvbuv[].
    da_hvbuv[] = hvbuv[].
    da_xvbadr[] = xvbadr[].
    da_yvbadr[] = yvbadr[].

    call function 'SD_PARTNER_DATA_PUT'
      exporting
        fic_objecttype      = da_objtyp
        fic_objectkey       = da_typeid
      tables
        frt_xvbpa           = da_xvbpa
        frt_yvbpa           = da_yvbpa
        frt_xvbuv           = da_xvbuv
        frt_hvbuv           = da_hvbuv
        frt_xvbadr          = da_xvbadr
        frt_yvbadr          = da_yvbadr
      exceptions
        no_object_specified = 1
        others              = 2.
    if sy-subrc <> 0.
      message e506(vp).
    endif.
    move-corresponding vbak to da_sdorgdata.
    da_sdorgdata-doctype = vbak-auart.
    call function 'SD_PARTNER_SINGLE_MODIFY'
      exporting
        fic_objecttype       = da_objtyp
        fic_objectkey        = da_typeid
        fis_sdorgdata        = da_sdorgdata
        fif_pargr            = tvak-pargr
        fif_parvw            = 'WE'
        fif_posnr            = '000000'
        fif_kunnr_old        = save-we
        fif_kunnr_new        = kuwev-kunnr
      importing
        fev_action_done      = da_action_done
        frf_log_count        = da_error_messages
      exceptions
        parameter_incomplete = 1
        object_not_found     = 2
        check_error          = 3
        others               = 4.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
    call function 'SD_PARTNER_DATA_GET'
      exporting
        fic_objecttype      = da_objtyp
        fic_objectkey       = da_typeid
        fic_xvbuv_merged    = charx
        fic_hvbuv_merged    = charx
      tables
        fet_xvbpa           = xvbpa
        fet_yvbpa           = yvbpa
        fet_xvbuv           = xvbuv
        fet_hvbuv           = hvbuv
        fet_xvbadr          = xvbadr
        fet_yvbadr          = yvbadr
      exceptions
        no_object_specified = 1
        no_object_found     = 2
        merge_failed        = 3
        others              = 4.
    if sy-subrc <> 0.
      message e506(vp).
    endif.
  endif.

  if vbak-kunnr is initial or vbak-kunnr ne kuagv-kunnr.

    if not gs_vtber_ext-kunnr is initial and
       gs_vtber_ext-vkorg is initial and
       gs_vtber_ext-kunnr eq kuagv-kunnr.
      default_vkorg = vbak-vkorg.
      default_vtweg = vbak-vtweg.
      default_spart = vbak-spart.
    endif.

    clear: vbak-vkorg,
           vbak-vtweg,
           vbak-spart.

    da_vkorg = default_vkorg.
    da_vtweg = default_vtweg.
    da_spart = default_spart.

* Umschlüsselung auf gemeinsame Vertriebswege ...
    if not da_vkorg is initial and
       not da_vtweg is initial.
      select single * from tvkov where vkorg = da_vkorg
                                   and vtweg = da_vtweg.
      if sy-subrc = 0.
        da_vtweg = tvkov-vtwku.
      endif.
    endif.
* ... und Sparten
    if not da_vkorg is initial and
       not da_spart is initial.
      select single * from tvkos where vkorg = da_vkorg
                                   and spart = da_spart.
      if sy-subrc = 0.
        da_spart = tvkos-spaku.
      endif.
    endif.

    if da_vkorg is initial.
      da_vkorg = '%'.
    endif.
    if da_vtweg is initial.
      da_vtweg = '%'.
    endif.
    if da_spart is initial.
      da_spart = '%'.
    endif.
* Umgeschlüsselten Vertriebsbereich separat merken
    da_vkorg_u = da_vkorg.
    da_vtweg_u = da_vtweg.
    da_spart_u = da_spart.

* Überprüfen, ob der eingegebene AG ein AG gemäß KNVP ist.
    if not kuagv-kunnr is initial.
      select single * from knvp where vkorg like da_vkorg
                                  and vtweg like da_vtweg
                                  and spart like da_spart
                                  and parvw = 'AG'
                                  and kunn2 = kuagv-kunnr.
      if sy-subrc = 0.
        if not default_vkorg is initial and
           not default_vtweg is initial and
           not default_spart is initial.
          da_default_ok = charx.
          vbak-vkorg = default_vkorg.
          vbak-vtweg = default_vtweg.
          vbak-spart = default_spart.
        endif.
      else.
* Der eingegebene AG ist kein zulässiger AG. Wenn er WE gemäß KNVP ist,
* wird KUWEV-KUNNR gefüllt und KUAGV-KUNNR gelöscht.
        select single * from knvp where vkorg like da_vkorg
                                    and vtweg like da_vtweg
                                    and spart like da_spart
                                    and parvw = 'WE'
                                    and kunn2 = kuagv-kunnr.
        if sy-subrc eq 0.
          kuwev-kunnr = kuagv-kunnr.
          clear kuagv-kunnr.
          message s738(v1) with kuwev-kunnr.
        else.
* Im Vertriebsbereich, der auf dem Anforderungsbild eingegeben wurde
* gibt es den Kunden weder als AG noch WE. Daher nochmal ohne VTBER.
          da_vkorg = '%'.
          da_vtweg = '%'.
          da_spart = '%'.
* Überprüfen, ob der eingegebene AG ein AG gemäß KNVP ist.
          select single * from knvp where vkorg like da_vkorg
                                      and vtweg like da_vtweg
                                      and spart like da_spart
                                      and parvw = 'AG'
                                      and kunn2 = kuagv-kunnr.
          if sy-subrc ne 0.
* Der eingegebene AG ist kein zulässiger AG. Wenn er WE gemäß KNVP ist,
* wird KUWEV-KUNNR gefüllt und KUAGV-KUNNR gelöscht.
            select single * from knvp where vkorg like da_vkorg
                                        and vtweg like da_vtweg
                                        and spart like da_spart
                                        and parvw = 'WE'
                                        and kunn2 = kuagv-kunnr.
            if sy-subrc eq 0.
              kuwev-kunnr = kuagv-kunnr.
              clear kuagv-kunnr.
              message i738(v1) with kuwev-kunnr.
            else.
* Prüfen, ob es sich um einen CPD-Kunden ohne KNVP-Segment handelt
              call function 'VIEW_KNA1'
                exporting
                  kunde     = kuagv-kunnr
                importing
                  anschrift = da_kna1
                exceptions
                  no_kna1   = 1
                  others    = 2.
              if sy-subrc = 0.
                select single * from t077d
                       where ktokd = da_kna1-ktokd.
                if sy-subrc = 0 and
                   t077d-xcpds is initial and
                   t077d-dear3 is initial and
                   t077d-dear5 is initial and
                   t077d-dear6 is initial.
* Wenn an dieser Stelle das CPD-, Konsumenten- oder Defaultkennzeichen
* nicht sitzt, wird eine Fehlermeldung ausgegeben
                  clear save.
                  message e199(vp) with kuagv-kunnr.
                else.
* Nachschauen, ob zum evtl. eingegebenen Vertriebsbereich ein
* KNVV-Segment existiert. Wenn ja wird derselbe akzeptiert
                  if not default_vkorg is initial and
                     not default_vtweg is initial and
                     not default_spart is initial.
                    select single * from knvv where kunnr = kuagv-kunnr
                                              and vkorg = da_vkorg_u
                                              and vtweg = da_vtweg_u
                                              and spart = da_spart_u.
                    if sy-subrc = 0.
                      da_default_ok = charx.
                      vbak-vkorg = default_vkorg.
                      vbak-vtweg = default_vtweg.
                      vbak-spart = default_spart.
                    else.

*  No knvv-entry existing: Is it a consumer ?
                      if not t077d-dear6 is initial.
                        da_default_ok = charx.
                        vbak-vkorg = default_vkorg.
                        vbak-vtweg = default_vtweg.
                        vbak-spart = default_spart.
                      endif.
                    endif.
                  endif.
                endif.
              else.
                clear save.
                message e199(vp) with kuagv-kunnr.
              endif.
            endif.
          endif.
        endif.
      endif.
    endif.
    if kuagv-kunnr is initial.
      if kuwev-kunnr is initial.
* Es muß möglich sein, auf dem Übersichtsbild "kopieren" zu drücken,
* ohne einen Partner eingeben zu müssen.
* Ansonsten muß ein Partner eingegeben werden
        if fcode ne fcode_kopieren.
*     Meldung "Bitte Auftraggeber oder Warenempfänger eingeben"
          message e112(vp).
        else.
          exit.
        endif.
      else.
*     Nur durchlaufen, fall sich Warenempfänger geändert hat
        if kuwev-kunnr ne save-we.
*       Orgdaten neu bestimmen
          clear save-vkorg.
          clear save-vtweg.
          clear save-spart.
* Falls nur der WE eingegeben wurde muß noch geprüft werden, ob
* es denselben in der KNVP gibt
          select single * from knvp where vkorg like da_vkorg_u
                                      and vtweg like da_vtweg_u
                                      and spart like da_spart_u
                                      and parvw = 'WE'
                                      and kunn2 = kuwev-kunnr.
          if sy-subrc eq 0.
            if not default_vkorg is initial and
               not default_vtweg is initial and
               not default_spart is initial.
              da_default_ok = charx.
              vbak-vkorg = default_vkorg.
              vbak-vtweg = default_vtweg.
              vbak-spart = default_spart.
            endif.
          endif.
          if da_default_ok is initial.
* Vertriebsbereich mit Hilfe des WE bestimmen
            perform vtber_bestimmen using kuwev-kunnr.
          endif.
          if sy-subrc = 0.
*         Auftraggeber zum Warenempfänger bestimmen
            perform ag_bestimmen using kuwev-kunnr
                                       kuagv-kunnr
                                       vbak-vkorg
                                       vbak-vtweg
                                       vbak-spart.
          endif.
        endif.
      endif.
    else.
*   Nur durchlaufen, falls sich Auftraggeber geändert hat
      if kuagv-kunnr ne save-ag and
         da_default_ok is initial.
        if xvbak-agupda is initial.
*     Vertriebsbereich mit Hilfe des AG bestimmen bzw. nur prüfen
          clear save-vkorg.
          clear save-vtweg.
          clear save-spart.
          perform vtber_bestimmen using kuagv-kunnr.
        else.
*     Vertriebsbereich mit Hilfe des AG nur prüfen
          perform vtber_bestimmen using kuagv-kunnr.
        endif.
      endif.
    endif.
  endif.
* So, an dieser Stelle müßte jetzt alles klar sein :
* Vertriebsbereich und Auftraggeber stehen fest !

* TVKO_SELECT muß hier noch gemacht werden, damit die Adresse der
* Verkaufsorganisation gelesen wird, wenn die Verkaufsorganisation
* neu ermittelt wurde
  if da_default_vkorg ne vbak-vkorg and
     t180-trtyp eq charh.
    if not tvko is initial.
      clear tvko.
    endif.
    perform tvko_select using vbak-vkorg
                              space
                              da_subrc.
  endif.

* Auftraggeber lesen und Partnertabelle füllen (falls AG-Änderung)
  perform auftraggeber_pruefen.

* Auftraggeber und Warenempfänger merken
  move kuagv-kunnr to save-ag.
  move kuwev-kunnr to save-we.
  if kuwev-kunnr is initial and save-we is initial.
* ship-to is there but with '0': was mandatory and could not be
* determined: change should be allowed
    read table xvbpa with key posnr = '000000'
                              parvw = 'WE'
                              kunnr = '0000000000'.
    if sy-subrc = 0.
      move xvbpa-kunnr to save-we.
    endif.
  endif.

  clear gs_vtber_ext.

endform.                               " KUNDEN_PRUEFEN