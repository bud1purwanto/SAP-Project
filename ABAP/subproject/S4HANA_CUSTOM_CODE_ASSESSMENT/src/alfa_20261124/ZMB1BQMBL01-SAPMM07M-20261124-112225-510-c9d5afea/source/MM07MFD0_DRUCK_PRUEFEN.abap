*----------------------------------------------------------------------*
*               FORM DRUCK_PRUEFEN                                     *
*----------------------------------------------------------------------*
*    Die ausgewählten Druckversion des Warenbegleitscheins wird geprüft*
*----------------------------------------------------------------------*
FORM DRUCK_PRUEFEN.
  CHECK NOT T158-KZBEW = O.
  IF NOT T158-TRTYP = H.                                         "661024
    IF XNAST IS INITIAL.                                         "661024
      CLEAR RM07M-XNAPR.                                         "661024
    ELSE.                                                        "661024
      RM07M-XNAPR = X.                                           "661024
    ENDIF.                                                       "661024
    EXIT.                                                        "661024
  ENDIF.                                                         "661024
  IF NOT AUTH04_WRK IS INITIAL.
    MESSAGE E122 WITH AUTH04_WRK.
  ENDIF.
  IF NOT AUTH04_BWA IS INITIAL.
    MESSAGE E123 WITH AUTH04_BWA.
  ENDIF.
  IF NOT RM07M-WVERS1 IS INITIAL.
    MKPF-WEVER = 1.
    T158-WEVER = 1.
  ENDIF.
  IF NOT RM07M-WVERS2 IS INITIAL.
    MKPF-WEVER = 2.
    T158-WEVER = 2.
  ENDIF.
* Changes per note 442706 dealing with collective slips and multiple
* account assignments. We always have to use single slip in that case.
* In MB_CREATE_GOODS_MOVEMENT form druck_pruefen is called in
* MB_CREATE_GOODS_ISSUE_HEADER. At that time X-MULKO is not known as PO
* data is processed during item processing. Therefore MKPF-WEVER and
* T158-WEVER needs to be adapted again in form buchen_nummmernvergabe
* before form kopfdialogstruktur_fuellen is called.
  IF NOT rm07m-wvers3 IS INITIAL AND NOT rm07m-xnapr is INITIAL. "HW 1145488
    IF t158-kzbew = b AND xmbwl IS INITIAL.
      IF NOT x_mulko IS INITIAL.
        MKPF-WEVER = 1.
        T158-WEVER = 1.
        RM07M-WVERS1 = RM07M-WVERS3.
        CLEAR RM07M-WVERS3.
      ELSE.
        MKPF-WEVER = 3.
        T158-WEVER = 3.
      ENDIF.
    ELSE.
      MKPF-WEVER = 3.
      T158-WEVER = 3.
    ENDIF.
  ENDIF.
  PRINT_UNAME = MKPF-USNAM.
  IF PRINT_UNAME IS INITIAL.
    PRINT_UNAME = SY-UNAME.
  ENDIF.
* Nachlesen Parameter NDR, wenn Verarbeitung über MB_CREATE -----------*
  IF NOT XMBWL IS INITIAL.
    IF NOT PR_UNAME IS INITIAL.
      PRINT_UNAME = PR_UNAME.
    ENDIF.
    IF PR_PRINT IS INITIAL.
      SELECT SINGLE * FROM USR05 WHERE BNAME = PRINT_UNAME
                                 AND   PARID = 'NDR'.
      IF SY-SUBRC IS INITIAL.
        RM07M-XNAPR = USR05-PARVA.
      ELSE.
        CLEAR RM07M-XNAPR.
      ENDIF.
    ELSEIF PR_PRINT = 1.
      RM07M-XNAPR = X.
    ELSEIF PR_PRINT = 2.
      CLEAR RM07M-XNAPR.
    ENDIF.
  ENDIF.
*----------------------------------------------------------------------*
  IF RM07M-XNAPR IS INITIAL.
    CLEAR T158-WEVER.
  ENDIF.
ENDFORM.