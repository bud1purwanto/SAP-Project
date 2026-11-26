***INCLUDE MV45AF0G_GG_SICHERN_PRUEFEN .
*---------------------------------------------------------------------*
*       FORM gg_sichern_pruefen                                       *
*---------------------------------------------------------------------*
* Aufruf der Gefahrgutprüfung und setzen des Kennzeichens             *
* 'sichern erlaubt'                                                   *
*---------------------------------------------------------------------*
*  -->  ch_subrc =  0 : sichern erlaubt                               *
*                   1 : sichern erlaubt mit Unvollständigkeitsstatus  *
*                   2 : sichern nicht erlaubt                         *
*---------------------------------------------------------------------*
FORM GG_SICHERN_PRUEFEN CHANGING CH_SUBRC.

  DATA: DA_START(2) TYPE N,
        DA_STATUS   TYPE C,
        E_DG_CHK_LOGTAB LIKE BALMI OCCURS 10 WITH HEADER LINE,
        L_TPPR TYPE SY-SUBRC.

* we store the value of ch_subrc from template processing
  L_TPPR = CH_SUBRC.
  CLEAR CH_SUBRC.
  DA_START = 9.                        " Startmodus sichern normal
  CALL FUNCTION 'DIALOG_GET_STATUS'
    IMPORTING
      DIALOG_STATUS = DA_STATUS.

  IF DA_STATUS     = CHARX OR
     call_function = charx or
     SY-BINPT      = CHARX OR
     SY-BATCH      = CHARX.
    DA_START = 10.
  ENDIF.

  CALL FUNCTION 'SD_EHS_HAZMAT_CHECK'
    EXPORTING
      IF_STARTMODUS                  = DA_START
    TABLES
      IT_VBAP                        = XVBAP
      IT_VBEP                        = XVBEP
      IT_VBPA                        = XVBPA
* Begin Correction 23.05.2007 1057243 ***********************************
      IT_VBUP                        = XVBUP
* End Correction 23.05.2007 1057243 *************************************
      E_DG_CHK_LOGTAB                = E_DG_CHK_LOGTAB
    CHANGING
      CS_VBAK                        = VBAK
      CF_DATALOSS                    = R185D-DATALOSS
      C_GGP_STATUS                   = RV45A_UV-VGGP
    EXCEPTIONS
      PRUEFUNG_NICHT_AKTIV           = 1
      KEINE_GG_RELEVANTEN_POSITIONEN = 2
      GG_VOLLSTAENDIG_SICHERN        = 3
      GG_UNVOLLSTAENDIG_SICHERN      = 4
      GG_SICHERN_VERBIETEN           = 5
      GG_CANCEL                      = 6
      OTHERS                         = 7.

  IF L_TPPR = 0.
    CH_SUBRC = SY-SUBRC.
  ELSE.
* only possible value is "1" (GG_UNVOLLSTAENDIG_SICHERN)
    IF SY-SUBRC < 4.
      CH_SUBRC = L_TPPR.
    ELSE.
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.
  READ TABLE HVBUV WITH KEY TBNAM = 'RV45A_UV' FDNAM = 'VGGP'.
  IF SY-SUBRC = 0.
    DELETE TABLE HVBUV.
  ENDIF.
  READ TABLE XVBUV WITH KEY TBNAM = 'RV45A_UV' FDNAM = 'VGGP'.
  IF SY-SUBRC = 0.
    DELETE TABLE XVBUV.
  ENDIF.


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

  CASE CH_SUBRC.
    WHEN 5.
*   Meldung ausgeben, daß der Beleg aus Gefahrgutsicht nicht gesichert
*   werden darf, da im GG-Customizing so eingestellt
*   Nur im Startmodus 9 !!
      IF DA_START = 9.
        MESSAGE I213(V2).
      ENDIF.
    WHEN 7.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDCASE.



ENDFORM.                    "gg_sichern_pruefen