*&---------------------------------------------------------------------*
*&  Include           MV45A_DPBP_SUBSCR_SETO01                         *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  dpbp_subscr_set  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE dpbp_subscr_set OUTPUT.
data: dpbp_subscr_repid type sy-repid,
      dpbp_subscr_dynnr type sy-dynnr.


CALL FUNCTION 'GET_HANDLE_SD_DPBP'
    IMPORTING
    HANDLE        = inst_badi_sd_dpbp
    ACTIVE        = active_badi_sd_dpbp.

IF  active_badi_sd_dpbp EQ CHARX.

    CALL METHOD inst_badi_sd_dpbp->TRANSFER_DATA_TO_SUBSCREEN
      CHANGING
        F_VBKD = VBKD
        F_REPID       = dpbp_subscr_repid
        F_DYNNR       = dpbp_subscr_dynnr.

     if dpbp_subscr_dynnr is initial or dpbp_subscr_repid is initial.
      dpbp_subscr_repid = 'SAPMV45A'.
      dpbp_subscr_dynnr = '6553'.
     endif.

 ELSE.

     dpbp_subscr_repid = 'SAPMV45A'.
     dpbp_subscr_dynnr = '6553'.

ENDIF.

ENDMODULE.                 " dpbp_subscr_set  OUTPUT