*eject
*---------------------------------------------------------------------*
*       FORM H_OPTION_SETZEN                                          *
*---------------------------------------------------------------------*
*       Die Eingabe im Feld RM07M-OPTION wird umgesetzt.              *
*---------------------------------------------------------------------*
FORM H_OPTION_SETZEN.
  RBDTER-OPTION = RM07M-OPTION_MB.
  CASE RBDTER-OPTION.
    WHEN '='.
      RBDTER-OPTION = 'EQ'.
    WHEN '<>'.
      RBDTER-OPTION = 'NE'.
    WHEN '>'.
      RBDTER-OPTION = 'GT'.
    WHEN '>='.
      RBDTER-OPTION = 'GE'.
    WHEN '<'.
      RBDTER-OPTION = 'LT'.
    WHEN '<='.
      RBDTER-OPTION = 'LE'.
    WHEN 'CP'.
      RBDTER-OPTION = 'EQ'.
    WHEN 'NP'.
      RBDTER-OPTION = 'EQ'.
    WHEN '  '.
      RBDTER-OPTION = 'EQ'.
  ENDCASE.
ENDFORM.