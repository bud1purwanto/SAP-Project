*&---------------------------------------------------------------------*
*&  Include           MV50AF0F_FCODE_DGMD_T_S                          *
*&---------------------------------------------------------------------*
FORM FCODE_DGMD_T_S.

  DATA: LT_BALMI TYPE BALMI OCCURS 0,
        L_BADI_INSTANCE TYPE REF TO IF_EX_EHS_DG_002,
        E_USX_LOGTAB LIKE BALMI OCCURS 5 WITH HEADER LINE.
  DATA  BEGIN OF LS_LIKPVB.
          INCLUDE STRUCTURE LIKPVB.
  DATA  END   OF LS_LIKPVB.

* get instance for badi methods   
  CALL FUNCTION 'EHS003_BADI_EHS_DG_002_GET_OBJ'
    IMPORTING
      E_BADI_OBJECT = L_BADI_INSTANCE.

*check authority
  CALL METHOD L_BADI_INSTANCE->AUTHORITY_CHECK
    EXPORTING
      I_TRTYP      = T180-TRTYP
    EXCEPTIONS
      NO_AUTHORITY = 1
      OTHERS_      = 2.

  IF SY-SUBRC <> 0.
    MESSAGE I401(CB01).
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
    EXIT.
  ENDIF.

  PERFORM XLIKP_AUS_LIKP_FUELLEN.
  LS_LIKPVB = LIKP.

*check for t/s-material relevant
  CALL METHOD L_BADI_INSTANCE->TPMAT_CHECK
    EXPORTING
      I_VBTYP        = LS_LIKPVB-VBTYP
      I_VBELN        = LS_LIKPVB-VBELN
    CHANGING
      I_XLIPS_TAB    = XLIPS[]
    EXCEPTIONS
      NO_TPMAT_EXIST = 1
      WRONG_PARAM    = 2
      NO_PROFL_FOUND = 3
      OTHERS_        = 4.

  IF SY-SUBRC = 1.
    MESSAGE I402(CB01).
    LS_LIKPVB-VOGGT = 'A'.
* update / correct x_dgmsd_tab and xvbuv-entries
    CALL METHOD L_BADI_INSTANCE->DGMSD_VBUV_UPDATE
      EXPORTING
        I_VBTYP = LS_LIKPVB-VBTYP
        I_ERROR = CHARX
      CHANGING
        X_XVBUV = XVBUV[]
      EXCEPTIONS
        OTHERS_ = 1.

* set data to SD header
    PERFORM GG_DATEN_UEBERNAHME TABLES LT_BALMI
                                USING  LS_LIKPVB 1.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
    EXIT.
  ELSEIF SY-SUBRC > 1.
    MESSAGE I403(CB01).
    LS_LIKPVB-VOGGT = 'B'.
    PERFORM GG_DATEN_UEBERNAHME TABLES LT_BALMI
                                USING  LS_LIKPVB 1.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
    EXIT.
  ENDIF.

*get dangerous goods data
  CALL METHOD L_BADI_INSTANCE->MD_DET_DELIVERY
    EXPORTING
      I_LIKPTAB                    = LS_LIKPVB
      I_LIPSTAB                    = XLIPS[]
      I_TVSTTAB                    = TVST
      I_VBPATAB                    = XVBPA[]
      I_TRTYP                      = T180-TRTYP
*    I_DG_START                   =
    CHANGING
      E_USX_LOGTAB                 = E_USX_LOGTAB[]
    EXCEPTIONS
      NO_TPMA_EXIST                = 1
      NO_RELEASE_STATUS_DETERMINED = 2
      NO_CTRY_DGMOT_DETERMINED     = 3
      ERROR_CTRY_DGMOT             = 4
      NO_SHIPPING_TYPES_DETERMINED = 5
      NO_DGMAT_AVAILABLE           = 6
      NO_TDG41_IDGTP               = 7
      NO_DG_MAT_TO_MATNR           = 8
      NO_LWDG_FOUND                = 9
      NO_SHIP_TO_COUNTRY           = 10
      DG_MASTER_NOT_RELEASED       = 11
      NON_DISJUNCT_VALIDITY_AREAS  = 12
      DG_MASTER_DELETED            = 13
      NO_DG_MAT_FOUND              = 14
      ERROR_BY_DET_CHECK_METHODS   = 15
      NO_DGDATA_MNTCE              = 16
      OTHERS_                      = 17.

  IF SY-SUBRC <> 0.
    CASE SY-SUBRC.

      WHEN '1'.
        MESSAGE I402(CB01).
        FCODE = FCODE_GLEICHE_SEITE.
        PERFORM FCODE_BEARBEITEN.
        EXIT.
      WHEN '2'.
        MESSAGE I204(CB01).
      WHEN '3'.
        MESSAGE I205(CB01).
      WHEN '4'.
        MESSAGE I206(CB01).
      WHEN '5'.
        MESSAGE I207(CB01).
      WHEN '6'.
        MESSAGE I208(CB01).
      WHEN '7'.
        MESSAGE I403(CB01).
      WHEN '8'.
        MESSAGE I404(CB01).
      WHEN '9'.
        MESSAGE I405(CB01).
      WHEN '10'.
        MESSAGE I406(CB01).
      WHEN '11'.
        MESSAGE I407(CB01).
      WHEN '12'.
        MESSAGE I209(CB01).
      WHEN '13'.
        MESSAGE I210(CB01).
      WHEN '14'.
        MESSAGE I408(CB01).
      WHEN '15'.
        MESSAGE I409(CB01).

    ENDCASE.

    LS_LIKPVB-VOGGT = 'B'.
* set data to SD header
    PERFORM GG_DATEN_UEBERNAHME TABLES LT_BALMI
                                USING  LS_LIKPVB 1.

* update / correct x_dgmsd_tab1 and xvbuv-entries
    CALL METHOD L_BADI_INSTANCE->DGMSD_VBUV_UPDATE
      EXPORTING
        I_VBTYP = LS_LIKPVB-VBTYP
        I_ERROR = CHARX
      CHANGING
        X_XVBUV = XVBUV[]
      EXCEPTIONS
        OTHERS_ = 1.

    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
    EXIT.

  ELSE.
* update / correct x_dgmsd_tab1 and xvbuv-entries
    CALL METHOD L_BADI_INSTANCE->DGMSD_VBUV_UPDATE
      EXPORTING
        I_VBTYP = LS_LIKPVB-VBTYP
      CHANGING
        X_XVBUV = XVBUV[]
      EXCEPTIONS
        OTHERS_ = 1.

  ENDIF.

ENDFORM.                    "FCODE_DGMD_T_S