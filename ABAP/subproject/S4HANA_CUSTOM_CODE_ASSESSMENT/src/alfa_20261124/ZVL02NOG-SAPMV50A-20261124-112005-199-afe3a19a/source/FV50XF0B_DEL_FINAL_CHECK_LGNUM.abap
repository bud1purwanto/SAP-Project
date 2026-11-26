*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_DEL_FINAL_CHECK_LGNUM                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DELIVERY_FINAL_CHECK_LGNUM
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
*      -->P_XLIKP  text
*----------------------------------------------------------------------*
FORM DELIVERY_FINAL_CHECK_LGNUM USING IS_LIKP STRUCTURE LIKP.

  DATA: LF_SUBRC LIKE SY-SUBRC.

  CHECK NOT IS_LIKP-VERURSYS IS INITIAL.

  PERFORM DELIVERY_SET_LGNUM_AND_VLSTK USING    SPACE
                                       CHANGING IS_LIKP
                                                LF_SUBRC.
  IF LF_SUBRC = 1.
    CASE V50AGL-SAMMELGANG.
      WHEN CHARX.
        PERFORM FINCHDEL_HANDLING(SAPFV50P) USING
        IS_LIKP-VBELN '01' 'E' 'VL' '409'
        SPACE SPACE SPACE SPACE GT_FINCHDEL.
      WHEN SPACE.
        PERFORM FINCHDEL_HANDLING(SAPFV50P) USING
        IS_LIKP-VBELN '01' 'E' 'VL' '408'
        SPACE SPACE SPACE SPACE GT_FINCHDEL.
    ENDCASE.
  ENDIF.

ENDFORM.                               " DELIVERY_FINAL_CHECK_LGNUM