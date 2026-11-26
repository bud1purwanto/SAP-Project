*eject
*----------------------------------------------------------------------*
*               FORM BEST_SUCHEN_PLAUSIS                               *
*----------------------------------------------------------------------*
*    Plausiprüfungen für die verschiedenen Selektionsmöglichkeiten     *
*    in MB0A                                                           *
*----------------------------------------------------------------------*
FORM best_suchen_plausis.
* wurde überhaupt ein Kriterium eingegeben ?
ENHANCEMENT-SECTION     BEST_SUCHEN_PLAUSIS_01 SPOTS ES_SAPMM07M.
  IF am07m-lifnr IS INITIAL AND am07m-matnv IS INITIAL AND
     am07m-reswk IS INITIAL AND xaktiv IS INITIAL
     AND rm07m-vlief IS INITIAL AND rm07m-eindt IS INITIAL AND
     rm07m-ean11 IS INITIAL AND rm07m-idnlf IS INITIAL AND
     rm07m-traid IS INITIAL AND rm07m-traty IS INITIAL AND
     rm07m-gwelf IS INITIAL AND rm07m-gwels IS INITIAL AND
     rm07m-vbeln IS INITIAL AND rm07m-xvers IS INITIAL AND
     rm07m-tknum IS INITIAL AND rm07m-pabnum IS INITIAL.
    SET CURSOR FIELD 'AM07M-LIFNR'.
    MESSAGE e017.
  ENDIF.
END-ENHANCEMENT-SECTION.
* Datum oder Lieferantenmaterial alleine genügt nicht
  IF ( NOT rm07m-eindt IS INITIAL OR NOT rm07m-idnlf IS INITIAL
     OR NOT rm07m-eindb IS INITIAL )
     AND am07m-reswk IS INITIAL                                  "357116
     AND am07m-lifnr IS INITIAL AND am07m-matnv IS INITIAL
     AND rm07m-ean11 IS INITIAL AND rm07m-vlief IS INITIAL
     AND rm07m-traid IS INITIAL AND rm07m-vbeln IS INITIAL
     AND rm07m-gwelf IS INITIAL AND rm07m-gwels IS INITIAL
     AND rm07m-tknum IS INITIAL AND rm07m-pabnum IS INITIAL.
    SET CURSOR FIELD 'AM07M-LIFNR'.
    MESSAGE e148.
  ENDIF.
  IF ( NOT rm07m-idnlf IS INITIAL AND am07m-lifnr IS INITIAL
       AND am07m-matnv IS INITIAL AND rm07m-ean11 IS INITIAL )
  OR ( NOT rm07m-traty IS INITIAL AND rm07m-traid IS INITIAL ).
    SET CURSOR FIELD 'AM07M-LIFNR'.
    MESSAGE e148.
  ENDIF.
  IF NOT rm07m-xvers IS INITIAL.
* falls über Vorgängerbeleg (ohne Versandelement), prüfen, ob eindeutig
* Selektionskriterien angegeben (entweder Lieferung oder Avis oder Grob-
* WE
    IF NOT rm07m-vlief IS INITIAL OR
       NOT rm07m-traid IS INITIAL OR
       NOT rm07m-gwelf IS INITIAL OR
       NOT rm07m-gwels IS INITIAL OR
       NOT rm07m-vbeln IS INITIAL OR
       NOT rm07m-tknum IS INITIAL OR
       NOT rm07m-pabnum IS INITIAL.
      IF ( NOT rm07m-vlief IS INITIAL OR
           NOT rm07m-traid IS INITIAL ) AND
         ( NOT rm07m-gwelf IS INITIAL OR
           NOT rm07m-gwels IS INITIAL ).
        MESSAGE e218.
      ELSEIF ( NOT rm07m-vlief IS INITIAL OR
               NOT rm07m-traid IS INITIAL ) AND
               NOT rm07m-vbeln IS INITIAL.
        MESSAGE e218.
      ELSEIF ( NOT rm07m-gwelf IS INITIAL OR
               NOT rm07m-gwels IS INITIAL ) AND
               NOT rm07m-vbeln IS INITIAL.
        MESSAGE e218.
* Transportnummer muß allein sein
      ELSEIF NOT rm07m-tknum IS INITIAL AND
           ( NOT rm07m-vlief IS INITIAL OR
             NOT rm07m-traid IS INITIAL OR
             NOT rm07m-gwelf IS INITIAL OR
             NOT rm07m-gwels IS INITIAL OR
             NOT rm07m-vbeln IS INITIAL ).
        MESSAGE e218.
* Abrufnummer Kanban muß allein sein
      ELSEIF NOT rm07m-pabnum IS INITIAL AND
           ( NOT rm07m-tknum IS INITIAL OR
             NOT rm07m-vlief IS INITIAL OR
             NOT rm07m-traid IS INITIAL OR
             NOT rm07m-gwelf IS INITIAL OR
             NOT rm07m-gwels IS INITIAL OR
             NOT rm07m-vbeln IS INITIAL ).
        MESSAGE e218.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.