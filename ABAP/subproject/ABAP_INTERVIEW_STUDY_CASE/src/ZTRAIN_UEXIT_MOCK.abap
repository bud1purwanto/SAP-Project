REPORT ztrain_uexit_mock.
* Mock data global SAPMV45A untuk syntax check FORM user exit latihan
TABLES: vbak, vbkd, t180.
DATA: BEGIN OF xvbap OCCURS 0.
        INCLUDE STRUCTURE vbapvb.
DATA: END OF xvbap.
DATA: fcode(20) TYPE c.

FORM userexit_check_vbak USING us_dialog.
* V1: requested delivery date tidak boleh lewat (hanya VA01)
  IF t180-trtyp = 'H'
     AND vbak-vdatu IS NOT INITIAL
     AND vbak-vdatu < sy-datum.
    MESSAGE e398(00) WITH 'Req. delivery date' vbak-vdatu
                          'tidak boleh sebelum hari ini' space.
  ENDIF.
ENDFORM.

FORM userexit_save_document_prepare.
  DATA: lv_msg(100) TYPE c,
        lv_err      TYPE c.

  CHECK t180-trtyp = 'H' OR t180-trtyp = 'V'.

* V2: PO number wajib untuk order type ZDOR
  IF vbak-auart = 'ZDOR' AND vbkd-bstkd IS INITIAL.
    lv_msg = 'PO number customer wajib diisi untuk order type ZDOR'.
    lv_err = 'X'.
  ENDIF.

* V3: Production Line wajib untuk item category ZTAN / ZP
  IF lv_err IS INITIAL.
    LOOP AT xvbap WHERE updkz <> 'D'
                    AND ( pstyv = 'ZTAN' OR pstyv = 'ZP' )
                    AND zline IS INITIAL.
      CONCATENATE 'Item' xvbap-posnr
        ': Production Line (tab Additional Screen) wajib diisi'
        INTO lv_msg SEPARATED BY space.
      lv_err = 'X'.
      EXIT.
    ENDLOOP.
  ENDIF.

  IF lv_err = 'X'.
    MESSAGE lv_msg TYPE 'I' DISPLAY LIKE 'E'.
    PERFORM folge_gleichsetzen(saplv00f).
    fcode = 'ENT1'.
    SET SCREEN sy-dynnr.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.
