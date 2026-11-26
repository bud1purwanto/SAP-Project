*eject
*---------------------------------------------------------------------*
*       FORM ANHANG_BEREINIGEN                                        *
*---------------------------------------------------------------------*
*       Die Tabellen DM07M und VM07M werden bereinigt.                *
*---------------------------------------------------------------------*
FORM ANHANG_BEREINIGEN.
  DATA: FAUSW LIKE DM07M-FAUSW,
        BTEXT LIKE DM07M-BTEXT,
        KZGRU LIKE DM07M-KZGRU,
        XPBED LIKE VM07M-XPBED,
        XSTBW LIKE DM07M-XSTBW,
        MAKTX LIKE DM07M-MAKTX,
        SOBFI LIKE VM07M-SOBFI,
        SOBLO LIKE VM07M-SOBLO,
        SOBVO LIKE VM07M-SOBVO,
        UMSOF LIKE DM07M-UMSOF,
        UMSOL LIKE DM07M-UMSOL,
        UMSOV LIKE DM07M-UMSOV,
        UMSOK LIKE MSEG-UMSOK,
        WERKS LIKE MSEG-WERKS,
        KZMHD LIKE T156-KZMHD,
        UMKZBWS LIKE MSEG-KZBWS.
  FAUSW = DM07M-FAUSW.
  KZGRU = DM07M-KZGRU.
  XPBED = VM07M-XPBED.
  XSTBW = DM07M-XSTBW.
  BTEXT = DM07M-BTEXT.
  MAKTX = DM07M-MAKTX.
  SOBFI = VM07M-SOBFI.
  SOBLO = VM07M-SOBLO.
  SOBVO = VM07M-SOBVO.
  UMSOF = DM07M-UMSOF.
  UMSOL = DM07M-UMSOL.
  UMSOV = DM07M-UMSOV.
  UMSOK = MSEG-UMSOK.
  WERKS = MSEG-WERKS.
  KZMHD = T156-KZMHD.
  UMKZBWS = DM07M-UMKZBWS.
  CLEAR: DM07M, VM07M.
  perform j_1b_tax_proc_set.          "note 205012
  IF NEXT_FAUSW IS INITIAL.
    DM07M-FAUSW = FAUSW.
    DM07M-BTEXT = BTEXT.
    VM07M-SOBFI = SOBFI.
    VM07M-SOBLO = SOBLO.
    VM07M-SOBVO = SOBVO.
    DM07M-UMSOF = UMSOF.
    DM07M-UMSOL = UMSOL.
    DM07M-UMSOV = UMSOV.
    DM07M-KZGRU = KZGRU.
    DM07M-XSTBW = XSTBW.
    VM07M-XPBED = XPBED.
    MSEG-UMSOK  = UMSOK.
    DM07M-KZMHD = KZMHD.
    DM07M-UMKZBWS = UMKZBWS.
  ELSE.
    DM07M-FAUSW = NEXT_FAUSW.
    DM07M-BTEXT = NEXT_BTEXT.
    VM07M-SOBFI = NEXT_SOBFI.
    VM07M-SOBLO = NEXT_SOBLO.
    VM07M-SOBVO = NEXT_SOBVO.
    DM07M-UMSOF = NEXT_UMSOF.
    DM07M-UMSOL = NEXT_UMSOL.
    DM07M-UMSOV = NEXT_UMSOV.
    DM07M-KZGRU = NEXT_KZGRU.
    DM07M-XSTBW = NEXT_XSTBW.
    VM07M-XPBED = NEXT_XPBED.
    MSEG-UMSOK  = NEXT_UMSOK.
    DM07M-UMKZBWS = NEXT_UMKZBWS.
    DM07M-KZMHD = KZMHD.
  ENDIF.
  UMSOK = MSEG-UMSOK.
  IF ANF_BILD IS INITIAL.
    CLEAR MSEG.
    MSEG-BWART = RM07M-BWART.
    MSEG-SOBKZ = RM07M-SOBKZ.
    MSEG-UMSOK = UMSOK.
    MSEG-GRUND = RM07M-GRUND.
    DM07M-UMKZBWS = UMKZBWS.
    PERFORM WERK_PRUEFEN(SAPFM07M) USING    X
                                        RM07M-WERKS
                                        VM07M-BWKEY
                                        DM07M-BWMOD
                                        DM07M-XEINK
                                        DM07M-XBKNG
                                        VM07M-XVKBW
                                        RM07M-BUKRS
                                        DM07M-KTOPL
                                        DM07M-PERIV
                                         MSEG-WAERS
                                         MKPF-BUDAT
                                         MSEG-GJAHR
                                        VM07M-MONAT
                                         MSEG-XRUEM
                                         MSEG-XRUEJ
                                        VM07M-LFGJA
                                        VM07M-LFMON
                                        DM07M-FABKL
                                        DM07M-KZXAB.
    MSEG-PARBU = RM07M-BUKRS.
    MSEG-WERKS = RM07M-WERKS.
    MSEG-LGORT = RM07M-LGORT.
  ELSE.
    DM07M-MAKTX = MAKTX.
  ENDIF.
ENDFORM.