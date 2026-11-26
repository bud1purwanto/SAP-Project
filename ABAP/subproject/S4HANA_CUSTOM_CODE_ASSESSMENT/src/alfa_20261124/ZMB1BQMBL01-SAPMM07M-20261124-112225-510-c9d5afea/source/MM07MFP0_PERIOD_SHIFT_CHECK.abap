*&---------------------------------------------------------------------*
*&      Form  PERIOD_SHIFT_CHECK
*&---------------------------------------------------------------------*
*  Check if period has changed ruing Tx runtime
*  Created with Note 1636844
*----------------------------------------------------------------------*
FORM period_shift_check.

  DATA: lv_period_shift TYPE xfeld,
        lv_bukrs   TYPE bukrs,
        lv_lfmon   TYPE lfmon,
        ls_marv_db TYPE marv,
        ls_marv_bf TYPE smarv,
        ls_marc_bf TYPE smarc,
        ls_marc_db TYPE marc,
        ls_mard_bf TYPE smard,
        ls_mard_db TYPE mard,
        ls_mchb_bf TYPE smchb,
        ls_mchb_db TYPE mchb,
        ls_mkol_bf TYPE smkol,
        ls_mkol_db TYPE mkol,
        ls_mska_bf TYPE smska,
        ls_mska_db TYPE mska,
        ls_msku_bf TYPE smsku,
        ls_msku_db TYPE msku,
        ls_mslb_bf TYPE smslb,
        ls_mslb_db TYPE mslb,
        ls_mspr_bf TYPE smspr,
        ls_mspr_db TYPE mspr,
        ls_mssa_bf TYPE smssa,
        ls_mssa_db TYPE mssa,
        ls_mssl_bf TYPE smssl,
        ls_mssl_db TYPE mssl,
        ls_mssq_bf TYPE smssq,
        ls_mssq_db TYPE mssq,
        ls_mbew_bf TYPE smbew,
        ls_mbew_db TYPE mbew,
        ls_ebew_bf TYPE sebew,
        ls_ebew_db TYPE ebew,
        ls_qbew_bf TYPE sqbew,
        ls_qbew_db TYPE qbew,
        ls_obew_bf TYPE sobew,
        ls_obew_db TYPE obew,
        ls_mstb_bf TYPE smstb,
        ls_mstb_db TYPE mstb,
        ls_mste_bf TYPE smste,
        ls_mste_db TYPE mste,
        ls_mstq_bf TYPE smstq,
        ls_mstq_db TYPE mstq.


  CLEAR lv_period_shift.

  IF tcurm-mbequ NE '2'. "late exclusive block only
    RETURN.
  ENDIF.

  LOOP AT xmarv INTO ls_marv_bf.
    SELECT SINGLE bukrs FROM t001k INTO lv_bukrs WHERE bwkey = ls_marv_bf-bwkey.
    CHECK sy-subrc IS INITIAL.
      SELECT SINGLE * FROM marv BYPASSING BUFFER INTO ls_marv_db WHERE bukrs = lv_bukrs.
      CHECK sy-subrc IS INITIAL.
        IF ls_marv_db-lfmon <> ls_marv_bf-lfmon AND
           ls_marv_db-lfgja GE ls_marv_bf-lfgja.
*         period shift was done during runtime, check stocks in detail
          lv_period_shift = 'X'.
          EXIT.
        ELSE.
*        go ahead, period is equal
        ENDIF.
  ENDLOOP.

  IF lv_period_shift = 'X'.
    LOOP AT xmarc INTO ls_marc_bf.
      SELECT SINGLE * FROM marc INTO ls_marc_db
             WHERE  werks = ls_marc_bf-werks
             AND    matnr = ls_marc_bf-matnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_marc_bf-lfmon <> ls_marc_db-lfmon AND
         ls_marc_db-lfgja GE ls_marc_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmard INTO ls_mard_bf.
      SELECT SINGLE * FROM mard INTO ls_mard_db
             WHERE  werks = ls_mard_bf-werks
             AND    matnr = ls_mard_bf-matnr
             AND    lgort = ls_mard_bf-lgort.
      CHECK sy-subrc IS INITIAL.
      IF ls_mard_bf-lfmon <> ls_mard_db-lfmon AND
         ls_mard_db-lfgja GE ls_mard_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmchb INTO ls_mchb_bf.
      SELECT SINGLE * FROM mchb INTO ls_mchb_db
             WHERE werks = ls_mchb_bf-werks
             AND   matnr = ls_mchb_bf-matnr
             AND   lgort = ls_mchb_bf-lgort
             AND   charg = ls_mchb_bf-charg.
      CHECK sy-subrc IS INITIAL.
      IF ls_mchb_bf-lfmon <> ls_mchb_db-lfmon AND
         ls_mchb_db-lfgja GE ls_mchb_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmbew INTO ls_mbew_bf.
      SELECT SINGLE * FROM mbew INTO ls_mbew_db
             WHERE bwkey = ls_mbew_bf-bwkey
             AND   matnr = ls_mbew_bf-matnr
             AND   bwtar = ls_mbew_bf-bwtar.
      CHECK sy-subrc IS INITIAL.
      IF ls_mbew_bf-lfmon <> ls_mbew_db-lfmon AND
         ls_mbew_db-lfgja GE ls_mbew_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xebew INTO ls_ebew_bf.
      SELECT SINGLE * FROM ebew INTO ls_ebew_db
             WHERE bwkey = ls_ebew_bf-bwkey
             AND   matnr = ls_ebew_bf-matnr
             AND   bwtar = ls_ebew_bf-bwtar
             AND   sobkz = ls_ebew_bf-sobkz
             AND   vbeln = ls_ebew_bf-vbeln
             AND   posnr = ls_ebew_bf-posnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_ebew_bf-lfmon <> ls_ebew_db-lfmon AND
         ls_ebew_db-lfgja GE ls_ebew_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xqbew INTO ls_qbew_bf.
      SELECT SINGLE * FROM qbew INTO ls_qbew_db
             WHERE bwkey = ls_qbew_bf-bwkey
             AND   matnr = ls_qbew_bf-matnr
             AND   bwtar = ls_qbew_bf-bwtar
             AND   sobkz = ls_qbew_bf-sobkz
             AND   pspnr = ls_qbew_bf-pspnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_qbew_bf-lfmon <> ls_qbew_db-lfmon AND
         ls_qbew_db-lfgja GE ls_qbew_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xobew INTO ls_obew_bf.
      SELECT SINGLE * FROM obew INTO ls_obew_db
             WHERE bwkey = ls_obew_bf-bwkey
             AND   matnr = ls_obew_bf-matnr
             AND   bwtar = ls_obew_bf-bwtar
             AND   sobkz = ls_obew_bf-sobkz
             AND   lifnr = ls_obew_bf-lifnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_obew_bf-lfmon <> ls_obew_db-lfmon AND
         ls_obew_db-lfgja GE ls_obew_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmkol INTO ls_mkol_bf.
      SELECT SINGLE * FROM mkol INTO ls_mkol_db
             WHERE werks = ls_mkol_bf-werks
             AND   matnr = ls_mkol_bf-matnr
             AND   lgort = ls_mkol_bf-lgort
             AND   charg = ls_mkol_bf-charg
             AND   sobkz = ls_mkol_bf-sobkz
             AND   lifnr = ls_mkol_bf-lifnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_mkol_bf-lfmon <> ls_mkol_db-lfmon AND
         ls_mkol_db-lfgja GE ls_mkol_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmska INTO ls_mska_bf.
      SELECT SINGLE * FROM mska INTO ls_mska_db
             WHERE werks = ls_mska_bf-werks
             AND   matnr = ls_mska_bf-matnr
             AND   lgort = ls_mska_bf-lgort
             AND   charg = ls_mska_bf-charg
             AND   sobkz = ls_mska_bf-sobkz
             AND   vbeln = ls_mska_bf-vbeln
             AND   posnr = ls_mska_bf-posnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_mska_bf-lfmon <> ls_mska_db-lfmon AND
         ls_mska_db-lfgja GE ls_mska_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmspr INTO ls_mspr_bf.
      SELECT SINGLE * FROM mspr INTO ls_mspr_db
             WHERE werks = ls_mspr_bf-werks
             AND   matnr = ls_mspr_bf-matnr
             AND   lgort = ls_mspr_bf-lgort
             AND   charg = ls_mspr_bf-charg
             AND   sobkz = ls_mspr_bf-sobkz
             AND   pspnr = ls_mspr_bf-pspnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_mspr_bf-lfmon <> ls_mspr_db-lfmon AND
         ls_mspr_db-lfgja GE ls_mspr_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmssa INTO ls_mssa_bf.
      SELECT SINGLE * FROM mssa INTO ls_mssa_db
             WHERE werks = ls_mssa_bf-werks
             AND   matnr = ls_mssa_bf-matnr
             AND   sobkz = ls_mssa_bf-sobkz
             AND   vbeln = ls_mssa_bf-vbeln
             AND   posnr = ls_mssa_bf-posnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_mssa_bf-lfmon <> ls_mssa_db-lfmon AND
         ls_mssa_db-lfgja GE ls_mssa_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmssq INTO ls_mssq_bf.
      SELECT SINGLE * FROM mssq INTO ls_mssq_db
             WHERE werks = ls_mssq_bf-werks
             AND   matnr = ls_mssq_bf-matnr
             AND   sobkz = ls_mssq_bf-sobkz
             AND   pspnr = ls_mssq_bf-pspnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_mssq_bf-lfmon <> ls_mssq_db-lfmon AND
         ls_mssq_db-lfgja GE ls_mssq_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmslb INTO ls_mslb_bf.
      SELECT SINGLE * FROM mslb INTO ls_mslb_db
             WHERE werks = ls_mslb_bf-werks
             AND   matnr = ls_mslb_bf-matnr
             AND   charg = ls_mslb_bf-charg
             AND   sobkz = ls_mslb_bf-sobkz
             AND   lifnr = ls_mslb_bf-lifnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_mslb_bf-lfmon <> ls_mslb_db-lfmon AND
         ls_mslb_db-lfgja GE ls_mslb_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmssl INTO ls_mssl_bf.
      SELECT SINGLE * FROM mssl INTO ls_mssl_db
             WHERE werks = ls_mssl_bf-werks
             AND   matnr = ls_mssl_bf-matnr
             AND   sobkz = ls_mssl_bf-sobkz
             AND   lifnr = ls_mssl_bf-lifnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_mssl_bf-lfmon <> ls_mssl_db-lfmon AND
         ls_mssl_db-lfgja GE ls_mssl_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmsku INTO ls_msku_bf.
      SELECT SINGLE * FROM msku INTO ls_msku_db
             WHERE werks = ls_msku_bf-werks
             AND   matnr = ls_msku_bf-matnr
             AND   charg = ls_msku_bf-charg
             AND   sobkz = ls_msku_bf-sobkz
             AND   kunnr = ls_msku_bf-kunnr.
      CHECK sy-subrc IS INITIAL.
      IF ls_msku_bf-lfmon <> ls_msku_db-lfmon AND
         ls_msku_db-lfgja GE ls_msku_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmstb INTO ls_mstb_bf.
      SELECT SINGLE * FROM mstb INTO ls_mstb_db
             WHERE werks = ls_mstb_bf-werks
             AND   matnr = ls_mstb_bf-matnr
             AND   charg = ls_mstb_bf-charg
             AND   sobkz = ls_mstb_bf-sobkz
             AND   bwtar = ls_mstb_bf-bwtar.
      CHECK sy-subrc IS INITIAL.
      IF ls_mstb_bf-lfmon <> ls_mstb_db-lfmon AND
         ls_mstb_db-lfgja GE ls_mstb_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmste INTO ls_mste_bf.
      SELECT SINGLE * FROM mste INTO ls_mste_db
             WHERE werks = ls_mste_bf-werks
             AND   matnr = ls_mste_bf-matnr
             AND   charg = ls_mste_bf-charg
             AND   sobkz = ls_mste_bf-sobkz
             AND   vbeln = ls_mste_bf-vbeln
             AND   posnr = ls_mste_bf-posnr
             AND   bwtar = ls_mste_bf-bwtar.
      CHECK sy-subrc IS INITIAL.
      IF ls_mste_bf-lfmon <> ls_mste_db-lfmon AND
         ls_mste_db-lfgja GE ls_mste_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
    LOOP AT xmstq INTO ls_mstq_bf.
      SELECT SINGLE * FROM mstq INTO ls_mstq_db
             WHERE werks = ls_mstq_bf-werks
             AND   matnr = ls_mstq_bf-matnr
             AND   charg = ls_mstq_bf-charg
             AND   sobkz = ls_mstq_bf-sobkz
             AND   PSPNR = ls_mstq_bf-PSPNR
             AND   bwtar = ls_mstq_bf-bwtar.
      CHECK sy-subrc IS INITIAL.
      IF ls_mstq_bf-lfmon <> ls_mstq_db-lfmon AND
         ls_mstq_db-lfgja GE ls_mstq_bf-lfgja.
        MESSAGE e574.
      ENDIF.
    ENDLOOP.
  ELSE.
    RETURN.
  ENDIF.

ENDFORM.                    "period_shift_check