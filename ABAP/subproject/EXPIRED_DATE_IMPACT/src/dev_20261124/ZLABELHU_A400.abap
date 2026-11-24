*&---------------------------------------------------------------------*
*& Report  ZLABELHU_A400
*& Appl. Area :  MM
*& Created by :  Akbar
*&---------------------------------------------------------------------*
*& Program - Print Label HU A400 - Jet Technologies
*& 25 April 2019
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | ##.##.## |             |            | Program created          *
*&---------------------------------------------------------------------*

REPORT  ZLABELHU_A400.
TABLES: MCHB.

DATA: V_FORMNAME  TYPE TDSFNAME  VALUE  'ZLABELHU_A400',
      V_FUNCNAME  TYPE RS38L_FNAM.

DATA: V_TAB    TYPE API_VALI OCCURS 0 WITH HEADER LINE.
DATA: CONTROL_PARAMETERS TYPE SSFCTRLOP,
      OUTPUT_OPTIONS TYPE SSFCOMPOP.

DATA: BEGIN OF IT_CHARG OCCURS 0,
  CHARG LIKE MCHB-CHARG,
  MATNR LIKE MCHB-MATNR,
  END OF IT_CHARG.

DATA: V_VBELN LIKE MSKA-VBELN,
      V_POSNR LIKE MSKA-POSNR,
      V_SONUM_ITEM(17),
      VBARCTEXTTRIAS(30),
      VBARCODETRIAS(20),
      VCODE(10),
      VCORE(20),
      VROLL(50),
      VNWEIGHT(10),
      VINSIDE(20),
      VOUTSIDE(20),
      V_LIVE TYPE P,
      V_POSTDATE TYPE MKPF-BUDAT,
      V_EXPDATE TYPE MKPF-BUDAT,
      VUSED(10),
      VWIDTH(10),
      VLENGTH(10),
      VSPLICE(30),
      V_SYM TYPE STRING.

DATA: ITAB LIKE ZLABEL_WINDOWS OCCURS 0 WITH HEADER LINE,
      ITAB2 LIKE ZLABEL_WINDOWS OCCURS 0 WITH HEADER LINE.

DATA: V_COPY TYPE P,
      V_ROW TYPE P,
      V_COPIES(3) VALUE 1,
      V_KALAB LIKE MSKA-KALAB,
      V_KAINS LIKE MSKA-KAINS,
      V_KASPE LIKE MSKA-KASPE,
      V_CLABS LIKE MCHB-CLABS,
      V_CINSM LIKE MCHB-CINSM,
      V_CEINM LIKE MCHB-CEINM,
      V_CSPEM LIKE MCHB-CSPEM,
      V_BOX_NO(40),
      V_ZZPACKING(10),
      V_SUM_NETWEIGHT TYPE P DECIMALS 2,
      V_S_SUM_QTYSHEET(20),
      V_SUM_QTYSHEET TYPE P DECIMALS 2.

DATA : V_ERDAT(3),
       V_PLANT_CODE(2).

CLEAR: VCODE,VWIDTH,VLENGTH,VNWEIGHT,VROLL,VCORE,VUSED,VINSIDE,VOUTSIDE,
      VBARCTEXTTRIAS,VBARCODETRIAS,V_SONUM_ITEM.

PARAMETER: V_CHARG LIKE MCHB-CHARG NO-DISPLAY,
           V_EXIDV LIKE MCHB-MATNR NO-DISPLAY,
           V_MATNR LIKE MARA-MATNR NO-DISPLAY,
           V_WERKS LIKE VBDPL-WERKS NO-DISPLAY,
           V_MAGRV LIKE VEKP-MAGRV NO-DISPLAY,
           V_TOTRL(4) NO-DISPLAY,             "Get Total Roll
           V_TOTBX(4) NO-DISPLAY,             "Get Total Box
           V_DATDD(2) NO-DISPLAY,
           V_DATMM(2) NO-DISPLAY,
           V_DATYY(1) NO-DISPLAY,
           V_TMWGHT TYPE P DECIMALS 3 NO-DISPLAY.

REFRESH: IT_CHARG, ITAB.

IF V_CHARG IS NOT INITIAL.
  SELECT CHARG MATNR INTO TABLE IT_CHARG FROM MCH1 WHERE CHARG EQ V_CHARG.
  DELETE ADJACENT DUPLICATES FROM IT_CHARG COMPARING CHARG.
ELSE.
  MESSAGE 'Data batch tidak didapatkan..!' TYPE 'I'.
  LEAVE LIST-PROCESSING.
ENDIF.

LOOP AT IT_CHARG.
  CLEAR: VCODE,VWIDTH,VLENGTH,VNWEIGHT,VCORE,VUSED,VINSIDE,VOUTSIDE,VBARCTEXTTRIAS,VBARCODETRIAS,V_SONUM_ITEM.

  IF IT_CHARG-CHARG IS NOT INITIAL AND IT_CHARG-MATNR IS NOT INITIAL.
    REFRESH V_TAB.
    CLEAR V_TAB.
    CALL FUNCTION 'QC01_BATCH_VALUES_READ'
      EXPORTING
        I_VAL_MATNR    = IT_CHARG-MATNR
        I_VAL_CHARGE   = IT_CHARG-CHARG
      TABLES
        T_VAL_TAB      = V_TAB
      EXCEPTIONS
        NO_CLASS       = 1
        INTERNAL_ERROR = 2
        NO_VALUES      = 3
        NO_CHARS       = 4
        OTHERS         = 5.
  ENDIF.

  CLEAR V_TAB-ATWRT.

  SELECT SINGLE VBELN POSNR INTO (V_VBELN, V_POSNR) FROM MSKA
  WHERE MATNR = IT_CHARG-MATNR AND CHARG = IT_CHARG-CHARG AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 ).

  IF SY-SUBRC = 0.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = V_VBELN
      IMPORTING
        OUTPUT = V_VBELN.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = V_POSNR
      IMPORTING
        OUTPUT = V_POSNR.

    CONCATENATE V_VBELN V_POSNR INTO V_SONUM_ITEM SEPARATED BY '/'.
  ENDIF.

  LOOP AT V_TAB.
    IF V_TAB-ATNAM = 'ZZCODE'.
      READ TABLE V_TAB WITH KEY ATNAM = 'ZZALIAS'.
      IF SY-SUBRC = 0.
        VCODE = V_TAB-ATWRT.  "ambil value ALIAS
      ELSE.
        VCODE = V_TAB-ATWTB.  "ambil value CODE
      ENDIF.
    ELSEIF V_TAB-ATNAM = 'ZZWIDTH'.
      VWIDTH = V_TAB-ATWTB.
    ELSEIF V_TAB-ATNAM = 'ZZLENGTH'.
      VLENGTH = V_TAB-ATWTB.
    ELSEIF V_TAB-ATNAM = 'ZZCORE'.
      CONCATENATE V_TAB-ATWRT '"' INTO VCORE.
    ELSEIF V_TAB-ATNAM = 'ZZPACKING'.
      IF SY-CPROG = 'ZPPPPRINTLABEL' OR SY-TCODE = 'MB90'.
        V_ZZPACKING = ' '.
      ELSEIF SY-TCODE = 'VL74'  OR SY-TCODE = 'ZHU005'.
        IF V_MAGRV = 'BOX'.
          V_ZZPACKING = V_TAB-ATWRT.
        ELSE.
          V_ZZPACKING = 'PL'.
        ENDIF.
      ENDIF.
*     Barcode Box No(from exidv plant and erdat)...
      CLEAR V_PLANT_CODE.
      IF V_WERKS = '1000'.
        V_PLANT_CODE = 'WR'.
      ELSEIF V_WERKS = '2000'.
        V_PLANT_CODE = 'KR'.
      ELSEIF V_WERKS = '3000'.
        V_PLANT_CODE = 'JR'.
      ENDIF.
      CONCATENATE V_DATMM V_DATYY INTO V_ERDAT.
      IF V_ZZPACKING <> 'PL'.
        CONCATENATE V_EXIDV V_PLANT_CODE V_ERDAT INTO V_BOX_NO SEPARATED BY '-'.
      ELSE.
        CONCATENATE V_EXIDV V_PLANT_CODE V_ERDAT V_DATDD INTO V_BOX_NO SEPARATED BY '-'.
      ENDIF.
    ELSEIF V_TAB-ATNAM = 'ZZINSIDE'.
      VINSIDE = V_TAB-ATWTB.
    ELSEIF V_TAB-ATNAM = 'ZZOUTSIDE'.
      VOUTSIDE = V_TAB-ATWTB.
    ELSEIF V_TAB-ATNAM = 'ZZEXPIREDLIVE'.
      V_LIVE = V_TAB-ATWTB.
    ENDIF.
  ENDLOOP.

  VBARCODETRIAS = V_EXIDV.    "Get Barcode Value
  VBARCTEXTTRIAS = V_BOX_NO.  "Get Barcode Text Value
  VSPLICE = 'Ø'.              "HU tidak menampilkan splice

* Get Net Weight
  PERFORM GET_NET_WEIGHT.
  WRITE V_SUM_NETWEIGHT TO VNWEIGHT EXPONENT 0 DECIMALS 2.
  CONDENSE VNWEIGHT.

* Add Symbol of Film Type
  IF VCODE IS NOT INITIAL.
    SELECT SINGLE SYMB1 FROM ZLABELSYMBOL INTO V_SYM WHERE FTYPE = VCODE.
  ENDIF.

* Get Used Before Value
  IF V_LIVE NE ''.
    CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
      EXPORTING
        MATNR = IT_CHARG-MATNR
        CHARG = IT_CHARG-CHARG
      IMPORTING
        PDATE = V_POSTDATE.

    IF SY-SUBRC = 0.
      V_EXPDATE = V_POSTDATE + V_LIVE.
      CONCATENATE V_EXPDATE+0(4) '.' V_EXPDATE+4(2) INTO VUSED.
    ENDIF.
  ENDIF.

  ITAB-VSONUM_ITEM    = V_SONUM_ITEM.
  ITAB-VBARCTEXTTRIAS = VBARCTEXTTRIAS.
  ITAB-VBARCODETRIAS  = VBARCODETRIAS.
  ITAB-VTYPE          = VCODE.
  ITAB-VCORE          = VCORE.
  ITAB-VNWEIGHT       = VNWEIGHT.
  ITAB-VINSIDE        = VINSIDE.
  ITAB-VOUTSIDE       = VOUTSIDE.
  ITAB-VUSED          = VUSED.
  ITAB-VWIDTH         = VWIDTH.
  ITAB-VLENGTH        = VLENGTH.
  ITAB-VPARTNO        = VSPLICE.

  APPEND ITAB.
  CLEAR ITAB.

ENDLOOP.

PERFORM PRINT_DATA.

*&---------------------------------------------------------------------*
*&      Form  print_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PRINT_DATA.

  ITAB2[] = ITAB[].
  CLEAR: ITAB.
  REFRESH: ITAB.

  LOOP AT ITAB2 INTO ITAB.
    DO V_COPIES TIMES.
      APPEND ITAB.
    ENDDO.
    CLEAR: ITAB.
  ENDLOOP.

  SORT ITAB BY VBATCH.

  DESCRIBE TABLE ITAB LINES V_ROW.

  DATA: GV_DEVTYPE    TYPE RSPOPTYPE.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  V_COPY = V_COPIES.
*  CONTROL_PARAMETERS-NO_DIALOG = ''. "set pop-up preview smartforms
  CONTROL_PARAMETERS-NO_DIALOG = 'X'.

  CALL FUNCTION V_FUNCNAME
    EXPORTING
      CONTROL_PARAMETERS = CONTROL_PARAMETERS
      OUTPUT_OPTIONS     = OUTPUT_OPTIONS
      V_ROW              = V_ROW
      V_TOTRL            = V_TOTRL
      V_TOTBX            = V_TOTBX
      V_COPY             = V_COPY
      V_SYM              = V_SYM
    TABLES
      ITAB               = ITAB.

ENDFORM.                    "print_data
*&---------------------------------------------------------------------*
*&      Form  GET_NET_WEIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_NET_WEIGHT .

*-- Begin of MD01
  DATA: BEGIN OF LT_MSKA OCCURS 0,
        MATNR LIKE MSKA-MATNR,
        WERKS LIKE MSKA-WERKS,
        LGORT LIKE MSKA-LGORT,
        CHARG LIKE MSKA-CHARG,
        SOBKZ LIKE MSKA-SOBKZ,
        VBELN LIKE MSKA-VBELN,
        POSNR LIKE MSKA-POSNR,
        KALAB LIKE MSKA-KALAB,
        KAINS LIKE MSKA-KAINS,
        KASPE LIKE MSKA-KASPE,
        KALAB1 TYPE ZGSGEW,
        KAINS1 TYPE ZGSGEW,
        KASPE1 TYPE ZGSGEW,
        END OF LT_MSKA,
        BEGIN OF LT_MCHB OCCURS 0,
        MATNR LIKE MCHB-MATNR,
        WERKS LIKE MCHB-WERKS,
        LGORT LIKE MCHB-LGORT,
        CHARG LIKE MCHB-CHARG,
        CLABS LIKE MCHB-CLABS,
        CINSM LIKE MCHB-CINSM,
        CEINM LIKE MCHB-CEINM,
        CSPEM LIKE MCHB-CSPEM,
        CLABS1 TYPE ZGSGEW,
        CINSM1 TYPE ZGSGEW,
        CEINM1 TYPE ZGSGEW,
        CSPEM1 TYPE ZGSGEW,
        END OF LT_MCHB.
*-- End of MD01

  IF V_TMWGHT EQ SPACE.

    CLEAR : V_KALAB,
            V_KAINS,
            V_KASPE,
            V_CLABS,
            V_CINSM,
            V_CEINM,
            V_CSPEM,
            V_SUM_NETWEIGHT.

*-- Begin of MD01
    SELECT MATNR WERKS LGORT CHARG SOBKZ VBELN POSNR KALAB KAINS KASPE
    INTO TABLE LT_MSKA
    FROM MSKA
    WHERE MATNR = V_MATNR AND
          WERKS = V_WERKS AND
          CHARG = V_CHARG.
    LOOP AT LT_MSKA.
      LT_MSKA-KALAB1 = LT_MSKA-KALAB.
      LT_MSKA-KAINS1 = LT_MSKA-KAINS.
      LT_MSKA-KASPE1 = LT_MSKA-KASPE.
      ADD: LT_MSKA-KALAB1 TO V_KALAB,
           LT_MSKA-KAINS1 TO V_KAINS,
           LT_MSKA-KASPE1 TO V_KASPE.
    ENDLOOP.

    SELECT MATNR WERKS LGORT CHARG CLABS CINSM CEINM CSPEM
    INTO TABLE LT_MCHB
    FROM MCHB
    WHERE MATNR = V_MATNR AND
          WERKS = V_WERKS AND
          CHARG = V_CHARG.
    LOOP AT LT_MCHB.
      LT_MCHB-CLABS1 = LT_MCHB-CLABS.
      LT_MCHB-CINSM1 = LT_MCHB-CINSM.
      LT_MCHB-CEINM1 = LT_MCHB-CEINM.
      LT_MCHB-CSPEM1 = LT_MCHB-CSPEM.
      ADD: LT_MCHB-CLABS1 TO V_CLABS,
           LT_MCHB-CINSM1 TO V_CINSM,
           LT_MCHB-CEINM1 TO V_CEINM,
           LT_MCHB-CSPEM1 TO V_CSPEM.
    ENDLOOP.

*-- End of MD01
    V_SUM_NETWEIGHT = V_KALAB + V_KAINS + V_KASPE +
                      V_CLABS + V_CINSM + V_CEINM +
                      V_CSPEM.
  ELSE.
    V_SUM_NETWEIGHT = V_TMWGHT.
  ENDIF.

ENDFORM.                    " GET_NET_WEIGHT