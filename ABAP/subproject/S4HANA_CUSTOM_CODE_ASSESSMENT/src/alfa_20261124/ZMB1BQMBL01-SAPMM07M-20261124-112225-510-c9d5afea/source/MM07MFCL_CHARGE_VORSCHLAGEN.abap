***INCLUDE MM07MFCL_CHARGE_VORSCHLAGEN .
*----------------------------------------------------------------------*
*       FORM CHARGE_VORSCHLAGEN                                        *
*----------------------------------------------------------------------*
*       Vorschlag der Charge über CFC                                  *
*----------------------------------------------------------------------*
FORM charge_vorschlagen USING loc_charg LIKE mseg-charg.

* BADI BADI_BATCH_NUMBER_INT:            "ERP 2005
  DATA: l_badi_batch_number_int TYPE REF TO badi_batch_number_int.

  CHECK loc_charg IS INITIAL.

** internal BADI
  TRY.
      GET BADI l_badi_batch_number_int.

      CALL BADI l_badi_batch_number_int->get_batch
        EXPORTING
          i_mseg     = mseg
          i_vm07m    = vm07m
          i_dm07m    = dm07m
          i_mkpf     = mkpf
          i_transfer = space
        IMPORTING
          e_charg    = loc_charg.

    CATCH cx_badi_not_implemented .
  ENDTRY.

* Aufruf das Customer Function Call
  CALL CUSTOMER-FUNCTION '010'
       EXPORTING
            i_mseg     = mseg
            i_vm07m    = vm07m
            i_dm07m    = dm07m
            i_mkpf     = mkpf
            i_transfer = space
       IMPORTING
            e_charg    = loc_charg.

ENDFORM.                    "CHARGE_VORSCHLAGEN

*----------------------------------------------------------------------*
*       FORM UMCHARGE_VORSCHLAGEN                                      *
*----------------------------------------------------------------------*
*       Vorschlag der Umlager-Charge über CFC                          *
*----------------------------------------------------------------------*
FORM umcharge_vorschlagen USING loc_charg LIKE mseg-umcha.

  DATA:
    l_zustd             LIKE t156m-zustd.

* BADI BADI_BATCH_NUMBER_INT:            "ERP 2005
  DATA: l_badi_batch_number_int TYPE REF TO badi_batch_number_int.

  CHECK loc_charg IS INITIAL.
  IF dm07m-kzuml IS INITIAL.         "may not been determined yet
    IF mseg-xauto = l.
      l_zustd = l.
    ENDIF.
    SELECT COUNT(*)
      FROM t156m
      WHERE bustm EQ s156s-bustm
        AND zustd EQ l_zustd.
    CHECK sy-dbcnt GT 1.
  ENDIF.

* Check that the process is not a stock transfer order (STO) "1432402
* in case of two step transfer, it is not allowed to set a   "1432402
* receiving batch as MARC-TRAME has no batch assignment.     "1432402
* If the batch is split valuated, it can lead to valuation   "1432402
* incons when the batch valuation type differs from PO       "1432402
  CHECK mseg-kzzug IS INITIAL AND mseg-ebeln IS INITIAL.     "1432402

** internal BADI
  TRY.
      GET BADI l_badi_batch_number_int.

      CALL BADI l_badi_batch_number_int->get_batch
        EXPORTING
          i_mseg     = mseg
          i_vm07m    = vm07m
          i_dm07m    = dm07m
          i_mkpf     = mkpf
          i_transfer = x
        IMPORTING
          e_charg    = loc_charg.

    CATCH cx_badi_not_implemented .
  ENDTRY.

  CALL CUSTOMER-FUNCTION '010'
       EXPORTING
            i_mseg     = mseg
            i_vm07m    = vm07m
            i_dm07m    = dm07m
            i_mkpf     = mkpf
            i_transfer = x
       IMPORTING
            e_charg    = loc_charg.

ENDFORM.                    "UMCHARGE_VORSCHLAGEN