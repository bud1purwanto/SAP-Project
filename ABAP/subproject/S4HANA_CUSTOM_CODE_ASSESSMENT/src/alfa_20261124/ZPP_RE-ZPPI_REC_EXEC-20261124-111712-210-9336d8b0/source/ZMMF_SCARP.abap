*----------------------------------------------------------------------*
* ZMMF_SCARP                                                           *
* ~~~~~~~~~~~~~~                                                       *
*                                                                      *
* Description: Scrap                                                   *
*                                                                      *
* Specification - PM                                                   *
* Abaper        - bagus aditya putra                                   *
*----------------------------------------------------------------------*
* Amendment History                                                    *
* ~~~~~~~~~~~~~~~~~                                                    *
* Ref | Date     | Abaper      | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~~               *
*----------------------------------------------------------------------*

REPORT  ZMMF_SCARP.

TABLES : MSEG.
DATA :V_E_DEVTYPE              TYPE RSPOPTYPE,
      FMNAME TYPE RS38L_FNAM.
*      ST_JOB_OUTPUT_INFO       TYPE SSFCRESCL,
*      ST_DOCUMENT_OUTPUT_INFO  TYPE SSFCRESPD,
*      ST_JOB_OUTPUT_OPTIONS    TYPE SSFCRESOP,
*      ST_OUTPUT_OPTIONS        TYPE SSFCOMPOP,
*      ST_CONTROL_PARAMETERS    TYPE SSFCTRLOP.

DATA : BEGIN OF TPARAM OCCURS 0,
       MBLNR TYPE MSEG-MBLNR,
       ZEILE TYPE MSEG-ZEILE,
       MJAHR TYPE MSEG-MJAHR,
       MATNR TYPE MSEG-MATNR,
       MEINS TYPE MSEG-MEINS,
       ABLAD TYPE MSEG-ABLAD,
       WERKS TYPE MSEG-WERKS,
       WEMPF TYPE MSEG-WEMPF,
       BUDAT_MKPF TYPE MSEG-BUDAT_MKPF,
       END OF TPARAM.

DATA : MATNR1 TYPE MSEG-MATNR,
       MATNR2 TYPE MSEG-MATNR,
       MENGE  TYPE MSEG-MENGE,
       DD(2),
       MM(2),
       YY(2),
       WERKS TYPE MSEG-WERKS,
       WEMPF TYPE MSEG-WEMPF,
       CPUTM TYPE MKPF-CPUTM,
       CPUDT TYPE MKPF-CPUDT,
       X(2),
       Y,
       VAR1(3).

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-001.
PARAMETERS : MBLNR TYPE MSEG-MBLNR OBLIGATORY.
PARAMETERS : MJAHR TYPE MSEG-MJAHR OBLIGATORY.
SELECT-OPTIONS : ZEILE FOR MSEG-ZEILE.
SELECTION-SCREEN END OF BLOCK BLOCK1.


START-OF-SELECTION.
  CLEAR : TPARAM. REFRESH : TPARAM.

  SELECT  MBLNR ZEILE MJAHR MATNR MEINS ABLAD WERKS WEMPF BUDAT_MKPF
    FROM MSEG
    INTO TABLE TPARAM
    WHERE MBLNR = MBLNR
    AND   ZEILE IN ZEILE
    AND   MJAHR = MJAHR
    AND   BWART = '101'.

  SORT TPARAM BY MBLNR MJAHR ZEILE ASCENDING ZEILE.
  DELETE ADJACENT DUPLICATES FROM TPARAM COMPARING MBLNR MJAHR ZEILE.

  LOOP AT TPARAM.
    CLEAR : MATNR1,MATNR2,MENGE,DD,MM,YY,WERKS,WEMPF,CPUTM,CPUDT,X,Y,VAR1.

    TRANSLATE TPARAM-MATNR TO UPPER CASE.
    SPLIT TPARAM-MATNR AT '-' INTO MATNR1 MATNR2.

    SELECT SUM( MENGE ) INTO MENGE
      FROM MSEG
      WHERE MBLNR = TPARAM-MBLNR
      AND   ZEILE = TPARAM-ZEILE
      AND   MJAHR = TPARAM-MJAHR
      AND   BWART = '101'.

    DD = TPARAM-BUDAT_MKPF+6(2).
    MM = TPARAM-BUDAT_MKPF+4(2).
    YY = TPARAM-BUDAT_MKPF+2(2).

    IF TPARAM-WERKS = '1000'.
      WERKS = 'W'.
    ELSEIF TPARAM-WERKS = '2000' OR TPARAM-WERKS = 'TTA2' OR TPARAM-WERKS = 'TTE'. "ADD NEW COMPANY
      WERKS = 'K'.
    ELSE.
      WERKS = '-'.
    ENDIF.

    TRANSLATE TPARAM-WEMPF TO UPPER CASE.
    IF TPARAM-WEMPF = 'REC-WP1' OR TPARAM-WEMPF = 'REC-KP1' OR TPARAM-WEMPF = 'TTAREC01' OR TPARAM-WEMPF = 'TTEREC01'. "ADD NEW COMPANY
      WEMPF = '1'.
    ELSEIF TPARAM-WEMPF = 'REC-WP2' OR TPARAM-WEMPF = 'REC-KP2'.
      WEMPF = '2'.
    ELSEIF TPARAM-WEMPF = 'REC-WP3' OR TPARAM-WEMPF = 'REC-KP3'.
      WEMPF = '3'.
    ELSEIF TPARAM-WEMPF = 'REC-WP4' OR TPARAM-WEMPF = 'REC-KP4'.
      WEMPF = '4'.
    ELSEIF TPARAM-WEMPF = 'REC-WP5' OR TPARAM-WEMPF = 'REC-KP5'.
      WEMPF = '5'.
    ELSEIF TPARAM-WEMPF =  'REC-KX1'.
      WEMPF = '6'.
    ELSEIF TPARAM-WEMPF = 'REC-KT1'.
      WEMPF = '7'.
    ELSEIF TPARAM-WEMPF = 'REC-KT2'.
      WEMPF = '8'.
    ELSEIF TPARAM-WEMPF = 'REC-KT3'.
      WEMPF = '9'.
    ELSEIF TPARAM-WEMPF = 'REC-KT4'.
      WEMPF = '10'.
    ELSEIF TPARAM-WEMPF = 'REC-KT5'.
      WEMPF = '11'.
    ELSE.
      WEMPF  = '-'.
    ENDIF.


    SELECT SINGLE CPUTM CPUDT INTO (CPUTM,CPUDT)
      FROM MKPF
      WHERE MBLNR = TPARAM-MBLNR
      AND   MJAHR = TPARAM-MJAHR.

    IF CPUTM BETWEEN '000000' AND '070000'.
      X = 'I'.
    ELSEIF CPUTM BETWEEN '070001' AND '153000'.
      X = 'II'.
    ELSEIF CPUTM BETWEEN '153001' AND '140000'.
      X = 'III'.
    ELSE.
      X  = '-'.
    ENDIF.

    SELECT SINGLE ZZGROUP INTO Y
      FROM ZGROUP
      WHERE ZZTANGGAL = CPUDT
      AND   ZZJAM_MASUK <= CPUTM
      AND   ZZJAM_KELUAR >= CPUTM.

    CONCATENATE X Y INTO VAR1.



    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        FORMNAME           = 'ZSF_SCARP'
      IMPORTING
        FM_NAME            = FMNAME
      EXCEPTIONS
        NO_FORM            = 1
        NO_FUNCTION_MODULE = 2
        OTHERS             = 3.



    CALL FUNCTION FMNAME
      EXPORTING
        MATNR1             = MATNR1
        MATNR2             = MATNR2
        MENGE              = MENGE
        MEINS              = TPARAM-MEINS
        DD                 = DD
        MM                 = MM
        YY                 = YY
        WERKS              = WERKS
        WEMPF              = WEMPF
        VAR1               = VAR1
        MBLNR              = TPARAM-MBLNR.


  ENDLOOP.

END-OF-SELECTION.