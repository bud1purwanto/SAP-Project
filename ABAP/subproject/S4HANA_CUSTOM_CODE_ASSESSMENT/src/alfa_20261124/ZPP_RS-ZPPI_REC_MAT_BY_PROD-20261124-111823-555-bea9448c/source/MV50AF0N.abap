*----------------------------------------------------------------------*
*   INCLUDE MV50AF0N                                                   *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM NICHT_SPERREN                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM nicht_sperren.
* Verhindert Sperren der Lieferung bei externem Lieferungsupdate.
* Muß aufgerufen werden, wenn der Aufrufer die Lieferung selbst schon
* gesperrt hat.
  nicht_sperren = charx.
ENDFORM.                    "nicht_sperren

*---------------------------------------------------------------------*
*       FORM NICHT_SPERREN_Y                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM nicht_sperren_y.
* Verhindert Sperren der Lieferung bei externem Lieferungsupdate.
* Verhindert auch Sperren des zugrundeliegenden Auftrags.
  nicht_sperren = chary.
ENDFORM.                    "nicht_sperren_y

*---------------------------------------------------------------------*
*       FORM NO_MESSAGES_UPDATE                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM no_messages_update.
  no_messages_update = charx.
ENDFORM.                    "no_messages_update

*---------------------------------------------------------------------*
*       FORM NO_DEQUEUE                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM new_dequeue USING if_no_dequeue TYPE c.

  IF if_no_dequeue = charx.
    no_dequeue = charx.
  ELSE.
    no_dequeue = space.
  ENDIF.

ENDFORM.                    "new_dequeue

*---------------------------------------------------------------------*
*  FORM no_dequeue
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
FORM no_dequeue.

  PERFORM new_dequeue USING charx.

ENDFORM.                    "no_dequeue

*---------------------------------------------------------------------*
*       FORM NO_IMSEG_REFRESH                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM no_imseg_refresh.

  no_imseg_refresh = charx.

ENDFORM.                    "no_imseg_refresh