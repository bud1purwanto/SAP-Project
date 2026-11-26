*&---------------------------------------------------------------------*
*&  Include           MV45AF0F_FCODE_DGMD_S                            *
*&---------------------------------------------------------------------*
FORM FCODE_DGMD_S.

  DATA: DG_ERROR TYPE C,
        L_BADI_INSTANCE TYPE REF TO IF_EX_EHS_DG_002.

  DATA: E_USX_LOGTAB LIKE BALMI OCCURS 5 WITH HEADER LINE.

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

*  initialize incompleteness entries
  READ TABLE HVBUV WITH KEY TBNAM = 'RV45A_UV' FDNAM = 'VGGP'.
  IF SY-SUBRC = 0.
    DELETE TABLE HVBUV.
  ENDIF.
  READ TABLE XVBUV WITH KEY TBNAM = 'RV45A_UV' FDNAM = 'VGGP'.
  IF SY-SUBRC = 0.
    DELETE TABLE XVBUV.
  ENDIF.
  RV45A_UV-VGGP = CHARX.

*check for t/s-material relevant
  CALL METHOD L_BADI_INSTANCE->TPMAT_CHECK
    EXPORTING
      I_VBTYP        = VBAK-VBTYP
      I_VBELN        = VBAK-VBELN
    CHANGING
      I_XVBAP_TAB    = XVBAP[]
    EXCEPTIONS
      NO_TPMAT_EXIST = 1
      WRONG_PARAM    = 2
      NO_PROFL_FOUND = 3
      OTHERS_        = 4.

  IF SY-SUBRC <> 0.
    IF SY-SUBRC = 1.
      MESSAGE I402(CB01).
* update / correct x_dgmsd_tab and xvbuv-entries
      CALL METHOD L_BADI_INSTANCE->DGMSD_VBUV_UPDATE
        EXPORTING
          I_VBTYP = VBAK-VBTYP
          I_ERROR = CHARX
        CHANGING
          X_XVBUV = XVBUV[]
        EXCEPTIONS
          OTHERS_ = 1.

      FCODE = FCODE_GLEICHE_SEITE.
      PERFORM FCODE_BEARBEITEN.
      EXIT.
    ELSEIF SY-SUBRC > 1.
      MESSAGE I403(CB01).
      DG_ERROR = CHARX.
    ENDIF.
  ENDIF.

*get dangerous goods data
  IF DG_ERROR <> CHARX.
    CALL METHOD L_BADI_INSTANCE->MD_DET_ORDER
      EXPORTING
        I_CHK_VBAK_WA                = VBAK
        I_TRTYP                      = T180-TRTYP
*   I_DG_START                   =
      CHANGING
        I_VBAPTAB                    = XVBAP[]
        I_VBEPTAB                    = XVBEP[]
        I_VBPATAB                    = XVBPA[]
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
        NO_TRTYP                     = 14
        NO_DG_MAT_FOUND              = 15
        ERROR_BY_DET_CHECK_METHODS   = 16
        NO_DGDATA_MNTCE              = 17
        OTHERS_                      = 18.

    IF SY-SUBRC <> 0.
      DG_ERROR = CHARX.
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
        WHEN '15'.
          MESSAGE I408(CB01).
        WHEN '16'.
          MESSAGE I409(CB01).

      ENDCASE.

    ENDIF.
  ENDIF.

* update / correct x_dgmsd_tab and xvbuv-entries
  CALL METHOD L_BADI_INSTANCE->DGMSD_VBUV_UPDATE
    EXPORTING
      I_VBTYP = VBAK-VBTYP
      I_ERROR = DG_ERROR
    CHANGING
      X_XVBUV = XVBUV[]
    EXCEPTIONS
      OTHERS_ = 1.

* Incompleteness log if error occured
  IF DG_ERROR = CHARX.
    CLEAR RV45A_UV-VGGP.
    CALL FUNCTION 'RV_CHECK_DOCUMENT_INPUT'
      EXPORTING
        FEHGR       = 'MK'
        VBXX_WA     = RV45A_UV
        TBNAM       = 'RV45A_UV  '
        FDNAM       = 'VGGP      '
        DIALOG      = SPACE
        DIA_VISIBLE = CHARX
      TABLES
        VBUV_DIA    = DVBUV
        VBUV_TAB    = XVBUV
        VBUV_LAST   = HVBUV.

* don't process the dg dynpro
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
    EXIT.
  ENDIF.

ENDFORM.                    "FCODE_DGMD