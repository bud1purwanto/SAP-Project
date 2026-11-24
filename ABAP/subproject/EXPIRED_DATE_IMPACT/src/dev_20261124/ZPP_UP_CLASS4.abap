REPORT ZPP_UP_CLASS4
       NO STANDARD PAGE HEADING LINE-SIZE 255.

INCLUDE BDCRECX1.

START-OF-SELECTION.

  PERFORM OPEN_GROUP.

  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '0100'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-AENNR'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RMCLM-CLASS'
                                'ZZJRPE24'.
  PERFORM BDC_FIELD       USING 'RMCLM-KLART'
                                '023'.
  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '0100'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-CLASS'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'RMCLM-CLASS'
                                'ZZJRPE24'.
  PERFORM BDC_FIELD       USING 'RMCLM-KLART'
                                '023'.
  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-SICHT'.
  PERFORM BDC_FIELD       USING 'RMCLM-KLBEZ'
                                'Characteristic Jumbo Roll PE'.
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
                                '=SCHL'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-KLBEZ'.
  PERFORM BDC_FIELD       USING 'RMCLM-KLBEZ'
                                'Characteristic Jumbo Roll PE'.
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
                                'RMCLM-MERKMA(01)'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(01)'
                                'ZZCODE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(02)'
                                'ZZTYPE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(03)'
                                'ZZTHICKNESS'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(04)'
                                'ZZDENSITY'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(05)'
                                'ZZEXPIREDLIVE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(06)'
                                'ZZLENGTH'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(07)'
                                'ZZWIDTH'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(08)'
                                'ZZTREATMENT'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(09)'
                                'ZZINSIDE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(10)'
                                'ZZOUTSIDE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(11)'
                                'ZZCORE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(12)'
                                'ZZGRADE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(13)'
                                'ZZCRITERIA'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(14)'
                                'ZZGRAMMAGE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(15)'
                                'ZZMONTHYEAR'.
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
                                'RMCLM-MERKMA(02)'.
  PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                                '15'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(02)'
                                'ZZSEQUENCENBR'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(03)'
                                'ZZDERIVATIVEMS'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(04)'
                                'ZZPOSITIONMS'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(05)'
                                'ZZDERIVATIVESS'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(06)'
                                'ZZPOSITIONSS'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(07)'
                                'ZZNOMORROLL'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(08)'
                                'ZZWEIGTHTOTAL'.
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
                                '31'.
  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-MERKMA(02)'.
  PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                                '29'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(02)'
                                'ZZSPLICE-1'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(03)'
                                'ZZSPLICE-2'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(04)'
                                'ZZSPLICE-3'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(05)'
                                'ZZSPECIALTOUCH-1'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(06)'
                                'ZZSPECIALTOUCH-2'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(07)'
                                'ZZSPECIALTOUCH-3'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(08)'
                                'ZZUNITOFMEASURE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(09)'
                                'ZZPEMBILANGASAL'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(10)'
                                'ZZPEMBILANGBARU'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(11)'
                                'ZZPENYEBUTASAL'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(12)'
                                'ZZPENYEBUTBARU'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(13)'
                                'ZZEXLENGTH'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(14)'
                                'ZZPACKINGCODE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(15)'
                                'ZZNUMBEROFROLL'.
  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-EINTRAG'.
  PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                                '46'.
  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-MERKMA(02)'.
  PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                                '43'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(02)'
                                'ZZORDERUOM'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(03)'
                                'ZZORDERQTYREAD'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(04)'
                                'ZZORDERQTYWRITE'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(05)'
                                'ZZWEIGHT'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(06)'
                                'ZZSCRAP'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(07)'
                                'ZZWEIGHTEL'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(08)'
                                'ZZEXLENGTHASAL'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(09)'
                                'ZZSPEED'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(10)'
                                'ZZNOLOTTOYOBO'.
  PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(11)'
                                'ZZNOROLLTOYOBO'.
  PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SAVE'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RMCLM-MERKMA(01)'.
  PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                                '43'.
  PERFORM BDC_TRANSACTION USING 'CL01'.

  PERFORM CLOSE_GROUP.