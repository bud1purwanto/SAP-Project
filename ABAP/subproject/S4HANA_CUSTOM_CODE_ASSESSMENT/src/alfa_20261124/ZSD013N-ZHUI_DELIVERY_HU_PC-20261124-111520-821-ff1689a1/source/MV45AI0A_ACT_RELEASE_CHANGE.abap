*&---------------------------------------------------------------------*
*&      Module  ACT_RELEASE_CHANGE  INPUT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
MODULE ACT_RELEASE_CHANGE INPUT.

DATA: DA_MENGEC(20) TYPE C.

  IF VBLB-AKFFZ NE *VBLB-AKFFZ.
    if not rv45z-docnum is initial.
*     Sichern der Fertigungsfreigabe-FZ, falls per EDI übermittelt
      rv45z-akffz = vblb-akffz.
    endif.

    WRITE *VBLB-AKFFZ TO DA_MENGEC LEFT-JUSTIFIED UNIT VBAP-VRKME.
    MESSAGE I624 WITH TEXT-228 DA_MENGEC.
* Änderung der aktuellen Fertigungsfreigabe-FZ - siehe Langtext
  ENDIF.

  IF VBLB-AKMFZ NE *VBLB-AKMFZ.
    if not rv45z-docnum is initial.
*     Sichern der Materialfreigabe-FZ, falls per EDI übermittelt
      rv45z-akmfz = vblb-akmfz.
    endif.

    WRITE *VBLB-AKMFZ TO DA_MENGEC LEFT-JUSTIFIED UNIT VBAP-VRKME.
    MESSAGE I624 WITH TEXT-227 DA_MENGEC.
* Änderung der aktuellen Materialfreigabe-FZ - siehe Langtext
  ENDIF.

ENDMODULE.                             " ACT_RELEASE_CHANGE  INPUT