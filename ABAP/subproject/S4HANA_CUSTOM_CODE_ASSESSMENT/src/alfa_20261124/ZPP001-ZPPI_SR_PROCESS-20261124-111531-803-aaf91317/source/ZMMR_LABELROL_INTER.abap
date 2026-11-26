*&---------------------------------------------------------------------*
*&      Form  inter_text_data2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM INTER_TEXT_DATA2 .
* Get SO NUmber and Item from last Batch
  DATA : "v_aufnr_inter TYPE afpo-aufnr,
         V_AUFNR_INTER_COMBINE TYPE AFPO-AUFNR,
         V_AUFNR_INTER_ORIGINAL TYPE AFPO-AUFNR,
         V_CHARG_DIGITREF TYPE AFPO-CHARG,
         V_AUFNR_TEMP TYPE AFPO-AUFNR.

  DATA : ITAB_CONSTANT LIKE ZCONSTANT.
  DATA :
        V_C_FEET_INTER_BOPET  TYPE P DECIMALS 5  VALUE '3.2801',
        V_C_INCH_INTER  TYPE P DECIMALS 7 VALUE '0.0392100',
        V_C_LBS  TYPE P DECIMALS 4 VALUE '2.2046',
        V_C_GAUGE VALUE 4,
        V_PART(40) TYPE C,
        V_LEN_LENGTH(2) VALUE 6,
        V_LEN_FEET(2) VALUE 7,
        V_INFO_THICKNESS(20) TYPE C.



  CLEAR: V_VBELN, V_POSNR, V_SONUM_ITEM.



*Get Net weight...
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
*    ENDLOOP.

*    IF v_der = 'W'.
*      SELECT SINGLE derivativems positionms derivativess positionss grade length1 length2 zconv aufnr
*      INTO (v_derivativems, v_positionms, v_derivativess, v_positionss, v_grade, v_splice1_d, v_splice2_d, v_zconv, v_aufnr_inter_original )
*      FROM zdigitctl
*      WHERE
*      zdigitctl~aufnr EQ v_aufnr AND
*      zdigitctl~positionss EQ v_pos.
*    ELSEIF v_der = 'M'.
*      SELECT SINGLE derivativems positionms derivativess positionss grade length1 length2 zconv aufnr
*      INTO (v_derivativems, v_positionms, v_derivativess, v_positionss, v_grade, v_splice1_d, v_splice2_d, v_zconv, v_aufnr_inter_original )
*      FROM zdigitctl
*      WHERE
*      zdigitctl~aufnr EQ v_aufnr AND
*      zdigitctl~positionms EQ v_pos.
*    ENDIF.
  ENDIF.

*** get constant from SONUM text
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


  CONCATENATE V_CHARG V_DERIVATIVEMS V_POSITIONMS V_DERIVATIVESS  V_POSITIONSS INTO V_BARCODE.


  CALL FUNCTION 'CONVERSION_EXIT_BAS36_OUTPUT'
    EXPORTING
      INPUT          = V_BARCODE
    IMPORTING
      OUTPUT         = V_BARCODE
    EXCEPTIONS
      INVALID_FORMAT = 1
      OTHERS         = 2.

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

* Modified (PRA) 14/03/05
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
    V_TAB-ATWTB = V_CHARG.
    APPEND V_TAB.

*Add Interfilm Part Number
    V_TAB-ATNAM = 'ZZBASE'.
    V_TAB-ATWTB = V_PART.
    APPEND V_TAB.


*Mod Left Justified
    CLEAR : V_S_SPLICE1,
            V_S_SPLICE2.

    IF ( V_SPLICE1_D NE 0 ).

      V_TAB-ATNAM = 'ZZSPLICE-1'.


      PERFORM CONV_TO_CHAR USING V_SPLICE1_D.
      V_SPLICE1_INTER = V_SPLICE1_D * V_C_FEET_INTER_BOPET.
      WRITE V_SPLICE1_INTER TO V_S_SPLICE1.

      CONDENSE V_S_SPLICE1 NO-GAPS.

      V_SPLICE1_MIRING = V_SPLICE1_D.
      WRITE V_SPLICE1_MIRING TO V_TAB-ATWTB.

      IF V_SPLICE1_D = 0.
        V_TAB-ATWTB = ''.
        V_S_SPLICE1 = ''.
      ENDIF.
      PERFORM RIGHT_JUSTIFIED USING V_LEN_LENGTH
                                    V_TAB-ATWTB.

      APPEND V_TAB.

    ENDIF.

    IF ( V_SPLICE2_D NE 0 ).

      V_TAB-ATNAM = 'ZZSPLICE-2'.

      PERFORM CONV_TO_CHAR USING V_SPLICE2_D.
      V_SPLICE2_INTER = V_SPLICE2_D * V_C_FEET_INTER_BOPET.
      WRITE V_SPLICE2_INTER TO V_S_SPLICE2.
      CONDENSE V_S_SPLICE2 NO-GAPS.

      V_SPLICE2_MIRING = V_SPLICE2_D.
      WRITE V_SPLICE2_MIRING TO V_TAB-ATWTB.

      IF V_SPLICE2_D = 0.
        V_TAB-ATWTB = ''.
        V_S_SPLICE2 = ''.
      ENDIF.
      PERFORM RIGHT_JUSTIFIED USING V_LEN_LENGTH
                                    V_TAB-ATWTB.
      APPEND V_TAB.
    ENDIF.
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

*Interfillm
        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        REPLACE ALL OCCURRENCES OF '.0' IN V_TAB-ATWTB WITH ' '.

*Start add condition for new type label L012 (Display Thickness(Gauge))
        IF V_LABELTYPE = 'L012'.
          V_GAUGE = V_TAB-ATWTB * V_C_GAUGE.
          WRITE V_GAUGE TO V_S_GAUGE.

          V_THICKNESS = V_TAB-ATWTB.

          CONDENSE V_THICKNESS NO-GAPS.
          CONDENSE V_S_GAUGE NO-GAPS.
          CONCATENATE V_THICKNESS ' mic.   ' V_S_GAUGE ' ga.' INTO V_INFO_THICKNESS.

          V_TAB-ATWTB = ''.
          V_S_GAUGE = ''.

        ELSE.
          V_GAUGE = V_TAB-ATWTB * V_C_GAUGE.
          WRITE V_GAUGE TO V_S_GAUGE.

          PERFORM RIGHT_JUSTIFIED USING V_LEN_MIC
                                        V_TAB-ATWTB.

          CONDENSE V_S_GAUGE NO-GAPS.

          V_THICKNESS = V_TAB-ATWTB.
        ENDIF.
*End add condition for new type label L012 (Display Thickness(Gauge))
      ENDIF.

* Get The Width value(MM -> Inch)
      IF V_ZLABEL-ATNAM = 'ZZWIDTH'.

*mode alias-------------------------
        IF V_FLAG_ZZALIAS = 'X' AND V_FLAG_WEIGHT_ZZALIAS = 'X'.
          V_TAB-ATWTB = WA_WIDTH.
        ENDIF.

*Interfillm
        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.

        IF ( V_LABELORIG = 'A014' OR V_LABELORIG = 'A015' OR V_LABELORIG = 'A020').
          DATA : V_INCH TYPE P DECIMALS 3.
        ELSE.
        ENDIF.

        V_INCH =   V_TAB-ATWTB * V_C_INCH_INTER.

        WRITE V_INCH TO V_S_INCH.

        CONDENSE V_S_INCH NO-GAPS.

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

*Interfillm
        PERFORM CONV_TO_CHAR USING V_TAB-ATWTB.
        V_FEET_INTER  = V_TAB-ATWTB * V_C_FEET_INTER_BOPET.
        WRITE V_FEET_INTER TO V_S_FEET.


        PERFORM RIGHT_JUSTIFIED USING V_LEN_NORMAL
                                      V_S_FEET.
        CONDENSE V_S_FEET NO-GAPS.


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

*Interfillm

        PERFORM CONV_TO_CHAR_3_DEC USING V_TAB-ATWTB.
        V_LBS = V_TAB-ATWTB * V_C_LBS.
        WRITE V_LBS TO V_S_LBS.

        CONDENSE V_S_LBS NO-GAPS.

        V_WEIGHT = V_TAB-ATWTB.
        WRITE V_WEIGHT TO V_TAB-ATWTB.
**mode 3 decimal
        PERFORM RIGHT_JUSTIFIED_3 USING  V_LEN_WEIGHT "v_len_normal
                                      V_TAB-ATWTB.

      ENDIF.

*Core
      IF V_ZLABEL-ATNAM = 'ZZCORE'.

*Interfilm
        CONCATENATE V_TAB-ATWRT '"' INTO V_TAB-ATWRT.
*        WRITE v_tab-atwrt TO v_tab-atwtb.
      ENDIF.

*Inside & Outside
      IF V_ZLABEL-ATNAM = 'ZZINSIDE' OR V_ZLABEL-ATNAM = 'ZZOUTSIDE'.

*Interfilm
        IF ( V_LABELTYPE EQ 'A014' OR V_LABELTYPE EQ 'A015' OR V_LABELTYPE EQ 'A016' OR V_LABELTYPE EQ 'A017' OR V_LABELTYPE EQ 'A018'
             OR V_LABELTYPE EQ 'A019' OR V_LABELTYPE EQ 'A020' OR V_LABELTYPE EQ 'A021' ).
          V_TAB-ATWTB = ''.
        ELSE.
          IF V_TAB-ATWTB = 'NONE'.
            V_TAB-ATWTB = ''.
          ENDIF.
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


*Mod Interfilm
  LOOP AT V_ZLABEL.

    IF V_ZLABEL-ATNAM = 'ZZGAUGE'.
      I_GAUGE = V_ZLABEL-DATA2.
      CONDENSE I_GAUGE NO-GAPS.
    ENDIF.


    IF V_ZLABEL-ATNAM = 'ZZTHICKNESS'.
      I_MICRON = V_ZLABEL-DATA2.
      CONDENSE I_MICRON NO-GAPS.
    ENDIF.


    IF V_ZLABEL-ATNAM = 'ZZINCHX'.
      I_INCH = V_ZLABEL-DATA2.
      CONDENSE I_INCH NO-GAPS.
    ENDIF.


    IF V_ZLABEL-ATNAM = 'ZZWIDTH'.
      I_MILI = V_ZLABEL-DATA2.
      CONDENSE I_MILI NO-GAPS.
    ENDIF.


    IF V_ZLABEL-ATNAM = 'ZZFEETX'.
      I_FEET = V_ZLABEL-DATA2.
      CONDENSE I_FEET NO-GAPS.
    ENDIF.


    IF V_ZLABEL-ATNAM = 'ZZLENGTH'.
      I_METERS = V_ZLABEL-DATA2.
      CONDENSE I_METERS NO-GAPS.
    ENDIF.

    IF V_ZLABEL-ATNAM = 'ZZLBS'.
      I_LBS = V_ZLABEL-DATA2.
      CONDENSE I_LBS NO-GAPS.
    ENDIF.


    IF V_ZLABEL-ATNAM = 'ZZWEIGHT'.
      I_KGS = V_ZLABEL-DATA2.
      CONDENSE I_KGS NO-GAPS.
    ENDIF.

  ENDLOOP.



*Mod Interfilm
  LOOP AT V_ZLABEL.
    V_TABIX = SY-TABIX.

*Mod Thickness
    IF V_ZLABEL-ATNAM = 'ZZGAUGE'.
      CONCATENATE I_GAUGE ' gauge ' '( ' I_MICRON ' micron )' INTO I_GAUGE.
      V_ZLABEL-DATA2 = I_GAUGE.
      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*Mod Width
    IF V_ZLABEL-ATNAM = 'ZZINCHX'.
      CONCATENATE I_INCH '"' '( ' I_MILI ' mm )' INTO I_INCH.

      V_ZLABEL-DATA2 = I_INCH.
      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*Mod Length
    IF V_ZLABEL-ATNAM = 'ZZFEETX'.
      CONCATENATE I_FEET ' feet ' '( ' I_METERS ' meters )' INTO I_FEET.

      V_ZLABEL-DATA2 = I_FEET.
      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*Mod Weight
    IF V_ZLABEL-ATNAM = 'ZZLBS'.
      CONCATENATE I_LBS ' lbs ' '( ' I_KGS ' kgs )' INTO I_LBS.
      V_ZLABEL-DATA2 = I_LBS.

      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*Remove Weight
    IF V_ZLABEL-ATNAM = 'ZZWEIGHT'.
      V_ZLABEL-DATA2 = ''.

      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*Remove Length
    IF V_ZLABEL-ATNAM = 'ZZLENGTH'.
      V_ZLABEL-DATA2 = ''.

      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*Remove Length
    IF V_ZLABEL-ATNAM = 'ZZWIDTH'.
      V_ZLABEL-DATA2 = ''.

      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*Remove Length
    IF V_ZLABEL-ATNAM = 'ZZTHICKNESS'.
      V_ZLABEL-DATA2 = ''.

      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*add barc1
    IF V_ZLABEL-ATNAM = 'ZZBARC1'.
      CONCATENATE V_CHARG '-' V_BARCODE INTO V_ZLABEL-DATA2.

      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*add Part
    IF V_ZLABEL-ATNAM = 'ZZBASE'.
      V_ZLABEL-DATA2 = V_P1.

      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

*add Job
    IF V_ZLABEL-ATNAM = 'ZZCOAT'.
      V_ZLABEL-DATA2 = V_J1.

      MODIFY V_ZLABEL INDEX V_TABIX.
    ENDIF.

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

    READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
*--- get data ATWRT (Characteristic Value)
    IF V_TAB-ATWRT = 'L001' OR V_TAB-ATWRT = 'L002' OR V_TAB-ATWRT = 'L003' OR V_TAB-ATWRT = 'L004' OR V_TAB-ATWRT = 'L005'
                            OR V_TAB-ATWRT = 'G001'
                            OR V_TAB-ATWRT = 'L011' OR V_TAB-ATWRT = 'L012'.
      LOOP AT V_ZLABEL.
        CLEAR TEXT_DATA.
        IF   V_ZLABEL-ATNAM = 'ZZTEXT1'.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_INFO_THICKNESS '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZFEETX'.
*          CONCATENATE v_l2 ' feet ' '( ' v_l1 ' meters )' INTO v_s_feet_inter.
          CONDENSE V_L2.
          V_S_FEET_INTER = V_L2.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_FEET_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSEIF V_ZLABEL-ATNAM = 'ZZLENGTH'.
          CLEAR TEXT_DATA-STR_TEXT.
          CONDENSE V_L1.
          V_S_FEET_INTER = V_L1.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_FEET_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSEIF V_ZLABEL-ATNAM = 'ZZINCHX'.
*          CONCATENATE v_w2 '" ' '( ' v_w1 ' mm )' INTO v_s_inch_inter.
          CONDENSE V_W2.
          V_S_INCH_INTER = V_W2.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_INCH_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSEIF V_ZLABEL-ATNAM = 'ZZWIDTH'.
          CLEAR TEXT_DATA-STR_TEXT.
          CONDENSE V_W1.
          V_S_INCH_INTER = V_W1.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_INCH_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSEIF V_ZLABEL-ATNAM = 'ZZLBS'.
*          CONCATENATE v_n2 ' lbs ' '( ' v_n1 ' kgs )' INTO v_s_lbs_inter.
          CONDENSE V_N2.
          V_S_LBS_INTER = V_N2.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_LBS_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSEIF V_ZLABEL-ATNAM = 'ZZWEIGHT'.
          CLEAR TEXT_DATA-STR_TEXT.
          CONDENSE V_N1.
          V_S_LBS_INTER = V_N1.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_LBS_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSEIF V_ZLABEL-ATNAM = 'ZZGAUGE'.
*          CONCATENATE v_t2 ' gauge ' '( ' v_t1 ' micron )' INTO v_s_gauge_inter.
*          CONCATENATE '<STX><ESC>' v_zlabel-data1 v_s_gauge_inter '<ETX>' INTO text_data-str_text.

        ELSEIF V_ZLABEL-ATNAM = 'ZZFEETS1'.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_FEET V_S_SPLICE1.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SPLICE1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZFEETS2'.
          PERFORM RIGHT_JUSTIFIED USING V_LEN_FEET V_S_SPLICE2.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_SPLICE2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZMT2'.
          CLEAR TEXT_DATA-STR_TEXT.
          CONDENSE V_S1.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZFT2'.
          CLEAR TEXT_DATA-STR_TEXT.
          CONDENSE V_S2.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZSOITEM'.
          WRITE V_SONUM1 TO TEXT_DATA-STR_TEXT NO-ZERO.
          WRITE V_SONUM2 TO V_TDNAME NO-ZERO.
          CONDENSE TEXT_DATA-STR_TEXT.
          CONDENSE V_TDNAME.

          CONCATENATE TEXT_DATA-STR_TEXT '/' V_TDNAME INTO TEXT_DATA-STR_TEXT.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 TEXT_DATA-STR_TEXT '<ETX>' INTO TEXT_DATA-STR_TEXT.


        ELSEIF V_ZLABEL-ATNAM = 'ZZCRITERIA'.
        ELSEIF V_ZLABEL-ATNAM = 'ZZNUMBEROFSHEET' AND V_SUM_QTYSHEET <> ''.
        ELSE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.

        APPEND TEXT_DATA.
      ENDLOOP.
    ELSE.
*Combine all command into internal table.
*--- get data ATWTB (Characteristic value description)
      LOOP AT V_ZLABEL.
* Get the strlen variable and substract from v_strlen for purpose right justified.
        IF V_ZLABEL-ATNAM = 'ZZFEETX'.
*Interfilm
*        CONCATENATE v_s_feet ' feet ' '( ' i_meters ' meters )' INTO v_s_feet_inter.
          CONCATENATE V_L2 ' feet ' '( ' V_L1 ' meters )' INTO V_S_FEET_INTER.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_FEET_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSEIF V_ZLABEL-ATNAM = 'ZZINCHX'.
*Interfilm
*        CONCATENATE v_s_inch '" ' '( ' i_mili ' mm )' INTO v_s_inch_inter.
          CONCATENATE V_W2 '" ' '( ' V_W1 ' mm )' INTO V_S_INCH_INTER.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_INCH_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSEIF V_ZLABEL-ATNAM = 'ZZLBS'.
*Interfilm
*        CONCATENATE v_s_lbs ' lbs ' '( ' i_kgs ' kgs )' INTO v_s_lbs_inter.
          CONCATENATE V_N2 ' lbs ' '( ' V_N1 ' kgs )' INTO V_S_LBS_INTER.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_LBS_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

        ELSEIF V_ZLABEL-ATNAM = 'ZZGAUGE'.
*Interfilm
*        CONCATENATE v_s_gauge ' gauge ' '( ' i_micron ' micron )' INTO v_s_gauge_inter.
          CONCATENATE V_T2 ' gauge ' '( ' V_T1 ' micron )' INTO V_S_GAUGE_INTER.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_GAUGE_INTER '<ETX>' INTO TEXT_DATA-STR_TEXT.

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
        ELSEIF
         V_ZLABEL-ATNAM = 'ZZSOITEM'.
        ELSEIF
          V_ZLABEL-ATNAM = 'ZZNUMBEROFSHEET' AND V_SUM_QTYSHEET <> ''.
        ELSE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.

        APPEND TEXT_DATA.
      ENDLOOP.
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

ENDFORM.                    " inter_text_data2