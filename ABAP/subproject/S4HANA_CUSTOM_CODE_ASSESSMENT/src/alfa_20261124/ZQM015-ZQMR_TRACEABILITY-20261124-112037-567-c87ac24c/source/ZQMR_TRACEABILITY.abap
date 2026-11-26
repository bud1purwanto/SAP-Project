*&---------------------------------------------------------------------*
*& Report  ZQMR_TRACEABILITY
*&
*&---------------------------------------------------------------------*
* Description      : Traceability Report
*
* Application Area - QM
* ABAPer           - PST - Adhy
* Date             - 08 November 2012
*----------------------------------------------------------------------*
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | ##.##.## |             |            | Program created          *
*&---------------------------------------------------------------------*

REPORT  ZQMR_TRACEABILITY.

INCLUDE ZQMR_TRACEABILITY_TOP.
INCLUDE ZQMR_TRACEABILITY_DATA.

*-- Untuk initial awal di selection screen
INITIALIZATION.
*  PERFORM SBU.
  TEXT    = 'OR'.
  G_REPID = SY-REPID. "call report id
  Y_PRINT-NO_PRINT_SELINFOS = 'X'.
  Y_PRINT-NO_PRINT_LISTINFOS = 'X'.
  PERFORM LAYOUT_INIT USING GS_LAYOUT. "call ALV layout for report by gs_layout
  PERFORM EVENTTAB_BUILD USING GT_EVENTS[].
  GS_VARIANT-REPORT = G_REPID.
  G_SAVE = 'A'.

START-OF-SELECTION.
  CLEAR : IT_DETAIL, IT_DETAIL2, IT_DISPLAY, IT_LIST, IT_FINAL3, IT_ISSUE, IT_ORDER, IT_ORDER2, IT_ISSUE_PO, IT_ISSUE_OR, CHECK.
  REFRESH : IT_DETAIL, IT_DETAIL2, IT_DISPLAY, IT_LIST, IT_FINAL3, IT_ISSUE, IT_ORDER, IT_ORDER2, IT_ISSUE_PO, IT_ISSUE_OR.

*-- VALIDASI SELECTION SCREEN
  SELECT SINGLE CHARG FROM MCH1 INTO CHECK WHERE CHARG EQ V_CHARG.
  IF V_CHARG IS INITIAL AND V_ATWRT IS INITIAL.
    MESSAGE 'Please enter only either Roll Number or Batch Number !' TYPE 'I'.
  ELSEIF V_CHARG IS NOT INITIAL AND V_ATWRT IS NOT INITIAL.
    MESSAGE 'Please enter only either Roll Number or Batch Number !' TYPE 'I'.
  ELSEIF CHECK IS INITIAL AND V_ATWRT IS INITIAL.
    MESSAGE 'Batch not found' TYPE 'I'.
  ELSE.

*-- FLOW PROGRAM
    IF R2 EQ 'X'.             "Trace Customer
      PERFORM GET_DETAIL.
      PERFORM DISPLAY.
    ELSEIF R1 EQ 'X'.         "Trace Roll
      PERFORM GET_DATA.
      PERFORM DISPLAY2.
    ELSEIF R3 EQ 'X'.
      IF V_CHARG NE ''.
        RANGES: P_CHARG_TMP FOR MCH1-CHARG.
        P_CHARG_TMP-SIGN = 'I'.
        P_CHARG_TMP-OPTION = 'EQ'.
        P_CHARG_TMP-LOW = V_CHARG.
        APPEND P_CHARG_TMP.
      ELSEIF V_ATWRT NE ''.
        RANGES: P_ROLL FOR AUSP-ATWRT.
        P_ROLL-SIGN = 'I'.
        P_ROLL-OPTION = 'EQ'.
        P_ROLL-LOW = V_ATWRT.
        APPEND P_ROLL.
      ENDIF.
      SUBMIT ZPP_SR_INPUT WITH P_CHARG IN P_CHARG_TMP
                        WITH P_ROLNO IN P_ROLL AND RETURN.
    ENDIF.
  ENDIF.

END-OF-SELECTION.