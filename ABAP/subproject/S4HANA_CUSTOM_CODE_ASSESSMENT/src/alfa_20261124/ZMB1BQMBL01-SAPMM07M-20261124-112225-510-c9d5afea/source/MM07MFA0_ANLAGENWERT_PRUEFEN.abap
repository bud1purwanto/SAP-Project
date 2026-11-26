*eject
*---------------------------------------------------------------------*
*       FORM ANLAGENWERT_PRUEFEN                                      *
*---------------------------------------------------------------------*
*       Die Anlagenwert wird geprüft und die ANEPs erzeugt.           *
*       Anhand der Tabelle X156W wird festgestellt, welche der        *
*       erzeugten Buchungszeilen, den Wert enthält, der auf die       *
*       Anlage zu buchen ist.                                         *
*---------------------------------------------------------------------*
FORM ANLAGENWERT_PRUEFEN.
  CHECK NOT MSEG-ANLN1 IS INITIAL AND NOT VM07M-KZWES = S AND
        NOT MSEG-BUSTW IS INITIAL AND TCURM-MBEQU IS INITIAL.
  CALL FUNCTION 'RWIN_CHECK'
       EXPORTING GJAHR     = MSEG-GJAHR
                 PROCESS   = 'BELEGPOS'
                 EVENT     = 'WERTPRFG'
       TABLES    TKOMP     = TKOMP
       EXCEPTIONS OTHERS = 0.
  DATA CNT02 LIKE T156W-CNT02. CLEAR CNT02.
  LOOP AT TKOMP.
    LOOP AT X156W WHERE BUSTW = MSEG-BUSTW.
      IF NOT X156W-XKAAO IS INITIAL.
        CNT02 = X156W-CNT02.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF NOT SY-SUBRC IS INITIAL OR CNT02 IS INITIAL.
      MESSAGE E058 WITH 'X156W' MSEG-BUSTW.
    ENDIF.
    MOVE-CORRESPONDING MKPF TO COBL.
    MOVE-CORRESPONDING DM07M TO COBL.
    MOVE-CORRESPONDING MSEG TO COBL.
    IF NOT MSEG-PARBU IS INITIAL.
      COBL-BUKRS = MSEG-PARBU.
    ENDIF.
    IF MSEG-MATNR IS INITIAL.
      COBL-MENGE = MSEG-ERFMG.
      COBL-MEINS = MSEG-ERFME.
    ENDIF.
    COBL-KOART = A.
    COBL-BZDAT = MKPF-BUDAT.
    LOOP AT XZCXCM WHERE CNT02 = CNT02
                   AND   CURTP = CURTP00.
      EXIT.
    ENDLOOP.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'XZCXCM' CNT02 CURTP00.
    ENDIF.
    COBL-WRBTR = XZCXCM-DMBTR.
    COBL-SHKZG = XZCXCM-SHKZG.
    LOOP AT XZCXCM WHERE CNT02 = CNT02
                   AND   CURTP = CURTP10.
      EXIT.
    ENDLOOP.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'XZCXCM' CNT02 CURTP10.
    ENDIF.
    COBL-DMBTR = XZCXCM-DMBTR.
    COBL-BUZEI = MSEG-ZEILE.
    CALL FUNCTION TKOMP-FUNCTION
         EXPORTING I_COBL = COBL
         IMPORTING E_COBL = COBL.
    DM07M-LNRAN = COBL-LNRAN.
  ENDLOOP.
ENDFORM.