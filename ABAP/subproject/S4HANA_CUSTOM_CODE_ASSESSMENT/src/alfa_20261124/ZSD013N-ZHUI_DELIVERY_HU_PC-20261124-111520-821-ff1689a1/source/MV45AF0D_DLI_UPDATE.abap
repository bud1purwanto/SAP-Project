*----------------------------------------------------------------------*
*   INCLUDE MV45AF0D_DLI_UPDATE                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   FORM DLI_UPDATE
*----------------------------------------------------------------------*
*   Diese Formroutine dient dazu, bei Setzen eines Absagegrundes die
*   dynamischen Posten bei aufwandsbezogener Fakturierung wieder zu
*   öffnen, sofern der Absagegrund entsprechend eingestellt ist.
*----------------------------------------------------------------------*
FORM DLI_UPDATE.

  DATA: DA_OPEN LIKE SY-BATCH.

  DATA: L_GM_EXIT   TYPE REF TO IF_EX_BADI_ISPS_GRANT,
        ACTIVE TYPE XFELD.

  DATA: ls_xvbkd_dip17 LIKE LINE OF xvbkd.                        "note 1358895

  CALL FUNCTION 'GET_HANDLE_IS_PS'
    IMPORTING
      HANDLE = L_GM_EXIT
      ACTIVE = ACTIVE.

  CALL FUNCTION 'DIP17_INIT_FLOW_UPDATE'
    EXPORTING
      I_CALLER = 'SD'.

* Nur bei Positionen, die aus dynamischen Posten entstanden sind
  LOOP AT XVBAP WHERE VKGRU EQ VKGRU_DYN_POSTEN OR
                      VKGRU EQ VKGRU_DYN_POSTEN_AG.
    IF XVBAP-UPDKZ NE UPDKZ_DELETE.
      IF NOT XVBAP-ABGRU IS INITIAL.
        SELECT SINGLE * FROM TVAG WHERE ABGRU EQ XVBAP-ABGRU.
        IF SY-SUBRC EQ 0 AND
          TVAG-EP_OFF EQ CHARX.
          DA_OPEN = CHARX.
        ELSE.
          DA_OPEN = SPACE.
        ENDIF.
      ELSE.
        DA_OPEN = SPACE.
      ENDIF.
    ELSE.
      DA_OPEN = CHARD.
    ENDIF.

* start of note 1358895
*/
*/ note 1616455 1/2 - begin
    READ TABLE xvbkd INTO ls_xvbkd_dip17
      WITH KEY vbeln = vbak-vbeln
               posnr = xvbap-posnr
      BINARY SEARCH.
    IF NOT sy-subrc IS INITIAL.
      READ TABLE xvbkd INTO ls_xvbkd_dip17
        WITH KEY  vbeln = vbak-vbeln
                  posnr = space
        BINARY SEARCH.
      IF NOT sy-subrc IS INITIAL.
        READ TABLE xvbkd INTO ls_xvbkd_dip17
          WITH KEY posnr = xvbap-posnr
          BINARY SEARCH.
        IF NOT sy-subrc IS INITIAL.
          LOOP AT xvbkd INTO  ls_xvbkd_dip17.
            IF NOT ls_xvbkd_dip17-ffprf IS INITIAL.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
*/ note 1616455 1/2 - end
*/
* end of note 1358895
*/
*/ note 1616455 2/2 - begin
    CALL FUNCTION 'DIP17_CANCEL_DI'
      EXPORTING
        I_VBELN  = VBAK-VBELN
        I_POSNR  = XVBAP-POSNR
        i_open   = da_open
        i_profnr = ls_xvbkd_dip17-ffprf
        i_usage  = '01'.
*/ note 1616455 2/2 - end
*/
* Interface for IS-PS Grant Managment
* Function: update the billing status in gmia table
* for each SD bill req. item.
    IF ACTIVE = CHARX.
      CALL METHOD L_GM_EXIT->GMIA_CANCEL
        EXPORTING
          I_VBELN = XVBAP-VBELN
          I_POSNR = XVBAP-POSNR
          I_OPEN  = DA_OPEN.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'DIP17_PERFORM_FLOW_UPDATE'
    EXPORTING
      I_CALLER = 'SD'.

  DATA: BEGIN OF DA_XITEMS OCCURS 0,
          POSNR LIKE VBAP-POSNR.
  DATA: END OF DA_XITEMS.

* Verkaufspreiskalkulation evtl. löschen
  LOOP AT XVBAP WHERE UPDKZ EQ UPDKZ_DELETE
                  AND PVPOS IS INITIAL.
    DA_XITEMS-POSNR = XVBAP-POSNR.
    APPEND DA_XITEMS.
  ENDLOOP.

  DESCRIBE TABLE DA_XITEMS LINES SY-TABIX.
  IF SY-TABIX > 0.
*   Verkaufspreiskalkulation löschen
    CALL FUNCTION 'VPKDB_DELETE_PDOC_FOR_SDORDER'
      EXPORTING
        I_VBELN       = VBAK-VBELN
      TABLES
        IT_POSNR      = DA_XITEMS
      EXCEPTIONS
        NO_PDOC_FOUND = 1
        OTHERS        = 2.
  ENDIF.

ENDFORM.                    "dli_update