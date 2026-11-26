*&---------------------------------------------------------------------*
*&  Include           BADI_SD_DPBP_PFPL_40                             *
*&---------------------------------------------------------------------*


CALL FUNCTION 'GET_HANDLE_SD_DPBP'
    IMPORTING
    HANDLE        = inst_badi_sd_dpbp
    ACTIVE        = active_badi_sd_dpbp.

IF  active_badi_sd_dpbp EQ CHARX.

   CALL METHOD inst_badi_sd_dpbp->FCODE_PFPL_40
    EXPORTING
     XVBKD = VBKD
    CHANGING
     XVBFA = XVBFA
     TFPLTS = TFPLTS[].
ENDIF.