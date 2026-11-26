*---------------------------------------------------------------------*
*       FORM FCODE_ZUKV_POSITION                                      *
*---------------------------------------------------------------------*
*       Anzeige Kreditversicherung auf Positionsebene                 *
*---------------------------------------------------------------------*
FORM FCODE_ZUKV_POSITION USING US_T185F STRUCTURE T185F
                               US_T185
                               US_T185V.

  CALL FUNCTION 'SD_RISK_EXTERNAL_MENUE'
       EXPORTING
            I_DOCUMENT = VBAK-VBELN
            I_ITEM     = VBAP-POSNR
            I_AKTYP    = US_T185F-AKTYP
       EXCEPTIONS
            NO_CONTRACT = 4.
  IF SY-SUBRC = 4.
    MESSAGE S781.
  ENDIF.
ENDFORM.