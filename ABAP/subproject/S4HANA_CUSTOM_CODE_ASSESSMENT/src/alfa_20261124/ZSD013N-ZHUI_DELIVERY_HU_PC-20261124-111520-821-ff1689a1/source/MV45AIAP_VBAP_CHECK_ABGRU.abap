*&---------------------------------------------------------------------*
*&  Include           MV45AIAP_VBAP_CHECK_ABGRU                        *
*&---------------------------------------------------------------------*
module vbap_check_abgru.

  DATA: LS_BDCRUN     LIKE BDCRUN,
        LV_VBAP_TABIX LIKE SY-TABIX,
        LS_VBAP       LIKE VBAPVB,
        LS_SVBAP      LIKE SVBAP.

  CHECK SY-BINPT = 'X'.
  CHECK NOT VBAK-ABDIS IS INITIAL.
ENHANCEMENT-SECTION     SAPMV45A_31 SPOTS ES_SAPMV45A.
  CHECK FCODE = FCODE_LIEFERABRUF OR
        FCODE = FCODE_FEINABRUF   OR
        FCODE = FCODE_PLANABRUF.
END-ENHANCEMENT-SECTION.

  CALL FUNCTION 'BDC_RUNNING'
       IMPORTING
            BI_INFO         = LS_BDCRUN
       EXCEPTIONS
            BI_INVALID_DATA = 1
            BI_NOTAKTIV     = 2
            OTHERS          = 3.

  CHECK SY-SUBRC = 0.
  CHECK LS_BDCRUN-CTU_AMODUS <> 'N'.

* If no item is selected the topmost item on the screen will be used.
* Normally this should not happen during batch-input processing but
* in foreground processing the user is able to deselect the items.
  LV_VBAP_TABIX = TC_SELLINE.
  IF LV_VBAP_TABIX = 0.
    LV_VBAP_TABIX = 1.
  ENDIF.
  READ TABLE SVBAP INTO LS_SVBAP INDEX LV_VBAP_TABIX.
  LV_VBAP_TABIX = LS_SVBAP-TABIX.
* Determine if a (the first) item is selected. Normally this should
* be the case during batch-input processing.
  LOOP AT IVBAP WHERE SELKZ EQ 'X'.
    LV_VBAP_TABIX = SY-TABIX.
    EXIT.
  ENDLOOP.

  READ TABLE XVBAP INTO LS_VBAP INDEX LV_VBAP_TABIX.
  CHECK SY-SUBRC = 0.

  CHECK NOT LS_VBAP-ABGRU IS INITIAL.

  MESSAGE E245(V4) WITH LS_VBAP-POSNR.

endmodule.