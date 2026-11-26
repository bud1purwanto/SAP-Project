*----------------------------------------------------------------------*
*              Beim Ändern der EMATN wird hier auf                     *
*              Gültigkeit geprüft                                      *
*----------------------------------------------------------------------*
FORM mpn_pruefen.

* changed EMATN in MSEG, original data in FUSS or YMSEG     "835301
  IF fuss IS INITIAL AND mseg-zeile = ymseg-zeile           "835301
     AND NOT ymseg-ematn IS INITIAL.                        "835301
    CALL FUNCTION 'MB_MPN_CHANGE_READ_DATA'                 "835301
      EXPORTING                                             "835301
        o_ematn          = ymseg-ematn                      "835301
        o_mprof          = dm07m-mprof                      "835301
        matnr            = mseg-matnr                       "835301
        n_ematn          = mseg-ematn                       "835301
        werks            = mseg-werks                       "835301
        mprof            = dm07m-mprof                      "835301
        revlv            = dm07m-revlv                      "835301
        check_mpn_change = 'X'                              "835301
      CHANGING                                              "835301
        mfrnr            = dm07m-mfrnr                      "835301
        txz01            = dm07m-maktx.                     "835301
  ELSE.                                                     "835301
    CALL FUNCTION 'MB_MPN_CHANGE_READ_DATA'
      EXPORTING
        o_ematn          = fuss-ematn
        o_mprof          = fuss-mprof                       "835301
        matnr            = mseg-matnr
        n_ematn          = mseg-ematn
        werks            = mseg-werks
        mprof            = dm07m-mprof
        revlv            = dm07m-revlv                      "160969
        check_mpn_change = 'X'
      CHANGING
        mfrnr            = dm07m-mfrnr
        txz01            = fuss-maktx.
    dm07m-maktx = fuss-maktx.
  ENDIF.                                                    "835301
ENDFORM.