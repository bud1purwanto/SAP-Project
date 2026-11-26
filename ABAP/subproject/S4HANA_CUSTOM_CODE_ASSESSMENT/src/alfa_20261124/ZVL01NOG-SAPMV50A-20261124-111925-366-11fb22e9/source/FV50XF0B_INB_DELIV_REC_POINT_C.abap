***INCLUDE FV50XF0B_INB_DELIV_REC_POINT_C .
*&---------------------------------------------------------------------*
*&      Form  INB_DELIV_REC_POINT_CHECK
*&---------------------------------------------------------------------*
*       Inbound deliveries which are to be submitted to a decentral
*       WM system require a receiving point
*----------------------------------------------------------------------*
FORM INB_DELIV_REC_POINT_CHECK USING IS_LIKP LIKE LIKPVB.

  IF IS_LIKP-VBTYP    EQ VBTYP_LIAV AND
     IS_LIKP-VERURSYS IS INITIAL    AND
     IS_LIKP-VLSTK    EQ CHARA      AND
     IS_LIKP-VSTEL    IS INITIAL.
    PERFORM FINCHDEL_HANDLING(SAPFV50P) USING
                                IS_LIKP-VBELN '01' 'E' 'VL' '581'
                                SPACE SPACE SPACE SPACE GT_FINCHDEL.
  ENDIF.

ENDFORM.                               " INB_DELIV_REC_POINT_CHECK