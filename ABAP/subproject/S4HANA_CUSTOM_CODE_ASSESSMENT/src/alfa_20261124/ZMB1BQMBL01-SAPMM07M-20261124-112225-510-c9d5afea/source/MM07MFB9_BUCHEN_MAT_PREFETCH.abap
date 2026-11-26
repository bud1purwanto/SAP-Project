*eject
*---------------------------------------------------------------------*
*       FORM BUCHEN_MAT_PREFETCH                                      *
*---------------------------------------------------------------------*
*       Der Material Prefetch wird vorbereitet.                       *
*---------------------------------------------------------------------*
FORM BUCHEN_MAT_PREFETCH  TABLES L_ENQUEUE_EXCEPTIONS       "396879
                          STRUCTURE ENQUEUES_EXCEPTION_S    "396879
                          USING  BDM07M LIKE DM07M
                                 BVM07M LIKE VM07M
                                 BMSEG  LIKE MSEG.

  CHECK ( INVENTUR IS INITIAL ) OR ( NOT INV_SHARED IS INITIAL ).
  CHECK NOT TCURM-MBEQU IS INITIAL AND NOT BMSEG-BUSTW IS INITIAL
                                   AND NOT BMSEG-BUSTW = BUSTW_WE06.
  IF NOT BMSEG-WERTU IS INITIAL.
    PERFORM BUCHEN_MAT_PREFETCH_FUELLEN
                             TABLES L_ENQUEUE_EXCEPTIONS    "396879
                                        USING BMSEG-MATBF   "396879
                                              BVM07M-BWKEY
                                              BMSEG-BWTAR
                                              BMSEG-SOBKZ
                                              BMSEG-KZBWS
                                              BMSEG-XOBEW   "kaz
                                              BMSEG-LIFNR   "kaz
                                              BMSEG-PS_PSP_PNR
                                              BMSEG-KDAUF
                                              BMSEG-KDPOS
                                              BDM07M-XEXEQ
                                              BMSEG-MENGE   "396879
                                              BMSEG-SHKZG   "396879
                                              BMSEG-EXBWR   "396879
                                              BMSEG-KZBEW.  "396879
  ENDIF.
  IF NOT BDM07M-KZUML IS INITIAL AND NOT BDM07M-UMWER IS INITIAL.
    PERFORM BUCHEN_MAT_PREFETCH_FUELLEN
                               TABLES L_ENQUEUE_EXCEPTIONS  "396879
                                        USING BMSEG-UMMAB   "396879
                                              BDM07M-UMBWK
                                              BMSEG-UMBAR
                                              BMSEG-UMSOK
                                              BDM07M-UMKZBWS
                                              BMSEG-XOBEW   "kaz
                                              BMSEG-LIFNR   "kaz
                                              BMSEG-PS_PSP_PNR
                                              BMSEG-KDAUF
                                              BMSEG-KDPOS
                                              BDM07M-UMXEXEQ
                                              BMSEG-MENGE   "396879
                                              BMSEG-SHKZG   "396879
                                              BMSEG-EXBWR   "396879
                                              BMSEG-KZBEW.  "396879
  ENDIF.

ENDFORM.                    "BUCHEN_MAT_PREFETCH