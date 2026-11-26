*eject
*---------------------------------------------------------------------*
*       FORM   TRANSAKTION_VERLASSEN_OHNE                             *
*---------------------------------------------------------------------*
*       Laufende Transaktion wird verlassen ohne Kontroll-Pop-Up      *
*---------------------------------------------------------------------*
FORM TRANSAKTION_VERLASSEN_OHNE.
  IF NOT SY-BINPT IS INITIAL.
    LEAVE PROGRAM.
  ENDIF.
  IF NOT SY-CALLD IS INITIAL.
    LEAVE.
  ELSE.
    IF NOT T063O-TCODE IS INITIAL.
      IF T063O-TCODE NE TCOD-MB00.
        LEAVE TO TRANSACTION T063O-TCODE.
      ELSE.
        SET SCREEN 0.
        LEAVE SCREEN.
      ENDIF.
    ENDIF.
*{   DELETE         TRDK904688                                        1
*\    LEAVE TO TRANSACTION TCODE.
*}   DELETE
*{   INSERT         TRDK904688                                        2
*    -bap- pas back ke current tcode
     TCODE = CL_DYNPRO=>GET_CURRENT_TRANSACTION( ) .
     LEAVE TO TRANSACTION tcode.
*}   INSERT
  ENDIF.
ENDFORM.