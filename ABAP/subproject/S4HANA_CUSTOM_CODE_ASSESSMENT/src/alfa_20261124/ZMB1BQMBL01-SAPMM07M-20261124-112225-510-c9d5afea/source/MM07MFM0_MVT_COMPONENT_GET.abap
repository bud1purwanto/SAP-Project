*&---------------------------------------------------------------------*
*&  Include           MM07MFM0_MVT_COMPONENT_GET                       *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  mvt_component_get
*&---------------------------------------------------------------------*
*  - Get movement type for subcontracting component
*  - Subsequent adjustment: Analyze negative quantity
*----------------------------------------------------------------------*
FORM mvt_component_get  USING    i_dimng
                                 i_rshkz
                        CHANGING e_bwart
                                 e_erfmg.

  IF i_dimng < 0.
    IF i_rshkz = h.
      SELECT SINGLE * FROM t156n WHERE fcode = fcod-lbws
                                  AND  bwart = space.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'T156N' fcod-lbws.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM t156n WHERE fcode = fcod-lbns
                                  AND  bwart = space.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'T156N' fcod-lbns.
      ENDIF.
    ENDIF.
    e_erfmg = 0 - i_dimng.
  ELSE.
    IF i_rshkz = h.
      SELECT SINGLE * FROM t156n WHERE fcode = fcod-lbwa
                                  AND  bwart = space.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'T156N' fcod-lbwa.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM t156n WHERE fcode = fcod-lbna
                                  AND  bwart = space.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e001 WITH 'T156N' fcod-lbna.
      ENDIF.
    ENDIF.
    e_erfmg = i_dimng.
  ENDIF.
  e_bwart = t156n-bwart_next.

ENDFORM.                    " mvt_component_get