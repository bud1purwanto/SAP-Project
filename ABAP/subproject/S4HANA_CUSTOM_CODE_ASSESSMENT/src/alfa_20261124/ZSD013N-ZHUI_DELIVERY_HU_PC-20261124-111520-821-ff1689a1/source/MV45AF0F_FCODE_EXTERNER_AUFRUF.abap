*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_EXTERNER_AUFRUF                             *
*----------------------------------------------------------------------*
FORM FCODE_EXTERNER_AUFRUF USING US_FCODE LIKE T185F-FCODE
                                 US_POSNR LIKE VBAP-POSNR
                                 US_ETENR LIKE VBEP-ETENR.
  INCLUDE FV45ELOC.
  INCLUDE FV45PLOC.
  LOCAL: VBEP, VBAP, XVBEP, XVBAP, FCODE, T185, T185F, T185V.

* Position lesen
  PERFORM XVBAP_LESEN_DIREKT(SAPFV45P)
    USING    US_POSNR
    CHANGING SVBAP-TABIX.

* Position bereitstellen
  PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).

* Einteilung dazulesen
  IF NOT US_ETENR IS INITIAL.
    PERFORM XVBEP_LESEN_DIREKT(SAPFV45E)
      USING    US_POSNR
               US_ETENR
      CHANGING SVBEP-TABIX.
  ENDIF.

* Einteilung bereitstellen
  PERFORM VBEP_BEARBEITEN_VORBEREITEN(SAPFV45E).

  CASE US_FCODE.
    WHEN 'IHKZ'.
      FCODE = US_FCODE.
      PERFORM BESCHAFFUNG_DETAIL(SAPFV45E) USING T185F
                                                 T185
                                                 T185V.
  ENDCASE.
ENDFORM.