*&---------------------------------------------------------------------*
*&      Form  LGORT_CD_ELIKZ_PFLEGEN
*&---------------------------------------------------------------------*
*       text: im Falle von Lagerortsplit kann es vorkommen, dass nur die
*             letzte MSEG-Position zur der Bestellposition das ELIKZ ge-
*             setzt hat; die anderen zugehörigen MSEG-Positionen muessen
*             das ELIKZ ebenfalls gesetzt haben;
*----------------------------------------------------------------------*
FORM LGORT_CD_ELIKZ_PFLEGEN TABLES MSEG_ORIG STRUCTURE MSEG
                                   CD_MSEG   STRUCTURE MSEG.

  TYPES: BEGIN OF CD_ELIKZ_STRUC,
           EBELN LIKE EKPO-EBELN,
           EBELP LIKE EKPO-EBELP,
         END OF CD_ELIKZ_STRUC.
  TYPES: CD_ELIKZ_TAB TYPE SORTED TABLE OF CD_ELIKZ_STRUC
                                        WITH UNIQUE KEY EBELN EBELP.
* cd_elikz beinhaltet alle endgelieferten Bestellpositionen
  DATA:  CD_ELIKZ TYPE CD_ELIKZ_TAB WITH HEADER LINE.
  DATA:  CD_MSEG_TABIX TYPE I.

  REFRESH: CD_MSEG, CD_ELIKZ.
  APPEND LINES OF MSEG_ORIG TO CD_MSEG.
* bei Verteilung wird ab dem 2. Lagerort ans Ende der MSEG angehängt;
* bei diesen Positionen wird dann das ELIKZ (ggfalls) gesetzt
* -> lesen vom Ende aus, um die Pos. mit ELIKZ zuerst zu bekommen
  SORT CD_MSEG BY ZEILE DESCENDING.
  LOOP AT CD_MSEG.
    CD_MSEG_TABIX = SY-TABIX.
    IF CD_MSEG-ELIKZ NE 'X'.
      READ TABLE CD_ELIKZ WITH TABLE KEY EBELN = CD_MSEG-EBELN
                                         EBELP = CD_MSEG-EBELP.
      IF SY-SUBRC IS INITIAL.
        CD_MSEG-ELIKZ = 'X'.
        MODIFY CD_MSEG INDEX CD_MSEG_TABIX.
      ENDIF.
    ELSE.
      CD_ELIKZ-EBELN = CD_MSEG-EBELN.
      CD_ELIKZ-EBELP = CD_MSEG-EBELP.
      INSERT TABLE CD_ELIKZ.
    ENDIF.
  ENDLOOP.
  SORT CD_MSEG BY ZEILE ASCENDING.
ENDFORM.