REPORT ZPP_UP_CLASS5
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
                              'ZZSRPE5'.
PERFORM BDC_FIELD       USING 'RMCLM-KLART'
                              '023'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=SCHL'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-SICHT'.
PERFORM BDC_FIELD       USING 'RMCLM-KLBEZ'
                              'Characteristic Jumbo Roll PE'.
PERFORM BDC_FIELD       USING 'RMCLM-STATU'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-SICHT'
                              'S'.
PERFORM BDC_FIELD       USING 'RMCLM-VONDT'
                              '14.11.2012'.
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
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(02)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(02)'
                              'ZZTYPE'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(03)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(03)'
                              'ZZTHICKNESS'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(04)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(04)'
                              'ZZDENSITY'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(05)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(05)'
                              'ZZEXPIREDLIVE'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(06)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(06)'
                              'ZZLENGTH'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(07)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(07)'
                              'ZZWIDTH'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(08)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(08)'
                              'ZZTREATMENT'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(09)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(09)'
                              'ZZINSIDE'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(10)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(10)'
                              'ZZOUTSIDE'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(11)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(11)'
                              'ZZCORE'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(12)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(12)'
                              'ZZGRADE'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(13)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MARK(12)'
                              'X'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(13)'
                              'ZZCRITERIA'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(14)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MARK(12)'
                              ''.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(14)'
                              'ZZGRAMMAGE'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(15)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '1'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(15)'
                              'ZZMONTHYEAR'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-EINTRAG'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(02)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(02)'
                              'ZZSEQUENCENBR'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(03)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(03)'
                              'ZZDERIVATIVEMS'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(04)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(04)'
                              'ZZPOSITIONMS'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(05)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(05)'
                              'ZZNOMORROLL'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(06)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(06)'
                              'ZZWEIGTHTOTAL'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(07)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(07)'
                              'ZZCONVERSIONROLLKG'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(08)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(08)'
                              'ZZCONVERSIONMTRKG'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(09)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(09)'
                              'ZZCONVERSIONKGM2'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(10)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(10)'
                              'ZZCONVERSIONROLLM2'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(11)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(11)'
                              'ZZALIAS'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(12)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(12)'
                              'ZZLABEL'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(13)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(13)'
                              'ZZPACKING'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(14)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(14)'
                              'ZZSPLICE-1'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(15)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '15'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(15)'
                              'ZZSPLICE-2'.
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
                              'RMCLM-MERKMA(02)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(02)'
                              'ZZSPLICE-3'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(03)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(03)'
                              'ZZSPECIALTOUCH-1'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(04)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(04)'
                              'ZZSPECIALTOUCH-2'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(05)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(05)'
                              'ZZSPECIALTOUCH-3'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(06)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(06)'
                              'ZZUNITOFMEASURE'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(07)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(07)'
                              'ZZPEMBILANGASAL'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(08)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(08)'
                              'ZZPEMBILANGBARU'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(09)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(09)'
                              'ZZPENYEBUTASAL'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(10)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(10)'
                              'ZZPENYEBUTBARU'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(11)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(11)'
                              'ZZEXLENGTH'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(12)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(12)'
                              'ZZPACKINGCODE'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(13)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(13)'
                              'ZZNUMBEROFROLL'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(14)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(14)'
                              'ZZTOTALM2'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(15)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '29'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(15)'
                              'ZZORDERUOM'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-EINTRAG'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '45'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(02)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '43'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(02)'
                              'ZZORDERQTYREAD'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(03)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '43'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(03)'
                              'ZZORDERQTYWRITE'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(04)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '43'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(04)'
                              'ZZWEIGHT'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(05)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '43'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(05)'
                              'ZZSCRAP'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(06)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '43'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(06)'
                              'ZZWEIGHTEL'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(07)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '43'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(07)'
                              'ZZEXLENGTHASAL'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(08)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '43'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(08)'
                              'ZZSPEED'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(09)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '43'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(09)'
                              'ZZNOLOTTOYOBO'.
PERFORM BDC_DYNPRO      USING 'SAPLCLMO' '7777'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RMCLM-MERKMA(10)'.
PERFORM BDC_FIELD       USING 'RMCLM-EINTRAG'
                              '43'.
PERFORM BDC_FIELD       USING 'RMCLM-MERKMA(10)'
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