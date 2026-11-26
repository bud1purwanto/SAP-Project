
************************************************************************
*                                                                      *
* PBO Module zur Ablaufsteuerung - Lieferungsabwicklung                *
*     Module alphabetisch geordnet; hier beginnend mit "D"             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE DUNKEL_VERARBEITEN OUTPUT                              *
*---------------------------------------------------------------------*
*       Dynpro dunkel verarbeiten                                     *
*---------------------------------------------------------------------*
MODULE dunkel_verarbeiten OUTPUT.

  CHECK t185-dunkel NE space.
  SUPPRESS DIALOG.

ENDMODULE.                    "dunkel_verarbeiten OUTPUT
*eject

*---------------------------------------------------------------------*
*       MODULE DUNKEL_STARTEN     OUTPUT                              *
*---------------------------------------------------------------------*
*       Start-Dynpro dunkel verarbeiten                               *
*---------------------------------------------------------------------*
MODULE dunkel_starten OUTPUT.

  SUPPRESS DIALOG.

ENDMODULE.                    "dunkel_starten OUTPUT
*eject
*&---------------------------------------------------------------------*
*&      Module  DELIVERY_SCHEDULE_DATA  OUTPUT  (HP_373580)
*&---------------------------------------------------------------------*
*       Read forecast delivery schedule data for current item
*----------------------------------------------------------------------*
MODULE delivery_schedule_data OUTPUT.

  CHECK lips-vgtyp CA vbtyp_lp.
  PERFORM delivery_schedule_data USING    lips-vgbel
                                          lips-vgpos
                                          lips-abart
                                 CHANGING vblb.

ENDMODULE.                             " DELIVERY_SCHEDULE_DATA  OUTPUT
*eject

*&---------------------------------------------------------------------*
*&      Module  docubatch_detail_open  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE docubatch_detail_open OUTPUT.

   PERFORM docubatch_detail_open.

ENDMODULE.                 " docubatch_detail_open  OUTPUT
*eject