*&---------------------------------------------------------------------*
*&  Include           BADI_SD_DPBP_PKO4                                *
*&---------------------------------------------------------------------*

CALL FUNCTION 'GET_HANDLE_SD_DPBP'
    IMPORTING
    HANDLE        = inst_badi_sd_dpbp
    ACTIVE        = active_badi_sd_dpbp.

 IF  active_badi_sd_dpbp EQ CHARX.

   CALL METHOD inst_badi_sd_dpbp->FCODE_PKO4
    EXPORTING
     XVBKD = XVBKD
    CHANGING
     XVBFA = XVBFA
     TFPLTS = TFPLTS[].
 ENDIF.