*&---------------------------------------------------------------------*
*& Report  ZHU_LABEL_PMI
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZHU_LABEL_PMI.
TABLES: ZHMS.
DATA: IT_ZHMS LIKE ZHMS OCCURS 0 WITH HEADER LINE.
DATA IT_CHARG LIKE CUXE1CUVAL OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF ITAB OCCURS 10,
        ICODE(9) TYPE C,"item code
        ORDER(15) TYPE C, "order number
        LTYPE(6) TYPE C, "line type
        PDATE(9) TYPE C, "production date
        BARC1(38) TYPE C, " barcode I
        BARC2(37) TYPE C, "barcode h
        BARC3(19) TYPE C, "barcode q
        WIDTH(6) TYPE C, "width
        LENGT(6) TYPE C, "lenght
        GWEIG(6) TYPE C, "gross
        NWEIG(6) TYPE C, "net
        PALID(4) TYPE C, "palet identification
        PALNO LIKE VEKP-EXIDV,  "(11) TYPE c, "manuf number/ batch
        NOCOA(30) TYPE C, "QA
        ROLPL(4) TYPE C, "number of piece per palet
        PALQT(3) TYPE C, "total palet ball
        EXPDT(11) TYPE C, "exp date
        THICK(4) TYPE C, "thickness
        STCH1(35) TYPE C,  "Special touch-1
        DESIG(36) TYPE C, "quality/designation
       END OF ITAB.

DATA : BEGIN OF ITAB_DL OCCURS 10,
        ICODE(9) TYPE C,"item code
        ORDER(15) TYPE C, "order number
        LTYPE(6) TYPE C, "line type
        PDATE(9) TYPE C, "production date
        BARC1(38) TYPE C, " barcode I
        BARC2(37) TYPE C, "barcode h
        BARC3(19) TYPE C, "barcode q
        WIDTH(6) TYPE C, "width
        LENGT(6) TYPE C, "lenght
        GWEIG(6) TYPE C, "gross
        NWEIG(6) TYPE C, "net
        PALID(4) TYPE C, "palet identification
        PALNO(21) TYPE C, "manuf number/ batch
        NOCOA(30) TYPE C, "QA
        ROLPL(4) TYPE C, "number of piece per palet
        PALQT(3) TYPE C, "total palet ball
        EXPDT(11) TYPE C, "exp date
        THICK(4) TYPE C, "thickness
        STCH1(35) TYPE C,  "Special touch-1
        DESIG(36) TYPE C, "quality/designation
       END OF ITAB_DL.

DATA: V_POSTDATE LIKE SY-DATUM, V_EXPDATE LIKE SY-DATUM, V_LIFE(4).
DATA : V_RETURNCODE TYPE I.
DATA: V_VAL TYPE P DECIMALS 3.
DATA: V_CUOBJ LIKE VBAP-CUOBJ.
DATA: V_NEWCHARG(16),
              V_SUMROL TYPE N LENGTH 7,
        V_SUMNW TYPE N LENGTH 4,
        V_SUMGW TYPE N LENGTH 4,
        V_PO(18).

CALL SCREEN 1100.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE USER_COMMAND_1100 INPUT.
  DATA: ACT_VENUM   TYPE PDT_T_VENUM.
  DATA: T_HEADS     TYPE  VSEP_T_VEKP.
  DATA: T_ITEMS     TYPE  VSEP_T_VEPO.
  DATA: T_HEADS2     TYPE  VSEP_T_VEKP WITH HEADER LINE.
  DATA: T_ITEMS2     TYPE  VSEP_T_VEPO WITH HEADER LINE.


  CASE SY-UCOMM.
    WHEN 'EXIT'.
      SET SCREEN 0.
    WHEN 'FIND'.
      PERFORM F_FIND.
    WHEN 'SAVE'.
      PERFORM F_SAVE.
    WHEN 'CLEAR'.
      CLEAR ITAB.
    WHEN 'PRINT'.
      PERFORM F_PRINT.
  ENDCASE.
  PERFORM F_CONDENSE_ITAB.

ENDMODULE.                 " USER_COMMAND_1100  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_1100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1100 OUTPUT.
  SET PF-STATUS 'STATUS_1100'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_1100  OUTPUT


*&---------------------------------------------------------------------*
*&      Form  f_save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_SAVE.
  IF ITAB-PALNO EQ '' OR ITAB-GWEIG EQ '' OR ITAB-NOCOA EQ ''.
    MESSAGE 'HU number kosong..!' TYPE 'I'.
    EXIT.
  ENDIF.

  IT_ZHMS-EXIDV = ITAB-PALNO.
  IT_ZHMS-PALID = ITAB-PALID.
  IT_ZHMS-GWEIGHT = ITAB-GWEIG.
  IT_ZHMS-NOCOA = ITAB-NOCOA.

  SELECT SINGLE * INTO ZHMS FROM ZHMS WHERE EXIDV = ITAB-PALNO.
  IF SY-SUBRC NE 0.
*  if it_zhms[] is initial.
    APPEND IT_ZHMS.
    INSERT ZHMS FROM IT_ZHMS.
  ELSE.
    APPEND IT_ZHMS.
    MODIFY ZHMS FROM IT_ZHMS.
  ENDIF.
  COMMIT WORK.

  IF SY-SUBRC EQ 0.
    MESSAGE 'Data Saved..!' TYPE 'I'.
  ELSE.
    MESSAGE 'Fail to Save data...!' TYPE 'I'.
  ENDIF.
ENDFORM.                    "f_save

*&---------------------------------------------------------------------*
*&      Form  f_find
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_FIND.

  REFRESH: ACT_VENUM, T_HEADS, T_ITEMS, T_HEADS2, T_ITEMS2, IT_ZHMS.
  CLEAR: ITAB-PALID, ITAB-GWEIG, ITAB-NOCOA.

  SELECT SINGLE * INTO IT_ZHMS FROM ZHMS WHERE EXIDV = ITAB-PALNO.
  IF SY-SUBRC = 0.
    ITAB-PALID = IT_ZHMS-PALID.
    ITAB-GWEIG = IT_ZHMS-GWEIGHT.
    ITAB-NOCOA = IT_ZHMS-NOCOA.
  ENDIF.
  SELECT SINGLE VENUM INTO T_HEADS2-VENUM FROM VEKP WHERE EXIDV = ITAB-PALNO.
  IF SY-SUBRC NE 0.
    MESSAGE 'Nomor HU tidak ada....!' TYPE 'I'.
    EXIT.
  ELSE.
    APPEND T_HEADS2-VENUM TO ACT_VENUM.
  ENDIF.

  CALL FUNCTION 'HUMO_READ_HU_HEADS_ITEMS_DB'
    EXPORTING
      ACT_VENUMS       = ACT_VENUM
    IMPORTING
      T_HEADS          = T_HEADS
      T_ITEMS          = T_ITEMS
*     T_ROOTS          =
    EXCEPTIONS
      NO_ENTRIES_FOUND = 1
      OTHERS           = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ELSE.
    T_HEADS2[] = T_HEADS[].
    T_ITEMS2[] = T_ITEMS[].
  ENDIF.
  READ TABLE T_HEADS2 WITH KEY EXIDV = ITAB-PALNO.
  IF SY-SUBRC = 0.
    WRITE T_HEADS2-NTGEW TO ITAB-NWEIG DECIMALS 0.
  ENDIF.

*  read table t_items2 with key ALTME = 'ROL'.
*  if sy-subrc = 0.
*    itab-rolpl = t_heads2-ntgew / t_items2-VEMNG.
*  endif.
  PERFORM F_GET_ROLL.

  ITAB-PALQT = '1'.
ENDFORM.                    "f_find


*&---------------------------------------------------------------------*
*&      Form  f_get_roll
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_ROLL.
  READ TABLE T_HEADS2 WITH KEY EXIDV = ITAB-PALNO.
  IF SY-SUBRC NE 0.
    MESSAGE 'Gagal ambil venum.' TYPE 'I'.
    EXIT.
  ENDIF.

  LOOP AT T_ITEMS INTO T_ITEMS2 WHERE VENUM = T_HEADS2-VENUM.
    T_ITEMS2-STATUS = 'OK'.
    MODIFY T_ITEMS2 TRANSPORTING STATUS WHERE VENUM = T_ITEMS2-UNVEL.
  ENDLOOP.
  T_ITEMS2-STATUS = 'OK'.
  MODIFY T_ITEMS2 TRANSPORTING STATUS WHERE VENUM = T_HEADS2-VENUM AND CHARG NE ''.

  CLEAR ITAB-ROLPL.
  LOOP AT T_ITEMS2 WHERE STATUS = 'OK' AND CHARG NE ''.
    ITAB-ROLPL = ITAB-ROLPL + 1.
  ENDLOOP.

*--- get char
  SELECT SINGLE POSEX KDMAT CUOBJ INTO (ITAB-LTYPE, ITAB-ICODE, V_CUOBJ) FROM VBAP
    WHERE VBELN = T_ITEMS2-SONUM+0(10) AND POSNR = T_ITEMS2-SONUM+10(6).

  CALL FUNCTION 'MILL_SE_GET_CHAR_AND_VALUE'
    EXPORTING
      INSTANCE                = V_CUOBJ
    TABLES
      ET_VALUE                = IT_CHARG
    EXCEPTIONS
      MATERIAL_HAS_NO_PROFIL  = 1
      NO_CONFIGURATION_PARAMS = 2
      FATAL_ERROR             = 3
      OTHERS                  = 4.

  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

  LOOP AT IT_CHARG.
*  if it_charg-atnam = 'ZZTYPE'.
*    itab-ltype = it_charg-atwrt.
    IF IT_CHARG-CHARC = 'ZZTHICKNESS'.
      V_VAL = IT_CHARG-VALUE.
      WRITE V_VAL TO ITAB-THICK DECIMALS 0.
    ELSEIF IT_CHARG-CHARC = 'ZZWIDTH'.
      REPLACE ALL OCCURRENCES OF ',' IN IT_CHARG-VALUE WITH ''.
      ITAB-WIDTH = IT_CHARG-VALUE.
*      write v_val to itab-width decimals 0.
    ELSEIF IT_CHARG-CHARC = 'ZZLENGTH'.
      REPLACE ALL OCCURRENCES OF ',' IN IT_CHARG-VALUE WITH ''.
      ITAB-LENGT = IT_CHARG-VALUE.
*      write v_val to itab-lengt decimals 0.
    ELSEIF IT_CHARG-CHARC = 'ZZSPECIALTOUCH-1'.
      V_NEWCHARG = IT_CHARG-VALUE.
    ELSEIF IT_CHARG-CHARC = 'ZZSPECIALTOUCH-2'.
      SPLIT IT_CHARG-VALUE AT ';' INTO IT_CHARG-VALUE ITAB-ORDER.
      CONDENSE ITAB-ORDER.
*      itab-stch1 = it_charg-value.
    ELSEIF IT_CHARG-CHARC = 'ZZSPECIALTOUCH-3'.
      ITAB-DESIG = IT_CHARG-VALUE.
    ELSEIF IT_CHARG-CHARC = 'ZZEXPIREDLIVE'.
      V_LIFE = IT_CHARG-VALUE.
    ENDIF.
  ENDLOOP.

  PERFORM F_POST_DATE.

*---
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = ITAB-LTYPE
    IMPORTING
      OUTPUT = ITAB-LTYPE.

  IF ITAB-LTYPE < 10.
    CONCATENATE '0' ITAB-LTYPE INTO ITAB-LTYPE.
*              itab-ltype = itab-ltype.
*            ELSE.
*              itab-a3 = v_posex.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = ITAB-LTYPE
    IMPORTING
      OUTPUT = ITAB-LTYPE.

  IF ITAB-LTYPE < 10.
    CONCATENATE '0' ITAB-LTYPE INTO ITAB-LTYPE.
  ENDIF.

*--    itab-barc1.
*            CONCATENATE 'I' itab-a1 '0' '01' s_po itab-a11 INTO itab-a5.
  CONCATENATE ITAB-ORDER ITAB-LTYPE INTO V_PO.
  CONCATENATE 'I' ITAB-ICODE '001' V_PO ITAB-PALID INTO ITAB-BARC1.
  REPLACE ALL OCCURRENCES OF '.' IN ITAB-BARC1 WITH ''.
  CONDENSE ITAB-BARC1 NO-GAPS.

*--    itab-barc2.
*          CONCATENATE 'H' '00' '037832' v_postdate+6(2) v_postdate+4(2) v_postdate+2(2) v_expdate+4(2) v_expdate+2(2)
*          v_newcharg+4(6) v_newcharg+13(2) INTO itab-a6.
  IF STRLEN( V_PO ) < 17.

    CONCATENATE 'H00037832' V_POSTDATE+6(2) V_POSTDATE+4(2) V_POSTDATE+2(2) V_EXPDATE+4(2) V_EXPDATE+2(2) V_NEWCHARG+4(6) V_NEWCHARG+13(2) INTO ITAB-BARC2.
    CONDENSE ITAB-BARC2 NO-GAPS.
  ELSE.
    CLEAR ITAB-BARC2.
  ENDIF.

*--    itab-barc3.
*          CONCATENATE 'Q' v_sumrol v_sumnw v_sumgw '01' INTO itab_dl-a7.
  V_SUMROL = ITAB-ROLPL * 10.
  V_SUMNW  = ITAB-NWEIG.
  V_SUMGW  = ITAB-GWEIG.
  CONCATENATE 'Q' V_SUMROL V_SUMNW V_SUMGW '01' INTO ITAB-BARC3.
  CONDENSE ITAB-BARC3 NO-GAPS.

  CONCATENATE V_NEWCHARG+4(6) V_NEWCHARG+13(2) INTO ITAB-STCH1.
ENDFORM.                    "f_get_roll

*&---------------------------------------------------------------------*
*&      Form  f_post_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_POST_DATE.

*  SELECT SINGLE ERSDA INTO V_POSTDATE FROM MCH1 WHERE CHARG EQ T_ITEMS2-CHARG AND MATNR = T_ITEMS2-MATNR.
  CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
    EXPORTING
      MATNR = T_ITEMS2-MATNR
      CHARG = T_ITEMS2-CHARG
    IMPORTING
      PDATE = V_POSTDATE.

  IF SY-SUBRC = 0.
    CONCATENATE V_POSTDATE+6(2) '.' V_POSTDATE+4(2) '.' V_POSTDATE+2(2) INTO ITAB-PDATE.
    V_EXPDATE = V_POSTDATE + V_LIFE.
    CONCATENATE V_EXPDATE+6(2) '.' V_EXPDATE+4(2) '.' V_EXPDATE+0(4) INTO ITAB-EXPDT.
  ENDIF.

ENDFORM.                    "f_post_date



*&---------------------------------------------------------------------*
*&      Form  F_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_PRINT .
  CLEAR ITAB_DL.
  REFRESH ITAB_DL.
  SELECT SINGLE * INTO IT_ZHMS FROM ZHMS WHERE EXIDV = ITAB-PALNO.
  IF SY-SUBRC EQ 0.
    IF IT_ZHMS-PALID NE ITAB-PALID.
      MESSAGE 'Nomor PALID berubah, data harus disimpan dulu..!' TYPE 'I'.
      EXIT.
    ELSEIF IT_ZHMS-GWEIGHT NE ITAB-GWEIG.
      MESSAGE 'Gross weight, data harus disimpan dulu..!' TYPE 'I'.
      EXIT.
    ELSEIF IT_ZHMS-NOCOA NE ITAB-NOCOA.
      MESSAGE 'Nomor COA berubah, data harus disimpan dulu..!' TYPE 'I'.
      EXIT.
    ELSE.
    ENDIF.

  ELSE.
    MESSAGE 'Sebelum di cetak, data harus disimpan dulu..!' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM F_CONDENSE_ITAB.
*---
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = ITAB-PALNO
    IMPORTING
      OUTPUT = ITAB-PALNO.

  ITAB_DL-ICODE = ITAB-ICODE.
*concatenate ';' itab-icode into itab_dl-icode.
  CONCATENATE ';' ITAB-ORDER INTO ITAB_DL-ORDER.
  CONCATENATE ';' ITAB-LTYPE INTO ITAB_DL-LTYPE.
  CONCATENATE ';' ITAB-PDATE INTO ITAB_DL-PDATE.
  CONCATENATE ';' ITAB-BARC1 INTO ITAB_DL-BARC1.
  CONCATENATE ';' ITAB-BARC2 INTO ITAB_DL-BARC2.
  CONCATENATE ';' ITAB-BARC3 INTO ITAB_DL-BARC3.
  CONCATENATE ';' ITAB-WIDTH INTO ITAB_DL-WIDTH.
  CONCATENATE ';' ITAB-LENGT INTO ITAB_DL-LENGT.
  CONCATENATE ';' ITAB-NWEIG INTO ITAB_DL-NWEIG.
  CONCATENATE ';' ITAB-GWEIG INTO ITAB_DL-GWEIG.
  CONCATENATE ';' ITAB-PALID INTO ITAB_DL-PALID.
  CONCATENATE ';' ITAB-PALNO INTO ITAB_DL-PALNO.
  CONCATENATE ';' ITAB-NOCOA INTO ITAB_DL-NOCOA.
  CONCATENATE ';' ITAB-ROLPL INTO ITAB_DL-ROLPL.
  CONCATENATE ';' ITAB-PALQT INTO ITAB_DL-PALQT.
  CONCATENATE ';' ITAB-EXPDT INTO ITAB_DL-EXPDT.
  CONCATENATE ';' ITAB-THICK INTO ITAB_DL-THICK.
  CONCATENATE ';' ITAB-STCH1 INTO ITAB_DL-STCH1.
  CONCATENATE ';' ITAB-DESIG INTO ITAB_DL-DESIG.

  APPEND ITAB_DL.

*---
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME              = 'c:\tslabel\pmi.txt'
      FILETYPE              = 'ASC'
      WRITE_FIELD_SEPARATOR = ' '
    TABLES
      DATA_TAB              = ITAB_DL.

  CALL FUNCTION 'GUI_RUN'
    EXPORTING
      COMMAND    = 'pmi.exe'
      CD         = 'C:\tslabel\'
    IMPORTING
      RETURNCODE = V_RETURNCODE.
ENDFORM.                    " F_PRINT


*&---------------------------------------------------------------------*
*&      Form  f_condense_itab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CONDENSE_ITAB.
  CONDENSE ITAB-ICODE.
  CONDENSE ITAB-ORDER.
  CONDENSE ITAB-LTYPE.
  CONDENSE ITAB-PDATE.
  CONDENSE ITAB-BARC1.
  CONDENSE ITAB-BARC2.
  CONDENSE ITAB-BARC3.
  CONDENSE ITAB-WIDTH.
  CONDENSE ITAB-LENGT.
  CONDENSE ITAB-NWEIG.
  CONDENSE ITAB-GWEIG.
  CONDENSE ITAB-PALID.
  CONDENSE ITAB-PALNO.
  CONDENSE ITAB-NOCOA.
  CONDENSE ITAB-ROLPL.
  CONDENSE ITAB-PALQT.
  CONDENSE ITAB-EXPDT.
  CONDENSE ITAB-THICK.
  CONDENSE ITAB-STCH1.
  CONDENSE ITAB-DESIG.

ENDFORM.                    "f_condense_itab