*eject
*---------------------------------------------------------------------*
*       FORM UPOS_GENERIEREN                                          *
*---------------------------------------------------------------------*
*       Bei Leergut werden bei Bewegungen ohne Belegbezug bzw. bei    *
*       automatischen Erstellen einer Bestellung im Hintergrund die   *
*       abhängigen Unterpositionszeilen erzeugt und in FUSS           *
*       abgestellt                                                    *
*---------------------------------------------------------------------*
FORM upos_generieren
               USING is_enhancement TYPE isu_upos_generieren."#EC *

  DATA: ls_isu_upos_samat  TYPE isu_upos_samat,  "IS2ERP
        ls_isu_upos_stueli TYPE isu_upos_stueli. "IS2ERP

  CHECK t158-trtyp = h.

ENHANCEMENT-POINT UPOS_GENERIEREN_01 SPOTS ES_SAPMM07M.

*##ngr-saanf
* 1.Sammelartikel:
* 'Einstreuen' der zuvor in VAR_FUSS geparkten Varianten
  IF vm07m-attyp = attyp-sam.
*    not matrix is initial.
    PERFORM upos_samat
                        USING ls_isu_upos_samat.    "IS2ERP
  ELSE.
    PERFORM upos_stueli
                        USING ls_isu_upos_stueli.  "IS2ERP
  ENDIF.
*##ngr-saend
ENDFORM.