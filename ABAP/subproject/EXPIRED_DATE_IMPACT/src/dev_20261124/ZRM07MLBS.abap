*-- bagus aditya putra
*---
REPORT ZRM07MLBS MESSAGE-ID M7 NO STANDARD PAGE HEADING LINE-SIZE 170.

************************************************************************
* Data declarations
************************************************************************

* Type pools
TYPE-POOLS: SLIS, IMREP.


* Database tables
TABLES: MARA, MAKT, MARD, MCHB, MKOL, MSLB, MSKA, MSKU, MSSA, MSPR,
        MSSQ, MBEW, EBEW, QBEW, T134M, T001W, T001L, MARC, T001, T001K,
        T023, T024.

TABLES : SSCRFIELDS.         "for the user-commands

DATA : SAP_CON LIKE DBCON-CON_NAME VALUE 'TRIASDB',
       DBTYPE TYPE DBCON_DBMS.

DATA : ATFLV1 TYPE P LENGTH 5 DECIMALS 1,
       ATFLV2 TYPE P LENGTH 9.
DATA : EXIDV1 TYPE VEKP-EXIDV,
       EXIDV2 TYPE VEKP-EXIDV,
       MAGRV TYPE VEKP-MAGRV,
       UEVEL TYPE VEKP-UEVEL,
       SONUM TYPE VBAK-VBELN,
       SOTEM TYPE VBAP-POSNR.


DATA : IT_CHAR TYPE STANDARD TABLE OF ZCHARACTER WITH HEADER LINE.
FIELD-SYMBOLS : <FS_CHAR> LIKE LINE OF IT_CHAR.

* working table for the entries of all stock tables
DATA: BEGIN OF COLLECTOR OCCURS 0,
       MATNR LIKE MARA-MATNR,
       WERKS LIKE T001W-WERKS,
       LGORT LIKE MARD-LGORT,
       SOBKZ LIKE MKOL-SOBKZ,
       PSPNR               LIKE  MSPR-PSPNR,
       VBELN               LIKE  MSKA-VBELN,
       POSNR               LIKE  MSKA-POSNR,
       LIFNR LIKE MSLB-LIFNR,
       KUNNR LIKE MSKU-KUNNR,
       LVORM               LIKE  MARD-LVORM,

       KZBWS LIKE MSSA-KZBWS,
       CHARG LIKE MCHB-CHARG,
       LABST LIKE MARD-LABST,
       INSME LIKE MARD-INSME,
       SPEME LIKE MARD-SPEME,
       EINME LIKE MARD-EINME,
       RETME LIKE MARD-RETME,
       UMLME LIKE MARD-UMLME,
       BWESB               LIKE  MARC-BWESB,                "AC0K020254
       GLGMG LIKE MARC-GLGMG,                               "n912093
       TRAME LIKE MARC-TRAME,                               "n912093
       UMLMC LIKE MARC-UMLMC.                               "n912093
DATA: END OF COLLECTOR.

* Internal tables
DATA: BEGIN OF HEADER OCCURS 0,
        MATNR LIKE MARA-MATNR,
        MAKTX LIKE MAKT-MAKTX,
        WERKS LIKE T001W-WERKS,
        NAME1 LIKE T001W-NAME1,
        MTART LIKE MARA-MTART,
        MATKL LIKE MARA-MATKL.
DATA: END OF HEADER.

DATA: BEGIN OF BESTAND OCCURS 0,
*        Key fields
         MATNR LIKE MARA-MATNR,
         WERKS LIKE T001W-WERKS,
         LGORT LIKE MARD-LGORT,
         SOBKZ LIKE MKOL-SOBKZ,
         SSNUM               LIKE  BICKEY-SSNUM,            "n531604
         PSPNR               LIKE  MSPR-PSPNR,              "n531604
         VBELN               LIKE  MSKA-VBELN,              "n531604
         POSNR               LIKE  MSKA-POSNR,              "n531604
         LIFNR LIKE MKOL-LIFNR,
         KUNNR LIKE MSKU-KUNNR,
         KZBWS LIKE MSSA-KZBWS,
         ZZTYPE(50),
         ZZTHICKNESS TYPE P LENGTH  5 DECIMALS 1,
         ZZWIDTH TYPE P LENGTH  9 DECIMALS 0,
         ZZLENGTH  TYPE P LENGTH 9 DECIMALS 0,
         ZZCORE(50),
         ZZCRITERIA(50),
         ZZPACKING(50),
         ZZNOMORROLL(50),
         ZZTREATMENT(50),
         ZZSPLICE_1 TYPE P LENGTH 9 DECIMALS 0,
         ZZSPLICE_2 TYPE P LENGTH 9 DECIMALS 0,
         ZZSPLICE_3 TYPE P LENGTH 9 DECIMALS 0,
         ZZALIAS(50),
         ZZLABEL(50),
         ZZEXLENGTH TYPE P LENGTH 9 DECIMALS 0,
         ZZEXPIREDLIVE TYPE SY-DATUM,
         HUPALLET TYPE VEKP-EXIDV,
         HUBOX TYPE VEKP-EXIDV,
         ERSDA TYPE MCH1-ERSDA,
         AUART TYPE VBAK-AUART,
         BEZEI TYPE TVAGT-BEZEI,
         NAMEX TYPE KNA1-NAME1,
         SONUM TYPE VBAK-VBELN,
         SOTEM TYPE VBAP-POSNR,
         CHARG LIKE MCHB-CHARG,
*        Additional data (texts, unit, ...)

         MAKTX LIKE MARAV-MAKTX,
         BWKEY LIKE MBEW-BWKEY,
         MTART LIKE MARAV-MTART,
         MATKL LIKE MARAV-MATKL,
         MEINS LIKE MARAV-MEINS,
         BWTTY LIKE MARC-BWTTY,
         XCHAR LIKE MARC-XCHAR,
         LGOBE LIKE T001L-LGOBE,
         BWTAR LIKE MCHA-BWTAR,
         WAERS LIKE T001-WAERS,
         NAME1 LIKE T001W-NAME1,
*        Quantities and currencies
         LABST LIKE MARD-LABST,
         WLABS LIKE MBEW-SALK3,
         INSME LIKE MARD-INSME,
         WINSM LIKE MBEW-SALK3,
         SPEME LIKE MARD-SPEME,
         WSPEM LIKE MBEW-SALK3,
         EINME LIKE MARD-EINME,
         WEINM LIKE MBEW-SALK3,
         RETME LIKE MARD-RETME,
         WRETM LIKE MBEW-SALK3,
         UMLME LIKE MARD-UMLME,
         WUMLM LIKE MBEW-SALK3,
         GLGMG LIKE MARC-GLGMG,                             "n912093
         WGLGM LIKE MBEW-SALK3,                             "n912093
         TRAME LIKE MARC-TRAME,                             "n912093
         WTRAM LIKE MBEW-SALK3,                             "n912093
         UMLMC LIKE MARC-UMLMC,                             "n912093
         WUMLC LIKE MBEW-SALK3,                             "n912093

*        Dummy field
         DUMMY               TYPE  ALV_DUMMY,
*        Colour
         FARBE TYPE SLIS_T_SPECIALCOL_ALV,
         LVORM               LIKE  MARD-LVORM,

*        valuated blocked GR stock                       "AC0K020254
         BWESB               LIKE  MARC-BWESB,              "AC0K020254
         WBWESB              LIKE  MBEW-SALK3.              "AC0K020254
*ENHANCEMENT-POINT EHP604_RM07MLBS_03 SPOTS ES_RM07MLBS STATIC .
DATA:  END OF BESTAND.

* define a lean table organ
TYPES : BEGIN OF STYPE_ORGAN,
          WERKS              LIKE  T001W-WERKS,
          BWKEY              LIKE  T001W-BWKEY,
          NAME1              LIKE  T001W-NAME1,
          BUKRS              LIKE  T001-BUKRS,
          WAERS              LIKE  T001-WAERS,
        END OF STYPE_ORGAN,

        STAB_ORGAN           TYPE STANDARD TABLE OF
                             STYPE_ORGAN
                             WITH DEFAULT KEY.

DATA: G_T_ORGAN              TYPE  STAB_ORGAN,
      G_S_ORGAN              TYPE  STYPE_ORGAN.

* define a buffer table for the MARD entries with flag
* for deletion
TYPES : BEGIN OF STYPE_MARD_LV,
          MATNR              LIKE  MARD-MATNR,
          WERKS              LIKE  MARD-WERKS,
          LGORT              LIKE  MARD-LGORT,
          LVORM              LIKE  MARD-LVORM,
        END OF STYPE_MARD_LV,

        HTAB_MARD_LV         TYPE HASHED TABLE OF
                             STYPE_MARD_LV
                   WITH UNIQUE KEY MATNR WERKS LGORT.

DATA : G_S_MARD_LV           TYPE  STYPE_MARD_LV,
       G_T_MARD_LV           TYPE  HTAB_MARD_LV.

* define a buffer table for the storage bins
TYPES : BEGIN OF STYPE_T001L,
          WERKS              LIKE  T001L-WERKS,
          LGORT              LIKE  T001L-LGORT,
          LGOBE              LIKE  T001L-LGOBE,
        END OF STYPE_T001L,

        HTAB_T001L           TYPE HASHED TABLE OF
                             STYPE_T001L
                             WITH UNIQUE KEY WERKS LGORT.

DATA : G_S_T001L             TYPE  STYPE_T001L,
       G_T_T001L             TYPE  HTAB_T001L.

TYPES : BEGIN OF STYPE_T001W,                               "09122009
          WERKS              TYPE  T001W-WERKS,             "09122009
          BWKEY              TYPE  T001W-BWKEY,             "09122009
          NAME1              TYPE  T001W-NAME1,             "09122009
        END OF STYPE_T001W.                                 "09122009
                                                            "09122009
DATA : GT_T001W              TYPE  STANDARD TABLE           "09122009
                                   OF STYPE_T001W.          "09122009

* define working areas for access table organ               "n531604
TYPES : BEGIN OF STYPE_BUFFER,                              "n531604
         WERKS               LIKE  T001W-WERKS,
         BUKRS               LIKE  T001-BUKRS,
         SUBRC               LIKE  SYST-SUBRC,
       END OF STYPE_BUFFER,

       STAB_BUFFER           TYPE STANDARD TABLE OF
                             STYPE_BUFFER
                             WITH DEFAULT KEY.

DATA : G_S_BUFFER          TYPE  STYPE_BUFFER,
       G_T_BUFFER          TYPE  STAB_BUFFER.

* Data for listviewer
DATA: REPID     LIKE SY-REPID.
DATA: FIELDCAT  TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE.
DATA: KEYINFO   TYPE SLIS_KEYINFO_ALV.
DATA: COLOR     TYPE SLIS_T_SPECIALCOL_ALV WITH HEADER LINE.
DATA: LAYOUT    TYPE SLIS_LAYOUT_ALV.

DATA: SORT      TYPE SLIS_T_SORTINFO_ALV WITH HEADER LINE.
DATA: EXCLUDING TYPE SLIS_T_EXTAB WITH HEADER LINE.

* internal working table for events / for the headlines     "n667256
DATA: GS_EVENTS     TYPE SLIS_ALV_EVENT.                    "n667256
DATA: GT_EVENTS     TYPE SLIS_T_EVENT.                      "n667256

                                                            "n667256
* for the header of the list, when alv grid is in use       "n667256
DATA : GT_UEB                TYPE  SLIS_T_LISTHEADER,       "n667256
       GS_UEB                TYPE  SLIS_LISTHEADER.         "n667256

* Variants
DATA: VARIANTE        LIKE DISVARIANT,
      VARIANTE_FLAT   LIKE DISVARIANT,
      DEF_VARIANTE    LIKE DISVARIANT,
      DEF_VARIANTE_F4 LIKE DISVARIANT,
      VARIANT_EXIT(1) TYPE C.

*ENHANCEMENT-POINT RM07MLBS_01 SPOTS ES_RM07MLBS STATIC.
*ENHANCEMENT-POINT RM07MLBS_13 SPOTS ES_RM07MLBS STATIC .
DATA : G_F_VARI_HSQ          LIKE  DISVARIANT-VARIANT,
       G_F_VARI_FLT          LIKE  DISVARIANT-VARIANT.

* working fields to save the initial display variants       "n579976
DATA : G_F_VARI_HSQ_INITIAL  LIKE  DISVARIANT-VARIANT,      "n579976
       G_F_VARI_FLT_INITIAL  LIKE  DISVARIANT-VARIANT.      "n579976

* Global variables for handling ALV functionality
TABLES: MMIM_REP_PRINT.

DATA: ALV_KEYINFO      TYPE SLIS_KEYINFO_ALV.
DATA: ALV_VARIANT      LIKE DISVARIANT.
DATA: ALV_LAYOUT       TYPE SLIS_LAYOUT_ALV.
DATA: ALV_REPID        LIKE SY-REPID.
DATA: ALV_PRINT        TYPE SLIS_PRINT_ALV.
DATA: ALV_DETAIL_FUNC(30)    TYPE  C,
      ALV_COLOR              LIKE      MMIM_REP_PRINT-COLOR.

* User settings for the checkboxes
DATA: OREF_SETTINGS TYPE REF TO CL_MMIM_USERDEFAULTS.

* define working fields
DATA : G_CNT_COL_POS         TYPE I,
       G_CNT_SPOS            TYPE I.

DATA : G_FLAG_OK(01)         TYPE C,
       G_FLAG_MESS_333(01)   TYPE C,
       G_FLAG_T001L(01)      TYPE C.

DATA : G_CNT_VARIANT_ERROR   TYPE I.                        "n667256

* does the user want to suppress objects from plant level ? "n577268
DATA : G_FLAG_SUPPRESS_INIT_LGORT(01)  TYPE C.              "n577268

DATA : BEGIN OF G_FLAG_SOBKZ,
         VBELN(01)           TYPE C,
         PSPNR(01)           TYPE C,
         LIFNR(01)           TYPE C,
         KUNNR(01)           TYPE C,
       END OF G_FLAG_SOBKZ.

CONSTANTS : C_NO_OUT(01)     TYPE C    VALUE 'X',
            C_OUT(01)        TYPE C    VALUE SPACE.

* flag to be set when INITIALIZATION was processed          "n667256
DATA G_FLAG_INITIALIZATION(01) TYPE C.                      "n667256

* authorization check should be always processed            "n829722
DATA T_FLAG_LAUNCHED(01) TYPE C.                            "n829722


************************************************************************
* Selection screen
************************************************************************

SELECTION-SCREEN BEGIN OF BLOCK ABGRENZUNG WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS:
  MATNR  FOR MARA-MATNR MEMORY ID MAT MATCHCODE OBJECT MAT1,
  WERKS  FOR T001L-WERKS  MEMORY ID WRK,                    "718285
  LGORT  FOR T001L-LGORT  MEMORY ID LAG,
  CHARG  FOR MCHB-CHARG  MEMORY ID CHA MATCHCODE OBJECT MCH1.

SELECTION-SCREEN END OF BLOCK ABGRENZUNG.

*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK LBS WITH FRAME TITLE TEXT-070.

SELECT-OPTIONS:
  MATART FOR MARA-MTART,
  MATKLA FOR MARA-MATKL,
  EKGRUP FOR MARC-EKGRP.
*ENHANCEMENT-POINT RM07MLBS_3 SPOTS ES_RM07MLBS STATIC .

SELECTION-SCREEN END OF BLOCK LBS.

*----------------------------------------------------------------------*

* for the selection os special stocks
SELECTION-SCREEN BEGIN OF BLOCK LB2 WITH FRAME TITLE TEXT-071.

* for the selection os special stocks
PARAMETERS : PA_SOND       LIKE      RMMMB-KZLSO
                           DEFAULT   'X'.

SELECT-OPTIONS:
  SO_SOBKZ                 FOR  MKOL-SOBKZ.

SELECTION-SCREEN END OF BLOCK LB2.

*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK LB1 WITH FRAME TITLE TEXT-080.

* select only lines who contain at least one negative stock
PARAMETERS: NEGATIV LIKE AM07M-SENEG.

* Documentation for parameter XMCHB improved                "n494306
PARAMETERS: XMCHB            LIKE      AM07M-MB52_XMCHB     "n494306
                             DEFAULT   'X'.

* Checkbox to eliminate lines with zero stocks
PARAMETERS: NOZERO   LIKE RMMMB-KZNUL.

* Checkbox to disable value processing.
* Documentation for parameter NOVALUES improved             "n494306
PARAMETERS: NOVALUES         LIKE      AM07M-MB52_NOVAL.    "n494306


SELECTION-SCREEN END OF BLOCK LB1.

*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK LISTE WITH FRAME TITLE TEXT-005.

* choose flat or hierarchic list                            "n531604
SELECTION-SCREEN BEGIN OF LINE.                             "n531604
SELECTION-SCREEN         POSITION 1.                        "n531604
PARAMETERS : PA_HSQ      LIKE  AM07M-MB52_ALV_HSQ        "#EC SEL_WRONG
                         DEFAULT  'X'                       "n531604
                         RADIOBUTTON GROUP ALVV             "n531604
                         USER-COMMAND ALVV.                 "n531604
SELECTION-SCREEN         COMMENT 3(40)  TEXT-006            "n531604
                         FOR FIELD PA_HSQ.                  "n531604
SELECTION-SCREEN END OF LINE.                               "n531604
                                                            "n531604
SELECTION-SCREEN BEGIN OF LINE.                             "n531604
SELECTION-SCREEN         POSITION 1.                        "n531604
PARAMETERS : PA_FLT      LIKE  AM07M-MB52_ALV_FLT        "#EC SEL_WRONG
                         RADIOBUTTON GROUP ALVV.            "n531604
SELECTION-SCREEN         COMMENT 3(40)  TEXT-007            "n531604
                         FOR FIELD PA_FLT.                  "n531604
SELECTION-SCREEN END OF LINE.                               "n531604

*  parameters :
*    pa_grid                  type  MB_XFELD
*                             default 'X'
*                             radiobutton group alv1,
*    pa_class                 type  MB_XFELD
*                             radiobutton group alv1.

PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT.

SELECTION-SCREEN END OF BLOCK LISTE.
*ENHANCEMENT-POINT EHP604_RM07MLBS_04 SPOTS ES_RM07MLBS STATIC .

SELECTION-SCREEN BEGIN OF BLOCK EXT WITH FRAME TITLE TXT3.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER LRB1 RADIOBUTTON GROUP LBR.
SELECTION-SCREEN COMMENT 4(20) TXT1 FOR FIELD LRB1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER LRB2 RADIOBUTTON GROUP LBR.
SELECTION-SCREEN COMMENT 4(20) TXT2 FOR FIELD LRB2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK EXT.

*----------------------------------------------------------------------*

INITIALIZATION.
  TXT1 = 'Screen'.
  TXT2 = 'OLAP'.
  TXT3 = 'Execution Type'.


* F4-Help for variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM F4_FOR_VARIANT.

************************************************************************
* Main program
************************************************************************

AT SELECTION-SCREEN.

* check radiobuttons                                          "n667256
  IF  PA_HSQ IS INITIAL.                                    "n667256
    IF  PA_FLT IS INITIAL.                                  "n667256
*     not allowed                                             "n667256
      MOVE  'X'              TO  PA_HSQ.                    "n667256
      ADD  1                 TO  G_CNT_VARIANT_ERROR.       "n667256
    ENDIF.                                                  "n667256
  ELSE.                                                     "n667256
    IF  PA_FLT IS INITIAL.                                  "n667256
    ELSE.                                                   "n667256
*     not allowed                                             "n667256
      CLEAR                  PA_FLT.                        "n667256
      ADD  1                 TO  G_CNT_VARIANT_ERROR.       "n667256
    ENDIF.                                                  "n667256
  ENDIF.                                                    "n667256
                                                            "n667256
* the user will get the info about the old variant only once  "n667256
  IF  G_CNT_VARIANT_ERROR = 1.                              "n667256
    IF  NOT SY-SLSET IS INITIAL.                            "n667256
      MESSAGE I634(DB)       WITH  SY-SLSET SY-REPID.       "n667256
    ENDIF.                                                  "n667256
  ENDIF.                                                    "n667256

* has the user changed the radiobuttons for the mode of the "n531604
* SAP-LIST-VIEWER ?                                         "n531604
  IF  SSCRFIELDS-UCOMM  =  'ALVV'.
*   yes, restore the old entry if extists                   "n531604
    IF      NOT PA_HSQ IS INITIAL.
      MOVE  G_F_VARI_HSQ     TO  P_VARI.
    ELSEIF  NOT  PA_FLT IS INITIAL.
*     for flat ( simple ) list
      MOVE  G_F_VARI_FLT     TO  P_VARI.
    ENDIF.

  ELSE.
*   save the display variant depending on the selected mode "n531604
*   of the SAP-LIST-VIEWER
    IF      NOT PA_HSQ IS INITIAL.
*     for hierarchic seq. list
      MOVE P_VARI            TO  G_F_VARI_HSQ.

    ELSEIF  NOT  PA_FLT IS INITIAL.
*     for flat ( simple ) list
      MOVE P_VARI            TO  G_F_VARI_FLT.

    ENDIF.
  ENDIF.

* it is necessary to set flag xmchb if batch has been entered because
* otherwise MCHB will not be read and non suitable items can't be
* be removed later on in form data_selection
  IF NOT CHARG[] IS INITIAL. XMCHB = 'X'. ENDIF.    "note 311770

* send a warning if the user starts this report without any "n531604
* restrictions for the database selection                   "n531604
* only when this report is started                          "n531604
  IF MATNR IS INITIAL AND                                   "n531604
     WERKS IS INITIAL AND                                   "n531604
     LGORT IS INITIAL AND                                   "n531604
     CHARG IS INITIAL.                                      "n531604
    IF  SY-UCOMM  =  'ONLI'  OR                             "n531604
        SY-UCOMM  =  'PRIN'.                                "n531604
*ENHANCEMENT-SECTION EHP604_RM07MLBS_43 SPOTS ES_RM07MLBS .
      MESSAGE  W689.    "The selection was not restricted   "n531604
*END-ENHANCEMENT-SECTION.
    ENDIF.                                                  "n531604
  ENDIF.                                                    "n531604
* go on only if the user wants to launch this report        "n667256
* the authorization check should be always processed        "n829722
  IF SY-UCOMM = 'ONLI' OR                                   "n829722
     SY-UCOMM = 'PRIN' OR                                   "n829722
     SY-UCOMM = 'SJOB' OR                                   "n829722
     SY-UCOMM = SPACE.                                      "n829722
    MOVE 'X' TO T_FLAG_LAUNCHED.                            "n829722
  ELSE.                                                     "n829722
    IF SY-UCOMM <> SPACE.                                   "n829722
      CLEAR T_FLAG_LAUNCHED.                                "n829722
    ENDIF.                                                  "n829722
  ENDIF.                                                    "n829722
  CHECK T_FLAG_LAUNCHED = 'X'.                              "n829722

  PERFORM ORGANISATION.

  PERFORM CHECK_ENTRY.

  PERFORM CHECK_AUTHORIZATION.

* save the parameters of this run in database table ESDUS   "n531604
  PERFORM                    F0200_SETTINGS_SAVE.           "n531604

*------------------------ Initialisierung -----------------------------*
INITIALIZATION.
*ENHANCEMENT-POINT RM07MLBS_05 SPOTS ES_RM07MLBS.
  PERFORM                    F0000_GET_PRINT_SETTINGS.      "n531604

* look for the setting of the parameters from the last run  "n531604
  PERFORM                    F0100_SETTINGS_INIT.           "n531604

  PERFORM INITIALISIERUNG.

* set flag when INITILIZATION is processed                  "n667256
  MOVE  'X'        TO  G_FLAG_INITIALIZATION.               "n667256
                                                            "n667256
*-----------------------------------------------------------"n667256
                                                            "n667256
*ENHANCEMENT-POINT RM07MLBS_07 SPOTS ES_RM07MLBS.

START-OF-SELECTION.

* it makes no sence to carry out this report                "n667256
  IF  G_CNT_VARIANT_ERROR > 0.                              "n667256
    IF  NOT SY-SLSET IS INITIAL.                            "n667256
      MESSAGE E634(DB)       WITH  SY-SLSET SY-REPID.       "n667256
    ENDIF.                                                  "n667256
  ENDIF.                                                    "n667256

* does the user restrict the storage locations and want to  "n577268
* suppress stock objects from plant level ?                 "n577268
  CLEAR                      COLLECTOR-LGORT.               "n577268
                                                            "n577268
  IF  COLLECTOR-LGORT IN LGORT.                             "n577268
    CLEAR                    G_FLAG_SUPPRESS_INIT_LGORT.    "n577268
  ELSE.                                                     "n577268
    MOVE  'X'                TO  G_FLAG_SUPPRESS_INIT_LGORT. "n577268
  ENDIF.                                                    "n577268

  PERFORM DATA_SELECTION.

*-------------------------- Datenausgabe-------------------------------*
END-OF-SELECTION.
  READ TABLE BESTAND INDEX 1 TRANSPORTING NO FIELDS.

  IF SY-SUBRC = 0.
*   the fieldcatalog depends on the type of list            "n531604
    IF      NOT PA_HSQ IS INITIAL.                          "n531604
*     create hierarchic list                                "n531604
      PERFORM                FIELDCATALOG.                  "n531604
    ELSEIF  NOT  PA_FLT IS INITIAL.                         "n531604
      PERFORM                F0300_FIELDCAT_FLAT.           "n531604
    ENDIF.                                                  "n531604

    IF  G_FLAG_MESS_333 = 'X'.
*     "The list is incomplete due to lacking authorization
      MESSAGE                S333.
    ENDIF.

    PERFORM LIST_OUTPUT.
  ELSE.
    MESSAGE S843.
*   Zu den vorgegebenen Daten ist kein Bestand vorhanden
    IF NOT SY-CALLD IS INITIAL.                             "307852
      LEAVE.                                                "307852
    ELSE.                                                   "307852
*      LEAVE TO TRANSACTION sy-tcode.                            "n1590783
*     SELECT-OPTIONS will be lost with leave to transaction..    "n1590783
*     Change logic to submit and provide select-options          "n1590783
      SUBMIT RM07MLBS                                       "n1590783
       WITH MATNR    IN MATNR                               "n1590783
       WITH WERKS    IN WERKS                               "n1590783
       WITH LGORT    IN LGORT                               "n1590783
       WITH CHARG    IN CHARG                               "n1590783
       WITH MATART   IN MATART                              "n1590783
       WITH MATKLA   IN MATKLA                              "n1590783
       WITH EKGRUP   IN EKGRUP                              "n1590783
       WITH PA_SOND  =  PA_SOND                             "n1590783
       WITH SO_SOBKZ IN SO_SOBKZ                            "n1590783
       WITH NEGATIV  =  NEGATIV                             "n1590783
       WITH XMCHB    = XMCHB                                "n1590783
       WITH NOZERO   = NOZERO                               "n1590783
       WITH NOVALUES = NOVALUES                             "n1590783
       WITH PA_HSQ   = PA_HSQ                               "n1590783
       WITH PA_FLT   = PA_FLT                               "n1590783
       WITH P_VARI   = P_VARI                               "n1590783
       VIA SELECTION-SCREEN.                                "n1590783
    ENDIF.                                                  "307852
  ENDIF.

************************************************************************
* Read organisation
************************************************************************
FORM ORGANISATION.

* define working areas                                        "09122009
  DATA : LS_ORGAN            LIKE  LINE OF G_T_ORGAN.       "09122009
  FIELD-SYMBOLS : <LS_T001W> LIKE  LINE OF GT_T001W.        "09122009

* get all existing storage bins of the required plants
  REFRESH : G_T_T001L, G_T_ORGAN.
  REFRESH : GT_T001W.                                       "09122009
  CLEAR   : G_S_T001L, G_S_ORGAN, G_FLAG_T001L.

  SELECT  WERKS LGORT LGOBE  FROM T001L        "#EC CI_GENBUFF 09122009
                   INTO CORRESPONDING FIELDS OF TABLE G_T_T001L
                   WHERE  WERKS IN WERKS
                     AND  LGORT IN LGORT
                     AND  LGOBE NE SPACE.

  IF  SY-SUBRC IS INITIAL.
    MOVE  'X'                TO  G_FLAG_T001L.
  ENDIF.

* read setting of the plants                                  "09122009
  SELECT WERKS NAME1 BWKEY    FROM T001W       "#EC CI_GENBUFF 09122009
    INTO CORRESPONDING FIELDS OF TABLE GT_T001W             "09122009
      WHERE WERKS IN WERKS.
                                                            "09122009
  LOOP AT GT_T001W           ASSIGNING  <LS_T001W>.         "09122009
    MOVE-CORRESPONDING  <LS_T001W>                          "09122009
                             TO  LS_ORGAN.          "#EC ENHOK 09122009
    APPEND  LS_ORGAN         TO  G_T_ORGAN.                 "09122009
  ENDLOOP.                                                  "09122009

  SORT G_T_ORGAN             BY BWKEY.

  LOOP AT G_T_ORGAN          INTO  G_S_ORGAN.
    ON CHANGE OF G_S_ORGAN-BWKEY.
      CLEAR                  G_FLAG_OK.

      SELECT SINGLE * FROM T001K
                   WHERE BWKEY EQ G_S_ORGAN-BWKEY.

      IF SY-SUBRC IS INITIAL.
        SELECT SINGLE * FROM T001
                   WHERE BUKRS EQ T001K-BUKRS.

        IF SY-SUBRC IS INITIAL.
          MOVE  'X'          TO  G_FLAG_OK.
        ENDIF.
      ENDIF.
    ENDON.

    IF  G_FLAG_OK = 'X'.
      MOVE-CORRESPONDING T001  TO  G_S_ORGAN.       "#EC ENHOK 09122009

      MODIFY  G_T_ORGAN        FROM  G_S_ORGAN.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " ORGANISATION

************************************************************************
* Check authorization on plant level for all selected plants
************************************************************************
FORM CHECK_AUTHORIZATION.

* define local working areas
  DATA : L_S_BUKRS           TYPE  STYPE_BUFFER,
         L_T_BUKRS           TYPE  STAB_BUFFER.

  SORT   G_T_ORGAN           BY WERKS.

* report displayed stocks for plant although the user has   "n591618
* not the required authorization for that plant             "n591618
  CLEAR                      G_S_BUFFER.                    "n591618

  LOOP AT G_T_ORGAN          INTO  G_S_ORGAN.
*   check the authority only after the plant has changed    "n531604
    IF  G_S_ORGAN-WERKS NE G_S_BUFFER-WERKS.
      MOVE  G_S_ORGAN-WERKS  TO  G_S_BUFFER-WERKS.

      AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
                     ID 'ACTVT' FIELD '03'
                     ID 'WERKS' FIELD G_S_ORGAN-WERKS.

      IF NOT SY-SUBRC IS INITIAL.
        SET  CURSOR          FIELD  'WERKS-LOW'.
        MESSAGE E120         WITH  G_S_ORGAN-WERKS.
      ENDIF.
    ENDIF.

    IF  NOVALUES IS INITIAL.                                "n531604
*     the user wants to see the values
      IF  G_S_ORGAN-BUKRS NE G_S_BUFFER-BUKRS.
*       check the authority after the company code changed

        AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*           parameters for AUTHORITY-CHECK command fixed    "n546707
            ID 'BUKRS' FIELD G_S_ORGAN-BUKRS                "n546707
            ID 'ACTVT' FIELD '03'.                          "n546707

        MOVE : G_S_ORGAN-BUKRS    TO  G_S_BUFFER-BUKRS,     "n667256
               SY-SUBRC           TO  G_S_BUFFER-SUBRC.     "n667256

        IF SY-SUBRC <> 0.
*         no authorization -> save the company code
          MOVE : 'X'              TO  G_FLAG_MESS_333,
                 G_S_ORGAN-BUKRS  TO  L_S_BUKRS-BUKRS.
          COLLECT L_S_BUKRS       INTO  L_T_BUKRS.
        ENDIF.
      ENDIF.

*     use the result from the buffer
      IF  G_S_BUFFER-SUBRC <> 0.
        CLEAR                G_S_ORGAN-WAERS.
        MODIFY  G_T_ORGAN    FROM  G_S_ORGAN
                             TRANSPORTING  WAERS.
      ENDIF.
    ENDIF.
  ENDLOOP.

* send the info for each missing autority
  IF  G_FLAG_MESS_333  =  'X'.
    SORT                     L_T_BUKRS.
    SET CURSOR               FIELD  'WERKS-LOW'.

    LOOP AT L_T_BUKRS        INTO  L_S_BUKRS.
*     No authorization to display data for company code &
      MESSAGE  I862(M3)      WITH  L_S_BUKRS-BUKRS.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "check_authorization

************************************************************************
* Check data on selection screen
************************************************************************
FORM CHECK_ENTRY.

* define working table                                        "09122009
  DATA : LT_T134M            TYPE  STANDARD TABLE OF T134M, "09122009
         LT_T023             TYPE  STANDARD TABLE OF T023.  "09122009

* Check some entered data for consistency
  CALL FUNCTION 'MMIM_ENTRYCHECK_MAIN'
    TABLES
      IT_MATNR = MATNR
      IT_WERKS = WERKS
      IT_LGORT = LGORT
      IT_EKGRP = EKGRUP
      IT_SOBKZ = SO_SOBKZ.

* Material type
  IF NOT MATART[] IS INITIAL.                               "09122009
    SELECT * FROM T134M      INTO TABLE LT_T134M            "09122009
      UP TO 1 ROWS                                          "09122009
        FOR ALL ENTRIES IN GT_T001W                         "09122009
          WHERE BWKEY =  GT_T001W-BWKEY                     "09122009
            AND MTART IN MATART.                            "09122009

    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E104(M3) WITH MATART-LOW.
    ENDIF.
  ENDIF.

* Material class
  IF NOT MATKLA[] IS INITIAL.                               "09122009
    SELECT *  FROM T023      INTO TABLE  LT_T023            "09122009
      UP TO 1 ROWS                                          "09122009
        WHERE MATKL IN MATKLA.                              "09122009

    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E883 WITH MATKLA-LOW.
    ENDIF.
  ENDIF.

* Display variant
  IF NOT P_VARI IS INITIAL.
    SET CURSOR               FIELD  'P_VARI'.

    IF      NOT PA_HSQ IS INITIAL.
*     for hierarchic seq. list
      MOVE : P_VARI          TO  VARIANTE-VARIANT,
             VARIANTE        TO  DEF_VARIANTE.

    ELSEIF  NOT  PA_FLT IS INITIAL.
*     for flat ( simple ) list
      MOVE : P_VARI          TO  VARIANTE_FLAT-VARIANT,
             VARIANTE_FLAT   TO  DEF_VARIANTE.
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        I_SAVE     = 'A'
      CHANGING
        CS_VARIANT = DEF_VARIANTE.
  ELSE.                                                     "n579976
*   the user wants no initial display variant               "n579976
                                                            "n579976
    IF      NOT PA_HSQ IS INITIAL.                          "n579976
*     for hierarchic seq. list                              "n579976
      IF  NOT G_F_VARI_HSQ_INITIAL IS INITIAL.              "n579976
*       but the SAP-LIST-VIEWER will apply the existing     "n579976
*       initial display variant for hierarchic lists        "n579976
        PERFORM  F3000_SEND_WARNING_M7_393                  "n579976
                             USING  G_F_VARI_HSQ_INITIAL.   "n579976
      ENDIF.                                                "n579976
                                                            "n579976
    ELSEIF  NOT  PA_FLT IS INITIAL.                         "n579976
*     for flat ( simple ) list                              "n579976
      IF  NOT G_F_VARI_FLT_INITIAL IS INITIAL.              "n579976
*       but the SAP-LIST-VIEWER will apply the existing     "n579976
*       initial display variant for flat lists              "n579976
        PERFORM  F3000_SEND_WARNING_M7_393                  "n579976
                             USING  G_F_VARI_FLT_INITIAL.   "n579976
      ENDIF.                                                "n579976
    ENDIF.                                                  "n579976
  ENDIF.

ENDFORM.                               "check_entry

************************************************************************
* Initialization: Read default variant
************************************************************************
FORM INITIALISIERUNG.

* prepare the areas for the different display variants
  REPID = SY-REPID.
  CLEAR : VARIANTE,          VARIANTE_FLAT.
  MOVE  : REPID              TO  VARIANTE-REPORT,
          REPID              TO  VARIANTE_FLAT-REPORT,
          'FLAT'             TO  VARIANTE_FLAT-HANDLE.

* the display variant is depending on the seleted mode of   "n531604
* the SAP-LIST-VIEWER : look for both variants              "n531604

* a) Get default variant for the hierarchic list
  DEF_VARIANTE = VARIANTE.

  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      I_SAVE     = 'A'
    CHANGING
      CS_VARIANT = DEF_VARIANTE
    EXCEPTIONS
      NOT_FOUND  = 2.

  IF SY-SUBRC = 0.
    MOVE  DEF_VARIANTE-VARIANT    TO  G_F_VARI_HSQ.
*   save the initial display variant for the hierseq. list  "n579976
    MOVE  DEF_VARIANTE-VARIANT    TO  G_F_VARI_HSQ_INITIAL. "n579976
  ENDIF.

* b) Get default variant for the non-hierarchic list
  DEF_VARIANTE = VARIANTE_FLAT.

  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      I_SAVE     = 'A'
    CHANGING
      CS_VARIANT = DEF_VARIANTE
    EXCEPTIONS
      NOT_FOUND  = 2.

  IF SY-SUBRC = 0.
    MOVE  DEF_VARIANTE-VARIANT    TO  G_F_VARI_FLT.
*   save the initial display variant for the flat list      "n579976
    MOVE  DEF_VARIANTE-VARIANT    TO  G_F_VARI_FLT_INITIAL. "n579976
  ENDIF.

* take the required variant
  IF      NOT PA_HSQ IS INITIAL.
*   for hierarchic seq. list
    P_VARI =  G_F_VARI_HSQ.

  ELSEIF  NOT  PA_FLT IS INITIAL.
*   for flat ( simple ) list
    P_VARI = G_F_VARI_FLT.
  ENDIF.
*ENHANCEMENT-POINT EHP604_RM07MLBS_05 SPOTS ES_RM07MLBS .

ENDFORM.                               " INITIALISIERUNG

************************************************************************
* Main data selection routine
************************************************************************
FORM DATA_SELECTION.

* Materials to be processed
  TYPES: BEGIN OF TY_MAT,
           MATNR LIKE MARA-MATNR,
           WERKS LIKE MARC-WERKS,
           XCHAR LIKE MARC-XCHAR,
           MTART LIKE MARA-MTART,
           MATKL LIKE MARA-MATKL,
           MEINS LIKE MARA-MEINS,
           TRAME LIKE MARC-TRAME,
           UMLMC LIKE MARC-UMLMC,
           GLGMG LIKE MARC-GLGMG,                           "n912093
           BWESB             LIKE  MARC-BWESB,              "AC0K020254
           LVORM_MARA        LIKE  MARA-LVORM,
           LVORM_MARC        LIKE  MARC-LVORM.
*ENHANCEMENT-POINT EHP604_RM07MLBS_06 SPOTS ES_RM07MLBS STATIC .
  TYPES:  END OF TY_MAT.

  DATA: T_MAT     TYPE TY_MAT OCCURS 0 WITH HEADER LINE,
        T_BATCH   TYPE TY_MAT OCCURS 0 WITH HEADER LINE,
        T_NOBATCH TYPE TY_MAT OCCURS 0 WITH HEADER LINE.
*ENHANCEMENT-POINT EHP604_RM07MLBS_07 SPOTS ES_RM07MLBS STATIC .

* buffer for reading working tables
  DATA : L_S_MAT             TYPE  TY_MAT,
         L_F_MATNR           LIKE  MAKT-MATNR.

  RANGES: R_SOBKZ FOR MKOL-SOBKZ.

  DATA: L_CNT_MATNR_I_EQ     TYPE I.                        "n759412
  DATA: L_CNT_MATNR_TOTAL    TYPE I.                        "n759412

************************************************************************
* Read material master data (MARA and MARC)
************************************************************************
  REFRESH COLLECTOR.

* take all matching entries, do not consider the deletion
* indicator

*** BEGIN INSERT n_759412
* analyse the select-option table for material
* numbers
  CLEAR : L_CNT_MATNR_TOTAL, L_CNT_MATNR_I_EQ.

  LOOP AT MATNR.
    ADD  1             TO  L_CNT_MATNR_TOTAL.

    IF  NOT MATNR-LOW     IS INITIAL  AND
            MATNR-SIGN    =  'I'      AND
            MATNR-OPTION  =  'EQ'     AND
            MATNR-HIGH    IS INITIAL.
*     the table contains single a material number
      ADD  1           TO  L_CNT_MATNR_I_EQ.
    ELSE.
      EXIT.
    ENDIF.
  ENDLOOP.
* added dynamic break-point ID MMIM_REP_MB52              "n912093
  BREAK-POINT ID MMIM_REP_MB52.                             "n912093
* process SELECT command depending on the
* required material selection
  IF  L_CNT_MATNR_TOTAL  > 0                 AND
      L_CNT_MATNR_TOTAL  = L_CNT_MATNR_I_EQ.
*ENHANCEMENT-SECTION EHP604_RM07MLBS_08 SPOTS ES_RM07MLBS .
    SELECT MARA~MATNR WERKS XCHAR MTART MATKL MEINS TRAME UMLMC
           BWESB GLGMG                       "AC0K020254  "n912093
         MARA~LVORM AS LVORM_MARA
         MARC~LVORM AS LVORM_MARC
         INTO CORRESPONDING FIELDS OF TABLE T_MAT
         FROM MARA INNER JOIN MARC
         ON MARA~MATNR = MARC~MATNR
         FOR ALL ENTRIES IN MATNR
         WHERE MARA~MATNR = MATNR-LOW
           AND WERKS IN WERKS
           AND MTART IN MATART
           AND MATKL IN MATKLA
           AND EKGRP IN EKGRUP.
*END-ENHANCEMENT-SECTION.
  ELSE.
* END INSERT n_759412
*ENHANCEMENT-SECTION EHP604_RM07MLBS_09 SPOTS ES_RM07MLBS .
    SELECT MARA~MATNR WERKS XCHAR MTART MATKL MEINS TRAME UMLMC
           BWESB GLGMG                          "AC0K020254 "912093
         MARA~LVORM AS LVORM_MARA
         MARC~LVORM AS LVORM_MARC
         INTO CORRESPONDING FIELDS OF TABLE T_MAT
         FROM MARA INNER JOIN MARC
         ON MARA~MATNR = MARC~MATNR
         WHERE MARA~MATNR IN MATNR
           AND WERKS IN WERKS
           AND MTART IN MATART
           AND MATKL IN MATKLA
           AND EKGRP IN EKGRUP.
*END-ENHANCEMENT-SECTION.
  ENDIF.                                                    "n759412
*ENHANCEMENT-POINT EHP604_RM07MLBS_10 SPOTS ES_RM07MLBS .
************************************************************************
* Get "normal" stocks.
* If no detailed batch display is required,
* all data come from MARD. Otherwise, materials with batch
* management are extracted from MCHB, the rest from MARD.
************************************************************************
  REFRESH: T_BATCH, T_NOBATCH.
* Split the worklist into the parts for each table...
  IF XMCHB IS INITIAL.
    T_NOBATCH[] = T_MAT[].
  ELSE.
    LOOP AT T_MAT.
      IF T_MAT-XCHAR IS INITIAL.
        APPEND T_MAT TO T_NOBATCH.
      ELSE.
        APPEND T_MAT TO T_BATCH.
      ENDIF.
    ENDLOOP.
  ENDIF.
*ENHANCEMENT-POINT EHP604_RM07MLBS_11 SPOTS ES_RM07MLBS .
* Access MARD
* I you think that instead of SELECT-APPEND we could have used
* an array fetch, please wait for the table names to become different
* from the internal fields. B.T.W.: The DB-interface also buffers.
  CLEAR COLLECTOR.
  READ TABLE T_NOBATCH INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
*ENHANCEMENT-SECTION EHP604_RM07MLBS_12 SPOTS ES_RM07MLBS .
    SELECT MATNR WERKS LGORT
           LABST UMLME INSME EINME SPEME RETME LVORM
           INTO (COLLECTOR-MATNR, COLLECTOR-WERKS, COLLECTOR-LGORT,
                 COLLECTOR-LABST, COLLECTOR-UMLME, COLLECTOR-INSME,
                 COLLECTOR-EINME, COLLECTOR-SPEME, COLLECTOR-RETME,
                 COLLECTOR-LVORM)
           FROM MARD
           FOR ALL ENTRIES IN T_NOBATCH
           WHERE MATNR = T_NOBATCH-MATNR
             AND WERKS = T_NOBATCH-WERKS
             AND LGORT IN LGORT.

*     save the MARD Key and deletion indicator for later
*     in table G_T_MARD_LV for use with special stocks
      IF NOT PA_SOND         IS INITIAL  AND
         NOT COLLECTOR-LVORM IS INITIAL.
        MOVE-CORRESPONDING  COLLECTOR
                             TO  G_S_MARD_LV.
        INSERT  G_S_MARD_LV  INTO  TABLE  G_T_MARD_LV.
      ENDIF.

      PERFORM                F2000_COLLECT_COLLECTOR.
    ENDSELECT.
*END-ENHANCEMENT-SECTION.
  ENDIF.

* Access MCHB
  CLEAR COLLECTOR.
  READ TABLE T_BATCH INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
*ENHANCEMENT-SECTION EHP604_RM07MLBS_13 SPOTS ES_RM07MLBS .
    SELECT MATNR WERKS LGORT CHARG
           CLABS CUMLM CINSM CEINM CSPEM CRETM LVORM
           INTO (COLLECTOR-MATNR, COLLECTOR-WERKS, COLLECTOR-LGORT,
                 COLLECTOR-CHARG,
                 COLLECTOR-LABST, COLLECTOR-UMLME, COLLECTOR-INSME,
                 COLLECTOR-EINME, COLLECTOR-SPEME, COLLECTOR-RETME,
                 COLLECTOR-LVORM)
           FROM MCHB
           FOR ALL ENTRIES IN T_BATCH
           WHERE MATNR = T_BATCH-MATNR
             AND WERKS = T_BATCH-WERKS
             AND LGORT IN LGORT
             AND CHARG IN CHARG.

      PERFORM                F2000_COLLECT_COLLECTOR.
    ENDSELECT.
*END-ENHANCEMENT-SECTION.
  ENDIF.

************************************************************************
* Transfer stocks from MARC (TRAME, UMLMC)
************************************************************************
  CLEAR COLLECTOR.

*ENHANCEMENT-SECTION EHP604_RM07MLBS_14 SPOTS ES_RM07MLBS .
  LOOP AT T_MAT WHERE UMLMC <> 0 OR TRAME <> 0 OR           "AC0K020254
                      BWESB <> 0 OR                         "AC0K020254
                      GLGMG <> 0.                           "912093

*     there are no lines with stock = zero

*     take the stocks from plant level only when the user   "n577268
*     does not restrict the storage location;               "n577268
    CHECK : G_FLAG_SUPPRESS_INIT_LGORT IS INITIAL.          "n577268

    IF NEGATIV = 'X'.
*       ignore entry if all stocks are zero or greater
      IF  T_MAT-TRAME >= 0 AND
          T_MAT-UMLMC >= 0 AND
          T_MAT-GLGMG >= 0.                                 "n912093
        CONTINUE.          "take the next entry
      ENDIF.
    ENDIF.

    COLLECTOR-MATNR = T_MAT-MATNR.
    COLLECTOR-WERKS = T_MAT-WERKS.
    COLLECTOR-UMLME = T_MAT-TRAME + T_MAT-UMLMC.
    COLLECTOR-LVORM = T_MAT-LVORM_MARC.
    COLLECTOR-BWESB = T_MAT-BWESB.                          "AC0K020254
    COLLECTOR-GLGMG = T_MAT-GLGMG.                          "n912093
    COLLECTOR-TRAME = T_MAT-TRAME.                          "n912093
    COLLECTOR-UMLMC = T_MAT-UMLMC.                          "n912093

    APPEND COLLECTOR.

  ENDLOOP.
*END-ENHANCEMENT-SECTION.

************************************************************************
* Consignment from vendor (MKOL)
* Read only if requested by one of the
* flags on the selection screen. Absolutely inconsistent, but
* due to compatibility...
* MKOL has a flag for deletion
************************************************************************

  IF  NOT PA_SOND IS INITIAL  AND
      NOT T_MAT[] IS INITIAL.
    IF  'K' IN SO_SOBKZ  OR
        'M' IN SO_SOBKZ.
      CLEAR                  COLLECTOR.

*ENHANCEMENT-SECTION EHP604_RM07MLBS_15 SPOTS ES_RM07MLBS .
      SELECT MATNR WERKS LGORT CHARG SOBKZ LIFNR
             SLABS SINSM SEINM SSPEM LVORM
             INTO (COLLECTOR-MATNR, COLLECTOR-WERKS, COLLECTOR-LGORT,
                   COLLECTOR-CHARG, COLLECTOR-SOBKZ, COLLECTOR-LIFNR,
                   COLLECTOR-LABST, COLLECTOR-INSME, COLLECTOR-EINME,
                   COLLECTOR-SPEME, COLLECTOR-LVORM)
             FROM MKOL
             FOR ALL ENTRIES IN T_MAT
             WHERE MATNR = T_MAT-MATNR
               AND WERKS = T_MAT-WERKS
               AND LGORT IN LGORT
               AND CHARG IN CHARG
               AND SOBKZ IN SO_SOBKZ.

        PERFORM              F2000_COLLECT_COLLECTOR.
      ENDSELECT.
*END-ENHANCEMENT-SECTION.
    ENDIF.
  ENDIF.

************************************************************************
* Special stocks at customer side (MSKU)
* MSKU has no flag for deletion
************************************************************************

  IF  NOT  PA_SOND IS INITIAL  AND
      NOT  T_MAT[] IS INITIAL.
    IF  'V' IN SO_SOBKZ  OR
        'W' IN SO_SOBKZ.
      CLEAR COLLECTOR.

*ENHANCEMENT-SECTION EHP604_RM07MLBS_16 SPOTS ES_RM07MLBS .
      SELECT MATNR WERKS CHARG SOBKZ KUNNR
           KULAB KUINS KUEIN KUUML                          " OM EHP604
           INTO (COLLECTOR-MATNR, COLLECTOR-WERKS, COLLECTOR-CHARG,
                 COLLECTOR-SOBKZ, COLLECTOR-KUNNR,
                 COLLECTOR-LABST, COLLECTOR-INSME, COLLECTOR-EINME,
                 COLLECTOR-UMLME)                           " OM EHP604
           FROM MSKU
           FOR ALL ENTRIES IN T_MAT
           WHERE MATNR = T_MAT-MATNR
             AND WERKS = T_MAT-WERKS
             AND CHARG IN CHARG
             AND SOBKZ  IN  SO_SOBKZ.

        PERFORM              F2000_COLLECT_COLLECTOR.
      ENDSELECT.
*END-ENHANCEMENT-SECTION.
    ENDIF.
  ENDIF.

************************************************************************
* Special stocks at vendor provision (MSLB)
* MSLB has no flag for deletion
************************************************************************

  IF  NOT  PA_SOND IS INITIAL  AND
      NOT  T_MAT[] IS INITIAL  AND
           'O'     IN SO_SOBKZ.
    CLEAR COLLECTOR.

*ENHANCEMENT-SECTION EHP604_RM07MLBS_17 SPOTS ES_RM07MLBS .
    SELECT MATNR WERKS CHARG SOBKZ LIFNR
           LBLAB LBINS LBEIN LBUML                          " OM EHP604
           INTO (COLLECTOR-MATNR, COLLECTOR-WERKS, COLLECTOR-CHARG,
                 COLLECTOR-SOBKZ, COLLECTOR-LIFNR,
                 COLLECTOR-LABST, COLLECTOR-INSME,
                 COLLECTOR-EINME, COLLECTOR-UMLME)          " OM EHP604
           FROM MSLB
           FOR ALL ENTRIES IN T_MAT
           WHERE MATNR = T_MAT-MATNR
             AND WERKS = T_MAT-WERKS
             AND CHARG IN CHARG
             AND SOBKZ  IN  SO_SOBKZ.

      PERFORM                F2000_COLLECT_COLLECTOR.
    ENDSELECT.
*END-ENHANCEMENT-SECTION.
  ENDIF.

************************************************************************
* Customer order stock (MSKA) and sum segment (MSSA) for valuation.
* Sum on the database and FOR ALL ENTRIES is not allowed from
* release 4.5 onwards, so the summation has to be done
* on the application server (here!).
* MSKA has no flag for deletion
************************************************************************

  IF  NOT  PA_SOND IS INITIAL  AND
      NOT  T_MAT[] IS INITIAL  AND
           'E'     IN SO_SOBKZ.
    CLEAR COLLECTOR.

*ENHANCEMENT-SECTION EHP604_RM07MLBS_18 SPOTS ES_RM07MLBS .
    SELECT MSKA~MATNR MSKA~WERKS LGORT CHARG MSKA~SOBKZ
           MSKA~VBELN MSKA~POSNR
           KALAB KAINS KASPE KAEIN KZBWS
           INTO (COLLECTOR-MATNR, COLLECTOR-WERKS, COLLECTOR-LGORT,
                 COLLECTOR-CHARG, COLLECTOR-SOBKZ,
                 COLLECTOR-VBELN, COLLECTOR-POSNR,
                 COLLECTOR-LABST, COLLECTOR-INSME, COLLECTOR-SPEME,
                 COLLECTOR-EINME, COLLECTOR-KZBWS)
           FROM MSKA INNER JOIN MSSA
           ON   MSKA~MATNR = MSSA~MATNR
            AND MSKA~WERKS = MSSA~WERKS
            AND MSKA~SOBKZ = MSSA~SOBKZ
            AND MSKA~VBELN = MSSA~VBELN
            AND MSKA~POSNR = MSSA~POSNR
           FOR ALL ENTRIES IN T_MAT
           WHERE MSKA~MATNR = T_MAT-MATNR
             AND MSKA~WERKS = T_MAT-WERKS
             AND MSKA~SOBKZ = 'E'
             AND MSKA~LGORT IN LGORT
             AND MSKA~CHARG IN CHARG.

      PERFORM                F2000_COLLECT_COLLECTOR.
    ENDSELECT.
*END-ENHANCEMENT-SECTION.

*   Transfer stocks for customer order (SATRA in MSSA)
    CLEAR COLLECTOR.
*ENHANCEMENT-SECTION EHP604_RM07MLBS_19 SPOTS ES_RM07MLBS .
    SELECT MATNR WERKS SOBKZ VBELN POSNR KZBWS SATRA
           INTO (COLLECTOR-MATNR, COLLECTOR-WERKS, COLLECTOR-SOBKZ,
                 COLLECTOR-VBELN, COLLECTOR-POSNR,
                 COLLECTOR-KZBWS, COLLECTOR-UMLME)
           FROM MSSA
           FOR ALL ENTRIES IN T_MAT
           WHERE MATNR = T_MAT-MATNR
             AND WERKS = T_MAT-WERKS
             AND SOBKZ  IN  SO_SOBKZ
             AND SATRA <> 0.

      PERFORM                F2000_COLLECT_COLLECTOR.
    ENDSELECT.
*END-ENHANCEMENT-SECTION.
  ENDIF.

************************************************************************
* The same game for project stocks (MSPR/MSSQ).
* MSPR has no flag for deletion
************************************************************************

  IF  NOT  PA_SOND IS INITIAL  AND
      NOT  T_MAT[] IS INITIAL  AND
           'Q'     IN SO_SOBKZ.
    CLEAR COLLECTOR.

*ENHANCEMENT-SECTION EHP604_RM07MLBS_20 SPOTS ES_RM07MLBS .
    SELECT MSPR~MATNR MSPR~WERKS LGORT CHARG MSPR~SOBKZ MSPR~PSPNR
           PRLAB PRINS PRSPE PREIN KZBWS
           INTO (COLLECTOR-MATNR, COLLECTOR-WERKS, COLLECTOR-LGORT,
                 COLLECTOR-CHARG, COLLECTOR-SOBKZ,
                 COLLECTOR-PSPNR,
                 COLLECTOR-LABST, COLLECTOR-INSME, COLLECTOR-SPEME,
                 COLLECTOR-EINME, COLLECTOR-KZBWS)
           FROM MSPR INNER JOIN MSSQ
           ON   MSPR~MATNR = MSSQ~MATNR
            AND MSPR~WERKS = MSSQ~WERKS
            AND MSPR~SOBKZ = MSSQ~SOBKZ
            AND MSPR~PSPNR = MSSQ~PSPNR
           FOR ALL ENTRIES IN T_MAT
           WHERE MSPR~MATNR = T_MAT-MATNR
             AND MSPR~WERKS = T_MAT-WERKS
             AND MSPR~LGORT IN LGORT
             AND MSPR~CHARG IN CHARG.

      PERFORM                F2000_COLLECT_COLLECTOR.
    ENDSELECT.
*END-ENHANCEMENT-SECTION.

*   Transfer stocks for projects (SQTRA in MSSQ)
    CLEAR COLLECTOR.
*ENHANCEMENT-SECTION EHP604_RM07MLBS_21 SPOTS ES_RM07MLBS .
    SELECT MATNR WERKS SOBKZ PSPNR KZBWS SQTRA
           INTO (COLLECTOR-MATNR, COLLECTOR-WERKS, COLLECTOR-SOBKZ,
                 COLLECTOR-PSPNR,
                 COLLECTOR-KZBWS, COLLECTOR-UMLME)
           FROM MSSQ
           FOR ALL ENTRIES IN T_MAT
           WHERE MATNR = T_MAT-MATNR
             AND WERKS = T_MAT-WERKS
             AND SOBKZ  IN  SO_SOBKZ
             AND SQTRA <> 0.

      PERFORM                F2000_COLLECT_COLLECTOR.
    ENDSELECT.
*END-ENHANCEMENT-SECTION.
  ENDIF.
*ENHANCEMENT-POINT RM07MLBS_02 SPOTS ES_RM07MLBS.

************************************************************************
* Extract key-data for other tables.
************************************************************************
  DATA: BEGIN OF T_MAKTKEY OCCURS 0,
          MATNR LIKE MAKT-MATNR,
        END OF T_MAKTKEY,

* working area for the material description
        BEGIN OF L_S_MAKT,
          MATNR LIKE MAKT-MATNR,
          MAKTX LIKE MAKT-MAKTX,
        END OF L_S_MAKT,

        BEGIN OF T_MAKT OCCURS 0,
          MATNR LIKE MAKT-MATNR,
          MAKTX LIKE MAKT-MAKTX,
        END OF T_MAKT,

        BEGIN OF T_MCHAKEY OCCURS 0,
          MATNR LIKE MCHA-MATNR,
          WERKS LIKE MCHA-WERKS,
          CHARG LIKE MCHA-CHARG,
        END OF T_MCHAKEY,
        BEGIN OF T_MCHA OCCURS 0,
          MATNR LIKE MCHA-MATNR,
          WERKS LIKE MCHA-WERKS,
          CHARG LIKE MCHA-CHARG,
          BWTAR LIKE MCHA-BWTAR,
        END OF T_MCHA.

  REFRESH: T_MAKTKEY, T_MCHAKEY, BESTAND.
* remove all items in bestand with wrong batch number. If we would
* not remove this, report will e.g. show materials which has
* only MARD entries, too.
  LOOP AT COLLECTOR WHERE CHARG IN CHARG.               "note 311770
    MOVE-CORRESPONDING COLLECTOR TO BESTAND.

*   fill the key of the special stocks into the field
*   assigment
*ENHANCEMENT-SECTION     RM07MLBS_03 SPOTS ES_RM07MLBS.
    CASE    COLLECTOR-SOBKZ.
      WHEN  'E'.
        MOVE  : 'X'               TO  G_FLAG_SOBKZ-VBELN.
        WRITE : COLLECTOR-VBELN   TO  BESTAND-SSNUM.
        MOVE  : '/'               TO  BESTAND-SSNUM+10(01).
        WRITE : COLLECTOR-POSNR   TO  BESTAND-SSNUM+12(08)
                                  NO-ZERO.
        CONDENSE                  BESTAND-SSNUM.

      WHEN  'T'.
        MOVE  : 'X'               TO  G_FLAG_SOBKZ-VBELN.
        WRITE : COLLECTOR-VBELN   TO  BESTAND-SSNUM.
        MOVE  : '/'               TO  BESTAND-SSNUM+10(01).
        WRITE : COLLECTOR-POSNR   TO  BESTAND-SSNUM+12(08)
                                  NO-ZERO.
        CONDENSE                  BESTAND-SSNUM.

      WHEN  'K'.
        MOVE  : 'X'               TO  G_FLAG_SOBKZ-LIFNR.
        WRITE : COLLECTOR-LIFNR   TO  BESTAND-SSNUM.

      WHEN  'M'.
        MOVE  : 'X'               TO  G_FLAG_SOBKZ-LIFNR.
        WRITE : COLLECTOR-LIFNR   TO  BESTAND-SSNUM.

      WHEN  'O'.
        MOVE  : 'X'               TO  G_FLAG_SOBKZ-LIFNR.
        WRITE : COLLECTOR-LIFNR   TO  BESTAND-SSNUM.

      WHEN  'Q'.
        MOVE  : 'X'               TO  G_FLAG_SOBKZ-PSPNR.
        WRITE : COLLECTOR-PSPNR   TO  BESTAND-SSNUM.

      WHEN  'V'.
        MOVE  : 'X'               TO  G_FLAG_SOBKZ-KUNNR.
        WRITE : COLLECTOR-KUNNR   TO  BESTAND-SSNUM.

      WHEN  'W'.
        MOVE  : 'X'               TO  G_FLAG_SOBKZ-KUNNR.
        WRITE : COLLECTOR-KUNNR   TO  BESTAND-SSNUM.

      WHEN  OTHERS.
        CLEAR                     BESTAND-SSNUM.
    ENDCASE.
*END-ENHANCEMENT-SECTION.

*ENHANCEMENT-POINT RM07MLBS_12 SPOTS ES_RM07MLBS .
    APPEND BESTAND.

    T_MAKTKEY-MATNR = BESTAND-MATNR.
    COLLECT T_MAKTKEY.

    IF BESTAND-CHARG <> SPACE.
      T_MCHAKEY-MATNR = BESTAND-MATNR.
      T_MCHAKEY-WERKS = BESTAND-WERKS.
      T_MCHAKEY-CHARG = BESTAND-CHARG.
      COLLECT T_MCHAKEY.
    ENDIF.
  ENDLOOP.

  FREE                       COLLECTOR.

************************************************************************
* Read additional tables
************************************************************************
  READ TABLE T_MAKTKEY INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    SELECT MATNR MAKTX INTO CORRESPONDING FIELDS OF TABLE T_MAKT
           FROM MAKT
           FOR ALL ENTRIES IN T_MAKTKEY
           WHERE MATNR = T_MAKTKEY-MATNR
             AND SPRAS = SY-LANGU.
    SORT T_MAKT BY MATNR.
  ENDIF.

* Read batch data only if values are requested
  READ TABLE T_MCHAKEY INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0 AND NOVALUES IS INITIAL.
    SELECT MATNR WERKS CHARG BWTAR
           INTO CORRESPONDING FIELDS OF TABLE T_MCHA
           FROM MCHA
           FOR ALL ENTRIES IN T_MCHAKEY
           WHERE MATNR = T_MCHAKEY-MATNR
             AND WERKS = T_MCHAKEY-WERKS
             AND CHARG = T_MCHAKEY-CHARG.
    SORT T_MCHA BY MATNR WERKS CHARG.
  ENDIF.

************************************************************************
* Data definitions for the valuation extraction
************************************************************************
  DATA: BEGIN OF T_MBEWKEY OCCURS 0,
          MATNR LIKE MBEW-MATNR,
          BWKEY LIKE MBEW-BWKEY,
          BWTAR LIKE MBEW-BWTAR,
        END OF T_MBEWKEY,

*       workin table for the material stock valuation
        BEGIN OF T_MBEW OCCURS 0,
          MATNR LIKE MBEW-MATNR,
          BWKEY LIKE MBEW-BWKEY,
          BWTAR LIKE MBEW-BWTAR,
*         consider the valuation of the special stocks E, Q "n531604
          SOBKZ              LIKE  EBEW-SOBKZ,              "n531604
          VBELN              LIKE  EBEW-VBELN,              "n531604
          POSNR              LIKE  EBEW-POSNR,              "n531604
          PSPNR              LIKE  QBEW-PSPNR,              "n531604

          LBKUM(12)  TYPE P DECIMALS 3,                     "407810
          SALK3(12)  TYPE P DECIMALS 2,                     "388735
          VPRSV LIKE MBEW-VPRSV,                            "353428
          VERPR LIKE MBEW-VERPR,                            "353428
          STPRS LIKE MBEW-STPRS,                            "353428
          PEINH LIKE MBEW-PEINH,                            "353428
        END OF T_MBEW.

  DATA: T_EBEWKEY LIKE T_MBEWKEY OCCURS 0 WITH HEADER LINE.
  DATA: T_QBEWKEY LIKE T_MBEWKEY OCCURS 0 WITH HEADER LINE.
  DATA: T_EBEW    LIKE T_MBEW    OCCURS 0 WITH HEADER LINE.
  DATA: T_QBEW    LIKE T_MBEW    OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF T_T134MKEY OCCURS 0,
          BWKEY LIKE T134M-BWKEY,
          MTART LIKE T134M-MTART,
        END OF T_T134MKEY,
        BEGIN OF T_T134M OCCURS 0,
          BWKEY LIKE T134M-BWKEY,
          MTART LIKE T134M-MTART,
          WERTU LIKE T134M-WERTU,
        END OF T_T134M.

************************************************************************
* Fill in additional data (first round) and extract the data
* for the access to the valuation tables.
************************************************************************
  SORT T_MAT BY MATNR WERKS.
  SORT G_T_ORGAN             BY WERKS.
  CLEAR : G_S_T001L,         G_S_ORGAN.


  LOOP AT BESTAND.
*   get the information per plant and storage location
*   with buffer
    IF  G_FLAG_T001L = 'X'.
      IF  BESTAND-WERKS = G_S_T001L-WERKS  AND
          BESTAND-LGORT = G_S_T001L-LGORT.
      ELSE.
*       read with plant and storage location
        READ TABLE G_T_T001L   INTO  G_S_T001L
          WITH TABLE KEY WERKS = BESTAND-WERKS
                         LGORT = BESTAND-LGORT.

        MOVE : BESTAND-WERKS TO G_S_T001L-WERKS,
               BESTAND-LGORT TO G_S_T001L-LGORT.

        IF SY-SUBRC <> 0.
          CLEAR              G_S_T001L-LGOBE.
        ENDIF.
      ENDIF.
    ENDIF.

*   take the storage bin from the buffer
    MOVE : G_S_T001L-LGOBE   TO  BESTAND-LGOBE.


*   get the information per plant with buffer
    IF  BESTAND-WERKS  NE  G_S_ORGAN-WERKS.
      READ TABLE G_T_ORGAN   INTO  G_S_ORGAN
          WITH KEY WERKS = BESTAND-WERKS
                             BINARY SEARCH.

      IF SY-SUBRC <> 0.
*       sorry nothing found
        CLEAR                G_S_ORGAN.
        MOVE : BESTAND-WERKS TO  G_S_ORGAN-WERKS.
      ENDIF.
    ENDIF.

*   take the following fields from the buffer
    MOVE : G_S_ORGAN-NAME1   TO  BESTAND-NAME1,
           G_S_ORGAN-WAERS   TO  BESTAND-WAERS,
           G_S_ORGAN-BWKEY   TO  BESTAND-BWKEY.


*   get the information from the material master MARC
*   with buffer
    IF  BESTAND-MATNR = L_S_MAT-MATNR  AND
        BESTAND-WERKS = L_S_MAT-WERKS.
*     results are in the buffer
    ELSE.
      CLEAR                  L_S_MAT.
      MOVE : BESTAND-MATNR   TO  L_S_MAT-MATNR,
             BESTAND-WERKS   TO  L_S_MAT-WERKS.

      READ TABLE T_MAT       INTO  L_S_MAT
         WITH KEY MATNR = BESTAND-MATNR
                  WERKS = BESTAND-WERKS
                             BINARY SEARCH.

      IF  SY-SUBRC <> 0.
*       sorry nothing found
        CLEAR                L_S_MAT.
        MOVE : BESTAND-MATNR TO  L_S_MAT-MATNR,
               BESTAND-WERKS TO  L_S_MAT-WERKS.
      ENDIF.
    ENDIF.

*   take the results the buffer
    MOVE : L_S_MAT-MTART     TO  BESTAND-MTART,
           L_S_MAT-MATKL     TO  BESTAND-MATKL,
           L_S_MAT-MEINS     TO  BESTAND-MEINS.


*   if this entry has no deletion flag, take the
*   deletion flag from a higher level like MARA, MARC,
*   or MARDA
    IF  BESTAND-LVORM IS INITIAL.
      IF      NOT  L_S_MAT-LVORM_MARC IS INITIAL.
        MOVE  L_S_MAT-LVORM_MARC
                             TO  BESTAND-LVORM.
      ELSEIF  NOT  L_S_MAT-LVORM_MARA IS INITIAL.
        MOVE  L_S_MAT-LVORM_MARA
                             TO  BESTAND-LVORM.

      ELSEIF  NOT G_T_MARD_LV[] IS INITIAL  AND
              NOT BESTAND-LGORT IS INITIAL  AND
              NOT BESTAND-SOBKZ IS INITIAL.
*       look for deletion flag in working table
*       g_t_mard_lv for a line with special stock
        IF  BESTAND-MATNR = G_S_MARD_LV-MATNR  AND
            BESTAND-WERKS = G_S_MARD_LV-WERKS  AND
            BESTAND-LGORT = G_S_MARD_LV-LGORT.
        ELSE.
*         read table only after the key has changed
          READ TABLE G_T_MARD_LV  INTO  G_S_MARD_LV
          WITH TABLE KEY MATNR = BESTAND-MATNR
                         WERKS = BESTAND-WERKS
                         LGORT = BESTAND-LGORT.

          IF SY-SUBRC <> 0.
*           fill the buffer in case the entry does not exist
            MOVE : BESTAND-MATNR  TO  G_S_MARD_LV-MATNR,
                   BESTAND-WERKS  TO  G_S_MARD_LV-WERKS,
                   BESTAND-LGORT  TO  G_S_MARD_LV-LGORT.
            CLEAR                 G_S_MARD_LV-LVORM.
          ENDIF.

*         take the result from the buffer
          MOVE  G_S_MARD_LV-LVORM   TO  BESTAND-LVORM.
        ENDIF.
      ENDIF.
    ENDIF.


*   read the material short description after the material
*   number has changed
    IF  BESTAND-MATNR NE L_S_MAKT-MATNR.
      READ TABLE T_MAKT      INTO  L_S_MAKT
                   WITH KEY MATNR = BESTAND-MATNR
                             BINARY SEARCH.

      IF SY-SUBRC <> 0.
*       sorry nothing found
        CLEAR                L_S_MAKT-MAKTX.
        MOVE  BESTAND-MATNR  TO  L_S_MAKT-MATNR.
      ENDIF.
    ENDIF.

*   take the results the buffer
    MOVE : L_S_MAKT-MAKTX    TO  BESTAND-MAKTX.

* added dynamic break-point ID MMIM_REP_MB52              "n912093
    BREAK-POINT ID MMIM_REP_MB52.                           "n912093
    IF BESTAND-CHARG <> SPACE AND NOVALUES IS INITIAL.
      READ TABLE T_MCHA WITH KEY MATNR = BESTAND-MATNR
                                 WERKS = BESTAND-WERKS
                                 CHARG = BESTAND-CHARG
                                 BINARY SEARCH.
      IF SY-SUBRC = 0.
        BESTAND-BWTAR = T_MCHA-BWTAR.
      ENDIF.



    ENDIF.
    MODIFY BESTAND.
* Valuation keys
    IF NOVALUES IS INITIAL.
      IF  BESTAND-SOBKZ = ' ' OR BESTAND-SOBKZ = 'O' OR
          BESTAND-SOBKZ = 'W' OR BESTAND-SOBKZ = 'V' OR
          BESTAND-KZBWS = 'A'.
        T_MBEWKEY-MATNR = BESTAND-MATNR.
        T_MBEWKEY-BWKEY = BESTAND-BWKEY.
        T_MBEWKEY-BWTAR = BESTAND-BWTAR.
        COLLECT T_MBEWKEY.
      ELSEIF BESTAND-SOBKZ = 'E' AND BESTAND-KZBWS = 'M'.
        T_EBEWKEY-MATNR = BESTAND-MATNR.
        T_EBEWKEY-BWKEY = BESTAND-BWKEY.
        T_EBEWKEY-BWTAR = BESTAND-BWTAR.
        COLLECT T_EBEWKEY.
      ELSEIF BESTAND-SOBKZ = 'Q' AND BESTAND-KZBWS = 'M'.
        T_QBEWKEY-MATNR = BESTAND-MATNR.
        T_QBEWKEY-BWKEY = BESTAND-BWKEY.
        T_QBEWKEY-BWTAR = BESTAND-BWTAR.
        COLLECT T_QBEWKEY.
      ENDIF.
      T_T134MKEY-BWKEY = BESTAND-BWKEY.
      T_T134MKEY-MTART = BESTAND-MTART.
      COLLECT T_T134MKEY.
    ENDIF.                             " novalues is initial
  ENDLOOP.

* release the space of global working tables after use
  FREE : G_T_MARD_LV, G_T_T001L, G_T_ORGAN.

************************************************************************
* Read the valuation tables
************************************************************************
  IF NOVALUES IS INITIAL.
    READ TABLE T_MBEWKEY INDEX 1 TRANSPORTING NO FIELDS.
    IF SY-SUBRC = 0.
      SELECT MATNR BWKEY BWTAR LBKUM SALK3   ##TOO_MANY_ITAB_FIELDS
             VPRSV VERPR STPRS PEINH                        "353428
             INTO CORRESPONDING FIELDS OF TABLE T_MBEW
             FROM MBEW
             FOR ALL ENTRIES IN T_MBEWKEY
             WHERE MATNR = T_MBEWKEY-MATNR
               AND BWKEY = T_MBEWKEY-BWKEY
               AND BWTAR = T_MBEWKEY-BWTAR.
      SORT T_MBEW BY MATNR BWKEY BWTAR.
    ENDIF.

    READ TABLE T_EBEWKEY INDEX 1 TRANSPORTING NO FIELDS.
    IF SY-SUBRC = 0.
*     "Unfortunately", EBEW and QBEW do not have sum segments over
*     the valuation types. Therefore, without batch data, another
*     SELECT-statement is needed.
      IF XMCHB = 'X'.
        SELECT MATNR BWKEY BWTAR SOBKZ VBELN POSNR LBKUM SALK3
               VPRSV VERPR STPRS PEINH
               INTO (T_EBEW-MATNR, T_EBEW-BWKEY, T_EBEW-BWTAR,
                     T_EBEW-SOBKZ,  T_EBEW-VBELN, T_EBEW-POSNR,
                     T_EBEW-LBKUM, T_EBEW-SALK3,
                     T_EBEW-VPRSV, T_EBEW-VERPR,
                     T_EBEW-STPRS, T_EBEW-PEINH)
               FROM EBEW
               FOR ALL ENTRIES IN T_EBEWKEY
               WHERE MATNR = T_EBEWKEY-MATNR
                 AND BWKEY = T_EBEWKEY-BWKEY
                 AND BWTAR = T_EBEWKEY-BWTAR.
          COLLECT T_EBEW.
        ENDSELECT.
      ELSE.
        SELECT MATNR BWKEY BWTAR SOBKZ VBELN POSNR LBKUM SALK3
               VPRSV VERPR STPRS PEINH
               INTO (T_EBEW-MATNR, T_EBEW-BWKEY,  T_EBEW-BWTAR,
                     T_EBEW-SOBKZ,  T_EBEW-VBELN, T_EBEW-POSNR,
                     T_EBEW-LBKUM, T_EBEW-SALK3,
                     T_EBEW-VPRSV, T_EBEW-VERPR,
                     T_EBEW-STPRS, T_EBEW-PEINH)
               FROM EBEW
               FOR ALL ENTRIES IN T_EBEWKEY
               WHERE MATNR = T_EBEWKEY-MATNR
                 AND BWKEY = T_EBEWKEY-BWKEY.
          COLLECT T_EBEW.
        ENDSELECT.
      ENDIF.

      SORT T_EBEW BY MATNR BWKEY BWTAR SOBKZ VBELN POSNR.
    ENDIF.

    READ TABLE T_QBEWKEY INDEX 1 TRANSPORTING NO FIELDS.
    IF SY-SUBRC = 0.
      IF XMCHB = 'X'.
        SELECT MATNR BWKEY BWTAR SOBKZ PSPNR LBKUM SALK3
               VPRSV VERPR STPRS PEINH
               INTO (T_QBEW-MATNR, T_QBEW-BWKEY, T_QBEW-BWTAR,
                     T_QBEW-SOBKZ, T_QBEW-PSPNR,
                     T_QBEW-LBKUM, T_QBEW-SALK3,
                     T_QBEW-VPRSV, T_QBEW-VERPR,
                     T_QBEW-STPRS, T_QBEW-PEINH)
               FROM QBEW
               FOR ALL ENTRIES IN T_QBEWKEY
               WHERE MATNR = T_QBEWKEY-MATNR
                 AND BWKEY = T_QBEWKEY-BWKEY
                AND BWTAR = T_QBEWKEY-BWTAR.
          COLLECT T_QBEW.
        ENDSELECT.
      ELSE.
        SELECT MATNR BWKEY BWTAR SOBKZ PSPNR LBKUM SALK3
               VPRSV VERPR STPRS PEINH
               INTO (T_QBEW-MATNR, T_QBEW-BWKEY, T_QBEW-BWTAR,
                     T_QBEW-SOBKZ, T_QBEW-PSPNR,
                     T_QBEW-LBKUM, T_QBEW-SALK3,
                     T_QBEW-VPRSV, T_QBEW-VERPR,
                     T_QBEW-STPRS, T_QBEW-PEINH)
               FROM QBEW
               FOR ALL ENTRIES IN T_QBEWKEY
               WHERE MATNR = T_QBEWKEY-MATNR
                 AND BWKEY = T_QBEWKEY-BWKEY.
          COLLECT T_QBEW.
        ENDSELECT.
      ENDIF.

      SORT T_QBEW BY MATNR BWKEY BWTAR SOBKZ PSPNR.
    ENDIF.

    READ TABLE T_T134MKEY INDEX 1 TRANSPORTING NO FIELDS.
    IF SY-SUBRC = 0.
      SELECT BWKEY MTART WERTU
             INTO CORRESPONDING FIELDS OF TABLE T_T134M
             FROM T134M
             FOR ALL ENTRIES IN T_T134MKEY
             WHERE BWKEY = T_T134MKEY-BWKEY
               AND MTART = T_T134MKEY-MTART.
      SORT T_T134M BY BWKEY MTART.
    ENDIF.
************************************************************************
* Fill the valuation data
************************************************************************
    DATA: FACTOR TYPE F.
    LOOP AT BESTAND.
      CHECK BESTAND-WAERS <> SPACE.  "Do nothing for failed Auth-Checks
      READ TABLE T_T134M WITH KEY BWKEY = BESTAND-BWKEY
                                  MTART = BESTAND-MTART
                                  BINARY SEARCH.
      CHECK SY-SUBRC = 0 AND T_T134M-WERTU = 'X'.
*     Set SY-SUBRC = 4. A successful table read resets it an starts
*     the value filling.
      SY-SUBRC = 4.
      IF  BESTAND-SOBKZ = ' ' OR BESTAND-SOBKZ = 'O' OR
          BESTAND-SOBKZ = 'W' OR BESTAND-SOBKZ = 'V' OR
          BESTAND-KZBWS = 'A'.
        READ TABLE T_MBEW WITH KEY MATNR = BESTAND-MATNR
                                   BWKEY = BESTAND-BWKEY
                                   BWTAR = BESTAND-BWTAR
                                   BINARY SEARCH.

      ELSEIF BESTAND-SOBKZ = 'E' AND BESTAND-KZBWS = 'M'.
        READ TABLE T_EBEW WITH KEY MATNR = BESTAND-MATNR
                                   BWKEY = BESTAND-BWKEY
                                   BWTAR = BESTAND-BWTAR
                                   SOBKZ = BESTAND-SOBKZ
                                   VBELN = BESTAND-VBELN    "n531604
                                   POSNR = BESTAND-POSNR    "n531604
                                   BINARY SEARCH.
        MOVE-CORRESPONDING T_EBEW TO T_MBEW.

      ELSEIF BESTAND-SOBKZ = 'Q' AND BESTAND-KZBWS = 'M'.
        READ TABLE T_QBEW WITH KEY MATNR = BESTAND-MATNR
                                   BWKEY = BESTAND-BWKEY
                                   BWTAR = BESTAND-BWTAR
                                   SOBKZ = BESTAND-SOBKZ
                                   PSPNR = BESTAND-PSPNR
                                   BINARY SEARCH.
        MOVE-CORRESPONDING T_QBEW TO T_MBEW.
      ENDIF.

      IF SY-SUBRC = 0.
        IF T_MBEW-LBKUM = 0.
*         Cannot happen, but in R/3 this does not hold in all cases...
          IF T_MBEW-PEINH = 0.                              "353428
            T_MBEW-PEINH = 1.                               "353428
          ENDIF.                                            "353428
*         Calculation of value in case of LBKUM = 0 only possible
*         for MBEW. EBEW and QBEW are collected over all subitems
*         (VBELN...), so the data are not available.
          IF BESTAND-SOBKZ = 'E' OR BESTAND-SOBKZ = 'Q'.    "388735
            FACTOR = 0.                                     "388735
            CLEAR BESTAND-WAERS.                            "388735
          ELSE.                                             "388735
            CASE T_MBEW-VPRSV.
              WHEN 'V'. FACTOR = T_MBEW-VERPR / T_MBEW-PEINH.
              WHEN 'S'. FACTOR = T_MBEW-STPRS / T_MBEW-PEINH.
            ENDCASE.
          ENDIF.                                            "388735
        ELSE.
          FACTOR = T_MBEW-SALK3 / T_MBEW-LBKUM.
        ENDIF.

        BESTAND-WLABS = BESTAND-LABST * FACTOR.
        BESTAND-WINSM = BESTAND-INSME * FACTOR.
        BESTAND-WSPEM = BESTAND-SPEME * FACTOR.
        BESTAND-WEINM = BESTAND-EINME * FACTOR.
        BESTAND-WUMLM = BESTAND-UMLME * FACTOR.
        BESTAND-WBWESB = BESTAND-BWESB * FACTOR.            "AC0K020254
        BESTAND-WGLGM = BESTAND-GLGMG * FACTOR.             "n912093
        BESTAND-WTRAM = BESTAND-TRAME * FACTOR.             "n912093
        BESTAND-WUMLC = BESTAND-UMLMC * FACTOR.             "n912093
*ENHANCEMENT-POINT EHP604_RM07MLBS_22 SPOTS ES_RM07MLBS .

        "- Characteristic
        CLEAR : IT_CHAR.
        REFRESH : IT_CHAR.
*        BREAK-POINT.
        IF BESTAND-CHARG NE ''.
          CLEAR : EXIDV1,EXIDV2,MAGRV,UEVEL.
          SELECT SINGLE EXIDV  MAGRV UEVEL INTO (EXIDV1,MAGRV,UEVEL)
            FROM VEPO
            JOIN VEKP ON VEPO~VENUM = VEKP~VENUM
            WHERE VEPO~CHARG = BESTAND-CHARG.

          IF MAGRV = 'BOX'.
            SELECT SINGLE EXIDV INTO EXIDV2
              FROM VEKP
              WHERE VEKP~VENUM = UEVEL.
            BESTAND-HUBOX = EXIDV1.
            BESTAND-HUPALLET = EXIDV2.
          ELSE.
            BESTAND-HUPALLET = EXIDV1.
          ENDIF.


          CALL FUNCTION 'ZCHARACTERISTICS'
            EXPORTING
              I_VAL_MATNR  = BESTAND-MATNR
              I_VAL_CHARGE = BESTAND-CHARG
            TABLES
              T_VAL_TAB    = IT_CHAR
            EXCEPTIONS
              NO_OBJECT    = 1
              NO_VALUES    = 2
              T_L_E1       = 2
              T_L_E2       = 3.
          IF SY-SUBRC EQ '0'.
            "- Tipe
            READ TABLE IT_CHAR  WITH  KEY ATNAM = 'ZZTYPE'  ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              BESTAND-ZZTYPE =  <FS_CHAR>-ATWRT.
            ENDIF.

            "- Thickness
            READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZTHICKNESS'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              MOVE <FS_CHAR>-ATFLV TO ATFLV1.
              MOVE  ATFLV1 TO BESTAND-ZZTHICKNESS .
            ENDIF.

            "- Width
            READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZWIDTH'   ASSIGNING <FS_CHAR> .
            IF SY-SUBRC = 0.
              MOVE <FS_CHAR>-ATFLV TO ATFLV2.
              BESTAND-ZZWIDTH =  ATFLV2.
            ENDIF.

            "- Length
            READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZLENGTHSHT'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              MOVE <FS_CHAR>-ATFLV TO ATFLV2.
              BESTAND-ZZLENGTH =  ATFLV2.
            ELSE.
              READ TABLE  IT_CHAR WITH  KEY ATNAM = 'ZZLENGTH'   ASSIGNING <FS_CHAR>.
              IF SY-SUBRC = 0.
                MOVE <FS_CHAR>-ATFLV TO ATFLV2.
                BESTAND-ZZLENGTH =  ATFLV2.
              ENDIF.
            ENDIF.

            "- Core.
            READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZCORE'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              BESTAND-ZZCORE =  <FS_CHAR>-ATWTB.
            ENDIF.

            "- Criteria Grade
            READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZCRITERIA'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              BESTAND-ZZCRITERIA =  <FS_CHAR>-ATWTB.
            ENDIF.

            "- Sistem Packing
            READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZPACKING'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              BESTAND-ZZPACKING =  <FS_CHAR>-ATWTB.
            ENDIF.

            "- Roll Number
            READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZNOMORROLL'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              BESTAND-ZZNOMORROLL =  <FS_CHAR>-ATWRT.
            ENDIF.

            "- Treatment
            READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZTREATMENT'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              BESTAND-ZZTREATMENT =  <FS_CHAR>-ATWTB.
            ENDIF.

            "- Splice-1
            READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZSPLICE-1'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              MOVE <FS_CHAR>-ATFLV TO ATFLV2.
              BESTAND-ZZSPLICE_1 =  ATFLV2.
            ENDIF.

            "- Splice-2
            READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZSPLICE-2'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              MOVE <FS_CHAR>-ATFLV TO ATFLV2.
              BESTAND-ZZSPLICE_2 =  ATFLV2.
            ENDIF.

            "- Splice-3
            READ TABLE IT_CHAR  WITH KEY ATNAM = 'ZZSPLICE-3'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              MOVE <FS_CHAR>-ATFLV TO ATFLV2.
              BESTAND-ZZSPLICE_3 =  ATFLV2.
            ENDIF.

            "- Alias
            READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZALIAS'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              BESTAND-ZZALIAS =  <FS_CHAR>-ATWRT.
            ENDIF.

            "- Label
            READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZLABEL'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              BESTAND-ZZLABEL =  <FS_CHAR>-ATWTB.
            ENDIF.

            "- Extra Length
            READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZEXLENGTH'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              MOVE <FS_CHAR>-ATFLV TO ATFLV2.
              BESTAND-ZZEXLENGTH =  ATFLV2.
            ENDIF.

              SELECT SINGLE ERSDA INTO BESTAND-ERSDA
                FROM MCH1
                WHERE CHARG = BESTAND-CHARG
                AND   MATNR = BESTAND-MATNR.

            "- Expired Live
            READ TABLE IT_CHAR WITH KEY ATNAM = 'ZZEXPIREDLIVE'   ASSIGNING <FS_CHAR>.
            IF SY-SUBRC = 0.
              MOVE <FS_CHAR>-ATFLV TO ATFLV2.
              BESTAND-ZZEXPIREDLIVE =  BESTAND-ERSDA + ATFLV2.
            ELSE.
              BESTAND-ZZEXPIREDLIVE = BESTAND-ERSDA. "'00000000'.
            ENDIF.

          ENDIF.
        ENDIF.

        IF BESTAND-SOBKZ EQ 'E'.
          CLEAR : SONUM,SOTEM.
          SPLIT BESTAND-SSNUM AT '/' INTO SONUM SOTEM.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = SONUM
            IMPORTING
              OUTPUT = BESTAND-SONUM.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              INPUT  = SOTEM
            IMPORTING
              OUTPUT = BESTAND-SOTEM.


          SELECT SINGLE AUART INTO BESTAND-AUART
            FROM VBAK
            JOIN VBAP ON VBAK~VBELN = VBAP~VBELN
            WHERE VBAK~VBELN = SONUM
            AND   VBAP~POSNR = SOTEM.

          SELECT SINGLE BEZEI INTO BESTAND-BEZEI
            FROM TVAGT
          JOIN VBAP ON VBAP~ABGRU = TVAGT~ABGRU
          WHERE SPRAS = 'E'
          AND VBELN = SONUM
          AND POSNR = SOTEM.

          SELECT SINGLE NAME1 INTO BESTAND-NAMEX
            FROM KNA1
          JOIN VBAK ON VBAK~KUNNR = KNA1~KUNNR
          JOIN VBAP ON VBAP~VBELN = VBAK~VBELN
          WHERE VBAP~VBELN = SONUM
          AND  VBAP~POSNR = SOTEM.

        ENDIF.

        MODIFY BESTAND.
      ENDIF.
    ENDLOOP.
  ENDIF.                               "novalues is initial

  IF LRB2 = 'X'.
    PERFORM CONNECT_SQL.
    PERFORM EXP_SQL.
    LEAVE SCREEN.
  ENDIF.

*ENHANCEMENT-POINT EHP604_RM07MLBS_23 SPOTS ES_RM07MLBS .
ENDFORM.                    "data_selection

************************************************************************
* Build fieldcatalog for list viewer
************************************************************************
FORM FIELDCATALOG.
* Header fields
  CLEAR FIELDCAT.
*ENHANCEMENT-SECTION     RM07MLBS_08 SPOTS ES_RM07MLBS.
  FIELDCAT-FIELDNAME     = 'MATNR'.
  FIELDCAT-TABNAME       = 'HEADER'.
  FIELDCAT-REF_TABNAME   = 'MARA'.
*END-ENHANCEMENT-SECTION.
  APPEND FIELDCAT.
  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'MAKTX'.
  FIELDCAT-TABNAME       = 'HEADER'.
  FIELDCAT-REF_TABNAME   = 'MAKT'.
  APPEND FIELDCAT.
  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'WERKS'.
  FIELDCAT-TABNAME       = 'HEADER'.
  FIELDCAT-REF_TABNAME   = 'T001W'.
  APPEND FIELDCAT.
  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'NAME1'.
  FIELDCAT-TABNAME       = 'HEADER'.
  FIELDCAT-REF_TABNAME   = 'T001W'.
  APPEND FIELDCAT.
  CLEAR FIELDCAT.
*ENHANCEMENT-POINT RM07MLBS_1 SPOTS ES_RM07MLBS .
  FIELDCAT-FIELDNAME     = 'MTART'.
  FIELDCAT-TABNAME       = 'HEADER'.
  FIELDCAT-REF_TABNAME   = 'MARA'.
  FIELDCAT-NO_OUT        = 'X'.
  APPEND FIELDCAT.
  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'MATKL'.
  FIELDCAT-TABNAME       = 'HEADER'.
  FIELDCAT-REF_TABNAME   = 'MARA'.
  FIELDCAT-NO_OUT        = 'X'.
  APPEND FIELDCAT.

* List body
  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'LGORT'.
  FIELDCAT-TABNAME       = 'BESTAND'.
  FIELDCAT-REF_TABNAME   = 'MARD'.
  FIELDCAT-OUTPUTLEN     = 5.
  APPEND FIELDCAT.

  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'LGOBE'.
  FIELDCAT-TABNAME       = 'BESTAND'.
  FIELDCAT-REF_TABNAME   = 'T001L'.
  FIELDCAT-NO_OUT        = 'X'.
  APPEND FIELDCAT.

  IF NOT PA_SOND IS INITIAL.
    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'SOBKZ'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-REF_TABNAME   = 'MKOL'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'KZBWS'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-REF_TABNAME   = 'MSSA'.
    FIELDCAT-OUTPUTLEN     = 1.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'AUART'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Sales Doc. Type'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'BEZEI'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'SO Rejection'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'NAMEX'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Customer Name'.
    APPEND FIELDCAT.


    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'SSNUM'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-REF_TABNAME   = 'BICKEY'.
    APPEND FIELDCAT.
  ENDIF.

  IF  XMCHB = 'X'.
    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'CHARG'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-REF_TABNAME   = 'MCHB'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZTYPE'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Tipe'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZTHICKNESS'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Thickness'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZWIDTH'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Width'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZLENGTH'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Length'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZCORE'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Core'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZCRITERIA'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Criteria'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZPACKING'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Packing'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZNOMORROLL'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Nomor Roll'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZTREATMENT'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Treatment'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZSPLICE_1'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Splice-1'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZSPLICE_2'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Splice-2'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZSPLICE_3'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Splice-3'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZALIAS'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Tipe Alias'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZLABEL'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Tipe Label'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZEXLENGTH'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Extra Length'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ZZEXPIREDLIVE'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Expired Date'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'HUPALLET'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'HU Pallet'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'HUBOX'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'HU Box'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'ERSDA'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-SELTEXT_L     = 'Production Date'.
    APPEND FIELDCAT.

  ENDIF.


  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'LVORM'.
  FIELDCAT-TABNAME       = 'BESTAND'.
  FIELDCAT-REF_TABNAME   = 'MARD'.
  FIELDCAT-OUTPUTLEN     = 3.
  APPEND FIELDCAT.

* Quantities
  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'LABST'.
  FIELDCAT-TABNAME       = 'BESTAND'.
  FIELDCAT-REF_TABNAME   = 'MARD'.
  FIELDCAT-QFIELDNAME    = 'MEINS'.
  APPEND FIELDCAT.

  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'MEINS'.
  FIELDCAT-TABNAME       = 'BESTAND'.
  FIELDCAT-REF_TABNAME   = 'MARA'.
  FIELDCAT-OUTPUTLEN     = '5'.
  APPEND FIELDCAT.

  CLEAR FIELDCAT.                                           "n912093
  FIELDCAT-FIELDNAME     = 'UMLME'.                         "n912093
  FIELDCAT-TABNAME       = 'BESTAND'.                       "n912093
  FIELDCAT-REF_TABNAME   = 'AM07M'.                         "n912093
  FIELDCAT-REF_FIELDNAME = 'MB52_TRAUML'.                   "n912093
  FIELDCAT-QFIELDNAME    = 'MEINS'.                         "n912093
  APPEND FIELDCAT.                                          "n912093

  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'INSME'.
  FIELDCAT-TABNAME       = 'BESTAND'.
  FIELDCAT-REF_TABNAME   = 'MARD'.
  FIELDCAT-QFIELDNAME    = 'MEINS'.
  APPEND FIELDCAT.

  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'EINME'.
  FIELDCAT-TABNAME       = 'BESTAND'.
  FIELDCAT-REF_TABNAME   = 'MARD'.
  FIELDCAT-QFIELDNAME    = 'MEINS'.
  APPEND FIELDCAT.

  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'SPEME'.
  FIELDCAT-TABNAME       = 'BESTAND'.
  FIELDCAT-REF_TABNAME   = 'MARD'.
  FIELDCAT-QFIELDNAME    = 'MEINS'.
  APPEND FIELDCAT.

  CLEAR FIELDCAT.
  FIELDCAT-FIELDNAME     = 'RETME'.
  FIELDCAT-TABNAME       = 'BESTAND'.
  FIELDCAT-REF_TABNAME   = 'MARD'.
  FIELDCAT-QFIELDNAME    = 'MEINS'.
  APPEND FIELDCAT.

* process MARC-BWESB as hidden field                     "AC0K020254
  CLEAR FIELDCAT.                                           "AC0K020254
  FIELDCAT-FIELDNAME     = 'BWESB'.                         "AC0K020254
  FIELDCAT-TABNAME       = 'BESTAND'.                       "AC0K020254
  FIELDCAT-REF_TABNAME   = 'MARC'.                          "AC0K020254
  FIELDCAT-QFIELDNAME    = 'MEINS'.                         "AC0K020254
  FIELDCAT-NO_OUT        = 'X'.                             "AC0K020254
  APPEND FIELDCAT.                                          "AC0K020254

* tied empties stock                                     "n912093
  FIELDCAT-FIELDNAME     = 'GLGMG'.                         "n912093
  FIELDCAT-TABNAME       = 'BESTAND'.                       "n912093
  FIELDCAT-REF_TABNAME   = 'MARC'.                          "n912093
  FIELDCAT-QFIELDNAME    = 'MEINS'.                         "n912093
  FIELDCAT-NO_OUT      = 'X'.                               "n912093
  APPEND FIELDCAT.                                          "n912093
  CLEAR FIELDCAT.                                           "n912093

* stock in transit                                       "n912093
  FIELDCAT-FIELDNAME     = 'TRAME'.                         "n912093
  FIELDCAT-TABNAME       = 'BESTAND'.                       "n912093
  FIELDCAT-REF_TABNAME   = 'MARC'.                          "n912093
  FIELDCAT-QFIELDNAME    = 'MEINS'.                         "n912093
  FIELDCAT-NO_OUT      = 'X'.                               "n912093
  APPEND FIELDCAT.                                          "n912093
  CLEAR FIELDCAT.                                           "n912093

* stock in uml                                           "n912093
  FIELDCAT-FIELDNAME     = 'UMLMC'.                         "n912093
  FIELDCAT-TABNAME       = 'BESTAND'.                       "n912093
  FIELDCAT-REF_TABNAME   = 'MARC'.                          "n912093
  FIELDCAT-QFIELDNAME    = 'MEINS'.                         "n912093
  FIELDCAT-NO_OUT      = 'X'.                               "n912093
  APPEND FIELDCAT.                                          "n912093
  CLEAR FIELDCAT.                                           "n912093


* set the key fields of the special stock as hidden fields
  IF  G_FLAG_SOBKZ-LIFNR = 'X'.
    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'LIFNR'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-REF_TABNAME   = 'MKOL'.
    FIELDCAT-NO_OUT        = 'X'.
    APPEND FIELDCAT.
  ENDIF.

  IF  G_FLAG_SOBKZ-KUNNR = 'X'.
    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'KUNNR'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-REF_TABNAME   = 'MSKU'.
    FIELDCAT-NO_OUT        = 'X'.
    APPEND FIELDCAT.
  ENDIF.

  IF  G_FLAG_SOBKZ-VBELN = 'X'.
    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'VBELN'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-REF_TABNAME   = 'MSKA'.
    FIELDCAT-NO_OUT        = 'X'.
    APPEND FIELDCAT.

    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'POSNR'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-REF_TABNAME   = 'MSKA'.
    FIELDCAT-NO_OUT        = 'X'.
    APPEND FIELDCAT.
  ENDIF.

  IF  G_FLAG_SOBKZ-PSPNR = 'X'.
    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'PSPNR'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-REF_TABNAME   = 'MSPR'.
    FIELDCAT-NO_OUT        = 'X'.
    APPEND FIELDCAT.
  ENDIF.

* here starts the second row
* Values
  IF NOVALUES IS INITIAL.
    CLEAR FIELDCAT.
    FIELDCAT-FIELDNAME     = 'DUMMY'.
    FIELDCAT-TABNAME       = 'BESTAND'.
    FIELDCAT-ROW_POS       = '2'.
    FIELDCAT-OUTPUTLEN     = 9.

*   calculate the length of the dummy field
    IF XMCHB = 'X'.
      ADD 11 TO FIELDCAT-OUTPUTLEN.
    ENDIF.

    IF NOT PA_SOND IS INITIAL.
      ADD 29 TO FIELDCAT-OUTPUTLEN.
    ENDIF.

    APPEND FIELDCAT.

*    CLEAR FIELDCAT.
*    FIELDCAT-FIELDNAME     = 'WLABS'.
*    FIELDCAT-TABNAME       = 'BESTAND'.
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-REF_TABNAME   = 'MBEW'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
*    FIELDCAT-ROW_POS       = '2'.
*    FIELDCAT-SELTEXT_S     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-DO_SUM        = 'X'.
*    APPEND FIELDCAT.
*    CLEAR FIELDCAT.
*    FIELDCAT-FIELDNAME     = 'WAERS'.
*    FIELDCAT-TABNAME       = 'BESTAND'.
*    FIELDCAT-REF_FIELDNAME = 'WAERS'.
*    FIELDCAT-REF_TABNAME   = 'T001'.
*    FIELDCAT-ROW_POS       = '2'.
*    FIELDCAT-OUTPUTLEN     = 5.
*    APPEND FIELDCAT.
*    CLEAR FIELDCAT.
*    FIELDCAT-FIELDNAME     = 'WUMLM'.
*    FIELDCAT-TABNAME       = 'BESTAND'.
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-REF_TABNAME   = 'MBEW'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
*    FIELDCAT-ROW_POS       = '2'.
*    FIELDCAT-SELTEXT_S     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-OUTPUTLEN     = '18'.
*    FIELDCAT-DO_SUM        = 'X'.
*    APPEND FIELDCAT.
*    CLEAR FIELDCAT.
*    FIELDCAT-FIELDNAME     = 'WINSM'.
*    FIELDCAT-TABNAME       = 'BESTAND'.
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-REF_TABNAME   = 'MBEW'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
*    FIELDCAT-ROW_POS       = '2'.
*    FIELDCAT-SELTEXT_S     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-OUTPUTLEN     = '18'.
*    FIELDCAT-DO_SUM        = 'X'.
*    APPEND FIELDCAT.
*    CLEAR FIELDCAT.
*    FIELDCAT-FIELDNAME     = 'WEINM'.
*    FIELDCAT-TABNAME       = 'BESTAND'.
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-REF_TABNAME   = 'MBEW'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
*    FIELDCAT-ROW_POS       = '2'.
*    FIELDCAT-SELTEXT_S     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-OUTPUTLEN     = '18'.
*    FIELDCAT-DO_SUM        = 'X'.
*    APPEND FIELDCAT.
*    CLEAR FIELDCAT.
*    FIELDCAT-FIELDNAME     = 'WSPEM'.
*    FIELDCAT-TABNAME       = 'BESTAND'.
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-REF_TABNAME   = 'MBEW'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
*    FIELDCAT-ROW_POS       = '2'.
*    FIELDCAT-SELTEXT_S     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-OUTPUTLEN     = '18'.
*    FIELDCAT-DO_SUM        = 'X'.
*    APPEND FIELDCAT.
*
*    CLEAR FIELDCAT.
*    FIELDCAT-FIELDNAME     = 'WRETM'.
*    FIELDCAT-TABNAME       = 'BESTAND'.
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-REF_TABNAME   = 'MBEW'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
*    FIELDCAT-ROW_POS       = '2'.
*    FIELDCAT-SELTEXT_S     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-SELTEXT_M     = TEXT-020.
*    FIELDCAT-OUTPUTLEN     = '18'.
*    FIELDCAT-DO_SUM        = 'X'.
*    APPEND FIELDCAT.

*  process estimated value MARC-BWESB as hidden field    "AC0K020254
*    CLEAR FIELDCAT.                                         "AC0K020254
*    FIELDCAT-FIELDNAME     = 'WBWESB'.                      "AC0K020254
*    FIELDCAT-TABNAME       = 'BESTAND'.                     "AC0K020254
*    FIELDCAT-REF_TABNAME   = 'MBEW'.                        "AC0K020254
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.                       "AC0K020254
*    FIELDCAT-CFIELDNAME    = 'WAERS'.                       "AC0K020254
*    FIELDCAT-ROW_POS       = '2'.                           "AC0K020254
*    FIELDCAT-SELTEXT_S     = TEXT-020.                      "AC0K020254
*    FIELDCAT-SELTEXT_M     = TEXT-020.                      "AC0K020254
*    FIELDCAT-SELTEXT_M     = TEXT-020.                      "AC0K020254
*    FIELDCAT-OUTPUTLEN     = '18'.                          "AC0K020254
*    FIELDCAT-DO_SUM        = 'X'.                           "AC0K020254
*    FIELDCAT-NO_OUT        = 'X'.                           "AC0K020254
*    APPEND FIELDCAT.                                        "AC0K020254
*
**   value for tied empties                               "n912093
*    FIELDCAT-NO_OUT      = 'X'.                             "n912093
*    FIELDCAT-FIELDNAME     = 'WGLGM'.                       "n912093
*    FIELDCAT-TABNAME       = 'BESTAND'.                     "n912093
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.                       "n912093
*    FIELDCAT-REF_TABNAME   = 'MBEW'.                        "n912093
*    FIELDCAT-CFIELDNAME    = 'WAERS'.                       "n912093
*    FIELDCAT-ROW_POS       = '2'.                           "n912093
*    FIELDCAT-SELTEXT_S     = TEXT-020.                      "n912093
*    FIELDCAT-SELTEXT_M     = TEXT-020.                      "n912093
*    FIELDCAT-SELTEXT_M     = TEXT-020.                      "n912093
*    FIELDCAT-OUTPUTLEN     = '18'.                          "n912093
*    FIELDCAT-DO_SUM        = 'X'.                           "n912093
*    APPEND FIELDCAT.                                        "n912093
*
**   value for transit                                    "n912093
*    FIELDCAT-NO_OUT      = 'X'.                             "n912093
*    FIELDCAT-FIELDNAME     = 'WTRAM'.                       "n912093
*    FIELDCAT-TABNAME       = 'BESTAND'.                     "n912093
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.                       "n912093
*    FIELDCAT-REF_TABNAME   = 'MBEW'.                        "n912093
*    FIELDCAT-CFIELDNAME    = 'WAERS'.                       "n912093
*    FIELDCAT-ROW_POS       = '2'.                           "n912093
*    FIELDCAT-SELTEXT_S     = TEXT-020.                      "n912093
*    FIELDCAT-SELTEXT_M     = TEXT-020.                      "n912093
*    FIELDCAT-SELTEXT_M     = TEXT-020.                      "n912093
*    FIELDCAT-OUTPUTLEN     = '18'.                          "n912093
*    FIELDCAT-DO_SUM        = 'X'.                           "n912093
*    APPEND FIELDCAT.
*
**   value for uml at plant                               "n912093
*    FIELDCAT-NO_OUT      = 'X'.                             "n912093
*    FIELDCAT-FIELDNAME     = 'WUMLC'.                       "n912093
*    FIELDCAT-TABNAME       = 'BESTAND'.                     "n912093
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.                       "n912093
*    FIELDCAT-REF_TABNAME   = 'MBEW'.                        "n912093
*    FIELDCAT-CFIELDNAME    = 'WAERS'.                       "n912093
*    FIELDCAT-ROW_POS       = '2'.                           "n912093
*    FIELDCAT-SELTEXT_S     = TEXT-020.                      "n912093
*    FIELDCAT-SELTEXT_M     = TEXT-020.                      "n912093
*    FIELDCAT-SELTEXT_M     = TEXT-020.                      "n912093
*    FIELDCAT-OUTPUTLEN     = '18'.                          "n912093
*    FIELDCAT-DO_SUM        = 'X'.                           "n912093
*    APPEND FIELDCAT.

  ENDIF.                               "novalues is initial
*ENHANCEMENT-POINT EHP604_RM07MLBS_24 SPOTS ES_RM07MLBS .

ENDFORM.                               " FELDKATALOG_AUFBAUEN

************************************************************************
* Show the result list
************************************************************************
FORM LIST_OUTPUT.

*  set pf-status 'STANDARD'.

*ENHANCEMENT-SECTION     RM07MLBS_09 SPOTS ES_RM07MLBS.
  KEYINFO-HEADER01 = 'MATNR'.
  KEYINFO-HEADER02 = 'WERKS'.
  KEYINFO-ITEM01   = 'MATNR'.
  KEYINFO-ITEM02   = 'WERKS'.
  KEYINFO-ITEM03   = 'LGORT'.

* new sort order
  SORT BESTAND BY MATNR WERKS LGORT
                  SOBKZ KZBWS
                  LIFNR KUNNR VBELN  POSNR  PSPNR CHARG.
*END-ENHANCEMENT-SECTION.


  REFRESH : SORT.
  CLEAR   : SORT, G_CNT_SPOS.

* create the sort table for the ALV depending on the
* list type
  IF      NOT PA_HSQ IS INITIAL.
*   for hierarchic seq. list

  ELSEIF  NOT  PA_FLT IS INITIAL.
*   for flat ( simple ) list
*ENHANCEMENT-SECTION     RM07MLBS_10 SPOTS ES_RM07MLBS.
    PERFORM  F0400_CREATE_SORT    USING  'MATNR'.
*END-ENHANCEMENT-SECTION.
    PERFORM  F0400_CREATE_SORT    USING  'WERKS'.
  ENDIF.

  PERFORM  F0400_CREATE_SORT      USING  'LGORT'.
  PERFORM  F0400_CREATE_SORT      USING  'SOBKZ'.
  PERFORM  F0400_CREATE_SORT      USING  'KZBWS'.
  PERFORM  F0400_CREATE_SORT      USING  'LIFNR'.
  PERFORM  F0400_CREATE_SORT      USING  'KUNNR'.

  PERFORM  F0400_CREATE_SORT      USING  'VBELN'.
  PERFORM  F0400_CREATE_SORT      USING  'POSNR'.
  PERFORM  F0400_CREATE_SORT      USING  'PSPNR'.


  DEFINE COLOURIZE.
    CLEAR COLOR.
    COLOR-FIELDNAME = &1.
    COLOR-COLOR-INT = '0'.
    IF &2 > 0.
      COLOR-COLOR-COL = '5'.
    ELSEIF &2 < 0.
      COLOR-COLOR-COL = '6'.
    ENDIF.
    APPEND COLOR.
    CASE &1.
      WHEN 'LABST'.
        COLOR-FIELDNAME = 'MEINS'.
        APPEND COLOR.
      WHEN 'WLABS'.
        COLOR-FIELDNAME = 'WAERS'.
        APPEND COLOR.
    ENDCASE.
  END-OF-DEFINITION.
*ENHANCEMENT-POINT EHP604_RM07MLBS_26 SPOTS ES_RM07MLBS .

* skip this loop when the user wants a flat list without
* colors
  IF  NOT PA_HSQ     IS INITIAL  OR
      NOT ALV_COLOR  =  'X'.
    LOOP AT BESTAND.
      IF  NOT PA_HSQ IS INITIAL.                            "n531604
*       create working table header only if a hierarchic    "n531604
*       list is required                                    "n531604
        ON CHANGE OF BESTAND-MATNR OR BESTAND-WERKS.
          MOVE-CORRESPONDING BESTAND TO HEADER.
*ENHANCEMENT-POINT RM07MLBS_2 SPOTS ES_RM07MLBS .
          APPEND HEADER.
        ENDON.
      ENDIF.                                                "n531604

*     create the table with the colour information          "n531604
*     depending on the customizing settings in table        "n531604
*     V_MMIM_REP_PRINT   'X' = no colors                    "n531604
      IF  ALV_COLOR NE 'X'.                                 "n531604
        REFRESH COLOR.
        COLOURIZE 'LABST' BESTAND-LABST.
        COLOURIZE 'UMLME' BESTAND-UMLME.
        COLOURIZE 'EINME' BESTAND-EINME.
        COLOURIZE 'SPEME' BESTAND-SPEME.
        COLOURIZE 'RETME' BESTAND-RETME.
        COLOURIZE 'INSME' BESTAND-INSME.
        COLOURIZE 'WLABS' BESTAND-WLABS.
        COLOURIZE 'WUMLM' BESTAND-WUMLM.
        COLOURIZE 'WEINM' BESTAND-WEINM.
        COLOURIZE 'WSPEM' BESTAND-WSPEM.
        COLOURIZE 'WRETM' BESTAND-WRETM.
        COLOURIZE 'WINSM' BESTAND-WINSM.
        COLOURIZE 'BWESB' BESTAND-BWESB.                    "AC0K020254
        COLOURIZE 'WBWESB' BESTAND-WBWESB.                  "AC0K020254
        COLOURIZE 'GLGMG' BESTAND-GLGMG.                    "n912093
        COLOURIZE 'WGLGM' BESTAND-WGLGM.                    "n912093
        COLOURIZE 'TRAME' BESTAND-TRAME.                    "n912093
        COLOURIZE 'WTRAM' BESTAND-WTRAM.                    "n912093
        COLOURIZE 'UMLMC' BESTAND-UMLMC.                    "n912093
        COLOURIZE 'WUMLC' BESTAND-WUMLC.                    "n912093
*ENHANCEMENT-POINT EHP604_RM07MLBS_27 SPOTS ES_RM07MLBS .
        BESTAND-FARBE = COLOR[].
        MODIFY BESTAND.
      ENDIF.                                                "n531604
    ENDLOOP.
  ENDIF.                                                    "n531604

* set the name for color table when required                "n531604
  IF  ALV_COLOR = 'X'.                                      "n531604
    CLEAR                    LAYOUT-COLTAB_FIELDNAME.       "n531604
  ELSE.                                                     "n531604
    MOVE  'FARBE'            TO  LAYOUT-COLTAB_FIELDNAME.   "n531604
  ENDIF.                                                    "n531604

  LAYOUT-GROUP_CHANGE_EDIT = 'X'.

  DATA : L_F_CHECK(01)       TYPE C.
*ENHANCEMENT-POINT EHP604_RM07MLBS_28 SPOTS ES_RM07MLBS STATIC .

* added dynamic break-point ID MMIM_REP_MB52                "n912093
  BREAK-POINT ID MMIM_REP_MB52.                             "n912093

* process the list according the parameters                 "n531604
  IF      NOT PA_HSQ IS INITIAL.                            "n531604
*     create a hierarchic list                              "n531604

*     assign form routine for page numbering                "n667256
    GS_EVENTS-NAME         =       'TOP_OF_PAGE'.           "n667256
    GS_EVENTS-FORM         = 'F4000_TOP_OF_PAGE'.           "n667256
    APPEND  GS_EVENTS      TO GT_EVENTS.                    "n667256

*ENHANCEMENT-POINT EHP604_RM07MLBS_29 SPOTS ES_RM07MLBS .


    CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
      EXPORTING
        I_INTERFACE_CHECK  = L_F_CHECK
        I_CALLBACK_PROGRAM = REPID
        IS_LAYOUT          = LAYOUT
        IT_FIELDCAT        = FIELDCAT[]
        I_DEFAULT          = 'X'
        I_SAVE             = 'A'
        IS_VARIANT         = VARIANTE
        IT_EVENTS          = GT_EVENTS[]                    "n667256
        I_TABNAME_HEADER   = 'HEADER'
        I_TABNAME_ITEM     = 'BESTAND'
        IS_KEYINFO         = KEYINFO
        IS_PRINT           = ALV_PRINT
        IT_SORT            = SORT[]
        IT_EXCLUDING       = EXCLUDING[]
      TABLES
        T_OUTTAB_HEADER    = HEADER
        T_OUTTAB_ITEM      = BESTAND
      EXCEPTIONS
        OTHERS             = 2.

  ELSEIF  NOT  PA_FLT IS INITIAL.                           "n531604
*   create a flat non-hierarchic list                     "n531604

*   assign form routine for page numbering only for       "n667256
*   classic ALV                                           "n667256
    IF  ALV_DETAIL_FUNC = 'REUSE_ALV_LIST_DISPLAY'.         "n667256
      GS_EVENTS-NAME       =       'TOP_OF_PAGE'.           "n667256
      GS_EVENTS-FORM       = 'F4000_TOP_OF_PAGE'.           "n667256
      APPEND  GS_EVENTS    TO GT_EVENTS.                    "n667256
    ENDIF.

*ENHANCEMENT-POINT EHP604_RM07MLBS_30 SPOTS ES_RM07MLBS .

    CALL FUNCTION ALV_DETAIL_FUNC
      EXPORTING
        I_INTERFACE_CHECK  = L_F_CHECK
        I_CALLBACK_PROGRAM = REPID
        IS_LAYOUT          = LAYOUT
        IT_FIELDCAT        = FIELDCAT[]
        IT_SORT            = SORT[]
        I_DEFAULT          = 'X'
        I_SAVE             = 'A'
        IS_VARIANT         = VARIANTE_FLAT
        IT_EVENTS          = GT_EVENTS[]                    "n667256
        IS_PRINT           = ALV_PRINT
      TABLES
        T_OUTTAB           = BESTAND
      EXCEPTIONS
        OTHERS             = 2.



  ENDIF.                                                    "n531604

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                               " LISTAUSGABE

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*       F4-Hilfe für Reportvariante                                    *
*----------------------------------------------------------------------*
FORM F4_FOR_VARIANT.

* look for the available display variant depending on the   "n531604
* selected mode of the SAP-LIST-VIEWER
  IF      NOT PA_HSQ IS INITIAL.
*     for hierarchic seq. list
    MOVE VARIANTE          TO  DEF_VARIANTE_F4.

  ELSEIF  NOT  PA_FLT IS INITIAL.
*     for flat ( simple ) list
    MOVE VARIANTE_FLAT     TO  DEF_VARIANTE_F4.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT          = DEF_VARIANTE_F4
      I_SAVE              = 'A'
*     it_default_fieldcat =
    IMPORTING
      E_EXIT              = VARIANT_EXIT
      ES_VARIANT          = DEF_VARIANTE
    EXCEPTIONS
      NOT_FOUND           = 2.

  IF SY-SUBRC = 2.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF VARIANT_EXIT = SPACE.
*     save the selected display variant
      P_VARI = DEF_VARIANTE-VARIANT.

      IF      NOT PA_HSQ IS INITIAL.
*       for hierarchic seq. list
        MOVE  P_VARI         TO  G_F_VARI_HSQ.

      ELSEIF  NOT  PA_FLT IS INITIAL.
*       for flat ( simple ) list
        MOVE  P_VARI         TO  G_F_VARI_FLT.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               " F4_FOR_VARIANT

*-----------------------------------------------------------"n531604
*    f0000_get_print_settings
*-----------------------------------------------------------"n531604

FORM F0000_GET_PRINT_SETTINGS.

* get the settings for the SAP-LIST-VIEWER
  SELECT SINGLE * FROM MMIM_REP_PRINT
                             WHERE REPORT = SY-REPID.

  IF SY-SUBRC <> 0.
*   if this entry is missing, set default values and insert
*   a new entry into database tabel MMIM_REP_PRINT
    CLEAR                    MMIM_REP_PRINT.
    MOVE : SY-REPID          TO  MMIM_REP_PRINT-REPORT,
           'X'               TO  MMIM_REP_PRINT-SELINFO.
    INSERT                   MMIM_REP_PRINT.

    IF  SY-SUBRC IS INITIAL.
      COMMIT                 WORK.
    ELSE.
*     error during insert into table MMIN_RE_PRINT
      MESSAGE  S895          WITH  TEXT-895.
    ENDIF.
  ENDIF.

* set the parameter for this run
  IF MMIM_REP_PRINT-SELINFO = 'X'.
    ALV_PRINT-NO_PRINT_SELINFOS = ' '.
  ELSE.
    ALV_PRINT-NO_PRINT_SELINFOS = 'X'.
  ENDIF.

  IF MMIM_REP_PRINT-COVERPAGE = 'X'.
    ALV_PRINT-NO_COVERPAGE = ' '.
  ELSE.
    ALV_PRINT-NO_COVERPAGE = 'X'.
  ENDIF.

  IF MMIM_REP_PRINT-LISTINFO = 'X'.
    ALV_PRINT-NO_PRINT_LISTINFOS = ' '.
  ELSE.
    ALV_PRINT-NO_PRINT_LISTINFOS = 'X'.
  ENDIF.

  IF MMIM_REP_PRINT-GRIDCONTROL = 'X'.
    ALV_DETAIL_FUNC = 'REUSE_ALV_GRID_DISPLAY'.
  ELSE.
    ALV_DETAIL_FUNC = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

  IF MMIM_REP_PRINT-COLOR = 'X'.
    ALV_COLOR       = 'X'.
  ELSE.
    ALV_COLOR       = SPACE.
  ENDIF.

ENDFORM.                     "f0000_get_print_settings

*-----------------------------------------------------------"n531604
* Initialization of the user defaults for the checkboxes
*    f0100_settings_init.                                   "n531604
*-----------------------------------------------------------"n531604

FORM F0100_SETTINGS_INIT.                                   "n531604

* only in dialog mode
  CHECK : SY-BATCH IS INITIAL.

  IF OREF_SETTINGS IS INITIAL.
    CREATE OBJECT OREF_SETTINGS
      EXPORTING
        I_ACTION = 'RM07MLBS'.
  ENDIF.

* get the parameters from the last run
  PA_SOND   = OREF_SETTINGS->GET( 'PA_SOND' ).
  PA_HSQ    = OREF_SETTINGS->GET( 'PA_HSQ' ).

  PA_FLT    = OREF_SETTINGS->GET( 'PA_FLT' ).
  NEGATIV   = OREF_SETTINGS->GET( 'NEGATIV' ).
  XMCHB     = OREF_SETTINGS->GET( 'XMCHB'   ).
  NOZERO    = OREF_SETTINGS->GET( 'NOZERO'  ).
  NOVALUES  = OREF_SETTINGS->GET( 'NOVALUES' ).

* check radiobuttons
  IF  PA_HSQ IS INITIAL.
    IF  PA_FLT IS INITIAL.
*     not allowed
      MOVE  'X'              TO  PA_HSQ.
    ENDIF.
  ELSE.
    IF  PA_FLT IS INITIAL.
    ELSE.
*     not allowed
      CLEAR                  PA_FLT.
    ENDIF.
  ENDIF.

ENDFORM.                     "f0100_settings_init           "n531604

************************************************************************
* Save the user settings
************************************************************************

FORM F0200_SETTINGS_SAVE.                                   "n531604

* only in dialog mode
  CHECK : SY-BATCH IS INITIAL.

* go on when the FORM routines of INITILIZATION             "n667256
* were processed                                            "n667256
  CHECK : G_FLAG_INITIALIZATION = 'X'.                      "n667256

* Save the settings
  CALL METHOD OREF_SETTINGS->SET( I_ELEMENT = 'PA_SOND'
    I_ACTIVE = PA_SOND ).
  CALL METHOD OREF_SETTINGS->SET( I_ELEMENT = 'PA_HSQ'
    I_ACTIVE = PA_HSQ ).
  CALL METHOD OREF_SETTINGS->SET( I_ELEMENT = 'PA_FLT'
    I_ACTIVE = PA_FLT ).
  CALL METHOD OREF_SETTINGS->SET( I_ELEMENT = 'NEGATIV'
    I_ACTIVE = NEGATIV ).
  CALL METHOD OREF_SETTINGS->SET( I_ELEMENT = 'XMCHB'
    I_ACTIVE = XMCHB ).

  CALL METHOD OREF_SETTINGS->SET( I_ELEMENT = 'NOZERO'
    I_ACTIVE = NOZERO ).
  CALL METHOD OREF_SETTINGS->SET( I_ELEMENT = 'NOVALUES'
    I_ACTIVE = NOVALUES ).

  CALL METHOD OREF_SETTINGS->FLUSH.

* carry out the database updates only; the normal commit    "n667256
* command does not allow to record this transaction for     "n667256
* a batch input session using transaction SHDB              "n667256
  CALL FUNCTION 'DB_COMMIT'.                                "n667256

ENDFORM.                     "f0200_settings_save           "n531604

*----------------------------------------------------------------------*
*    f0300_fieldcat_flat
*----------------------------------------------------------------------*

FORM F0300_FIELDCAT_FLAT.

* define macro
  DEFINE MACRO_FILL_FIELDCAT.
    ADD  : 1                 TO  G_CNT_COL_POS.
    MOVE : G_CNT_COL_POS     TO  FIELDCAT-COL_POS,
           &1                TO  FIELDCAT-FIELDNAME,
           'BESTAND'         TO  FIELDCAT-TABNAME,
           &2                TO  FIELDCAT-REF_TABNAME,
           &3                TO  FIELDCAT-NO_OUT.

    IF  NOT FIELDCAT-SELTEXT_L IS INITIAL.
      MOVE : FIELDCAT-SELTEXT_L   TO  FIELDCAT-SELTEXT_M,
             FIELDCAT-SELTEXT_L   TO  FIELDCAT-SELTEXT_S.
    ENDIF.

    APPEND                   FIELDCAT.
    CLEAR                    FIELDCAT.
  END-OF-DEFINITION.

*ENHANCEMENT-SECTION     RM07MLBS_11 SPOTS ES_RM07MLBS.

  MACRO_FILL_FIELDCAT 'MATNR'  'MARA'   C_OUT.
*END-ENHANCEMENT-SECTION.
  MACRO_FILL_FIELDCAT 'MAKTX'  'MAKT'   C_NO_OUT.
  MACRO_FILL_FIELDCAT 'WERKS'  'T001W'  C_OUT.
  MACRO_FILL_FIELDCAT 'NAME1'  'T001W'  C_NO_OUT.
  MACRO_FILL_FIELDCAT 'MTART'  'MARA'   C_NO_OUT.
  MACRO_FILL_FIELDCAT 'MATKL'  'MARA'   C_NO_OUT.
  MACRO_FILL_FIELDCAT 'LGORT'  'MARD'   C_OUT.
  MACRO_FILL_FIELDCAT 'LGOBE'  'T001L'  C_NO_OUT.           "1311282

  IF NOT PA_SOND IS INITIAL.
    MACRO_FILL_FIELDCAT 'SOBKZ'  'MKOL'   C_OUT.

    IF  NOVALUES IS INITIAL.
      MACRO_FILL_FIELDCAT 'KZBWS'  'MSSA'   C_OUT.
    ENDIF.

    MACRO_FILL_FIELDCAT 'AUART'  'VBAK'   C_OUT.

    FIELDCAT-SELTEXT_L     = 'SO Rejection'.
    FIELDCAT-OUTPUTLEN     = '40'.
    MACRO_FILL_FIELDCAT 'BEZEI'  ''   C_OUT.


    FIELDCAT-SELTEXT_L     = 'Customer Name'.
    FIELDCAT-OUTPUTLEN     = '40'.
    MACRO_FILL_FIELDCAT 'NAMEX'  ''   C_OUT.

    MOVE : 'SSNUM'           TO  FIELDCAT-REF_FIELDNAME.
    MACRO_FILL_FIELDCAT 'SSNUM' 'BICKEY' C_OUT.
  ENDIF.

  MACRO_FILL_FIELDCAT 'LVORM'  'MARD'   C_OUT.

  IF XMCHB = 'X'.
    MACRO_FILL_FIELDCAT 'CHARG'  'MCHB'   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Type'.
    FIELDCAT-OUTPUTLEN     = '20'.
    MACRO_FILL_FIELDCAT 'ZZTYPE'  ''   C_OUT.


    FIELDCAT-SELTEXT_L     = 'Thickness'.
    FIELDCAT-OUTPUTLEN     = '20'.
    MACRO_FILL_FIELDCAT 'ZZTHICKNESS'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Width'.
    FIELDCAT-OUTPUTLEN     = '20'.
    MACRO_FILL_FIELDCAT 'ZZWIDTH'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Length'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ZZLENGTH'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Core'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ZZCORE'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Criteria'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ZZCRITERIA'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Packing'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ZZPACKING'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Nomor Roll'.
    FIELDCAT-OUTPUTLEN     = '30'.
    MACRO_FILL_FIELDCAT 'ZZNOMORROLL'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Treatment'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ZZTREATMENT'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Splice-1'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ZZSPLICE_1'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Splice-2'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ZZSPLICE_2'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Splice-3'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ZZSPLICE_3'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Tipe Alias'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ZZALIAS'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Tipe Label'.
    FIELDCAT-OUTPUTLEN     = '50'.
    MACRO_FILL_FIELDCAT 'ZZLABEL'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Extra Length'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ZZEXLENGTH'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Expired Date'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ZZEXPIREDLIVE'  ''  C_OUT .

    FIELDCAT-SELTEXT_L     = 'HU Pallet'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'HUPALLET'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'HUBOX'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'HUBOX'  ''   C_OUT.

    FIELDCAT-SELTEXT_L     = 'Production Date'.
    FIELDCAT-OUTPUTLEN     = '18'.
    MACRO_FILL_FIELDCAT 'ERSDA'  ''   C_OUT.
  ENDIF.

  MACRO_FILL_FIELDCAT 'MEINS'  'MARA'   C_OUT.

* Stock and value for stock unrestrestricted use
  FIELDCAT-QFIELDNAME    = 'MEINS'.
  MACRO_FILL_FIELDCAT 'LABST'  'MARD'   C_OUT.
*ENHANCEMENT-POINT EHP604_RM07MLBS_31 SPOTS ES_RM07MLBS .

  IF NOVALUES IS INITIAL.
*    FIELDCAT-OUTPUTLEN     = 5.
*    MACRO_FILL_FIELDCAT 'WAERS'  'T001'   C_OUT.
*
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
**   'Wert frei verwend.'.
*    FIELDCAT-SELTEXT_L     = TEXT-021.
*    FIELDCAT-DO_SUM        = 'X'.
*    FIELDCAT-OUTPUTLEN     = '18'.
*    MACRO_FILL_FIELDCAT 'WLABS'  'MBEW'   C_OUT.
  ENDIF.

* stock and value for stock in transfer
  FIELDCAT-QFIELDNAME    = 'MEINS'.
  FIELDCAT-REF_FIELDNAME = 'MB52_TRAUML'.                   "n912093
  MACRO_FILL_FIELDCAT 'UMLME'  'AM07M'   C_OUT.             "n912093
*ENHANCEMENT-POINT EHP604_RM07MLBS_32 SPOTS ES_RM07MLBS .

  IF NOVALUES IS INITIAL.
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
*   'Wert in Umlagerung'. // Wert Umlag u. Transit     "n912093
*   'Wert Umlag.Bestand'. // n912093                   "n912093
*    FIELDCAT-SELTEXT_L     = TEXT-030.                      "n912093
*    FIELDCAT-DO_SUM        = 'X'.
*    FIELDCAT-OUTPUTLEN     = '18'.
*    MACRO_FILL_FIELDCAT 'WUMLM'  'MBEW'   C_OUT.
  ENDIF.

* stock and value for stock in quality inspection
  FIELDCAT-QFIELDNAME    = 'MEINS'.
  MACRO_FILL_FIELDCAT 'INSME'  'MARD'   C_OUT.
*ENHANCEMENT-POINT EHP604_RM07MLBS_33 SPOTS ES_RM07MLBS .

  IF NOVALUES IS INITIAL.
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
**   "Wert in QualPrüfng'
*    FIELDCAT-SELTEXT_L     = TEXT-023.
*    FIELDCAT-DO_SUM        = 'X'.
*    FIELDCAT-OUTPUTLEN     = '18'.
*    MACRO_FILL_FIELDCAT 'WINSM'  'MBEW'   C_OUT.
  ENDIF.

* stock and value for restricted stock
  FIELDCAT-QFIELDNAME    = 'MEINS'.
  MACRO_FILL_FIELDCAT 'EINME'  'MARD'   C_OUT.
*ENHANCEMENT-POINT EHP604_RM07MLBS_34 SPOTS ES_RM07MLBS .

  IF NOVALUES IS INITIAL.
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
**   "Wert nicht frei'
*    FIELDCAT-SELTEXT_L     = TEXT-024.
*    FIELDCAT-DO_SUM        = 'X'.
*    FIELDCAT-OUTPUTLEN     = '18'.
*    MACRO_FILL_FIELDCAT 'WEINM'  'MBEW'   C_OUT.
  ENDIF.

* stock and value for blocked stock
  FIELDCAT-QFIELDNAME    = 'MEINS'.
  MACRO_FILL_FIELDCAT 'SPEME'  'MARD'   C_OUT.
*ENHANCEMENT-POINT EHP604_RM07MLBS_35 SPOTS ES_RM07MLBS .

  IF NOVALUES IS INITIAL.
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
**   'Wert Sperrbestand'
*    FIELDCAT-SELTEXT_L     = TEXT-025.
*    FIELDCAT-DO_SUM        = 'X'.
*    FIELDCAT-OUTPUTLEN     = '18'.
*    MACRO_FILL_FIELDCAT 'WSPEM'  'MBEW'   C_OUT.
  ENDIF.

* stock and value for blocked returns
  FIELDCAT-QFIELDNAME    = 'MEINS'.
  MACRO_FILL_FIELDCAT 'RETME'  'MARD'   C_OUT.
*ENHANCEMENT-POINT EHP604_RM07MLBS_36 SPOTS ES_RM07MLBS .

* Values
  IF NOVALUES IS INITIAL.
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.
*    FIELDCAT-CFIELDNAME    = 'WAERS'.
**   "Wert RetourenSperr'.
*    FIELDCAT-SELTEXT_L     = TEXT-026.
*    FIELDCAT-DO_SUM        = 'X'.
*    FIELDCAT-OUTPUTLEN     = '18'.
*    MACRO_FILL_FIELDCAT 'WRETM'  'MBEW'   C_OUT.
  ENDIF.                               "novalues is initial

* process valuated block GR stock as hidden field        "AC0K020254
  FIELDCAT-QFIELDNAME    = 'MEINS'.                         "AC0K020254
  MACRO_FILL_FIELDCAT 'BWESB'  'MARC'   C_NO_OUT.           "AC0K020254
*ENHANCEMENT-POINT EHP604_RM07MLBS_37 SPOTS ES_RM07MLBS .
                                                            "AC0K020254
* the estimated value for the valuated block GR stock    "AC0K020254
* as hidden field, too                                   "AC0K020254
  IF NOVALUES IS INITIAL.                                   "AC0K020254
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.                       "AC0K020254
*    FIELDCAT-CFIELDNAME    = 'WAERS'.                       "AC0K020254
**   value blocked GR stock                               "AC0K020254
*    FIELDCAT-SELTEXT_L     = TEXT-027.                      "AC0K020254
*    FIELDCAT-DO_SUM        = 'X'.                           "AC0K020254
*    FIELDCAT-OUTPUTLEN     = '18'.                          "AC0K020254
*    MACRO_FILL_FIELDCAT 'WBWESB'  'MBEW'   C_NO_OUT.        "AC0K020254
  ENDIF.

* stock and value for tied empties                    "n912093
  FIELDCAT-QFIELDNAME    = 'MEINS'.                         "n912093
  MACRO_FILL_FIELDCAT 'GLGMG'  'MARC'   C_NO_OUT.           "n912093
*ENHANCEMENT-POINT EHP604_RM07MLBS_38 SPOTS ES_RM07MLBS .
                                                            "n912093
* Values                                              "n912093
  IF NOVALUES IS INITIAL.                                   "n912093
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.                       "n912093
*    FIELDCAT-CFIELDNAME    = 'WAERS'.                       "n912093
**   'Wert gebundenes Leergut'                         "n912093
*    FIELDCAT-SELTEXT_L     = TEXT-028.                      "n912093
*    FIELDCAT-DO_SUM        = 'X'.                           "n912093
*    FIELDCAT-OUTPUTLEN     = '18'.                          "n912093
*    MACRO_FILL_FIELDCAT 'WGLGM'  'MBEW'   C_NO_OUT.         "n912093
  ENDIF.                                                    "n912093


* stock and value for stock in transit                "n912093
  FIELDCAT-QFIELDNAME    = 'MEINS'.                         "n912093
  MACRO_FILL_FIELDCAT 'TRAME'  'MARC'   C_NO_OUT.           "n912093
*ENHANCEMENT-POINT EHP604_RM07MLBS_39 SPOTS ES_RM07MLBS .
                                                            "n912093
* Values                                              "n912093
  IF NOVALUES IS INITIAL.                                   "n912093
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.                       "n912093
*    FIELDCAT-CFIELDNAME    = 'WAERS'.                       "n912093
**   'Wert Transitbestand'                             "n912093
*    FIELDCAT-SELTEXT_L     = TEXT-029.                      "n912093
*    FIELDCAT-DO_SUM        = 'X'.                           "n912093
*    FIELDCAT-OUTPUTLEN     = '18'.                          "n912093
*    MACRO_FILL_FIELDCAT 'WTRAM'  'MBEW'   C_NO_OUT.         "n912093
  ENDIF.                                                    "n912093

* stock and value for stock in transit                "n912093
  FIELDCAT-QFIELDNAME    = 'MEINS'.                         "n912093
  MACRO_FILL_FIELDCAT 'UMLMC'  'MARC'   C_NO_OUT.           "n912093
*ENHANCEMENT-POINT EHP604_RM07MLBS_40 SPOTS ES_RM07MLBS .
                                                            "n912093
* Values                                              "n912093
  IF NOVALUES IS INITIAL.                                   "n912093
*    FIELDCAT-REF_FIELDNAME = 'SALK3'.                       "n912093
*    FIELDCAT-CFIELDNAME    = 'WAERS'.                       "n912093
**   'Wert Umlagerung an Werk'                         "n912093
*    FIELDCAT-SELTEXT_L     = TEXT-022.                      "n912093
*    FIELDCAT-DO_SUM        = 'X'.                           "n912093
*    FIELDCAT-OUTPUTLEN     = '18'.                          "n912093
*    MACRO_FILL_FIELDCAT 'WUMLC'  'MBEW'   C_NO_OUT.         "n912093
  ENDIF.                                                    "n912093

* set the key fields of the special stock as hidden fields
  IF  G_FLAG_SOBKZ-LIFNR = 'X'.
    MACRO_FILL_FIELDCAT 'LIFNR'  'MKOL'   C_NO_OUT.
  ENDIF.

  IF  G_FLAG_SOBKZ-KUNNR = 'X'.
    MACRO_FILL_FIELDCAT 'KUNNR'  'MSKU'   C_NO_OUT.
  ENDIF.

  IF  G_FLAG_SOBKZ-VBELN = 'X'.
    MACRO_FILL_FIELDCAT 'VBELN'  'MSKA'   C_NO_OUT.
    MACRO_FILL_FIELDCAT 'POSNR'  'MSKA'   C_NO_OUT.
  ENDIF.

  IF  G_FLAG_SOBKZ-PSPNR = 'X'.
    MACRO_FILL_FIELDCAT 'PSPNR'  'MSPR'   C_NO_OUT.
  ENDIF.

ENDFORM.                     "f0300_fieldcat_flat

*----------------------------------------------------------------------*
*    f0400_create_sort
*----------------------------------------------------------------------*

FORM F0400_CREATE_SORT
                   USING     L_F_FIELDNAME LIKE SORT-FIELDNAME.

* create the table with the alv sort information

  IF      NOT PA_HSQ IS INITIAL.
*   for hierarchic seq. list
*   check whether this is an active field is in the
*   fieldcat
    READ TABLE FIELDCAT WITH KEY
                             FIELDNAME = L_F_FIELDNAME
                             NO_OUT    = SPACE.

  ELSEIF  NOT  PA_FLT IS INITIAL.
*   for flat ( simple ) list
*   check whether this field is in the fieldcat
    READ TABLE FIELDCAT WITH KEY
                             FIELDNAME = L_F_FIELDNAME.
  ENDIF.

  IF SY-SUBRC IS INITIAL.
    ADD  1                   TO  G_CNT_SPOS.
    MOVE : G_CNT_SPOS        TO  SORT-SPOS,
           L_F_FIELDNAME     TO  SORT-FIELDNAME,
           'X'               TO  SORT-UP,
           'BESTAND'         TO  SORT-TABNAME.
    APPEND                   SORT.
    CLEAR                    SORT.
  ENDIF.

ENDFORM.                     "f0400_create_sort

*----------------------------------------------------------------------*
*    f2000_COLLECT_collector.
*----------------------------------------------------------------------*

FORM F2000_COLLECT_COLLECTOR.

* does the user want to suppress stock objects from plant   "n577268
* level ?                                                   "n577268
  IF  G_FLAG_SUPPRESS_INIT_LGORT = 'X'.                     "n577268
    IF  COLLECTOR-LGORT IS INITIAL.                         "n577268
*     ignore stock objects without storage location         "n577268
      EXIT.                  "--> go to exit                "n577268
    ENDIF.                                                  "n577268
  ENDIF.                                                    "n577268

************************************************************************
* process the functions "No zero stocks",
* "Negative stocks only", "Without batches" here
************************************************************************
*ENHANCEMENT-POINT EHP604_RM07MLBS_41 SPOTS ES_RM07MLBS .

  IF NEGATIV = 'X'.
*   ignore entry if all stocks are zero or greater
    IF COLLECTOR-LABST >= 0 AND COLLECTOR-EINME >= 0 AND
       COLLECTOR-INSME >= 0 AND COLLECTOR-RETME >= 0 AND
       COLLECTOR-SPEME >= 0 AND COLLECTOR-UMLME >= 0.
      EXIT.                  "--> go to exit
    ENDIF.
  ENDIF.

  IF NOZERO = 'X'.
*   ignore all entries without stock
    IF COLLECTOR-LABST = 0 AND COLLECTOR-EINME = 0 AND
       COLLECTOR-INSME = 0 AND COLLECTOR-RETME = 0 AND
       COLLECTOR-SPEME = 0 AND COLLECTOR-UMLME = 0.
      EXIT.                  "--> go to exit
    ENDIF.
  ENDIF.

  IF XMCHB IS INITIAL.
    CLEAR COLLECTOR-CHARG.
  ENDIF.

  COLLECT                    COLLECTOR.

ENDFORM.                     "f2000_COLLECT_collector.

*-----------------------------------------------------------"n579976
*     F3000_SEND_WARNING_M7_393                             "n579976
*-----------------------------------------------------------"n579976
                                                            "n579976
*&---------------------------------------------------------------------*
*&      Form  F3000_SEND_WARNING_M7_393
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->L_VARIANT  text
*----------------------------------------------------------------------*
FORM F3000_SEND_WARNING_M7_393                              "n579976
         USING     L_VARIANT LIKE  DISVARIANT-VARIANT.      "n579976
                                                            "n579976
* check the customising settings : emerge warning 393 ?     "n579976
  CALL FUNCTION              'ME_CHECK_T160M'               "n579976
    EXPORTING                                               "n579976
      I_ARBGB                = 'M7'                         "n579976
      I_MSGNR                = '393'                        "n579976
    EXCEPTIONS                                              "n579976
      NOTHING                = 0                            "n579976
      OTHERS                 = 1.                           "n579976
                                                            "n579976
  IF SY-SUBRC <> 0.                                         "n579976
*   list will be created using the initial layout &         "n579976
    MESSAGE I393             WITH  L_VARIANT.               "n667256
  ENDIF.                                                    "n579976
                                                            "n579976
ENDFORM.                     "F3000_SEND_WARNING_M7_393     "n579976
                                                            "n579976
*-----------------------------------------------------------"n579976


*-----------------------------------------------------------"n667256
*  F4000_TOP_OF_PAGE.                                       "n667256
*-----------------------------------------------------------"n667256
                                                            "n667256

AT SELECTION-SCREEN OUTPUT.                                 "n667256
  AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '1'.
  IF SY-SUBRC NE 0.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'LRB2'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
                                                            "n667256
*ENHANCEMENT-POINT RM07MLBS_04 SPOTS ES_RM07MLBS.
  IF  G_FLAG_INITIALIZATION IS INITIAL.                     "n667256
*   the process time INITIALIZATION was not done, so        "n667256
*   carry out the functions here                            "n667256
    MOVE  'X'                TO G_FLAG_INITIALIZATION.      "n667256
                                                            "n667256
    PERFORM                  F0000_GET_PRINT_SETTINGS.      "n667256
                                                            "n667256
*   look for the setting of the parameters from the         "n667256
*   last run                                                "n667256
    PERFORM                  F0100_SETTINGS_INIT.           "n667256
                                                            "n667256
    PERFORM                  INITIALISIERUNG.               "n667256
  ENDIF.                                                    "n667256
                                                            "n667256
*-----------------------------------------------------------"n667256

*------------------------- Datenselektion -----------------------------*
FORM F4000_TOP_OF_PAGE.                       "#EC CALLED      "n667256
                                                            "n667256
* go on if there is a print destination set                 "n667256
  CHECK   NOT SY-PRDSN IS INITIAL.                          "n667256

* go on if it is in print modus, only                       "n960980
  CHECK SY-UCOMM = '&RNT' OR SY-UCOMM IS INITIAL.           "n960980

                                                            "n667256
*     classic ALV : use the simple write command            "n667256
  WRITE : SY-DATLO DD/MM/YYYY, SY-TITLE, SY-PAGNO.          "n667256
                                                            "n667256
                                                            "n667256
ENDFORM.                     "F4000_TOP_OF_PAGE.            "n667256
                                                            "n667256
*&---------------------------------------------------------------------*
*&      Form  CONNECT_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONNECT_SQL .
  SELECT SINGLE DBMS
          FROM DBCON
          INTO DBTYPE
          WHERE CON_NAME = SAP_CON.

  IF DBTYPE = 'MSS'.
    TRY .
      EXEC SQL.
        SET CONNECTION :SAP_CON
      ENDEXEC.

      EXEC SQL.
        CONNECT TO :SAP_CON
      ENDEXEC.

      IF SY-SUBRC <> 0.
        MESSAGE 'Not Connected..!!' TYPE 'I'.
      ELSE.
        MESSAGE 'Database SQL Connected' TYPE 'I'.
      ENDIF.
    ENDTRY.
  ENDIF.
ENDFORM.                    " CONNECT_SQL
*&---------------------------------------------------------------------*
*&      Form  EXP_SQL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXP_SQL .
  TRY .
      EXEC SQL.
        DELETE  FROM XZBMBC
      ENDEXEC.

      EXEC SQL.
        COMMIT WORK
      ENDEXEC.
    CATCH CX_SY_NATIVE_SQL_ERROR.
      MESSAGE 'Error in procedure execution delete' TYPE 'I'.
      RETURN.
  ENDTRY.

  TRY.
      LOOP AT BESTAND.
        EXEC SQL.
          INSERT INTO XZBMBC(COL001,COL002,COL003,COL004,COL005,COL006,COL007,COL008,COL009,COL010,COL011,COL012,COL013,COL014,COL015,
                             COL016,COL017,COL018,COL019,COL020,COL021,COL022,COL023,COL024,COL025,COL026,COL027,COL028,COL029,COL030,
                             COL031,COL032,COL033,COL034,COL035,COL036,COL037,COL038)
          VALUES(:BESTAND-MATNR,:BESTAND-WERKS,:BESTAND-LGORT,:BESTAND-SOBKZ,:BESTAND-KZBWS,
                 :BESTAND-AUART,:BESTAND-BEZEI,:BESTAND-NAMEX,:BESTAND-SONUM,:BESTAND-SOTEM,
                 :BESTAND-LVORM,:BESTAND-CHARG,:BESTAND-ZZTYPE,:BESTAND-ZZTHICKNESS,:BESTAND-ZZWIDTH,:BESTAND-ZZLENGTH,
                 :BESTAND-ZZCORE,:BESTAND-ZZCRITERIA,:BESTAND-ZZPACKING,:BESTAND-ZZNOMORROLL,:BESTAND-ZZTREATMENT,
                 :BESTAND-ZZSPLICE_1,:BESTAND-ZZSPLICE_2,:BESTAND-ZZSPLICE_3,:BESTAND-ZZALIAS,:BESTAND-ZZLABEL,:BESTAND-ZZEXLENGTH,
                 :BESTAND-ZZEXPIREDLIVE,:BESTAND-HUPALLET,:BESTAND-HUBOX,:BESTAND-ERSDA,:BESTAND-MEINS,
                 :BESTAND-LABST,:BESTAND-UMLME,:BESTAND-INSME,:BESTAND-EINME,:BESTAND-SPEME,:BESTAND-RETME)
        ENDEXEC.

      ENDLOOP.

      EXEC SQL.
        COMMIT WORK
      ENDEXEC.

    CATCH CX_SY_NATIVE_SQL_ERROR.
      MESSAGE 'Error in procedure execution insert' TYPE 'I'.
      RETURN.
  ENDTRY.

  IF SY-SUBRC  = 0.
    MESSAGE 'Penyimpanan Data ke SQL sukses!!!' TYPE 'I'.
  ENDIF.
ENDFORM.                    " EXP_SQL