*----------------------------------------------------------------------*
*   INCLUDE MV45AF0C_CROSS_SELL_ERMITTELN                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CROSS_SELL_ERMITTELN
*&---------------------------------------------------------------------*
FORM CROSS_SELL_ERMITTELN.

  DATA: DA_SUBRC LIKE SY-SUBRC,
        DA_CRSPL LIKE TCSP-CRSPL.

  PERFORM TCSPF_SELECT USING    VBAK-VKORG
                                VBAK-VTWEG
                                VBAK-SPART
                                KUAGV-PVKSM
                                TVAK-PVBSM
                       CHANGING DA_CRSPL.

  CHECK NOT DA_CRSPL IS INITIAL.

  PERFORM TCSP_SELECT USING    DA_CRSPL
                               CHARX
                      CHANGING DA_SUBRC.

ENDFORM.                               " CROSS_SELL_ERMITTELN



























