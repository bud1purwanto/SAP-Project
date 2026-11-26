*&---------------------------------------------------------------------*
*&      Form  LGORT_CD_LAGERORTE_IN_FUSS
*&---------------------------------------------------------------------*
*       text: einpflegen der CD-Lagerorte in fuss (durch append)
*----------------------------------------------------------------------*
*      -->P_CD_MSEG
*----------------------------------------------------------------------*
FORM LGORT_CD_LAGERORTE_IN_FUSS TABLES P_CD_MSEG STRUCTURE MSEG.

  DATA: CD_ZEILE  LIKE FUSS-ZEILE.
  DATA: CD_FUSS   LIKE FUSS,
        H_CD_FUSS LIKE FUSS.

  CLEAR: P_CD_MSEG,
         CD_ZEILE.

* zwischenpuffern aktuelle Fuss-Zeile
  MOVE FUSS TO CD_FUSS.
* exclude additional item from later adjustments
  CLEAR: FUSS-URZEI,
         FUSS-ESTAK,
         FUSS-AUREL.                   "insert by kh note 164231

  LOOP AT P_CD_MSEG.
    IF SY-TABIX = 1.
      MOVE P_CD_MSEG TO MSEG.
      MOVE P_CD_MSEG-MENGE TO CD_FUSS-MENGE.
      MOVE P_CD_MSEG-MEINS TO CD_FUSS-MEINS.
      MOVE P_CD_MSEG-ERFMG TO CD_FUSS-ERFMG.
      MOVE P_CD_MSEG-ERFME TO CD_FUSS-ERFME.
      MOVE P_CD_MSEG-LGORT TO CD_FUSS-LGORT.
      IF NOT P_CD_MSEG-LGORT IS INITIAL.
* falls erste Position: nur dann merken, falls tatsaechlich eine
* Verteilung zuruekkam
        MOVE P_CD_MSEG TO CD_MSEG_EINGEMISCHT.
        IF xmigo IS INITIAL.
          APPEND CD_MSEG_EINGEMISCHT.
        ENDIF.
      ENDIF.
    ELSE.
      IF CD_ZEILE IS INITIAL.
* Falls mehr als ein zusätzlicher Lagerort zur gleichen Position
* eingefügt werden soll, braucht man nur einmal über FUSS zu loopen.
        MOVE FUSS TO H_CD_FUSS.
        PERFORM LGORT_CD_ERMITTELN_ZEILENNR CHANGING CD_ZEILE.
        MOVE H_CD_FUSS TO FUSS.
      ELSE.
        CD_ZEILE = CD_ZEILE + 1.
      ENDIF.
      MOVE CD_ZEILE        TO FUSS-ZEILE.
      IF NOT XMBWL IS INITIAL.                             "EP 2.0
*       MB_CREATE: generate line_id for the new items      "EP 2.0
        CLEAR fuss-line_id.                                "EP 2.0
        CALL METHOD cl_mmim_line_id_manager=>line_id_get   "EP 2.0
                   CHANGING                                "EP 2.0
                     c_line_id = fuss-line_id.             "EP 2.0
      ENDIF.                                               "EP 2.0
      MOVE CD_FUSS-line_id TO FUSS-PARENT_ID.              "EP 2.0
      MOVE P_CD_MSEG-MENGE TO FUSS-MENGE.
      MOVE P_CD_MSEG-MEINS TO FUSS-MEINS.
      MOVE P_CD_MSEG-ERFMG TO FUSS-ERFMG.
      MOVE P_CD_MSEG-ERFME TO FUSS-ERFME.
      MOVE P_CD_MSEG-LGORT TO FUSS-LGORT.
      APPEND FUSS.
* eingemischte Pos. merken; werden spaeter an CD zurueckgegeben
      MOVE P_CD_MSEG TO CD_MSEG_EINGEMISCHT.
      MOVE CD_ZEILE  TO CD_MSEG_EINGEMISCHT-ZEILE.
      IF xmigo IS INITIAL.
        APPEND CD_MSEG_EINGEMISCHT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  MOVE CD_FUSS TO FUSS.

ENDFORM.                               " LGORT_CD_LAGERORTE_IN_FUSS