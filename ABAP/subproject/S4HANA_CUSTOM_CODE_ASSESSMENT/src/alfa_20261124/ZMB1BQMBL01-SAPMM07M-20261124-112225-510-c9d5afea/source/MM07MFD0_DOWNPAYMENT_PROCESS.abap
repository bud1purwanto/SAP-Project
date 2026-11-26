*&---------------------------------------------------------------------*
*&  Include           MM07MFD0_DOWNPAYMENT_PROCESS
*&---------------------------------------------------------------------*
* This subroutine is responsible for calling FM ME_DP_CLEARING, which
* handles the processing of down payments
* New lines are being added to xekbe.

* MAA EhP4 fields in PO history table EKBE_MA filled        "n1369731
* incorrectly, assign internal table ZDM07M, too            "n1369731

* MAA EhP4 consider the PO history table for multi account  "n1329660
* assignment, too                                           "n1329660

*----------------------------------------------------------------------*
*      <--T_XEKBE  PO History
*----------------------------------------------------------------------*

FORM downpayment_process
  USING     ut_zdm07m        TYPE  ty_t_dm07m               "n1369731
  CHANGING  ct_xekbe         TYPE  me_ekbe
            ct_xekbe_ma      TYPE  me_ekbe_ma_s.            "n1369731

  DATA: ls_ekbe TYPE ekbe.

* Search table EKBE for entries which represent a GR / GR cancellation
  READ TABLE ct_xekbe WITH KEY vgabe = eins
                         INTO ls_ekbe.

  IF sy-subrc = 0.
    CALL FUNCTION 'ME_DP_CLEARING'
      EXPORTING
        imd_vgabe   = eins
        imd_bukrs   = xmseg-bukrs
      TABLES                                                "n1369731
        imt_zdm07m  = ut_zdm07m                             "n1369731
      CHANGING
        cht_ekbe    = ct_xekbe
        cht_ekbe_ma = ct_xekbe_ma.                "n1329660 "n1369731
  ENDIF.

ENDFORM.                    "DOWNPAYMENT_PROCESS