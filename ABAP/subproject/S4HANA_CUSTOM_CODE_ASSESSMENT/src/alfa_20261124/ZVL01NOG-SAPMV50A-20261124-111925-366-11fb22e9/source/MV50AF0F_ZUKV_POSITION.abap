***INCLUDE MV50AF0F_ZUKV_POSITION .
*---------------------------------------------------------------------*
*       FORM FCODE_ZUKV_POSITION                                      *
*---------------------------------------------------------------------*
*       Anzeige Kreditversicherung auf Positionsebene                 *
*---------------------------------------------------------------------*
FORM FCODE_ZUKV_POSITION USING US_T185F STRUCTURE T185F
                               US_T185
                               US_T185V.

  DATA: LF_POSNR TYPE POSNR_VL.

  CASE TAXI_SCREEN_GROUP.
    WHEN C_TAXI_SCRGRP_ITEM.
      LF_POSNR = GS_LIPS_MAIN-POSNR.
    WHEN C_TAXI_SCRGRP_BATCH.
      LF_POSNR = GS_LIPS_CHSP-POSNR.
    WHEN OTHERS.
      LF_POSNR = LIPS-POSNR.
  ENDCASE.

  CALL FUNCTION 'SD_RISK_EXTERNAL_MENUE'
       EXPORTING
            I_DOCUMENT  = LIKP-VBELN
            I_ITEM      = LIPS-POSNR
            I_AKTYP     = US_T185F-AKTYP
       EXCEPTIONS
            NO_CONTRACT = 4.
  IF SY-SUBRC = 4.
    MESSAGE S781(V1).
  ENDIF.

ENDFORM.