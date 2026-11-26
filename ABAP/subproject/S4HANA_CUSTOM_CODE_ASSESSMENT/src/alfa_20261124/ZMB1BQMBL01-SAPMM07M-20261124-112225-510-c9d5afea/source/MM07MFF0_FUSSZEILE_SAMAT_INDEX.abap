*&---------------------------------------------------------------------*
*&      Form  FUSSZEILE_SAMAT_INDEX
*&---------------------------------------------------------------------*
*       text  ermitteln des Index a_zeile zu einem Sammelartikel, der
*             bereits in ymseg aber auch noch in fuss steht (hw 0120165)
*----------------------------------------------------------------------*
FORM fusszeile_samat_index.

  READ TABLE fuss WITH KEY matnr = mseg-matnr
                           zeile = mseg-zeile.
  IF sy-subrc = 0.
* nur wenn es tatsaechlich Sammelartikel ist -> a_zeile umschiessen
    IF fuss-attyp = attyp-sam.
      a_zeile = sy-tabix.
    ENDIF.
  ENDIF.

ENDFORM.                               " FUSSZEILE_SAMAT_INDEX