*&---------------------------------------------------------------------*
*&  Include           MV45AF0D_DGMSD_DETERMINE                         *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  DGMSD_DETERMINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_DA_SUBRC  text
*----------------------------------------------------------------------*
FORM DGMSD_DETERMINE  CHANGING CH_SUBRC.

  DATA: DA_START(2) TYPE N,
        DA_STATUS   TYPE C,
        TPPR_ACTIVE  TYPE C,
        DGMSD_WA LIKE RDGSDIOT,
        I_DGMSD_TAB LIKE DGMSD OCCURS 0,
        E_DG_LOGTAB LIKE  BALMI OCCURS 0 WITH HEADER LINE,
        I_DNACT LIKE RDGDNACT,
        GF_AKTIV LIKE V50AGL-GEFAHRGUT_AKTIV,
        MSGTY LIKE BALMI-MSGTY,
        MSGID LIKE BALMI-MSGID,
        MSGNO LIKE BALMI-MSGNO,
        DG_ERROR TYPE C,
        TEXT  LIKE T100-TEXT,
        TEXT1 LIKE T100-TEXT,
        TEXT2 LIKE T100-TEXT,
        TEXT3 LIKE T100-TEXT,
        TEXT4 LIKE T100-TEXT,
        FLG_MSG TYPE C,
        L_ANSWER.
  DATA: L_BADI_INSTANCE TYPE REF TO IF_EX_EHS_DG_002.
  DATA: E_USX_LOGTAB LIKE BALMI OCCURS 5 WITH HEADER LINE.

* Check if functionality should be processed
  CALL FUNCTION 'EHS003_TPPR_GET'
    IMPORTING
      E_TPPR_ACTIVE = TPPR_ACTIVE
    EXCEPTIONS
      OTHERS_       = 1.

  CHECK TPPR_ACTIVE = CHARX.
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


* startmode: dialog saving (da_start = 1)
  DA_START = 1.
  CALL FUNCTION 'DIALOG_GET_STATUS'
    IMPORTING
      DIALOG_STATUS = DA_STATUS.

  IF DA_STATUS = CHARX OR
*    first data adoption (Erstdatenübernahme; da_start = 2)
     SY-BINPT  = CHARX OR
     SY-BATCH  = CHARX.
    DA_START = 2.
  ENDIF.

* get instance
  CALL FUNCTION 'EHS003_BADI_EHS_DG_002_GET_OBJ'
    IMPORTING
      E_BADI_OBJECT = L_BADI_INSTANCE.

*check for t/s-material
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
* no relevant materials in document--> exit and save
    IF SY-SUBRC = 1.
      CH_SUBRC = 0.
* update / correct x_dgmsd_tab and xvbuv-entries
      CALL METHOD L_BADI_INSTANCE->DGMSD_VBUV_UPDATE
        EXPORTING
          I_VBTYP = VBAK-VBTYP
        CHANGING
          X_XVBUV = XVBUV[]
        EXCEPTIONS
          OTHERS_ = 1.

      EXIT.
    ELSEIF SY-SUBRC > 1.
* message only for normal saving
      IF DA_START = 1.
        MSGTY = 'W'.
        MSGID = 'CB01'.
        MSGNO = 411.
        DG_ERROR = CHARX.
      ELSEIF DA_START = 2.
* first database
        E_DG_LOGTAB-MSGTY = 'W'.
        E_DG_LOGTAB-MSGID = 'CB01'.
        E_DG_LOGTAB-MSGNO = 411.
        APPEND E_DG_LOGTAB.
        CH_SUBRC = 1.
      ENDIF.
    ENDIF.
  ENDIF.

  IF DG_ERROR <> CHARX.
    CALL METHOD L_BADI_INSTANCE->MD_DET_ORDER
      EXPORTING
        I_CHK_VBAK_WA                = VBAK
        I_TRTYP                      = T180-TRTYP
        I_DG_START                   = DA_START
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

* Begin Correction 25.09.2007 1095897 *****************************
    IF SY-SUBRC > 1.
*     exception NO_TPMA_EXIST means that we have a pipeline transport
*     or a material where no DG checks or papers are relevant
* End Correction 25.09.2007 1095897 *******************************
      IF DA_START = 1.
* saving in dialog
        DG_ERROR = CHARX.

        CASE SY-SUBRC.
          WHEN '2'.
            MSGTY = 'W'.
            MSGID = 'DG'.
            MSGNO = 422.
          WHEN '3'.
            MSGTY = 'W'.
            MSGID = 'DG'.
            MSGNO = 406.
          WHEN '4'.
            MSGTY = 'W'.
            MSGID = 'DG'.
            MSGNO = 462.
          WHEN '5'.
            MSGTY = 'W'.
            MSGID = 'DG'.
            MSGNO = 401.
          WHEN '6'.
            MSGTY = 'W'.
            MSGID = 'DG'.
            MSGNO = 464.
          WHEN '7'.
            MSGTY = 'W'.
            MSGID = 'CB01'.
            MSGNO = 403.
          WHEN '8'.
            MSGTY = 'W'.
            MSGID = 'CB01'.
            MSGNO = 404.
          WHEN '9'.
            MSGTY = 'W'.
            MSGID = 'CB01'.
            MSGNO = 405.
          WHEN '10'.
            MSGTY = 'W'.
            MSGID = 'CB01'.
            MSGNO = 406.
          WHEN '11'.
            MSGTY = 'W'.
            MSGID = 'CB01'.
            MSGNO = 407.
          WHEN '12'.
            MSGTY = 'W'.
            MSGID = 'DG'.
            MSGNO = 453.
          WHEN '13'.
            MSGTY = 'W'.
            MSGID = 'DG'.
            MSGNO = 457.
          WHEN '14'.
          WHEN '15'.
            MSGTY = 'W'.
            MSGID = 'CB01'.
            MSGNO = 408.
          WHEN '16'.
            MSGTY = 'W'.
            MSGID = 'CB01'.
            MSGNO = 409.
          WHEN '17'.
            MSGTY = 'W'.
            MSGID = 'CB01'.
            MSGNO = 410.
*           CLEAR DG_ERROR.
            FLG_MSG = CHARX.

        ENDCASE.

      ELSEIF DA_START = 2.
* first database (not yet realized) --> always saving
        CH_SUBRC = 1.
      ENDIF.
    ENDIF.
  ENDIF.

* set incompleteness if error occured
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

* output of error message
  IF DA_START = 1     AND
     ( DG_ERROR = CHARX OR FLG_MSG = CHARX ).

* conversion of message to text
*   TEXTLINE3
    CALL FUNCTION 'SWO_TEXT_MESSAGE'
      EXPORTING
        LANGUAGE = SY-LANGU
        MESSAGE  = MSGNO
        WORKAREA = MSGID
      IMPORTING
        TEXT     = TEXT.
*   TEXT_OPTION1
    CALL FUNCTION 'SWO_TEXT_MESSAGE'
      EXPORTING
        LANGUAGE = SY-LANGU
        MESSAGE  = '413'
        WORKAREA = 'CB01'
      IMPORTING
        TEXT     = TEXT1.
*   TEXT_OPTION2
    CALL FUNCTION 'SWO_TEXT_MESSAGE'
      EXPORTING
        LANGUAGE = SY-LANGU
        MESSAGE  = '414'
        WORKAREA = 'CB01'
      IMPORTING
        TEXT     = TEXT2.
*   Titel
    CALL FUNCTION 'SWO_TEXT_MESSAGE'
      EXPORTING
        LANGUAGE = SY-LANGU
        MESSAGE  = '415'
        WORKAREA = 'CB01'
      IMPORTING
        TEXT     = TEXT3.
*   TEXTLINE1
    CALL FUNCTION 'SWO_TEXT_MESSAGE'
      EXPORTING
        LANGUAGE = SY-LANGU
        MESSAGE  = '416'
        WORKAREA = 'CB01'
      IMPORTING
        TEXT     = TEXT4.
    L_ANSWER = CHAR2.

    WHILE  L_ANSWER = CHAR2.
      CALL FUNCTION 'POPUP_TO_DECIDE'
           EXPORTING
                DEFAULTOPTION     = '2'
                TEXTLINE1         = TEXT4
*         TEXTLINE2         = ' '
                TEXTLINE3         = TEXT
                TEXT_OPTION1      = TEXT1
                TEXT_OPTION2      = TEXT2
                ICON_TEXT_OPTION1 = 'ICON_SYSTEM_SAVE'
                ICON_TEXT_OPTION2 = 'ICON_INFORMATION'
                TITEL             = TEXT3
                START_COLUMN      = 25
                START_ROW         = 6
                CANCEL_DISPLAY    = 'X'
           IMPORTING
                ANSWER            = L_ANSWER.

      CASE L_ANSWER.

        WHEN CHAR1.
*    saving
          CH_SUBRC = 0.
          EXIT.
        WHEN CHARA.
*    Bearbeiten und Abbrechen: Zurück zur Belegbearbeitung
          L_ANSWER = CHAR9.
          CH_SUBRC = 2.
        WHEN CHAR2.
*     show longtext
          CALL FUNCTION 'EHS003_MESSAGE_OUTPUT'
            EXPORTING
              SPRSL   = SY-LANGU
              ARBGB   = MSGID
              MSGNR   = MSGNO
            EXCEPTIONS
              OTHERS_ = 1.

          CH_SUBRC = 0.
      ENDCASE.
    ENDWHILE.
    IF L_ANSWER = CHAR9.
      EXIT.
    ENDIF.
  ENDIF.

  CHECK CH_SUBRC = 0.

* check incompleteness of dgmsd fields
  CALL FUNCTION 'EHS003_CHECK_INCOMPLETENESS'
    EXPORTING
      DIALOG      = SPACE
      FEHGR       = TVAK-FEHGR
      TBNAM       = 'DGMSD'
      I_VBTYP     = VBAK-VBTYP
      I_VBELN     = VBAK-VBELN
      I_VBAK      = VBAK
    TABLES
      I_VBUV_LAST = HVBUV
      I_VBUV_TAB  = XVBUV
      I_VBUV_DIA  = DVBUV
      I_VBAP      = XVBAP
    EXCEPTIONS
      OTHERS_     = 1.

ENDFORM.                    " DGMSD_DETERMINE