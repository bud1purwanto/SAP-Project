*&---------------------------------------------------------------------*
*&      Form  AG_AUF_HINWEIS_PRUEFEN
*&---------------------------------------------------------------------*
*       Der eingegebene Auftraggeber wird überprüft auf eventuell     *
*       vorhandene Angebote bzw. Kontrakte. Liegt mindestens ein      *
*       vorangeganger Verkaufsbeleg vor, wird ein Hinweis darüber     *
*       angezeigt.                                                    *
*---------------------------------------------------------------------*
form ag_auf_hinweis_pruefen.

  data:  da_dynpro like sy-dynnr,
         da_vdatu like vbak-vdatu,
         da_vprgr like vbak-vprgr,
         da_ketdat(10),
         da_kprgbz(1),
         da_subrc like sy-subrc.
  data:  save_vdatu like vbak-vdatu,
         save_vprgr like vbak-vprgr.
  data:  da_length type i.
  local: tvak.

  data: da_ang_header_exist(1)  type c value ' ',
        da_kon_header_exist(1)  type c value ' ',
        da_trvog                like tvak-trvog,
        da_answer               type c,
        da_vbeln                like vbak-vbeln,
        da_lines                like sy-tfill,
        da_diagnosetext(30)     type c.

  data: da_dynpfield_tab like dynpread occurs 0 with header line.
  data: da_bapiflag(1) type c,
        da_nodialog(1) type c.

* call the dialogue flag
  if call_bapi = charx.
     call function 'DIALOG_GET_STATUS'
          importing
             dialog_status = da_bapiflag.
  endif.
  if call_function = charx.
     if call_bapi = charx.
        if da_bapiflag = charx.
           da_nodialog = charx.
        else.
           da_nodialog = space.
        endif.
     else.
        da_nodialog = charx.
     endif.
  endif.

  save_vdatu = vbak-vdatu .
  save_vprgr = vbak-vprgr .

  check sy-batch eq space and
        ( sy-binpt eq space or not cattaktiv is initial ) .
  CHECK da_nodialog EQ SPACE OR DISPLAY_MESSAGE_POPUP EQ CHARX.

* no messages about quotations and contracts if Lean Order Processing
  check call_activity ne gc_activity_lord.

*----------------------------------------------------------------------*
* Auf Kopfebene pruefen
*----------------------------------------------------------------------*
* nur pruefen wenn nicht im 'Anlegen mit Bezug'
  check kopieren eq space and svbak-tabix eq 0.

  refresh hnw_vbak.
  clear hnw_vbak.

  if taxi_body_subscreen eq '4400' or
     taxi_body_subscreen eq '4402' or
     taxi_body_subscreen eq '4406' or
     taxi_body_subscreen eq '4414'.
    da_dynpro = '4440'.
  else.
    da_dynpro = taxi_body_subscreen.
  endif.

*  PERFORM DYNP_VALUES_READ(SAPMV45A) USING 'SAPMV45A'
*                                           DA_DYNPRO
*                                           'RV45A-KETDAT'
*                                  CHANGING DA_KETDAT
*                                           DA_SUBRC.
*


  move 'RV45A-KETDAT' to da_dynpfield_tab-fieldname.
  append da_dynpfield_tab.
  move 'RV45A-KPRGBZ' to da_dynpfield_tab-fieldname.
  append da_dynpfield_tab.

  call function 'DYNP_VALUES_READ'
    exporting
      dyname               = 'SAPMV45A'
      dynumb               = da_dynpro
    tables
      dynpfields           = da_dynpfield_tab
    exceptions
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      others               = 10.

  if sy-subrc eq 0.
    do 2 times.
      read table da_dynpfield_tab index sy-index.
      if sy-subrc eq 0.
        case sy-tabix.
          when '1'.
            da_ketdat = da_dynpfield_tab-fieldvalue.
          when '2'.
            da_kprgbz = da_dynpfield_tab-fieldvalue.
        endcase.
      endif.
    enddo.

    call function 'PERIOD_AND_DATE_CONVERT_INPUT'
      exporting
        dialog_date_is_in_the_past = space
        external_date              = da_ketdat
        external_period            = da_kprgbz
      importing
        internal_date              = da_vdatu
        internal_period            = da_vprgr
      exceptions
        others                     = 4.

    if sy-subrc eq 0.
      vbak-vdatu = da_vdatu.
      vbak-vprgr = da_vprgr.
    endif.

  endif.

*
*  IF DA_SUBRC EQ 0.
*    PERFORM DYNP_VALUES_READ(SAPMV45A) USING 'SAPMV45A'
*                                             DA_DYNPRO
*                                             'RV45A-KPRGBZ'
*                                    CHANGING DA_KPRGBZ
*                                             DA_SUBRC.

*    IF DA_SUBRC EQ 0.

*    ENDIF.
*  ENDIF.

* Angebote zum Auftraggeber lesen
  if tvak-hnwag ca 'ACE'.
    perform vakpa_select using kuagv-kunnr
                               'AG'    " Partnerrolle = AG
                               vbak-vkorg
                               '2'     " TRVOG = Angebote
                               vbak-vtweg
                               vbak-spart
                               kuagv-kunnr
                               da_ang_header_exist.
  endif.

* Kontrakte zum Auftraggeber lesen
  if tvak-hnwkm ca 'ACE'.
    perform vakpa_select using kuagv-kunnr
                               'AG'    " Partnerrolle = AG
                               vbak-vkorg
                               '4'     " TRVOG = Kontrakt
                               vbak-vtweg
                               vbak-spart
                               kuagv-kunnr
                               da_kon_header_exist.

    perform vakpa_select using kuagv-kunnr
                               'AG'    " Partnerrolle = AG
                               vbak-vkorg
                               '3'     " TRVOG = Lieferpläne
                               vbak-vtweg
                               vbak-spart
                               kuagv-kunnr
                               da_kon_header_exist.

*   Zusätzlich Hinweis laut Kundenliste/Kundenhierarchie
    if not tvak-hnwk2 is initial.
      perform vakpa_abruf_select using kuagv-kunnr
                                      '4'     " TRVOG = Kontrakt
                                      tvak-hnwk2
                                      da_kon_header_exist.
    endif.
  endif.

* Wenn aus der Kontaktbearbeitung aufgerufen wird I-Message bringen ...
  if display_message_popup eq charx.
    if da_ang_header_exist ne space.
      if da_kon_header_exist ne space.
        message i189.
      else.
        message i187.
      endif.
    else.
      if da_kon_header_exist ne space.
        message i188.
      endif.
    endif.
  endif.
* ... und Routine vorzeitig verlassen
  check display_message_popup ne charx.

* Bestimme die Anzahl der gefundenen offenen Belege
  describe table hnw_vbak lines da_lines.

* Hinweis in Abhängigkeit der beiden Schalter anzeigen
  if da_ang_header_exist ne space.
    if da_kon_header_exist ne space.
      if tvak-hnwag eq 'E' or tvak-hnwkm eq 'E'.
        da_answer = 2.
      else.
*   Hinweis, dass zum Auftraggeber mind. ein Angebot und Kontrakt
*   existiert
        move text-210 to da_diagnosetext.
        da_length = strlen( da_diagnosetext ) + 1.
        move kuagv-kunnr to da_diagnosetext+da_length.
        call function 'POPUP_TO_DECIDE_WITH_MESSAGE'
          exporting
            defaultoption = '1'
            diagnosetext1 = da_diagnosetext
            diagnosetext2 = text-211
            diagnosetext3 = text-223
            textline1     = ' '
            text_option1  = text-212
            text_option2  = text-213
            titel         = text-214
          importing
            answer        = da_answer.
      endif.
    else.
* Angebote
      if ( tvak-hnwag = 'C' and da_lines = 1 ) or tvak-hnwag = 'E'.
        da_answer = 2.
      else.
        call function 'POPUP_TO_DECIDE_WITH_MESSAGE'
          exporting
            defaultoption = '1'
            diagnosetext1 = text-210
            diagnosetext2 = kuagv-kunnr
            diagnosetext3 = text-215
            textline1     = ' '
            text_option1  = text-212
            text_option2  = text-213
            titel         = text-216
          importing
            answer        = da_answer.
      endif.
    endif.
  else.
    if da_kon_header_exist ne space.
* Kontrakte
      if ( tvak-hnwkm = 'C' and da_lines = 1 ) or tvak-hnwkm = 'E'.
        da_answer = 2.
      else.
        call function 'POPUP_TO_DECIDE_WITH_MESSAGE'
          exporting
            defaultoption = '1'
            diagnosetext1 = text-210
            diagnosetext2 = kuagv-kunnr
            diagnosetext3 = text-218
            textline1     = ' '
            text_option1  = text-212
            text_option2  = text-213
            titel         = text-219
          importing
            answer        = da_answer.
      endif.
    endif.
  endif.

  if da_answer = '2' and da_lines > 0.
    if da_lines = 1.
      da_vbeln = hnw_vbak-vbeln.
      da_trvog = hnw_vbak-trvog.
    endif.
    if da_lines > 1 or
      ( da_lines = 1 and da_ang_header_exist = charx and
                         tvak-hnwag eq 'A' ) or             "Angebot
      ( da_lines = 1 and da_kon_header_exist = charx and
                          tvak-hnwkm eq 'A' ).   "Kontrakt/Lieferplan
*   es existieren Referenzbelege --> Anzeigen
      call function 'SD_LIST_REFERENCE_DOCUMENT'
        exporting
          kopf_ebene = 'X'
          i_kunnr    = kuagv-kunnr
        importing
          e_vbeln    = da_vbeln
          e_trvog    = da_trvog
        tables
          list_vapma = hnw_vbap
          list_vakpa = hnw_vbak.
    endif.
    if not da_vbeln is initial.
*     bei genau einem Vorlagebeleg wird eine S-Meldung ausgegeben
      if da_lines = 1 and ( tvak-hnwag ne 'A' or tvak-hnwkm ne 'A' ).
        if da_ang_header_exist = charx.
          message s725 with kuagv-kunnr da_vbeln.
        endif.
        if da_kon_header_exist = charx.
          message s726 with kuagv-kunnr da_vbeln.
        endif.
      endif.
*     copy header texts again in this case
      clear no_text_copy-header.
*     aus der angezeigten Liste wurde ein Beleg zum Kopieren gewählt
      perform beleg_kopf_kopieren_aus_liste using da_vbeln
                                                  da_trvog.
      no_text_copy-header = charx.
      if vbkd-posnr ne posnr_low.
*     adjust XVBKD tabix if necessay
        perform xvbkd_lesen_direkt(sapfv45k) using posnr_low
                                                   svbkd-tabix.
        perform vbkd_bearbeiten_vorbereiten(sapfv45k).
      endif.
    endif.
  endif.
  if vbak-vgbel is initial.
    vbak-vdatu = save_vdatu.
    vbak-vprgr = save_vprgr.
  endif.

endform.                    "ag_auf_hinweis_pruefen