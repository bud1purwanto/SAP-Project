*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_IEHS                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM FCODE_IEHS                                               *
*---------------------------------------------------------------------*
*       Aufruf EH&S Berichtsauskunft                                  *
*---------------------------------------------------------------------*
FORM FCODE_IEHS USING H185F STRUCTURE T185F
                      H185  STRUCTURE T185
                      H185V STRUCTURE T185V.

* local data -----------------------------------------------------------
  DATA : L_MATNR_TAB LIKE QMATNR OCCURS 10 WITH HEADER LINE.
  DATA:  L_BADI_INSTANCE TYPE REF TO IF_EX_EHS_PS_002.
  DATA:  EHS_PS_002_ACTIVE TYPE XFELD VALUE 'X'.

* function body --------------------------------------------------------

  REFRESH L_MATNR_TAB.

* copy all materials to l_matnr_tab
  LOOP AT XVBAP.
    CLEAR L_MATNR_TAB.
    L_MATNR_TAB-MATNR = XVBAP-MATNR.
    APPEND L_MATNR_TAB.
  ENDLOOP.

  CALL METHOD CL_EXITHANDLER=>GET_INSTANCE
    EXPORTING
        EXIT_NAME              = 'EHS_PS_002'
        NULL_INSTANCE_ACCEPTED = 'X'
    IMPORTING
        ACT_IMP_EXISTING = EHS_PS_002_ACTIVE
    CHANGING
      INSTANCE = L_BADI_INSTANCE
    EXCEPTIONS
      OTHERS   = 1.

* call the report info-system
    CALL METHOD L_BADI_INSTANCE->ENTRY_INQUIERY
      EXPORTING
        I_FLG_NEW_TASK   = EHS01_TRUE
        I_QMATNR_TAB     = L_MATNR_TAB[]
      EXCEPTIONS
        ILLEGAL_REPTYPE  = 1
        ILLEGAL_RVLID    = 2
        ILLEGAL_LANGU    = 3
        NO_MATERIALS     = 4
        NO_REPORTS_FOUND = 5
        INTERNAL_ERROR   = 6
        RFC_FAILED       = 7
        OTHERS           = 8.
    IF SY-SUBRC <> 0.
      CASE SY-SUBRC.
        WHEN 5.
          MESSAGE I002(CB01) WITH ''.
*       Es wurden keine & Berichte gefunden
        WHEN OTHERS.
          MESSAGE S001(CB01) WITH 'C1G1_ENTRY_INQUIERY_APPOBJ'
                                SY-REPID
                                SY-SUBRC
                                ''.
*   interner System-Fehler! (&1 &2 &3 &4)
    ENDCASE.
  ENDIF.

ENDFORM.                    "FCODE_IEHS