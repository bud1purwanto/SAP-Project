*eject
*---------------------------------------------------------------------*
*       FORM BELEG_LESEN_POP_WEWA.                                    *
*---------------------------------------------------------------------*
*       Der Beleg wird gelesen. Für die gefundenen Positionen mit     *
*       Bestellung, wird die Bestellung gelesen und die Tabelle       *
*       Fuss aufgebaut.                                               *
*---------------------------------------------------------------------*
FORM BELEG_LESEN_POP_WEWA.

  CALL FUNCTION 'MB_READ_MATERIAL_HEADER'
       EXPORTING
            MBLNR = RM07M-MBLNR
            MJAHR = RM07M-MJAHR
            TRTYP = A
            VGART = VGART_WA
       IMPORTING
            KOPF  = XMKPF.
  CALL FUNCTION 'MB_READ_MATERIAL_POSITION'
       EXPORTING
            MBLNR  = XMKPF-MBLNR
            MJAHR  = XMKPF-MJAHR
            ZEILE  = RM07M-ZEILE
            ZEILB  = RM07M-ZEILB
            TRTYP  = A
       TABLES
            SEQTAB = XMSEG.
  LOOP AT XMSEG.
    IF XMSEG-EBELN IS INITIAL OR XMSEG-XAUTO = X
       OR XMSEG-KZZUG IS INITIAL.
      XMSEG-KZZUG = X.
      MODIFY XMSEG.
    ELSE.
      XMSEG-KZBEW = B.
      XMSEG-BWART = RM07M-BWARTWE.
      XMSEG-WERKS = XMSEG-UMWRK.
      XMSEG-LGORT = RM07M-LGORT.
      CLEAR XMSEG-UMMAT.
      CLEAR XMSEG-UMWRK.
      CLEAR XMSEG-UMLGO.
      CLEAR XMSEG-UMCHA.
      CLEAR XMSEG-UMZST.
      CLEAR XMSEG-UMZUS.
      CLEAR XMSEG-UMBAR.
      CLEAR XMSEG-UMSOK.
      CLEAR XMSEG-UMMAB.
      clear xmseg-lgnum.
      clear xmseg-lgtyp.
      clear xmseg-lgpla.
      MODIFY XMSEG.
    ENDIF.
  ENDLOOP.
  PERFORM BELEG_ERGAENZEN.
  CLEAR RM07M-MBLNR.
ENDFORM.