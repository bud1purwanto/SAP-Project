*---------------------------------------------------------------------*
*       FORM PPS_AUFTRAGSENTWICKLUNG                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  SEGINDEX                                                      *
*---------------------------------------------------------------------*
FORM PPS_AUFTRAGSENTWICKLUNG USING SEGINDEX.
* nicht für Sammelartikel-Zeilen
  CHECK NOT XVM07M-ATTYP = ATTYP-SAM.
  CLEAR XAUFBE.
* CHECK NOT YAUFBE_CR[] IS INITIAL.
* begin of note 500498
* order history function should only be called when item has been
* valuated. Therefore first check if entries for currencies exits in
* YAUFBE_CR.
  LOOP AT YAUFBE_CR WHERE BUZEI = ZDM07M-ZEILD.
    EXIT.
  ENDLOOP.
  IF SY-SUBRC <> 0.
    EXIT.                                          "item not valuated
  ENDIF.
* end of note 500498
ENHANCEMENT-POINT PPS_AUFTRAGSENTWICKLUNG_01 SPOTS ES_SAPMM07M.
  MOVE-CORRESPONDING XVM07M TO XAUFBE.
  MOVE-CORRESPONDING ZDM07M TO XAUFBE.
  MOVE-CORRESPONDING XMKPF TO XAUFBE.
  MOVE-CORRESPONDING XMSEG TO XAUFBE.
ENHANCEMENT-POINT PPS_AUFTRAGSENTWICKLUNG_02 SPOTS ES_SAPMM07M.
  XAUFBE-POSNR = XMSEG-AUFPS.
  XAUFBE-POPER = XVM07M-MONAT.
  XAUFBE-BDATJ = XMSEG-GJAHR.
  IF_SECON.
  IF NOT MBVAL IS INITIAL.
    XACCHD-CPUDT = MW_CPUDT.
    XACCHD-CPUTM = MW_CPUTM.
  ENDIF.
  END_SECON.
  XAUFBE-GJAHR = XMSEG-MJAHR.
  XAUFBE-BELNR = XMSEG-MBLNR.
  XAUFBE-BUZEI = XMSEG-ZEILE.
  IF NOT XOWER IS INITIAL.
    XAUFBE-XWOFF = X.
  ENDIF.
  DATA: KALN1 LIKE MBEW-KALNR.
  IF NOT ZDM07M-RMBEW IS INITIAL AND NOT XMSEG-WERTU IS INITIAL
   and not ( ( xmseg-sobkz = E or xmseg-sobkz = Q )         "note 359947
           and xmseg-kzbws is initial ).                    "note 359947
    IF NOT MBVAL IS INITIAL.
      CLEAR XAUFBE-KALN1.
    ENDIF.
    IF_SECON.
    CALL FUNCTION 'MB_READ_VALUE_ENQUEUE_TABLE'
         EXPORTING
              I_MATBF     =    XMSEG-MATBF
              I_BWKEY     =   XVM07M-BWKEY
              I_BWTAR     =    XMSEG-BWTAR
              I_SOBKZ     =    XMSEG-SOBKZ
              I_MAT_KDAUF =    XMSEG-MAT_KDAUF
              I_MAT_KDPOS =    XMSEG-MAT_KDPOS
              I_MAT_PSPNR =    XMSEG-MAT_PSPNR
              I_LIFNR     =    XMSEG-EMLIF                  "kaz
              I_KZBWS     =    XMSEG-KZBWS
              I_XOBEW     =    XMSEG-XOBEW                  "kaz
         IMPORTING
*         E_SMBEW     =
*         E_KALNR     =
              E_KALN1     = KALN1
         TABLES
              XMBEW       = XMBEW
              XEBEW       = XEBEW
              XQBEW       = XQBEW
              XOBEW       = XOBEW                           "kaz
              .
    XAUFBE-KALN1 = KALN1.
    END_SECON.
  ENDIF.
  CASE XMSEG-KZBEW.
    WHEN F.
      XAUFBE-VGABE = D.
    WHEN OTHERS.
      IF XVM07M-MLCCS_RELEVANT IS INITIAL.
        EXIT.
      ENDIF.
      IF XMSEG-KZBEW = B OR XMSEG-BUSTW = 'WA03'.
        XAUFBE-VGABE = I.
*       RHU 11.01.2006 Note 870876
*       For goods receipts for purchase order with account assignment
*       to the production order: set d/c indicator the other way around,
*       because for the order this is a consumption.
        IF XMSEG-KZBEW = B.
          IF XAUFBE-SHKZG = H.
            XAUFBE-SHKZG = S.
          ELSE.
            XAUFBE-SHKZG = H.
          ENDIF.
        ENDIF.
      ELSE.
        XAUFBE-VGABE = C.
      ENDIF.
  ENDCASE.
  APPEND XAUFBE.
** Die Entwicklung wird in allen Währungen aufgebaut.
  LOOP AT YAUFBE_CR WHERE BUZEI = ZDM07M-ZEILD.
    IF YAUFBE_CR-AUFNR NE XMSEG-AUFNR OR YAUFBE_CR-POSNR NE XMSEG-AUFPS.
      MESSAGE E001 WITH 'YAUFBE_CR' ZDM07M-ZEILD XMSEG-AUFNR XMSEG-AUFPS
      .
    ENDIF.
    XAUFBE_CR = YAUFBE_CR.
    XAUFBE_CR-VGABE = XAUFBE-VGABE.
    XAUFBE_CR-GJAHR = XAUFBE-GJAHR.
    XAUFBE_CR-BELNR = XAUFBE-BELNR.
    XAUFBE_CR-BUZEI = XAUFBE-BUZEI.
    APPEND XAUFBE_CR.
  ENDLOOP.
ENDFORM.                    "PPS_AUFTRAGSENTWICKLUNG