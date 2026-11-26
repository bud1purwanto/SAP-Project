*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_ITP1                                        *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_ITP1                                               *
*---------------------------------------------------------------------*
*       Die erste Position wird bereitgestellt,                       *
*       Ferner wird das Selektionskennzeichen zurückgesetzt.          *
*---------------------------------------------------------------------*
FORM FCODE_ITP1.

  IF DPP_ACTIVE IS INITIAL.
    READ TABLE IVBAP INDEX 1.
  ELSE.
    READ TABLE IVBAP_PV INDEX 1.
  ENDIF.
  IF SY-SUBRC NE 0.
* Es ist keine weitere Position vorhanden
    MESSAGE S075.
  ELSE.
    IF DPP_ACTIVE IS INITIAL.
      ITEM_DETAIL_TABIX = IVBAP-TABIX.
    ELSE.
      ITEM_DETAIL_TABIX = IVBAP_PV-TABIX.
    ENDIF.
ENHANCEMENT-SECTION     FCODE_ITP1_10 SPOTS ES_SAPMV45A.
    TCTRL_U_ERF_AUFTRAG-TOP_LINE = SY-TABIX.
    IVBAP_TABIX_ZEILE_1 = TCTRL_U_ERF_AUFTRAG-TOP_LINE.
END-ENHANCEMENT-SECTION.
  ENDIF.

ENDFORM.