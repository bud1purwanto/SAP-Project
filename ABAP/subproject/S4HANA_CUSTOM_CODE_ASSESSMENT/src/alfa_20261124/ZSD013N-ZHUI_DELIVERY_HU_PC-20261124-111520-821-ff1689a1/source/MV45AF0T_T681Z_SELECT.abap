*---------------------------------------------------------------------*
*       FORM T681Z_SELECT                                             *
*---------------------------------------------------------------------*
*       Lesen der Tabelle 681Z (Applikationsdaten)                    *
*---------------------------------------------------------------------*
FORM T681Z_SELECT USING US_KAPPL
                        US_SUBRC.

  US_SUBRC = 0.
  CHECK US_KAPPL NE T681Z-KAPPL.
  SELECT SINGLE * FROM T681Z WHERE KVEWE = 'B'
                             AND   KAPPL = US_KAPPL.
  US_SUBRC = SY-SUBRC.

ENDFORM.