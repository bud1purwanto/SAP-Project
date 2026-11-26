*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_APOD                                        *
*----------------------------------------------------------------------*
*   Jump into POD splitscreen out of inbound delivery overview         *
*----------------------------------------------------------------------*
FORM FCODE_APOD USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

  DATA: LT_VBUP TYPE VBUP OCCURS 0 WITH HEADER LINE.
  DATA: LF_KZPOD    LIKE LIPS-KZPOD,
        LF_LFIMG    LIKE LIPS-LFIMG,
        LF_PODREL   LIKE LIPS-PODREL,
        LF_TRTYP    LIKE T180-TRTYP,
        LV_ERROR_FLAG TYPE XFELD,                           "v_n_1411527
        LT_TVPOD_S    TYPE TABLE OF TVPODVB,
        LF_KZPOD_S    LIKE LIPS-KZPOD,
        LF_LFIMG_S    LIKE LIPS-LFIMG,
        LF_PODREL_S   LIKE LIPS-PODREL,            "1414978 "^_n_1411527
        LF_NOCHANGE TYPE C VALUE SPACE.

ENHANCEMENT-POINT MV50AF0F_FCODE_APOD_01 SPOTS ES_SAPMV50A STATIC.

*  CHECK LIPS-KZPOD NE SPACE.
*... Uom must not be changed in POD scenario
  IF ( LIPS-VRKME NE *LIPS-VRKME   OR
       LIPS-MEINS NE *LIPS-MEINS ) AND NOT
       LIPS-KZPOD IS INITIAL.
    MESSAGE I655(VL).
    CHECK 1 = 2.
  ENDIF.

  IF LIPS EQ *LIPS.
    LF_NOCHANGE = CHARX.
  ELSE.
    LF_NOCHANGE = SPACE.
  ENDIF.
  LT_VBUP[] = XVBUP[].
  READ TABLE LT_VBUP WITH KEY VBELN = LIPS-VBELN
                              POSNR = LIPS-POSNR.
  CHECK SY-SUBRC EQ 0.
  IF NOT LIPS-UECHA IS INITIAL OR
     LT_VBUP-WBSTA EQ CHARC    OR
*    lt_vbup-lvsta ca 'BC'.
     lt_vbup-lvsta = 'B'.                                      "n_854506
    LF_TRTYP = CHARA.
  ELSE.
    LF_TRTYP = T180-TRTYP.
  ENDIF.

  IF ( NOT XLIPS-CHMULT IS INITIAL AND XLIPS-KZPOD CA 'XA' ) OR
       XLIPS-KZPOD IS INITIAL.
    MESSAGE I678(VL) WITH XLIPS-POSNR XLIPS-VBELN.
    CHECK 1 = 2.
  ENDIF.

  LV_ERROR_FLAG = CHARX.                                    "v_n_1411527

  WHILE LV_ERROR_FLAG EQ CHARX.
    CALL FUNCTION 'LE_POD_TVPOD_READ'
      TABLES
        IT_LIPS                 = XLIPS
        ET_TVPOD                = LT_TVPOD_S.    "n_1414978 "^_n_1411527              .

    CALL FUNCTION 'LE_POD_DATA_PROCESSING'
       EXPORTING
            IT_LIKP                     = LIKP
            IS_LIPS                     = LIPS
            IF_PODAU                    = TVLP-PODAU
            IF_TRTYP                    = LF_TRTYP
            IF_DIALOG                   = CHARX
            IF_NOCHANGE                 = LF_NOCHANGE
       IMPORTING
            EF_LIPS_KZPOD               = LF_KZPOD
            EF_LIPS_LFIMG               = LF_LFIMG
            EF_LIPS_PODREL              = LF_PODREL
       TABLES
            IT_XLIPS                    = XLIPS
            IT_YLIPS                    = YLIPS
       EXCEPTIONS
            ERROR_TVPOD_UPDATE          = 1
            NO_DEFAULT_REASON_FOUND     = 2
            POD_PROCESSING_DATA_MISSING = 3
            ITEM_NOT_POD_RELEVANT       = 4
            OTHERS                      = 5.
  CHECK SY-SUBRC EQ 0.

  CHECK LIPS-KZPOD NE SPACE.
  IF ( LF_KZPOD NE LIPS-KZPOD   OR
       LF_LFIMG NE LIPS-LFIMG ) AND NOT
     TVLP-PODAU EQ SPACE.
      LF_KZPOD_S  = LIPS-KZPOD.                             "v_n_1411527
      LF_LFIMG_S  = LIPS-LFIMG.
      LF_PODREL_S = LIPS-PODREL.                            "^_n_1411527
    LIPS-KZPOD  = LF_KZPOD.
    LIPS-LFIMG  = LF_LFIMG.
    LIPS-PODREL = LF_PODREL.
    CALL FUNCTION 'SHP_QUANTITY_SET'
      EXPORTING
        IF_ACTION                    = 'A'
*               IF_RATIO                     = ' '
      CHANGING
        CF_LFIMG                     = LIPS-LFIMG
        CF_LGMNG                     = LIPS-LGMNG
        CF_LFIMG_FLO                 = LIPS-LFIMG_FLO
        CF_LGMNG_FLO                 = LIPS-LGMNG_FLO
        CF_UMVKZ                     = LIPS-UMVKZ
        CF_UMVKN                     = LIPS-UMVKN
        CF_UMREV                     = LIPS-UMREV
        CF_AKMNG                     = LIPS-AKMNG
      EXCEPTIONS
        CONVERSION_OVERFLOW          = 1
        ESSENTIAL_DATA_MISSING       = 2
        ERROR                        = 3
        OTHERS                       = 4.

    CASE SY-SUBRC.
      WHEN 0.
          IF LIKP-VBTYP = VBTYP_LIAV.                       "v_n_1411527
            V50AGL-SAMMELGANG = 'X'.
            REFRESH CVBFS.
            IF NOT LIPS-KZPOD IS INITIAL.
              PERFORM LIPS-LFIMG_PRUEFEN(SAPFV50P) USING '6789'.
            ENDIF.
* partial goods receipt
            PERFORM LIPS-LFIMG_PRUEFEN(SAPFV50P) USING 'b'.
            LOOP AT CVBFS.
              message id     cvbfs-msgid
                      type   'I'
                      number cvbfs-msgno
                      with   cvbfs-msgv1
                             cvbfs-msgv2
                             cvbfs-msgv3
                             cvbfs-msgv4
                      display like 'E'.
            ENDLOOP.
            IF CVBFS[] IS INITIAL.
              CLEAR LV_ERROR_FLAG.
            ELSE.
* reset quantities und values
              LIPS-KZPOD  = LF_KZPOD_S.
              LIPS-LFIMG  = LF_LFIMG_S.
              LIPS-PODREL = LF_PODREL_S.
              CALL FUNCTION 'SHP_QUANTITY_SET'
                   EXPORTING
                        IF_ACTION                    = 'A'
*                       IF_RATIO                     = ' '
                   CHANGING
                        CF_LFIMG                     = LIPS-LFIMG
                        CF_LGMNG                     = LIPS-LGMNG
                        CF_LFIMG_FLO                 = LIPS-LFIMG_FLO
                        CF_LGMNG_FLO                 = LIPS-LGMNG_FLO
                        CF_UMVKZ                     = LIPS-UMVKZ
                        CF_UMVKN                     = LIPS-UMVKN
                        CF_UMREV                     = LIPS-UMREV
                        CF_AKMNG                     = LIPS-AKMNG
                   EXCEPTIONS
                        CONVERSION_OVERFLOW          = 1
                        ESSENTIAL_DATA_MISSING       = 2
                        ERROR                        = 3
                        OTHERS                       = 4.
* reset POD entries
              CALL FUNCTION 'LE_POD_TVPOD_BUFFER_RESET'
                TABLES
                  IT_TVPOD       = LT_TVPOD_S.                "n_1414978
            ENDIF.
            CLEAR V50AGL-SAMMELGANG.
          ELSE.
            CLEAR LV_ERROR_FLAG.
          ENDIF.                                            "^_n_1411527

          PERFORM XLIPS_AENDERN(SAPFV50P).
ENHANCEMENT-SECTION     MV50AF0F_FCODE_APOD_02 SPOTS ES_SAPMV50A.
        CALL FUNCTION 'LIPS_STATUS_MAINTAIN'
             EXPORTING
                  F_LIKP  = LIKP
                  F_POSNR = LIPS-POSNR
             TABLES
                  FXLIPS  = XLIPS
                  FXVBAPF = XVBAPF
                  FXVBUP  = XVBUP
                  FYVBUP  = YVBUP
                  fxvbfa   = xvbfa.                             "XAN-SPE

END-ENHANCEMENT-SECTION.
      WHEN 1. RAISE CONVERSION_OVERFLOW.
      WHEN 2. RAISE ESSENTIAL_DATA_MISSING.
      WHEN 3. RAISE ERROR.
    ENDCASE.
    ELSE.                                                     "n_1411527
      CLEAR LV_ERROR_FLAG.                                    "n_1411527
    ENDIF.
  ENDWHILE.                                                   "n_1411527

ENDFORM.