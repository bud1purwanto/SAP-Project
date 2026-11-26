*eject
*---------------------------------------------------------------------*
*       FORM BUCHEN_MAT_PREFETCH_FUELLEN                              *
*---------------------------------------------------------------------*
*       Der Material Prefetch wird gefüllt.                           *
*---------------------------------------------------------------------*
FORM BUCHEN_MAT_PREFETCH_FUELLEN
                               TABLES LT_ENQUEUE_EXCEPTIONS     "396879
                                 STRUCTURE ENQUEUES_EXCEPTION_S "396879
                                 USING B-MATBF LIKE MSEG-MATBF
                                       B-BWKEY LIKE VM07M-BWKEY
                                       B-BWTAR LIKE MSEG-BWTAR
                                       B-SOBKZ LIKE MSEG-SOBKZ
                                       B-KZBWS LIKE MSEG-KZBWS
                                       B-XOBEW LIKE MSEG-XOBEW"kaz
                                       B-LIFNR LIKE MSEG-LIFNR"kaz
                                  B-PS_PSP_PNR LIKE MSEG-PS_PSP_PNR
                                       B-KDAUF LIKE MSEG-KDAUF
                                       B-KDPOS LIKE MSEG-KDPOS
                                       B-XEXEQ LIKE DM07M-XEXEQ
                                       B-MENGE LIKE MSEG-MENGE "396879
                                       B-SHKZG LIKE MSEG-SHKZG "396879
                                       B-EXBWR LIKE MSEG-EXBWR "396879
                                       B-KZBEW LIKE MSEG-KZBEW."396879
  DATA: PXOBEW LIKE MSEG-XOBEW.                             "kaz
  PXOBEW = B-XOBEW.                                         "kaz
  IF B-SOBKZ NE O.                                          "kaz
    CLEAR PXOBEW.                                           "kaz
  ENDIF.                                                    "kaz
* IF b-kzbws IS INITIAL OR b-kzbws = a.                             "kaz
  IF ( B-KZBWS IS INITIAL OR B-KZBWS = A ) AND PXOBEW IS INITIAL."kaz
    PREFETCH04-MATNR = B-MATBF.
    PREFETCH04-BWKEY = B-BWKEY.
    PREFETCH04-BWTAR = B-BWTAR.
    COLLECT PREFETCH04.
    IF TCURM-MBEQU = '3'.                                   "396879
      PERFORM FIRST_FILL_ENQ_EXC_TAB
        TABLES  LT_ENQUEUE_EXCEPTIONS
        USING   B-MATBF
                B-BWKEY
                B-BWTAR
                ' '
                ' '
                ' '
                ' '
                ' '
                B-MENGE
                B-SHKZG
                B-EXBWR
                B-KZBEW.
    ENDIF.                                                  "396879

* ELSEIF b-kzbws = o OR b-kzbws = m.                                "kaz
  ELSEIF B-KZBWS = O OR B-KZBWS = M OR NOT PXOBEW IS INITIAL."kaz
    IF B-SOBKZ = E.
      PREFETCH21-MATNR = B-MATBF.
      PREFETCH21-BWKEY = B-BWKEY.
      PREFETCH21-BWTAR = B-BWTAR.
      PREFETCH21-SOBKZ = B-SOBKZ.
      PREFETCH21-VBELN = B-KDAUF.
      PREFETCH21-POSNR = B-KDPOS.
      COLLECT PREFETCH21.
      IF TCURM-MBEQU = '3'.                                 "396879
        PERFORM FIRST_FILL_ENQ_EXC_TAB
          TABLES  LT_ENQUEUE_EXCEPTIONS
          USING   B-MATBF
                  B-BWKEY
                  B-BWTAR
                  B-SOBKZ
                  B-KDAUF
                  B-KDPOS
                  ' '
                  ' '
                  B-MENGE
                  B-SHKZG
                  B-EXBWR
                  B-KZBEW.
      ENDIF.
      IF B-KZBWS = O.
        CLEAR PREFETCH21-POSNR.
      ENDIF.
    ELSEIF B-SOBKZ = Q.
      PREFETCH22-MATNR = B-MATBF.
      PREFETCH22-BWKEY = B-BWKEY.
      PREFETCH22-BWTAR = B-BWTAR.
      PREFETCH22-SOBKZ = B-SOBKZ.                           "396879 ??
      PREFETCH22-PSPNR = B-PS_PSP_PNR.
      COLLECT PREFETCH22.
      IF TCURM-MBEQU = '3'.                                 "396879
        PERFORM FIRST_FILL_ENQ_EXC_TAB
          TABLES  LT_ENQUEUE_EXCEPTIONS
          USING   B-MATBF
                  B-BWKEY
                  B-BWTAR
                  B-SOBKZ
                  ' '
                  ' '
                  B-PS_PSP_PNR
                  ' '
                  B-MENGE
                  B-SHKZG
                  B-EXBWR
                  B-KZBEW.
      ENDIF.
    ELSEIF B-SOBKZ = O.                                     "kaz
      PREFETCH29-MATNR = B-MATBF.                           "kaz
      PREFETCH29-BWKEY = B-BWKEY.                           "kaz
      PREFETCH29-BWTAR = B-BWTAR.                           "kaz
      PREFETCH29-SOBKZ = B-SOBKZ.                           "kaz
      PREFETCH29-LIFNR = B-LIFNR.                           "kaz
      COLLECT PREFETCH29.                                   "kaz
      IF TCURM-MBEQU = '3'.                                 "396879
        PERFORM FIRST_FILL_ENQ_EXC_TAB
          TABLES  LT_ENQUEUE_EXCEPTIONS
          USING   B-MATBF
                  B-BWKEY
                  B-BWTAR
                  B-SOBKZ
                  ' '
                  ' '
                  ' '
                  B-LIFNR
                  B-MENGE
                  B-SHKZG
                  B-EXBWR
                  B-KZBEW.
      ENDIF.
    ENDIF.
  ENDIF.
  B-XEXEQ = X.

ENDFORM.                    "BUCHEN_MAT_PREFETCH_FUELLEN