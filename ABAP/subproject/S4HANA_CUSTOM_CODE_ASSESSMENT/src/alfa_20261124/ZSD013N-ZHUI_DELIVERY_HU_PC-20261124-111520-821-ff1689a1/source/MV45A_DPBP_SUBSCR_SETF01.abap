*&---------------------------------------------------------------------*
*&  Include           MV45A_DPBP_SUBSCR_SETF01                         *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  dpbp_subscr_set
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dpbp_subscr_set .

DATA: inst_badi_sd_dpbp   TYPE REF TO IF_EX_BADI_SD_DPBP,
      active_badi_sd_dpbp TYPE xfeld,
      dpbp_subscr_repid type sy-repid,
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


ENDIF.
ENDFORM.                    " dpbp_subscr_set