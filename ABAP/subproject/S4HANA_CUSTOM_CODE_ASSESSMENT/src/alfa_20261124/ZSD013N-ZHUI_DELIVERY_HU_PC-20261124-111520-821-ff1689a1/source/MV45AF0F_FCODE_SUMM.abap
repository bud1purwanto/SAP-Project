*---------------------------------------------------------------------*
*       FORM FCODE_SUMM                                               *
*---------------------------------------------------------------------*
*       Report Kurzanzeige Lieferabruf                                *
*---------------------------------------------------------------------*
FORM FCODE_SUMM USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.


* Arbeitstabelle für die Einteilungen
  DATA:    BEGIN OF DA_XVBEP OCCURS 150.
          INCLUDE STRUCTURE VBEPVB.
  DATA:    END OF DA_XVBEP.

* Arbeitstabelle zum Belegfluß
  DATA:    BEGIN OF DA_XVBFA OCCURS 0.
          INCLUDE STRUCTURE VBFAVB.
  DATA:    END OF DA_XVBFA.



  T185  = H185.
  T185F = H185F.
  T185V = H185V.

* Belegfluß in Arbeitstabelle übernehmen
  LOOP AT XVBFA INTO DA_XVBFA WHERE VBELV EQ VBAK-VBELN
                              AND POSNV EQ VBAP-POSNR
                              AND UPDKZ NE UPDKZ_DELETE.
    APPEND DA_XVBFA.
  ENDLOOP.

* Einteilungen in Arbeitstabelle übernehmen
  LOOP AT XVBEP INTO DA_XVBEP WHERE VBELN EQ VBAK-VBELN
                              AND POSNR EQ VBAP-POSNR
                              AND UPDKZ NE UPDKZ_DELETE.
    APPEND DA_XVBEP.
  ENDLOOP.
  CALL FUNCTION 'SD_SHOW_SUMMARY_DELIVERIES'
       EXPORTING
            I_VBAK  = VBAK
            I_VBAP  = VBAP
            I_VBLB  = VBLB
            I_KUAGV = KUAGV
            I_KUWEV = KUWEV
            I_VBAPD = VBAPD
            I_TVAK  = TVAK
            I_RV45Z = RV45Z
       TABLES
            FXVBEP  = DA_XVBEP
            FXVBFA  = DA_XVBFA.



  H185  = T185.
  H185F = T185F.
  H185V = T185V.

  FCODE = T185F-FCODE.

ENDFORM.