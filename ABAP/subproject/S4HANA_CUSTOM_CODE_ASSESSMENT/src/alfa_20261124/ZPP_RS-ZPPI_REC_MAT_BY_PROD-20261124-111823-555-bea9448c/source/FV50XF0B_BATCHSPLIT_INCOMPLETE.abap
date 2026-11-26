*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_BATCHSPLIT_INCOMPLETE                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BATCHSPLIT_INCOMPLETE_CHECK
*&---------------------------------------------------------------------*
*       Checks whether batch split is complete or not yet done
*       if delivery is relevant for decentral processing.
*----------------------------------------------------------------------*
FORM BATCHSPLIT_INCOMPLETE_CHECK USING IS_LIKP LIKE LIKPVB.

  DATA: LF_SUBRC LIKE SY-SUBRC,
        LS_XLIPS LIKE LIPSVB,
        BEGIN OF LT_WORK OCCURS 0,
          POSNR LIKE LIPS-POSNR,
        END OF LT_WORK.

  CHECK IS_LIKP-VLSTK EQ CHARA AND IS_LIKP-VERURSYS IS INITIAL.

  LF_SUBRC = 0.
* Loop at all batch split items and extract main item numbers
  LOOP AT XLIPS WHERE VBELN EQ IS_LIKP-VBELN                "v_n_594230
                  AND UPDKZ NE UPDKZ_DELETE                 "^_n_594230
                  AND UECHA NE POSNR_LOW.
    LT_WORK-POSNR = XLIPS-UECHA.
    COLLECT LT_WORK.
  ENDLOOP.
  LOOP AT LT_WORK.
*   Read all main items and check delivery quantity
    LOOP AT XLIPS INTO LS_XLIPS WHERE VBELN EQ IS_LIKP-VBELN
                                  AND POSNR EQ LT_WORK-POSNR
                                  AND UPDKZ NE UPDKZ_DELETE.
*     Error if delivery quantity is greater than zero
      IF LS_XLIPS-LFIMG NE 0.
        LF_SUBRC = 4.
      ENDIF.
      EXIT.
    ENDLOOP.
*   No main item for batch split item or incomplete batch split: error
    IF LF_SUBRC NE 0 OR SY-SUBRC NE 0.
      LF_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF LF_SUBRC NE 0.
    PERFORM FINCHDEL_HANDLING(SAPFV50P) USING
                                IS_LIKP-VBELN '01' 'E' 'VL' '582'
                                SPACE SPACE SPACE SPACE GT_FINCHDEL.
  ENDIF.

ENDFORM.                               " BATCHSPLIT_INCOMPLETE_CHECK