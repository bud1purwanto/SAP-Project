*&---------------------------------------------------------------------*
*&      Form  text_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TEXT_DATA.
*  DATA : v_sval LIKE sval OCCURS 10 WITH HEADER LINE,
*         v_copies(20).
*  IF sy-tcode <> 'VL74'.
*    v_sval-tabname = 'TSP01_SP0R'.
*    v_sval-fieldname = 'RQCOPIES'.
*    APPEND v_sval.
*
*    CALL FUNCTION 'POPUP_GET_VALUES'
*      EXPORTING
**     NO_VALUE_CHECK        = ' '
*        popup_title           = 'Printer'
*       start_column          = '5'
*       start_row             = '5'
**   IMPORTING
**     RETURNCODE            =
*      TABLES
*        fields                = v_sval
**   EXCEPTIONS
**     ERROR_IN_FIELDS       = 1
**     OTHERS                = 2
*              .
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
*
*    IF v_sval-value IS INITIAL.
*      v_sval-value = 1.
*    ELSE.
*      SHIFT v_sval-value LEFT DELETING LEADING space.
*    ENDIF.
*  ENDIF.


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
          V_LABELTYPE,
          V_LABELMAP.

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

*( 27/06/06 Remove from characteristics)

*    elseif v_tab-atnam = 'ZZGRADE'.
*      v_grade =  v_tab-atwrt.
*    elseif v_tab-atnam = 'ZZDERIVATIVEMS'.
*      v_derivativems = v_tab-atwrt.
*    elseif v_tab-atnam = 'ZZPOSITIONMS'.
*      v_positionms = v_tab-atwrt.
*    elseif v_tab-atnam = 'ZZDERIVATIVESS'.
*      v_derivativess = v_tab-atwrt.
*    elseif v_tab-atnam = 'ZZPOSITIONSS'.
*      v_positionss = v_tab-atwrt.
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


**For Roll Expired Live
*    IF v_tab-atnam = 'ZZEXPIREDLIVE'.
*      	v_live = ''.
*      v_live = v_tab-atwtb.
*    ENDIF.


*GR date...
*    if v_tab-atnam = 'ZZGRDATE'.
*      v_erdat_mm = v_tab-atwtb+3(2).
*      v_erdat_yy = v_tab-atwtb+9(1).
*    endif.

*/---change on 150405---
*ZZCONVERSIONMTRKG
*    IF v_tab-atnam = 'ZZCONVERSIONMTRKG'.
**      v_ZZCONVERSIONMTRKG = v_tab-atwtb.
*      SHIFT v_tab-atwtb LEFT DELETING LEADING space.
*      SPLIT v_tab-atwtb AT v_del INTO v_zzconversionmtrkg v_1.
*    ENDIF.
*---------------------/

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

*/---change on 150405---
* Length is getting from weight/conversionmtrkg.
*  READ TABLE v_tab WITH KEY atnam = 'ZZLENGTH'.
*  IF sy-subrc <> 0.
*    IF v_zzconversionmtrkg IS NOT INITIAL.
*      v_tab-atnam = 'ZZLENGTH'.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.
*      SHIFT v_tab-atwtb LEFT DELETING LEADING space.
*      APPEND v_tab.
*    ENDIF.
*  ELSE.
*    IF v_zzconversionmtrkg IS NOT INITIAL.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.
*      SHIFT v_tab-atwtb LEFT DELETING LEADING space.
*      MODIFY v_tab INDEX sy-tabix.
*    ENDIF.
*  ENDIF.

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
*Mod 01/07/2006
*  IF v_derivativems = '00'.
*    v_derivativems = ''.
*  ENDIF.
*
*  IF v_positionms = '00'.
*    v_positionms = ''.
*  ENDIF.

  IF V_DERIVATIVESS = '00'.
    V_DERIVATIVESS = ''.
  ENDIF.

  IF V_POSITIONSS = '00'.
    V_POSITIONSS = ''.
  ENDIF.


  CONCATENATE V_PRODLINE V_CODE V_MONTHYEAR V_SEQUENCENBR V_GRADE V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS V_POSITIONSS
  INTO V_ROLLNO
  SEPARATED BY SPACE.

*  READ TABLE v_tab WITH KEY atnam = 'ZZTYPE'.
*  IF sy-subrc = 0.
*    CONCATENATE v_type v_thickness INTO v_type SEPARATED BY '-'.
*    v_tab-atwtb = v_type.
*    MODIFY v_tab INDEX sy-tabix.
*  ENDIF.
*  IF sy-tcode <> 'VL74'.
**Roll no and barcode roll no.
*    v_tab-atnam = 'ZZROLLNO'.
*    v_tab-atwtb = v_rollno.
*    APPEND v_tab.
*
*    v_tab-atnam = 'ZZBCROLL'.
*    v_tab-atwtb = v_charg.
*    APPEND v_tab.
*
*    v_tab-atnam = 'ZZBARC'.
*    v_tab-atwtb = v_charg.
*    APPEND v_tab.
*  ENDIF.

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
*    SELECT SINGLE ersda INTO v_postdate FROM mch1 WHERE charg EQ v_charg.
*
*
*    IF sy-subrc = 0.
*      IF v_live <> ''.
*        v_expdate = v_postdate + v_live.
*        v_tab-atnam = 'ZZEX'.
*        CONCATENATE v_expdate+6(2) '/' v_expdate+4(2) '/' v_expdate+0(4) INTO v_tab-atwtb.
*        APPEND v_tab.
*      ENDIF.
*    ENDIF.



* Clear
    CLEAR : V_S_SPLICE1,
            V_S_SPLICE2.

    V_TAB-ATNAM = 'ZZSPLICE-1'.
*Get The Splices At 1st Value(M -> Feet)

    IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' OR V_LABELORIG EQ 'D013' ).
*Interfillm

      PERFORM CONV_TO_CHAR USING V_SPLICE1_D.
      V_SPLICE1_INTER = V_SPLICE1_D * V_C_FEET_INTER.
      WRITE V_SPLICE1_INTER TO V_S_SPLICE1.
      V_SPLICE1_MIRING = V_SPLICE1_D.
      WRITE V_SPLICE1_MIRING TO V_TAB-ATWTB.
      PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                    V_TAB-ATWTB.
    ELSE.
      PERFORM CONV_TO_CHAR USING V_SPLICE1_D.
      V_SPLICE1 = V_SPLICE1_D * V_C_FEET.
      WRITE V_SPLICE1 TO V_S_SPLICE1.
      V_SPLICE1_MIRING = V_SPLICE1_D.
      WRITE V_SPLICE1_MIRING TO V_TAB-ATWTB.

      IF V_SPLICE1_D = ''.
        V_TAB-ATWTB = ''.
        V_S_SPLICE1 = ''.
      ENDIF.

      PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                    V_TAB-ATWTB.
    ENDIF.
    APPEND V_TAB.

    V_TAB-ATNAM = 'ZZSPLICE-2'.
*Get The Splices At 2nd Value(M -> Feet)
    IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' OR V_LABELORIG EQ 'D013'
      OR V_LABELORIG EQ 'D015'
    ).
*Interfillm

      PERFORM CONV_TO_CHAR USING V_SPLICE2_D.
      V_SPLICE2_INTER = V_SPLICE2_D * V_C_FEET_INTER.
      WRITE V_SPLICE2_INTER TO V_S_SPLICE2.
      V_SPLICE2_MIRING = V_SPLICE2_D.
      WRITE V_SPLICE2_MIRING TO V_TAB-ATWTB.
      PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                    V_TAB-ATWTB.
    ELSE.
      PERFORM CONV_TO_CHAR USING V_SPLICE2_D.
      V_SPLICE2 = V_SPLICE2_D * V_C_FEET.
      WRITE V_SPLICE2 TO V_S_SPLICE2.
      V_SPLICE2_MIRING = V_SPLICE2_D.
      WRITE V_SPLICE2_MIRING TO V_TAB-ATWTB.

      IF V_SPLICE2_D = ''.
        V_TAB-ATWTB = ''.
        V_S_SPLICE2 = ''.
      ENDIF.

      PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                    V_TAB-ATWTB.
    ENDIF.
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
* START ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
        REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
        CONDENSE V_TAB-ATWTB NO-GAPS.
* END ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
        V_INCH =   V_TAB-ATWTB * V_C_INCH.
        WRITE V_INCH TO V_S_INCH.
        V_WIDTH = V_TAB-ATWTB.
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

        IF ( V_LABELORIG EQ 'D009' OR V_LABELORIG EQ 'D010' ).
*Interfillm
          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
* START ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
          REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
          CONDENSE V_TAB-ATWTB NO-GAPS.
* END ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
          V_FEET_INTER  = V_TAB-ATWTB * V_C_FEET_INTER.
          WRITE V_FEET_INTER TO V_S_FEET.
          V_LENGTH = V_TAB-ATWTB.
          WRITE V_LENGTH TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.
        ELSE.

          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
* START ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
          REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
          CONDENSE V_TAB-ATWTB NO-GAPS.
* END ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
          V_FEET   = V_TAB-ATWTB * V_C_FEET.
          WRITE V_FEET TO V_S_FEET.
          V_LENGTH = V_TAB-ATWTB.
          WRITE V_LENGTH TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.

        ENDIF.
      ENDIF.

* Get The Length Value(MM -> Inch) For SheetLine
* Replace Feet to Inch in format

      IF V_ZLABEL-ATNAM = 'ZZLENGTHSHT'.
        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
* START ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
        REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
        CONDENSE V_TAB-ATWTB NO-GAPS.
* END ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
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

**Get The Splices At 1st Value(M -> Feet)
*      IF v_zlabel-atnam = 'ZZSPLICE-1'.
*        IF ( v_labelorig EQ 'D009' OR v_labelorig EQ 'D010'  ).
**Interfillm
*
*          PERFORM conv_to_char USING v_tab-atwtb.
*          v_splice1_inter = v_tab-atwtb * v_c_feet_inter.
*          WRITE v_splice1_inter TO v_s_splice1.
*          v_splice1_miring = v_tab-atwtb.
*          WRITE v_splice1_miring TO v_tab-atwtb.
*          PERFORM right_justified USING v_len_normal
*                                        v_tab-atwtb.
*        ELSE.
*          PERFORM conv_to_char USING v_tab-atwtb.
*          v_splice1 = v_tab-atwtb * v_c_feet.
*          WRITE v_splice1 TO v_s_splice1.
*          v_splice1_miring = v_tab-atwtb.
*          WRITE v_splice1_miring TO v_tab-atwtb.
*          PERFORM right_justified USING v_len_normal
*                                        v_tab-atwtb.
*
*        ENDIF.
**        PERFORM conv_to_char USING v_tab-atwtb.
**        v_splice1 = v_tab-atwtb * v_c_feet.
**        WRITE v_splice1 TO v_s_splice1.
**        v_splice1_miring = v_tab-atwtb.
**        WRITE v_splice1_miring TO v_tab-atwtb.
**        PERFORM right_justified USING v_len_normal
**                                      v_tab-atwtb.
*      ENDIF.

**Get The Splices At 2nd Value(M -> Feet)
*      IF v_zlabel-atnam = 'ZZSPLICE-2'.
*        IF ( v_labelorig EQ 'D009' OR v_labelorig EQ 'D010'  ).
**Interfillm
*
*          PERFORM conv_to_char USING v_tab-atwtb.
*          v_splice2_inter = v_tab-atwtb * v_c_feet_inter.
*          WRITE v_splice2_inter TO v_s_splice2.
*          v_splice2_miring = v_tab-atwtb.
*          WRITE v_splice2_miring TO v_tab-atwtb.
*          PERFORM right_justified USING v_len_normal
*                                        v_tab-atwtb.
*        ELSE.
*          PERFORM conv_to_char USING v_tab-atwtb.
*          v_splice2 = v_tab-atwtb * v_c_feet.
*          WRITE v_splice2 TO v_s_splice2.
*          v_splice2_miring = v_tab-atwtb.
*          WRITE v_splice2_miring TO v_tab-atwtb.
*          PERFORM right_justified USING v_len_normal
*                                        v_tab-atwtb.
*
*        ENDIF.
**        PERFORM conv_to_char USING v_tab-atwtb.
**        v_splice2 = v_tab-atwtb * v_c_feet.
**        WRITE v_splice2 TO v_s_splice2.
**        v_splice2_miring = v_tab-atwtb.
**        WRITE v_splice2_miring TO v_tab-atwtb.
**        PERFORM right_justified USING v_len_normal
**                                      v_tab-atwtb.
*      ENDIF.

*Core
      IF V_ZLABEL-ATNAM = 'ZZCORE'.

        IF ( V_LABELTYPE EQ 'D009' OR V_LABELTYPE EQ 'D010' OR V_LABELORIG EQ 'D013' )
        AND ( SY-TCODE NE 'VL74'  OR SY-TCODE NE 'ZHU005' ).
*Interfilm
          WRITE V_TAB-ATWRT TO V_TAB-ATWTB. "PERFORM right_justified USING 1 v_tab-atwrt.
        ELSE.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_CORE
                                        V_TAB-ATWTB.
        ENDIF.
      ENDIF.

*Inside & Outside
      IF V_ZLABEL-ATNAM = 'ZZINSIDE' OR V_ZLABEL-ATNAM = 'ZZOUTSIDE'.

        IF ( V_LABELTYPE EQ 'D009' OR V_LABELTYPE EQ 'D010' OR V_LABELORIG EQ 'D013' )
        AND ( SY-TCODE NE 'VL74'  OR SY-TCODE NE 'ZHU005' ).
*Interfilm
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


ENDFORM.                    "text_data


*&--------------------------------------------------------------------*
*&      Form  text_data
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM NEW_TEXT_DATA.

  DATA : FILE_DIR TYPE STRING VALUE '/spare/saplabel/'.
* // Data for Convert Value
  DATA : V_GAUGE  TYPE P,
*mode 2 dec - 5 digit
         V_S_GAUGE(5),
         V_S_GAUGE_INTER(40),
         V_INCH  TYPE P DECIMALS 2 ,
         V_S_INCH(8),
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
         V_I_WIDTH(10),
         V_I_WEIGHT(10),
         V_I_LENGTH(10),
         V_I_BSTNK TYPE VBAK-BSTNK, "PO Number (free text)
         V_INNER_CORE(50),
         V_LOTNO(40) TYPE C.

  DATA :                           "Added by AKBAR 30.08.2019 (Type D206)
        V_STOUCH1 TYPE STRING,
        V_STOUCH2 TYPE STRING,
        V_TABIX_TEMP TYPE SY-TABIX. "Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)

  DATA : V_CHARGTS      LIKE VBDPL-CHARG, "Added by AKBAR 24.10.2019 (New label type for TTA)
         V_BARCODETS    LIKE AFPO-ABLAD,
         V_CHARG_LONGTS LIKE AFPO-ABLAD.

  DATA : V_GETMATRTYPE TYPE STRING,  "Added by Fany 17.07.2024 (Validation to display material type in label)
         V_GETBARC2 TYPE STRING, "Added by Fany 26.08.2024 (Validation to display variable BARC2 in label)
         V_GETMANUF TYPE STRING.  "Added by Fany 23.01.2025 (Validation to display manufacturing date in label)


  DATA  : V_TEMP(20). " Add by Fany at 16-May-2025 for Laminator Subcont Project
  DATA: IT_TEMPZCODE TYPE TABLE OF STRING WITH HEADER LINE. " Add by Fany at 16-May-2025 for Laminator Subcont Project


*  DATA : v_sval LIKE sval OCCURS 10 WITH HEADER LINE,
*         v_copies(20).
*  IF sy-tcode <> 'VL74'.
*    v_sval-tabname = 'TSP01_SP0R'.
*    v_sval-fieldname = 'RQCOPIES'.
*    APPEND v_sval.
*
*    CALL FUNCTION 'POPUP_GET_VALUES'
*      EXPORTING
**     NO_VALUE_CHECK        = ' '
*        popup_title           = 'Printer'
*       start_column          = '5'
*       start_row             = '5'
**   IMPORTING
**     RETURNCODE            =
*      TABLES
*        fields                = v_sval
**   EXCEPTIONS
**     ERROR_IN_FIELDS       = 1
**     OTHERS                = 2
*              .
*    IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
*
*    IF v_sval-value IS INITIAL.
*      v_sval-value = 1.
*    ELSE.
*      SHIFT v_sval-value LEFT DELETING LEADING space.
*    ENDIF.
*  ENDIF.


* Get SO NUmber and Item from last Batch

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
          V_LABELTYPE,
          V_LABELMAP.

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

      SELECT SINGLE TEXT2 INTO V_LABELMAP FROM ZMAP_LABEL WHERE CODE EQ V_LABELTYPE.
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

  "---------------------------------------------------
  "Start Add Bothside Treatment by Fiqih (29.04.2026)
* Get Bothside Treatment...
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZINSIDE'.
  IF SY-SUBRC = 0.
    DATA: LV_TEXT2(20) TYPE C,
          LV_TEXT4(20) TYPE C.

    SELECT SINGLE  TEXT2 TEXT4
      INTO (LV_TEXT2, LV_TEXT4)
      FROM ZMAP_LABEL
      WHERE CODE EQ V_LABELTYPE.

    CONDENSE V_TYPE.
    IF V_TYPE NE '' AND LV_TEXT2 NE '' AND V_TYPE CS LV_TEXT2.
      V_TAB-ATWTB = LV_TEXT4.
    ENDIF.
    MODIFY V_TAB INDEX SY-TABIX.
  ENDIF.
  "End Add Bothside Treatment by Fiqih (29.04.2026)

* Weight is getting from formula...
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZWEIGHT'.
  IF SY-SUBRC <> 0.

    "Start - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)
    IF V_LABELTYPE = 'D207'.
      CLEAR: V_SUM_NETWEIGHT, V_TAB-ATWTB.
      PERFORM GET_ACTDATA CHANGING V_SUM_NETWEIGHT V_TAB-ATWTB.
    ENDIF.
    "End - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)

    IF V_LABELTYPE = 'SB10'.
      DATA V_ROUND_WEIGHT TYPE P DECIMALS 1.
      PERFORM CONVERSION_WEIGHT USING V_SUM_NETWEIGHT CHANGING V_ROUND_WEIGHT.
      V_TAB-ATNAM = 'ZZWEIGHT'.
      V_TAB-ATWTB = V_ROUND_WEIGHT.
    ELSE.
      V_TAB-ATNAM = 'ZZWEIGHT'.
      V_TAB-ATWTB = V_SUM_NETWEIGHT.
    ENDIF.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
  ELSE.

    "Start - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)
    IF V_LABELTYPE = 'D207'.
      CLEAR: V_SUM_NETWEIGHT, V_TAB-ATWTB.
      V_TABIX_TEMP = SY-TABIX.
      PERFORM GET_ACTDATA CHANGING V_SUM_NETWEIGHT V_TAB-ATWTB.

      SY-TABIX = V_TABIX_TEMP.
      V_TAB-ATNAM = 'ZZWEIGHT'.
    ENDIF.
    "End - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)

    V_TAB-ATWTB = V_SUM_NETWEIGHT.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
  ENDIF.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZLENGTH'.
  IF SY-SUBRC <> 0.

    "Start - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)
    IF V_LABELTYPE = 'D207'.
      CLEAR: V_SUM_NETWEIGHT, V_TAB-ATWTB.
      PERFORM GET_ACTDATA CHANGING V_SUM_NETWEIGHT V_TAB-ATWTB.
    ENDIF.
    "End - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)

*    IF v_zzconversionmtrkg IS NOT INITIAL.
    V_TAB-ATNAM = 'ZZLENGTH'.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.
    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    APPEND V_TAB.
*    ENDIF.
  ELSE.
*    IF v_zzconversionmtrkg IS NOT INITIAL.
*      v_tab-atwtb = v_sum_netweight / v_zzconversionmtrkg.

    "Start - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)
    IF V_LABELTYPE = 'D207'.
      CLEAR: V_SUM_NETWEIGHT, V_TAB-ATWTB.
      V_TABIX_TEMP = SY-TABIX.
      PERFORM GET_ACTDATA CHANGING V_SUM_NETWEIGHT V_TAB-ATWTB.

      SY-TABIX = V_TABIX_TEMP.
      V_TAB-ATNAM = 'ZZLENGTH'.
    ENDIF.
    "End - Added by AKBAR 11.12.2019 (Type D207 - Actual Length & Weight)

    SHIFT V_TAB-ATWTB LEFT DELETING LEADING SPACE.
    MODIFY V_TAB INDEX SY-TABIX.
*    ENDIF.
  ENDIF.
*----------------------/
  CLEAR : V_GETBARC2.
  SELECT SINGLE TEXT4 INTO "Added by Fany 26.08.2024
        V_GETBARC2
        FROM ZMAP_LABEL WHERE
        CODE = V_LABELTYPE AND TEXT4 = 'CHARG2'.
  IF V_GETBARC2 NE ''. "Add by Fany (26-08-2024), mapping batch for TTA
    V_CHARGTS = V_CHARG.
    SHIFT V_CHARGTS LEFT.
    CONCATENATE '9' V_CHARGTS INTO V_CHARGTS.
    CONCATENATE V_CHARGTS V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS  V_POSITIONSS INTO V_BARCODETS.

    CALL FUNCTION 'CONVERSION_EXIT_BAS36_OUTPUT'
      EXPORTING
        INPUT          = V_BARCODETS
      IMPORTING
        OUTPUT         = V_BARCODETS
      EXCEPTIONS
        INVALID_FORMAT = 1
        OTHERS         = 2.
  ENDIF.
  "End - Added by AKBAR 24.10.2019 (New label type for TTA)


* Start Add by Fany at 16-May-2025 For Laminator Subcont Project
  IF V_LABELTYPE = 'G104'.
      READ TABLE V_TAB WITH KEY ATNAM = 'ZZALIAS'.
      IF SY-SUBRC EQ 0.
         CLEAR : IT_TEMPZCODE.
         CLEAR : V_TEMP.
         SPLIT V_TAB-ATWRT AT SPACE INTO TABLE IT_TEMPZCODE.
         READ TABLE IT_TEMPZCODE INDEX LINES( IT_TEMPZCODE ).
          IF SY-SUBRC EQ 0.
             V_TEMP = IT_TEMPZCODE.
             IF V_TEMP NE ''.
               READ TABLE V_TAB WITH KEY ATNAM = 'ZZTYPE'.
               IF SY-SUBRC = 0.
                 V_TAB-ATWRT = V_TEMP.
                 V_TAB-ATWTB = V_TEMP.
                 MODIFY V_TAB  INDEX SY-TABIX TRANSPORTING ATWRT ATWTB.
               ENDIF.
             ENDIF.
          ENDIF.
      ENDIF.
  ENDIF.
* End Add by Fany at 16-May-2025 For Laminator Subcont Project

  IF V_DERIVATIVESS = '00'.
    V_DERIVATIVESS = ''.
  ENDIF.

  IF V_POSITIONSS = '00'.
    V_POSITIONSS = ''.
  ENDIF.


  CONCATENATE V_PRODLINE V_CODE V_MONTHYEAR V_SEQUENCENBR V_GRADE V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS V_POSITIONSS
  INTO V_ROLLNO
  SEPARATED BY SPACE.


*New condition for label customer stock CKI Laminator
  IF V_LABELTYPE = 'G105'.
    READ TABLE V_TAB WITH KEY ATNAM = 'ZZNOMORROLL'.
    IF SY-SUBRC = 0.
        V_ROLLNO = V_TAB-ATWRT.
    ENDIF.
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

    IF V_LABELTYPE = 'D218' OR V_LABELTYPE = 'B222'. "add 20-7-2017 memecah roll jd 2 baris
      V_TAB-ATNAM = 'ZZROLL8'.
      V_TAB-ATWTB = V_ROLLNO+0(13).
      APPEND V_TAB.

      V_TAB-ATNAM = 'ZZROLL9'.
      V_TAB-ATWTB = V_ROLLNO+14(15).
      APPEND V_TAB.
    ENDIF.

    V_TAB-ATNAM = 'ZZBCROLL'.
*    v_tab-atwtb = v_charg.
    IF V_LABELTYPE = 'D113' OR V_LABELTYPE = 'B113'.
      PERFORM SNW_ROLL_BARCODE.
    ELSEIF V_GETBARC2 NE ''. "Add by Fany (26-08-2024), mapping batch for TTA
      V_TAB-ATWTB = V_BARCODETS.
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
    IF V_LABELTYPE = 'A171' OR V_LABELTYPE = 'SB17'. "Add by Fiqih - 13.03.2026
      V_TAB-ATWTB = V_CHARG.
    ELSE.
      CONCATENATE V_CHARG '-' V_BARCODE INTO V_CHARG_LONG.
      V_TAB-ATWTB = V_CHARG_LONG.
    ENDIF.
    APPEND V_TAB.

    IF V_GETBARC2 NE ''. "Add by Fany (26-08-2024), mapping batch for TTA
      V_TAB-ATNAM = 'ZZBARC2'.
      IF V_LABELTYPE = 'A171' OR V_LABELTYPE = 'SB17'. "Add by Fiqih - 13.03.2026
        V_TAB-ATWTB = V_CHARGTS.
      ELSE.
        CONCATENATE V_CHARGTS '-' V_BARCODETS INTO V_CHARG_LONGTS.
        V_TAB-ATWTB = V_CHARG_LONGTS.
      ENDIF.
      APPEND V_TAB.
    ENDIF.
    "End - Added by AKBAR 24.10.2019 (New label type for TTA)

    "Start Added by AKBAR 15.03.2019 (Type label SANYO EPac)
    IF V_LABELTYPE = 'SE01' OR V_LABELTYPE = 'SE02' OR V_LABELTYPE = 'SE03' OR V_LABELTYPE = 'SE04' OR V_LABELTYPE = 'SE05'.
      V_TAB-ATNAM = 'ZZBARC2'.
      CONDENSE V_ROLLNO NO-GAPS.
      V_TAB-ATWTB = V_ROLLNO.
      APPEND V_TAB.

      V_TAB-ATNAM = 'ZZBARC3'.
      V_TAB-ATWTB = V_SUM_NETWEIGHT.
      PERFORM CONV_TO_CHAR_3_DEC USING V_TAB-ATWTB.
      V_LBS = V_TAB-ATWTB * V_C_LBS.
      WRITE V_LBS TO V_TAB-ATWTB.
      PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT
                                      V_TAB-ATWTB.
      REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
      APPEND V_TAB.

    ENDIF.
    "End Added by AKBAR 15.03.2019 (Type label SANYO EPac)

*Add Expired Date
*    SELECT SINGLE ersda INTO v_postdate FROM mch1 WHERE charg EQ v_charg AND matnr EQ v_matnr.
    CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
      EXPORTING
        MATNR = V_MATNR
        CHARG = V_CHARG
      IMPORTING
        PDATE = V_POSTDATE.


    IF SY-SUBRC = 0.
      CLEAR : V_GETMANUF.
      SELECT SINGLE TEXT5 INTO "Added by Fany 23.01.2025
          V_GETMANUF
      FROM ZMAP_LABEL WHERE
      CODE = V_LABELTYPE AND TYPE = 'DOS' AND TEXT5 = 'MANUF'.

      IF V_GETMANUF NE ''. "Display manufacturing date.
        "Start Add New Label A172 by Fiqih 15/06/2026 - For DIsplay Manuf Date DD.MM.YYYY
        IF V_LABELTYPE = 'A172'.
          V_TAB-ATNAM = 'ZZEX'.
          CONCATENATE V_POSTDATE+6(2) '.' V_POSTDATE+4(2) '.' V_POSTDATE+0(4) INTO V_TAB-ATWTB.
          APPEND V_TAB.
        "End Add New Label A172 by Fiqih 15/06/2026 - For DIsplay Manuf Date DD.MM.YYYY
        ELSE.
          V_TAB-ATNAM = 'ZZEX'.
          CONCATENATE V_POSTDATE+0(4) '.' V_POSTDATE+4(2) INTO V_TAB-ATWTB.
          APPEND V_TAB.
        ENDIF.

*Mag-Data (Manufacturing Date : DD/MM/YYYY)
     ELSEIF ( V_LABELTYPE = 'A113' OR V_LABELTYPE = 'E109').
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_POSTDATE+6(2) '/' V_POSTDATE+4(2) '/' V_POSTDATE+0(4)  INTO V_TAB-ATWTB.
        APPEND V_TAB.
      "Case new label manuf and expired
      ELSEIF ( V_LABELTYPE = 'A162' OR V_LABELTYPE = 'C126' OR V_LABELTYPE = 'D131' OR V_LABELTYPE = 'G104' OR V_LABELTYPE = 'G105').
        V_TAB-ATNAM = 'ZZMANUFDATE'.
        CONCATENATE V_POSTDATE+0(4) '.' V_POSTDATE+4(2) INTO V_TAB-ATWTB.
        APPEND V_TAB.

        V_EXPDATE = V_POSTDATE + V_LIVE.
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_EXPDATE+0(4) '.' V_EXPDATE+4(2) INTO V_TAB-ATWTB.
        APPEND V_TAB.
      ELSE.
*Other (Used Before :)
          IF V_LABELTYPE = 'D201' OR V_LABELTYPE = 'D205' OR V_LABELTYPE = 'D206' "ADDED BY AKBAR 30.08.2019 (TYPE D206)
             OR V_LABELTYPE = 'D207' OR V_LABELTYPE = 'D208'.                                             "Added by AKBAR 11.12.2019 (Type D207)
          ELSEIF V_LABELTYPE = 'D121'. "Condition for label CKI, conditional expired live. Add by Fany 18.08.2025
             DATA : V_MAPEXP_BY_TYPE TYPE STRING.
             DATA : V_TYPE_TEMP(30).
             DATA : V_LIVE_TEMP(2).
             DATA : BEGIN OF IT_MAPEXP_BY_TYPE OCCURS 0,
                        TYPE_MONTH(30),
                    END OF IT_MAPEXP_BY_TYPE.
             READ TABLE V_TAB WITH KEY ATNAM = 'ZZTYPE'.
             SELECT SINGLE TEXT5 INTO
             V_MAPEXP_BY_TYPE
             FROM ZMAP_LABEL WHERE
             CODE = V_LABELTYPE AND TYPE = 'DOS'.
             IF V_MAPEXP_BY_TYPE NE ''.
               SPLIT V_MAPEXP_BY_TYPE AT ',' INTO TABLE IT_MAPEXP_BY_TYPE.
               LOOP AT IT_MAPEXP_BY_TYPE.
                 SPLIT IT_MAPEXP_BY_TYPE-TYPE_MONTH AT '+' INTO V_TYPE_TEMP V_LIVE_TEMP.
                 IF V_TYPE_TEMP EQ V_TAB-ATWRT.
                   V_EXPDATE = V_POSTDATE + ( V_LIVE_TEMP * 30 ).
                   V_TAB-ATNAM = 'ZZEX'.
                   CONCATENATE V_EXPDATE+0(4) '.' V_EXPDATE+4(2) INTO V_TAB-ATWTB.
                   APPEND V_TAB.
                   EXIT.
                 ENDIF.
               ENDLOOP.
             ENDIF.
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

        IF V_LABELTYPE = 'A147' OR V_LABELTYPE = 'A148' OR V_LABELTYPE = 'A172'.
          CONCATENATE V_THICKNESS ' mic.' INTO V_INFO_THICKNESS.
        ELSE.
          CONCATENATE V_THICKNESS ' mic.   ' V_S_GAUGE ' ga.' INTO V_INFO_THICKNESS.
        ENDIF.

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
* START ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
        REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
        CONDENSE V_TAB-ATWTB NO-GAPS.
* END ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik

        IF V_LABELTYPE = 'A129' OR V_LABELTYPE = 'A302' OR V_LABELTYPE = 'A303' OR V_LABELTYPE = 'A306'.
          PERFORM GET_INCH_FR_SO USING V_S_INCH.
        ELSE.
          V_INCH =   V_TAB-ATWTB * V_C_INCH.
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
* START ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
        REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
        CONDENSE V_TAB-ATWTB NO-GAPS.
* END ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik

        IF V_LABELTYPE = 'B211' OR V_LABELTYPE = 'B212' OR V_LABELTYPE = 'B222'
          OR V_LABELTYPE = 'D211' OR V_LABELTYPE = 'D212' OR V_LABELTYPE = 'D218'.
          PERFORM GET_FEET_FR_SO USING V_S_FEET.
        ELSE.
          V_FEET   = V_TAB-ATWTB * V_C_FEET.
          WRITE V_FEET TO V_S_FEET.
        ENDIF.

* START ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
        REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
        CONDENSE V_TAB-ATWTB NO-GAPS.
* END ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
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
* START ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
        REPLACE ALL OCCURRENCES OF ',' IN V_TAB-ATWTB WITH ''.
        CONDENSE V_TAB-ATWTB NO-GAPS.
* END ADD BY TRST-FIQIH 07.09.2026 - Hapus koma pemisah ribuan agar aman konversi numerik
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
        IF V_LABELTYPE = 'SB10'.
          DATA: V_ROUND_WEIGHT2 TYPE P DECIMALS 1,
                V_ROUND_LBS     TYPE P DECIMALS 1.
          PERFORM CONVERSION_WEIGHT USING V_LBS CHANGING V_ROUND_LBS.
          WRITE V_ROUND_LBS TO V_S_LBS.
          V_ROUND_WEIGHT2 = V_TAB-ATWTB.
          WRITE V_ROUND_WEIGHT2 TO V_TAB-ATWTB.
        ELSE.
          V_WEIGHT = V_TAB-ATWTB.
          WRITE V_WEIGHT TO V_TAB-ATWTB.
          WRITE V_LBS TO V_S_LBS.
        ENDIF.
*mode 3 decimal
        PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT "v_len_normal
                                      V_TAB-ATWTB.
      ENDIF.

*Core Left Justified
      IF V_ZLABEL-ATNAM = 'ZZCORE'.
        "Start Added by AKBAR 15.03.2019 (Type label SANYO EPac)
        IF V_LABELTYPE = 'SE01' OR V_LABELTYPE = 'SE02' OR V_LABELTYPE = 'SE03' OR V_LABELTYPE = 'SE04' OR V_LABELTYPE = 'SE05'
        OR V_LABELMAP  = 'PMI-QR'.
          SPLIT V_TAB-ATWTB AT '(' INTO V_TAB-ATWTB V_CORE_SS.
          SHIFT V_CORE_SS BY 1 PLACES RIGHT.
          SHIFT V_CORE_SS LEFT DELETING LEADING SPACE.
          CONCATENATE V_CORE_SS '(' V_TAB-ATWTB ')' INTO V_TAB-ATWTB.
        ELSE.
          CONCATENATE V_TAB-ATWTB 'CORE' INTO V_TAB-ATWTB.
        ENDIF.
        "End Added by AKBAR 15.03.2019 (Type label SANYO EPac)
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

  "For Inner Core Label
  IF V_LABELTYPE = 'A143'.
    READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZTEXT2'.
    V_I_WIDTH = V_WIDTH.
    V_I_LENGTH = V_S_LENGTH.
    V_I_WEIGHT = V_SUM_NETWEIGHT.
    CONDENSE V_I_WIDTH NO-GAPS.
    CONDENSE V_I_LENGTH NO-GAPS.
    CONDENSE V_I_WEIGHT NO-GAPS.
    CONCATENATE V_S_WIDTH 'mm' INTO V_I_WIDTH.
    CONCATENATE V_S_LENGTH 'm' INTO V_I_LENGTH.
    CONCATENATE V_I_WEIGHT 'kg' INTO V_I_WEIGHT.
    IF V_FLAG_ZZALIAS <> 'X'.
      CONCATENATE V_TYPE '-' V_THICKNESS '/' V_I_WIDTH '/' V_I_LENGTH '/' V_I_WEIGHT INTO V_INNER_CORE.
    ELSE.
      CONCATENATE V_TYPE '/' V_I_WIDTH '/' V_I_LENGTH '/' V_I_WEIGHT INTO V_INNER_CORE.
    ENDIF.
    V_ZLABEL-DATA2 = V_INNER_CORE.
    MODIFY V_ZLABEL TRANSPORTING DATA2 WHERE ATNAM = 'ZZTEXT2' .
  ENDIF.

  "For Inner Core Label
  IF V_LABELTYPE = 'A147' OR V_LABELTYPE = 'A148' OR V_LABELTYPE = 'A172'.
    READ TABLE V_ZLABEL WITH KEY ATNAM = 'ZZTYPE'.
    V_I_WIDTH = V_WIDTH.
    V_I_LENGTH = V_S_LENGTH.
    V_I_WEIGHT = V_SUM_NETWEIGHT.
    CONDENSE V_I_WIDTH NO-GAPS.
    CONDENSE V_I_LENGTH NO-GAPS.
    CONDENSE V_I_WEIGHT NO-GAPS.
    CONCATENATE V_S_WIDTH 'mm' INTO V_I_WIDTH.
    CONCATENATE V_S_LENGTH 'm' INTO V_I_LENGTH.
    CONCATENATE V_I_WEIGHT 'kg' INTO V_I_WEIGHT.
    IF V_FLAG_ZZALIAS <> 'X'.
      CONCATENATE V_TYPE '-' V_THICKNESS '/' V_I_WIDTH '/' V_I_LENGTH INTO V_INNER_CORE.
    ELSE.
      CONCATENATE V_TYPE '/' V_I_WIDTH '/' V_I_LENGTH INTO V_INNER_CORE.
    ENDIF.
    V_ZLABEL-DATA2 = V_INNER_CORE.
    MODIFY V_ZLABEL TRANSPORTING DATA2 WHERE ATNAM = 'ZZTEXT2' .

    READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
    IF SY-SUBRC = 0.
      V_ZLABEL-DATA2 = V_TAB-ATWRT.
*       V_ZLABEL-ATNAM = 'ZZTHICKNESS'.
*       APPEND V_ZLABEL.
      MODIFY V_ZLABEL TRANSPORTING DATA2 WHERE ATNAM = 'ZZTHICKNESS' .
    ENDIF.
  ENDIF.

  "Start Add by Fiqih - 11.03.2026
  "For Inner Core Label
  IF V_LABELTYPE = 'A171' OR V_LABELTYPE = 'SB17'.

    CLEAR: V_I_BSTNK.

    IF V_VBELN IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = V_VBELN
        IMPORTING
          OUTPUT = V_VBELN.

      SELECT SINGLE BSTNK INTO V_I_BSTNK FROM VBAK WHERE VBAK~VBELN = V_VBELN.
    ENDIF.

    V_I_WIDTH = V_S_WIDTH.
    CONDENSE V_I_WIDTH NO-GAPS.

    IF V_FLAG_ZZALIAS <> 'X'.
      CONCATENATE V_TYPE '-' V_THICKNESS '/' V_I_WIDTH '/' V_I_BSTNK INTO V_INNER_CORE.
    ELSE.
      CONCATENATE V_TYPE '/' V_I_WIDTH '/' V_I_BSTNK INTO V_INNER_CORE.
    ENDIF.

    V_ZLABEL-DATA2 = V_INNER_CORE.
    MODIFY V_ZLABEL TRANSPORTING DATA2 WHERE ATNAM = 'ZZTEXT2'.
  ENDIF.
  "End Add by Fiqih - 11.03.2026

*/---Added on 150405---
*cek previouly label
  CLEAR : V_LOTNO.

  IF ( V_LABELTYPE = 'B114' OR V_LABELTYPE = 'E108' OR V_LABELTYPE = 'C110' OR V_LABELTYPE = 'D115' OR
     V_LABELTYPE = 'A109' OR V_LABELTYPE = 'A148' OR V_LABELTYPE = 'C111' OR V_LABELTYPE = 'F107' OR V_LABELTYPE = 'D116' OR V_LABELTYPE = 'D119' ).

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
        IF V_LABELTYPE = 'A302' OR V_LABELTYPE = 'A303' OR V_LABELTYPE = 'A306'.
        ELSE.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_INCH V_S_INCH.
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
           V_LABELTYPE = 'B215' OR V_LABELTYPE = 'B216' OR V_LABELTYPE = 'B223' OR
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

*- add part for A261
    IF V_LABELTYPE = 'A129'.
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
        CONCATENATE '<STX><ESC>F"PART  "<LF>Part no. ' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
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

    ELSEIF V_LABELTYPE = 'D206' OR V_LABELTYPE = 'D207'. "Added by AKBAR 30.08.2019 (Type D206) & Type D207 at 11.12.2019

      "untuk mengambil data Special Touch 1 - 2
      CLEAR: V_STOUCH1, V_STOUCH2.
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

      CLEAR: TEXT_DATA-STR_TEXT.
      CONCATENATE ' PO No.: ' V_STOUCH1 INTO TEXT_DATA-STR_TEXT.
      CONCATENATE '<STX><ESC>F"PART1  "<LF>' TEXT_DATA-STR_TEXT '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.

      CLEAR: TEXT_DATA-STR_TEXT.
      CONCATENATE ' Part No.: ' V_STOUCH2 INTO TEXT_DATA-STR_TEXT.
      CONCATENATE '<STX><ESC>F"PART2  "<LF>' TEXT_DATA-STR_TEXT '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.

      "Start - Added by AKBAR 13.11.2019 (label SANYO EPac add barcode film)
    ELSEIF V_LABELTYPE = 'SE01' OR V_LABELTYPE = 'SE02' OR V_LABELTYPE = 'SE03' OR V_LABELTYPE = 'SE04' OR V_LABELTYPE = 'SE05'.

      "untuk mengambil data Special Touch 1
      CLEAR: V_STOUCH1.
      READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPECIALTOUCH-1'.
      IF SY-SUBRC = 0.
        V_STOUCH1 = V_TAB-ATWRT.
      ELSE.
        MESSAGE 'Special Touch - 1 belum memiliki data' TYPE 'I'.
        LEAVE LIST-PROCESSING.
      ENDIF.

      CLEAR: TEXT_DATA-STR_TEXT.
      TEXT_DATA-STR_TEXT = V_STOUCH1.
      CONCATENATE '<STX><ESC>F"FBARC  "<LF>' TEXT_DATA-STR_TEXT '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
      "End - Added by AKBAR 13.11.2019 label SANYO EPac add barcode film)
    ELSEIF V_LABELMAP = 'PMI-QR'.
      "Start - Added by J. Budi 07.05.2023 (Label PMI add QR Code)
      CLEAR: V_STOUCH1, TEXT_DATA-STR_TEXT.

      CONCATENATE V_EXPDATE+0(4) '.' V_EXPDATE+4(2) INTO V_TAB-ATWTB.
      " Start Edited PMI-QR structure by Fiqih (menambahkan keterangan hardcoded Roll, Type, Thick, dll. <SUB><CR><SUB><LF> untuk enter) - 16.07.2026
      CONCATENATE 'Roll No:' V_ROLLNO
                  '<SUB><CR><SUB><LF>Type:' V_TYPE
                  '<SUB><CR><SUB><LF>Thick:' V_THICKNESS
                  '<SUB><CR><SUB><LF>Widht:' V_S_WIDTH
                  '<SUB><CR><SUB><LF>Length:' V_S_LENGTH
                  '<SUB><CR><SUB><LF>Used Before:' V_TAB-ATWTB INTO V_STOUCH1 SEPARATED BY ' '.
      " End Edited PMI-QR structure by Fiqih  (menambahkan keterangan hardcoded Roll, Type, Thick, dll. <SUB><CR><SUB><LF> untuk enter) - 16.07.2026

      TEXT_DATA-STR_TEXT = V_STOUCH1.
      CONCATENATE '<STX><ESC>F"FBARC  "<LF>' TEXT_DATA-STR_TEXT '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
      "End - Added by J. Budi 07.05.2023 (Label PMI add QR Code)
    ENDIF.


* Start Add by Fany 16-May-2025 For Laminator Subcont Project
      IF V_LABELTYPE = 'G104'.
         CLEAR : V_I_LENGTH, V_I_WEIGHT.
         V_I_LENGTH = V_S_LENGTH.
         V_I_WEIGHT = V_SUM_NETWEIGHT.
         CONDENSE V_I_WEIGHT NO-GAPS.
         REPLACE ALL OCCURENCES OF ',' IN V_I_LENGTH WITH '' .

         DATA : IT_LINES TYPE TLINE OCCURS 0 WITH HEADER LINE.
         DATA : V_NAME LIKE THEAD-TDNAME.
         DATA : V_LOTCOUNT TYPE I VALUE 0.
         DATA : V_LOTCHAR TYPE STRING.
         DATA : THEAD LIKE THEAD.
         DATA : V_QRLOT1 TYPE STRING.
         DATA : V_QRLOT2 TYPE STRING.
         DATA : V_QRLOT3 TYPE STRING.
         DATA : BEGIN OF IT_LOT OCCURS 0,
                  BATCH LIKE MCH1-CHARG,
                  NOLOT LIKE AUSP-ATWRT,
                  LENGTH LIKE AUSP-ATWRT,
                  MATNR LIKE MCH1-MATNR,
               END OF IT_LOT.

         V_NAME+0(10)    = V_MATNR.
         V_NAME+22(10)   = V_CHARG.

          CALL FUNCTION 'READ_TEXT'
            EXPORTING
              CLIENT                  = SY-MANDT
              ID                      = 'VERM'
              LANGUAGE                = SY-LANGU
              NAME                    = V_NAME
              OBJECT                  = 'CHARGE'
            TABLES
              LINES                   = IT_LINES
            EXCEPTIONS
              ID                      = 1
              LANGUAGE                = 2
              NAME                    = 3
              NOT_FOUND               = 4
              OBJECT                  = 5
              REFERENCE_CHECK         = 6
              WRONG_ACCESS_TO_ARCHIVE = 7
              OTHERS                  = 8.

         IF SY-SUBRC EQ 0.
           LOOP AT IT_LINES.
              IF SY-TABIX GT 1.
                IF IT_LINES-TDLINE IS NOT INITIAL OR IT_LINES-TDLINE NE ''.
                  SPLIT IT_LINES-TDLINE AT ':' INTO IT_LOT-BATCH IT_LOT-LENGTH.
                  SELECT SINGLE A~MATNR B~ATWRT INTO (IT_LOT-MATNR,IT_LOT-NOLOT) FROM MCH1 AS A
                    JOIN AUSP AS B ON A~CUOBJ_BM = B~OBJEK
                      JOIN CABN AS C ON B~ATINN = C~ATINN
                      WHERE  C~ATNAM EQ 'ZZNOLOTSUBCONT' AND A~CHARG = IT_LOT-BATCH.
                  APPEND IT_LOT.
                ENDIF.
              ENDIF.
           ENDLOOP.
         ENDIF.

         DO 3 TIMES.
           ADD 1 TO V_LOTCOUNT.
           IF V_LOTCOUNT GT 1.
             V_LOTCHAR = 'ZZNOLOTSUBCONT' && V_LOTCOUNT.
           ELSE.
             V_LOTCHAR = 'ZZNOLOTSUBCONT'.
           ENDIF.
           READ TABLE V_TAB WITH KEY ATNAM = V_LOTCHAR.
           IF SY-SUBRC = 0.
               READ TABLE IT_LOT WITH KEY NOLOT = V_TAB-ATWRT.
               IF SY-SUBRC = 0.
                 TEXT_DATA-STR_TEXT = '<STX><ESC>F"LOT' && V_LOTCOUNT && '  "<LF>' && V_TAB-ATWRT && '-' && IT_LOT-LENGTH && '<ETX>'.
                 APPEND TEXT_DATA.
               ELSE.
                 TEXT_DATA-STR_TEXT = '<STX><ESC>F"LOT' && V_LOTCOUNT && '  "<LF>' && V_TAB-ATWRT && '-' && V_I_LENGTH && '<ETX>'.
                 APPEND TEXT_DATA.
               ENDIF.
               IF V_LOTCOUNT EQ 1.
                 TEXT_DATA-STR_TEXT = '<STX><ESC>F"LTXT' && V_LOTCOUNT && ' "<LF>WIP PRT CKI <ETX>'.
                 APPEND TEXT_DATA.

                 TEXT_DATA-STR_TEXT = '<STX><ESC>F"LTXT' && V_LOTCOUNT && 'B"<LF>No Lot: <ETX>'.
                 APPEND TEXT_DATA.

               ELSEIF V_LOTCOUNT EQ 2 OR V_LOTCOUNT EQ 3.
                 TEXT_DATA-STR_TEXT = '<STX><ESC>F"LTXT' && V_LOTCOUNT && ' "<LF>SR BF CKI <ETX>'.
                 APPEND TEXT_DATA.

                 TEXT_DATA-STR_TEXT = '<STX><ESC>F"LTXT' && V_LOTCOUNT && 'B"<LF>No Lot: <ETX>'.
                 APPEND TEXT_DATA.
               ENDIF.
            ENDIF.
         ENDDO.



          READ TABLE V_TAB WITH KEY ATNAM = 'ZZPOCUSTOMER'.
            IF SY-SUBRC = 0.
              CONCATENATE '<STX><ESC>F"POCKI "<LF>' V_TAB-ATWRT '<ETX>' INTO TEXT_DATA-STR_TEXT.
              APPEND TEXT_DATA.
            ENDIF.

          READ TABLE V_TAB WITH KEY ATNAM = 'ZZSKU'.
          IF SY-SUBRC = 0.
           TEXT_DATA-STR_TEXT = '<STX><ESC>F"SKUTXT"<LF>SKU: <ETX>' .
           APPEND TEXT_DATA.

           CONCATENATE '<STX><ESC>F"SKU   "<LF>' V_TAB-ATWRT '<ETX>' INTO TEXT_DATA-STR_TEXT.
           APPEND TEXT_DATA.
          ENDIF.

        CONCATENATE '<STX><ESC>F"BARCLN"<LF>' V_CHARG '-' V_I_WEIGHT '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
    ENDIF.

    IF V_LABELTYPE = 'G105'.
      DATA : V_CUST LIKE KNA1-NAME1,
             V_SKU  LIKE CAWNT-ATWTB.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZNOLOTSUBCONT'.
      IF SY-SUBRC = 0.
         CONCATENATE '<STX><ESC>F"LOT  "<LF>' V_TAB-ATWRT '<ETX>' INTO TEXT_DATA-STR_TEXT.
         APPEND TEXT_DATA.
      ENDIF.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZNOLOTSUBCONT2'.
      IF SY-SUBRC = 0.
         CONCATENATE '<STX><ESC>F"LOT  "<LF>' V_TAB-ATWRT '<ETX>' INTO TEXT_DATA-STR_TEXT.
         APPEND TEXT_DATA.
      ENDIF.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZNOLOTSUBCONT3'.
      IF SY-SUBRC = 0.
         CONCATENATE '<STX><ESC>F"LOT  "<LF>' V_TAB-ATWRT '<ETX>' INTO TEXT_DATA-STR_TEXT.
         APPEND TEXT_DATA.
      ENDIF.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZPOCUSTOMER'.
      IF SY-SUBRC = 0.
        CONCATENATE '<STX><ESC>F"POCKI "<LF>' V_TAB-ATWRT '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ENDIF.

      READ TABLE V_TAB WITH KEY ATNAM = 'ZZCUSTOMER'.
      IF SY-SUBRC = 0.
        CLEAR : V_CUST.
        SELECT SINGLE NAME1 FROM KNA1
        INTO V_CUST WHERE KUNNR = V_TAB-ATWRT.

          IF SY-SUBRC = 0.
            CONCATENATE '<STX><ESC>F"CUST  "<LF>' V_CUST '<ETX>' INTO TEXT_DATA-STR_TEXT.
            APPEND TEXT_DATA.
          ENDIF.
       ENDIF.

       READ TABLE V_TAB WITH KEY ATNAM = 'ZZSKU'.
        IF SY-SUBRC = 0.
           TEXT_DATA-STR_TEXT = '<STX><ESC>F"SKUTXT"<LF>SKU: <ETX>' .
           APPEND TEXT_DATA.

           CONCATENATE '<STX><ESC>F"SKU   "<LF>' V_TAB-ATWRT '<ETX>' INTO TEXT_DATA-STR_TEXT.
           APPEND TEXT_DATA.
        ENDIF.
    ENDIF.
* End Add by Fany 16-May-2025 For Laminator Subcont Project

    PERFORM ADD_PART_A214.

    "GET MATERIAL TYPE FROM SO CUST. NUMB --30-8-2017
    CLEAR : V_GETMATRTYPE .
    SELECT SINGLE TEXT3 INTO "Added by Fany 17.07.2024
      V_GETMATRTYPE
      FROM ZMAP_LABEL WHERE
      CODE = V_LABELTYPE AND TYPE = 'DOS' AND TEXT3 = 'MATRTYPE'.
    IF  V_GETMATRTYPE NE ''.
      PERFORM GET_MATRLTYPE.
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
*&      Form  get_inch_fr_so
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_INCH_FR_SO USING V_S_INCH.
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
      CLIENT                  = SY-MANDT
      ID                      = 'Z001'
      LANGUAGE                = 'E'
      NAME                    = V_TDNAME
      OBJECT                  = 'VBBP'
    TABLES
      LINES                   = IT_LINES
* START EDITED BY TRST-FIQIH 07.09.2026 - Penanganan exception READ_TEXT agar tidak dump saat text SO kosong
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.
* END EDITED BY TRST-FIQIH 07.09.2026 - Penanganan exception READ_TEXT agar tidak dump saat text SO kosong

  IF SY-SUBRC = 0.
    READ TABLE IT_LINES WITH KEY TDLINE+0(2) = 'W2'.
    IF SY-SUBRC = 0.
      V_S_INCH = IT_LINES-TDLINE+3(20).
    ENDIF.
  ENDIF.

* START ADD BY TRST-FIQIH 15.09.2026 - Pesan Error jika Inch kosong
  IF V_S_INCH IS INITIAL.
    DATA: LV_MSG_INCH TYPE STRING.
    CONCATENATE 'SO' V_SONUM1 'Item' V_SONUM2 'tidak memiliki teks Packing Instruction (W2) untuk lebar Inch'
      INTO LV_MSG_INCH SEPARATED BY SPACE.
    MESSAGE LV_MSG_INCH TYPE 'E'.
  ENDIF.
* END ADD BY TRST-FIQIH 15.09.2026 - Pesan Error jika Inch kosong
ENDFORM.                    "get_inch_fr_so

*&---------------------------------------------------------------------*
*&      Form  GET_FEET_FR_SO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_S_FEET   text
*----------------------------------------------------------------------*
FORM GET_FEET_FR_SO USING V_S_FEET.
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
      CLIENT                  = SY-MANDT
      ID                      = 'Z001'
      LANGUAGE                = 'E'
      NAME                    = V_TDNAME
      OBJECT                  = 'VBBP'
    TABLES
      LINES                   = IT_LINES
* START EDITED BY TRST-FIQIH 07.09.2026 - Penanganan exception READ_TEXT agar tidak dump saat text SO kosong
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.
* END EDITED BY TRST-FIQIH 07.09.2026 - Penanganan exception READ_TEXT agar tidak dump saat text SO kosong

  IF SY-SUBRC = 0.
    READ TABLE IT_LINES WITH KEY TDLINE+0(2) = 'L2'.
    IF SY-SUBRC = 0.
      V_S_FEET = IT_LINES-TDLINE+3(20).
    ENDIF.
  ENDIF.

* START ADD BY TRST-FIQIH 07.09.2026 - Default Feet Label D212 & Pesan Error jika Feet kosong
  IF V_LABELTYPE = 'D212' AND V_S_FEET IS INITIAL.
    DATA: WA_TAB_LOC LIKE LINE OF V_TAB,
          LV_LEN_D212(30) TYPE C.
    READ TABLE V_TAB INTO WA_TAB_LOC WITH KEY ATNAM = 'ZZLENGTH'.
    IF SY-SUBRC = 0.
      LV_LEN_D212 = WA_TAB_LOC-ATWTB.
      REPLACE ALL OCCURRENCES OF ',' IN LV_LEN_D212 WITH SPACE.
      REPLACE ALL OCCURRENCES OF '.' IN LV_LEN_D212 WITH SPACE.
      CONDENSE LV_LEN_D212 NO-GAPS.

      IF LV_LEN_D212 CS '6098' OR WA_TAB_LOC-ATWRT CS '6098'.
        V_S_FEET = '20,000'.
      ELSEIF LV_LEN_D212 CS '18293' OR WA_TAB_LOC-ATWRT CS '18293'.
        V_S_FEET = '60,000'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF V_S_FEET IS INITIAL.
    DATA: LV_MSG_FEET TYPE STRING.
    CONCATENATE 'SO' V_SONUM1 'Item' V_SONUM2 'tidak memiliki teks Packing Instruction (L2) untuk panjang Feet'
      INTO LV_MSG_FEET SEPARATED BY SPACE.
    MESSAGE LV_MSG_FEET TYPE 'E'.
  ENDIF.
* END ADD BY TRST-FIQIH 07.09.2026 - Default Feet Label D212 & Pesan Error jika Feet kosong
ENDFORM.                    "GET_FEET_FR_SO

*&---------------------------------------------------------------------*
*&      Form  add_part_a214
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ADD_PART_A214.
  IF V_LABELTYPE = 'A214' OR  V_LABELTYPE = 'A215'  OR  V_LABELTYPE = 'E201'.
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
      CONCATENATE '<STX><ESC>F"PART  "<LF>' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.       APPEND TEXT_DATA.
    ENDIF.
  ENDIF.
ENDFORM.                    "add_part_a214


*&---------------------------------------------------------------------*
*&      Form  GET_MATRLTYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_MATRLTYPE.
  CLEAR: V_PARTNO.

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
    CONCATENATE '<STX><ESC>F"PART  "<LF>' V_PARTNO '<ETX>' INTO TEXT_DATA-STR_TEXT.
    APPEND TEXT_DATA.
  ENDIF.

ENDFORM.                    "GET_MATRLTYPE
*&---------------------------------------------------------------------*
*&      Form  GET_ACTDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ACTDATA CHANGING P_ACTWEIG P_ACTLENG.

  DATA: V_STOUCH3     TYPE STRING,
        V_ACTLENG(30) TYPE C,
        V_ACTWEIG(30) TYPE C,
        V_ACTCORE(30) TYPE C.

  CLEAR: V_ACTLENG, V_ACTWEIG, V_ACTCORE, V_STOUCH3.
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPECIALTOUCH-3'.
  IF SY-SUBRC = 0.
    V_STOUCH3 = V_TAB-ATWRT.
    SPLIT V_STOUCH3 AT '-' INTO V_ACTLENG V_ACTWEIG V_ACTCORE.

    "Get Act Length
    P_ACTLENG = V_ACTLENG.

    "Get Act Weight
    REPLACE ALL OCCURRENCES OF ',' IN V_ACTWEIG WITH SPACE.
    CONDENSE V_ACTWEIG NO-GAPS.
    P_ACTWEIG = V_ACTWEIG.
  ENDIF.

ENDFORM.                    " GET_ACTDATA

*&---------------------------------------------------------------------*
*&      Form  CONVERSION_WEIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ATFLV      text
*      -->WEIGHT     text
*----------------------------------------------------------------------*
FORM CONVERSION_WEIGHT USING ATFLV CHANGING WEIGHT.
  DATA: TOCHAR1 TYPE P DECIMALS 2,
        TOCHAR2 TYPE P DECIMALS 1.

  TOCHAR1 = ATFLV.

  CALL FUNCTION 'ROUND'
    EXPORTING
      DECIMALS      = 1
      INPUT         = TOCHAR1
      SIGN          = '-'
    IMPORTING
      OUTPUT        = TOCHAR2
    EXCEPTIONS
      INPUT_INVALID = 1
      OVERFLOW      = 2
      TYPE_INVALID  = 3
      OTHERS        = 4.

  IF SY-SUBRC EQ 0.
    WEIGHT = TOCHAR2.
  ENDIF.
ENDFORM.                    "CONVERSION_WEIGHT