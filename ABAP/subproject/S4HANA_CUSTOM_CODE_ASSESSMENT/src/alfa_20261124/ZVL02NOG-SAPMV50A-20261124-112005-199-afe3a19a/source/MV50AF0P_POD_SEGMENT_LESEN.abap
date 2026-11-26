*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_POD_SEGMENT_LESEN                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  POD_SEGMENT_LESEN
*&---------------------------------------------------------------------*
*       POD Segmente zur Lieferung lesen
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pod_segment_lesen.
  DATA: lf_datum LIKE sy-datlo,
        lf_uzeit LIKE sy-timlo,
        gf_step  LIKE sy-tabix.

  READ TABLE xvbuk WITH KEY vbeln = likp-vbeln.
  IF sy-subrc EQ 0 AND xvbuk-wbstk NE charc AND sy-tcode EQ 'VLPOD'
    AND NOT fcode EQ 'ANZA_T' AND NOT xvbuk-pdstk EQ space.
    IF fcode EQ 'NEWD_T'.                         "note 376116
      CHECK 1 = 2.                                "note 376116
    ELSE.                                         "note 376116
      IF cl_ops_switch_check=>mm_sfws_sit( ) IS INITIAL.
        MESSAGE e058(vla) WITH likp-vbeln.
        CHECK 1 = 2.
      ELSE.
        IF lips-sitkz IS INITIAL.
          MESSAGE e058(vla) WITH likp-vbeln.
          CHECK 1 = 2.
        ENDIF.
      ENDIF.
    ENDIF.                                        "note 376116
  ELSEIF sy-subrc EQ 0 AND xvbuk-pdstk EQ space
         AND ( sy-tcode EQ 'VLPOD' OR sy-tcode EQ 'VLPODA' ).
      MESSAGE e646(vl) WITH likp-vbeln.
      CHECK 1 = 2.
  ENDIF.

  IF t180-trtyp EQ charv.
    GET PARAMETER ID 'DAT' FIELD lf_datum.
    GET PARAMETER ID 'TIM' FIELD lf_uzeit.
    IF NOT lf_datum IS INITIAL AND NOT lf_uzeit IS INITIAL  "n_971882
       AND sy-calld = 'X'.                                  "n_971882
      likp-podat = lf_datum.
      likp-potim = lf_uzeit.
    ELSEIF likp-potim = space AND likp-podat IS INITIAL.   "v_n_1271936
      likp-podat = sy-datlo.
      likp-potim = sy-timlo.                               "^_n_1271936
    ENDIF.
    READ TABLE xvbuk WITH KEY vbeln = likp-vbeln.
    IF sy-subrc EQ 0.
      IF xvbuk-wbstk EQ charc AND xvbuk-pdstk CA 'ABC'.
        MOVE charb TO r185d-dataloss.
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR gf_step.
  EXPORT gf_step TO MEMORY ID 'GF_STEP'.

  CALL FUNCTION 'LE_POD_TVPOD_READ'
    TABLES
      it_lips = xlips.

ENDFORM.                               " POD_SEGMENT_LESEN