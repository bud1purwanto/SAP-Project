*eject
*----------------------------------------------------------------------*
*  Die Nachrichtenpflege wird auf Positionseben durchgeführt           *
*----------------------------------------------------------------------*
FORM NACHRICHTEN_PFLEGE.

  DATA: BILDTEXT LIKE DV70A-BTEXT.
  DATA: FNCODE(20).


  CLEAR T185.
  CLEAR T185F.
  CLEAR T185V.
*----------------- Bildtitel wird gesetzt -----------------------------*
  BILDTEXT = TEXT-N02.
  BILDTEXT+20(1) = '$'.
  CONDENSE BILDTEXT.
  SEARCH BILDTEXT FOR '$'.
  SY-FDPOS = SY-FDPOS - 1.
  WRITE '....................' TO BILDTEXT+SY-FDPOS(20).
  WRITE SPACE TO BILDTEXT+20(1).
* write mseg-mblnr to bildtext+21.
  WRITE MKPF-MBLNR TO BILDTEXT+21.
  WRITE MSEG-ZEILE TO BILDTEXT+32.
*-------------- Werte für Bildfolgesteuerung werden übergeben ---------*
  T185-PANEL = 'NUEB'.
  T185-BLDGR = 'N0 '.
  T185F-FCODE = 'ENT1'.
  T185F-TRTYP = T158-TRTYP.

  PERFORM NACHRICHT_ERZEUGEN.

  IF T158-TRTYP EQ H.
    CASE MSEG-KZBEW.
      WHEN B.
        AUTHORITY-CHECK OBJECT 'M_MSEG_WWE'
                        ID 'ACTVT' FIELD ACTVT04
                        ID 'WERKS' FIELD MSEG-WERKS.
      WHEN F.
        AUTHORITY-CHECK OBJECT 'M_MSEG_WWF'
                        ID 'ACTVT' FIELD ACTVT04
                        ID 'WERKS' FIELD MSEG-WERKS.
      WHEN OTHERS.
        AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
                        ID 'ACTVT' FIELD ACTVT04
                        ID 'WERKS' FIELD MSEG-WERKS.
    ENDCASE.
    IF NOT SY-SUBRC IS INITIAL.
      T185F-TRTYP = A.
    ENDIF.
  ELSEIF T158-TRTYP = V.
    AUTHORITY-CHECK OBJECT 'M_MSEG_WMB'
                    ID 'ACTVT' FIELD ACTVT04
                    ID 'WERKS' FIELD MSEG-WERKS.
    IF NOT SY-SUBRC IS INITIAL.
      T185F-TRTYP = A.
    ENDIF.
  ENDIF.

*----------- Aufruf Dialogbaustein Nachrichtensteuerung ---------------*
  IF T158-TRTYP EQ V OR T158-TRTYP EQ A.
    NAST_KEY-MBLNR = MKPF-MBLNR.
    IF NOT MKPF-MBLNR IS INITIAL.
      NAST_KEY-MJAHR = MKPF-MJAHR.
    ENDIF.
    NAST_KEY-ZEILE = MSEG-ZEILE.
    CONDENSE NAST_KEY NO-GAPS.
    MSG_OBJKY = NAST_KEY.
  ENDIF.
  CALL FUNCTION 'RV_MESSAGES_MAINTENANCE'
        EXPORTING MIN_T185  = T185
                  MIN_T185F = T185F
                  MIN_T185V = T185V
                  MIN_OBJKY = MSG_OBJKY
                  MIN_KAPPL = 'ME'
                  MIN_KALSM = 'ME0001'
                  MIN_BTEXT = BILDTEXT
                  MIN_CUA_TEXT = TEXT-N02
                  PI_OBJTYPE   = MSG_OBJTYP
        IMPORTING MEX_FCODE = FNCODE
                  MEX_T185F = T185F
                  MEX_T185V = T185V
                  MEX_UPDAT = X_UPD
        TABLES    MTB_PART  = PART.
  CLEAR CCODE.
  IF NOT X_UPD IS INITIAL AND T158-TRTYP = V.
    XCONFIRM = X.
    UPD_NAST = X.
*   call function 'RV_MESSAGES_UPDATE'
*        exporting msg_objky = msg_objky
*        exceptions others = 1.
    CALL FUNCTION 'MB_MESSAGE_UPDATE'
         EXPORTING
              M_KAPPL = 'ME'
              M_OBJKY = MSG_OBJKY
         EXCEPTIONS
              ERROR_MESSAGE = 4.
   ENDIF.

ENDFORM.