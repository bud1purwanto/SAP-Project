*---------------------------------------------------------------------*
*       FORM FCODE_RUEB                                               *
*---------------------------------------------------------------------*
*       Übernehmen Referenzbeleg via Dialogbaustein                   *
*---------------------------------------------------------------------*
FORM fcode_rueb.

  DATA: fr_grpos LIKE vbap-posnr,
        fr_subrc LIKE sy-subrc,
        da_subrc LIKE sy-subrc,
        BEGIN OF fr_selek OCCURS 10,
                 grpos LIKE vbap-grpos,
                uepos LIKE vbap-uepos, " UEPOS ist f.alle altern.gleich
                 count(4) TYPE p,
        END OF fr_selek.

  DATA: wa_xvbap LIKE xvbap.

* Im Fall von Wertkontraktübernahme entsprechende Positionen übernehmen
  PERFORM wertkontraktuebernahme_pos USING da_subrc.
* Wenn Position selektiert wurde, die nicht direkt übernommen werden
* darf, immer auf Positionsauswahlbild
  IF da_subrc > 0.
    ivbap_tabix_zeile_1 = 1.
    fcode = fcode_gleiche_seite.
    PERFORM fcode_bearbeiten.
    MESSAGE s433(v1).
    EXIT.
  ENDIF.

  LOOP AT ivbap WHERE selkz EQ selektiert.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
* Keine Position markiert
    MESSAGE s323.
* Wertkontraktpositionen wieder zur Verfügung stellen
    READ TABLE xvbap WITH KEY erlre = chare.
    IF sy-subrc = 0.
      PERFORM ivbap_aufbauen_alte(sapfv45p).
      ivbap_tabix_zeile_1 = 1.
    ENDIF.
    fcode = fcode_gleiche_seite.
    PERFORM fcode_bearbeiten.
    EXIT.
  ENDIF.

* Prüfen, ob bei Vollreferenz alle Positionen oder Alternativpositionen
* selektiert wurden

* Prüfen, ob mehr als eine Alternativposition gewählt wurde.

* Tabelle der zu den selektierten Positionen gehörenden Grundpositionen
* aufbauen
  IF positionsvorschlag EQ space.
    LOOP AT xvbap WHERE updkz NE updkz_delete.

      vbap = xvbap.
      MOVE-CORRESPONDING xvbap TO vbapd.
* Untergeordnete Positionen werden wegen der Alternativpositionen
* nur berücksichtigt, wenn die übergeordnete Position selektiert ist.
      IF vbap-uepos > 0.
        IF vbapd-attyp EQ var_typ.
          READ TABLE ivbap WITH KEY vbap-posnr BINARY SEARCH.
        ELSE.
          READ TABLE ivbap WITH KEY vbap-uepos BINARY SEARCH.
        ENDIF.
      ENDIF.
      IF ( sy-subrc = 0 AND
         ivbap-selkz = selektiert ) OR
         vbap-uepos = 0.
* Ist die Position gemäss Bedingung relevant ?
        PERFORM vbap_kopieren_pruefen_einzeln(sapfv45c) USING sy-subrc.
        CHECK sy-subrc = 0.

        CLEAR fr_selek.
        IF xvbap-grpos = 0.
          fr_grpos = vbap-posnr.
        ELSE.
          fr_grpos = vbap-grpos.
        ENDIF.
        READ TABLE ivbap WITH KEY vbap-posnr BINARY SEARCH.
        READ TABLE fr_selek WITH KEY fr_grpos BINARY SEARCH.
        IF sy-subrc = 0.
          IF ivbap-selkz = selektiert.
            IF fr_selek-count = 9999.
              fr_selek-count = 1.
            ELSE.
              fr_selek-count = fr_selek-count + 1.
            ENDIF.
          ELSE.
            IF fr_selek-count = 9999.
              fr_selek-count = 0.
            ENDIF.
          ENDIF.
          MODIFY fr_selek INDEX sy-tabix.
        ELSE.
          fr_selek-grpos = fr_grpos.
          IF ivbap-selkz = selektiert.
            fr_selek-count = 1.
          ELSE.
            IF NOT vbap-uepos IS INITIAL AND
               vbap-stlkn IS INITIAL.
              fr_selek-count = 9999.
            ELSE.
              fr_selek-count = 0.
            ENDIF.
          ENDIF.
          fr_selek-uepos = vbap-uepos.
* immer append, da die Positionen sortiert kommen
          APPEND fr_selek.
        ENDIF.
      ENDIF.
    ENDLOOP.

* jede Position muss selbst oder ihre Grundposition selektiert sein
    LOOP AT fr_selek.
* keine Alternative gewählt und Vollreferenz --> Fehler
* Alternative Unterposition nicht selektiert --> Fehler
      IF ( fr_selek-count = 0 AND
           tvcpa-voref NE space ) OR
         ( fr_selek-count = 0 AND
           fr_selek-uepos > 0 ).
        rv45a-posnr = fr_selek-grpos.
        IF cl_ops_switch_check=>ops_sfws_sc_advret2( ) = abap_true.
* ARM II
        ELSE.
          MESSAGE s485 WITH fr_selek-grpos.
          fr_subrc = 4.
          EXIT.
        ENDIF.
      ENDIF.
* mehrere Alternativen gewählt
* und kein Angebot
      IF fr_selek-count > 1 AND
         NOT fr_selek-count = 9999.
        IF *tvak-vbtyp CN 'AB'.
          MESSAGE s486 WITH fr_selek-grpos.
* damit die Anzeige auf der betreffenden Position aufsetzt
          rv45a-posnr = fr_selek-grpos.
          fr_subrc = 4.
          EXIT.
        ELSE.
          MESSAGE i023 WITH fr_selek-grpos.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF fr_subrc = 4.
      PERFORM xvbap_positionieren(sapfv45p).
      fcode = fcode_gleiche_seite.
      PERFORM fcode_bearbeiten.
      EXIT.
    ENDIF.
  ENDIF.

* Nicht selektierte Positionen löschen
  LOOP AT ivbap WHERE selkz NE selektiert.
    DELETE ivbap.
  ENDLOOP.

  LOOP AT xvbap.
    READ TABLE ivbap WITH KEY xvbap-posnr BINARY SEARCH.
    IF sy-subrc > 0.
      CLEAR fr_selek.
      READ TABLE fr_selek WITH KEY xvbap-posnr BINARY SEARCH.
* Unterpositionen werden gelöscht, wenn sie nicht explizit gewählt sind,
* und ihre übergeordnete Position nicht,
* oder sie sind nicht selektierte Alternativpositionen
      IF xvbap-uepos IS INITIAL     OR
         NOT xvbap-grpos IS INITIAL OR
         xvbap-attyp EQ var_typ.
        xvbap-updkz = updkz_delete.
        MODIFY xvbap.
      ELSE.
        READ TABLE xvbap INTO wa_xvbap WITH KEY posnr = xvbap-uepos.
        IF sy-subrc = 0 AND
*          nicht selektierte Unterposition wird gelöscht
           NOT xvbap-uepos IS INITIAL AND
           ( xvbap_umfang = 'A' OR
             fr_selek-uepos IS INITIAL ) AND
           ( ( xvbap-uepvw IS INITIAL AND
               xvbap-stlnr IS INITIAL ) OR
             ( NOT xvbap-uepvw IS INITIAL OR
               NOT xvbap-stlnr IS INITIAL ) AND
             wa_xvbap-updkz = updkz_delete ).
          xvbap-updkz = updkz_delete.
          MODIFY xvbap.
        ENDIF.
      ENDIF.
      IF cl_ops_switch_check=>ops_sfws_sc_advret2( ) = abap_true.
* ARM II
        xvbap-updkz = updkz_delete.
        MODIFY xvbap.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Das Löschen der entsprechenden Einträge aus der Partnertabelle
* erfolgt in der Routine 'FV45CF0C_CVBPA_UEBERARBEITEN'

ENHANCEMENT-POINT FCODE_RUEB_01 SPOTS ES_SAPMV45A.

  PERFORM fcode_leave(saplv00f).

ENDFORM.                    "FCODE_RUEB