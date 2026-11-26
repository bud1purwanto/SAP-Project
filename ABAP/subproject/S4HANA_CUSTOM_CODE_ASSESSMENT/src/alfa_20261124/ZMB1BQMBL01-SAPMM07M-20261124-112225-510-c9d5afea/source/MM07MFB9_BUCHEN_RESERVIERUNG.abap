*eject
*---------------------------------------------------------------------*
*       FORM BUCHEN_RESERVIERUNG                                      *
*---------------------------------------------------------------------*
*       Wird on COMMIT ON LEVEL LEVEL_RESB prozessiert.               *
*       Grund: PP-Anforderung.                                        *
*       Bei Auslösung von Ereignispunkt wird entnommene Menge aus     *
*       Bestandsführung vom Update des PP auf die RESB wieder         *
*       überschrieben.                                                *
*       Durch COMMIT ON LEVEL wird sichergestellt, daß MM-Update      *
*       am Schluß läuft.                                              *
*---------------------------------------------------------------------*
FORM BUCHEN_RESERVIERUNG.
  CALL FUNCTION 'MB_CHANGE_RESERVATION_WA' IN UPDATE TASK
       TABLES
            XMRES = ZMRES.
ENDFORM.