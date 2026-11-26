FUNCTION ZFM_LOG_PK.
**"----------------------------------------------------------------------
**"*"Local interface:
**"  IMPORTING
**"     REFERENCE(PINNR) TYPE  ZPINNR
**"     REFERENCE(HUSEQ) TYPE  ZPOSNR_PL
**"     REFERENCE(REPID) TYPE  REPID
**"     REFERENCE(AREA) TYPE  TEXT10
**"     REFERENCE(DESCR) TYPE  TEXT255
**"----------------------------------------------------------------------
*
*  data:
*  ld_log type zpack_pcl_log,
*  ld_computer_name type string.
*
*  ld_log-pinnr = pinnr.
*  ld_log-huseq = huseq.
*  ld_log-repid = repid.
*  ld_log-area  = area.
*  ld_log-descr = descr.
*
*  ld_log-aedat = sy-datum.
*  ld_log-aezet = sy-uzeit.
*  ld_log-aenam = sy-uname.
*  ld_log-tcode = sy-tcode.
*
*  CALL FUNCTION 'POC_GET_COMPUTER_NAME'
*    IMPORTING
*      ex_computer_name = ld_computer_name
*    EXCEPTIONS
*      gui_error        = 1
*      OTHERS           = 2.
*
*  IF sy-subrc <> 0.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*  DATA: ex type ref to cx_root.
*
*  TRY.
*    ld_log-computer_name = ld_computer_name.
*    INSERT zpack_pcl_log FROM ld_log.
*
*  CATCH cx_root INTO ex.
*    "-- do nothing
*
*  ENDTRY.
*
ENDFUNCTION.