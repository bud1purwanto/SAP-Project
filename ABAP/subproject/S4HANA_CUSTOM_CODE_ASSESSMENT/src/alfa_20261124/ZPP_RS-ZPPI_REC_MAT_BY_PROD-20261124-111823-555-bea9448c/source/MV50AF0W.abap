***********************************************************************
*  Unterroutinen RV-Versand alphabetisch sortiert:                    *
*  -----------------------------------------------                    *
*  Buchstabe W:                                                       *
*                                                                     *
***********************************************************************

***********************************************************************
*                                                                     *
* Bereitstellen Warenempfänger aus Partnertabelle                     *
*                                                                     *
* Verwendung  in  :  SAPMV50A                                         *
*                 :  SAPLV50S                                         *
*                                                                     *
* note 96532 ALRK085781 Pop up: customer to be deleted                *
*                                                                     *
***********************************************************************



*---------------------------------------------------------------------*
*       FORM WARENEMPFAENGER_BEREITSTELLEN                             *
*---------------------------------------------------------------------*
*       Warenempfänger aus Partnertabelle lesen                       *
*       und Namen des Partners zur Verfügung stellen.                 *
*       Beim Kopieren eines Auftrages.                                *
*---------------------------------------------------------------------*
FORM warenempfaenger_bereitstellen.

  LOOP AT xvbpa WHERE vbeln EQ likp-vbeln
                AND   parvw EQ parvw_we.

    CLEAR vtcom.
    vtcom-kunnr = xvbpa-kunnr.
    vtcom-aland = tvst-aland.
    vtcom-vbeln = likp-vbeln.
    vtcom-vkorg = likp-vkorg.
    vtcom-vtweg = rv50a-vtweg.
    vtcom-spart = rv50a-spart.
    vtcom-pargr = tvlk-pargr.
    vtcom-ablad = xvbpa-ablad.
    vtcom-noablad = charx.
    IF v50agl-sammelgang NE space OR v50agl-kommirueckmeldung NE space.
      vtcom-msgkz = 'U'.
    ENDIF.
    CALL FUNCTION 'VIEW_KUWEV'
      EXPORTING
        comwa = vtcom
      IMPORTING
        wewa  = kuwev.
    IF NOT xvbpa-adrnr IS INITIAL.
      PERFORM warenempf_manuell_lesen.
*     Lines deleted n_532800
    ENDIF.
    kunnr_old = kuwev-kunnr.

  ENDLOOP.

ENDFORM.                    "warenempfaenger_bereitstellen
*eject


*---------------------------------------------------------------------*
*       FORM WARENEMPFAENGER_LIEFERSPERRE                             *
*---------------------------------------------------------------------*
*  Es wird geprüft, ob für den angegebenen Warenempfänger eine        *
*  Liefersperre vorliegt.                                             *
*---------------------------------------------------------------------*
FORM warenempfaenger_liefersperre USING wl_subrc LIKE sy-subrc.

  wl_subrc = 0.

  CHECK v50agl-no_check_delivery_block IS INITIAL.                 "AIP

  IF kuwev-lifsd NE space.
    PERFORM tvls_select USING kuwev-lifsd
                              space
                              sy-subrc.
    IF tvls-speau IS INITIAL
       OR tvlk-aufer <> 'X'.           " Problem 1141928 7/96 RM
* Problem 1141928: Liefersperre bei Umlagerungsbestellung
* wurde nicht abgefangen.
* Der folgende select darf nur übergangen werden, wenn ein Auftrag
* erforlich war und die Liefersperre aus dem Auftrag übernommen
* wurde.
*   spea = initial  entspricht y
*   aufer <> 'X'    entspricht z
*
*      aufer  !            speau
*             !    blank          X
*             -------------------------
*      blank  !      yz            z
*      X      !      y
*      B      !      yz            z
*

***     Prüfen, ob Liefersperre je Lieferart                          *
      SELECT SINGLE * FROM  tvlsp
             WHERE  lifsp       = kuwev-lifsd
             AND    lfart       = tvlk-lfart.
      IF sy-subrc = 0.
        SELECT SINGLE * FROM tvlst WHERE spras EQ sy-langu
                                   AND   lifsp EQ kuwev-lifsd.
        wl_subrc = 4.
        CLEAR: kunnr_old.
        PERFORM message_handling USING cvbap-posnr
                                       '112'
                                       'E'
                                       'VL'
                                       kuwev-kunnr
                                       kuwev-name1
                                       tvlst-vtext
                                       space.
      ENDIF.
    ENDIF.
  ENDIF.

*-------Prüfung: Boykottlistenzugehörigkeit des Warenempfaengers
  DATA: h_boyld  LIKE t001-land1,
        h_sperre LIKE sy-subrc.

  CLEAR: h_boyld,
         h_sperre.

*------- Aufruf FB zur SLS-Pruefung
  CALL FUNCTION 'FT_SLS_PARTNER_DOCUMENT_CHECK'
    EXPORTING
      i_base_document  = '2LI'
      i_partner_number = kuwev-kunnr
      i_country_knex   = space
    IMPORTING
      e_sperre         = h_sperre
      e_sls_country    = h_boyld
    EXCEPTIONS
      not_found        = 1
      OTHERS           = 2.

  IF NOT ( h_sperre IS INITIAL ).
    wl_subrc = 4.
    CLEAR: kunnr_old.
    PERFORM message_handling USING cvbap-posnr
                                   '525'
                                   'E'
                                   'V1'
                                   'WE'
                                   kuwev-kunnr
                                   h_boyld
                                   space.
  ENDIF.

ENDFORM.                    "warenempfaenger_liefersperre
*EJECT


*---------------------------------------------------------------------*
*       FORM WARENEMPF_MANUELL_KOPIEREN                               *
*---------------------------------------------------------------------*


*---------------------------------------------------------------------*
*       FORM WARENEMPF_MANUELL_LESEN                                  *
*---------------------------------------------------------------------*
FORM warenempf_manuell_lesen.

* Read XVBPA work area for the ship-to party if necessary
  IF xvbpa-parvw NE parvw_we.                               "45B/46A
    READ TABLE xvbpa WITH KEY vbeln = likp-vbeln
                              posnr = posnr_low
                              parvw = parvw_we.
    CHECK sy-subrc EQ 0.
  ENDIF.
  CHECK NOT xvbpa-adrnr IS INITIAL.
* Lesen des entsprechenden manuellen Partners
  READ TABLE xvbadr WITH KEY xvbpa-adrnr BINARY SEARCH.
  IF sy-subrc NE 0.                                         "99A/45B
    PERFORM sadr_select USING xvbpa-adrnr
                              xvbpa-adrnp
                              xvbpa-adrda.
  ENDIF.
* Versorgen der Warenempfängerdaten
  kuwev-name1 = xvbadr-name1.
  kuwev-ort01 = xvbadr-ort01.
  kuwev-land1 = xvbadr-land1.
  kuwev-lzone = xvbadr-lzone.
  kuwev-regio = xvbadr-regio.                               "50A
  kuwev-stras = xvbadr-stras.                               "46A BEY
  kuwev-pstlz = xvbadr-pstlz.
  kuwev-txjcd = xvbadr-txjcd.                               "n_568007

* Lines deleted n_532800

ENDFORM.                    "warenempf_manuell_lesen
*eject


*---------------------------------------------------------------------*
*       FORM WADAT_PRUEFEN                                            *
*---------------------------------------------------------------------*
FORM wadat_pruefen.

  IF NOT likp-vbtyp EQ vbtyp_liav.                          "v_n_619440
    IF likp-wadat IS INITIAL AND lieferung_or = charx
                             AND likp-verursys IS INITIAL.
      MESSAGE e069.
    ENDIF.
  ENDIF.                                                    "^_n_619440

ENHANCEMENT-POINT EHP_WADAT_PRUEFEN_01 SPOTS ES_SAPMV50A .


ENHANCEMENT-POINT wadat_pruefen_01 SPOTS es_sapmv50a.
ENDFORM.                    "wadat_pruefen
*---------------------------------------------------------------------*
*       FORM WARENEMPF_AENDERN                                        *
*---------------------------------------------------------------------*
FORM warenempf_aendern.
  DATA: we_fehler.
*----------------------------------------------------------------------*
* Prüfen des Status der Lieferung                                      *
*----------------------------------------------------------------------*
* Fakturastatus
  IF vbuk-fkstk CA 'BC'.
    MESSAGE i083 WITH text-013.
    we_fehler = charx.
  ENDIF.
* Kommissionierstatus
  IF vbuk-kostk CA 'BC'.
    MESSAGE i083 WITH text-016.
    we_fehler = charx.
  ENDIF.
* Darf der Warenempfänger noch geändert werden ?
  IF we_fehler EQ charx.
    kuwev-kunnr = kunnr_old.
    EXIT.
  ENDIF.
*----------------------------------------------------------------------*
* Löschen der bisher ermittelten Daten                                 *
*----------------------------------------------------------------------*
  CLEAR: kuwev-name1.
* Löschen der Partnertabelle
  LOOP AT xvbpa WHERE parvw = parvw_we.
    DELETE xvbpa.
  ENDLOOP.
  CLEAR xvbpa.
* Löschen der Nachrichtentabellen
  CALL FUNCTION 'RV_MESSAGES_REFRESH'.
* Nachrichtenvorschlag
  LOOP AT prop WHERE parvw = parvw_we.
    DELETE prop.
  ENDLOOP.
  CLEAR prop.
* Texte
  IF lieferung_or NE space.
    REFRESH xthead.
  ENDIF.
ENDFORM.                    "warenempf_aendern
*EJECT

*---------------------------------------------------------------------*
*       FORM WARENEMPF_PRUEFEN                                        *
*---------------------------------------------------------------------*
*       Es wird überprüft, ob für die Lieferung ein Warempfänger      *
*       angegeben werden darf oder muß und ggf entsprechende          *
*       Fehlermeldungen erzeugt                                       *
*       wurde der Warenempfänger zu Recht angegeben, wird er gelesen  *
*       PAER: we           Kunde angegeben        :      ok, lesen    *
*       paer: we           Kunde nicht angegeben  :      ok           *
*       paer: we  pflicht  Kunde angegeben        :      ok, lesen    *
*       paer: we  pflicht  Kunde nicht angegeben  :      Fehler       *
*       paer:              Kunde angegeben        :      Fehler       *
*       paer:              Kunde nicht angegeben  :      ok           *
*                                                                     *
*  Außerdem wird geprüft, ob für den angegebenen Warenempfänger eine  *
*  Liefersperre vorliegt.                                             *
*---------------------------------------------------------------------*
FORM warenempf_pruefen.

  IF fcode(4) = fcode_back  OR                              "46A BEY
     fcode(4) = fcode_ende.
    PERFORM funktion_ausfuehren.
  ENDIF.
  IF fcode(4) = 'VL02'      OR
     fcode(4) = 'VL03'      OR
     fcode(4) = 'VL04'.
    PERFORM fcode_bearbeiten.
  ENDIF.

  IF kuwev-name1 NE space.
    IF kuwev-kunnr NE kunnr_old.
      PERFORM warenempf_aendern.
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.

  PERFORM tpaer_select USING tvlk-pargr
                             parvw_we
                             space
                             sy-subrc.

  IF sy-subrc NE 0.
    IF kuwev-kunnr NE space.
      MESSAGE e107.
    ENDIF.
  ELSE.
    IF kuwev-kunnr NE space.
      IF kunnr_old EQ space
         OR kunnr_old NE kuwev-kunnr.
        PERFORM kuwev_select_delivery
                    USING kuwev-kunnr sy-subrc.
        PERFORM warenempf_manuell_lesen.
        PERFORM build_address_dialog.                       "n_535879
        r185d-dataloss = charx.
      ENDIF.
*----------------------------------------------------------------------*
* Nach Änderung des Warenempfängers werden Kopfdaten neu ermittelt     *
*----------------------------------------------------------------------*
      IF kunnr_old NE space AND
         kunnr_old NE kuwev-kunnr.
*----------------------------------------------------------------------*
* Neuermitteln der Kopfdaten                                           *
*----------------------------------------------------------------------*
        PERFORM likp_fuellen_kuwev(sapfv50k).
*----------------------------------------------------------------------*
* Neuermitteln der Route                                               *
*----------------------------------------------------------------------*
        PERFORM route_ermitteln(sapfv50k) USING likp-route
                                                charx
                                                sy-subrc.
*----------------------------------------------------------------------*
* Neuermitteln Export                                                  *
*----------------------------------------------------------------------*
        PERFORM likp_export_bestimmen(sapfv50k).
*----------------------------------------------------------------------*
* Neuermitteln von Texten                                              *
*----------------------------------------------------------------------*
        PERFORM likp_fuellen_texte(sapfv50k) USING space.
      ENDIF.
      kunnr_old = kuwev-kunnr.
    ELSE.
      IF tpaer-papfl EQ charx.
        MESSAGE e106.
      ENDIF.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
* Prüfen Liefersperre                                                  *
*----------------------------------------------------------------------*
  IF kuwev-kunnr NE space.
    PERFORM warenempfaenger_liefersperre USING sy-subrc.
  ENDIF.

  "del PERFORM
  "del

  SET CURSOR FIELD lips-posnr LINE sy-stepl.
ENDFORM.                    "warenempf_pruefen
*EJECT

*---------------------------------------------------------------------*
*       FORM WARENEMPF_NAME_AENDERN.                                  *
*---------------------------------------------------------------------*
FORM warenempf_name_aendern.
  DATA: BEGIN OF xvbpakey,
        mandt LIKE vbpa-mandt,
        vbeln LIKE vbpa-vbeln,
        posnr LIKE vbpa-posnr,
        parvw LIKE vbpa-parvw,
        END OF xvbpakey.

*  Wurde der Name des Warenempfängers geändert ?
  xvbpakey-mandt = sy-mandt.
  xvbpakey-vbeln = likp-vbeln.
  xvbpakey-posnr = posnr_low.
  xvbpakey-parvw = parvw_we.
  READ TABLE xvbpa WITH KEY xvbpakey BINARY SEARCH.
  IF xvbpa-name1 NE kuwev-name1
     AND xvbpa-kunnr EQ kuwev-kunnr.
    kuwev-name1 = xvbpa-name1.
  ENDIF.
ENDFORM.                    "warenempf_name_aendern
*EJECT