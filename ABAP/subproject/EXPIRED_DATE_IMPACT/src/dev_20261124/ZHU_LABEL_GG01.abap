*&---------------------------------------------------------------------*
* Report           : ZHU_LABEL_GG01                                    *
* Created by       : Mualifi                                           *
* Created by       : 22-11-2013                                        *
* Application Area : MM                                                *
* Description      : Print Pallet Labels Gudang Garam                  *
*&---------------------------------------------------------------------*
REPORT  ZHU_LABEL_GG01                           .
DATA: IT_ZHMS LIKE ZHMS OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF ITAB OCCURS 10,
       EXIDV TYPE N LENGTH 20, "LIKE vekp-exidv,    "HU number
       BSTKD LIKE VBKD-BSTKD,    "PO number
       BSTKD_E LIKE VBKD-BSTKD_E,    "PO number
       PRTNO(40),                "karakteristik SO (special touch-1)
       PRTDC(40),                "Part Description
       PRTSP(64),                "Part specification
       PROLL TYPE P DECIMALS 0,    "roll per pallet
       PDATE LIKE SY-DATUM,                 "Berisi tanggal GR batch dengan format MM/YYYY
       EDATE LIKE SY-DATUM,                 "Berisi tanggal Used Before Batch dengan format MM/YYYY
       NTGEW LIKE VEKP-NTGEW,     "nett weight
       BRGEW TYPE P DECIMALS 2, "LIKE zhms-gweight,     "gross weight
       ZTYPE(10),
       ZCORE(2),
       LENGT(20),
       WIDTH(20),
       THICK(20),
       ZCONV LIKE API_VALI-ATWRT,
       MATNR LIKE MCH1-MATNR,
       CHARG LIKE MCH1-CHARG,
       VLIVE TYPE P DECIMALS 0,
       SONUM LIKE VEPO-SONUM,
       PALID LIKE ZHMS-PALID,
END OF ITAB.

DATA : BEGIN OF IT_LABEL OCCURS 0,
       TXT01(100),
  END OF IT_LABEL.


DATA : BEGIN OF I_HU OCCURS 10,
       VENUM LIKE VEKP-VENUM,
       EXIDV LIKE VEKP-EXIDV,
       CUOBJ LIKE VEPO-CUOBJ,
       END OF I_HU.

DATA: I_CHAR TYPE CUXE1CUVAL OCCURS 0 WITH HEADER LINE.

DATA: V_EXIDV TYPE N LENGTH 20.
DATA: V_PALID LIKE ZHMS-PALID,
      V_NOCOA LIKE ZHMS-NOCOA,
      V_ROUND TYPE P DECIMALS 0.
DATA: V_TITLE(64),
      V_NOTOK(1),
      ANS TYPE CHAR1.

DATA: FIELDS TYPE SVAL OCCURS 0 WITH HEADER LINE.

DATA: V_BCODE TYPE CHAR41,
      V_PRTNO TYPE CHAR12,
      V_TYPE TYPE CHAR12,
      V_SIZE TYPE CHAR36,
      V_PDATE TYPE CHAR12,
      V_EDATE TYPE CHAR12,
      V_HUNO TYPE CHAR12,
      V_PALED TYPE CHAR12,
      V_RQTY TYPE CHAR12,
      V_KQTY TYPE CHAR12.

*--- HU items
DATA: BEGIN OF IT_ERSDA OCCURS 0,
      MATNR LIKE MCH1-MATNR,
      CHARG LIKE MCH1-CHARG,
      ERSDA LIKE MCH1-ERSDA,
      END OF IT_ERSDA.

DATA: IT_EXIDV TYPE HUM_EXIDV_T.
DATA: IT_VEPO LIKE VEPOVB OCCURS 0,
      WA_VEPO TYPE VEPOVB OCCURS 0 WITH HEADER LINE.

*--- smartforms.
DATA: V_FORMNAME   TYPE TDSFNAME  VALUE 'ZSF_LABEL_KDM',
      V_FUNCNAME   TYPE RS38L_FNAM.
*DATA: I_NAST LIKE NAST.
DATA: I_SSFCOMPOP TYPE SSFCOMPOP.
DATA: I_SSFCTRLOP  TYPE SSFCTRLOP.
DATA: I_RECIPIENT          TYPE SWOTOBJID.
DATA: I_SENDER             TYPE SWOTOBJID.
*DATA: I_ADDR_KEY           LIKE ADDR_KEY.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS: P_EXIDV LIKE VEKP-EXIDV.
PARAMETERS: V_STD(1) DEFAULT '1' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B1.

*--- start of selection
START-OF-SELECTION.
  IF V_STD = '1' OR V_STD = '0'.
  ELSE.
    MESSAGE 'Standard Quantity harus berisi 1 atau 0' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM F_GET_HU_ITEMS.
  PERFORM FIND_DATA.
  PERFORM SET_PALNO.
  IF V_NOTOK NE 'X'.
    PERFORM DL_DATA.
  ELSE.
    MESSAGE 'Gagal update data pallet number' TYPE 'E'.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  f_get_expired
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_HU_ITEMS.
*  V_EXIDV = ITAB-EXIDV.
  APPEND P_EXIDV TO IT_EXIDV.

  CALL FUNCTION 'HU_GET_HUS_DB'
    EXPORTING
      IT_HU_NUMBERS = IT_EXIDV
    IMPORTING
*     ET_HU_HEADER  =
      ET_HU_ITEMS   = IT_VEPO.

*  IF sy-subrc = 0.
*    DELETE it_vepo WHERE vemng = 0.
*  ENDIF.
ENDFORM.                    "f_get_expired*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  find_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FIND_DATA.
  DATA: V_ROUND TYPE P DECIMALS 2,
        V_VENUM LIKE VEKP-VENUM.

  SELECT SINGLE VENUM INTO V_VENUM FROM VEKP WHERE EXIDV = P_EXIDV.
  LOOP AT IT_VEPO INTO WA_VEPO WHERE VENUM = V_VENUM.
    IF WA_VEPO-SONUM = ''.
      V_VENUM = WA_VEPO-UNVEL.
      LOOP AT IT_VEPO INTO WA_VEPO WHERE VENUM = V_VENUM.
        EXIT.
      ENDLOOP.
    ENDIF.
    EXIT.
  ENDLOOP.

  IF WA_VEPO-SONUM NE ''.
*--- get Part number.
    SELECT SINGLE KDMAT INTO ITAB-PRTNO FROM VBAP WHERE VBELN = WA_VEPO-SONUM+0(10) AND POSNR = WA_VEPO-SONUM+10(6).
    IF SY-SUBRC NE 0.
      CLEAR ITAB-PRTNO.
    ENDIF.

    SELECT SINGLE CUOBJ INTO I_HU-CUOBJ FROM VBAP WHERE VBELN = WA_VEPO-SONUM+0(10) AND POSNR = WA_VEPO-SONUM+10(6).

*--- get PO number by Cust add by Afir 12-09-2018
    SELECT SINGLE BSTKD INTO ITAB-BSTKD FROM VBKD WHERE VBELN = WA_VEPO-SONUM+0(10).

    IF SY-SUBRC = 0.
      PERFORM GET_LIVE.
      PERFORM GET_SOCHAR.
    ELSE.
      MESSAGE 'Nomor HU atau nomor SO tidak ada...!'  TYPE 'E'.
    ENDIF.
  ELSE.
    MESSAGE 'HU tidak terikat SO....!' TYPE 'E'.
  ENDIF.

  DELETE IT_VEPO WHERE VEMNG = 0.

*--- find weight
  CLEAR ITAB-NTGEW.
  LOOP AT IT_VEPO INTO WA_VEPO.
    ITAB-NTGEW = ITAB-NTGEW + WA_VEPO-VEMNG.
  ENDLOOP.
  ITAB-PROLL = ITAB-NTGEW / ITAB-ZCONV.
  V_ROUND = ITAB-NTGEW / ITAB-PROLL.
  ITAB-NTGEW = ITAB-PROLL * V_ROUND.
ENDFORM.                    "find_data


*--- get SO Characteristic.
FORM GET_SOCHAR.
  CALL FUNCTION 'MILL_SE_GET_CHAR_AND_VALUE'
    EXPORTING
      INSTANCE                = I_HU-CUOBJ
    TABLES
      ET_VALUE                = I_CHAR
    EXCEPTIONS
      MATERIAL_HAS_NO_PROFIL  = 1
      NO_CONFIGURATION_PARAMS = 2
      FATAL_ERROR             = 3
      OTHERS                  = 4.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.

    CLEAR: ITAB-ZTYPE, ITAB-ZTYPE, ITAB-THICK, ITAB-WIDTH,
           ITAB-LENGT, ITAB-ZCORE, ITAB-ZCONV, ITAB-PROLL.
    LOOP AT I_CHAR.
      CASE I_CHAR-CHARC.
*        WHEN 'ZZSPECIALTOUCH-1'.
*          itab-prtno = i_char-value_txt.
        WHEN 'ZZTYPE'.
          ITAB-ZTYPE = I_CHAR-VALUE.
        WHEN 'ZZTHICKNESS'.
          V_ROUND = I_CHAR-VALUE.
          WRITE V_ROUND TO ITAB-THICK LEFT-JUSTIFIED.
        WHEN 'ZZWIDTH'.
          ITAB-WIDTH = I_CHAR-VALUE_TXT.
          REPLACE ',' IN ITAB-WIDTH  WITH '.'.
        WHEN 'ZZLENGTH'.
          ITAB-LENGT = I_CHAR-VALUE_TXT.
          REPLACE ',' IN ITAB-LENGT  WITH '.'.
        WHEN 'ZZCORE'.
          ITAB-ZCORE = I_CHAR-VALUE_TXT.
        WHEN 'ZZCONVERSIONROLLKG'.
          ITAB-ZCONV = I_CHAR-VALUE.
          REPLACE ',' WITH '' INTO ITAB-ZCONV.   "T005X
          CONDENSE ITAB-ZCONV NO-GAPS.
*        WHEN 'ZZSPECIALTOUCH-1'.
*          itab-prtno = i_char-value.

      ENDCASE.
    ENDLOOP.

    READ TABLE I_CHAR WITH KEY CHARC = 'ZZALIAS'.
    IF SY-SUBRC = 0.
      ITAB-ZTYPE = I_CHAR-VALUE.
    ELSE.
      CONCATENATE ITAB-ZTYPE '-' ITAB-THICK  INTO ITAB-ZTYPE.
    ENDIF.
    CONCATENATE ITAB-ZTYPE  ', ( ' ITAB-WIDTH ' mm x  ' ITAB-LENGT ' m); ' INTO ITAB-PRTSP.

*    itab-proll = itab-ntgew / itab-zconv.
  ENDIF.
ENDFORM.                    "get_sochar

*--- get live
FORM GET_LIVE.
*- start of modify by afir for production date
  DATA: BEGIN OF IT_BUDAT OCCURS 0,
          MBLNR LIKE MSEG-MBLNR,
          MATNR LIKE MSEG-MATNR,
          SMBLN LIKE MSEG-SMBLN,
          BWART LIKE MSEG-BWART,
          CHARG LIKE MSEG-CHARG,
          BUDAT LIKE MSEG-BUDAT_MKPF,
    END OF IT_BUDAT.

  DATA: ITAB2 LIKE IT_BUDAT OCCURS 0  WITH HEADER LINE.

  DATA I_BATCH LIKE API_VALI OCCURS 0 WITH HEADER LINE.
  DATA: V_MSG(70).

  CLEAR: I_BATCH, V_MSG.
  REFRESH: I_BATCH.

  DELETE IT_VEPO WHERE VEMNG = 0.
  SELECT MBLNR MATNR SMBLN BWART CHARG BUDAT_MKPF INTO TABLE IT_BUDAT FROM MSEG
  FOR ALL ENTRIES IN IT_VEPO WHERE CHARG = IT_VEPO-CHARG AND BWART IN (101,102).

  ITAB2[] = IT_BUDAT[].
  LOOP AT ITAB2 WHERE SMBLN NE ''.
    DELETE IT_BUDAT WHERE MBLNR = ITAB2-SMBLN.
  ENDLOOP.

  IF IT_BUDAT[] IS INITIAL.
    CLEAR: ITAB-EDATE.
    CONCATENATE 'Batch no.' IT_BUDAT-CHARG 'tidak ada GRN 101' INTO V_MSG SEPARATED BY SPACE.
    MESSAGE V_MSG TYPE 'E'.
  ENDIF.

  SORT IT_BUDAT BY BUDAT DESCENDING.
  READ TABLE IT_BUDAT INDEX 1.

  FIELDS-TABNAME = 'SYST'.
  FIELDS-FIELDNAME = 'DATUM'.
  READ TABLE IT_LABEL INDEX 5.
  REPLACE ALL OCCURRENCES OF '/' IN IT_BUDAT-BUDAT WITH ''.
  CONCATENATE IT_BUDAT-BUDAT+0(4) IT_BUDAT-BUDAT+4(2)  IT_BUDAT-BUDAT+6(2) INTO IT_BUDAT-BUDAT.
  FIELDS-VALUE = IT_BUDAT-BUDAT.
  APPEND FIELDS.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = 'Cek Tanggal Produksi'
      TEXT_QUESTION         = 'Apakah anda ingin mengganti tanggal produksi?'
      TEXT_BUTTON_1         = 'Ya'
      TEXT_BUTTON_2         = 'Tidak'
      DEFAULT_BUTTON        = 'A'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = ANS.

  IF ANS = '1'.
    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        POPUP_TITLE = 'Masukkan Tanggal Produksi Baru'
      TABLES
        FIELDS      = FIELDS[].

    READ TABLE FIELDS INDEX 1.
    IF FIELDS-VALUE IS NOT INITIAL.
      ITAB-PDATE = FIELDS-VALUE.
    ENDIF.
  ELSE.
    ITAB-PDATE = IT_BUDAT-BUDAT.
  ENDIF.

  CALL FUNCTION 'QC01_BATCH_VALUES_READ'
    EXPORTING
      I_VAL_MATNR  = IT_BUDAT-MATNR
      I_VAL_CHARGE = IT_BUDAT-CHARG
    TABLES
      T_VAL_TAB    = I_BATCH.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    READ TABLE I_BATCH WITH KEY ATNAM = 'ZZEXPIREDLIVE'.
    IF SY-SUBRC = 0.
      ITAB-VLIVE = I_BATCH-ATWRT.
    ENDIF.
*- end of modify by afir for production date

    ITAB-EDATE = ITAB-PDATE + ITAB-VLIVE.
  ENDIF.

ENDFORM.                    "get_live


*&---------------------------------------------------------------------*
*&      Form  get_palno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_PALNO.
* GWEIGHT --> Print date
* NOCOA --> Part number

  DATA: V_GWEIGHT LIKE ZHMS-GWEIGHT.   " print date
  CLEAR: IT_ZHMS.
  CLEAR V_NOTOK.

  ITAB-EXIDV = P_EXIDV.

* HU printed
  SELECT * INTO TABLE IT_ZHMS FROM ZHMS WHERE EXIDV = P_EXIDV. "AND GWEIGHT = V_GWEIGHT.
  IF SY-SUBRC = 0. "reprint
    SORT IT_ZHMS BY PALID DESCENDING.
    READ TABLE IT_ZHMS INDEX 1.
    ITAB-PALID = IT_ZHMS-PALID.

  ELSE. "new
*    CONCATENATE SY-DATUM+2(2) SY-DATUM+4(2) SY-DATUM+6(2) INTO V_GWEIGHT.
    CONCATENATE ITAB-PDATE+2(2) ITAB-PDATE+4(2) ITAB-PDATE+6(2) INTO V_GWEIGHT.
    SELECT * INTO TABLE IT_ZHMS FROM ZHMS WHERE NOCOA = ITAB-PRTNO AND GWEIGHT = V_GWEIGHT.

    IF SY-SUBRC = 0. "continue palid
      SORT IT_ZHMS BY PALID DESCENDING.
      READ TABLE IT_ZHMS INDEX 1.

      ITAB-PALID = IT_ZHMS-PALID + 1.

      IT_ZHMS-EXIDV = ITAB-EXIDV.
      IT_ZHMS-PALID = ITAB-PALID.
      IT_ZHMS-GWEIGHT = V_GWEIGHT.
      IT_ZHMS-NOCOA = ITAB-PRTNO.
    ELSE.
      ITAB-PALID = 1.
      IT_ZHMS-EXIDV = ITAB-EXIDV.
      IT_ZHMS-PALID = ITAB-PALID.
      IT_ZHMS-GWEIGHT = V_GWEIGHT.
      IT_ZHMS-NOCOA = ITAB-PRTNO.

    ENDIF.
    REFRESH IT_ZHMS.
*    PERFORM GET_USER.
    APPEND IT_ZHMS.

    INSERT INTO ZHMS VALUES IT_ZHMS.
    IF SY-SUBRC NE 0.  "continue printing
      V_NOTOK = 'X'.
    ENDIF.
    COMMIT WORK.
    IF SY-SUBRC NE 0.  "continue printing
      V_NOTOK = 'X'.
    ENDIF.
  ENDIF.

  APPEND ITAB.
ENDFORM.                    "get_palno



*&---------------------------------------------------------------------*
*&      Form  dl_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DL_DATA.
  DATA: V_TXT(50),
        V_PALID TYPE N LENGTH 3,
        V_PRTNO(25).

  REFRESH IT_LABEL.

  V_PRTNO = ITAB-PRTNO.
  CONDENSE V_PRTNO NO-GAPS.
  SHIFT V_PRTNO RIGHT DELETING TRAILING SPACE.
  TRANSLATE V_PRTNO USING ' 0'.

  V_PALID = ITAB-PALID.
  WRITE V_PALID TO ITAB-PALID.

  CONCATENATE V_PRTNO
  ITAB-EDATE+6(2) ITAB-EDATE+4(2) ITAB-EDATE+2(2)
  ITAB-PDATE+6(2) ITAB-PDATE+4(2) ITAB-PDATE+2(2)
  ITAB-PALID  V_STD
  INTO IT_LABEL-TXT01.
  APPEND IT_LABEL.

  IT_LABEL-TXT01 = ITAB-PRTNO.   CONDENSE IT_LABEL-TXT01. APPEND IT_LABEL.

  IT_LABEL-TXT01 = ITAB-ZTYPE.               APPEND IT_LABEL.
  CONCATENATE ITAB-WIDTH 'mm X' ITAB-LENGT 'm' INTO IT_LABEL-TXT01 SEPARATED BY SPACE.   APPEND IT_LABEL.

  WRITE  ITAB-PDATE TO IT_LABEL-TXT01 DD/MM/YYYY.
  REPLACE ALL OCCURRENCES OF '.' IN IT_LABEL-TXT01 WITH '/'.  APPEND IT_LABEL.

  WRITE  ITAB-EDATE TO IT_LABEL-TXT01 DD/MM/YYYY.
  REPLACE ALL OCCURRENCES OF '.' IN IT_LABEL-TXT01 WITH '/'.  APPEND IT_LABEL.

  IT_LABEL-TXT01 = ITAB-EXIDV.   APPEND IT_LABEL.
  IT_LABEL-TXT01 = ITAB-PALID.   APPEND IT_LABEL.

  V_TXT = ITAB-PROLL.
  CONDENSE V_TXT.
  CONCATENATE 'Quantity :' V_TXT 'rol' INTO IT_LABEL-TXT01 SEPARATED BY SPACE.
  CONDENSE IT_LABEL-TXT01.    APPEND IT_LABEL.

  V_TXT = ITAB-NTGEW.
  WRITE ITAB-NTGEW TO V_TXT DECIMALS 2.
  CONDENSE V_TXT.
  CONCATENATE 'Netto :' V_TXT 'kg' INTO IT_LABEL-TXT01 SEPARATED BY SPACE.
  CONDENSE IT_LABEL-TXT01.    APPEND IT_LABEL.

*--- add by Afir 12-09-2018
  V_TXT = ITAB-BSTKD.
  CONDENSE V_TXT.
  CONCATENATE 'PO Number :' V_TXT INTO IT_LABEL-TXT01 SEPARATED BY SPACE.
  CONDENSE IT_LABEL-TXT01.    APPEND IT_LABEL.
*--- End add by Afir 12-09-2018

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*     BIN_FILESIZE            =
      FILENAME                = 'c:\tslabel\LabelA4GG.txt'
    TABLES
      DATA_TAB                = IT_LABEL
    EXCEPTIONS
      FILE_WRITE_ERROR        = 1
      NO_BATCH                = 2
      GUI_REFUSE_FILETRANSFER = 3
      INVALID_TYPE            = 4
      NO_AUTHORITY            = 5
      UNKNOWN_ERROR           = 6
      HEADER_NOT_ALLOWED      = 7
      SEPARATOR_NOT_ALLOWED   = 8
      FILESIZE_NOT_ALLOWED    = 9
      HEADER_TOO_LONG         = 10
      DP_ERROR_CREATE         = 11
      DP_ERROR_SEND           = 12
      DP_ERROR_WRITE          = 13
      UNKNOWN_DP_ERROR        = 14
      ACCESS_DENIED           = 15
      DP_OUT_OF_MEMORY        = 16
      DISK_FULL               = 17
      DP_TIMEOUT              = 18
      FILE_NOT_FOUND          = 19
      DATAPROVIDER_EXCEPTION  = 20
      CONTROL_FLUSH_ERROR     = 21
      OTHERS                  = 22.

  IF SY-SUBRC = 0.
  ELSEIF SY-SUBRC = 15.
    MESSAGE 'Gagal download data, jangan buka file ggempol.xls..!' TYPE 'E'.
  ELSE.
    MESSAGE 'Gagal download data label, silahkan diulangi lagi.' TYPE 'E'.
  ENDIF.
ENDFORM.                    "dl_data



*&---------------------------------------------------------------------*
*&      Form  f_cetak
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CETAK.

* Get Function Module name of SmartForms
* --------------------------------------
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZHU_LABEL_GG01'
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-SUBRC = 0.

    WRITE: ITAB-EXIDV TO V_EXIDV NO-ZERO.

    CALL FUNCTION V_FUNCNAME
      EXPORTING
        CONTROL_PARAMETERS = I_SSFCTRLOP
        OUTPUT_OPTIONS     = I_SSFCOMPOP
        MAIL_RECIPIENT     = I_RECIPIENT
        MAIL_SENDER        = I_SENDER
        V_BCODE            = V_BCODE
        V_PRTNO            = V_PRTNO
        V_TYPE             = V_TYPE
        V_SIZE             = V_SIZE
        V_PDATE            = V_PDATE
        V_EDATE            = V_EDATE
        V_HUNO             = V_HUNO
        V_PALED            = V_PALED
        V_RQTY             = V_RQTY
        V_KQTY             = V_KQTY.
  ENDIF.
ENDFORM.                    "f_cetak