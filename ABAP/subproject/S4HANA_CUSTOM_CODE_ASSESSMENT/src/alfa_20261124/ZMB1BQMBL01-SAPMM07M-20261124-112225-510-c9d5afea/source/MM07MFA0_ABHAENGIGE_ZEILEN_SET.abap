*---------------------------------------------------------------------*
*       FORM ABHAENGIGE_ZEILEN_SETZEN                                 *
*---------------------------------------------------------------------*
*       Bei Übernahme von Positionen aus dem Selektionsbild wird die  *
*       Belegzeile geändert, falls nicht alle Positionen übernommen   *
*       werden; bei Stücklisten (Leergut) müssen daher auch die       *
*       Zeilen-Verweise der abhängigen Positionen geändert werden     *
*---------------------------------------------------------------------*
FORM ABHAENGIGE_ZEILEN_SETZEN.
  DATA: H_FUSS LIKE FUSS.
  H_FUSS = FUSS.
  LOOP AT FUSS WHERE URZEI = H_FUSS-ZEILE.
    FUSS-URZEI = MSEG-ZEILE.
    MODIFY FUSS.
  ENDLOOP.
*##ngr-saanf
* bei Sammelartikel sind die Varianten vor Auswahl des Sammelartikels
* zunächst noch in VAR_FUSS geparkt; dort muß Umsetzung analog erfolgen
  LOOP AT VAR_FUSS WHERE URZEI = H_FUSS-ZEILE.
    VAR_FUSS-URZEI = MSEG-ZEILE.
    MODIFY VAR_FUSS.
  ENDLOOP.
  LOOP AT VAR_FUSS WHERE KOPF_ZEILE = H_FUSS-ZEILE.
    VAR_FUSS-KOPF_ZEILE = MSEG-ZEILE.
    MODIFY VAR_FUSS.
  ENDLOOP.
*##ngr-saend
  FUSS = H_FUSS.
ENDFORM.