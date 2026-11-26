*&---------------------------------------------------------------------*
*&  Include           /SPE/STO_DELIV_F03                               *
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM /spe/condition_number_get TABLES   it_lipsvb TYPE shp_lips_t
                               USING    is_likpvb TYPE likpvb
                               CHANGING c_knumv   TYPE likpvb-knumv.

  CONSTANTS: lc_number_range TYPE inri-nrrangenr VALUE '01',
             lc_cond_object  TYPE inri-object    VALUE 'KONV'.

  DATA: l_is_repl_deliv TYPE xflag.




* first check if delivery is a replenishment delivery for an STO
  CALL FUNCTION '/SPE/STO_REPL_DELIV_CHECK'
    EXPORTING
      is_likpvb       = is_likpvb
    IMPORTING
      e_is_repl_deliv = l_is_repl_deliv
    TABLES
      it_lipsvb       = it_lipsvb.

  CHECK l_is_repl_deliv <> space.

* Is the Delivery Relevant for Billing?
  READ TABLE it_lipsvb WITH KEY vbeln = is_likpvb-vbeln fkrel = 'V'.
  CHECK sy-subrc EQ 0.

  IF is_likpvb-knumv = space.
* Get number for conditions
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = lc_number_range
        object      = lc_cond_object
      IMPORTING
        number      = c_knumv.
  ENDIF.

ENDFORM.                    "/spe/condition_number_get