*----------------------------------------------------------------------*
*   INCLUDE MV45AF0O_ON_CTMENU_OV_HEADER                               *
*----------------------------------------------------------------------*
FORM ON_CTMENU_OV_HEADER USING PIF_MENU TYPE REF TO CL_CTMENU.

  CALL METHOD PIF_MENU->LOAD_GUI_STATUS
              EXPORTING PROGRAM = 'SAPMV45A'
                        STATUS  = 'U_HEAD'
                        MENU    = PIF_MENU.

ENDFORM.                               " ON_CTMENU_OV_HEADER