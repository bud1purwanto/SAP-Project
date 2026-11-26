*&---------------------------------------------------------------------*
*& Created by : Mualifi
*& Created on : 04-03-2013a
*& Program    : ZCOI_KE21N_SR
*& Desc.      : Get data DO and run KE21N
*&--------------------------------------------------------------------- *
REPORT  ZCOI_KE21N_SR.
TABLES: LIKP, LIPS, VBUK, CE18888.

DATA: BEGIN OF IT_LIPS OCCURS 0,
      VBELN LIKE LIPS-VBELN,
      POSNR LIKE LIPS-POSNR,
      VBELV LIKE LIPS-VBELV,
      POSNV LIKE LIPS-POSNV,
      KCMENG LIKE LIPS-KCMENG,   " DO qty
*      KCMENG2 LIKE LIPS-KCMENG,   " Do UOM
      VRKME LIKE LIPS-VRKME,   " UOM
      SHKZG LIKE LIPS-SHKZG,
      MATNR LIKE LIPS-MATNR,
      UMVKZ LIKE LIPS-UMVKZ,
      UMVKN LIKE LIPS-UMVKN,
      WERKS LIKE LIPS-WERKS, "ADD NEW COMPANY
  END OF IT_LIPS.

DATA: BEGIN OF IT_SO OCCURS 0,
      MATNR LIKE LIPS-MATNR,
      VBELN LIKE LIPS-VBELN,
      POSNR LIKE LIPS-POSNR,
      KCMENG LIKE LIPS-KCMENG,   " DO qty
      KCMENG2 LIKE LIPS-KCMENG,   " Do UOM
      VRKME LIKE LIPS-VRKME,   " UOM
      QCOPA LIKE CE18888-VVSQT,   " COPA qty
      DELTA LIKE LIPS-KCMENG,   " Delta
      BELNR LIKE CE18888-BELNR,   " Doc number
      BELNR2 TYPE N LENGTH 10,    "LIKE CE18888-BELNR,   " new Doc number
      ERROR(1),
      REMARK LIKE ZTLOG-TEXT,   "T100-TEXT,
      ICONS(4),
      BOX(1),
      WERKS LIKE LIPS-WERKS, "ADD NEW COMPANY
  END OF IT_SO.

DATA: IT_COPA LIKE  CE18888 OCCURS 0 WITH HEADER LINE.
DATA: IT_COPA2 LIKE  CE18888 OCCURS 0 WITH HEADER LINE.
DATA: WA_ZTLOG LIKE ZTLOG OCCURS 0 WITH HEADER LINE.

DATA: IT_MSG LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
DATA: S_OPTIONS TYPE CTU_PARAMS.
*DATA: BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.
RANGES: P_AMVT FOR LIKP-WADAT_IST.

DATA: V_DOCNO LIKE CE18888-BELNR.
DATA: V_TERMINAL LIKE USR41-TERMINAL.

INCLUDE ZCOI_KE21N_SR_INCL.
INCLUDE ZBDCRECX.
INCLUDE Z_PROG_INFO.             "Program Documentation

SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_PLANT FOR LIPS-WERKS NO INTERVALS OBLIGATORY.
PARAMETERS: P_PERIO LIKE SY-DATUM.   "CE18888-PERIO OBLIGATORY.
*PARAMETERS: P_BUDAT LIKE LIKP-WADAT_IST NO-DISPLAY. "OBLIGATORY DEFAULT SY-DATUM.
SELECTION-SCREEN END OF BLOCK BLK1.

INITIALIZATION.
  CONCATENATE SY-DATUM+0(4) SY-DATUM+4(2) '01' INTO P_PERIO.
  P_PERIO = P_PERIO - 1.

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

*--- handling event DOUBLE_CLICK.
CLASS LCL_EVENT_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS: CATCH_DOUBLECLICK
             FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
             IMPORTING
                E_COLUMN
                ES_ROW_NO
                SENDER.
ENDCLASS.                    "lcl_event_receiver DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.
  METHOD CATCH_DOUBLECLICK.
    DATA: LS_OUTTAB LIKE IT_SO,
            LS_CELLTAB TYPE LVC_S_STYL.

    READ TABLE IT_SO INTO LS_OUTTAB INDEX ES_ROW_NO-ROW_ID.
    IF SY-SUBRC = 0.
*      if e_column-fieldname eq 'TKNUM'.
*        SET PARAMETER ID 'TNR' FIELD ls_outtab-TKNUM.
*        CALL TRANSACTION 'VT03N' AND SKIP FIRST SCREEN.
*      endif.
    ENDIF.
  ENDMETHOD.                    "catch_doubleclick
ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION


START-OF-SELECTION.
  CALL SCREEN 100.

END-OF-SELECTION.

*----------------------------------------------------------------------*
*  MODULE awal OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE AWAL OUTPUT.
  PERFORM GET_DATE.
  CHECK IT_SO[] IS INITIAL.
  PERFORM GET_DATA.
  PERFORM DISPLAY_ALV.
ENDMODULE.                    "awal OUTPUT


*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  DATA: V_PERIO LIKE CE18888-PERIO.
  CONCATENATE P_PERIO+0(4) P_PERIO+4(2) INTO V_PERIO SEPARATED BY '0'.

  SELECT A~VBELN A~POSNR A~VBELV A~POSNV A~KCMENG A~VRKME A~SHKZG A~MATNR A~UMVKZ A~UMVKN A~WERKS "ADD NEW COMPANY
    INTO TABLE IT_LIPS
    FROM ( LIPS AS A JOIN LIKP AS B ON A~VBELN = B~VBELN ) JOIN VBUK AS C ON B~VBELN = C~VBELN
    WHERE B~WADAT_IST IN P_AMVT AND A~PSTYV IN ('ZRER','ZRPN','ZRPP','ZRRN') AND C~WBSTK = 'C'
    AND A~WERKS IN S_PLANT. "Add New Company

  CHECK IT_LIPS[] IS NOT INITIAL.
  LOOP AT IT_LIPS.
    IT_SO-VBELN = IT_LIPS-VBELV.
    IT_SO-POSNR = IT_LIPS-POSNV.
    IF IT_LIPS-SHKZG = 'X'.
      IT_SO-KCMENG = IT_LIPS-KCMENG * -1.
      IT_SO-KCMENG2 = ( IT_LIPS-KCMENG / ( IT_LIPS-UMVKZ / IT_LIPS-UMVKN ) ) * -1.
    ELSE.
      IT_SO-KCMENG = IT_LIPS-KCMENG.
      IT_SO-KCMENG2 = ( IT_LIPS-KCMENG / ( IT_LIPS-UMVKZ / IT_LIPS-UMVKN ) ).
    ENDIF.
    IT_SO-MATNR = IT_LIPS-MATNR.
    IT_SO-VRKME = IT_LIPS-VRKME.
    IT_SO-WERKS = IT_LIPS-WERKS. "ADD NEW COMPANY
    COLLECT IT_SO.
  ENDLOOP.

  SELECT * INTO TABLE IT_COPA FROM CE18888
     FOR ALL ENTRIES IN IT_SO WHERE KAUFN = IT_SO-VBELN AND KDPOS = IT_SO-POSNR
    AND VRGAR = 'A' AND PALEDGER = '01'
    AND WERKS IN S_PLANT. "Add New Company

  CHECK IT_COPA[] IS NOT INITIAL.
  IT_COPA2[] = IT_COPA[].

  SORT IT_COPA2 BY BELNR.
  LOOP AT IT_COPA.
    LOOP AT IT_COPA2 WHERE KAUFN = IT_COPA-KAUFN AND KDPOS = IT_COPA-KDPOS.
      IT_SO-BELNR = IT_COPA2-BELNR.
    ENDLOOP.
    IF SY-SUBRC = 0.
      IT_SO-QCOPA = IT_COPA2-VVSQT.
      MODIFY IT_SO TRANSPORTING QCOPA BELNR WHERE VBELN = IT_COPA-KAUFN AND POSNR = IT_COPA-KDPOS.
    ENDIF.
  ENDLOOP.

  LOOP AT IT_SO.
    V_DOCNO = IT_SO-BELNR.

    IF IT_SO-BELNR = ''.
      IT_SO-ERROR = 'X'.
      IT_SO-ICONS = '@0A@'.
      IT_SO-REMARK = 'No COPA document Number'.
    ELSEIF IT_SO-KCMENG = 0.
      IT_SO-ERROR = 'X'.
      IT_SO-ICONS = '@0A@'.
      IT_SO-REMARK = 'No DO Qty (tidak perlu KE21N)'.

    ELSEIF IT_SO-KCMENG NE IT_SO-QCOPA.
      SELECT BELNR INTO IT_COPA-BELNR FROM CE18888
          WHERE KAUFN = IT_SO-VBELN AND KDPOS = IT_SO-POSNR
         AND VRGAR = 'F' AND PALEDGER = '01' AND PERIO = V_PERIO AND RBELN = ''
        AND WERKS IN S_PLANT. "Add New Company.
        CONCATENATE IT_COPA-BELNR '; ' IT_SO-REMARK INTO IT_SO-REMARK SEPARATED BY SPACE.
        IT_SO-BELNR2 = IT_COPA-BELNR.
      ENDSELECT.
      IF SY-SUBRC = 0.
        IT_SO-ERROR = 'Y'.
        IT_SO-ICONS = '@08@'.
      ELSE.
        IT_SO-ERROR = 'P'.
        IT_SO-ICONS = '@09@'.
        CONCATENATE 'Partial DO' IT_SO-REMARK INTO IT_SO-REMARK.
      ENDIF.
      IT_SO-DELTA = IT_SO-QCOPA - IT_SO-KCMENG.
    ELSEIF IT_SO-KCMENG EQ IT_SO-QCOPA.
      SELECT BELNR INTO IT_COPA-BELNR FROM CE18888
         WHERE KAUFN = IT_SO-VBELN AND KDPOS = IT_SO-POSNR
        AND VRGAR = 'F' AND PALEDGER = '01' AND RBELN = ''
        AND WERKS IN S_PLANT. "Add New Company
        CONCATENATE IT_COPA-BELNR '; ' IT_SO-REMARK INTO IT_SO-REMARK SEPARATED BY SPACE.
        IT_SO-BELNR2 = IT_COPA-BELNR.
      ENDSELECT.
      IF SY-SUBRC = 0.
        IT_SO-ERROR = 'X'.
        IT_SO-ICONS = '@08@'.
      ENDIF.
    ENDIF.

    MODIFY IT_SO.
  ENDLOOP.

  PERFORM GET_TERMINAL.
ENDFORM.                    "get_data



*&---------------------------------------------------------------------*
*&      Form  get_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATE.
  CONCATENATE P_PERIO+0(4) P_PERIO+4(2) '01' INTO P_AMVT-LOW.

  CALL FUNCTION 'SG_PS_GET_LAST_DAY_OF_MONTH'
    EXPORTING
      DAY_IN            = P_PERIO
    IMPORTING
      LAST_DAY_OF_MONTH = P_AMVT-HIGH
    EXCEPTIONS
      DAY_IN_NOT_VALID  = 1
      OTHERS            = 2.

  P_AMVT-SIGN = 'I'.
  P_AMVT-OPTION = 'BT'.
  APPEND P_AMVT.
ENDFORM.                    "get_date

*&---------------------------------------------------------------------*
*&      Form  get_terminal
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_TERMINAL.
  CALL FUNCTION 'TERMINAL_ID_GET'
    EXPORTING
      USERNAME             = SY-UNAME
    IMPORTING
      TERMINAL             = V_TERMINAL
    EXCEPTIONS
      MULTIPLE_TERMINAL_ID = 1
      NO_TERMINAL_FOUND    = 2
      OTHERS               = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    "get_terminal
*&---------------------------------------------------------------------*
*&      Form  run_ke21n
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM RUN_KE21N.
  DATA: V_BUDAT(10).
  S_OPTIONS-DISMODE = 'E'.
  S_OPTIONS-NOBINPT = 'X'.

*  WRITE P_BUDAT TO V_BUDAT.
  WRITE P_PERIO TO V_BUDAT.

  LOOP AT IT_SO WHERE BOX EQ 'X' AND ERROR = ' '.
    CLEAR IT_MSG.
    REFRESH: BDCDATA, IT_MSG.

    PERFORM BDC_DYNPRO      USING 'SAPMKEI2'          '0100'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'        '=NEXT'.
    PERFORM BDC_FIELD       USING 'CEST1-VRGAR'       'F'.
    PERFORM BDC_FIELD       USING 'CEST1-BUDAT'       V_BUDAT.
*    PERFORM BDC_FIELD       USING 'CEST1-PERDE'       V_BLN.
    PERFORM BDC_FIELD       USING 'CEST0-BELNR'       IT_SO-BELNR.

    PERFORM BDC_DYNPRO      USING 'SAPMKEI2'         '0200'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'       '=BUCH'.

    CALL TRANSACTION 'KE21N' USING BDCDATA OPTIONS FROM S_OPTIONS MESSAGES INTO IT_MSG.
    READ TABLE IT_MSG WITH KEY MSGTYP = 'S'.
    IF SY-SUBRC = 0.
      IT_SO-ICONS = '@08@'.
      IT_SO-ERROR = 'Y'.
      IT_SO-BELNR2 = IT_MSG-MSGV1.
      CONCATENATE IT_SO-BELNR2 'ref. from' IT_SO-BELNR INTO IT_SO-REMARK SEPARATED BY SPACE.
      MODIFY IT_SO.

*-- update log table
      WA_ZTLOG-ZDATE = SY-DATUM.
      WA_ZTLOG-ZTIME = SY-UZEIT.
      WA_ZTLOG-ZPROG = SY-CPROG.
      WA_ZTLOG-UNAME = SY-UNAME.
      WA_ZTLOG-TERMINAL = V_TERMINAL.
      WA_ZTLOG-DOCNO = IT_SO-BELNR.
      WA_ZTLOG-TEXT = IT_SO-REMARK.

      INSERT ZTLOG FROM WA_ZTLOG.
      COMMIT WORK.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "run_ke21n


*&---------------------------------------------------------------------*
*&      Form  RUN_KE21N2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM RUN_KE21N2.
  DATA: V_BUDAT(10),
        V_KCMENG(20),
        V_KCMENG2(20).

  S_OPTIONS-DISMODE = 'E'.
  S_OPTIONS-NOBINPT = 'X'.

*  WRITE P_BUDAT TO V_BUDAT.
  WRITE P_PERIO TO V_BUDAT.

  LOOP AT IT_SO WHERE BOX EQ 'X' AND ERROR = 'P'.
    CLEAR IT_MSG.
    REFRESH: BDCDATA, IT_MSG.

    V_KCMENG = IT_SO-KCMENG.
    V_KCMENG2 = IT_SO-KCMENG2.

    PERFORM BDC_DYNPRO      USING 'SAPMKEI2'          '0100'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'        '=NEXT'.
    PERFORM BDC_FIELD       USING 'CEST1-VRGAR'       'F'.
    PERFORM BDC_FIELD       USING 'CEST1-BUDAT'       V_BUDAT.
*    PERFORM BDC_FIELD       USING 'CEST1-PERDE'       V_BLN.
    PERFORM BDC_FIELD       USING 'CEST0-BELNR'       IT_SO-BELNR.

    PERFORM BDC_DYNPRO      USING 'SAPMKEI2' '0200'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'                              '=TAB2'.

    PERFORM BDC_DYNPRO      USING 'SAPMKEI2' '0200'.
    PERFORM BDC_FIELD       USING 'BDC_OKCODE'                              '=BUCHx'.
    PERFORM BDC_FIELD       USING 'GT_LINES_VAL-VALUE(01)'  V_KCMENG.    "'4'.
    PERFORM BDC_FIELD       USING 'GT_LINES_VAL-VALUE(02)'  V_KCMENG2.    "'3'.
    CALL TRANSACTION 'KE21N' USING BDCDATA OPTIONS FROM S_OPTIONS MESSAGES INTO IT_MSG.

    READ TABLE IT_MSG WITH KEY MSGTYP = 'S'.
    IF SY-SUBRC = 0.
      IT_SO-ICONS = '@08@'.
      IT_SO-ERROR = 'Y'.
      IT_SO-BELNR2 = IT_MSG-MSGV1.
      IF IT_SO-REMARK = ''.
        CONCATENATE IT_SO-BELNR2 'ref. from' IT_SO-BELNR INTO IT_SO-REMARK SEPARATED BY SPACE.
      ELSE.
        CONCATENATE IT_SO-BELNR2 IT_SO-REMARK INTO IT_SO-REMARK SEPARATED BY SPACE.
      ENDIF.
      MODIFY IT_SO.

*-- update log table
      WA_ZTLOG-ZDATE = SY-DATUM.
      WA_ZTLOG-ZTIME = SY-UZEIT.
      WA_ZTLOG-ZPROG = SY-CPROG.
      WA_ZTLOG-UNAME = SY-UNAME.
      WA_ZTLOG-TERMINAL = V_TERMINAL.
      WA_ZTLOG-DOCNO = IT_SO-BELNR.
      WA_ZTLOG-TEXT = IT_SO-REMARK.

      UPDATE ZTLOG FROM WA_ZTLOG.
      COMMIT WORK.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "run_ke21n