***INCLUDE MV50AF0F_FCODE_IFDH .
*----------------------------------------------------------------------*
*       FORM FCODE_IFDH
*----------------------------------------------------------------------*
*       Anlegen Finanzdokument
*       Vorschlag der Akkreditivwerte aus Absicherungsschema
*----------------------------------------------------------------------*
FORM FCODE_IFDH.

  DATA: DA_AKART LIKE T691K-AKART,
        DA_AKKTP LIKE T691K-AKKTP,
        loc_back_to_report(1) TYPE c.

  IF NOT ( LIKP-LCNUM IS INITIAL ).
    MESSAGE I578(EI).

  ELSE.
*------- Aufruf Riskmanagement
    CALL FUNCTION 'SD_ORDER_RISK_CHECK'
         EXPORTING
              I_ABSTP             = '0'
              I_ABSSC             = LIKP-ABSSC
         IMPORTING
              E_AKART             = DA_AKART
              E_AKKTP             = DA_AKKTP
         EXCEPTIONS
              SECURITY_NOT_ACTIVE = 4.

*------- Ausgabe Info-Message
    IF NOT ( SY-SUBRC IS INITIAL ).
      MESSAGE W573(EI) WITH LIKP-ABSSC.
    ENDIF.

*------- Vorbelegung der Variablen fuer Anlegen Finanzdokument
    SET PARAMETER ID 'AKA' FIELD DA_AKART.
    SET PARAMETER ID 'AKY' FIELD DA_AKKTP.
    SET PARAMETER ID 'BUK' FIELD TVKO-BUKRS.
    loc_back_to_report = 'X'.
    EXPORT loc_back_to_report TO MEMORY ID 'SAP_FT_LOC_MASTER'.

*------- Vorbelegung der Variablen fuer Datenrueckuebernahme
    FCODE_IFDH_ACTIVATED = 'X'.

  ENDIF.

ENDFORM.                               " FCODE_IFDH