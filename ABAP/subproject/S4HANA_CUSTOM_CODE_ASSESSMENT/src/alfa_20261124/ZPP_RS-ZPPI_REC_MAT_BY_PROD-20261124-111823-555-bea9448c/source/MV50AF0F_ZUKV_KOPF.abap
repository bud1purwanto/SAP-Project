***INCLUDE MV50AF0F_ZUKV_KOPF .
*---------------------------------------------------------------------*
*       FORM FCODE_ZUKV_KOPF                                          *
*---------------------------------------------------------------------*
*       Anzeige Kreditversicherung auf Kopfebene                      *
*---------------------------------------------------------------------*
FORM FCODE_ZUKV_KOPF USING US_T185F STRUCTURE T185F
                           US_T185  STRUCTURE T185
                           US_T185V STRUCTURE T185V.

  CALL FUNCTION 'SD_RISK_EXTERNAL_MENUE'
       EXPORTING
            I_DOCUMENT = LIKP-VBELN
            I_AKTYP    = US_T185F-AKTYP
       EXCEPTIONS
            NO_CONTRACT = 4.
  IF SY-SUBRC = 4.
    MESSAGE S781(V1).
  ENDIF.
ENDFORM.