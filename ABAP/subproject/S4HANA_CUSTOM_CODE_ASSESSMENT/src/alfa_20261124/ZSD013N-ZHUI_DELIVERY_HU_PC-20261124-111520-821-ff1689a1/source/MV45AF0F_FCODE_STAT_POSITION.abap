*---------------------------------------------------------------------*
*       FORM FCODE_STAT_POSITION                                      *
*---------------------------------------------------------------------*
* Status of position                                                  *
*---------------------------------------------------------------------*
FORM FCODE_STAT_POSITION  USING US_T185F
                                US_T185
                                US_T185V.

  DATA: BEGIN OF S_VBAK OCCURS 1.
          INCLUDE STRUCTURE VBAK.
  DATA: END OF S_VBAK.
  DATA: S_IVBAP LIKE IVBAP OCCURS 1 WITH HEADER LINE.

  S_IVBAP[] = IVBAP[].
  IF VBAP-VKGRU EQ VKGRU_REP_REPARATURANFO.
    LOOP AT UVBAP WHERE UEPOS EQ VBAP-POSNV.
      READ TABLE S_IVBAP WITH KEY POSNR = UVBAP-POSNR BINARY SEARCH.
      IF SY-SUBRC      EQ 0 AND
         S_IVBAP-SELKZ IS INITIAL.
        S_IVBAP-SELKZ = CHARX.
        MODIFY S_IVBAP INDEX SY-TABIX.
      ELSEIF SY-SUBRC NE 0.
        S_IVBAP-SELKZ = CHARX.
        S_IVBAP-POSNR = UVBAP-POSNR.
        READ TABLE XVBAP WITH KEY POSNR = UVBAP-POSNR.
        S_IVBAP-TABIX = SY-TABIX.
        APPEND S_IVBAP.
      ENDIF.
    ENDLOOP.
    CLEAR VBAP-POSNR.
  ENDIF.

  CLEAR S_VBAK.
  S_VBAK = VBAK.
  APPEND S_VBAK.

  CALL FUNCTION 'SD_ORDER_STATUS_OVERVIEW'
       EXPORTING
            I_VBELN = VBAK-VBELN
            I_POSNR = VBAP-POSNR
            I_VBTYP = VBAK-VBTYP
       TABLES
            FXVBAK  = S_VBAK
            FXVBAP  = XVBAP
            FXVBEP  = XVBEP
            FXVBUK  = XVBUK
            FXVBUP  = XVBUP
            FIVBAP  = S_IVBAP.

ENDFORM.