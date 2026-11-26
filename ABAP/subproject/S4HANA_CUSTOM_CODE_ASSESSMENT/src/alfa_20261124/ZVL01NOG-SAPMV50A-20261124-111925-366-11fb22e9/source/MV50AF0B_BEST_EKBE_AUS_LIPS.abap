*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BEST_EKBE_AUS_LIPS                                *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM BEST_EKBE_AUS_LIPS                                       *
*---------------------------------------------------------------------*
*       Für eine Lieferposition wird die Bestellung via               *
*       EKBE fortgeschrieben                                          *
*---------------------------------------------------------------------*
*  <->  XEKBE       Tab. mit Bestellentw.sätzen                       *
*  -->  beal_lips  neue/alte Lieferposition                           *
*---------------------------------------------------------------------*
FORM BEST_EKBE_AUS_LIPS TABLES XEKBE     STRUCTURE EKBE
                        USING  BEAL_LIPS STRUCTURE LIPSVB.

* Keine Firtschreibung falls Bestellung in anderem System liegt
  CHECK BEAL_LIPS-VGSYS IS INITIAL.                             "AIP

* Init Bestellent.satz
  CLEAR XEKBE.

* Welches Update-Kz.?
  CASE BEAL_LIPS-UPDKZ.
    WHEN UPDKZ_NEW.
*     Position wird hinzugefügt
      XEKBE-MANDT = BEAL_LIPS-MANDT.
      XEKBE-EBELN = BEAL_LIPS-VGBEL.
      XEKBE-EBELP = BEAL_LIPS-VGPOS.
      XEKBE-VGABE = '8'.
      XEKBE-BELNR = BEAL_LIPS-VBELN.
      XEKBE-GJAHR = BEAL_LIPS-POSNR(2).
      XEKBE-BUZEI = BEAL_LIPS-POSNR+2(4).
      XEKBE-BEWTP = 'L'.
      XEKBE-BUDAT = BEAL_LIPS-ERDAT.
      XEKBE-MENGE = BEAL_LIPS-LFIMG.
      if BEAL_LIPS-kzfme na 'AB'.
      IF ( BEAL_LIPS-UMREZ NE BEAL_LIPS-UMVKZ OR
           BEAL_LIPS-UMREN NE BEAL_LIPS-UMVKN ) AND
           BEAL_LIPS-UMREN NE 0.
        XEKBE-MENGE = BEAL_LIPS-LGMNG * BEAL_LIPS-UMREN
                    / BEAL_LIPS-UMREZ.
      ENDIF.
     endif.

ENHANCEMENT-POINT BEST_EKBE_AUS_LIPS_01 SPOTS ES_SAPMV50A.

    WHEN UPDKZ_UPDATE.
*     Position wurde verändert
      XEKBE-MANDT = BEAL_LIPS-MANDT.
      XEKBE-EBELN = BEAL_LIPS-VGBEL.
      XEKBE-EBELP = BEAL_LIPS-VGPOS.
      XEKBE-VGABE = '8'.
      XEKBE-BELNR = BEAL_LIPS-VBELN.
      XEKBE-GJAHR = BEAL_LIPS-POSNR(2).
      XEKBE-BUZEI = BEAL_LIPS-POSNR+2(4).
      XEKBE-BEWTP = 'L'.
      XEKBE-BUDAT = BEAL_LIPS-ERDAT.
      XEKBE-MENGE = BEAL_LIPS-LFIMG.
      if BEAL_LIPS-kzfme na 'AB'.
      IF ( BEAL_LIPS-UMREZ NE BEAL_LIPS-UMVKZ OR
           BEAL_LIPS-UMREN NE BEAL_LIPS-UMVKN ) AND
           BEAL_LIPS-UMREN NE 0.
        XEKBE-MENGE = BEAL_LIPS-LGMNG * BEAL_LIPS-UMREN
                    / BEAL_LIPS-UMREZ.
      ENDIF.
     endif.

ENHANCEMENT-POINT BEST_EKBE_AUS_LIPS_02 SPOTS ES_SAPMV50A.

    WHEN UPDKZ_DELETE.
*     Position wurde gelöscht
      XEKBE-MANDT = BEAL_LIPS-MANDT.
      XEKBE-EBELN = BEAL_LIPS-VGBEL.
      XEKBE-EBELP = BEAL_LIPS-VGPOS.
      XEKBE-VGABE = '8'.
      XEKBE-BELNR = BEAL_LIPS-VBELN.
      XEKBE-GJAHR = BEAL_LIPS-POSNR(2).
      XEKBE-BUZEI = BEAL_LIPS-POSNR+2(4).
      XEKBE-BEWTP = 'L'.
      XEKBE-BUDAT = BEAL_LIPS-ERDAT.
      XEKBE-MENGE = BEAL_LIPS-LFIMG.
      if BEAL_LIPS-kzfme na 'AB'.
      IF ( BEAL_LIPS-UMREZ NE BEAL_LIPS-UMVKZ OR
           BEAL_LIPS-UMREN NE BEAL_LIPS-UMVKN ) AND
           BEAL_LIPS-UMREN NE 0.
        XEKBE-MENGE = BEAL_LIPS-LGMNG * BEAL_LIPS-UMREN
                    / BEAL_LIPS-UMREZ.
      ENDIF.
     endif.

ENHANCEMENT-POINT BEST_EKBE_AUS_LIPS_03 SPOTS ES_SAPMV50A.

  ENDCASE.                             "Welches Update-Kz.?

* update-kennzeichen wird in ELIKZ übergeben
  XEKBE-ELIKZ = BEAL_LIPS-UPDKZ.

* Anhängen an Tab.
  APPEND XEKBE.
ENDFORM.                               "best_ekbe_aus_lips