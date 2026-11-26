*---------------------------------------------------------------------*
*     MODULE FCODE_MAUS                                      *
*---------------------------------------------------------------------*
*       Popup zur Auswahl der Merkmale für das Übersichtsbild         *
*---------------------------------------------------------------------*
MODULE FCODE_MAUS.

  CHECK FCODE = 'MAUS'.

ENHANCEMENT-POINT FCODE_MAUS_02 SPOTS ES_SAPMV45A STATIC.
   XMERKMAL_SAVE[] = XMERKMAL[].

   TCTRL_CHAR_VA_SEL_LIN1 = 1.
   CALL SCREEN 0850 STARTING AT  10  2.

* Auswahl der Merkmalsübersicht wurde verändert.
   if ( xmerkmal[] <> xmerkmal_save[]  and
      not rv45a-muebs is initial )    or
      ( xmerkmal_save[] is initial     and
        not xmerkmal[] is initial      and
        rv45a-muebs is initial ) .
ENHANCEMENT-SECTION     FCODE_MAUS_01 SPOTS ES_SAPMV45A.
     RV45a-muebs = '**********'.
END-ENHANCEMENT-SECTION.
     clear vbmuet-bezei.
   endif.
ENHANCEMENT-POINT FCODE_MAUS_03 SPOTS ES_SAPMV45A.

   REFRESH XMERKMAL_SAVE.


* IF FCODE = FCODE_ABBRECHEN.
    FCODE = FCODE_GLEICHE_SEITE.
* ENDIF.

ENDMODULE.