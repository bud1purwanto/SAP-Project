*&---------------------------------------------------------------------*
*&  Include           ZTEST_INCL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  text_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

DATA: WA_VTAB LIKE V_TAB OCCURS 0 WITH HEADER LINE,
      VTYPE(10),
      VWIDTH(10),
      VLENGTH(10),
      VNWEIGHT(10),
      VINCH(10),
      VFEET(10),
      VLBS(10),
      VROLL(50),
*      VSO(20),
*      VITEM(10),
      VCORE(20),
      VTHICK(20),
      VUSED(10),
      VINSIDE(20),
      VOUTSIDE(20),
      VBARCTEXT(30),
      VBARCTEXT2(30),
      VBARCODE1(20),
      VBARCODE2(20).

DATA :V_FORMNAME  TYPE TDSFNAME  VALUE 'ZLABEL_A131',
        V_FUNCNAME  TYPE RS38L_FNAM,
         CRKMNG(10)  TYPE C.

*&---------------------------------------------------------------------*
*&      Form  TEXT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TEXT_DATA.

  CLEAR: VTYPE,VWIDTH,VLENGTH,VNWEIGHT,VINCH,VFEET,VLBS,VROLL,VCORE,VTHICK,VUSED,VINSIDE,VOUTSIDE,VBARCTEXT,
      VBARCTEXT2,VBARCODE1,VBARCODE2.
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
          V_FEET_INTER  = V_TAB-ATWTB * V_C_FEET_INTER.
          WRITE V_FEET_INTER TO V_S_FEET.
          V_LENGTH = V_TAB-ATWTB.
          WRITE V_LENGTH TO V_TAB-ATWTB.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                        V_TAB-ATWTB.
        ELSE.

          PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
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
        V_LOTNO(40) TYPE C.

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
      OR V_LABELTYPE = 'A121' OR V_LABELTYPE = 'A122' OR V_LABELTYPE = 'A129'
      OR V_LABELTYPE = 'D113' OR V_LABELTYPE = 'D117' OR V_LABELTYPE = 'D118' OR V_LABELTYPE = 'D119'
      OR V_LABELTYPE = 'E112' OR V_LABELTYPE = 'E113' OR V_LABELTYPE = 'E114'
      OR V_LABELTYPE = 'F108' OR V_LABELTYPE = 'F109'
      OR V_LABELTYPE = 'I102' OR V_LABELTYPE = 'E117' OR V_LABELTYPE = 'E118'
      OR V_LABELTYPE = 'A109' OR V_LABELTYPE = 'G103' OR V_LABELTYPE = 'N101').
        V_TAB-ATNAM = 'ZZEX'.
        CONCATENATE V_POSTDATE+0(4) '.' V_POSTDATE+4(2) INTO V_TAB-ATWTB.
        APPEND V_TAB.

      ELSE.
*--- add by ALF when J107-J108 use production Date.
        IF V_LABELTYPE = 'J107' OR V_LABELTYPE = 'J108' OR V_LABELTYPE = 'D109' OR V_LABELTYPE = 'D110'
            OR V_LABELTYPE = 'J116'  OR V_LABELTYPE = 'J117' OR V_LABELTYPE = 'J112' OR V_LABELTYPE = 'B102'
            OR V_LABELTYPE = 'J103' OR V_LABELTYPE = 'J113' OR V_LABELTYPE = 'J120' OR V_LABELTYPE = 'J121'
            OR V_LABELTYPE = 'J118' OR V_LABELTYPE = 'J119' OR V_LABELTYPE = 'E209'.
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

  " TO SMARTFORMS

  READ TABLE V_TAB INTO WA_VTAB WITH KEY ATNAM = 'ZZCODE'.
  VTYPE = WA_VTAB-ATWTB. CLEAR WA_VTAB.
  READ TABLE V_TAB INTO WA_VTAB WITH KEY ATNAM = 'ZZCORE'.
  VCORE = WA_VTAB-ATWTB. CLEAR WA_VTAB.
  CONCATENATE VCORE 'CORE' INTO VCORE.
  READ TABLE V_TAB INTO WA_VTAB WITH KEY ATNAM = 'ZZROLLNO'.
  VROLL = WA_VTAB-ATWTB. CLEAR WA_VTAB.
  READ TABLE V_TAB INTO WA_VTAB WITH KEY ATNAM = 'ZZBARC'.
  VBARCODE1 = WA_VTAB-ATWTB. CLEAR WA_VTAB.
  READ TABLE V_TAB INTO WA_VTAB WITH KEY ATNAM = 'ZZBARC1'.
  VBARCTEXT = WA_VTAB-ATWTB. CLEAR WA_VTAB.
  READ TABLE V_TAB INTO WA_VTAB WITH KEY ATNAM = 'ZZINSIDE'.
  VINSIDE = WA_VTAB-ATWTB. CLEAR WA_VTAB.
  READ TABLE V_TAB INTO WA_VTAB WITH KEY ATNAM = 'ZZOUTSIDE'.
  VOUTSIDE = WA_VTAB-ATWTB. CLEAR WA_VTAB.
  READ TABLE V_TAB INTO WA_VTAB WITH KEY ATNAM = 'ZZEX'.
  VUSED = WA_VTAB-ATWTB. CLEAR WA_VTAB.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZWEIGHT'.
  IF SY-SUBRC = 0.
    VNWEIGHT = V_TAB-ATWTB.
    PERFORM CONV_TO_CHAR_3_DEC USING V_TAB-ATWTB.
    V_LBS = V_TAB-ATWTB * V_C_LBS.
    WRITE V_LBS TO VLBS.
  ELSE.
    READ TABLE V_TAB WITH KEY ATNAM = 'ZZWEIGH'.
    VNWEIGHT = V_TAB-ATWTB.
    PERFORM CONV_TO_CHAR_3_DEC USING V_TAB-ATWTB.
    V_LBS = V_TAB-ATWTB * V_C_LBS.
    WRITE V_LBS TO VLBS.
  ENDIF.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZWIDTH'.
  VWIDTH = V_TAB-ATWTB.
  IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
    V_TAB-ATWTB = WA_WIDTH.
  ENDIF.
  PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
  V_INCH =   V_TAB-ATWTB * V_C_INCH.
  WRITE V_INCH TO VINCH.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZLENGTH'.
  VLENGTH = V_TAB-ATWTB.
  IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
    V_TAB-ATWTB = WA_LENGT.
  ENDIF.
  PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
  V_FEET   = V_TAB-ATWTB * V_C_FEET.
  WRITE V_FEET TO VFEET.
  REPLACE ALL OCCURRENCES OF '.0' IN VFEET WITH ' '.

* Get the Thickness value(Mic -> Gauge)
  READ TABLE V_TAB WITH KEY ATNAM = 'ZZTHICKNESS'.
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
  V_THICKNESS = V_TAB-ATWTB.
  CONDENSE V_THICKNESS NO-GAPS.
  CONCATENATE V_THICKNESS ' mic.   ' V_S_GAUGE ' ga.' INTO V_INFO_THICKNESS.
  V_TAB-ATWTB = ''.
  V_S_GAUGE = ''.
  VTHICK = V_INFO_THICKNESS.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  CALL FUNCTION V_FUNCNAME
    EXPORTING
      V_TYPE = VTYPE
      V_WIDTH = VWIDTH
      V_LENGTH = VLENGTH
      V_NWEIGHT = VNWEIGHT
      V_INCH = VINCH
      V_FEET = VFEET
      V_LBS = VLBS
      V_ROLL = VROLL
      V_CORE = VCORE
      V_THICK = VTHICK
      V_USED = VUSED
      V_INSIDE = VINSIDE
      V_OUTSIDE = VOUTSIDE
      V_BARCTEXT = VBARCTEXT
      V_BARCTEXT2 = VBARCTEXT2
      V_BARCODE1 = VBARCODE1
      V_BARCODE2 = VBARCODE2
      V_SONUM = V_SONUM_ITEM
*  TABLES
*    T_MSEG               = I_MSEG
  .


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
      CLIENT   = SY-MANDT
      ID       = 'Z001'
      LANGUAGE = 'E'
      NAME     = V_TDNAME
      OBJECT   = 'VBBP'
    TABLES
      LINES    = IT_LINES.

  IF SY-SUBRC = 0.
    READ TABLE IT_LINES WITH KEY TDLINE+0(2) = 'W2'.
    IF SY-SUBRC = 0.
      V_S_INCH = IT_LINES-TDLINE+3(20).
    ENDIF.
  ENDIF.
ENDFORM.                    "get_inch_fr_so



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