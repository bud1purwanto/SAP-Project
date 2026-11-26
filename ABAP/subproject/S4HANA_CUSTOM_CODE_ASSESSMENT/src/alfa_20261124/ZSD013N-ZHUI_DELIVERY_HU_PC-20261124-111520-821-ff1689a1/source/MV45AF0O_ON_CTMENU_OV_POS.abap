*----------------------------------------------------------------------*
*   INCLUDE MV45AF0O_ON_CTMENU_OV_POS                                  *
*----------------------------------------------------------------------*
FORM ON_CTMENU_OV_POS USING PIF_MENU TYPE REF TO CL_CTMENU.

  CALL METHOD PIF_MENU->LOAD_GUI_STATUS
              EXPORTING PROGRAM = 'SAPMV45A'
                        STATUS  = 'U_ITEM'
                        MENU    = PIF_MENU.

*   FCODES zur Desaktivierung
* DATA: l_fcodes type sctx_fcodes.
* data: begin of l_wa_fcodes,          " for add/disable functions
*         fcode type UI_FUNC,          " from status menu
*       end of l_wa_fcodes.
*Interne Tabelle mit Fcodes füllen.
*  l_wa_fcodes-fcode = 'HEAD'.
*  append l_wa_fcodes to l_fcodes.
* CALL METHOD PIF_menu->disable_functions
*             EXPORTING fcodes = l_fcodes.

ENDFORM.                               " ON_CTMENU_OV_POS