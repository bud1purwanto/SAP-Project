*&--------------------------------------------------------------------*
*&      Form  MATNR_PRUEFEN_PRODH                                     *
*&--------------------------------------------------------------------*
*       Prüft, ob ein Material zur gegebenen Produkthierarchie        *
*       gehört oder nicht                                             *
*       US_SUBRC = 0: Stimmt überein                                  *
*       US_SUBRC = 1: Keine generische Suche, paßt nicht              *
*       US_SUBRC = 4: Generische Suche, paßt nicht                    *
*---------------------------------------------------------------------*
FORM MATNR_PRUEFEN_PRODH USING PRODH      LIKE VBAP-PRODH
                               VBAP_PRODH LIKE VBAP-PRODH
                               US_SUBRC.

  DATA: DA_PRODH LIKE VBAP-PRODH,
        DA_SUBRC LIKE SY-SUBRC.

  DA_SUBRC = 0.
  DA_PRODH = PRODH.

* Prüfen, ob generisch gesucht werden soll
  SEARCH PRODH FOR '**'.
  CASE SY-SUBRC.
*   Generische Suche
    WHEN 0.
      REPLACE CHAR* WITH SPACE INTO DA_PRODH.
      SEARCH VBAP_PRODH FOR DA_PRODH STARTING AT 1.
      DA_SUBRC = SY-SUBRC.
*   Überprüfung auf exakte Übereinstimmung
    WHEN 4.
      IF VBAP_PRODH NE PRODH.
        DA_SUBRC = 1.
      ENDIF.
  ENDCASE.

  US_SUBRC = DA_SUBRC.

ENDFORM.