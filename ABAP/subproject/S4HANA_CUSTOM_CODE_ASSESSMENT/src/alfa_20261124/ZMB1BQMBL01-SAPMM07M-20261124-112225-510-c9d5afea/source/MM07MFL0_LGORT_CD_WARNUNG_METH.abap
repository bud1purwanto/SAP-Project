*&---------------------------------------------------------------------*
*&      Form  LGORT_CD_WARNUNG_METH_IGNOR
*&---------------------------------------------------------------------*
*       text: Obwohl die Pos. verteilungsrelevant waere, wird das Ver-
*             fahren nicht angewandt, da Lagerort * eingegeben wurde.
*             Ausgabe Warnmeldung und Aufruf CD, damit die Info weiter-
*             gereicht wird;
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LGORT_CD_WARNUNG_METH_IGNOR.

  DATA: BEGIN OF CD_MSEG OCCURS 0.     " Schnittstelle zu cross-docking;
          INCLUDE STRUCTURE MSEG.      " hier kommen die Lgorte hinein
  DATA: END OF CD_MSEG.

  DATA: rc LIKE sy-subrc.                                  " P9BK157624

  MESSAGE W419(W#) WITH MSEG-MATNR.
* Uebergabeparameter 'X': zeigt an, dass verteil-irrelevant ist
  PERFORM LGORT_CD_GET_DISTRIBUTION TABLES CD_MSEG
*                               USING 'X'.                 " P9BK157624
                               USING 'X'                   " P9BK157624
                               CHANGING rc.                " P9BK157624
*  IF sy-subrc NE 0.                                       " P9BK157624
  IF rc NE 0.                                              " P9BK157624
    sy-subrc = 0.
    rc = 0.                                                " P9BK157624
  ENDIF.

ENDFORM.                               " LGORT_CD_WARNUNG_METH_IGNOR