*---------------------------------------------------------------------*
*       MODULE SET_CURSOR_IDNKD                                       *
*---------------------------------------------------------------------*
*       Der Cursor wird ergonomisch auf die Kundenmaterialnr. gesetzt *
*---------------------------------------------------------------------*
MODULE SET_CURSOR_IDNKD OUTPUT.

  PERFORM SET_CURSOR USING 'VBAP-KDMAT'.

ENDMODULE.