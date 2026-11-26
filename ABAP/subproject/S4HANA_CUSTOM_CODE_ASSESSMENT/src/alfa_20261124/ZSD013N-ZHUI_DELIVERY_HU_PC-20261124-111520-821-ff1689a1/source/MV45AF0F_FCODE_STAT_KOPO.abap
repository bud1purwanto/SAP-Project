*---------------------------------------------------------------------*
*       FORM FCODE_STAT_KOPO                                          *
*---------------------------------------------------------------------*
* Overview of header an position                                      *
*---------------------------------------------------------------------*
FORM FCODE_STAT_KOPO  USING US_T185F
                            US_T185
                            US_T185V.



  DATA: BEGIN OF S_VBAK OCCURS 1.
          INCLUDE STRUCTURE VBAK.
  DATA: END OF S_VBAK.

  IF DATA_READ_FROM_ARCHIVE = 'X'.
    MESSAGE S002(VL) WITH VBAK-VBELN.
    EXIT.
  ENDIF.

  CLEAR S_VBAK.
  S_VBAK = VBAK.
  APPEND S_VBAK.

  CALL FUNCTION 'SD_ORDER_STATUS_OVERVIEW'
       EXPORTING
            I_VBELN = VBAK-VBELN
            I_POSNR = 0
            I_VBTYP = VBAK-VBTYP
       TABLES
            FXVBAK  = S_VBAK
            FXVBAP  = XVBAP
            FXVBEP  = XVBEP
            FXVBUK  = XVBUK
            FXVBUP  = XVBUP
            FIVBAP  = IVBAP.

ENDFORM.