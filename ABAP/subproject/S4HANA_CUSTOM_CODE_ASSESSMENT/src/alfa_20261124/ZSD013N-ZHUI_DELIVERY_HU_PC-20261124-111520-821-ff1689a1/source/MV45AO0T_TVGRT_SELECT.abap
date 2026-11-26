*---------------------------------------------------------------------*
*       MODULE TVGRT_SELECT                                           *
*---------------------------------------------------------------------*
*       Lesen Verkäufergruppentext                                    *
*---------------------------------------------------------------------*
MODULE TVGRT_SELECT OUTPUT.

  PERFORM TVGRT_SELECT USING VBAK-VKGRP
                             SPACE
                             SY-SUBRC.

ENDMODULE.