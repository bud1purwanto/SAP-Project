*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CHECK_TPS_CHANGE                                  *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM CHECK_TPS_CHANGE                                         *
*---------------------------------------------------------------------*
*       Überprüfung of Beleg im Sinne der Transportplanung geändert   *
*---------------------------------------------------------------------*
FORM CHECK_TPS_CHANGE.

  DATA: YLIPS_SIZE TYPE I, YVBPA_SIZE TYPE I.
  DATA: EXITFLAG.

  CLEAR EXITFLAG.

* check for call by transport
  SY-SUBRC = 0.
  IF AUFRUFER = CHART.
    SY-SUBRC = 4. EXIT.
  ENDIF.

* check changes in packing
  SY-SUBRC = 4.
  IF PACKDATEN_VERBUCHEN = CHARX.
    SY-SUBRC = 0. EXIT.
  ENDIF.

* check new items in LIPS
  SY-SUBRC = 4.
  LOOP AT XLIPS WHERE UPDKZ = UPDKZ_NEW.
    IF XLIPS-POSAR = SPACE AND
       ( XLIPS-BWART <> SPACE OR LIKP-VBTYP = VBTYP_LIAV ).
      EXITFLAG = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF EXITFLAG <> SPACE.
    SY-SUBRC = 0.
    EXIT.
  ENDIF.

* check deletion in LIPS
  SY-SUBRC = 4.
  LOOP AT YLIPS WHERE UPDKZ = UPDKZ_DELETE.
    IF YLIPS-POSAR = SPACE AND
       ( YLIPS-BWART <> SPACE OR LIKP-VBTYP = VBTYP_LIAV ).
      EXITFLAG = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF EXITFLAG <> SPACE.
    SY-SUBRC = 0.
    EXIT.
  ENDIF.

* check changes in LIPS
  SY-SUBRC = 4.
  LOOP AT XLIPS WHERE UPDKZ = UPDKZ_UPDATE.
    IF XLIPS-POSAR = SPACE AND
       ( XLIPS-BWART <> SPACE OR LIKP-VBTYP = VBTYP_LIAV ).
      READ TABLE YLIPS WITH KEY POSNR = XLIPS-POSNR.
      CHECK SY-SUBRC = 0.
      SY-SUBRC = 4.
      IF XLIPS-MATNR <> YLIPS-MATNR OR
         XLIPS-WERKS <> YLIPS-WERKS OR
         XLIPS-LFIMG <> YLIPS-LFIMG OR "#&rm
         XLIPS-VRKME <> YLIPS-VRKME OR
         XLIPS-NTGEW <> YLIPS-NTGEW OR
         XLIPS-BRGEW <> YLIPS-BRGEW OR
         XLIPS-GEWEI <> YLIPS-GEWEI OR
         XLIPS-VOLUM <> YLIPS-VOLUM OR
         XLIPS-VOLEH <> YLIPS-VOLEH OR
         XLIPS-UEPOS <> YLIPS-UEPOS OR
         XLIPS-LADGR <> YLIPS-LADGR OR
         XLIPS-TRAGR <> YLIPS-TRAGR OR
         XLIPS-BWART <> YLIPS-BWART OR
         XLIPS-MTART <> YLIPS-MTART OR
         XLIPS-POSAR <> YLIPS-POSAR OR
         XLIPS-KCMENG <> YLIPS-KCMENG OR
         XLIPS-KCBRGEW <> YLIPS-KCBRGEW OR
         XLIPS-KCNTGEW <> YLIPS-KCNTGEW OR
         XLIPS-KCVOLUM <> YLIPS-KCVOLUM OR
         XLIPS-KCGEWEI <> YLIPS-KCGEWEI OR
         XLIPS-KCVOLEH <> YLIPS-KCVOLEH OR
         XLIPS-UECHA <> YLIPS-UECHA OR
         XLIPS-PROSA <> YLIPS-PROSA.
        EXITFLAG = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF EXITFLAG <> SPACE.
    SY-SUBRC = 0.
    EXIT.
  ENDIF.

* check changes in VBPA
  SY-SUBRC = 4.
  LOOP AT XVBPA WHERE UPDKZ = UPDKZ_NEW OR UPDKZ = UPDKZ_UPDATE.
    EXITFLAG = 'X'.
    EXIT.
  ENDLOOP.
  IF EXITFLAG <> SPACE.
    SY-SUBRC = 0.
    EXIT.
  ENDIF.

* check deletions in VBPA
  DESCRIBE TABLE YVBPA LINES YVBPA_SIZE.
  IF YVBPA_SIZE > 0.
    SY-SUBRC = 0. EXIT.
  ENDIF.

* check changes in LIKP
  SY-SUBRC = 4.
  IF YLIKP-WADAT <> LIKP-WADAT OR
     YLIKP-LDDAT <> LIKP-LDDAT OR
     YLIKP-TDDAT <> LIKP-TDDAT OR
     YLIKP-LFDAT <> LIKP-LFDAT OR
     YLIKP-KODAT <> LIKP-KODAT OR
     YLIKP-ABLAD <> LIKP-ABLAD OR
     YLIKP-INCO1 <> LIKP-INCO1 OR
     YLIKP-INCO2 <> LIKP-INCO2 OR
     YLIKP-ROUTE <> LIKP-ROUTE OR
     YLIKP-KNFAK <> LIKP-KNFAK OR
     YLIKP-LPRIO <> LIKP-LPRIO OR
     YLIKP-VSBED <> LIKP-VSBED OR
     YLIKP-KUNNR <> LIKP-KUNNR OR
     YLIKP-KUNAG <> LIKP-KUNAG OR
     YLIKP-BTGEW <> LIKP-BTGEW OR
     YLIKP-NTGEW <> LIKP-NTGEW OR
     YLIKP-GEWEI <> LIKP-GEWEI OR
     YLIKP-VOLUM <> LIKP-VOLUM OR
     YLIKP-VOLEH <> LIKP-VOLEH OR
     YLIKP-ANZPK <> LIKP-ANZPK OR
     YLIKP-BEROT <> LIKP-BEROT OR
     YLIKP-LFUHR <> LIKP-LFUHR OR
     YLIKP-LSTEL <> LIKP-LSTEL OR
     YLIKP-LIFNR <> LIKP-LIFNR OR
     YLIKP-WERKS <> LIKP-WERKS.
    SY-SUBRC = 0. EXIT.
  ENDIF.
ENDFORM.


































