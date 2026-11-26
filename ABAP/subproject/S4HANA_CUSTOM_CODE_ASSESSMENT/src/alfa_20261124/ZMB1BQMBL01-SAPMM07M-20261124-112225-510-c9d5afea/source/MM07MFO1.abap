*----------------------------------------------------------------------*
*   INCLUDE MM07MFO1                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OBEWENTWICKLUNG_GENERIEREN
*&---------------------------------------------------------------------*
*       Die Obewentwicklung wird generiert
*----------------------------------------------------------------------*
FORM OBEWENTWICKLUNG_GENERIEREN.                                    "kaz

  CLEAR XROWA.

* Components in SC purchase order
  IF ( MKPF-VGART = 'WE' OR
       MKPF-VGART = 'WO' OR
       MKPF-VGART = 'WL' )                                       "983034
      AND XVM07M-PSTYP = '3'.                                   "1003375
* migrantory subcontracting
    IF ( MKPF-VGART = 'WE' OR MKPF-VGART = 'WL' )                "983034
        AND XMSEG-LIFNR <> XMSEG-EMLIF.                          "983034
      IF XMSEG-SHKZG = H.
        XROWA-MVCTG = 2.
      ELSE.
        XROWA-MVCTG = 1.
      ENDIF.
* consumption
    ELSE.
      IF XMSEG-SHKZG = H.                                       "1003375
        XROWA-MVCTG = 3.
      ELSE.
        XROWA-MVCTG = 4.
      ENDIF.
    ENDIF.

* physical inventory
  ELSEIF NOT INVENTUR IS INITIAL.
    IF XMSEG-SHKZG = H.                                         "1003375
      XROWA-MVCTG = 5.
    ELSE.
      XROWA-MVCTG = 6.
    ENDIF.
* all other movements
  ELSE.
    IF XMSEG-SHKZG = H.                                         "1003375
      XROWA-MVCTG = 2.
    ELSE.
      XROWA-MVCTG = 1.
    ENDIF.
  ENDIF.
  MOVE-CORRESPONDING ZDM07M TO XROWA.
  MOVE-CORRESPONDING XVM07M TO XROWA.
  MOVE-CORRESPONDING XMKPF TO XROWA.
  MOVE-CORRESPONDING XMSEG TO XROWA.
  XROWA-WRBTR = XVM07M-NETWR.
  XROWA-MWSKZ = XVM07M-MB_MWSKZ.

*  LOOP AT YFBUZ WHERE ZEILE = YMBUZ-ZEILE
  LOOP AT YFBUZ WHERE ZEILE = YMBUZ-ZEILZ
                AND   XUMBW = SPACE
                AND   KTOSL = 'BSX'.
    XROWA-WRBTR = YFBUZ-DMBTR.
    XROWA-SHKZG = YFBUZ-SHKZG.
    XROWA-HKONT = YFBUZ-HKONT.
    XROWA-GSBER = YFBUZ-GSBER.
    XROWA-PRCTR = YFBUZ-PRCTR.
  ENDLOOP.
  CHECK SY-SUBRC IS INITIAL.                 "Nur bewertungsrelevant
* clear: xrowa-status, xrowa-belnr, xrowa-gjahr, xrowa-buzei.
  APPEND XROWA.

ENDFORM.                    " OBEWENTWICKLUNG_GENERIEREN            "kaz