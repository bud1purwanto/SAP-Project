
*&---------------------------------------------------------------------*
*&      Form  prima_text_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PRIMA_TEXT_DATA.
*Start Code
  DATA : TEXT1(100) TYPE C,
         TEXT2(100) TYPE C.
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

*zztype + thickness...
*    IF v_tab-atnam = 'ZZTHICKNESS'.
*      v_thickness = v_tab-atwtb.
*    ENDIF.

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

**For Roll Expired Live
*    IF v_tab-atnam = 'ZZEXPIREDLIVE'.
*      	v_live = ''.
*      v_live = v_tab-atwtb.
*    ENDIF.


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

*    IF v_derivativems = '00'.
*      v_derivativems = ''.
*    ENDIF.
*
*    IF v_positionms = '00'.
*      v_positionms = ''.
*    ENDIF.

  IF V_DERIVATIVESS = '00'.
    V_DERIVATIVESS = ''.
  ENDIF.

  IF V_POSITIONSS = '00'.
    V_POSITIONSS = ''.
  ENDIF.

  CONCATENATE V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS V_POSITIONSS INTO V_ROLLNO.

*ROll No Using Batch and derivatime/position ex. 000000001 - 01010202
  CONCATENATE V_CHARG '-' V_ROLLNO INTO V_ROLLNO SEPARATED BY SPACE.


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
    V_TAB-ATWTB = V_BARCODE.
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

**Add Expired Date
*      SELECT SINGLE ersda INTO v_postdate FROM mch1 WHERE charg EQ v_charg.
*
*
*      IF sy-subrc = 0.
*        IF v_live <> ''.
*          v_expdate = v_postdate + v_live.
*          v_tab-atnam = 'ZZEX'.
*          CONCATENATE v_expdate+6(2) '/' v_expdate+4(2) '/' v_expdate+0(4) INTO v_tab-atwtb.
*          APPEND v_tab.
*        ENDIF.
*      ENDIF.

* Clear
*    clear : v_s_splice1,
*            v_s_splice2.
*
*    v_tab-atnam = 'ZZSPLICE-1'.
*Get The Splices At 1st Value(M -> Feet)

*PrimaPack No Splice at all

*    perform conv_to_char using v_splice1_d.
*    v_splice1 = v_splice1_d * v_c_feet.
*    write v_splice1 to v_s_splice1.
*    v_splice1_miring = v_splice1_d.
*    write v_splice1_miring to v_tab-atwtb.
*    perform right_justified using v_len_normal
*                                  v_tab-atwtb.
*
*    append v_tab.

*    v_tab-atnam = 'ZZSPLICE-2'.
*Get The Splices At 2nd Value(M -> Feet)

*PrimaPack
*    perform conv_to_char using v_splice2_d.
*    v_splice2 = v_splice2_d * v_c_feet.
*    write v_splice2 to v_s_splice2.
*    v_splice2_miring = v_splice2_d.
*    write v_splice2_miring to v_tab-atwtb.
*    perform right_justified using v_len_normal
*                                  v_tab-atwtb.
*    append v_tab.
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
        WRITE V_GAUGE TO V_S_GAUGE.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_MIC
                                      V_TAB-ATWTB.
        V_THICKNESS = V_TAB-ATWTB.

*//orig on 27-06-05
*        SPLIT v_tab-atwtb AT v_dot INTO v_tab-atwtb v_1.
*        PERFORM conv_to_char USING v_tab-atwtb.
*        REPLACE ALL OCCURRENCES OF '.0' IN v_tab-atwtb WITH ' '.
*
*        v_gauge = v_tab-atwtb * v_c_gauge.
*        WRITE v_gauge TO v_s_gauge.
*        PERFORM right_justified USING v_len_mic
*                                      v_tab-atwtb.
*        v_thickness = v_tab-atwtb.

      ENDIF.

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
        WRITE V_WIDTH TO V_WIDTH_SS.
        WRITE V_WIDTH TO V_TAB-ATWTB.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_TAB-ATWTB.
      ENDIF.

* Get The Length Value(M -> Feet)

      IF V_ZLABEL-ATNAM = 'ZZLENGTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_LENGT.
        ENDIF.

*PrimaPack

        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        WRITE V_TAB-ATWTB TO V_LENGTH_SS.

        V_FEET   = V_TAB-ATWTB * V_C_FEET.
        WRITE V_FEET TO V_S_FEET.
        V_LENGTH = V_TAB-ATWTB.
        WRITE V_LENGTH TO V_TAB-ATWTB.
        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_TAB-ATWTB.
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
        WRITE V_WEIGHT TO V_WEIGHT_SS.
*mode 3 decimal
        PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT "v_len_normal
                                      V_TAB-ATWTB.
      ENDIF.


*core
      IF V_ZLABEL-ATNAM = 'ZZCORE'.

        IF ( V_LABELTYPE EQ 'A009' ) AND ( SY-TCODE NE 'VL74'  OR SY-TCODE NE 'ZHU005' ).
*Prima Pack
          WRITE V_TAB-ATWRT TO V_TAB-ATWTB.
          CONCATENATE V_TAB-ATWRT '"' INTO V_CORE_SS.
        ELSE.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_CORE
                                            V_TAB-ATWTB.
        ENDIF.
      ENDIF.

*Inside & Outside
      IF V_ZLABEL-ATNAM = 'ZZINSIDE'.
        IF ( V_LABELTYPE EQ 'A009' ) AND ( SY-TCODE NE 'VL74'  OR SY-TCODE NE 'ZHU005' ).
*Prima Pack
          TRANSLATE V_TAB-ATWTB TO LOWER CASE.
          IF V_TAB-ATWTB <> 'none'.
            TRANSLATE V_TAB-ATWTB TO LOWER CASE.
            WRITE V_TAB-ATWTB TO V_TREAT_SS.
            CONCATENATE 'inside' V_TREAT_SS INTO V_TREAT_SS SEPARATED BY SPACE.
          ENDIF.
        ELSE.
          PERFORM RIGHT_JUSTIFIED_NO_GAP USING V_LEN_IN_OUT
                                           V_TAB-ATWTB.
        ENDIF.
      ENDIF.

      IF V_ZLABEL-ATNAM = 'ZZOUTSIDE'.
        IF ( V_LABELTYPE EQ 'A009' ) AND ( SY-TCODE NE 'VL74'  OR SY-TCODE NE 'ZHU005' ).
*Prima Pack
          TRANSLATE V_TAB-ATWTB TO LOWER CASE.
          IF V_TAB-ATWTB <> 'none'.
            TRANSLATE V_TAB-ATWTB TO LOWER CASE.
            WRITE V_TAB-ATWTB TO V_TREAT_SS.
            CONCATENATE 'outside' V_TREAT_SS INTO V_TREAT_SS SEPARATED BY SPACE.
          ENDIF.
        ELSE.
          PERFORM RIGHT_JUSTIFIED_NO_GAP USING V_LEN_IN_OUT
                                           V_TAB-ATWTB.
        ENDIF.
      ENDIF.


*Type
      IF V_ZLABEL-ATNAM = 'ZZTYPE'.
        IF V_FLAG_ZZALIAS <> 'X'.

          CONCATENATE V_TAB-ATWRT  V_THICKNESS INTO V_TAB-ATWTB SEPARATED BY '-' .
          CONDENSE V_TAB-ATWTB NO-GAPS.
        ELSE.
*Mod for BOPP Heatseal Clear
          IF V_TAB-ATWRT EQ 'BOPP HEATSEAL CLEAR'.
            V_TAB-ATWRT = 'BOPP Heatseal Clear'.
          ENDIF.

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
*            if sy-tabix = 2.
*              shift text_data-str_text+7  right by 2 places .
*              add 1 to posi.
*              text_data-str_text+6(3) = posi.
*            endif.

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
*            if sy-tabix = 2.
*              shift text_data-str_text+7  right by 2 places .
*              add 1 to posi.
*              text_data-str_text+6(3) = posi.
*            endif.

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
*Roll
      IF ( V_LABELTYPE EQ 'A009' ) AND ( SY-TCODE NE 'VL74'  OR SY-TCODE NE 'ZHU005' ).

        IF V_ZLABEL-ATNAM = 'ZZTEXT1'.

          CONDENSE V_THICKNESS NO-GAPS.
          CONDENSE V_WIDTH_SS NO-GAPS.
          CONDENSE V_LENGTH_SS NO-GAPS.

          CONCATENATE V_THICKNESS 'micron x ' V_WIDTH_SS 'mm x ' V_LENGTH_SS 'Meters' INTO TEXT1 SEPARATED BY SPACE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 TEXT1 '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSEIF V_ZLABEL-ATNAM = 'ZZTEXT2'.
          CONDENSE V_CORE_SS NO-GAPS.
*        condense v_treat_ss no-gaps.
          CONDENSE V_WEIGHT_SS NO-GAPS.


          CONCATENATE V_CORE_SS 'x ' V_TREAT_SS 'x ' V_WEIGHT_SS 'Kgs' INTO TEXT2  SEPARATED BY SPACE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 TEXT2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZLENGTH'.
          V_ZLABEL-DATA2 = ''.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZCORE'.
          V_ZLABEL-DATA2 = ''.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZTHICKNESS'.
          V_ZLABEL-DATA2 = ''.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZSPLICE-1'.
          V_ZLABEL-DATA2 = ''.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZSPLICE-2'.
          V_ZLABEL-DATA2 = ''.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZCRITERIA'.
          V_ZLABEL-DATA2 = ''.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZWEIGHT'.
          V_ZLABEL-DATA2 = ''.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZWIDTH'.
          V_ZLABEL-DATA2 = ''.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.

      ELSE.
*Box/Pallet
        IF V_ZLABEL-ATNAM = 'ZZFEETX'.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_S_FEET.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_FEET '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZINCHX'.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_S_INCH.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_INCH '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZLBS'.
*mode 3 decimal
          PERFORM RIGHT_JUSTIFIED_3 USING V_LEN_WEIGHT "v_len_normal
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
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_S_SPLICE1.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SPLICE1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF
          V_ZLABEL-ATNAM = 'ZZFEETS2'.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
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
      ENDIF.

      APPEND TEXT_DATA.
    ENDLOOP.

* Number of copies...
*    CONCATENATE '<STX><RS>' v_sval-value '<ETX>' INTO v_copies.
*    text_data-str_text = v_copies.
*    APPEND text_data.
    TEXT_DATA-STR_TEXT = '<STX><RS>1<ETX>'.
    APPEND TEXT_DATA.

    TEXT_DATA-STR_TEXT = '<STX><US>1<ETX>'.
    APPEND TEXT_DATA.

    TEXT_DATA-STR_TEXT = '<STX><ETB><ETX>'.
    APPEND TEXT_DATA.

  ENDDO.
**get data filename.
*  CONCATENATE pfn 'T001' '.DAX' INTO file_d.
**get format filename.
*  CONCATENATE file_dir 'T001' '.TAX' INTO file_f.
**get batch filename.
*  CONCATENATE file_dir 'T001' '.BAT' INTO file_b.
**get image filename.
*  CONCATENATE file_dir 'T001' '.IMG' INTO file_i.

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




ENDFORM.                    "prima_text_data