*eject
*&---------------------------------------------------------------------*
*&      Form  BELEG_POS_KOPIEREN_AUS_LISTE
*&---------------------------------------------------------------------*
*       Beleg kopieren auf Positionsebene                              *
*----------------------------------------------------------------------*
form beleg_pos_kopieren_aus_liste using    us_vbeln us_posnr
                                  changing ch_subrc.

  data: da_posnr like vbap-posnr,
        da_xvbap_entries_1 like sy-tfill,
        da_xvbap_entries_2 like sy-tfill.
  data: lv_message type string.                             "#EC NEEDED

  da_posnr = vbap-posnr.

  describe table xvbap lines da_xvbap_entries_1.

* Für mehrfaches Kopieren wird Fluß und Status mit übergeben
  refresh cvbfa.
  append lines of xvbfa to cvbfa.
  refresh cvbup.
  append lines of xvbup to cvbup.

ENHANCEMENT-POINT BELEG_POS_KOPIEREN_AUS_LIST_10 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT BELEG_POS_KOPIEREN_AUS_LIST_11 SPOTS ES_SAPMV45A.

ENHANCEMENT-SECTION     BELEG_POS_KOPIEREN_AUS_LIST_01 SPOTS ES_SAPMV45A.
  if call_activity eq gc_activity_lord.
    call function 'RV_DOCUMENT_COPY_NO_POPUP'
      exporting
        fvak              = tvak
        fvbak             = vbak
        fvbpa             = vbpa
        i_vbeln           = us_vbeln
        if_called_by_lord = charx
      importing
        fvbak             = cvbak
        fvbuk             = cvbuk
        fvcpa             = tvcpa
        fvbrk             = cvbrk
      tables
        fxvbap            = cvbap
        fxvbep            = cvbep
        fxvbfa            = cvbfa
        fyvbfa            = yvbfa
        fxvbkd            = cvbkd
        fxvbpa            = cvbpa
        fxvbuk            = xvbuk
        fxvbup            = cvbup
        fxvbuv            = xvbuv
        fxfpla            = cfpla
        fxfplt            = cfplt
        fxvbsn            = cvbsn
        fxvbrp            = cvbrp
      exceptions
        error_message     = 1.
    if sy-subrc = 1.
      message id sy-msgid type 'W' number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              into lv_message.
      message_collect_lord.
      ch_subrc = 4.
      exit.
    endif.
  else.
    call function 'RV_DOCUMENT_COPY_NO_POPUP'
      exporting
        fvak    = tvak
        fvbak   = vbak
        fvbpa   = vbpa
        i_vbeln = us_vbeln
      importing
        fvbak   = cvbak
        fvbuk   = cvbuk
        fvcpa   = tvcpa
        fvbrk   = cvbrk
      tables
        fxvbap  = cvbap
        fxvbep  = cvbep
        fxvbfa  = cvbfa
        fyvbfa  = yvbfa
        fxvbkd  = cvbkd
        fxvbpa  = cvbpa
        fxvbuk  = xvbuk
        fxvbup  = cvbup
        fxvbuv  = xvbuv
        fxfpla  = cfpla
        fxfplt  = cfplt
        fxvbsn  = cvbsn
        fxvbrp  = cvbrp.
  endif.
END-ENHANCEMENT-SECTION.

* Tabelle FXVBAP muß bis auf zu kopierende Position gelöscht werden
  perform vorlage_tab_mit_pos_abstimmen(sapfv45c) using us_posnr.

* Im Änderungsfalle die aktuelle Position löschen
  if svbap-tabix > 0.
    if mat_auf_hinweis_copy = 'X'.
      keep_posnr = vbap-posnr.
    endif.
    perform xvbap_loeschen_akt_pos(sapfv45p) using vbap-posnr.
  endif.

* Beleg kopieren
  perform vorlage_kopieren(sapfv45c).

* check if copy process was successful
  describe table xvbap lines da_xvbap_entries_2.
  if not da_xvbap_entries_2 > da_xvbap_entries_1.
    ch_subrc = 4.
    exit.
  endif.

* Referenzmenge des Vorgängers prüfen
  kopieren = charx.
  perform xvbap_lesen_allgemein(sapfv45p) using da_posnr
                                          space
                                          svbap-tabix.
  if svbap-tabix = 0.
    da_posnr = us_posnr.
    perform xvbap_lesen_allgemein(sapfv45p) using da_posnr
                                            space
                                            svbap-tabix.
  endif.
  if svbap-tabix > 0.
    perform vbap_bearbeiten_vorbereiten(sapfv45p).
    perform vbep-wmeng_pruefen_vorgaenger(sapfv45e)
                                          using vbap-kwmeng
                                                'RV45A-KWMENG'.
    read table uvbap with key uepos = da_posnr binary search.
    if sy-subrc = 0.
      loop at uvbap from sy-tabix.
        if uvbap-uepos > da_posnr.
          exit.
        endif.
        if uvbap-uepos = da_posnr.
          perform xvbap_lesen_direkt(sapfv45p) using uvbap-posnr
                                            changing svbap-tabix.
          perform vbap_bearbeiten_vorbereiten(sapfv45p).
          perform vbep-wmeng_pruefen_vorgaenger(sapfv45e)
                                                using vbap-kwmeng
                                                      'RV45A-KWMENG'.
        endif.
      endloop.
      perform xvbap_lesen_direkt(sapfv45p) using da_posnr
                                        changing svbap-tabix.
      perform vbap_bearbeiten_vorbereiten(sapfv45p).
    endif.
  endif.
  clear kopieren.

* Kennzeichen setzen, daß kopiert wurde
  ch_subrc = 0.

* Selektionskennzeichen zurücknehmen
  rv45a-vbap_selkz = ' '.
  loop at ivbap.
    ivbap-selkz = ' '.
    modify ivbap.
  endloop.

endform.                    "BELEG_POS_KOPIEREN_AUS_LISTE