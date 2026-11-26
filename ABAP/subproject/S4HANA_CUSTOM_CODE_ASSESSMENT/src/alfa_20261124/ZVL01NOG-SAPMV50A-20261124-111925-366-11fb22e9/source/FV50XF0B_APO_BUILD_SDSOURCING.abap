*&---------------------------------------------------------------------*
*&  Include           FV50XF0B_APO_BUILD_SDSOURCING                    *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form APO_BUILD_SDSOURCING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->text
*----------------------------------------------------------------------*
FORM APO_BUILD_SDSOURCING.

  CALL FUNCTION 'ND_EXITS_ACTIVE_CHECK'
    EXCEPTIONS
      EXITS_NOT_ACTIVE = 1
      OTHERS           = 2.

  CHECK SY-SUBRC EQ 0.
  EXIT.

  DATA: LF_ATPCHECK_IN_APO,
        LS_VBAPVB LIKE XVBAP,
        LF_TABIX LIKE SY-TABIX.
  LOOP AT XVBAP INTO LS_VBAPVB.
    IF  LS_VBAPVB-PROSA NE CHARB.
      CONTINUE.
    ENDIF.

    READ TABLE XVBAP WITH KEY VBELN = LS_VBAPVB-VBELN
                              POSNR = LS_VBAPVB-UEPOS.
    CHECK SY-SUBRC EQ 0.
    CHECK XVBAP-PROSA CA 'AC'.
    LF_TABIX = SY-TABIX.
* test on sourcing case ( ATP done in APO )
    CALL FUNCTION 'SD_MAT_WERK_APOATPCHECK'
      EXPORTING
        IV_MATNR           = XVBAP-MATNR
        IV_WERKS           = XVBAP-WERKS
      IMPORTING
        EV_ATPCHECK_IN_APO = LF_ATPCHECK_IN_APO.

    CHECK NOT LF_ATPCHECK_IN_APO IS INITIAL.
    XVBAP-SRCPS = SRCPS_MAINITEM.
    XVBAP-BEDUP = 'X'.
    MODIFY XVBAP INDEX LF_TABIX TRANSPORTING SRCPS BEDUP.
  ENDLOOP.

ENDFORM.                    "APO_BUILD_SDSOURCING
