*eject
*----------------------------------------------------------------------*
*               FORM BELEGDATEN_STORNO                                 *
*----------------------------------------------------------------------*
*    Die Daten für den Beleg bei Transaktion MBST werden gesetzt.
*----------------------------------------------------------------------*
FORM BELEGDATEN_STORNO.
  CLEAR RC.
  IF T156N-XSTOR = EINS.
*   In case of return delivery take BLDAT from reference document
    IF xmbwl IS INITIAL.                                    "note 638935
      MKPF-BLDAT = XMKPF-BLDAT.                             "note 638935
    ENDIF.                                                  "note 638935
    IF MSEG-SHKZG = S.
      MSEG-SHKZG = H.
    ELSEIF MSEG-SHKZG = H.
      MSEG-SHKZG = S.
    ENDIF.
  ELSEIF T156N-XSTOR = ZWEI.
*   In case of cancellation take BLDAT from reference document    638935
    IF xmbwl IS INITIAL.                                    "note 638935
      MKPF-BLDAT = XMKPF-BLDAT.                             "note 638935
    ENDIF.                                                  "note 638935
* for cancellation with mbst of a service material document => error
* because transaction ml81 should be used instead  => note 323521

    IF     XMKPF-TCODE  CS 'ML81' OR  XMKPF-TCODE  CS 'ML85'
        or XMKPF-TCODE2 CS 'ML81' OR  XMKPF-TCODE2 CS 'ML85'.
      MESSAGE E027(ME) WITH Text-030.
    ENDIF.
    LOOP AT YMSEG WHERE SMBLN = MSEG-MBLNR
                  AND   SJAHR = MSEG-MJAHR
                  AND   SMBLP = MSEG-ZEILE.
      STORNO = STORNO - 1.
    ENDLOOP.
    IF NOT SY-SUBRC IS INITIAL.
      LOOP AT FUSS WHERE SMBLN = MSEG-MBLNR
                   AND   SJAHR = MSEG-MJAHR
                   AND   SMBLP = MSEG-ZEILE.
        STORNO = STORNO - 1.
      ENDLOOP.
    ENDIF.
    IF SY-SUBRC IS INITIAL.
      RC = 4.
      EXIT.
    ENDIF.
    SELECT * FROM M_MBMPS WHERE SMBLN = MSEG-MBLNR
                          AND   SJAHR = MSEG-MJAHR
                          AND   SMBLP = MSEG-ZEILE.
      STORNO = STORNO - 1.
    ENDSELECT.
    IF SY-SUBRC IS INITIAL.
      INDEX_A = INDEX_A + 1.
      RC = 4.
      EXIT.
    ENDIF.
*   valuation logic for cancellation:
*     - GR (KZBEW = F/ B) is valuated according to the history
*     - cancellation for consignation/ pipeline is valuated according to
*       RKWA in a separate logic (PIPELINE_PREIS_ERMITTELN, SAPFM07M)
*     - for an external value (EXBWR) in the document to be cancelled,
*       this value is also used for the cancellation
*     - others: use MSEG-DMBTR as external value
    IF MSEG-EXBWR IS INITIAL AND NOT MSEG-KZBEW = F
                             AND NOT MSEG-KZBEW = B
                             AND NOT MSEG-SOBKZ = K             " 648004
                             AND NOT MSEG-SOBKZ = P.            " 648004
      DM07M-EXWRT = MSEG-DMBTR.
*     Reversal document will be valuated by the value of    "note 569986
*     the original document.                                "note 569986
* Gelöscht                                                      "N1090014
*      IF mseg-kzbew IS INITIAL AND NOT t001k-mlbwa IS INITIAL.   "756353
*        MSEG-EXBWR  = MSEG-DMBTR.                           "note 569986
*      ENDIF.                                                "note 569986
    ELSE.
      DM07M-EXWRT = MSEG-EXBWR.
    ENDIF.
*    The following lines had to be deleted because it was not possible
*    to cancel 541 with WERKS <> UMWRK.
**   Folgender CLEAR ist notwendig, da ansonsten MBST für 541-er
**   Buchungen auf einer Seite immer nur eine Zeile anzeigt.
*    IF MSEG-UMSOK = O AND MSEG-KZBEW IS INITIAL AND
*    IM_PROCESS IS INITIAL AND MSEG-SOBKZ IS INITIAL.
*      CLEAR: MSEG-UMMAT,
*             MSEG-UMWRK.
*    ENDIF.
    IF MSEG-SHKZG = S.
      MSEG-SHKZG = H.
    ELSEIF MSEG-SHKZG = H.
      MSEG-SHKZG = S.
    ENDIF.
  ENDIF.
  IF T156N-XSTOR = DREI.
    CLEAR MSEG-KZBEW.
  ELSE.
    MSEG-SMBLN = MSEG-MBLNR.
    MSEG-SJAHR = MSEG-MJAHR.
    MSEG-SMBLP = MSEG-ZEILE.
    DM07M-KONTO = MSEG-SAKTO.
ENHANCEMENT-POINT MM07MFB1_BELEGDATEN_STORNO_01 SPOTS ES_MM07MFB1_BELEGDATEN_STORNO INCLUDE BOUND.
  ENDIF.
ENDFORM.