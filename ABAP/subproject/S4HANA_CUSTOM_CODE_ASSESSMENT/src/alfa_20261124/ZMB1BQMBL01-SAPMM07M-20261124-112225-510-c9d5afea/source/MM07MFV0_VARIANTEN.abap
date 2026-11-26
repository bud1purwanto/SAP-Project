*eject
*##ngr-saanf
*---------------------------------------------------------------------*
*       FORM VARIANTEN                                                *
*---------------------------------------------------------------------*
*       Matrixverarbeitung der Varianten                              *
*---------------------------------------------------------------------*
FORM VARIANTEN USING SAMMAT ZEILE.

  field-symbols: <ls_var_fuss> like var_fuss.
  DATA: BEGIN OF VAR_VALUES OCCURS 0.
*         INCLUDE STRUCTURE MTRX_WSEL.                            " PPF
          INCLUDE STRUCTURE MTRX_WERTE." PPF
* DATA:   MATNR LIKE MSEG-MATNR.                                  " PPF
  DATA: END OF VAR_VALUES.
  DATA: SAMMAT_DATEN LIKE MTRX_KOPF.
  data: anz_comp type mb_line_depth.                     "note 602466
  DATA: PAUFRUF(2) TYPE C.             " PPF
  IF VAREAC IS INITIAL.                " PPF
    CLEAR PAUFRUF.                     " PPF
  ELSE.                                " PPF
    MOVE 'NV' TO PAUFRUF.              " PPF
    CLEAR VAREAC.                      " PPF
  ENDIF.                               " PPF

* Tabelle der Knotenwerte aufbauen
  REFRESH VAR_VALUES.
  IF VM07M-XSTOR = ZWEI OR AKTYP = A.
    VAR_VALUES-WTSTA = A.
  ENDIF.
* LOOP AT VAR_FUSS WHERE KOPF_ZEILE = ZEILE AND              " PPF 4.0C
*                        UPTYP = UPTYP_VAR.                  " PPF 4.0C
  LOOP AT VAR_FUSS WHERE KOPF_ZEILE = ZEILE.                 " PPF 4.0C

* Modus E: Menge
    CLEAR VAR_VALUES.
    VAR_VALUES-MATNR = VAR_FUSS-MATNR.
    VAR_VALUES-MODE  = E.
    VAR_VALUES-FWERT = VAR_FUSS-ERFMG / 1000.
    APPEND VAR_VALUES.
* Modus C: Charge
    CLEAR VAR_VALUES.
    VAR_VALUES-MATNR = VAR_FUSS-MATNR.
    VAR_VALUES-MODE  = C.
    VAR_VALUES-CWERT = VAR_FUSS-CHARG.
    IF VM07M-XCHPF IS INITIAL OR
       AKTYP NE H.
      VAR_VALUES-WTSTA = A.
    ENDIF.
    APPEND VAR_VALUES.
* Modus B: Bestandsart
* beim ersten Aufruf Übernahme Bestandsart aus Kopfzeile
    IF VAR_FUSS-INSMK IS INITIAL AND
       MATRIX IS INITIAL.
      VAR_FUSS-INSMK = MSEG-INSMK.
    ENDIF.
    CLEAR VAR_VALUES.
    VAR_VALUES-MATNR = VAR_FUSS-MATNR.
    VAR_VALUES-MODE  = B.
    VAR_VALUES-CWERT = VAR_FUSS-INSMK.
    IF NOT AKTYP = H.
      VAR_VALUES-WTSTA = A.
    ENDIF.
    APPEND VAR_VALUES.
* Modus O: Lagerort
    IF VAR_FUSS-LGORT IS INITIAL.
      VAR_FUSS-LGORT = MSEG-LGORT.
    ENDIF.
    CLEAR VAR_VALUES.
    VAR_VALUES-MATNR = VAR_FUSS-MATNR.
    VAR_VALUES-MODE  = O.
    VAR_VALUES-CWERT = VAR_FUSS-LGORT.
    IF NOT AKTYP = H.
      VAR_VALUES-WTSTA = A.
    ENDIF.
    APPEND VAR_VALUES.
* Modus N: EAN
* vorlaeufig deaktiviert, da für EAN auch EIngabe der Mengeneinheit
* notwendig
*   clear var_values.
*   var_values-matnr = var_fuss-matnr.
*   var_values-mode  = 'N'.
*   var_values-cwert = var_fuss-ean11_kon.
*   append var_values.
    IF MSEG-KZBEW = B.
* Modus M: Bestellmenge
      CLEAR VAR_VALUES.
      VAR_VALUES-MATNR = VAR_FUSS-MATNR.
      VAR_VALUES-MODE  = M.
      VAR_VALUES-FWERT = VAR_FUSS-BSMNG / 1000.
      VAR_VALUES-WTSTA = A.
      APPEND VAR_VALUES.
* Modus K: Endlieferungs-Kennzeichen
* vorläufig nicht, da die Matrixdarstellung Checkboxen in diesem Sinn
* nicht zuläßt
*     clear var_values.
*     var_values-matnr = var_fuss-matnr.
*     var_values-mode  = k.
*     var_values-cwert = var_fuss-elikz.
*     if vm07m-kzwes = s
*      or t158-kzbew = o or mseg-kzbew = o
*        or mseg-kzbew is initial or dm07m-bstyp = l
*        or mseg-kzbew = l
*        or mseg-ebeln = auto_best.
*       var_values-wtsta = a.
*     endif.
*     append var_values.
* Modus L: Lieferschein-Menge
      CLEAR VAR_VALUES.
      VAR_VALUES-MATNR = VAR_FUSS-MATNR.
      VAR_VALUES-MODE  = L.
      VAR_VALUES-CWERT = VAR_FUSS-LSMNG / 1000.
      APPEND VAR_VALUES.
* Modus H: Liefercharge
      CLEAR VAR_VALUES.
      VAR_VALUES-MATNR = VAR_FUSS-MATNR.
      VAR_VALUES-MODE  = H.
      VAR_VALUES-CWERT = VAR_FUSS-LICHA.
      IF VM07M-XCHPF IS INITIAL.
        VAR_VALUES-WTSTA = A.
      ENDIF.
      APPEND VAR_VALUES.
    ENDIF.
  ENDLOOP.

* PPF 4.0C: begin
* fertig, wenn keine Varianten vorhanden
*  IF NOT SY-SUBRC IS INITIAL AND NOT DM07M-UPVOR IS INITIAL.
*    EXIT.
*  ENDIF.
* PPF 4.0C: end

  MOVE-CORRESPONDING MSEG TO SAMMAT_DATEN.
  MOVE DM07M-MATKL  TO SAMMAT_DATEN-MATKL.                        " PPF
  MOVE VM07M-MTART  TO SAMMAT_DATEN-MTART.                        " PPF
  MOVE C_ATTYP_SAMA TO SAMMAT_DATEN-ATTYP.                        " PPF

  SAMMAT_DATEN-MEINS = MSEG-ERFME.

  CALL FUNCTION 'MB_PROCESS_VARIANTS'
       EXPORTING
            P_KOPFDATEN   = SAMMAT_DATEN
            P_APPLICATION = 'MB'
            P_AKTYP       = AKTYP
            P_AUFRUF      = PAUFRUF
       TABLES
            VAR_VALUES    = VAR_VALUES
       EXCEPTIONS
            OTHERS        = 1.

  IF NOT SY-SUBRC IS INITIAL.
    CLEAR MATRIX.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* wieder übernehmen der in der Matrix geänderten Werte
  CLEAR MSEG-ERFMG.
  SORT VAR_VALUES BY MATNR MODE.
  LOOP AT VAR_FUSS WHERE KOPF_ZEILE = ZEILE.
    LOOP AT VAR_VALUES WHERE MATNR = VAR_FUSS-MATNR.
      PERFORM VAR_WERT_AUS_MATRIX USING VAR_VALUES-MODE
                                        VAR_VALUES-FWERT
                                        VAR_VALUES-CWERT.
      DELETE VAR_VALUES.
    ENDLOOP.
    MODIFY VAR_FUSS.
  ENDLOOP.

* verarbeiten neuer Varianten (= restliche Zeilen in VAR_VALUES)
  DATA: LAST_VAR LIKE MSEG-MATNR.
  DATA: H_TABIX LIKE SY-TABIX.
* MOVE UPTYP_VAR TO DM07M-UPTYP.
  MOVE-CORRESPONDING MSEG  TO VAR_FUSS.
  MOVE-CORRESPONDING DM07M TO VAR_FUSS.
  MOVE-CORRESPONDING VM07M TO VAR_FUSS.
  LOOP AT VAR_VALUES.
    IF LAST_VAR NE VAR_VALUES-MATNR.
      MOVE-CORRESPONDING MSEG  TO VAR_FUSS.
      MOVE-CORRESPONDING DM07M TO VAR_FUSS.
      MOVE-CORRESPONDING VM07M TO VAR_FUSS.
      VAR_FUSS-MATNR = VAR_VALUES-MATNR.
      VAR_FUSS-STATU = VAR_VALUES-STATU.
      CLEAR VAR_FUSS-ERFMG.
      CLEAR VAR_FUSS-MENGE.
      CLEAR VAR_FUSS-BPMNG.
      CLEAR VAR_FUSS-BSTMG.
      CLEAR VAR_FUSS-MATBF.
      CLEAR VAR_FUSS-ZEILE.
      VAR_FUSS-KOPF_ZEILE = ZEILE.
      VAR_FUSS-KZ_NEU = X.
*     LINE_ID for new positions must be new.
      clear var_fuss-line_id.
      APPEND VAR_FUSS.
      H_TABIX = SY-TABIX.
    ENDIF.
    LAST_VAR = VAR_VALUES-MATNR.
    PERFORM VAR_WERT_AUS_MATRIX USING VAR_VALUES-MODE
                                      VAR_VALUES-FWERT
                                      VAR_VALUES-CWERT.
    MODIFY VAR_FUSS INDEX H_TABIX.
  ENDLOOP.
* neue Zeilen werden nur dann übernommen, wenn die Menge <> 0 ist
  DELETE VAR_FUSS WHERE KZ_NEU = X AND
                        ERFMG = 0.
* Set LINE_ID, PARENT_ID and DEPTH.
* This coding part is executed for GR for PO as well as for
* VGART = WA.
  loop at var_fuss assigning <ls_var_fuss>.
    call method cl_mmim_line_id_manager=>line_id_get
      changing c_line_id = <ls_var_fuss>-line_id.
    <ls_Var_fuss>-parent_id  = mseg-line_id.
    <ls_Var_fuss>-line_depth = mseg-line_depth + 1.
    if <ls_var_fuss>-kopf_zeile =  zeile and             "note 602466
       <ls_var_fuss>-erfmg      <> 0.                    "note 602466
      add 1 to anz_comp.                                 "note 602466
    endif.                                               "note 602466
  endloop.
  field-symbols <fs_yvm07m> like vm07m.                  "note 544663
  read table yvm07m assigning <fs_yvm07m>                "note 544663
    with key zeilv = mseg-zeile.                         "note 544663
  if sy-subrc = 0.                                       "note 544663
    <fs_yvm07m>-line_count = anz_comp.                   "note 544663
  endif.                                                 "note 544663
ENDFORM.