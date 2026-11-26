*&---------------------------------------------------------------------*
*&      Form  sampoerna_text_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAMPOERNA_TEXT_DATA.

  DATA : FILE_DIR TYPE STRING VALUE '/spare/saplabel/'.
* // Data for Convert Value
  DATA : V_GAUGE  TYPE P,
*mode 2 dec - 5 digit
         V_S_GAUGE(5),
         V_S_GAUGE_INTER(40),
         V_INCH  TYPE P DECIMALS 2 ,
         V_S_INCH(6),
         V_S_WIDTH(4),
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

*Sampoerna
  DATA: ICHARAC TYPE CUXE1CUVAL OCCURS 0 WITH HEADER LINE,
        WA_STOUCH1 LIKE AUSP-ATWRT,
        WA_STOUCH2 LIKE AUSP-ATWRT,
        WA_STOUCH3 LIKE AUSP-ATWRT,
        V_BATCHNO(30),
        V_BCROLL(152),
        V_CUOBJ LIKE VBAP-CUOBJ.


* Get SO NUmber and Item from last Batch
  CLEAR : V_VBELN, V_POSNR, V_SONUM_ITEM, V_CUOBJ.

  SELECT SINGLE VBELN POSNR  INTO (V_VBELN, V_POSNR)
  FROM MSKA
  WHERE  MATNR = V_MATNR AND  WERKS = V_WERKS AND
         CHARG = V_CHARG AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 ).

  IF SY-SUBRC NE 0.

*set pop up to get data SONUM.
    DATA: L_ANSWER, L_VALUE1 LIKE SPOP-VARVALUE1.

    DO.
      CALL FUNCTION 'POPUP_TO_GET_ONE_VALUE'
        EXPORTING
          TEXTLINE1   = 'Untuk mendapatkan data Special Touch'
          TEXTLINE2   = 'Masukkan Nomor SONUM'
          TEXTLINE3   = '(SO dan Item Number)'
          TITEL       = 'Batch sudah tidak terikat pada SO'
          VALUELENGTH = 16
        IMPORTING
          ANSWER      = L_ANSWER
          VALUE1      = L_VALUE1.
      IF L_ANSWER = 'J'.
        V_VBELN = L_VALUE1+0(10).
        V_POSNR = L_VALUE1+10(6).
        EXIT.
        MESSAGE 'Data SONUM Kosong, data special touch tidak akan terambil.' TYPE 'I'.
      ELSE.
        MESSAGE 'Silahkan tekan tombol CONTINUE.' TYPE 'I'.
      ENDIF.
    ENDDO.
  ENDIF.

  IF V_VBELN NE ''.

    SELECT SINGLE CUOBJ INTO V_CUOBJ
    FROM VBAP
    WHERE
    VBELN EQ V_VBELN AND
    POSNR EQ V_POSNR.

*Get SO Characteristics
    REFRESH ICHARAC.
    IF SY-SUBRC = 0.

      CALL FUNCTION 'MILL_SE_GET_CHAR_AND_VALUE'
        EXPORTING
          INSTANCE                = V_CUOBJ
        TABLES
          ET_VALUE                = ICHARAC
        EXCEPTIONS
          MATERIAL_HAS_NO_PROFIL  = 1
          NO_CONFIGURATION_PARAMS = 2
          FATAL_ERROR             = 3
          OTHERS                  = 4.

      LOOP AT ICHARAC.
        REPLACE ALL OCCURRENCES OF ',' IN ICHARAC-VALUE WITH ''.
        CONDENSE ICHARAC-VALUE NO-GAPS.

        CASE ICHARAC-CHARC.
          WHEN 'ZZCODE'.

          WHEN 'ZZSPECIALTOUCH-1'.
            WA_STOUCH1  = ICHARAC-VALUE.
          WHEN 'ZZSPECIALTOUCH-2'.
            WA_STOUCH2  = ICHARAC-VALUE.
          WHEN 'ZZSPECIALTOUCH-3'.
            WA_STOUCH3  = ICHARAC-VALUE_TXT.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDIF.


  CLEAR :
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
*    LOOP AT v_tab.
*      IF v_tab-atnam = 'ZZDERIVATIVEMS'.
*        v_derivativems = v_tab-atwrt.
*      ELSEIF v_tab-atnam = 'ZZPOSITIONMS'.
*        v_positionms = v_tab-atwrt.
*      ELSEIF v_tab-atnam = 'ZZDERIVATIVESS'.
*        v_derivativess = v_tab-atwrt.
*      ELSEIF v_tab-atnam = 'ZZPOSITIONSS'.
*        v_positionss = v_tab-atwrt.
*      ENDIF.
*    ENDLOOP.

*    IF v_der = 'W'.
*      SELECT SINGLE derivativems positionms derivativess positionss grade length1 length2 zconv
*      INTO (v_derivativems, v_positionms, v_derivativess, v_positionss, v_grade, v_splice1_d, v_splice2_d, v_zconv)
*      FROM zdigitctl
*      WHERE
*      zdigitctl~aufnr EQ v_aufnr AND
*      zdigitctl~positionss EQ v_pos.
*    ELSEIF v_der = 'M'.
*      SELECT SINGLE derivativems positionms derivativess positionss grade length1 length2 zconv
*      INTO (v_derivativems, v_positionms, v_derivativess, v_positionss, v_grade, v_splice1_d, v_splice2_d, v_zconv)
*      FROM zdigitctl
*      WHERE
*      zdigitctl~aufnr EQ v_aufnr AND
*      zdigitctl~positionms EQ v_pos.
*    ENDIF.
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

    V_TAB-ATNAM = 'ZZBARC'.
*    v_tab-atwtb = v_charg.
    V_TAB-ATWTB = V_BARCODE.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBARC1'.
*--- set SONUM as batch number for PMI and Sampoerna
*    v_tab-atwtb = v_charg.
    CONCATENATE V_VBELN V_POSNR+1(5) INTO V_TAB-ATWTB.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBARC2'.
    V_TAB-ATWTB = V_CHARG.
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
      V_TAB-ATNAM = 'ZZEX'.
      CONCATENATE V_POSTDATE+6(2) '/' V_POSTDATE+4(2) '/' V_POSTDATE+0(4) INTO V_TAB-ATWTB.
      APPEND V_TAB.

*--- set SONUM as batch number for PMI and Sampoerna
*      CONCATENATE '0000' wa_stouch1 v_postdate+6(2) v_postdate+4(2) v_postdate+2(2) '000000' v_charg 'A' INTO v_bcroll.
      CONCATENATE '0000' WA_STOUCH1 V_POSTDATE+6(2) V_POSTDATE+4(2) V_POSTDATE+2(2) '000000' V_VBELN V_POSNR+1(5) 'A' INTO V_BCROLL.

    ENDIF.


*WOP Number
    V_TAB-ATNAM = 'ZZLOTNUMBER'.
    V_TAB-ATWTB = WA_STOUCH1.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZTEXT1'.
    V_TAB-ATWTB = WA_STOUCH2.
    APPEND V_TAB.



*Mod Left Justified
* Clear
    CLEAR : V_S_SPLICE1,
            V_S_SPLICE2.

    V_TAB-ATNAM = 'ZZSPLICE-1'.
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

*          v_s_splice1,
*          v_s_splice2.

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
        CONDENSE V_TAB-ATWTB NO-GAPS.
      ENDIF.
*Mod Left Justified

      IF V_ZLABEL-ATNAM = 'ZZLENGTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_LENGT.
        ENDIF.


        REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
        CONDENSE V_TAB-ATWTB NO-GAPS.

      ENDIF.


** Get The NetWeight Value(KG -> LBS)
      IF V_ZLABEL-ATNAM = 'ZZWEIGH' OR V_ZLABEL-ATNAM = 'ZZWEIGHT'.
        V_TAB-ATWTB = ''.
      ENDIF.


*Core Left Justified
      IF V_ZLABEL-ATNAM = 'ZZCORE'.
        V_TAB-ATWTB = ''.
      ENDIF.

      IF V_ZLABEL-ATNAM = 'ZZINSIDE' OR V_ZLABEL-ATNAM = 'ZZOUTSIDE'.
        V_TAB-ATWTB = ''.
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
      IF V_ZLABEL-ATNAM = 'ZZWIDTH'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 ' mm' '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZLENGTH'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 ' m' '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZBCROLL'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_BCROLL '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZFEETS1'.

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

* case of label type K102-103 change text WRAPPING FILM with special touch-3
  READ TABLE TEXT_DATA WITH KEY STR_TEXT = '<STX>H5;o1050,110;f0;c20;h1;w1;d3,WRAPPING FILM ;<ETX>'.
  IF SY-SUBRC = 0.
    REPLACE ALL OCCURRENCES OF 'WRAPPING FILM' IN TEXT_DATA-STR_TEXT WITH WA_STOUCH3.
    MODIFY TEXT_DATA TRANSPORTING STR_TEXT WHERE STR_TEXT = '<STX>H5;o1050,110;f0;c20;h1;w1;d3,WRAPPING FILM ;<ETX>' .
  ENDIF.

*get data filename.
  CONCATENATE PFN 'DATA' '.DAX' INTO FILE_D.
*get format filename.
  CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.
*get batch filename.
  CONCATENATE FILE_DIR  'DATA' '.BAT' INTO FILE_B.

*mark diffrent label
  V_LABELIMGOLD = V_LABELIMGNEW.


ENDFORM.                    "sampoerna_text_data



*********************************************
*--- Philip Morris
*********************************************
FORM PM_TEXT_DATA.

  DATA : FILE_DIR TYPE STRING VALUE '/spare/saplabel/'.
* // Data for Convert Value
  DATA : V_GAUGE  TYPE P,
*mode 2 dec - 5 digit
         V_S_GAUGE(5),
         V_S_GAUGE_INTER(40),
         V_INCH  TYPE P DECIMALS 2 ,
         V_S_INCH(6),
         V_S_WIDTH(4),
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

*Sampoerna
  DATA: ICHARAC TYPE CUXE1CUVAL OCCURS 0 WITH HEADER LINE,
        WA_STOUCH1 LIKE AUSP-ATWRT,
        WA_STOUCH2 LIKE AUSP-ATWRT,
        WA_STOUCH3 LIKE AUSP-ATWRT,
        V_BATCHNO(30),
        V_BCROLL(152),
        V_CUOBJ LIKE VBAP-CUOBJ,
        V_KDMAT LIKE VBAP-KDMAT.

* Get SO NUmber and Item from last Batch
  CLEAR : V_VBELN, V_POSNR, V_SONUM_ITEM, V_CUOBJ.

  SELECT SINGLE VBELN POSNR
  INTO (V_VBELN, V_POSNR)
  FROM MSKA
  WHERE  MATNR = V_MATNR AND  CHARG = V_CHARG AND
         ( KALAB > 0 OR  KAINS > 0 OR  KASPE > 0 ).

  IF SY-SUBRC NE 0.

*set pop up to get data SONUM.
    DATA: L_ANSWER, L_VALUE1 LIKE SPOP-VARVALUE1.

    DO.
      CALL FUNCTION 'POPUP_TO_GET_ONE_VALUE'
        EXPORTING
          TEXTLINE1   = 'Untuk mendapatkan data Special Touch'
          TEXTLINE2   = 'Masukkan Nomor SONUM'
          TEXTLINE3   = '(SO dan Item Number)'
          TITEL       = 'Batch sudah tidak terikat pada SO'
          VALUELENGTH = 16
        IMPORTING
          ANSWER      = L_ANSWER
          VALUE1      = L_VALUE1.
      IF L_ANSWER = 'J'.
        V_VBELN = L_VALUE1+0(10).
        V_POSNR = L_VALUE1+10(6).
        EXIT.
        MESSAGE 'Data SONUM Kosong, data special touch tidak akan terambil.' TYPE 'I'.
      ELSE.
        MESSAGE 'Silahkan tekan tombol CONTINUE.' TYPE 'I'.
      ENDIF.
    ENDDO.
  ENDIF.

  IF V_VBELN NE ''.
    SELECT SINGLE CUOBJ KDMAT INTO (V_CUOBJ, V_KDMAT)
    FROM VBAP
    WHERE VBELN EQ V_VBELN AND POSNR EQ V_POSNR.

*Get SO Characteristics
    REFRESH ICHARAC.
    IF SY-SUBRC = 0.

      CALL FUNCTION 'MILL_SE_GET_CHAR_AND_VALUE'
        EXPORTING
          INSTANCE                = V_CUOBJ
        TABLES
          ET_VALUE                = ICHARAC
        EXCEPTIONS
          MATERIAL_HAS_NO_PROFIL  = 1
          NO_CONFIGURATION_PARAMS = 2
          FATAL_ERROR             = 3
          OTHERS                  = 4.

      LOOP AT ICHARAC.
        REPLACE ALL OCCURRENCES OF ',' IN ICHARAC-VALUE WITH ''.
        CONDENSE ICHARAC-VALUE NO-GAPS.

        CASE ICHARAC-CHARC.
          WHEN 'ZZCODE'.

          WHEN 'ZZSPECIALTOUCH-1'.
            WA_STOUCH1  = ICHARAC-VALUE_TXT.
          WHEN 'ZZSPECIALTOUCH-2'.
*            wa_stouch2  = icharac-value_txt.
            SPLIT ICHARAC-VALUE_TXT AT ';' INTO WA_STOUCH2 ICHARAC-VALUE_TXT.
          WHEN 'ZZSPECIALTOUCH-3'.
            WA_STOUCH3  = ICHARAC-VALUE_TXT.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDIF.


  CLEAR :
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
*    LOOP AT v_tab.
*      IF v_tab-atnam = 'ZZDERIVATIVEMS'.
*        v_derivativems = v_tab-atwrt.
*      ELSEIF v_tab-atnam = 'ZZPOSITIONMS'.
*        v_positionms = v_tab-atwrt.
*      ELSEIF v_tab-atnam = 'ZZDERIVATIVESS'.
*        v_derivativess = v_tab-atwrt.
*      ELSEIF v_tab-atnam = 'ZZPOSITIONSS'.
*        v_positionss = v_tab-atwrt.
*      ENDIF.
*    endloop.

*    IF v_der = 'W'.
*      SELECT SINGLE derivativems positionms derivativess positionss grade length1 length2 zconv
*      INTO (v_derivativems, v_positionms, v_derivativess, v_positionss, v_grade, v_splice1_d, v_splice2_d, v_zconv)
*      FROM zdigitctl
*      WHERE
*      zdigitctl~aufnr EQ v_aufnr AND
*      zdigitctl~positionss EQ v_pos.
*    ELSEIF v_der = 'M'.
*      SELECT SINGLE derivativems positionms derivativess positionss grade length1 length2 zconv
*      INTO (v_derivativems, v_positionms, v_derivativess, v_positionss, v_grade, v_splice1_d, v_splice2_d, v_zconv)
*      FROM zdigitctl
*      WHERE
*      zdigitctl~aufnr EQ v_aufnr AND
*      zdigitctl~positionms EQ v_pos.
*    ENDIF.
  ENDIF.

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

*Get Net weight...
  PERFORM GET_NET_WEIGHT.

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
    V_TAB-ATNAM = 'ZZLENGTH'.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
  ELSE.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
  ENDIF.
*----------------------/


  IF V_DERIVATIVESS = '00'.
    V_DERIVATIVESS = ''.
  ENDIF.

  IF V_POSITIONSS = '00'.
    V_POSITIONSS = ''.
  ENDIF.

*--- add by ALF for label K130
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
  IF SY-SUBRC = 0 AND V_TAB-ATWRT = 'K130'.
    CONCATENATE V_PRODLINE V_CODE V_MONTHYEAR V_SEQUENCENBR V_GRADE V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS V_POSITIONSS
    INTO V_ROLLNO.
  ELSE.
    CONCATENATE V_PRODLINE V_CODE V_MONTHYEAR V_SEQUENCENBR V_GRADE V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS V_POSITIONSS
    INTO V_ROLLNO
    SEPARATED BY SPACE.
  ENDIF.

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

    V_TAB-ATNAM = 'ZZBARC'.
*    v_tab-atwtb = v_charg.
    V_TAB-ATWTB = V_BARCODE.
    APPEND V_TAB.

*Expired Date
    CLEAR: V_POSTDATE.
*    SELECT SINGLE ERSDA INTO V_POSTDATE FROM MCH1 WHERE CHARG EQ V_CHARG AND MATNR EQ V_MATNR.
    CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
      EXPORTING
        MATNR = V_MATNR
        CHARG = V_CHARG
      IMPORTING
        PDATE = V_POSTDATE.

*    v_tab-atwtb = v_charg.
    READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
    V_TAB-ATNAM = 'ZZBARC1'.
    IF SY-SUBRC = 0 AND ( V_TAB-ATWRT = 'K140' OR V_TAB-ATWRT = 'K150' OR V_TAB-ATWRT = 'K160' ). "PMI
*      concatenate v_vbeln+4(6) v_Posnr+3(2) '-' v_postdate+6(2) v_postdate+4(2) v_postdate+2(2) into v_tab-atwtb.
*      CONCATENATE WA_STOUCH1+4(6) WA_STOUCH1+13(2) '-' V_POSTDATE+6(2) V_POSTDATE+4(2) V_POSTDATE+2(2) INTO V_TAB-ATWTB.
      CONCATENATE WA_STOUCH1+4(6) WA_STOUCH1+13(2) IT_CHARG-CHARG+3(7) INTO V_TAB-ATWTB.
    ELSE.
      CONCATENATE V_VBELN V_POSNR+1(5) INTO V_TAB-ATWTB.
    ENDIF.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZBARC2'.
    V_TAB-ATWTB = V_CHARG.
    APPEND V_TAB.

*    IF sy-subrc = 0.
    READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
    V_TAB-ATNAM = 'ZZEX'.
    IF SY-SUBRC = 0 AND ( V_TAB-ATWRT = 'K140' OR V_TAB-ATWRT = 'K150' OR V_TAB-ATWRT = 'K160' ).  "PMI
      CONCATENATE V_POSTDATE+6(2) '.' V_POSTDATE+4(2) '.' V_POSTDATE+0(4) INTO V_TAB-ATWTB.
    ELSE.
      CONCATENATE V_POSTDATE+6(2) '/' V_POSTDATE+4(2) '/' V_POSTDATE+0(4) INTO V_TAB-ATWTB.
    ENDIF.
    APPEND V_TAB.

*      v_tab-atnam = 'ZZBCROLL'.
*      CONCATENATE '0000' wa_stouch1 v_postdate+6(2) v_postdate+4(2) v_postdate+2(2) '000000' v_charg 'A' INTO v_bcroll.

*--- add by ALF for label K140 and K150 (PMI Bekasi)
    READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
    IF SY-SUBRC = 0 AND ( V_TAB-ATWRT = 'K140' OR V_TAB-ATWRT = 'K150' OR V_TAB-ATWRT = 'K160' ).
*      CONCATENATE wa_stouch1 v_postdate+6(2) v_postdate+4(2) v_postdate+2(2) '037832' v_vbeln+4(6) v_Posnr+3(2)
      CONCATENATE V_KDMAT V_POSTDATE+6(2) V_POSTDATE+4(2) V_POSTDATE+2(2) '037832' WA_STOUCH1+4(6) WA_STOUCH1+13(2)
                   IT_CHARG-CHARG+3(7) 'A' INTO V_BCROLL.
*                  '-' V_POSTDATE+6(2) V_POSTDATE+4(2) V_POSTDATE+2(2)
*      'A' INTO V_BCROLL.
      REPLACE ALL OCCURRENCES OF '.' IN V_BCROLL WITH ''.
    ELSE.
      CONCATENATE WA_STOUCH1 V_POSTDATE+6(2) V_POSTDATE+4(2) V_POSTDATE+2(2) V_VBELN V_POSNR+1(5) 'A' INTO V_BCROLL.
      REPLACE ALL OCCURRENCES OF '.' IN V_BCROLL WITH ''.
    ENDIF.
*    ENDIF.


*WOP Number
    V_TAB-ATNAM = 'ZZLOTNUMBER'.
    V_TAB-ATWTB = V_KDMAT. "wa_stouch1.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZTEXT1'.
    V_TAB-ATWTB = WA_STOUCH2.
    APPEND V_TAB.



*Mod Left Justified
* Clear
    CLEAR : V_S_SPLICE1,
            V_S_SPLICE2.

    V_TAB-ATNAM = 'ZZSPLICE-1'.
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

*          v_s_splice1,
*          v_s_splice2.

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
        CONDENSE V_TAB-ATWTB NO-GAPS.
      ENDIF.
*Mod Left Justified
* Get The Length Value(M -> Feet)

      IF V_ZLABEL-ATNAM = 'ZZLENGTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_LENGT.
        ENDIF.


        REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
        CONDENSE V_TAB-ATWTB NO-GAPS.

      ENDIF.



** Get The NetWeight Value(KG -> LBS)
      IF V_ZLABEL-ATNAM = 'ZZWEIGH' OR V_ZLABEL-ATNAM = 'ZZWEIGHT'.
        V_TAB-ATWTB = ''.
      ENDIF.
*
*Core Left Justified
      IF V_ZLABEL-ATNAM = 'ZZCORE'.
        V_TAB-ATWTB = ''.
      ENDIF.

      IF V_ZLABEL-ATNAM = 'ZZINSIDE' OR V_ZLABEL-ATNAM = 'ZZOUTSIDE'.
        V_TAB-ATWTB = ''.
      ENDIF.


*Type
      IF V_ZLABEL-ATNAM = 'ZZTYPE'.
*--- PMI tidak perlu TYPE
        CLEAR V_TAB-ATWTB.
*        IF v_flag_zzalias <> 'X'.
*
*          CONCATENATE v_tab-atwrt  v_thickness INTO v_tab-atwtb SEPARATED BY '-' .
*          CONDENSE v_tab-atwtb NO-GAPS.
*        ELSE.
*          WRITE v_tab-atwrt TO v_tab-atwtb.
*        ENDIF.
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
      IF V_ZLABEL-ATNAM = 'ZZWIDTH'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 ' mm' '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZLENGTH'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 ' m' '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZBCROLL'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_BCROLL '<ETX>' INTO TEXT_DATA-STR_TEXT.
      ELSEIF V_ZLABEL-ATNAM = 'ZZFEETS1'.
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

  READ TABLE TEXT_DATA WITH KEY STR_TEXT = '<STX>H5;o1050,110;f0;c20;h1;w1;d3,WRAPPING FILM ;<ETX>'.
  IF SY-SUBRC = 0.
    REPLACE ALL OCCURRENCES OF 'WRAPPING FILM' IN TEXT_DATA-STR_TEXT WITH WA_STOUCH3.
    MODIFY TEXT_DATA TRANSPORTING STR_TEXT WHERE STR_TEXT = '<STX>H5;o1050,110;f0;c20;h1;w1;d3,WRAPPING FILM ;<ETX>' .
  ENDIF.

*get data filename.
  CONCATENATE PFN 'DATA' '.DAX' INTO FILE_D.
*get format filename.
  CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.
*get batch filename.
  CONCATENATE FILE_DIR  'DATA' '.BAT' INTO FILE_B.

*mark diffrent label
  V_LABELIMGOLD = V_LABELIMGNEW.


ENDFORM.                    "sampoerna_text_data