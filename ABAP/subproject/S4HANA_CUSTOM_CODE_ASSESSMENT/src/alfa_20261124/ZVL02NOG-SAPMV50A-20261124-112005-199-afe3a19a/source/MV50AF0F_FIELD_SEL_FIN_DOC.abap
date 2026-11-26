***INCLUDE MV50AF0F_FIELD_SEL_FIN_DOC .
*&---------------------------------------------------------------------*
*&      Form  FIELD_SEL_FIN_DOC
*&---------------------------------------------------------------------*
*       Steuerung der Feldauswahl fuer die Risikomanagementfelder /
*       Finanzdokumentfelder:
*       Finanzdokumentnummer, Abschreibungsprozentsatz, Absicherungs-
*       schema nur eingabebereit, wenn nicht bereits im Auftrag
*       gefuellt ODER wenn Lieferung nicht bereits (teil-) fakturiert
*       ist
*       Finanzdokumentdaten werden nicht angezeigt, enn Absicherungs-
*       Finanzdokumentnummer wird nicht angezeigt, wenn Absicherungs-
*       schema nicht gefuellt ist
*----------------------------------------------------------------------*
FORM FIELD_SEL_FIN_DOC.

  DATA: H_FIN_DOC_MAINT        TYPE C          VALUE ' ',
        H_RISK_MGMT_PROC_MAINT TYPE C          VALUE ' ',
        H_LCNUM                LIKE VBKD-LCNUM,
        H_ABSSC                LIKE VBKD-ABSSC.

  IF VBUK-FKSTK CA 'BC'.               " LF bereits (teil-)beliefert
    SCREEN-INPUT = 0.

  ELSE.
    IF LIKP-ABSSC IS INITIAL AND       " Ausblenden FD wenn ASchema
       LIKP-LCNUM IS INITIAL.          " initial
      IF SCREEN-GROUP3 EQ 'FDN'.
        SCREEN-ACTIVE = 0.
      ENDIF.
    ELSE.
      IF ( screen-name eq 'LIKP-ABSSC' ) .
        SCREEN-INPUT = 0.
      endif.

      IF SCREEN-GROUP3 EQ 'FDN'.       " Finanzdokumentdaten
        IF CVBKD-LCNUM IS INITIAL.
          H_LCNUM = VBKD-LCNUM.
        ELSE.
          H_LCNUM = CVBKD-LCNUM.
        ENDIF.
*------- Ist Finanzdokument bereits im Auftrag zugeordnet ?
        CALL FUNCTION 'RV_LOC_ORDER_DATA_RETRIEVE'
          EXPORTING
            I_FIN_DOC_NUMBER     = H_LCNUM
          IMPORTING
            E_FIN_DOC_MAINTAINED = H_FIN_DOC_MAINT
          EXCEPTIONS
            OTHERS               = 1.

        IF NOT ( H_FIN_DOC_MAINT IS INITIAL ) OR
           NOT ( SY-SUBRC        IS INITIAL ).
          SCREEN-INPUT = 0.
        ENDIF.

      ENDIF.

      IF SCREEN-GROUP3 EQ 'RSK'.       " Absicherungsschema
        IF CVBKD-ABSSC IS INITIAL.
          H_ABSSC = VBKD-ABSSC.
        ELSE.
          H_ABSSC = CVBKD-ABSSC.
        ENDIF.
*------- Ist Absicherungsschema bereits im Auftrag zugeordnet ?
        CALL FUNCTION 'RV_LOC_ORDER_DATA_RETRIEVE'
          EXPORTING
            I_RISK_MGMT_PROC            = H_ABSSC
          IMPORTING
            E_RISK_MGMT_PROC_MAINTAINED = H_RISK_MGMT_PROC_MAINT
          EXCEPTIONS
            OTHERS                      = 1.

        IF NOT ( H_RISK_MGMT_PROC_MAINT IS INITIAL ) OR
           NOT ( SY-SUBRC               IS INITIAL ).
          SCREEN-INPUT = 0.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                               " FIELD_SEL_FIN_DOC