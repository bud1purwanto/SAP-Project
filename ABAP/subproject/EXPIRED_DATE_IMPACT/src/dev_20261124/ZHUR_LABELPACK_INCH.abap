*-- HU label with inch value base on SO items text
FORM INCH_TEXT_DATA .

  DATA : FILE_DIR TYPE STRING VALUE '/spare/saplabel/'.

* // Data for Convert Value
  DATA : V_GAUGE  TYPE P,
*mode 2 dec - 5 digit
         V_S_GAUGE(5),
         V_S_GAUGE_INTER(40),
         V_INCH  TYPE P DECIMALS 2 ,
         V_S_INCH(20),
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
         V_S_LBS(20),
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
         V_LEN_GAUGE(2) VALUE 8,
         V_LEN_CORE(2) VALUE 10,
         V_LEN_IN_OUT(2) VALUE 15,
         V_LEN_NORMAL(2) VALUE 8,
*mode 3 decimal x
         V_LEN_WEIGHT(2) VALUE 8,
         V_STRLEN(2),
         V_LEN_SOITEM(2) VALUE 17,
         V_LEN_WIDTH(2) VALUE 4,
         V_LEN_INCH(2) VALUE 6,
         V_LEN_LENGTH(2) VALUE 6,
         V_LEN_FEET(2) VALUE 7,
         V_LEN_LBS(2) VALUE 9.

*mode decimal 3
  DATA :
*---{ modified to 2 dec by adhimass@perdana-consulting.co.id
*       v_weight TYPE p DECIMALS 3,
         V_WEIGHT TYPE P DECIMALS 2,
*---}
         V_LENGTH TYPE P DECIMALS 2,
         V_WIDTH  TYPE P DECIMALS 2,
         V_SPLICE2_MIRING TYPE P DECIMALS 2,
         V_SPLICE1_MIRING TYPE P DECIMALS 2.
*DATA : v_i_atwtb(16) TYPE p.

  DATA:                           "Added by AKBAR 10.01.2019 (untuk Type A137 & J129)
      V_STOUCH3 TYPE STRING.

* Get SO NUmber and Item from last Batch
  CLEAR : V_VBELN, V_POSNR, V_SONUM_ITEM.

  SELECT SINGLE VBELN POSNR
  INTO (V_VBELN, V_POSNR)
  FROM MSKA
  WHERE
  MATNR = V_MATNR AND
  WERKS = V_WERKS AND
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



*Get Net weight...
  PERFORM GET_NET_WEIGHT.
  CLEAR :
*          v_erdat_mm,
*          v_erdat_yy,
          V_TYPE,
          V_THICKNESS,
          V_PRODLINE,
          V_MONTHYEAR,
          V_SEQUENCENBR,
          V_CODE,
          V_GRADE,
          V_DERIVATIVEMS,
          V_DERIVATIVESS,
          V_POSITIONMS,
          V_POSITIONSS,
          V_ZZPACKING,
          V_LABELTYPE.
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
    ELSEIF V_TAB-ATNAM = 'ZZMONTHYEAR'.
      V_MONTHYEAR = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZSEQUENCENBR'.
      V_SEQUENCENBR = V_TAB-ATWRT.

* { Add on 14/03/05 (PRA)
    ELSEIF V_TAB-ATNAM = 'ZZCODE'.
      V_CODE =  V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZGRADE'.
      V_GRADE =  V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVEMS'.
      V_DERIVATIVEMS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZPOSITIONMS'.
      V_POSITIONMS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVESS'.
      V_DERIVATIVESS = V_TAB-ATWRT.
    ELSEIF V_TAB-ATNAM = 'ZZPOSITIONSS'.
      V_POSITIONSS = V_TAB-ATWRT.
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
  IF V_LABELORIG <> 'A137' AND V_LABELORIG <> 'J129'. "Added by AKBAR 18.01.2019 (Type A137 & J129)
    PERFORM GET_INCHI.
  ENDIF.

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

*Get Roll No...
*  CONCATENATE v_prodline v_type v_monthyear v_sequencenbr INTO v_rollno SEPARATED BY space.
* Modified (PRA) 14/03/05
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

    IF V_ZZPACKING <> 'PL'.
      CONCATENATE V_EXIDV V_PLANT_CODE V_ERDAT INTO V_BOX_NO SEPARATED BY '-'.
    ELSE.
      CONCATENATE V_EXIDV V_PLANT_CODE V_ERDAT V_ERDAT_DD INTO V_BOX_NO SEPARATED BY '-'.
    ENDIF.

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

*Add Expired Date
*    SELECT SINGLE ERSDA INTO V_POSTDATE FROM MCH1 WHERE CHARG EQ V_CHARG
*              AND MATNR = V_MATNR.
    CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
      EXPORTING
        MATNR = V_MATNR
        CHARG = V_CHARG
      IMPORTING
        PDATE = V_POSTDATE.


    IF SY-SUBRC = 0.
      "MANUF DATE
      IF ( V_LABELTYPE = 'PLA134' OR V_LABELTYPE = 'PLA142' OR V_LABELTYPE = 'PLA145'
           OR V_LABELTYPE = 'PLA137' OR V_LABELTYPE = 'PLJ129'). "Added by AKBAR 09.01.2019 (Type A137 & J129)
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_POSTDATE+0(4) '.' V_POSTDATE+4(2) INTO V_TAB-ATWTB.
        APPEND V_TAB.
      ELSE.
        IF V_LIVE <> ''.
          V_EXPDATE = V_POSTDATE + V_LIVE.
          V_TAB-ATNAM = 'ZZEX'.
          CONCATENATE V_EXPDATE+0(4) '.' V_EXPDATE+4(2) INTO V_TAB-ATWTB.
          APPEND V_TAB.
        ENDIF.
      ENDIF.
    ENDIF.

  ELSE.
*Roll no and barcode roll no.
    V_TAB-ATNAM = 'ZZROLLNO'.
    V_TAB-ATWTB = V_ROLLNO.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBCROLL'.
    V_TAB-ATWTB = V_CHARG.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBARC'.
    V_TAB-ATWTB = V_CHARG.
    APPEND V_TAB.



  ENDIF.



**EX value
*  v_tab-atnam = 'ZZEX'.
*  v_tab-atwtb = 'EX'.
*  APPEND v_tab.

*Getting the data atnam from table zlabel.
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE V_ZLABEL
  FROM ZLABEL.

* Do the conversion...
  CLEAR : V_S_INCH,
          V_S_GAUGE,
          V_S_FEET,
          V_S_LBS,
          V_S_SPLICE1,
          V_S_SPLICE2.

* Loop zlabel for conversion (Inch, Feet, Lbs, Gauge)
* And update the data which is not the conversion's value...
* Conversion value will be transfer to text file after this looping condition...
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

* Set conversion & Right Justified...
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
        IF V_LABELORIG <> 'A137' AND V_LABELORIG <> 'J129'. "Added by FATHIR 18.01.2019 (Type A137 & J129)
          V_S_GAUGE = V_T2.
        ELSE.
          WRITE V_GAUGE TO V_S_GAUGE.
        ENDIF.

        V_THICKNESS = V_TAB-ATWTB.

*For Alias
        CONDENSE V_THICKNESS NO-GAPS.

        CONCATENATE V_THICKNESS ' mic.  ' V_S_GAUGE ' ga.' INTO V_INFO_THICKNESS.

        V_TAB-ATWTB = ''.
        V_S_GAUGE = ''.

      ENDIF.

* Get The Width value(MM -> Inch)
      IF V_ZLABEL-ATNAM = 'ZZWIDTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_WIDTH .
        ENDIF.

        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        V_INCH =   V_TAB-ATWTB * V_C_INCH.
        IF V_LABELORIG <> 'A137' AND V_LABELORIG <> 'J129'. "Added by AKBAR 18.01.2019 (Type A137 & J129)
          V_S_INCH = V_W2.
        ELSE.
          WRITE V_INCH TO V_S_INCH.
        ENDIF.
        V_WIDTH = V_TAB-ATWTB.
        WRITE V_WIDTH TO V_TAB-ATWTB.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_WIDTH
                                      V_TAB-ATWTB.
      ENDIF.

* Get The Length Value(M -> Feet)

      IF V_ZLABEL-ATNAM = 'ZZLENGTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_LENGT.
        ENDIF.

        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        V_FEET   = V_TAB-ATWTB * V_C_FEET.
        IF V_LABELORIG <> 'A137' AND V_LABELORIG <> 'J129'. "Added by AKBAR 18.01.2019 (Type A137 & J129)
          V_S_FEET = V_L2.
        ELSE.
          WRITE V_FEET TO V_S_FEET.
        ENDIF.
        V_LENGTH = V_TAB-ATWTB.
        WRITE V_LENGTH TO V_TAB-ATWTB.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_LENGTH
                                       V_TAB-ATWTB.

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
        REPLACE ALL OCCURRENCES OF ',' IN V_N2 WITH ''.
        V_LBS = V_N2 * V_TOT_ROLL.
        WRITE V_LBS TO V_S_LBS.
        V_WEIGHT = V_TAB-ATWTB.
        WRITE V_WEIGHT TO V_TAB-ATWTB.
*mode 3 decimal
        PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT "v_len_normal
                                      V_TAB-ATWTB.
      ENDIF.

*Get The Splices At 1st Value(M -> Feet)
      IF V_ZLABEL-ATNAM = 'ZZSPLICE-1'.
      ENDIF.

*Get The Splices At 2nd Value(M -> Feet)
      IF V_ZLABEL-ATNAM = 'ZZSPLICE-2'.
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

*---
    ELSEIF V_ZLABEL-ATNAM = 'ZZODR'.
      DATA: V_BSTKD_E LIKE VBKD-BSTKD_E,
            V_CHAR10 TYPE N LENGTH 10.  "like vbak-vbeln.

      V_CHAR10 = V_VBELN.

*      IF V_LABELORIG = 'J120' OR V_LABELORIG = 'J121' OR V_LABELORIG = 'A305' OR V_LABELORIG = 'A308' OR
*         V_LABELORIG = 'J122' OR V_LABELORIG = 'J123' OR V_LABELORIG = 'A309' OR
*         V_LABELORIG = 'B215 ' OR V_LABELORIG = 'B216 ' OR V_LABELORIG = 'B223' OR
*         V_LABELORIG = 'D213' OR V_LABELORIG = 'D214' OR V_LABELORIG = 'D219'.
*
*        SELECT SINGLE BSTKD_E INTO V_BSTKD_E FROM VBKD WHERE VBELN = V_CHAR10.
*
*        IF SY-SUBRC = 0.
**            CONCATENATE '<STX><ESC>' v_zlabel-data1 v_bstkd '<ETX>' INTO text_data-str_text.
*          V_ZLABEL-DATA2 = V_BSTKD_E.
*        ENDIF.
*      ENDIF.

*---
    ELSE.
      V_ZLABEL-DATA2 = ' '.
    ENDIF.

    MODIFY V_ZLABEL INDEX V_TABIX TRANSPORTING DATA2.
  ENDLOOP.

*/---Added on 150405---
*cek previouly label

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

      " Start add by Fiqih 27.03.2026 (tambahkan teks RTP jika menggunakan Pallet RTP)
      " 1. Eksekusi Subroutine (Hanya membuat baris baru)
      IF GV_IS_RTP = 'X'.
        LV_SHIFT_UP = 15. " P_SHIFT_UP (Naikkan Pallet No 20 dots)
        LV_GAP_DOWN = 30. " P_GAP_DOWN (Jarak RTP 50 dots ke bawah)
        PERFORM ADJUST_AND_INJECT_TEXT USING    'Pallet No.:'           " P_ANCHOR (Teks yg dicari)
                                                'Returnable Packaging'  " P_INJECT (Teks yg diinjeksi)
                                                'H199,TXT199'           " P_NEW_ID (ID unik TXT baru)
                                                LV_SHIFT_UP             " P_SHIFT_UP (Naikkan Pallet No 20 dots)
                                                LV_GAP_DOWN             " P_GAP_DOWN (Jarak RTP 50 dots ke bawah)
                                       CHANGING TEXT_DATA-STR_TEXT
                                                LV_INJECT_STR.
      ENDIF.

      " 2. APPEND BARIS ORIGINAL (Teks Pallet No.: yg sudah naik)
      APPEND TEXT_DATA.

      " 3. APPEND BARIS BARU (Teks RTP) KE TEXT_DATA
      IF LV_INJECT_STR IS NOT INITIAL.
        TEXT_DATA-STR_TEXT = LV_INJECT_STR.
        APPEND TEXT_DATA.     " Tambahkan Baris text RTP ke TEXT_DATA
        CLEAR LV_INJECT_STR.  " Bersihkan agar tidak ikut ke-append di loop berikutnya
      ENDIF.
      " End add by Fiqih 27.03.2026 (tambahkan teks RTP jika menggunakan Pallet RTP)

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
        IF V_LABELTYPE = 'PLA304' OR V_LABELTYPE = 'PLA305'.
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
      ELSE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ENDIF.

      APPEND TEXT_DATA.
    ENDLOOP.

*  add customer part number
    IF V_LABELTYPE = 'PLA134' OR V_LABELTYPE = 'PLA142' OR V_LABELTYPE = 'PLA145'.
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
      ENDIF.
    ELSEIF V_LABELORIG = 'A137' OR  V_LABELORIG = 'J129'.
      "untuk mengambil data Special Touch 1 - 3

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
        IF V_LABELTYPE = 'PLA137' OR V_LABELTYPE = 'PLA137'.
           CONCATENATE '<STX><ESC>F"BPART  "<LF>' V_STOUCH3 '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
        ENDIF.
        IF V_PARTNO NE ''.
           CONCATENATE '<STX><ESC>F"SKU  "<LF>' V_PARTNO '<ETX>' '' INTO TEXT_DATA-STR_TEXT.   APPEND TEXT_DATA. "Added by Fany 20-11-2024
        ENDIF.
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
  CONCATENATE FILE_DIR  'DATA' '.BAT' INTO FILE_B.

*mark diffrent label
  V_LABELIMGOLD = V_LABELIMGNEW.

ENDFORM.                    " inchi_text_data


*&---------------------------------------------------------------------*
*&      Form  GET_INCHI
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