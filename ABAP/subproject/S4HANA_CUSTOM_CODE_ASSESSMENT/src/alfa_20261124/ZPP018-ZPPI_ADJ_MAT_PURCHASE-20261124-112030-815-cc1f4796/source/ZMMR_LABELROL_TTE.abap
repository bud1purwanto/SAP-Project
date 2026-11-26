*&---------------------------------------------------------------------*
*&      Include  ZMMR_LABELROL_TTE
*&---------------------------------------------------------------------*
*& Appl. Area :  MM
*& Created by :  Akbar
*&---------------------------------------------------------------------*
*& Program - Print Label TTE
*& 22 Mei 2019
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*&      Form  TYB_TEXT_DATA_TTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM TYB_TEXT_DATA_TTE .
    DATA : V_TY_ROLLN(10),
           V_TY_LOTN(6),
           V_TY_SPLICE1(10),
           V_TY_SPLICE2(10),
           V_TY_SPLICE3(10),
           V_TY_TEXT1(21),
           V_TY_TEXT2(21),
           V_TY_TEXT3(21),
           V_TY_QRTEXT(42),
           V_S_THICKNESS(3),
           V_TY_LOWER123(3),
           V_S_WIDTH(5),
           V_S_LENGTH(6),
           V_S_WEIGHT(8),
           V_J1(2),
           V_YEAR(2),
           V_GRADE(2),
           V_CDGRD(2),
           V_GRADEDESC(15),
           V_TAILORED(2),
           V_MONTH(2),
           V_DATE(3),
           V_LENGRD TYPE I,
           V_BLN TYPE I,
           V_BLN_A TYPE I,
           V_BLN_GANJIL TYPE STRING,
           V_BLN_B TYPE I,
           V_BLN_GENAP TYPE STRING.

    DATA: V_IMAG(2).
    DATA: V_CORDNT(4).

    CONCATENATE FILE_DIR  'DATA' '.BAT' INTO FILE_B.

    CLEAR : V_FLAG_ZZALIAS, V_TYPE, V_LABELTYPE.

    SORT V_TAB BY ATNAM.
    LOOP AT V_TAB.

      V_FLAG_ZZALIAS = ''. "Reset flag alias to ''.

      IF V_TAB-ATNAM = 'ZZALIAS'.     "Ambil value tipe film by Character Alias
        V_TYPE = V_TAB-ATWRT.
        V_FLAG_ZZALIAS = 'X'.
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

      IF V_TAB-ATNAM = 'ZZLABEL'.
        V_LABELTYPE = V_TAB-ATWRT.
        V_LABELIMGNEW = V_TAB-ATWRT.
      ENDIF.

      IF V_TAB-ATNAM = 'ZZSPLICE-1'.
        REPLACE ALL OCCURRENCES OF ',' IN  V_TAB-ATWTB WITH ''.
        V_TY_SPLICE1 = V_TAB-ATWTB.
      ENDIF.

      IF V_TAB-ATNAM = 'ZZSPLICE-2'.
        REPLACE ALL OCCURRENCES OF ',' IN  V_TAB-ATWTB WITH ''.
        V_TY_SPLICE2 = V_TAB-ATWTB.
      ENDIF.

      IF V_TAB-ATNAM = 'ZZCONVERSIONROLLKG'.
        V_SUM_NETWEIGHT = V_TAB-ATFLV.
        V_S_WEIGHT = V_SUM_NETWEIGHT.  "Num to String
        PERFORM RIGHT_JUSTIFIED USING 8 V_S_WEIGHT.
      ENDIF.

      IF V_TAB-ATNAM = 'ZZNOROLLTOYOBO'.
        V_TY_ROLLN = V_TAB-ATWRT.

        "Start Rule 3 digit awal untuk hasil barcode ke-2
        V_YEAR =  V_TY_ROLLN+0(1).    "1 digit pertama
        V_MONTH =  V_TY_ROLLN+1(1).   "1 digit kedua => Value 1 - 6 (value 1 untuk bulan januari dan februari dst)
        V_DATE =  V_TY_ROLLN+2(2).    "2 digeit ketiga dan keempat

        CALL FUNCTION 'CONVERT_STRING_TO_INTEGER'
          EXPORTING
            P_STRING = V_MONTH
          IMPORTING
            P_INT    = V_BLN.   "Value 1 - 6 (1 untuk bulan januari dan februari dst)

        V_BLN_A = V_BLN * 2 - 1.  "int
        V_BLN_GANJIL = V_BLN_A.   "string
        V_BLN_B = V_BLN * 2.      "int
        V_BLN_GENAP = V_BLN_B.    "string

        IF V_DATE <= 50.                "Aturan Bulan Ganjil
          IF V_BLN_GANJIL < 10.
            CONCATENATE  V_YEAR '0' V_BLN_GANJIL  INTO V_TY_LOWER123.
          ELSEIF V_BLN_GANJIL >= 10.
            CONCATENATE  V_YEAR V_BLN_GANJIL  INTO V_TY_LOWER123.
          ENDIF.
        ELSEIF V_DATE > 50.             "Aturan Bulan Genap
          IF V_BLN_GENAP < 10.
            CONCATENATE  V_YEAR '0' V_BLN_GENAP  INTO V_TY_LOWER123.
          ELSEIF V_BLN_GENAP >= 10.
            CONCATENATE  V_YEAR V_BLN_GENAP  INTO V_TY_LOWER123.
          ENDIF.
        ENDIF.
        "End Rule 3 digit awal untuk hasil barcode ke-2

      ENDIF.

      IF V_TAB-ATNAM = 'ZZNOLOTTOYOBO'.
        V_TY_LOTN = V_TAB-ATWRT.
      ENDIF.

      IF V_TAB-ATNAM = 'ZZGRADE'.
        IF V_TAB-ATWTB CS '-'.
          SPLIT V_TAB-ATWTB AT '-' INTO V_GRADE V_GRADEDESC.
        ELSE.
          V_GRADE = V_TAB-ATWRT.
        ENDIF.
        V_CDGRD = V_GRADE.
*        PERFORM RIGHT_JUSTIFIED USING 2 V_GRADE.
      ENDIF.

      IF V_TAB-ATNAM = 'ZZTAILORED'.
        V_TAILORED = V_TAB-ATWRT.
        "Start Add by Fiqih - Hilangkan NC dari Category 08.07.2026
        IF V_TAILORED EQ 'NC'.
          V_TAILORED = ' '.
        ENDIF.
        "End Add by Fiqih - Hilangkan NC dari Category 08.07.2026
*        PERFORM RIGHT_JUSTIFIED USING 2 V_TAILORED.
      ENDIF.

    ENDLOOP.

*---------------------/
*Getting the data atnam from table zlabel.
    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE V_ZLABEL
    FROM ZLABEL.

    SORT V_ZLABEL BY ATNAM.
    LOOP AT V_ZLABEL.
      V_TABIX = SY-TABIX.
      CLEAR V_TAB-ATWTB.
      READ TABLE V_TAB WITH KEY ATNAM = V_ZLABEL-ATNAM.
      IF SY-SUBRC = 0.

        IF V_TAB-ATNAM = 'ZZTHICKNESS'.
          REPLACE ALL OCCURRENCES OF '.0' IN V_TAB-ATWTB WITH ' '.
          PERFORM TY_RIGHT_JUSTIFIED USING 3 V_TAB-ATWTB.
          V_S_THICKNESS = V_TAB-ATWTB.
        ENDIF.

        IF V_TAB-ATNAM = 'ZZWIDTH'.
          PERFORM TY_RIGHT_JUSTIFIED USING 4 V_TAB-ATWTB.
          V_S_WIDTH = V_TAB-ATWTB.
        ENDIF.

        IF V_TAB-ATNAM = 'ZZLENGTH'.
          PERFORM TY_RIGHT_JUSTIFIED USING 5 V_TAB-ATWTB.
          V_S_LENGTH = V_TAB-ATWTB.
        ENDIF.

        V_ZLABEL-DATA2 = V_TAB-ATWTB.
      ELSE.
        V_ZLABEL-DATA2 = ' '.
      ENDIF.

      MODIFY V_ZLABEL INDEX V_TABIX TRANSPORTING DATA2.
    ENDLOOP.

*---------------------/
*Getting image treatment characteristic.

    IF V_LABELIMGOLD <> V_LABELIMGNEW.

      REFRESH TEXT_DATA2.
      CLEAR TEXT_DATA2.

      CONCATENATE FILE_DIR  'CLEAR.TAX' INTO FILE_F.

      PERFORM GETFRSRV_F.
      TEXT_DATA2[] = IT[].

      LOOP AT TEXT_DATA2.
        TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
        APPEND TEXT_DATA.
      ENDLOOP.

      "----GET INSIDE
      CLEAR: V_ZLABELMAPIMAGE-IMAG1.
      REFRESH: V_ZLABELMAPIMAGE.
      LOOP AT V_TAB WHERE ATNAM = 'ZZINSIDE'.
        IF V_TAB-ATWRT = 'CO'.
          V_ZLABELMAPIMAGE-IMAG1 = 'IMGCORONA'.
          APPEND V_ZLABELMAPIMAGE.
        ELSEIF  V_TAB-ATWRT = 'CM'.
          V_ZLABELMAPIMAGE-IMAG1 = 'IMGCERAMIC'.
          APPEND V_ZLABELMAPIMAGE.
        ELSEIF V_TAB-ATWRT = 'CC'.
          V_ZLABELMAPIMAGE-IMAG1 = 'IMGCERCOAT'.
          APPEND V_ZLABELMAPIMAGE.
        ENDIF.

        IF V_ZLABELMAPIMAGE-IMAG1 EQ ''.
          EXIT.
        ELSE.
          V_IMAG   = 'G2'.
          V_CORDNT = 'INSD'.
          PERFORM F_LOADIMAGE_TTE USING V_CORDNT V_IMAG.
        ENDIF.
      ENDLOOP.

      "----GET OUTSIDE
      CLEAR: V_ZLABELMAPIMAGE-IMAG1.
      REFRESH: V_ZLABELMAPIMAGE.
      LOOP AT V_TAB WHERE ATNAM = 'ZZOUTSIDE'.
        IF V_TAB-ATWRT = 'CO'.
          V_ZLABELMAPIMAGE-IMAG1 = 'IMGCORONA'.
          APPEND V_ZLABELMAPIMAGE.
        ELSEIF V_TAB-ATWRT = 'CM'.
          V_ZLABELMAPIMAGE-IMAG1 = 'IMGCERAMIC'.
          APPEND V_ZLABELMAPIMAGE.
        ELSEIF V_TAB-ATWRT = 'CC'.
          V_ZLABELMAPIMAGE-IMAG1 = 'IMGCERCOAT'.
          APPEND V_ZLABELMAPIMAGE.
        ENDIF.

        IF V_ZLABELMAPIMAGE-IMAG1 EQ ''.
          EXIT.
        ELSE.
          V_IMAG   = 'G3'.
          V_CORDNT = 'OUTD'.
          PERFORM F_LOADIMAGE_TTE USING V_CORDNT V_IMAG.
        ENDIF.
      ENDLOOP.

    ENDIF.
*---------------------/

******
*  DO V_COPIES TIMES.     "Modified by AKBAR 27.11.2019 (Case on print data copies)
    REFRESH TEXT_DATA2.
    CLEAR: TEXT_DATA2, V_TY_TEXT1, V_TY_TEXT2.

*Get template sesuai tipe label dan tambahkan ke DAX (TEXT DATA).
    CONCATENATE FILE_DIR  V_LABELTYPE '.TAX' INTO FILE_F.
    PERFORM GETFRSRV_F.
    TEXT_DATA2[] = IT[].

    LOOP AT TEXT_DATA2.
      TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
      APPEND TEXT_DATA.
    ENDLOOP.

    CONCATENATE V_TYPE V_S_THICKNESS V_S_WIDTH V_S_LENGTH V_CDGRD INTO V_TY_TEXT1. "Barcode ke-1
    V_TY_TEXT1+19(2) = V_TAILORED.

    CONCATENATE V_TY_LOWER123 V_TY_ROLLN V_TY_LOTN '000' INTO V_TY_TEXT2. "Barcode ke-2

*Start - menambah value ke DAX (TEXT DATA).
    TEXT_DATA-STR_TEXT = '<STX><ESC>E1,1<CAN><ETX>'.  "Separate DAX Language between template and value
    APPEND TEXT_DATA.

    LOOP AT V_ZLABEL.
      IF V_ZLABEL-ATNAM = 'ZZBARC1'.  "QR Code
*        V_LENGRD = STRLEN( V_TAILORED ).
*        IF V_LENGRD = 1.
*          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 INTO TEXT_DATA-STR_TEXT.
*          CONCATENATE TEXT_DATA-STR_TEXT V_TY_TEXT2 INTO TEXT_DATA-STR_TEXT SEPARATED BY SPACE.
*          CONCATENATE TEXT_DATA-STR_TEXT '<ETX>' INTO TEXT_DATA-STR_TEXT.
*        ELSE.
*          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 V_TY_TEXT2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
*        ENDIF.
        "Start Add by Fiqih - Enhance QR Label TTE 17.07.2026
        CONCATENATE V_TY_TEXT1 V_TY_TEXT2 INTO V_TY_QRTEXT RESPECTING BLANKS.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_QRTEXT '<ETX>' INTO TEXT_DATA-STR_TEXT.
        "End Add by Fiqih - Enhance QR Label TTE 17.07.2026
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZBARC2'.  "Barcode ke-1
        DATA: LV_V_ZLABEL-DATA1(13).
        V_LENGRD = STRLEN( V_TAILORED ).
        IF V_LENGRD = 1.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 ' <ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSE.
          "Start Enhance by Fiqih - Enhance QR Label TTE 17.07.2026
          LV_V_ZLABEL-DATA1 = V_ZLABEL-DATA1.
          CONCATENATE '<STX><ESC>' LV_V_ZLABEL-DATA1 V_TY_TEXT1 '<ETX>' INTO TEXT_DATA-STR_TEXT RESPECTING BLANKS.
          "End Enhance by Fiqih - Enhance QR Label TTE 17.07.2026
        ENDIF.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZBARC3'.  "Barcode ke-2
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZTEXT1'.
        V_LENGRD = STRLEN( V_TAILORED ).
        IF V_LENGRD = 1.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 ' <ETX>' INTO TEXT_DATA-STR_TEXT.
        ELSE.
          CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        ENDIF.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZTEXT2'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_TEXT2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZFILM'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TYPE '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZSPLICE-1' AND V_ZLABEL-DATA2 NE ''.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 'J1: ' V_TY_SPLICE1 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZSPLICE-2' AND V_ZLABEL-DATA2 NE ''.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 'J2: ' V_TY_SPLICE2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZTREAT'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TAILORED '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZWEIGHT'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_S_WEIGHT '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZROLL1'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_ROLLN '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZROLL2'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_ROLLN '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZLOTNUMBER'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_TY_LOTN '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZGRADE'.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_GRADE '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ELSEIF V_ZLABEL-ATNAM = 'ZZTYPE' OR V_ZLABEL-ATNAM = 'ZZCRITERIA' OR V_ZLABEL-ATNAM = 'ZZCORE'
             OR V_ZLABEL-ATNAM = 'ZZINSIDE' OR V_ZLABEL-ATNAM = 'ZZOUTSIDE'.
        V_ZLABEL-ATNAM = V_ZLABEL-ATNAM.
      ELSE.
        CONCATENATE '<STX><ESC>' V_ZLABEL-DATA1 V_ZLABEL-DATA2 '<ETX>' INTO TEXT_DATA-STR_TEXT.
        APPEND TEXT_DATA.
      ENDIF.
    ENDLOOP.

*Conditiion for end syntax label command.
    TEXT_DATA-STR_TEXT = '<STX><RS>1<ETX>'.
    APPEND TEXT_DATA.

    CONCATENATE '<STX><US>' V_COPIES '<ETX>' INTO TEXT_DATA-STR_TEXT. "Nilai jumlah cetak (Copies)
    APPEND TEXT_DATA.

    TEXT_DATA-STR_TEXT = '<STX><ETB><ETX>'.
    APPEND TEXT_DATA.

*  ENDDO.     "Modified by AKBAR 27.11.2019 (Case on print data copies)

  ENDFORM.                    " tyb_text_data


*&---------------------------------------------------------------------*
*&      Form  F_LOADIMAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM F_LOADIMAGE_TTE USING V_CORDNT V_IMAG.

    LOOP AT V_ZLABELMAPIMAGE.
      REFRESH TEXT_DATA2.
      CLEAR TEXT_DATA2.

      CONCATENATE FILE_DIR  V_ZLABELMAPIMAGE-IMAG1 '.TAX' INTO FILE_F.

      PERFORM GETFRSRV_F.

      READ TABLE IT INDEX 2.
      REPLACE ALL OCCURRENCES OF 'G0' IN IT WITH V_IMAG.
      REPLACE ALL OCCURRENCES OF '0000' IN IT WITH V_CORDNT.
      MODIFY IT INDEX 2.

      TEXT_DATA2[] = IT[].

      LOOP AT TEXT_DATA2.
        TEXT_DATA-STR_TEXT = TEXT_DATA2-STR_TEXT.
        APPEND TEXT_DATA.
      ENDLOOP.
    ENDLOOP.
  ENDFORM.                    "F_LOADIMAGE