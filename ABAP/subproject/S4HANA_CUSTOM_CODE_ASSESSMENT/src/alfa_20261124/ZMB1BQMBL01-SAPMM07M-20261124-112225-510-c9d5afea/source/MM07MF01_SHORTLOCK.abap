*----------------------------------------------------------------------*
***INCLUDE MM07MF01_SHORTLOCK .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  first_fill_enq_exc_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ENQUEUE_EXCEPTIONS  text
*----------------------------------------------------------------------*
FORM FIRST_FILL_ENQ_EXC_TAB
   TABLES
    P_LT_ENQUEUE_EXCEPTIONS STRUCTURE ENQUEUES_EXCEPTION_S
    USING P_MATBF
          P_BWKEY
          P_BWTAR
          P_SOBKZ
          P_KDAUF
          P_KDPOS
          P_PSPNR
          P_LIFNR
          P_MENGE
          P_SHKZG
          P_EXBWR
          P_KZBEW.

  DATA: WA_ENQUEUE_EXCEPTIONS LIKE ENQUEUES_EXCEPTION_S.

  CLEAR  WA_ENQUEUE_EXCEPTIONS.
  CLEAR P_LT_ENQUEUE_EXCEPTIONS.
* check if valuated stock posting:
  READ TABLE X156W WITH KEY
    BUSTW = ZMSEG-BUSTW
    VORSL = 'BSX'.
  IF SY-SUBRC = 0.
    WA_ENQUEUE_EXCEPTIONS-BWKEY = P_BWKEY.
    WA_ENQUEUE_EXCEPTIONS-MATNR = P_MATBF.
    WA_ENQUEUE_EXCEPTIONS-BWTAR = P_BWTAR.
    WA_ENQUEUE_EXCEPTIONS-SOBKZ = P_SOBKZ.
    WA_ENQUEUE_EXCEPTIONS-VBELN = P_KDAUF.      "E
    WA_ENQUEUE_EXCEPTIONS-POSNR = P_KDPOS.      "E
    WA_ENQUEUE_EXCEPTIONS-PSPNR = P_PSPNR.      "Q
    WA_ENQUEUE_EXCEPTIONS-LIFNR = P_LIFNR.      "O
*   test case: Retourenpositonen. Stimmt da das SHKZG ?
    IF P_SHKZG = 'H'.
      WA_ENQUEUE_EXCEPTIONS-MENGE =  0 - P_MENGE.
    ELSE.
      WA_ENQUEUE_EXCEPTIONS-MENGE = P_MENGE.
    ENDIF.
* hier eventuell auf zmseg-VPRSV abfragen.. und dann exklusiv sperren,
* falls man sich in richtung null bewegt???
    IF NOT P_EXBWR IS INITIAL OR NOT P_KZBEW IS INITIAL.
      WA_ENQUEUE_EXCEPTIONS-BSX_POSTING = 'E'.
    ELSE.
      WA_ENQUEUE_EXCEPTIONS-BSX_POSTING = 'X'.
    ENDIF.
  ENDIF.
  COLLECT WA_ENQUEUE_EXCEPTIONS INTO P_LT_ENQUEUE_EXCEPTIONS.


************************************************************
** check if valuated stock posting:
*  READ TABLE X156W WITH KEY
*    BUSTW = ZMSEG-BUSTW
*    VORSL = 'BSX'.
*  IF SY-SUBRC = 0.
*    WA_ENQUEUE_EXCEPTIONS-BWKEY = ZMSEG-WERKS.
*    WA_ENQUEUE_EXCEPTIONS-MATNR = ZMSEG-MATNR.
*    WA_ENQUEUE_EXCEPTIONS-BWTAR = ZMSEG-BWTAR.
*    WA_ENQUEUE_EXCEPTIONS-SOBKZ = ZMSEG-SOBKZ.
*    WA_ENQUEUE_EXCEPTIONS-VBELN = ZMSEG-KDAUF.      "E
*    WA_ENQUEUE_EXCEPTIONS-POSNR = ZMSEG-KDPOS.      "E
*    WA_ENQUEUE_EXCEPTIONS-PSPNR = ZMSEG-PS_PSP_PNR. "Q  ??? wrong!!
*    WA_ENQUEUE_EXCEPTIONS-LIFNR = ZMSEG-LIFNR .     "O
*
**   test case: Retourenpositonen. Stimmt da das SHKZG ?
*    IF ZMSEG-SHKZG = 'H'.
*      WA_ENQUEUE_EXCEPTIONS-MENGE =  0 - ZMSEG-MENGE.
*    ELSE.
*      WA_ENQUEUE_EXCEPTIONS-MENGE = ZMSEG-MENGE.
*    ENDIF.
** hier eventuell auf zmseg-VPRSV abfragen.. und dann exklusiv sperren,
** falls man sich in richtung null bewegt???
*    IF NOT ZMSEG-EXBWR IS INITIAL OR NOT ZMSEG-KZBEW IS INITIAL.
*      WA_ENQUEUE_EXCEPTIONS-BSX_POSTING = 'E'.
*    ELSE.
*      WA_ENQUEUE_EXCEPTIONS-BSX_POSTING = 'X'.
*    ENDIF.
*  ENDIF.
*  COLLECT WA_ENQUEUE_EXCEPTIONS INTO P_LT_ENQUEUE_EXCEPTIONS.

ENDFORM.                    " first_fill_enq_exc_tab