
*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_IFDH                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       FORM FCODE_IFDH
*----------------------------------------------------------------------*
*       Anlegen Finanzdokument
*       Vorschlag der Akkreditivwerte aus Absicherungsschema
*----------------------------------------------------------------------*
FORM FCODE_IFDH.

  DATA: DA_AKART LIKE T691K-AKART,
        DA_AKKTP LIKE T691K-AKKTP,
        lf_from_doc TYPE char1.

  IF NOT ( VBKD-LCNUM IS INITIAL ).
    MESSAGE I578(EI).
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.

  ELSE.
*------- Aufruf Riskmanagement
    CALL FUNCTION 'SD_ORDER_RISK_CHECK'
         EXPORTING
              I_ABSTP             = '0'
              I_ABSSC             = VBKD-ABSSC
         IMPORTING
              E_AKART             = DA_AKART
              E_AKKTP             = DA_AKKTP
         EXCEPTIONS
              SECURITY_NOT_ACTIVE = 4.

*------- Ausgabe Info-Message
    IF NOT ( SY-SUBRC IS INITIAL ).
      MESSAGE W573(EI) WITH VBKD-ABSSC.
*    fcode = fcode_gleiche_seite.
*    perform fcode_bearbeiten.
    ENDIF.

*------- Vorbelegung der Variablen fuer Anlegen Finanzdokument
    SET PARAMETER ID 'AKA' FIELD DA_AKART.
    SET PARAMETER ID 'AKY' FIELD DA_AKKTP.
    SET PARAMETER ID 'BUK' FIELD TVKO-BUKRS.
    lf_from_doc = 'X'.
    EXPORT lf_from_doc FROM lf_from_doc TO MEMORY ID 'FDTWZ007'.

*------- Vorbelegung der Variablen fuer Datenrueckuebernahme
    FCODE_IFDH_ACTIVATED = 'X'.

  ENDIF.

ENDFORM.                               " FCODE_IFDH