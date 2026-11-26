*---------------------------------------------------------------------*
*       FORM BEDARF_FUELLEN                                           *
*---------------------------------------------------------------------*
*       Verbuchungssätze Bedarf übernehmen                            *
*---------------------------------------------------------------------*
FORM BEDARF_FUELLEN
     TABLES IT_XVBAP_MODIFY_REQUIREMENTS STRUCTURE VBAPVB
            IT_YVBAP_MODIFY_REQUIREMENTS STRUCTURE VBAPVB.

  DATA: DA_TRTYP LIKE T180-TRTYP,
        da_vbap LIKE vbapvb,
        lt_qtvb TYPE qtvbd OCCURS 0.

* Einzel- und Summenbedarfssätze abrufen, die Tabellen sind sortiert
  CHECK BEDARF_TRENNEN NE SPACE.

* Zusagedaten werden verwaltet
  IF NOT TVAK-DELCF IS INITIAL.
    LOOP AT XVBAP INTO DA_VBAP
                  WHERE UPDKZ NE UPDKZ_DELETE.
* Zusagedaten aus den Einteilungen löschen
      PERFORM VBEP_ZUSAGE_BERECHNEN(SAPFV45E) USING DA_VBAP-VBELN
                                                    DA_VBAP-POSNR
                                                    SPACE.
    ENDLOOP.
  ENDIF.

* In the case of a rush order: Sales requirements have to be modified
* for undelivered or deleted items, see subprogram LIEFERUNG_ERZEUGEN
  lt_qtvb[] = xqtvb[].
  IF NOT it_xvbap_modify_requirements[] IS INITIAL
  OR NOT IT_YVBAP_MODIFY_REQUIREMENTS[] IS INITIAL.
    CALL FUNCTION 'RV_REQUIREMENT_GENERATE'
         EXPORTING
              FVBAK       = VBAK
              VKORG_SPRAS = TVKO_SADR-SPRAS
         TABLES
              XVBAPF      = XVBAPF
              XVBUP       = XVBUP
              YVBUP       = YVBUP
              XVBAP       = IT_XVBAP_MODIFY_REQUIREMENTS
              YVBAP       = IT_YVBAP_MODIFY_REQUIREMENTS
              XVBEP       = XVBEP
              YVBEP       = YVBEP
              VVBAP       = VVBAP
              VVBEP       = VVBEP
              XVBPA       = XVBPA
        avbbd       = avbbd
        xqtvb       = lt_qtvb
        yqtvb       = yqtvb.
* TRTYP auf 'X' um im RV_REQUIREMENT_SEPARATE nicht zu initialisieren.
    DA_TRTYP = CHARX.

* Normaler Aufruf
  ELSE.
    CALL FUNCTION 'RV_REQUIREMENT_GENERATE'
         EXPORTING
              FVBAK       = VBAK
              VKORG_SPRAS = TVKO_SADR-SPRAS
         TABLES
              XVBAPF      = XVBAPF
              XVBUP       = XVBUP
              YVBUP       = YVBUP
              XVBAP       = XVBAP
              YVBAP       = YVBAP
              XVBEP       = XVBEP
              YVBEP       = YVBEP
              VVBAP       = VVBAP
              VVBEP       = VVBEP
              XVBPA       = XVBPA
        avbbd       = avbbd
        xqtvb       = lt_qtvb
        yqtvb       = yqtvb.
    DA_TRTYP = T180-TRTYP.

  ENDIF.

* Bei Neuterminierung tatsächliche Bedarfe (nach Kreditlimit etc.)
* ins Memory schreiben
  IF CALL_ACTIVITY EQ ACTIVITY_ATP_AREA.
    CALL FUNCTION 'RV_REQUIREMENT_EXPORT'.
  ENDIF.

  CALL FUNCTION 'RV_REQUIREMENT_SEPARATE'
       EXPORTING
            TRTYP = DA_TRTYP
       TABLES
            XVBBE = XVBBE
            XVBBS = XVBBS
            YVBBE = YVBBE
            YVBBS = YVBBS.

* Zusagedaten wieder einmischen
  IF NOT TVAK-DELCF IS INITIAL.
    PERFORM VBEP_ZUSAGE_ERMITTELN(SAPFV45E) USING *VBAK-VBELN
                                                  POSNR_LOW.
  ENDIF.

ENDFORM.                    "BEDARF_FUELLEN