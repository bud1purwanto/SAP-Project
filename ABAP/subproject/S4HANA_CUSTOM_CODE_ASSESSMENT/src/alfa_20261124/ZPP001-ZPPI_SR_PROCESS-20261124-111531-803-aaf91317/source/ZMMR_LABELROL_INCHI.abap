*&--------------------------------------------------------------------*
*&      Form  text_data
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM INCHI_TEXT_DATA.

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

  DATA:                           "Added by AKBAR 10.01.2019 (untuk Type A137 & J129)
        V_STOUCH1 TYPE STRING,
        V_STOUCH2 TYPE STRING,
        V_STOUCH3 TYPE STRING.

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
          V_TYPE,
          V_THICKNESS,
          V_PRODLINE,
          V_MONTHYEAR,
          V_SEQUENCENBR,
          V_CODE,
          V_ZZPACKING,
          V_LABELTYPE.


*Mod Replace v_grade
  CONCATENATE V_CHARG V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS  V_POSITIONSS INTO V_BARCODE.

  CALL FUNCTION 'CONVERSION_EXIT_BAS36_OUTPUT'
    EXPORTING
      INPUT          = V_BARCODE
    IMPORTING
      OUTPUT         = V_BARCODE
    EXCEPTIONS
      INVALID_FORMAT = 1
      OTHERS         = 2.
*  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

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
      OR V_LABELTYPE = 'I102' OR V_LABELTYPE = 'E117' OR V_LABELTYPE = 'E118'
      OR V_LABELTYPE = 'A109' OR V_LABELTYPE = 'A134' OR V_LABELTYPE = 'A142'
      OR V_LABELTYPE = 'A145' OR V_LABELTYPE = 'A137' OR V_LABELTYPE = 'J129').     "Added by AKBAR 10.01.2019 (Type A137 & J129)
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_POSTDATE+0(4) '.' V_POSTDATE+4(2) INTO V_TAB-ATWTB.
        APPEND V_TAB.

      ELSE.
*--- add by ALF when J107-J108 use production Date.
        IF V_LABELTYPE = 'J107' OR V_LABELTYPE = 'J108' OR V_LABELTYPE = 'D109' OR V_LABELTYPE = 'D110'
            OR V_LABELTYPE = 'J116'  OR V_LABELTYPE = 'J117' OR V_LABELTYPE = 'J112' OR V_LABELTYPE = 'B102'
            OR V_LABELTYPE = 'J103' OR V_LABELTYPE = 'J113' OR V_LABELTYPE = 'J120' OR V_LABELTYPE = 'J121'
            OR V_LABELTYPE = 'E209'  OR V_LABELTYPE = 'J127' OR V_LABELTYPE = 'J128'
            OR V_LABELTYPE = 'J134' OR V_LABELTYPE = 'J135'. "Added by J.Budi 02.03.2020 (Type J134 ref. J116 & J135 ref. J117)

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

  IF V_LABELTYPE <> 'A137' AND V_LABELTYPE <> 'J129'. "Added by AKBAR 18.01.2019 (Type A137 & J129)
    PERFORM GET_INCHI.
  ENDIF.

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
        IF V_LABELTYPE <> 'A137' AND V_LABELTYPE <> 'J129'. "Added by FATHIR 18.01.2019 (Type A137 & J129)
          WRITE V_T2 TO V_S_GAUGE.
        ELSE.
          WRITE V_GAUGE TO V_S_GAUGE.
        ENDIF.
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
        V_INCH = V_TAB-ATWTB * V_C_INCH.
        IF V_LABELTYPE <> 'A137' AND V_LABELTYPE <> 'J129'. "Added by AKBAR 18.01.2019 (Type A137 & J129)
          WRITE V_W2 TO V_S_INCH.
        ELSE.
          WRITE V_INCH TO V_S_INCH.
        ENDIF.

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
        IF V_LABELTYPE <> 'A137' AND V_LABELTYPE <> 'J129'. "Added by AKBAR 18.01.2019 (Type A137 & J129)
          WRITE V_L2 TO V_S_FEET.
        ELSE.
          WRITE V_FEET TO V_S_FEET.
        ENDIF.
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
*        V_LBS = V_TAB-ATWTB * V_C_LBS.
        WRITE V_N2 TO V_S_LBS.
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

  IF V_LABELIMGOLD <> V_LABELIMGNEW. "Add logo image 'ASTRIA'

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
        IF V_LABELTYPE = 'A304' OR V_LABELTYPE = 'A305'.
        ELSE.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_INCH
                                        V_S_INCH.
        ENDIF.
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

    " KODE MATERIAL
    IF V_LABELTYPE = 'A134' OR V_LABELTYPE = 'A142' OR V_LABELTYPE = 'A145'.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_VBELN
        IMPORTING
          OUTPUT = V_VBELN.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_POSNR
        IMPORTING
          OUTPUT = V_POSNR.

      CLEAR: V_PARTNO.
      SELECT SINGLE KDMAT INTO V_PARTNO FROM VBAP WHERE VBELN = V_VBELN AND POSNR = V_POSNR.

      IF V_PARTNO NE ''.
        CONCATENATE '<STX><ESC>F"PART  "<LF>Part no. ' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT SEPARATED BY SPACE.       APPEND TEXT_DATA.
        CONCATENATE '<STX><ESC>F"BPART  "<LF>' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
        CONCATENATE '<STX><ESC>F"PART1  "<LF>Film Type / Width / Part No.' '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.

        CLEAR: TEXT_DATA-STR_TEXT.
        READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZTYPE'.
        IF SY-SUBRC = 0.
          TEXT_DATA-STR_TEXT = V_ZLABEL-DATA2.
        ENDIF.

        READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZWIDTH'.
        IF SY-SUBRC = 0.
          CONCATENATE TEXT_DATA-STR_TEXT ' / ' V_ZLABEL-DATA2 'mm' INTO TEXT_DATA-STR_TEXT.
        ENDIF.

        CONCATENATE '<STX><ESC>F"PART2  "<LF>' TEXT_DATA-STR_TEXT ' / ' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
      ELSE.
        CONCATENATE '<STX><ESC>F"PART1  "<LF>Film Type / Width' '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.

        CLEAR: TEXT_DATA-STR_TEXT.
        READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZTYPE'.
        IF SY-SUBRC = 0.
          TEXT_DATA-STR_TEXT = V_ZLABEL-DATA2.
        ENDIF.

        READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZWIDTH'.
        IF SY-SUBRC = 0.
          CONCATENATE TEXT_DATA-STR_TEXT ' / ' V_ZLABEL-DATA2 'mm' INTO TEXT_DATA-STR_TEXT.
        ENDIF.

        CONCATENATE '<STX><ESC>F"PART2  "<LF>' TEXT_DATA-STR_TEXT '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
      ENDIF.

    ELSEIF V_LABELTYPE = 'A137' OR  V_LABELTYPE = 'J129'. "Added by AKBAR 09.01.2019 (Type A137 & J129) LINE 837 - 893
      "untuk mengambil data Special Touch 1 - 3
      CLEAR: V_STOUCH1, V_STOUCH2, V_STOUCH3.
      READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPECIALTOUCH-1'.
      IF SY-SUBRC = 0.
        V_STOUCH1 = V_TAB-ATWRT.
      ELSE.
        MESSAGE 'Special Touch - 1 belum memiliki data' TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ENDIF.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPECIALTOUCH-2'.
      IF SY-SUBRC = 0.
        V_STOUCH2 = V_TAB-ATWRT.
      ELSE.
        MESSAGE 'Special Touch - 2 belum memiliki data' TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ENDIF.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
      IF SY-SUBRC = 0.
        V_STOUCH3 = V_TAB-ATWRT.
      ELSE.
        MESSAGE 'Special Touch - 3 belum memiliki data' TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_VBELN
        IMPORTING
          OUTPUT = V_VBELN.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_POSNR
        IMPORTING
          OUTPUT = V_POSNR.

      CLEAR: V_PARTNO.
      SELECT SINGLE KDMAT INTO V_PARTNO FROM VBAP WHERE VBELN = V_VBELN AND POSNR = V_POSNR.

      IF V_STOUCH3 NE ''.
        CONCATENATE '<STX><ESC>F"PART  "<LF>PO Ref. ' V_STOUCH3 '<ETX>' INTO TEXT_DATA-STR_TEXT SEPARATED BY SPACE.       APPEND TEXT_DATA.
        CONCATENATE '<STX><ESC>F"BPART  "<LF>' V_STOUCH3 '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
        CONCATENATE '<STX><ESC>F"PART1  "<LF>Film Type / Width / PO Ref.' '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.

        CLEAR: TEXT_DATA-STR_TEXT.
        TEXT_DATA-STR_TEXT = V_STOUCH1.
        CONCATENATE TEXT_DATA-STR_TEXT ' / ' V_STOUCH2 INTO TEXT_DATA-STR_TEXT.

        CONCATENATE '<STX><ESC>F"PART2  "<LF>' TEXT_DATA-STR_TEXT ' / ' V_STOUCH3 '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
      ELSE.
        CONCATENATE '<STX><ESC>F"PART1  "<LF>Film Type / Width' '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.

        CLEAR: TEXT_DATA-STR_TEXT.
        TEXT_DATA-STR_TEXT = V_STOUCH1.
        CONCATENATE TEXT_DATA-STR_TEXT ' / ' V_STOUCH2 INTO TEXT_DATA-STR_TEXT.

        CONCATENATE '<STX><ESC>F"PART2  "<LF>' TEXT_DATA-STR_TEXT '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
      ENDIF.

      IF V_PARTNO NE ''.
           CONCATENATE '<STX><ESC>F"SKU  "<LF>' V_PARTNO '<ETX>' '' INTO TEXT_DATA-STR_TEXT.   APPEND TEXT_DATA. "Added by Fany 20-11-2024
      ENDIF.
    ENDIF.

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


*&---------------------------------------------------------------------*
*&      Form  get_inchi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_INCHI.
  DATA: V_SONUM1 LIKE VBAP-VBELN,  "TYPE p LENGTH 10,
        V_SONUM2 LIKE VBAP-POSNR,  " TYPE p LENGTH 6,
        V_TDNAME LIKE THEAD-TDNAME.

  DATA: IT_LINES TYPE TLINE OCCURS 0 WITH HEADER LINE.

  SELECT SINGLE VBELN POSNR INTO (V_SONUM1, V_SONUM2)
  FROM MSKA
  WHERE CHARG = V_CHARG AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 OR KAVLA > 0 OR KAVIN > 0 OR KAVSP > 0 ).

  CONCATENATE V_SONUM1 V_SONUM2 INTO V_TDNAME.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT   = SY-MANDT
      ID       = 'Z001'
      LANGUAGE = 'E'
      NAME     = V_TDNAME
      OBJECT   = 'VBBP'
    TABLES
      LINES    = IT_LINES.

  IF SY-SUBRC = 0.

    LOOP AT IT_LINES.
      IF IT_LINES-TDLINE+0(2) = 'L1'.
        V_L1 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'L2'.
        V_L2 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'W1'.
        V_W1  = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'W2'.
        V_W2  = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'N1'.
        V_N1  = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'N2'.
        V_N2  = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'S1'.
        V_S1 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'S2'.
        V_S2 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'T1'.
        V_T1 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'T2'.
        V_T2 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'P1'.
        V_P1 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'J1'.
        V_J1 = IT_LINES-TDLINE+3(20).
      ELSEIF IT_LINES-TDLINE+0(2) = 'F1'.
        V_F1 = IT_LINES-TDLINE+3(24).
      ELSEIF IT_LINES-TDLINE+0(2) = 'F2'.
        V_F2 = IT_LINES-TDLINE+3(24).
      ELSEIF IT_LINES-TDLINE+0(2) = 'F3'.
        V_F3 = IT_LINES-TDLINE+3(24).
      ELSEIF IT_LINES-TDLINE+0(2) = 'F4'.
        V_F4 = IT_LINES-TDLINE+3(24).
      ENDIF.
    ENDLOOP.
  ELSE.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    "get_inchi