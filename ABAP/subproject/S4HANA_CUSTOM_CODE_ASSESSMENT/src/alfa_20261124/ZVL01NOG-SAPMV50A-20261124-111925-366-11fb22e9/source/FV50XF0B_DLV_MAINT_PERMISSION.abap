*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_DLV_MAINT_PERMISSION                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DLV_MAINTAIN_PERMISSION
*&---------------------------------------------------------------------*
*       Permission for delivery
*----------------------------------------------------------------------*
FORM DLV_MAINTAIN_PERMISSION.

*  DATA: LF_SUBRC LIKE SYST-SUBRC.
*  DATA: LT_INS_PERMISSION LIKE AIP_PERMISSION OCCURS 0.
*  DATA: LT_UPD_PERMISSION LIKE AIP_PERMISSION OCCURS 0.
*  DATA: LS_REC_PERMISSION LIKE AIP_PERMISSION.
*  FIELD-SYMBOLS: <LS_XLIPS> TYPE LIPSVB.
*
*  LOOP AT XLIPS ASSIGNING <LS_XLIPS> WHERE UPDKZ EQ UPDKZ_NEW
*                                       AND VGSYS NE SPACE.
**   new delivery entries, AIP scenario
*    CLEAR LS_REC_PERMISSION.
*    LS_REC_PERMISSION-MANDT       = SY-MANDT.
*    LS_REC_PERMISSION-TYP         = '3'.
*    LS_REC_PERMISSION-BELNR       = <LS_XLIPS>-VBELN.
*    LS_REC_PERMISSION-POSNR       = <LS_XLIPS>-POSNR.
**   LS_REC_PERMISSION-ORIG_SYS    =
**   LS_REC_PERMISSION-ORIG_BELTYP =
**   LS_REC_PERMISSION-ORIG_BELNR  =
**   LS_REC_PERMISSION-ORIG_POSNR  =
*    APPEND LS_REC_PERMISSION TO LT_INS_PERMISSION.
*  ENDLOOP.
*
*  IF V50AGL-SYNCHRON IS INITIAL.
**   asynchronous update
*    CALL FUNCTION 'AIP_MAINTAIN_PERMISSION' IN UPDATE TASK
*         TABLES
*              T_INS_PERMISSION = LT_INS_PERMISSION
*              T_UPD_PERMISSION = LT_UPD_PERMISSION.
*  ELSE.
**   synchronous update
*    CALL FUNCTION 'AIP_MAINTAIN_PERMISSION'
*         TABLES
*              T_INS_PERMISSION = LT_INS_PERMISSION
*              T_UPD_PERMISSION = LT_UPD_PERMISSION.
*  ENDIF.
*
ENDFORM.                               " DLV_MAINTAIN_PERMISSION