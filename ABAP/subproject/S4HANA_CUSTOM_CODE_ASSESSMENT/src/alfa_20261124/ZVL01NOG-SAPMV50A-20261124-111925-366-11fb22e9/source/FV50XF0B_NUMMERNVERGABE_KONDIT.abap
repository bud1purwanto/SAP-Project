***INCLUDE FV50XF0B_NUMMERNVERGABE_KONDIT .
*---------------------------------------------------------------------*
*       FORM NUMMERNVERGABE_KONDITIONEN                               *
*---------------------------------------------------------------------*
*  -->  IF_KOPF_TABIX                                                 *
*---------------------------------------------------------------------*
form nummernvergabe_konditionen using if_kopf_tabix like sy-tabix.

  DATA: KNUMP_ALT LIKE LIKP-KNUMP .

  IF NOT XLIKP-KALSP IS INITIAL.
    IF XLIKP-VBELN = XLIKP-KNUMP OR
       XLIKP-KNUMP(1) = '$' OR
       XLIKP-KNUMP IS INITIAL .
      KNUMP_ALT = XLIKP-KNUMP.
      call function 'NUMBER_GET_NEXT'
        exporting
          nr_range_nr = '01'
          object      = 'KONV'
        importing
          number      = xlikp-knump.
      likp-knump = xlikp-knump.
      modify xlikp index if_kopf_tabix.
      LOOP AT TKOMV WHERE KNUMV = KNUMP_ALT .
        tkomv-knumv = xlikp-knump.
        modify tkomv index sy-tabix.
      endloop.
    endif.
  endif.

* Billing of Replenishment Deliveries
* Get number for conditions in case of replenishment deliveries
  PERFORM /spe/condition_number_get TABLES   xlips[]
                                    USING    xlikp
                                    CHANGING xlikp-knumv.


endform.                    "NUMMERNVERGABE_KONDITIONEN