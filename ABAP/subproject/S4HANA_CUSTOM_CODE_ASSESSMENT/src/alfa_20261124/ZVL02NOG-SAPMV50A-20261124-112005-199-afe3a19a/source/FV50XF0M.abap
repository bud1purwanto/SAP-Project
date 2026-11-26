************************************************************************
* Unterroutinen RV-Versand alphabetisch sortiert:                      *
* -----------------------------------------------                      *
* Buchstabe M:                                                         *
*                                                                      *
* Verwendung  in  :  SAPMV50A                                          *
*                 :  SAPLV50S                                          *
************************************************************************



*---------------------------------------------------------------------*
*       FORM MESSAGE_AUFBAUEN                                         *
*---------------------------------------------------------------------*
*       Die zu sendende Nachricht wird zusammengebaut                 *
*---------------------------------------------------------------------*
form message_aufbauen using ma_msgno like sy-msgno
                            ma_msgty like sy-msgty
                            ma_msgid like sy-msgid
                            ma_msgv1 type clike
                            ma_msgv2 type clike
                            ma_msgv3 type clike
                            ma_msgv4 type clike
                            ma_ftext type clike.

  data: ftext(300) type c.             "Hilfsfeld für Fehlernachricht

  ftext       = space.

  select single * from t100 where sprsl = sy-langu
                            and   arbgb = ma_msgid
                            and   msgnr = ma_msgno.

  if sy-subrc = 0.
    ftext       = t100-text.
*    Try to replace numbered place holders first
    replace '&1' with ma_msgv1 into ftext.
    replace '&2' with ma_msgv2 into ftext.
    replace '&3' with ma_msgv3 into ftext.
    replace '&4' with ma_msgv4 into ftext.
    replace '$1' with ma_msgv1 into ftext.
    replace '$2' with ma_msgv2 into ftext.
    replace '$3' with ma_msgv3 into ftext.
    replace '$4' with ma_msgv4 into ftext.
*    Replace simple place holders if any left
    replace '&' with ma_msgv1 into ftext.
    replace '$' with ma_msgv1 into ftext.
    replace '&' with ma_msgv2 into ftext.
    replace '$' with ma_msgv2 into ftext.
    replace '&' with ma_msgv3 into ftext.
    replace '$' with ma_msgv3 into ftext.
    replace '&' with ma_msgv4 into ftext.
    replace '$' with ma_msgv4 into ftext.
    condense ftext.
    ma_ftext = ftext.
  endif.

endform.
*eject

*---------------------------------------------------------------------*
*       FORM MESSAGE_HANDLING                                         *
*---------------------------------------------------------------------*
*       Auftretende Nachrichten werden nach folgendem Schema behandelt*
*                                                                     *
*                         VL01                   VL04                 *
*       ----------------------------------------------------------    *
*                                                                     *
*        Infos +          sammeln + weiter       ignore               *
*        Warnungen        bei Bedarf anzeigen                         *
*                                                                     *
*                                                                     *
*        Error            zeigen + anhalten      Fehlerprotokoll      *
*                                                                     *
*        Abbruch          Abbruch                Abbruch              *
*                                                                     *
*                                                                     *
*---------------------------------------------------------------------*
form message_handling using mh_posnr like vbap-posnr
                            mh_msgno like sy-msgno
                            mh_msgty like sy-msgty
                            mh_msgid like sy-msgid
                            mh_msgv1 type clike
                            mh_msgv2 type clike
                            mh_msgv3 type clike
                            mh_msgv4 type clike.

 check gv_event_pov is initial.       " ignore error messages during POV


  data: force_vbfs.
  if mh_msgty ca V50AGL-MSGTY_SET_FOR_VBFS.
    vbsk-ernum = vbsk-ernum + 1.
    perform message_vbfs_aufbauen using vbsk-sammg
                                            mh_posnr
                                            mh_msgno
                                            mh_msgty
                                            mh_msgid
                                            mh_msgv1
                                            mh_msgv2
                                            mh_msgv3
                                            mh_msgv4.
  else.
    case mh_msgty.
      when chara.
        perform message_senden using mh_msgno
                                     mh_msgty
                                     mh_msgid
                                     mh_msgv1
                                     mh_msgv2
                                     mh_msgv3
                                     mh_msgv4.
      when chare.
*      Beim Hinzufügen Fehler ins Protokoll:
*      Sammelgang, Kopier-Modus...
        if ( t185f-aktyp = charh and sy-tcode ne 'VL11' ) or
           v50agl-sammelgang = charx or
           positionsgenerieren = charx.
          vbsk-ernum = vbsk-ernum + 1.
          perform message_vbfs_aufbauen using vbsk-sammg
                                              mh_posnr
                                              mh_msgno
                                              mh_msgty
                                              mh_msgid
                                              mh_msgv1
                                              mh_msgv2
                                              mh_msgv3
                                              mh_msgv4.
        else.
          perform message_senden using mh_msgno
                                       mh_msgty
                                       mh_msgid
                                       mh_msgv1
                                       mh_msgv2
                                       mh_msgv3
                                       mh_msgv4.
        endif.
      when chari.
        perform check_force_vbfs using force_vbfs
                                         mh_msgno
                                         mh_msgid.
* I-Meldungen kommen ins Protokoll,wenn
* - Meldung zu generierten (Verpackungs-)positionen
* - oder im Sammelgang
*   . 1. nur wenn für die Versandstelle I-Meldungen erwünscht sind oder
*   . 2. die spezielle Fehelermeldung zwingend ins Protokoll soll.
*   . Ist 1. und 2. nicht erfüllt, werden die messages ignoriert.
* - oder im Dialog (im Nicht-Sammelgang) im Hinzufüge-Modus VL01...
* - sie während des manuellen Splitvorganges ausgelöst werden
        if v50agl-sammelgang = charx
           or positionsgenerieren = charx                     "DS
*      or v50agl-split      = charx
        .
          if lips-posar = charc  or
             tvst-imess = charx  or
             tvst-vstel is initial or                         "n_597352
             force_vbfs = charx.
            vbsk-ernum = vbsk-ernum + 1.
            perform message_vbfs_aufbauen using vbsk-sammg
                                                mh_posnr
                                                mh_msgno
                                                mh_msgty
                                                mh_msgid
                                                mh_msgv1
                                                mh_msgv2
                                                mh_msgv3
                                                mh_msgv4.
          else.
*          ignorieren
          endif.
        else.
          if ( lips-posar  = charc and
               positionsgenerieren = charx ) or
             ( t185f-aktyp = charh and sy-tcode ne 'VL11' ).
            vbsk-ernum = vbsk-ernum + 1.
            perform message_vbfs_aufbauen using vbsk-sammg
                                                mh_posnr
                                                mh_msgno
                                                mh_msgty
                                                mh_msgid
                                                mh_msgv1
                                                mh_msgv2
                                                mh_msgv3
                                                mh_msgv4.
          else.
            perform message_senden using mh_msgno
                                         mh_msgty
                                         mh_msgid
                                         mh_msgv1
                                         mh_msgv2
                                         mh_msgv3
                                         mh_msgv4.
          endif.
        endif.
      when others.
        if v50agl-sammelgang ne charx.
          if ( t185f-aktyp = charh and sy-tcode ne 'VL11' ) or
             ( lips-posar = charc and positionsgenerieren = charx ).
            perform message_vbfs_aufbauen using space
                                                mh_posnr
                                                mh_msgno
                                                mh_msgty
                                                mh_msgid
                                                mh_msgv1
                                                mh_msgv2
                                                mh_msgv3
                                                mh_msgv4.
          else.
            perform message_senden using mh_msgno
                                         mh_msgty
                                         mh_msgid
                                         mh_msgv1
                                         mh_msgv2
                                         mh_msgv3
                                         mh_msgv4.
          endif.
        endif.

    endcase.
  endif.

endform.
*eject

*---------------------------------------------------------------------*
*       FORM MESSAGE_SENDEN                                           *
*---------------------------------------------------------------------*
*       Die zu sendende Nachricht wird zusammengebaut und gesendet    *
*---------------------------------------------------------------------*
form message_senden using ms_msgno like sy-msgno
                          ms_msgty like sy-msgty
                          ms_msgid like sy-msgid
                          ms_msgv1 type clike
                          ms_msgv2 type clike
                          ms_msgv3 type clike
                          ms_msgv4 type clike.

  data: lf_event(3),
        lf_IN_UPDATE_TASK like sy-subrc,                      "n_519121
        lf_msgty like vbfs-msgty.

* Ab 4.0 darf Während der Exit Command-Verarbeitung keine E- oder
* W-message mehr gesendet werden, sie werden auf i-messages umgestellt
  clear lf_event.
  if not v50agl-dialog is initial.                          "v_n_667121
    call 'DY_GET_DYNPRO_EVENT'
          id 'EVENT' field lf_event.
  endif.                                                    "^_n_667121

  if ( lf_event eq 'INP' or lf_event eq 'EXC' ) and           "n_978510
     ( ms_msgty eq charw or ms_msgty eq chare ).
    lf_msgty = chari.
  ELSEIF SY-TCODE EQ 'VTWABU' AND MS_MSGTY NA 'EA' .          "v_576929
    exit.
*   deleted lines                              "n_458732old   "^_576929
  else.
    lf_msgty = ms_msgty.
  endif.

  if lf_msgty ca 'IWS'.                                     "v_n_519121
    CALL FUNCTION 'TH_IN_UPDATE_TASK'
         IMPORTING
             IN_UPDATE_TASK = lf_IN_UPDATE_TASK
             .
    if not lf_IN_UPDATE_TASK is initial.
      exit.
    endif.

    check sy-oncom ne 'P'. "perform on commit                 "n_710686

  endif.                                                    "^_n_519121

  message id     ms_msgid
          type   lf_msgty
          number ms_msgno
          with   ms_msgv1
                 ms_msgv2
                 ms_msgv3
                 ms_msgv4.


endform.
*eject

*---------------------------------------------------------------------*
*       FORM MESSAGE_VBFS_AUFBAUEN                                    *
*---------------------------------------------------------------------*
*       Auftretende nachrichten werden in diesem Protokoll fest-      *
*       gehalten und                                                  *
*       - in der VL01 auf Anforderung angezeigt                       *
*       - in der VL04 an das rufende Programm zurückgegeben           *
*---------------------------------------------------------------------*
form message_vbfs_aufbauen using mva_samnr like vbfs-sammg
                                 mva_posnr like vbap-posnr
                                 mva_msgno like sy-msgno
                                 mva_msgty like sy-msgty
                                 mva_msgid like sy-msgid
                                 mva_msgv1 type clike
                                 mva_msgv2 type clike
                                 mva_msgv3 type clike
                                 mva_msgv4 type clike.

  data: lf_subrc like sy-subrc.

* bestimmen nächsten Zaehlerstand
  if zaehler_vbfs eq 99.
    zaehler_vbfs = 0.
  else.
    zaehler_vbfs = zaehler_vbfs + 1.
  endif.

  clear cvbfs.
  cvbfs-mandt      = likp-mandt.
  cvbfs-sammg      = mva_samnr.
  if vbsk-smart is initial.                "AIP
    cvbfs-smart    = charl.                "AIP
  else.                                    "AIP
    cvbfs-smart    = vbsk-smart.           "AIP
  endif.                                   "AIP
  cvbfs-vbeln      = cvbak-vbeln.
  cvbfs-posnr      = mva_posnr.
  cvbfs-zaehl      = zaehler_vbfs.
  cvbfs-msgid      = mva_msgid.
  cvbfs-msgno      = mva_msgno.
  cvbfs-msgty      = mva_msgty.
  cvbfs-msgv1      = mva_msgv1.
  cvbfs-msgv2      = mva_msgv2.
  cvbfs-msgv3      = mva_msgv3.
  cvbfs-msgv4      = mva_msgv4.

  perform filter_multiple_messages using    cvbfs           "50A
                                   changing lf_subrc.
  if lf_subrc eq 0.
    append cvbfs.
  endif.

endform.
*-----------------------------------------------------------------------
*
*-----------------------------------------------------------------------
form message_vbfs_aufbauen_packen using mva_samnr like vbfs-sammg
                                        mva_posnr like vbap-posnr
                                        mva_msgno like sy-msgno
                                        mva_msgty like sy-msgty
                                        mva_msgid like sy-msgid
                                        mva_msgv1 type clike
                                        mva_msgv2 type clike
                                        mva_msgv3 type clike
                                        mva_msgv4 type clike.


  loop at cvbfs where vbeln = likp-vbeln and
                      posnr = lips-posnr and
                      msgv1 = lips-matnr and
                      msgid = 'V8'       and
                      msgno = '518'.

    cvbfs-msgv2 = mva_msgv2.
    cvbfs-msgv3 = mva_msgv3.
    cvbfs-msgv4 = mva_msgv4.
    modify cvbfs.
    exit.
  endloop.

  check sy-subrc > 0.

* bestimmen nächsten Zaehlerstand
  if zaehler_vbfs eq 99.
    zaehler_vbfs = 0.
  else.
    zaehler_vbfs = zaehler_vbfs + 1.
  endif.

  clear cvbfs.
  cvbfs-mandt      = likp-mandt.
  cvbfs-sammg      = mva_samnr.
  if vbsk-smart is initial.                "AIP
    cvbfs-smart    = charl.                "AIP
  else.                                    "AIP
    cvbfs-smart    = vbsk-smart.           "AIP
  endif.                                   "AIP
  cvbfs-vbeln      = likp-vbeln .
  cvbfs-posnr      = lips-posnr .
  cvbfs-zaehl      = zaehler_vbfs.
  cvbfs-msgid      = mva_msgid.
  cvbfs-msgno      = mva_msgno.
  cvbfs-msgty      = mva_msgty.
  cvbfs-msgv1      = mva_msgv1.
  cvbfs-msgv2      = mva_msgv2.
  cvbfs-msgv3      = mva_msgv3.
  cvbfs-msgv4      = mva_msgv4.
  append cvbfs.

endform.
*&---------------------------------------------------------------------*
*&      Form  CHECK_FORCE_VBFS
*&---------------------------------------------------------------------*
*       Einige der Info messages sind zumindest für den                *
*       SD monitor interessant und sollen deshalb protokolliert        *
*       werden.                                                        *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form check_force_vbfs using force_vbfs type c
                            mh_msgno like sy-msgno
                            mh_msgid like sy-msgid.
  clear force_vbfs.
  case mh_msgid.
    when 'VL'.
      case mh_msgno.
        when  999
*               or 14
*               or 28
*               or 29
*               or 31
*               or 35
*               or 38
*               or 39
*               or 61
*               or 95
*               or 114
*               or 126
*               or 137
           or 150
*               or 156
*               or 170
*               or 196
*               or 351
*               or 373
*               or 374
*               or 413
           .
          force_vbfs = charx.
      endcase.
    when 'AG'.                                             "v_n_1638809
      case mh_msgno.
        when 602.
          force_vbfs = charx.
      endcase.                                             "^_n_1638809
  endcase.
*Legende: VL
*014   Position & wird wegen abweichender Partner nicht beliefert
*028   Material & hat Status: &
*029   Pos. &, MB-Datum & durch Tagesdatum ersetzt
*035   Position & Einteilung & zur Lieferung gesperrt: &
*038   Position & wird wegen abweichender Route nicht beliefert
*039   Position & hat eine abweichende Transportgruppe &
*061   Gemäß Teilliefervereinbarung findet keine Nachlieferung statt
*095   Material & hat Status: & (Lieferung ist unzulässig)
*114   Warenausgang geplant für den &, verlegt auf den &
*126   Terminierung der Position ergibt Warenausgangsdatum &
*137   Position wird gelöscht, da Artikel gesperrt und Teilliefervereinb
*150   Es sind nur & & verfügbar
*156   Artikel & gesperrt (Liefermenge auf 0 gesetzt)
*170   Fehler bei Erzeugen Prüflos für Artikel &1 (Position wird nicht e
*196   Lieferung &: Kommissionierdatum & gesetzt bitte Liefertermine prü
*351   Bitte eine Materialnummer in Position & eingeben
*373   Bedarfsart für Positionstyp & und Dispomerkmal & ist nicht ermitt
*374   Umschlüsselung der Bedarfsart & nicht erfolgreich
*413   Material & ist für Verkauf aus & nicht vorgesehen
*
endform.                               " CHECK_FORCE_VBFS

*&---------------------------------------------------------------------*
*&      Form  MESSAGE_HANDLING_DEFAULT
*&---------------------------------------------------------------------*
*       Übergibt die SY-Felder an das message-handling.
*----------------------------------------------------------------------*
*  -->  syst: Struktur der Systemtabelle, nur aus Performance-Gründen
*             als globale Struktur (per Referenz)
*  -->  Positionsnummer die im Sammelgangsprotokoll mit ausgegeben
*       soll.
*----------------------------------------------------------------------*
form message_handling_default using value(iv_posnr) like vbap-posnr.

  perform message_handling using iv_posnr   syst-msgno
                                 syst-msgty syst-msgid
                                 syst-msgv1 syst-msgv2
                                 syst-msgv3 syst-msgv4.

endform.                               " MESSAGE_HANDLING_DEFAULT

*&---------------------------------------------------------------------*
*&      Form  MESSAGE_HANDLING_BALMI
*&---------------------------------------------------------------------*
*       Übergibt die msg*-Felder aus Balmi an das message-handling.
*----------------------------------------------------------------------*
*  -->  Positionsnummer die im Sammelgangsprotokoll mit ausgegeben
*       soll.
*----------------------------------------------------------------------*
form message_handling_balmi using if_posnr like vbap-posnr
                                  is_balmi structure balmi.

  perform message_handling using if_posnr
                                 is_balmi-msgno
                                 is_balmi-msgty
                                 is_balmi-msgid
                                 is_balmi-msgv1
                                 is_balmi-msgv2
                                 is_balmi-msgv3
                                 is_balmi-msgv4.

endform.                               " MESSAGE_HANDLING_BALMI

*&---------------------------------------------------------------------*
*&      Form  MESSAGE_STEUERUNG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form message_steuerung using    iv_mhpar structure gs_mhpar
                                iv_msgvs like v50agl-msgvs
                                iv_msgid like sy-msgid
                                iv_msgno like sy-msgno
                       changing ev_msgty like sy-msgty
                                ev_rcode like sy-subrc.

  data: lf_msgty like vbfs-msgty,
        lf_msgno like vbfs-msgno.

  lf_msgty = ev_msgty.
  lf_msgno = iv_msgno.

  call function 'SD_MESSAGE_LOG_MSGTY_GET'
       exporting
            iv_msgvs        = iv_msgvs
            iv_msgid        = iv_msgid
            iv_msgno        = lf_msgno
            is_mhpar        = iv_mhpar
       importing
            ev_msgty        = ev_msgty
       exceptions
            no_record_found = 1
            others          = 2.

  ev_rcode = sy-subrc.
*----default: calling type.
  if sy-subrc ne 0.
    ev_msgty = lf_msgty.
  endif.
* if ev_msgty eq space.                                     "50A
*   ev_msgty = 'I'.
* endif.

endform.                               " MESSAGE_STEUERUNG

*&---------------------------------------------------------------------*
*&      Form  MESSAGE_HANDLING_VARIABEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form message_handling_variabel using    iv_posnr like vbap-posnr
                                        iv_msgno like sy-msgno
                                        iv_msgty like sy-msgty
                                        iv_msgid like sy-msgid
                                        iv_msgv1 type clike
                                        iv_msgv2 type clike
                                        iv_msgv3 type clike
                                        iv_msgv4 type clike
                                        iv_mhpar structure gs_mhpar
                                        iv_msgvs like v50agl-msgvs
                              changing  ev_msgty like sy-msgty
                                        ev_rcode like sy-subrc.
  data: lv_msgty like sy-msgty.

*---default: calling message type:
  ev_msgty = iv_msgty.

*----use a local copy for further calling , avoiding accidents
  lv_msgty = ev_msgty(1).

  perform message_steuerung
              using
                 iv_mhpar
                 iv_msgvs
                 iv_msgid
                 iv_msgno
              changing
                 lv_msgty
                 ev_rcode.

  ev_msgty(1) = lv_msgty.
  check lv_msgty ne space.

  perform message_handling
              using
                 iv_posnr
                 iv_msgno
                 lv_msgty
                 iv_msgid
                 iv_msgv1
                 iv_msgv2
                 iv_msgv3
                 iv_msgv4.

endform.                               " MESSAGE_HANDLING_VARIABEL

*&---------------------------------------------------------------------*
*&      Form  MHPAR_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PAR_NAME  text
*      -->P_PAR_VALUE  text
*----------------------------------------------------------------------*
form mhpar_set using    p_name
                        p_value.

  field-symbols: <f>.
  assign component p_name of structure gs_mhpar to <f>.
  check sy-subrc eq 0.
  <f> = p_value.

endform.                                                    " MHPAR_SET
*&---------------------------------------------------------------------*
*&      Form  filter_multiple_messages (50A)
*&---------------------------------------------------------------------*
*       Multiple appearance of messages that should appear only once
*       per document or per item is suppressed
*----------------------------------------------------------------------*
form filter_multiple_messages using    is_vbfs  type vbfs
                              changing cf_subrc like sy-subrc.

  local: sy-subrc.

  data: begin of ls_msg_filt,
          msgid like vbfs-msgid,
          msgno like vbfs-msgno,
          item  type c,
        end of ls_msg_filt.



  statics: lt_msg_filt like ls_msg_filt occurs 0.

  cf_subrc = 0.

* Fill filter table on initial call
  if lt_msg_filt[] is initial.

*   VL112: Ship-to party is blocked for delivery
    ls_msg_filt-msgid = 'VL'. ls_msg_filt-msgno = '112'.
    ls_msg_filt-item = space.
    append ls_msg_filt to lt_msg_filt.

*   VL096: Order is incomplete - maintain the order
    ls_msg_filt-msgid = 'VL'. ls_msg_filt-msgno = '096'.
    ls_msg_filt-item = space.
    append ls_msg_filt to lt_msg_filt.

*   VL014: Item &: delivery split because the partners are different
    ls_msg_filt-msgid = 'VL'. ls_msg_filt-msgno = '014'.
    ls_msg_filt-item = charx.
    append ls_msg_filt to lt_msg_filt.

*   VL074: Delivery date & is in the past                    "v_n_898627
    ls_msg_filt-msgid = 'VL'. ls_msg_filt-msgno = '074'.
    ls_msg_filt-item = space.
    append ls_msg_filt to lt_msg_filt.                       "^_n_898627

*   Further messages may be added...

    sort lt_msg_filt by msgid msgno.

  endif.

* Is requested message a candidate for filtering?
  read table lt_msg_filt into ls_msg_filt
                         with key msgid = is_vbfs-msgid
                                  msgno = is_vbfs-msgno
                         binary search.
  if sy-subrc ne 0.
*   Message can be appended to CVBFS
    cf_subrc = 0.
    exit.
  endif.

  if ls_msg_filt-item eq space.
*   Filter messages that should appear only once per document
    loop at cvbfs transporting no fields
                  where sammg eq is_vbfs-sammg
                    and smart eq is_vbfs-smart
                    and vbeln eq is_vbfs-vbeln
                    and msgid eq is_vbfs-msgid
                    and msgno eq is_vbfs-msgno.
      if sy-subrc eq 0.
        cf_subrc = 4.
*       Correct total number of errors in collective run
        perform correct_error_counter using is_vbfs.
        exit.
      endif.
    endloop.
  else.
*   Filter messages that should appear only once per item
    loop at cvbfs transporting no fields
                  where sammg eq is_vbfs-sammg
                    and smart eq is_vbfs-smart
                    and vbeln eq is_vbfs-vbeln
                    and posnr eq is_vbfs-posnr
                    and msgid eq is_vbfs-msgid
                    and msgno eq is_vbfs-msgno.
      if sy-subrc eq 0.
        cf_subrc = 4.
*       Correct total number of errors in collective run
        perform correct_error_counter using is_vbfs.
        exit.
      endif.
    endloop.
  endif.

endform.                    " filter_multiple_messages
*&---------------------------------------------------------------------*
*&      Form  correct_error_counter
*&---------------------------------------------------------------------*
*       Corrects error counter for messages that do not appear in the
*       error log due to filtering.
*----------------------------------------------------------------------*
form correct_error_counter using is_vbfs like vbfs.

  if zaehler_vbfs ne 0.
    subtract 1 from zaehler_vbfs.
  else.
    zaehler_vbfs = 0.
  endif.
* Only messages of type 'Error' and 'Information' are written to the
* error log during collective runs
  if is_vbfs-msgty ca 'EI'.
    if vbsk-ernum ne 0.
      subtract 1 from vbsk-ernum.
    else.
      vbsk-ernum = 0.
    endif.
  endif.

endform.                    " correct_error_counter