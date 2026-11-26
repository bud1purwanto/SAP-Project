*eject.
*---------------------------------------------------------------------*
*       MODULE T151T_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen der Kundengruppe                                        *
*---------------------------------------------------------------------*
MODULE T151T_SELECT OUTPUT.

  PERFORM T151T_SELECT USING VBKD-KDGRP
                             SPACE
                             SY-SUBRC.

ENDMODULE.