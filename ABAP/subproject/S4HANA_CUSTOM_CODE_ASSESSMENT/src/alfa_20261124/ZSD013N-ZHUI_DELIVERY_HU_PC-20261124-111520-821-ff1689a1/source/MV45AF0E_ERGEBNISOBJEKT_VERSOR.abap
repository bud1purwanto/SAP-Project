*----------------------------------------------------------------------*
*   INCLUDE MV45AF0E_ERGEBNISOBJEKT_VERSOR                             *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM ERGEBNISOBJEKT_VERSORGEN                                 *
*---------------------------------------------------------------------*
*       Ergebnisobjekt mit der aktuellen Belegnummer versorgen        *
*       (muß unbedingt nach der internen Nummernvergabe laufen,       *
*       aber vor dem Anlegen des endgültigen CO-Objektes!)            *
*---------------------------------------------------------------------*
FORM ergebnisobjekt_versorgen.

  DATA: da_kzvbr LIKE vbap-kzvbr.
  DATA: BEGIN OF da_xvbpa OCCURS 10.
          INCLUDE STRUCTURE vbpavb.
  DATA: END OF da_xvbpa.
  DATA: BEGIN OF da_xvbfa OCCURS 0.
          INCLUDE STRUCTURE vbfavb.
  DATA: END OF da_xvbfa.


  CHECK *vbak-vbeln IS INITIAL.

* XVBPA alten Stand sichern, damit spätere Zugriffe auf Partnertabelle
* mit Belegnummer blank erfolgreich sind.
  da_xvbpa[] = xvbpa[].

  da_xvbfa[] = xvbfa[].

* Für Routine ERGEBNISOBJEKT_VERSORGEN Partner mit Belegnummer versehen
  PERFORM vbeln_in_partner.

  LOOP AT xvbap WHERE updkz NE updkz_delete  AND
                      NOT paobjnr IS initial.

    svbap-tabix = sy-tabix.
    PERFORM vbap_bearbeiten_vorbereiten(sapfv45p).

    vbap-vbeln = vbak-vbeln.

    IF vbap-kzvbr EQ *vbap-kzvbr.
      da_kzvbr = *vbap-kzvbr.
      CLEAR *vbap-kzvbr.         "Sonst läuft VBAP-VBELV_ERMITTELN nicht
    ENDIF.
    PERFORM vbap-vbelv_ermitteln(sapfv45p).
     *vbap-kzvbr = da_kzvbr.

    PERFORM cobl_fuellen(sapfv45p) USING vbak
                                         vbap
                                         vbkd
                                         cobl. "relevant for the PAOBJNR

ENHANCEMENT-POINT ERGEBNISOBJEKT_VERSORGEN_01 SPOTS ES_SAPMV45A.
    PERFORM ergebnisobjekt_aktualisieren(sapfv45p).

* Abrechnungsvorschrift nur aktualisieren, wenn sich tatsächlich die
* Ergebnisobjektnummer geändert hat
    IF vbap-paobjnr NE *vbap-paobjnr.
*--------------- Anfang * Unnötig, da ERGEBNISOBJEKT_VERSOR jetzt läuft
*-----------------------* bevor die echte OBJNR vergeben wird
*     PERFORM t459k_lesen(sapmv45a).
*     IF NOT t459k-aprof IS INITIAL.
*
** Check first, if default rule is allowed in settlement profile
*     CALL FUNCTION 'K_KONTY_CHECK'
*             EXPORTING
*                  aprof             = t459k-aprof
*                  konty             = objektart_eo
*             EXCEPTIONS
*                  konty_not_allowed = 1
*                  OTHERS            = 2.
*
*     IF sy-subrc = 0.
*
*       CALL FUNCTION 'OBJECT_NUMBER_GET_TM'
*               EXPORTING
*                    obart = objektart_vb
*               IMPORTING
*                    objnr = *vbap-objnr.
*
*       PERFORM aufteilungsregel_umbenennen(sapfv45p)
*                                USING vbap-objnr
*                                      *vbap-objnr.
*--------------- Ende --------------------------------------------------
      PERFORM aufteilungsregel_aktualisieren(sapfv45p).
*   ENDIF.
*   ENDIF.

* Gegebenenfalls Banfen aktualisieren
      LOOP AT xvbep WHERE posnr EQ vbap-posnr
                        AND wmeng GT 0
                        AND updkz NE updkz_delete
                        AND bnfpo GT 0.
        svbep-tabix = sy-tabix.
        PERFORM vbep_bearbeiten_vorbereiten(sapfv45e).
* ... Flags setzen, um den Sprung in Beschaffung_Aendern zu erreichen
        CLEAR beschaffung_erfolgt.
        vbap_ende_verfuegbarkeit = charx.
        PERFORM vbep_bearbeiten_beschaffung(sapfv45e).
* Ergebnis abholen ist hier nicht nötig
      ENDLOOP.
    ENDIF.

* Geänderte Daten wieder zurücksetzen
    vbap-vbeln = *vbap-vbeln.
    vbap-vbelv = *vbap-vbelv.
    vbap-posnv = *vbap-posnv.

    PERFORM xvbap_aendern(sapfv45p).

  ENDLOOP.

* XVBPA wieder mit vorherigem Stand versorgen
  CLEAR xvbpa.
  xvbpa[] = da_xvbpa[].

  CLEAR xvbfa.
  xvbfa[] = da_xvbfa[].


ENDFORM.                    "ergebnisobjekt_versorgen