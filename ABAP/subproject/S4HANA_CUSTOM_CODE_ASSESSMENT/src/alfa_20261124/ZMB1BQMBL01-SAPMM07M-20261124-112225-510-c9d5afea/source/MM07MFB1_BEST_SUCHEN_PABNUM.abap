*----------------------------------------------------------------------*
*               FORM BEST_SUCHEN_PABNUM                                *
*----------------------------------------------------------------------*
*    Bestellungen suchen über Abrufnummer  (Kanban)                    *
*----------------------------------------------------------------------*
FORM BEST_SUCHEN_PABNUM.

  CALL FUNCTION 'PAB_JIT_CALL_GR_ITEMS_GET'
       EXPORTING
            I_PABNUM = RM07M-PABNUM
       TABLES
            E_WUEB   = WUEB.
ENDFORM.