*eject
*---------------------------------------------------------------------*
*       FORM UMLAGERUNG_STRING_PRUEFEN                               *
*---------------------------------------------------------------------*
*       Der Mengenstring für die Umalgerung von Chargen wird geprüft
*---------------------------------------------------------------------*
FORM umlagerung_string_pruefen.
* This form has been replaced by function mb_transfer_string_check.
* see note331195


*  CHECK NOT dm07m-umxch IS INITIAL.
*  DATA umzst LIKE mseg-umzst.          "Ziel-Zustand der Umlagercharge
** UMZST aus aktuellem und zukünftigen Umlagerungszustand ermitteln
*  IF dm07m-qm_umzst EQ null.
*    umzst = x.
*  ELSEIF dm07m-qm_umzst EQ eins.
*    umzst = space.
*  ELSEIF dm07m-qm_zustd IS INITIAL.
*    umzst = mseg-umzst.
*  ELSE.
*    IF kzdch EQ charge_auf_werk.
*      IF mseg-matnr EQ mseg-ummat AND mseg-werks EQ mseg-werks
*                                  AND mseg-charg EQ mseg-umcha.
*        IF dm07m-qm_zustd EQ null.
*          umzst = x.
*        ELSEIF dm07m-qm_zustd EQ eins.
*          umzst = space.
*        ELSE.
*          umzst = mseg-umzst.
*        ENDIF.
*      ELSE.
*        umzst = mseg-umzst.
*      ENDIF.
*    ELSE.
*      IF mseg-matnr EQ mseg-ummat AND mseg-charg EQ mseg-umcha.
*        IF dm07m-qm_zustd EQ null.
*          umzst = x.
*        ELSEIF dm07m-qm_zustd EQ eins.
*          umzst = space.
*        ELSE.
*          umzst = mseg-umzst.
*        ENDIF.
*      ELSE.
*        umzst = mseg-umzst.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*  IF NOT umzst IS INITIAL.
*    READ TABLE x156m INDEX 2.
*    IF sy-subrc IS INITIAL.
*      IF x156m-lbbsa = '01'.
*        CLEAR vw.
**##ngr-saanf
*        IF NOT mbefu-attyp = attyp-sam.
*          SELECT * FROM t156m WHERE bustm = s156s-bustm
*                               AND  zustd = NULL.
*            IF vw IS INITIAL.
*              vw = x.
*            ELSE.
*              vw = y.
*              MOVE t156m TO x156m.
*              MODIFY x156m INDEX 2.
*              PERFORM segmentdaten_t156m_umlagerung(sapfm07m).
*              EXIT.
*            ENDIF.
*          ENDSELECT.
*        ELSE.
*          CLEAR t156m.
*        ENDIF.
**##ngr-saend
*        IF NOT vw = y.
*          MESSAGE e001 WITH 'T156M' s156s-bustm null.
*        ENDIF.
*      ENDIF.
*    ELSE.
*      MESSAGE e001 WITH 'X156M' s156s-bustm null zwei.
*    ENDIF.
*  ENDIF.

ENDFORM.