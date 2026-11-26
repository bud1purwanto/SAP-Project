***INCLUDE MV50AF0F_FCODE_EXKO .
*---------------------------------------------------------------------*
*       FORM FCODE_EXKO                                               *
*---------------------------------------------------------------------*
*       Ausfuhrkontrolle im Simulationsmodus in der Lieferbearbeitung *
*---------------------------------------------------------------------*
FORM FCODE_EXKO.

  IF TVLK-EXCOK IS INITIAL.
    MESSAGE ID 'V1' TYPE 'I' NUMBER '652'.
  ENDIF.

  CALL FUNCTION 'RV_EXPORT_CONTROL_DELIVERY'
       EXPORTING
            EXPORT_DATE_NEW        = LIKP-WADAT
            CONSIGNEE_NEW          = LIKP-KUNNR
            EXPORT_NUMBER          = LIKP-EXNUM
            I_PROT_ACTIVE          = 'X'
            I_PREDECESSOR_DOCUMENT = TVLK-aufer
       TABLES
            I_VBPAVB               = XVBPA    " Partnerdaten
            I_LIPSVB               = XLIPS.    " Lieferpositionen

ENDFORM.