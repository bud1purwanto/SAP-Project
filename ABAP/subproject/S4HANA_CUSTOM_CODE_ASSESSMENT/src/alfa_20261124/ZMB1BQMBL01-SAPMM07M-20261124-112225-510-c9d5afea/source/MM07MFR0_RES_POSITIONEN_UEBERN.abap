*eject
*---------------------------------------------------------------------*
*       FORM RES_POSITIONEN_UEBERNEHMEN_02                            *
*---------------------------------------------------------------------*
*       Die gefundenen Reservierungspositionen werden übernommen.     *
*---------------------------------------------------------------------*
FORM res_positionen_uebernehmen_02.

   DATA: ls_isu_umrechnen_me TYPE isu_umrechnen_me. "IS2ERP

  IF NOT rm07m-istmg IS INITIAL AND xrbefu-fmeng IS INITIAL.
    DATA: menge1 TYPE f.
    menge1 = ( rm07m-istmg * xrbefu-bdmng ) / rm07m-solmg.
    mseg-menge = menge1.
    IF mseg-meins = mseg-erfme.
      mseg-erfmg = menge1.
    ENDIF.
  ELSE.
    mseg-menge = xrbefu-offen.
    CLEAR mseg-erfmg.
  ENDIF.
  IF mseg-meins NE mseg-erfme
     OR ( mseg-meins = mseg-erfme AND mseg-erfmg IS INITIAL ).

    DATA: l_kzwso LIKE mara-kzwsm,     "Begin P40K033318 SW
          l_umwso LIKE mara-kzwsm,
          menge_f TYPE f,
          erfmg_f TYPE f.
    PERFORM read_kzwso(sapfm07m) CHANGING l_kzwso           "ALRK115218
                                          l_umwso.          "ALRK115218
    IF l_kzwso EQ 'B' AND mseg-charg IS INITIAL AND
       dm07m-umrez IS INITIAL AND dm07m-umren IS INITIAL.
      menge_f = xrbefu-offen.
      erfmg_f = xrbefu-erfmg.
      CALL FUNCTION 'CONVERT_TO_FRACT5'
           EXPORTING
                nomin               = menge_f
                denomin             = erfmg_f
           IMPORTING
                nomout              = dm07m-umrez
                denomout            = dm07m-umren
           EXCEPTIONS
                conversion_overflow = 1
                OTHERS              = 2.
    ENDIF.                             "End P40K033318 SW
    mseg-erfmg = 0.
    PERFORM umrechnen_me(sapfm07m) USING mseg-matnr
                                         mseg-charg         "ALR014884
                                         mseg-werks         "ALR014884
*                                         mseg-cuobj          "ALR014884
                                         mseg-meins
                                         mseg-erfme
                                         mseg-menge
                                         mseg-erfmg
                                        dm07m-umrez
                                        dm07m-umren
                                        ls_isu_umrechnen_me. "IS2ERP
    CLEAR: dm07m-umrez,
           dm07m-umren.

    IF l_kzwso EQ a AND                "P40K044742 SW
       mseg-erfmg NE xrbefu-erfmg.
      CALL FUNCTION 'ME_CHECK_T160M'
           EXPORTING
                i_arbgb = 'XU'
                i_msgnr = '051'
                i_msgvs = msgvs
           EXCEPTIONS
                nothing = 00
                warning = 01
                error   = 02.
      CASE sy-subrc.
        WHEN 0.
          MESSAGE s051(xu).
        WHEN 1.
          MESSAGE w051(xu).
        WHEN 2.
          MESSAGE e051(xu).
      ENDCASE.
                                       "        Geä
    ENDIF.                             "P40K044742 SW

  ENDIF.
ENDFORM.