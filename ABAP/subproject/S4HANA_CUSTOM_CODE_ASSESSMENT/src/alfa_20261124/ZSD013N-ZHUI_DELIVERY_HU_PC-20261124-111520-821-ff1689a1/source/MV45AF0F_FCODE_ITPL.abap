*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_ITPL                                        *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_ITPL                                               *
*---------------------------------------------------------------------*
*       Die letzte Position wird bereitgestellt,                      *
*       Ferner wird das Selektionskennzeichen zurückgesetzt.          *
*---------------------------------------------------------------------*
FORM FCODE_ITPL.
  DATA : TCTRL_TABIX LIKE SY-TABIX,
         DA_TABIX    LIKE SY-TABIX.

* letzte Position bereitstellen
  IF DPP_ACTIVE IS INITIAL.
    DESCRIBE TABLE IVBAP LINES SY-TABIX.
    READ TABLE IVBAP INDEX SY-TABIX.
    DA_TABIX = IVBAP-TABIX.
  ELSE.
    DESCRIBE TABLE IVBAP_PV LINES SY-TABIX.
    READ TABLE IVBAP_PV INDEX SY-TABIX.
    DA_TABIX = IVBAP_PV-TABIX.
  ENDIF.
  IF SY-SUBRC NE 0.
* Es ist keine letzte Position vorhanden
    MESSAGE S075.
  ELSE.
    ITEM_DETAIL_TABIX = DA_TABIX.
    TCTRL_TABIX = SY-TABIX.
    READ TABLE SVBAP WITH KEY TABIX = DA_TABIX.
    IF SY-SUBRC NE 0.
ENHANCEMENT-SECTION     FCODE_ITPL_10 SPOTS ES_SAPMV45A.
      TCTRL_U_ERF_AUFTRAG-TOP_LINE = TCTRL_TABIX.
      IVBAP_TABIX_ZEILE_1 = TCTRL_U_ERF_AUFTRAG-TOP_LINE.
END-ENHANCEMENT-SECTION.
    ENDIF.

  ENDIF.

ENDFORM.