*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_ITPM                                        *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_ITPM                                               *
*---------------------------------------------------------------------*
*       Die vorhergehende Position wird bereitgestellt,               *
*       Ferner wird das Selektionskennzeichen zurückgesetzt.          *
*---------------------------------------------------------------------*
FORM FCODE_ITPM.
  DATA: TCTRL_TABIX LIKE SY-TABIX.
  DATA: DA_POSNR LIKE VBAP-POSNR.
  DATA: DA_IVBAP LIKE IVBAP OCCURS 0 WITH HEADER LINE.

* Produktvorschlag
  IF NOT DPP_ACTIVE IS INITIAL.
    DA_IVBAP[] = IVBAP[].
    CLEAR IVBAP.
    REFRESH IVBAP.
    LOOP AT IVBAP_PV.
      MOVE-CORRESPONDING IVBAP_PV TO IVBAP.
      APPEND IVBAP.
    ENDLOOP.
  ENDIF.

* FOR DELETED ITEM LINE
  READ TABLE IVBAP WITH KEY TABIX = ITEM_DETAIL_TABIX.
  IF IVBAP-TABIX > XVBAP_HIGH_POSNR.
    ITEM_DETAIL_TABIX = IVBAP-TABIX.
  ENDIF.

  READ TABLE SVBAP WITH KEY TABIX = ITEM_DETAIL_TABIX.
  IF SY-SUBRC = 0.
    READ TABLE IVBAP WITH KEY TABIX = ITEM_DETAIL_TABIX.
    DA_POSNR = IVBAP-POSNR.
* vorhergehende Position bereitstellen
    IF DPP_ACTIVE IS INITIAL.
      READ TABLE IVBAP WITH KEY DA_POSNR BINARY SEARCH.
    ELSE.
      READ TABLE IVBAP WITH KEY DA_POSNR.
    ENDIF.

    IF SY-SUBRC = 8.
* Es ist keine weitere Position vorhanden
      MESSAGE S075.
    ENDIF.
    IF SY-SUBRC = 0.
      SY-TABIX = SY-TABIX - 1.
    ENDIF.
    READ TABLE IVBAP INDEX SY-TABIX.
    IF SY-SUBRC NE 0.
* Es ist keine weitere Position vorhanden
      MESSAGE S075.
    ELSE.
      TCTRL_TABIX = SY-TABIX.

      ITEM_DETAIL_TABIX = IVBAP-TABIX.
      READ TABLE SVBAP WITH KEY TABIX = IVBAP-TABIX.
      IF SY-SUBRC NE 0.
ENHANCEMENT-SECTION     FCODE_ITPM_10 SPOTS ES_SAPMV45A.
        TCTRL_U_ERF_AUFTRAG-TOP_LINE = TCTRL_TABIX.
        IVBAP_TABIX_ZEILE_1 = TCTRL_U_ERF_AUFTRAG-TOP_LINE.
END-ENHANCEMENT-SECTION.
      ENDIF.

    ENDIF.

  ELSE.
    READ TABLE IVBAP INDEX 1.
    IF SY-SUBRC = 0.
      ITEM_DETAIL_TABIX = IVBAP-TABIX.
ENHANCEMENT-SECTION     FCODE_ITPM_11 SPOTS ES_SAPMV45A.
      TCTRL_U_ERF_AUFTRAG-TOP_LINE = SY-TABIX.
      IVBAP_TABIX_ZEILE_1 = TCTRL_U_ERF_AUFTRAG-TOP_LINE.
END-ENHANCEMENT-SECTION.
    ENDIF.
  ENDIF.

* Produktvorschlag
  IF NOT DPP_ACTIVE IS INITIAL.
    IVBAP[] = DA_IVBAP[].
  ENDIF.

ENDFORM.