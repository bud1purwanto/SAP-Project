*&---------------------------------------------------------------------*
* Report           : ZHU_LABEL                                         *
* Created by       : Mualifi                                           *
* Created by       : 15-10-2012                                        *
* Application Area : MM                                                *
* Description      : Print Pallet Labels                               *
*&---------------------------------------------------------------------*
REPORT  ZHU_LABEL                           .
TABLES: ZHMS.

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

       END OF ITAB.

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
DATA: V_TITLE(64).

*--- HU items
DATA: BEGIN OF IT_ERSDA OCCURS 0,
      MATNR LIKE MCH1-MATNR,
      CHARG LIKE MCH1-CHARG,
      ERSDA LIKE MCH1-ERSDA,
      END OF IT_ERSDA.

DATA: IT_EXIDV TYPE HUM_EXIDV_T.
DATA: IT_VEPO LIKE VEPOVB OCCURS 0,
      WA_VEPO TYPE VEPOVB OCCURS 0 WITH HEADER LINE.
*  DATA: it_header LIKE vekpvb OCCURS 0.


*--- smartforms.
DATA: V_FORMNAME   TYPE TDSFNAME  VALUE 'ZSF_LABEL_KDM',
      V_FUNCNAME   TYPE RS38L_FNAM.

DATA: I_NAST LIKE NAST.
DATA: I_SSFCOMPOP TYPE SSFCOMPOP.
DATA: I_SSFCTRLOP  TYPE SSFCTRLOP.
DATA: I_RECIPIENT          TYPE SWOTOBJID.
DATA: I_SENDER             TYPE SWOTOBJID.
DATA: I_ADDR_KEY           LIKE ADDR_KEY.

INCLUDE ZHU_LABEL_1100.

*--- end of smartforms
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS: RB1 RADIOBUTTON GROUP GOPT DEFAULT 'X',
            RB2 RADIOBUTTON GROUP GOPT, "GG Gempol
            RB3 RADIOBUTTON GROUP GOPT, "P"GG Gempol
            RB4 RADIOBUTTON GROUP GOPT. "KU020A
SELECTION-SCREEN END OF BLOCK B1.

*--- start of selection
START-OF-SELECTION.
  IF RB1 = 'X'.
    V_TITLE = 'PT. KARYADIBYA MAHARDIKA'.
    CALL SCREEN 1100.
*  ELSEIF RB2 = 'X'.
*    V_TITLE = 'PT. GUDANG GARAM'.
*    CALL SCREEN 1100.
  ELSEIF RB2 = 'X'.
    CALL TRANSACTION 'ZHU021'.
  ELSEIF RB3 = 'X'.
    CALL TRANSACTION 'ZHU020'.
  ELSEIF RB4 = 'X'.
    CALL TRANSACTION 'ZHU025'.
  ENDIF.

END-OF-SELECTION.
*----------------------------------------------------------------------*
*  MODULE status_1000 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE STATUS_1000 OUTPUT.
  SET PF-STATUS '1000'.
  SET TITLEBAR 'ZHU_LABEL'.
ENDMODULE.                 " STATUS_1000  OUTPUT


*&---------------------------------------------------------------------*
*&      Form  f_get_expired
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_HU_ITEMS.
  V_EXIDV = ITAB-EXIDV.
  APPEND V_EXIDV TO IT_EXIDV.

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