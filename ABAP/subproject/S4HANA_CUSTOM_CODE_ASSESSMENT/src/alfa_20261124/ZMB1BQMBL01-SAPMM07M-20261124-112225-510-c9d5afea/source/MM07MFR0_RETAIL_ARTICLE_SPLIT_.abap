*WTH BEGIN NOTE 180691
*----------------------------------------------------------------------*
*       Form  retail_article_split_check
*----------------------------------------------------------------------*
*   Message e116: ... Funktion Lagerort/Charge * hier nicht vorgesehen *
*   genau für die Fälle:                                               *
*     - für Position existiert eine Stückliste                         *
*     - Position ist ein Sammelartikel                                 *
*     - Position ist als Variante an einen Sammelartikel gebunden      *
*     - es dreht sich um strukturierte Artikel                         *
*----------------------------------------------------------------------*
FORM RETAIL_ARTICLE_SPLIT_CHECK.
   DATA: ANZ_COMP LIKE SY-TABIX.

   IF NOT MBEFU-MLGUT IS INITIAL.
*                           bei LG-Stückliste nicht erlaubt
      CLEAR ANZ_COMP.
      PERFORM LEERG_STUELI_LESEN USING MSEG-MATNR MSEG-ERFME.
      IF SY-SUBRC IS INITIAL.
        DESCRIBE TABLE SLCOMP LINES ANZ_COMP.
        IF ANZ_COMP > 0.
           MESSAGE E116.
        ENDIF.
      ENDIF.
   ELSEIF VM07M-ATTYP = ATTYP-SAM.
*                           bei Sammelartikel nicht erlaubt
      MESSAGE E116.
   ELSEIF VM07M-ATTYP = ATTYP-VAR
      AND NOT MSEG-URZEI IS INITIAL
      AND NOT MSEG-ZEILE = MSEG-URZEI.
*                           bei Variante zu Sammelartikel nicht erlaubt
      MESSAGE E116.
   ELSEIF ( VM07M-ATTYP = ATTYP-VKS  OR  VM07M-ATTYP = ATTYP-LOT  OR
            VM07M-ATTYP = ATTYP-DIS ).
*                           auch nicht bei strukturierten Artikeln
      MESSAGE E116.
   ENDIF.
ENDFORM.                    " RETAIL_ARTICLE_SPLIT_CHECK