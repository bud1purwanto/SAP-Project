*&---------------------------------------------------------------------*
*&      Form  VAKPA_ABRUF_SELECT
*&---------------------------------------------------------------------*
*       Zusätzlich zum Hinweis auf Rahmenverträge wird hier die        *
*       Liste um zusätzliche Hinweise ergänzt.                         *
*----------------------------------------------------------------------*
FORM VAKPA_ABRUF_SELECT USING US_KUNNR
                              US_TRVOG
                              US_HINWEIS
                              CH_HEADER_EXIST.

  DATA: DA_SUBRC LIKE SY-SUBRC.
  DATA: BEGIN OF LIST_HIERARCHIE OCCURS 0.
          INCLUDE STRUCTURE VBPAVB.
  DATA: END OF LIST_HIERARCHIE.
  DATA: LS_TVTA LIKE TVTA.

* Liste Kontrakte laut Kontrakt
  IF US_HINWEIS CA 'AC'.
    SELECT * FROM VAKPA_REF WHERE KUNDE = US_KUNNR AND
                                  PARVW = 'AA' AND
                                  TRVOG = US_TRVOG AND
                                  VBTYP NE VBTYP_GRUKO AND
                                  ( ABRUF_PART = ' ' OR
                                    ABRUF_PART = 'A' ) AND
                                  ( GBSTK = ' ' OR
                                    GBSTK = 'A' OR
                                    GBSTK = 'B' ).

*     Gültigkeitszeitraum prüfen
      CHECK ( VAKPA_REF-DATAB <= VBAK-VDATU AND
              VAKPA_REF-DATBI >= VBAK-VDATU ) OR
              VBAK-VDATU IS INITIAL.

*     Liste füllen
      IF DA_SUBRC EQ 0.
        CH_HEADER_EXIST = CHARX.
        HNW_VBAK-VBELN = VAKPA_REF-VBELN.
        HNW_VBAK-DATAB = VAKPA_REF-DATAB.
        HNW_VBAK-DATBI = VAKPA_REF-DATBI.
        HNW_VBAK-TRVOG = VAKPA_REF-TRVOG.
        HNW_VBAK-AUART = VAKPA_REF-AUART.
        HNW_VBAK-KUNNR = VAKPA_REF-KUNNR.
        APPEND HNW_VBAK.
      ENDIF.
    ENDSELECT.
  ENDIF.

* Liste Kontrakte laut Kundenhierarchie
  IF US_HINWEIS CA 'BC'.

*   Umschlüsselung auf gemeinsamen Vertriebsbereich
    CALL FUNCTION 'TVTA_SINGLE_READ'
         EXPORTING
              I_VKORG         = VBAK-VKORG
              I_VTWEG         = VBAK-VTWEG
              I_SPART         = VBAK-SPART
         IMPORTING
              O_TVTA          = LS_TVTA
         EXCEPTIONS
              NOT_FOUND       = 1
              PARAMETER_ERROR = 2
              OTHERS          = 3.
    IF SY-SUBRC = 0.
*     Kundenhierarchie mit AUDAT und VTWKU/SPAKU lesen
      CALL FUNCTION 'SD_CUSTOMER_HIERARCHY_PATH'
           EXPORTING
                CUSTOMER        = US_KUNNR
                DATE            = VBAK-AUDAT
                HTYPE           = VBAK-HITYP_PR
                SALES_ORG       = VBAK-VKORG
                SALES_CHANNEL   = LS_TVTA-VTWKU
                SALES_DIVISION  = LS_TVTA-SPAKU
           TABLES
                HPATH           = LIST_HIERARCHIE
           EXCEPTIONS
                HITYP_NOT_EXIST = 1
                NODE_NOT_EXIST  = 2
                PARVW_NOT_EXIST = 3.
    ELSE.
*     Kundenhierarchie mit AUDAT lesen
      CALL FUNCTION 'SD_CUSTOMER_HIERARCHY_PATH'
         EXPORTING
              CUSTOMER        = US_KUNNR
              DATE            = VBAK-AUDAT
              HTYPE           = VBAK-HITYP_PR
              SALES_ORG       = VBAK-VKORG
              SALES_CHANNEL   = VBAK-VTWEG
              SALES_DIVISION  = VBAK-SPART
         TABLES
              HPATH           = LIST_HIERARCHIE
         EXCEPTIONS
              HITYP_NOT_EXIST = 1
              NODE_NOT_EXIST  = 2
              PARVW_NOT_EXIST = 3.
    ENDIF.

    IF SY-SUBRC EQ 0.
      LOOP AT LIST_HIERARCHIE.
        SELECT * FROM VAKPA_REF WHERE KUNDE = LIST_HIERARCHIE-KUNNR AND
                                      PARVW = 'AG' AND
                                      TRVOG = US_TRVOG AND
                                      VBTYP NE VBTYP_GRUKO AND
                                      ABRUF_PART = 'B' AND
                                      ( GBSTK = ' ' OR
                                        GBSTK = 'A' OR
                                        GBSTK = 'B' ).

*         Gültigkeitszeitraum prüfen
          CHECK ( VAKPA_REF-DATAB <= VBAK-VDATU AND
                  VAKPA_REF-DATBI >= VBAK-VDATU ) OR
                  VBAK-VDATU IS INITIAL.

*         Liste füllen
          IF DA_SUBRC EQ 0.
            CH_HEADER_EXIST = CHARX.
            HNW_VBAK-VBELN = VAKPA_REF-VBELN.
            HNW_VBAK-DATAB = VAKPA_REF-DATAB.
            HNW_VBAK-DATBI = VAKPA_REF-DATBI.
            HNW_VBAK-TRVOG = VAKPA_REF-TRVOG.
            HNW_VBAK-AUART = VAKPA_REF-AUART.
            HNW_VBAK-KUNNR = VAKPA_REF-KUNNR.
            APPEND HNW_VBAK.
          ENDIF.
        ENDSELECT.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.