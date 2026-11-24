*&---------------------------------------------------------------------*
*&  Report      : ZMMR_LABELROL_TYB                               *
*&  Appl. Area  : MM                                                   *
*&  Created by  : Mualifi                                              *
*&  Created on  : 06 November 2014                                      *
*&---------------------------------------------------------------------*
REPORT  ZMMR_LABELROL_TYB NO STANDARD PAGE HEADING MESSAGE-ID PP.

TABLES: AFPO,MARA, MCHA.

DATA: BEGIN OF IT_CHARG OCCURS 0,
      MATNR LIKE MCHA-MATNR,
      CHARG LIKE MCHA-CHARG,
  END OF IT_CHARG.

DATA : V_AUFNR TYPE AFPO-AUFNR,
       V_POS(2) TYPE C,
       V_DER(1) TYPE C,
       V_CRITERIAGRD(1) TYPE C.
DATA: V_MSG(135).

DATA: V_NUM TYPE P.

SELECT-OPTIONS : P_CHARG FOR MCHA-CHARG.
PARAMETER      : V_COPIES(3) DEFAULT 1.

INCLUDE ZMMR_LABELROL_INCL.


START-OF-SELECTION.
  SELECT MATNR CHARG INTO TABLE IT_CHARG FROM MCHA
  WHERE CHARG IN P_CHARG.

  LOOP AT IT_CHARG.
    CLEAR : V_MATNR,
            V_WERKS,
            V_CHARG,
            V_LGORT,
            V_CRITERIAGRD.

    V_CHARG = IT_CHARG-CHARG.
    V_MATNR = IT_CHARG-MATNR.

    CASE IT_CHARG-MATNR+0(2).
      WHEN 'SR'.
      WHEN OTHERS.
        CONCATENATE IT_CHARG-CHARG '-' IT_CHARG-MATNR ': bukan Finish goods..!' INTO V_MSG SEPARATED BY SPACE.
        MESSAGE V_MSG TYPE 'I'.
        CONTINUE.
    ENDCASE.

    IF SY-SUBRC = 0.
      REFRESH V_TAB.
      CLEAR V_TAB.
      CALL FUNCTION 'QC01_BATCH_VALUES_READ'
        EXPORTING
          I_VAL_MATNR    = V_MATNR
          I_VAL_CHARGE   = V_CHARG
        TABLES
          T_VAL_TAB      = V_TAB
        EXCEPTIONS
          NO_CLASS       = 1
          INTERNAL_ERROR = 2
          NO_VALUES      = 3
          NO_CHARS       = 4
          OTHERS         = 5.

      IF SY-SUBRC = 0.
        CLEAR: V_DERIVATIVEMS, V_POSITIONMS, V_DERIVATIVESS,  V_POSITIONSS,
               V_GRADE, V_NUM, V_SPLICE1_D, V_SPLICE2_D.

        "Added for RTP Core by Carfin 18.02.2019
        PERFORM CEK_RTP_CORE CHANGING FCN_ERRNO.
        IF FCN_ERRNO <> 0.
          STOP.
        ENDIF.
        "Added for RTP Core by Carfin 18.02.2019

        V_DERIVATIVEMS = '00'.
        V_POSITIONMS = '00'.
        V_DERIVATIVESS = '00'.
        V_POSITIONSS = '00'.

        LOOP AT V_TAB.
          IF V_TAB-ATNAM = 'ZZDERIVATIVEMS'.
            V_DERIVATIVEMS = V_TAB-ATWRT.
          ELSEIF V_TAB-ATNAM = 'ZZPOSITIONMS'.
            V_POSITIONMS = V_TAB-ATWRT.
          ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVESS'.
            V_DERIVATIVESS = V_TAB-ATWRT.
          ELSEIF V_TAB-ATNAM = 'ZZPOSITIONSS'.
            V_POSITIONSS = V_TAB-ATWRT.
          ELSEIF V_TAB-ATNAM = 'ZZGRADE'.
            V_GRADE = V_TAB-ATWRT.
          ELSEIF V_TAB-ATNAM = 'ZZSPLICE-1'.
            V_NUM = V_TAB-ATFLV.
            V_SPLICE1_D = V_NUM.
          ELSEIF V_TAB-ATNAM = 'ZZSPLICE-2'.
            V_NUM = V_TAB-ATFLV.
            V_SPLICE2_D = V_NUM.
          ENDIF.
        ENDLOOP.

        READ TABLE V_TAB WITH KEY ATNAM = 'ZZCRITERIA'.
        IF SY-SUBRC = 0.
          V_CRITERIAGRD = V_TAB-ATWRT.
        ENDIF.

        V_TAB-ATWRT = 'F100'.
        MODIFY V_TAB TRANSPORTING ATWRT WHERE ATNAM = 'ZZLABEL'.

        READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
        IF SY-SUBRC = 0.
          CLEAR MARA-MATKL.
          SELECT SINGLE MATKL
          INTO MARA-MATKL
          FROM MARA
          WHERE MATNR = V_MATNR.

          PERFORM NEW_TEXT_DATA.

          AT LAST.
            PERFORM DOWNLOAD_DATA.
            PERFORM GETFRSRV_B.
            PERFORM PRINT.
            PERFORM REFRESH_ALL.
          ENDAT.
        ELSE.
          MESSAGE I000(0K) WITH 'Label type is not exist! (Order#)' P_CHARG-LOW.
          STOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  refresh_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM REFRESH_ALL.
  REFRESH: V_TAB,V_TAB2, V_TAB3, V_ZLABEL, V_ZLABELMAPIMAGE, IT_CHARG, TEXT_DATA, TEXT_DATA2, P_CHARG, IT.
  CLEAR: V_TAB,V_TAB2, V_TAB3, V_ZLABEL, V_ZLABELMAPIMAGE, IT_CHARG, TEXT_DATA, TEXT_DATA2, P_CHARG, IT.
ENDFORM.                    "refresh_all



*&---------------------------------------------------------------------*
*&      Form  NEW_TEXT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM NEW_TEXT_DATA.

  DATA : FILE_DIR TYPE STRING VALUE '/spare/saplabel/'.
* // Data for Convert Value
  DATA : V_GAUGE  TYPE P,
*mode 2 dec - 5 digit
         V_S_GAUGE(5),
         V_S_GAUGE_INTER(40),
         V_INCH  TYPE P DECIMALS 2 ,
         V_S_INCH(6),
         V_S_WIDTH(4),
         V_S_LENGTH(8),
         V_S_INCH_INTER(40),
         V_FEET  TYPE P DECIMALS 2,
*for D009/iterfilm
         V_FEET_INTER TYPE P,
         V_S_FEET(20),
         V_S_FEET_INTER(40),
*mode 3 decimal
*------{ modified to 2 dec by adhimass@perdana-consulting.co.id
*       v_lbs  TYPE p DECIMALS 3,
         V_LBS  TYPE P DECIMALS 2,
*------}
         V_S_LBS(10),
         V_S_LBS_INTER(40),
         V_SPLICE1_INTER  TYPE P,
         V_SPLICE1  TYPE P DECIMALS 2,
         V_S_SPLICE1(20),
         V_SPLICE2_INTER  TYPE P,
         V_SPLICE2  TYPE P DECIMALS 2,
         V_S_SPLICE2(20),
         V_TEST(100) VALUE 39,
         V_INFO_ERROR(100) TYPE C,
         V_INFO_THICKNESS(20) TYPE C.
*mode 1 decimal - 5 digit
  DATA : V_LEN_MIC(2) VALUE 8,
*mode 2 decimal - 5 digit
         V_LEN_GAUGE(2) VALUE 5,
         V_LEN_CORE(2) VALUE 10,
         V_LEN_IN_OUT(2) VALUE 15,
         V_LEN_NORMAL(2) VALUE 8,
         V_LEN_LENGTH(2) VALUE 6,
         V_LEN_FEET(2) VALUE 7,
         V_LEN_WIDTH(2) VALUE 4,
         V_LEN_INCH(2) VALUE 6,
*mode 3 decimal x
         V_LEN_WEIGHT(2) VALUE 8,
         V_LEN_LBS(2) VALUE 9,
         V_STRLEN(2),
         V_LEN_SOITEM(2) VALUE 17.

*mode decimal 3
  DATA :
*---{ modified to 2 dec by adhimass@perdana-consulting.co.id
*       v_weight TYPE p DECIMALS 3,
         V_WEIGHT TYPE P DECIMALS 2,
*---}
         V_LENGTH TYPE P DECIMALS 2,
         V_LENGTH_SS(9) TYPE C,
         V_WIDTH  TYPE P DECIMALS 2,
         V_WIDTH_SS(9) TYPE C,
         V_SPLICE2_MIRING TYPE P DECIMALS 2,
         V_SPLICE1_MIRING TYPE P DECIMALS 2,
         V_TREAT_SS(24) TYPE C,
         V_CORE_SS(3) TYPE C,
         V_WEIGHT_SS(9) TYPE C.
  DATA :
*SMI
        V_LOTNO(40) TYPE C.

  CLEAR : V_VBELN, V_POSNR, V_SONUM_ITEM.



  SELECT SINGLE VBELN POSNR
  INTO (V_VBELN, V_POSNR)
  FROM MSKA
  WHERE
  MATNR = V_MATNR AND
*  werks = v_werks AND
*    lgort = v_lgort and
  CHARG = V_CHARG AND
  ( KALAB > 0 OR
  KAINS > 0 OR
  KASPE > 0 ).


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


  CLEAR :
*          v_erdat_mm,
*          v_erdat_yy,
          V_TYPE,
          V_THICKNESS,
          V_PRODLINE,
          V_MONTHYEAR,
          V_SEQUENCENBR,
          V_CODE,
*          v_grade,
*          v_derivativems,
*          v_derivativess,
*          v_positionms,
*          v_positionss,
          V_ZZPACKING,
          V_LABELTYPE.

*Mod for new Slitting Perdana
*W mean SS
*M mean MS
  IF SY-TCODE = 'VL74'  OR SY-TCODE = 'ZHU005'.

  ELSE.

  ENDIF.

*Mod Replace v_grade
*  CONCATENATE v_charg v_derivativems v_positionms v_derivativess  v_positionss v_grade INTO v_barcode.

  CONCATENATE V_CHARG V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS  V_POSITIONSS INTO V_BARCODE.


  CALL FUNCTION 'CONVERSION_EXIT_BAS36_OUTPUT'
    EXPORTING
      INPUT          = V_BARCODE
    IMPORTING
      OUTPUT         = V_BARCODE
    EXCEPTIONS
      INVALID_FORMAT = 1
      OTHERS         = 2.
*Get Net weight...
  PERFORM GET_NET_WEIGHT.

* ZZALIAS is the first priority...
* if zzalias ne space then zzalias = zztype...
  SORT V_TAB BY ATNAM.


* Reset v_flag_zzalias to ''
  V_FLAG_ZZALIAS = ''.

* reset wa alias
  WA_LENGT = SPACE.
  WA_WIDTH = SPACE.
  WA_THICK = SPACE.
  WA_DENSI = SPACE.
  V_FLAG_WEIGHT_ZZALIAS = ''.


  LOOP AT V_TAB.

    IF V_TAB-ATNAM = 'ZZALIAS'.

      V_TYPE = V_TAB-ATWRT.
      V_FLAG_ZZALIAS = 'X'.

      PERFORM MOD_WEIGHT_ALIAS USING V_MATNR V_CHARG V_WERKS V_TYPE.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZTYPE'.
      IF SY-SUBRC = 0.
        V_TAB-ATWRT = V_TYPE.
        V_TAB-ATWTB = V_TYPE.
        MODIFY V_TAB  INDEX SY-TABIX TRANSPORTING ATWRT ATWTB.
      ENDIF.
    ENDIF.

    IF V_FLAG_ZZALIAS <> 'X'.
      IF V_TAB-ATNAM = 'ZZTYPE'.
        V_TYPE = V_TAB-ATWRT.
      ENDIF.
    ENDIF.

* Get the roll No...
    IF V_TAB-ATNAM = 'ZZPRODLINE'.
      V_PRODLINE = V_TAB-ATWRT.
*    ELSEIF v_tab-atnam = 'ZZTYPE'.
*      v_type  = v_tab-atwtb.
    ELSEIF V_TAB-ATNAM = 'ZZMONTHYEAR'.
      V_MONTHYEAR = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZSEQUENCENBR'.
      V_SEQUENCENBR = V_TAB-ATWRT.

* { Add on 14/03/05 (PRA)
    ELSEIF V_TAB-ATNAM = 'ZZCODE'.
      V_CODE =  V_TAB-ATWRT.
*}

*get label type value
    ELSEIF V_TAB-ATNAM = 'ZZLABEL'.
      V_LABELTYPE = V_TAB-ATWRT.
      V_LABELIMGNEW = V_TAB-ATWRT.
      V_LABELORIG = V_TAB-ATWRT.
    ENDIF.

* For print Slit Roll, ignore zzpacking...
    IF V_TAB-ATNAM = 'ZZPACKING'.
      IF SY-CPROG = 'ZPPPPRINTLABEL' OR SY-TCODE = 'MB90'.
        V_ZZPACKING = ' '.
        CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
      ELSEIF SY-TCODE = 'VL74'  OR SY-TCODE = 'ZHU005'.
        IF V_MAGRV = 'BOX'.
          V_ZZPACKING = V_TAB-ATWRT.
          CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
          V_LABELTYPE = V_LABEL.
        ELSE.
          V_ZZPACKING = 'PL'.
          CONCATENATE V_ZZPACKING V_LABELTYPE INTO V_LABEL.
          V_LABELTYPE = V_LABEL.
        ENDIF.
      ENDIF.
    ENDIF.


*For Roll Expired Live
    IF V_TAB-ATNAM = 'ZZEXPIREDLIVE'.
      V_LIVE = ''.
      V_LIVE = V_TAB-ATWTB.
    ENDIF.

  ENDLOOP.


* Weight is getting from formula...
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZWEIGHT'.
  IF SY-SUBRC <> 0.
    V_TAB-ATNAM = 'ZZWEIGHT'.
    V_TAB-ATWTB = V_SUM_NETWEIGHT.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
  ELSE.
    V_TAB-ATWTB = V_SUM_NETWEIGHT.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
  ENDIF.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZLENGTH'.
  IF SY-SUBRC <> 0.
*    IF v_zzconversionmtrkg IS NOT INITIAL.
    V_TAB-ATNAM = 'ZZLENGTH'.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
*    ENDIF.
  ELSE.
*    IF v_zzconversionmtrkg IS NOT INITIAL.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
*    ENDIF.
  ENDIF.
*----------------------/


  IF V_DERIVATIVESS = '00'.
    V_DERIVATIVESS = ''.
  ENDIF.

  IF V_POSITIONSS = '00'.
    V_POSITIONSS = ''.
  ENDIF.


  CONCATENATE V_PRODLINE V_CODE V_MONTHYEAR V_SEQUENCENBR V_GRADE V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS V_POSITIONSS
  INTO V_ROLLNO
  SEPARATED BY SPACE.


* Only for t-code vl74...
  IF SY-TCODE = 'VL74'  OR SY-TCODE = 'ZHU005'.
* Barcode Box No(from exidv plant and erdat)...
    CLEAR V_PLANT_CODE.
    IF V_WERKS = '1000'.
      V_PLANT_CODE = 'WR'.
    ELSEIF V_WERKS = '2000'.
      V_PLANT_CODE = 'KR'.
    ELSEIF V_WERKS = '3000'.
      V_PLANT_CODE = 'JR'.
    ENDIF.

    CONCATENATE V_ERDAT_MM V_ERDAT_YY INTO V_ERDAT.

    CONCATENATE V_EXIDV V_PLANT_CODE V_ERDAT INTO V_BOX_NO SEPARATED BY '-'.

*Barcode box no.
    V_TAB-ATNAM = 'ZZBARC'.
    V_TAB-ATWTB = V_EXIDV.
    APPEND V_TAB.
*Total roll
    V_TAB-ATNAM = 'ZZTOTRL'.
    V_TAB-ATWTB = V_TOT_ROLL.
    APPEND V_TAB.

*Total box.
    V_TAB-ATNAM = 'ZZTOTBX'.
    V_TAB-ATWTB = V_TOT_BOX.
    APPEND V_TAB.

* Pallet or Box no...
    IF V_MAGRV = 'BOX'.
      V_TAB-ATNAM = 'ZZBOX'.
      V_TAB-ATWTB = V_BOX_NO.

      APPEND V_TAB.
    ELSEIF V_MAGRV = 'PLT'.
      V_TAB-ATNAM = 'ZZPALET'.
      V_TAB-ATWTB = V_BOX_NO.
      APPEND V_TAB.
    ENDIF.
  ELSE.
*Roll no and barcode roll no.
    V_TAB-ATNAM = 'ZZROLLNO'.
    V_TAB-ATWTB = V_ROLLNO.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBCROLL'.
*    v_tab-atwtb = v_charg.
    IF V_LABELTYPE = 'D113' OR V_LABELTYPE = 'B113'.
      PERFORM SNW_ROLL_BARCODE.
    ELSE.
      V_TAB-ATWTB = V_BARCODE.
    ENDIF.

    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBARC'.
*    v_tab-atwtb = v_charg.
    V_TAB-ATWTB = V_BARCODE.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBARC1'.
*    v_tab-atwtb = v_charg.
    CONCATENATE V_CHARG '-' V_BARCODE INTO V_CHARG_LONG.
    V_TAB-ATWTB = V_CHARG_LONG.
    APPEND V_TAB.

*Add Expired Date
*    SELECT SINGLE ersda INTO v_postdate FROM mch1 WHERE charg EQ v_charg AND matnr EQ v_matnr.
    CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
      EXPORTING
        MATNR = V_MATNR
        CHARG = V_CHARG
      IMPORTING
        PDATE = V_POSTDATE.


    IF SY-SUBRC = 0.
*Mag-Data (Manufacturing Date : DD/MM/YYYY)
      IF ( V_LABELTYPE = 'A113' OR V_LABELTYPE = 'E109' ).
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_POSTDATE+6(2) '/' V_POSTDATE+4(2) '/' V_POSTDATE+0(4)  INTO V_TAB-ATWTB.
        APPEND V_TAB.

*Senawang and others (Manufacturing Date : YYYY.MM)
      ELSEIF ( V_LABELTYPE = 'A123'
      OR V_LABELTYPE = 'B113' OR V_LABELTYPE = 'B121' OR V_LABELTYPE = 'B122'
      OR V_LABELTYPE = 'A121' OR V_LABELTYPE = 'A122'
      OR V_LABELTYPE = 'D113' OR V_LABELTYPE = 'D117' OR V_LABELTYPE = 'D118' OR V_LABELTYPE = 'D119'
      OR V_LABELTYPE = 'E112' OR V_LABELTYPE = 'E113' OR V_LABELTYPE = 'E114'
      OR V_LABELTYPE = 'F108' OR V_LABELTYPE = 'F109'
      OR V_LABELTYPE = 'I102' OR V_LABELTYPE = 'E117'
      OR V_LABELTYPE = 'A109').
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_POSTDATE+0(4) '.' V_POSTDATE+4(2) INTO V_TAB-ATWTB.
        APPEND V_TAB.

      ELSE.
*--- add by ALF when J107-J108 use production Date.
        IF V_LABELTYPE = 'J107' OR V_LABELTYPE = 'J108' OR V_LABELTYPE = 'D109' OR V_LABELTYPE = 'D110'
            OR V_LABELTYPE = 'J116'  OR V_LABELTYPE = 'J117' OR V_LABELTYPE = 'J112' OR V_LABELTYPE = 'B102'
            OR V_LABELTYPE = 'J103' OR V_LABELTYPE = 'J113' OR V_LABELTYPE = 'J120' OR V_LABELTYPE = 'J121'.
          V_EXPDATE = V_POSTDATE.
          V_TAB-ATNAM = 'ZZEX'.
          CONCATENATE V_EXPDATE+0(4) '.' V_EXPDATE+4(2) INTO V_TAB-ATWTB.
          APPEND V_TAB.
        ELSE.
*Other (Used Before :)
          IF V_LABELTYPE = 'D201'.
          ELSE.
            IF V_LIVE <> ''.
              V_EXPDATE = V_POSTDATE + V_LIVE.
              V_TAB-ATNAM = 'ZZEX'.
              CONCATENATE V_EXPDATE+0(4) '.' V_EXPDATE+4(2) INTO V_TAB-ATWTB.
              APPEND V_TAB.
            ENDIF.
          ENDIF.    "no expired date
        ENDIF.
      ENDIF.


    ENDIF.


*Mod Left Justified
* Clear
    CLEAR : V_S_SPLICE1,
            V_S_SPLICE2.

    V_TAB-ATNAM = 'ZZSPLICE-1'.
*Get The Splices At 1st Value(M -> Feet)

    PERFORM CONV_TO_CHAR USING V_SPLICE1_D.
    V_SPLICE1 = V_SPLICE1_D * V_C_FEET.
    WRITE V_SPLICE1 TO V_S_SPLICE1.
    V_SPLICE1_MIRING = V_SPLICE1_D.
    WRITE V_SPLICE1_MIRING TO V_TAB-ATWTB.

    IF V_SPLICE1_D = 0.
      V_TAB-ATWTB = ''.
      V_S_SPLICE1 = ''.
    ENDIF.
    PERFORM RIGHT_JUSTIFIED USING V_LEN_LENGTH
                                  V_TAB-ATWTB.
*    ENDIF.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZSPLICE-2'.
    PERFORM CONV_TO_CHAR USING V_SPLICE2_D.
    V_SPLICE2 = V_SPLICE2_D * V_C_FEET.
    WRITE V_SPLICE2 TO V_S_SPLICE2.
    V_SPLICE2_MIRING = V_SPLICE2_D.
    WRITE V_SPLICE2_MIRING TO V_TAB-ATWTB.

    IF V_SPLICE2_D = 0.
      V_TAB-ATWTB = ''.
      V_S_SPLICE2 = ''.
    ENDIF.
    PERFORM RIGHT_JUSTIFIED USING V_LEN_LENGTH
                                  V_TAB-ATWTB.
*    ENDIF.
    APPEND V_TAB.
  ENDIF.


*Getting the data atnam from table zlabel.
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE V_ZLABEL
  FROM ZLABEL.

* Do the conversion...
  CLEAR : V_S_INCH,
          V_S_GAUGE,
          V_S_FEET,
          V_S_LBS.

  SORT V_ZLABEL BY ATNAM.
  LOOP AT V_ZLABEL.
    V_TABIX = SY-TABIX.
    CLEAR V_TAB-ATWTB.

    READ TABLE V_TAB WITH KEY ATNAM = V_ZLABEL-ATNAM.
    IF SY-SUBRC = 0.
* split/erase "kg" from net weight.
      IF V_ZLABEL-ATNAM = 'ZZWEIGHT'.
        SPLIT V_TAB-ATWTB AT V_DEL INTO V_TAB-ATWTB V_1.
      ENDIF.

* Set conversion & Left Justified...
* Get the Thickness value(Mic -> Gauge)
      IF V_ZLABEL-ATNAM = 'ZZTHICKNESS'.

        IF V_FLAG_ZZALIAS <> 'X' AND V_FLAG_WEIGHT_ZZALIAS = SPACE.
          SPLIT V_TAB-ATWTB AT V_DOT INTO V_TAB-ATWTB V_1.
        ELSEIF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_THICK.
        ELSEIF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = SPACE.
          SPLIT V_TAB-ATWTB AT V_DOT INTO V_TAB-ATWTB V_1.
        ENDIF.


        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        REPLACE ALL OCCURRENCES OF '.0' IN V_TAB-ATWTB WITH ' '.

        V_GAUGE = V_TAB-ATWTB * V_C_GAUGE.
        WRITE V_GAUGE TO V_S_GAUGE.
*        PERFORM right_justified USING v_len_mic
*                                      v_tab-atwtb.

        V_THICKNESS = V_TAB-ATWTB.

*Prepare For Alias
        CONDENSE V_THICKNESS NO-GAPS.

        CONCATENATE V_THICKNESS ' mic.   ' V_S_GAUGE ' ga.' INTO V_INFO_THICKNESS.

        V_TAB-ATWTB = ''.
        V_S_GAUGE = ''.


      ENDIF.

*Mod Left Justified
* Get The Width value(MM -> Inch)
      IF V_ZLABEL-ATNAM = 'ZZWIDTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_WIDTH.
        ENDIF.

        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        V_INCH =   V_TAB-ATWTB * V_C_INCH.
        WRITE V_INCH TO V_S_INCH.
        V_WIDTH = V_TAB-ATWTB.
*        WRITE v_width TO v_tab-atwtb.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_WIDTH
                                      V_TAB-ATWTB.

        WRITE V_TAB-ATWTB TO V_S_WIDTH.
        CONDENSE V_S_WIDTH NO-GAPS.

      ENDIF.
*Mod Left Justified
* Get The Length Value(M -> Feet)

      IF V_ZLABEL-ATNAM = 'ZZLENGTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_LENGT.
        ENDIF.

        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        V_FEET   = V_TAB-ATWTB * V_C_FEET.
        WRITE V_FEET TO V_S_FEET.
        V_LENGTH = V_TAB-ATWTB.
        WRITE V_LENGTH TO V_TAB-ATWTB.
        WRITE V_LENGTH TO V_S_LENGTH.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_LENGTH
                                      V_TAB-ATWTB.
        WRITE V_TAB-ATWTB TO V_S_LENGTH.
        CONDENSE V_S_LENGTH NO-GAPS.

*        ENDIF.
      ENDIF.

* Get The Length Value(MM -> Inch) For SheetLine
* Replace Feet to Inch in format

      IF V_ZLABEL-ATNAM = 'ZZLENGTHSHT'.
        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        V_FEET   = V_TAB-ATWTB * V_C_INCH.
        WRITE V_FEET TO V_S_FEET.
        V_LENGTH = V_TAB-ATWTB.
        WRITE V_LENGTH TO V_TAB-ATWTB.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_TAB-ATWTB.
      ENDIF.


* Get The NetWeight Value(KG -> LBS)
      IF V_ZLABEL-ATNAM = 'ZZWEIGH' OR V_ZLABEL-ATNAM = 'ZZWEIGHT'.

*        PERFORM conv_to_char USING v_tab-atwtb.
        PERFORM CONV_TO_CHAR_3_DEC USING V_TAB-ATWTB.
        V_LBS = V_TAB-ATWTB * V_C_LBS.
        WRITE V_LBS TO V_S_LBS.
        V_WEIGHT = V_TAB-ATWTB.
        WRITE V_WEIGHT TO V_TAB-ATWTB.
*mode 3 decimal
        PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT "v_len_normal
                                      V_TAB-ATWTB.
      ENDIF.

*Core Left Justified
      IF V_ZLABEL-ATNAM = 'ZZCORE'.
        CONCATENATE V_TAB-ATWTB 'CORE' INTO V_TAB-ATWTB.
      ENDIF.

*Type
      IF V_ZLABEL-ATNAM = 'ZZTYPE'.
        IF V_FLAG_ZZALIAS <> 'X'.

          CONCATENATE V_TAB-ATWRT  V_THICKNESS INTO V_TAB-ATWTB SEPARATED BY '-' .
          CONDENSE V_TAB-ATWTB NO-GAPS.
        ELSE.
          WRITE V_TAB-ATWRT TO V_TAB-ATWTB.
        ENDIF.


      ENDIF.

*Clean Grade Value
      IF V_ZLABEL-ATNAM = 'ZZGRADE'.
        V_TAB-ATWTB = ''.
      ENDIF.


* Criteria Grade for all label except toyobo
      IF V_ZLABEL-ATNAM = 'ZZCRITERIA'.
        IF V_TAB-ATWRT = '2'.
          V_CRITERIA = '.'.
        ELSE.
          V_CRITERIA = ' '.
        ENDIF.
      ENDIF.

*//
      V_ZLABEL-DATA2 = V_TAB-ATWTB.
    ELSE.
      V_ZLABEL-DATA2 = ' '.
    ENDIF.

    MODIFY V_ZLABEL INDEX V_TABIX TRANSPORTING DATA2.
  ENDLOOP.

*/---Added on 150405---
*cek previouly label
  CLEAR : V_LOTNO.

  IF ( V_LABELTYPE = 'B114' OR V_LABELTYPE = 'E108' OR V_LABELTYPE = 'C110' OR V_LABELTYPE = 'D115' OR
     V_LABELTYPE = 'A109' OR V_LABELTYPE = 'C111' OR V_LABELTYPE = 'F107' OR V_LABELTYPE = 'D116' ).

    CONCATENATE V_TYPE '-' V_THICKNESS '/' V_S_WIDTH 'mm /' V_S_LENGTH 'm' INTO V_LOTNO SEPARATED BY SPACE..
  ENDIF.

  IF V_LABELIMGOLD <> V_LABELIMGNEW.

*clear image and format to text-data---------------------
    REFRESH TEXT_DATA2.
    CLEAR TEXT_DATA2.

    CONCATENATE FILE_DIR  'CLEAR.TAX' INTO FILE_F.

    PERFORM GETFRSRV_F.
    TEXT_DATA2[] = IT[].

    LOOP AT TEXT_DATA2.
      TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.

      APPEND TEXT_DATA.
    ENDLOOP.


    SELECT IMAG1
      INTO CORRESPONDING FIELDS OF TABLE V_ZLABELMAPIMAGE
      FROM ZLABELMAPIMAGE
      WHERE KODE = V_LABELIMGNEW ORDER BY IMAG1.


    LOOP AT V_ZLABELMAPIMAGE.
*load image to text-data---------------------
      REFRESH TEXT_DATA2.
      CLEAR TEXT_DATA2.

      CONCATENATE FILE_DIR  V_ZLABELMAPIMAGE-IMAG1 '.TAX' INTO FILE_F.

      PERFORM GETFRSRV_F.
      TEXT_DATA2[] = IT[].

      LOOP AT TEXT_DATA2.
        TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.

        APPEND TEXT_DATA.
      ENDLOOP.

    ENDLOOP.

  ENDIF.

*---------------------/




******
  DO V_COPIES TIMES.
    REFRESH TEXT_DATA2.
    CLEAR TEXT_DATA2.

    CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.

    PERFORM GETFRSRV_F.
    TEXT_DATA2[] = IT[].

    LOOP AT TEXT_DATA2.
      TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
      IF SY-TABIX = 2.
        SHIFT TEXT_DATA-STR_TEXT+7  RIGHT BY 2 PLACES .
        ADD 1 TO POSI.
        TEXT_DATA-STR_TEXT+6(3) = POSI.
      ENDIF.

      APPEND TEXT_DATA.
    ENDLOOP.

******

*Condition for start and end syntax label command.
    TEXT_DATA-STR_TEXT = '<STX><ESC>E1,1<CAN><ETX>'.
    APPEND TEXT_DATA.

*Combine all command into internal table.
    LOOP AT V_ZLABEL.
* Get the strlen variable and substract from v_strlen for purpose right justified.
      IF V_ZLABEL-ATNAM = 'ZZTEXT1'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_INFO_THICKNESS '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZFEETX'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_FEET
                                      V_S_FEET.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_FEET '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZINCHX'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_INCH
                                      V_S_INCH.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_INCH '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZLBS'.
*mode 3 decimal
        PERFORM RIGHT_JUSTIFIED_3 USING V_LEN_LBS "v_len_normal
                                      V_S_LBS.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_LBS '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZGAUGE'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_GAUGE
                                      V_S_GAUGE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_GAUGE '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZFEETS1'.
*      write v_splice1 to v_s_splice1.
*      v_s_splice1 = v_splice1.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_FEET
                                      V_S_SPLICE1.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SPLICE1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZFEETS2'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_FEET
                                      V_S_SPLICE2.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SPLICE2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZCRITERIA'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_CRITERIA '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
       V_ZLABEL-ATNAM = 'ZZSOITEM'.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_SOITEM
                                      V_SONUM_ITEM.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_SONUM_ITEM '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZNUMBEROFSHEET' AND V_SUM_QTYSHEET <> ''.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_S_SUM_QTYSHEET.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SUM_QTYSHEET '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF
        V_ZLABEL-ATNAM = 'ZZLOTNUMBER'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_LOTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.

      ELSEIF V_ZLABEL-ATNAM = 'ZZODR'.
        DATA: V_BSTKD_E LIKE VBKD-BSTKD_E,
              V_CHAR10 TYPE N LENGTH 10.  "like vbak-vbeln.

        V_CHAR10 = V_VBELN.

        IF V_LABELTYPE = 'J120' OR V_LABELTYPE = 'J121' OR V_LABELTYPE = 'A305' OR V_LABELTYPE = 'A308' OR
           V_LABELTYPE = 'J122' OR V_LABELTYPE = 'J123' OR V_LABELTYPE = 'A309' OR
           V_LABELTYPE = 'B215 ' OR V_LABELTYPE = 'B216 ' OR V_LABELTYPE = 'B223' OR
           V_LABELTYPE = 'D213' OR V_LABELTYPE = 'D214' OR V_LABELTYPE = 'D219'.

          SELECT SINGLE BSTKD_E INTO V_BSTKD_E FROM VBKD WHERE VBELN = V_CHAR10 AND POSNR = ''.

          IF SY-SUBRC = 0.
            CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_BSTKD_E '<ETX>' INTO TEXT_DATA-STR_TEXT.
          ENDIF.
        ENDIF.
      ELSE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ENDIF.

      APPEND TEXT_DATA.
    ENDLOOP.

* Number of copies...
    TEXT_DATA-STR_TEXT = '<STX><RS>1<ETX>'.
    APPEND TEXT_DATA.

    TEXT_DATA-STR_TEXT = '<STX><US>1<ETX>'.
    APPEND TEXT_DATA.

    TEXT_DATA-STR_TEXT = '<STX><ETB><ETX>'.
    APPEND TEXT_DATA.

  ENDDO.

*get data filename.
  CONCATENATE PFN 'DATA' '.DAX' INTO FILE_D.
*get format filename.
  CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.
*get batch filename.
*  CONCATENATE file_dir  v_labeltype '.BAT' INTO file_b.
  CONCATENATE FILE_DIR  'DATA' '.BAT' INTO FILE_B.

*get image filename.
*  CONCATENATE file_dir v_labeltype '.IMG' INTO file_i.

*mark diffrent label
  V_LABELIMGOLD = V_LABELIMGNEW.

ENDFORM.                    "new_text_data