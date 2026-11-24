REPORT ZPP_UP_CLASS3
       NO STANDARD PAGE HEADING LINE-SIZE 255.

INCLUDE BDCRECX1.

START-OF-SELECTION.

  PERFORM OPEN_GROUP.

  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '0100'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-CLASS'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RMCLM-CLASS'
                                'ZZSRPE1'.
  PERFORM BDC_FIELD       USING 'RMCLM-KLART'
                                '023'.

  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SCHL'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-SICHT'.
  PERFORM BDC_FIELD       USING 'RMCLM-KLBEZ'
                                'Characteristic Slit Roll PE 1'.
  PERFORM BDC_FIELD       USING 'RMCLM-STATU'
                                '1'.
  PERFORM BDC_FIELD       USING 'RMCLM-SICHT'
                                'S'.
  PERFORM BDC_FIELD       USING 'RMCLM-VONDT'
                                '05.11.2012'.
  PERFORM BDC_FIELD       USING 'RMCLM-BISDT'
                                '31.12.9999'.
  PERFORM BDC_FIELD       USING 'RMCLM-PRAUS'
                                'X'.


  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=MERK'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-KSCHL(01)'.


  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-MERKMA(15)'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(01)'
                                'ZZPRODLINE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(02)'
                                'ZZCODE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(03)'
                                'ZZTYPE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(04)'
                                'ZZTHICKNESS'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(05)'
                                'ZZDENSITY'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(06)'
                                'ZZEXPIREDLIVE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(07)'
                                'ZZLENGTH'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(08)'
                                'ZZWIDTH'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(09)'
                                'ZZTREATMENT'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(10)'
                                'ZZINSIDE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(11)'
                                'ZZOUTSIDE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(12)'
                                'ZZCORE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(13)'
                                'ZZGRADE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(14)'
                                'ZZCRITERIA'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(15)'
                                'ZZGRAMMAGE'.

  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-EINTRAG'.
  PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                                '16'.


  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-EINTRAG'.
  PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                                '15'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(02)'
                                'ZZMONTHYEAR'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(03)'
                                'ZZSEQUENCENBR'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(04)'
                                'ZZDERIVATIVEMS'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(05)'
                                'ZZPOSITIONMS'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(06)'
                                'ZZDERIVATIVESS'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(07)'
                                'ZZPOSITIONSS'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(08)'
                                'ZZNOMORROLL'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(09)'
                                'ZZCONVERSIONROLLKG'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(10)'
                                'ZZCONVERSIONMTRKG'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(11)'
                                'ZZCONVERSIONKGM2'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(12)'
                                'ZZCONVERSIONROLLM2'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(13)'
                                'ZZALIAS'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(14)'
                                'ZZLABEL'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(15)'
                                'ZZPACKING'.

  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-EINTRAG'.
  PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                                '30'.
  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-MERKMA(14)'.
  PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                                '29'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(02)'
                                'ZZSPECIALTOUCH-1'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(03)'
                                'ZZSPECIALTOUCH-2'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(04)'
                                'ZZSPECIALTOUCH-3'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(05)'
                                'ZZUNITOFMEASURE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(06)'
                                'ZZEXLENGTH'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(07)'
                                'ZZPACKINGCODE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(08)'
                                'ZZNUMBEROFROLL'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(09)'
                                'ZZTOTALM2'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(10)'
                                'ZZORDERUOM'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(11)'
                                'ZZORDERQTYREAD'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(12)'
                                'ZZORDERQTYWRITE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(13)'
                                'ZZWEIGHT'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(14)'
                                'ZZWEIGHTEL'.
  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SAVE'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-MERKMA(01)'.
  PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                                '29'.
  PERFORM BDC_TRANSACTION USING 'CL01'.

  PERFORM CLOSE_GROUP.