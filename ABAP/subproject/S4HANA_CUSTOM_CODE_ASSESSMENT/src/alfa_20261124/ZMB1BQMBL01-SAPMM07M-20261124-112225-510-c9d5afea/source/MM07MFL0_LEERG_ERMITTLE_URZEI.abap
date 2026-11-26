*&---------------------------------------------------------------------*
*&      Form  LEERG_ERMITTLE_URZEI
*&---------------------------------------------------------------------*
*       text: in fuss: look for corresponding full product to an empty;
*             this is used in order to determine urzei of the empty
*----------------------------------------------------------------------*
FORM LEERG_ERMITTLE_URZEI USING P_EBELN P_UEBPO P_LFBNR
                       CHANGING P_URZEI.
  DATA: KZ_URZEI_SET TYPE C.
  CLEAR KZ_URZEI_SET.
* first attempt: check sl_kopf;
* but: if there are several (partial) goods receipts to a po and several
* reversals to the po I have several full product positions
* in fuss with the same ebeln and ebelp; just the last one is stored
* in sl_kopf; this one might be wrong -> extended check with lfbnr
  IF DM07M-UPTYP = UPTYP_VAR.
    IF SAMMAT-EBELN = P_EBELN AND SAMMAT-EBELP = P_UEBPO
       AND SAMMAT-LFBNR = P_LFBNR.
      P_URZEI = SAMMAT-ZEILE.
      KZ_URZEI_SET = X.
    ENDIF.
  ELSE.
    IF SL_KOPF-EBELN = P_EBELN AND SL_KOPF-EBELP = P_UEBPO
       AND SL_KOPF-LFBNR = P_LFBNR.
      P_URZEI = SL_KOPF-ZEILE.
      KZ_URZEI_SET = X.
    ENDIF.
  ENDIF.
* get the right full product from table fuss
  IF KZ_URZEI_SET IS INITIAL.
    DATA: VG_FUSS LIKE FUSS.
    READ TABLE FUSS INTO VG_FUSS WITH KEY EBELN = P_EBELN
                                          EBELP = P_UEBPO
                                          LFBNR = P_LFBNR.
    IF SY-SUBRC IS INITIAL.
      P_URZEI = VG_FUSS-ZEILE.
    ELSE.
* if fuss is not filled -> check yfuss
      READ TABLE YFUSS INTO VG_FUSS WITH KEY EBELN = P_EBELN
                                             EBELP = P_UEBPO
                                             LFBNR = P_LFBNR.
      IF SY-SUBRC IS INITIAL.
        P_URZEI = VG_FUSS-ZEILE.
      ELSE.
* corresponding full product could not be found
        IF DM07M-UPTYP NE UPTYP_VAR.
           MESSAGE E001 WITH 'FUSS' P_EBELN P_UEBPO P_LFBNR.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               " LEERG_ERMITTLE_URZEI