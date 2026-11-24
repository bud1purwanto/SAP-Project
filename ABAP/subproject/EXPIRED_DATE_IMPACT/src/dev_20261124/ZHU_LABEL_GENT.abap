*&---------------------------------------------------------------------*
* Report           : ZHU_LABEL_GENT                                    *
* Created by       : Mualifi                                           *
* Created by       : 10-02-2015                                        *
* Application Area : MM                                                *
* Description      : Print Pallet Labels Gencteks                      *
*&---------------------------------------------------------------------*
REPORT  ZHU_LABEL_GENT                           .
DATA: IT_VEPO TYPE VEPO OCCURS 0 WITH HEADER LINE.
DATA: V_VENUM LIKE VEKP-VENUM.

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
PARAMETERS: P_EXIDV LIKE VEKP-EXIDV. "DEFAULT '6000011027'.
SELECTION-SCREEN END OF BLOCK B1.

*--- start of selection
START-OF-SELECTION.
  PERFORM F_GET_HU_ITEMS.
  PERFORM F_CETAK.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  f_get_expired
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_HU_ITEMS.
  DATA: BEGIN OF LVBPLP OCCURS 0.
          INCLUDE STRUCTURE VBPLP.
  DATA: END OF LVBPLP.
  DATA: COMWA LIKE  VBCO3.
  COMWA-EXIDV = P_EXIDV.

  SELECT SINGLE VENUM INTO V_VENUM FROM VEKP WHERE EXIDV = P_EXIDV.

  SELECT * INTO TABLE IT_VEPO FROM VEPO WHERE VENUM = V_VENUM.

  SELECT * FROM VEPO  APPENDING TABLE IT_VEPO
    FOR ALL ENTRIES IN IT_VEPO WHERE VENUM = IT_VEPO-UNVEL.

  DELETE IT_VEPO WHERE CHARG = ''.
  DELETE ADJACENT DUPLICATES FROM IT_VEPO COMPARING CHARG.

*-- get ROLNO
  DATA: V_ATWRT LIKE AUSP-ATWRT,
        V_ATFLV TYPE P DECIMALS 2,  "LIKE AUSP-ATFLV,
        V_NO TYPE P.

  CLEAR: IT_VEPO-VENUM.
  MODIFY IT_VEPO TRANSPORTING VENUM WHERE VENUM NE ''.

  LOOP AT IT_VEPO.
    CLEAR V_ATWRT.
    V_NO =  V_NO + 1.
    IT_VEPO-WERKS = V_NO.
    SELECT SINGLE  AUSP~ATWRT FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK INTO V_ATWRT
    WHERE MCH1~MATNR  = IT_VEPO-MATNR  AND   MCH1~CHARG  = IT_VEPO-CHARG    AND   CABN~ATNAM = 'ZZNOMORROLL'.
    IT_VEPO-P_MATERIAL = V_ATWRT. "CONDENSE IT_MSEG-ZZTHICKNESS.

    CLEAR: V_ATWRT, V_ATFLV.
    SELECT SINGLE  AUSP~ATFLV FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK INTO V_ATFLV
    WHERE MCH1~MATNR  = IT_VEPO-MATNR  AND   MCH1~CHARG  = IT_VEPO-CHARG    AND   CABN~ATNAM = 'ZZWIDTH'.
*    WRITE V_ATFLV TO IT_VEPO-SONUM DECIMALS 2.
    IT_VEPO-SONUM = V_ATFLV.
    CONDENSE IT_VEPO-SONUM.

    CLEAR: V_ATWRT, V_ATFLV.
    SELECT SINGLE  AUSP~ATFLV FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK INTO V_ATFLV
    WHERE MCH1~MATNR  = IT_VEPO-MATNR  AND   MCH1~CHARG  = IT_VEPO-CHARG    AND   CABN~ATNAM = 'ZZCONVERSIONROLLKG'.
*    WRITE V_ATFLV TO IT_VEPO-SPE_IDPLATE DECIMALS 2.
    IT_VEPO-SPE_IDPLATE = V_ATFLV.
    CONDENSE IT_VEPO-SPE_IDPLATE.

*-- posisi turunan
    V_ATWRT = '00'.
    SELECT SINGLE  AUSP~ATWRT FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK INTO V_ATWRT
    WHERE MCH1~MATNR  = IT_VEPO-MATNR  AND   MCH1~CHARG  = IT_VEPO-CHARG    AND   CABN~ATNAM = 'ZZDERIVATIVEMS'.
    CONDENSE V_ATWRT.
    CONCATENATE IT_VEPO-VENUM V_ATWRT INTO IT_VEPO-VENUM.

    V_ATWRT = '00'.
    SELECT SINGLE  AUSP~ATWRT FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK INTO V_ATWRT
    WHERE MCH1~MATNR  = IT_VEPO-MATNR  AND   MCH1~CHARG  = IT_VEPO-CHARG    AND   CABN~ATNAM = 'ZZPOSITIONMS'.
    CONDENSE V_ATWRT.
    CONCATENATE IT_VEPO-VENUM V_ATWRT INTO IT_VEPO-VENUM.

    V_ATWRT = '00'.
    SELECT SINGLE  AUSP~ATWRT FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK INTO V_ATWRT
    WHERE MCH1~MATNR  = IT_VEPO-MATNR  AND   MCH1~CHARG  = IT_VEPO-CHARG    AND   CABN~ATNAM = 'ZZDERIVATIVESS'.
    CONDENSE V_ATWRT.
    CONCATENATE IT_VEPO-VENUM V_ATWRT INTO IT_VEPO-VENUM.

    V_ATWRT = '00'.
    SELECT SINGLE  AUSP~ATWRT FROM CABN JOIN AUSP ON CABN~ATINN = AUSP~ATINN JOIN MCH1 ON CUOBJ_BM = AUSP~OBJEK INTO V_ATWRT
    WHERE MCH1~MATNR  = IT_VEPO-MATNR  AND   MCH1~CHARG  = IT_VEPO-CHARG    AND   CABN~ATNAM = 'ZZPOSITIONSS'.
    CONDENSE V_ATWRT.
    CONCATENATE IT_VEPO-VENUM V_ATWRT INTO IT_VEPO-VENUM.
*---
    MODIFY IT_VEPO.

  ENDLOOP.
ENDFORM.                    "f_get_expired*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*&      Form  f_cetak
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_CETAK.
  DATA: P_QTY(2).

  DESCRIBE TABLE IT_VEPO LINES P_QTY.

* Get Function Module name of SmartForms
* --------------------------------------
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZHU_LABEL_GENT'
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-SUBRC = 0.
    CALL FUNCTION V_FUNCNAME
      EXPORTING
        CONTROL_PARAMETERS = I_SSFCTRLOP
        OUTPUT_OPTIONS     = I_SSFCOMPOP
        MAIL_RECIPIENT     = I_RECIPIENT
        MAIL_SENDER        = I_SENDER
        P_EXIDV            = P_EXIDV
        P_QTY              = P_QTY
      TABLES
        IT_VEPO            = IT_VEPO.
  ENDIF.
ENDFORM.                    "f_cetak