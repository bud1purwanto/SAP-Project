*&---------------------------------------------------------------------*
*&      Form  LGORT_CD_EINMISCHEN_LAGERORTE
*&---------------------------------------------------------------------*
*       text: ueber CD-Baustein wird die Lagertortverteilung zu dem
*             aktuellen Material ermittelt und in fuss gefuellt
*----------------------------------------------------------------------*
FORM LGORT_CD_EINMISCHEN_LAGERORTE.

  DATA: BEGIN OF CD_MSEG OCCURS 5.     " Schnittstelle zu cross-docking;
          INCLUDE STRUCTURE MSEG.      " hier kommen die Lgorte hinein
  DATA: END OF CD_MSEG.

  DATA: RC like sy-subrc.                                  " P9BK157624

  PERFORM lgort_cd_get_distribution TABLES cd_mseg
*                               USING space                " P9BK157624
                               USING space                 " P9BK157624
                               CHANGING rc.                " P9BK157624
*** begin P9BK157624
*  IF sy-subrc = 2.
  IF rc = 2.
    MESSAGE w418(w#) WITH mseg-matnr.
*  ELSEIF sy-subrc = 1  OR  sy-subrc = 0.
  ELSEIF rc = 1  OR  rc = 0.
* entweder keine Verteilung notwendig -> es beibt beim aktuellen Satz in
* fuss; oder aber komplette Verteilung in fuss eintragen
*    IF sy-subrc = 1.
    IF rc = 1.
      sy-subrc = 0.
      rc = 0.
*** end P9BK157624
    ELSE.
* der zweite CD-FB (bei buchen_ausfuehren) braucht die Info, dass CD-
* relevante Positionen im Spiel sind
      CD_VORGANG_AKTIV = 'X'.
    ENDIF.
    PERFORM LGORT_CD_LAGERORTE_IN_FUSS TABLES CD_MSEG.
  ENDIF.

ENDFORM.                               " LGORT_CD_EINMISCHEN_LAGERORTE