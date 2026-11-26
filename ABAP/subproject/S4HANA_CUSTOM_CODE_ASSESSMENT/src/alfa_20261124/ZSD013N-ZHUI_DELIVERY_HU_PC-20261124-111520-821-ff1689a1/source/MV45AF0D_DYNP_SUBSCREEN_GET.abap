*---------------------------------------------------------------------*
*       FORM DYNP_SUBSCREEN_GET                                       *
*---------------------------------------------------------------------*
*       Dynpronummern aus Rahmenprogramm besorgen                     *
*---------------------------------------------------------------------*
FORM DYNP_SUBSCREEN_GET CHANGING CH_HEADER_SUBSCREEN
                                 CH_BODY_SUBSCREEN
                                 CH_SUBRC.

  IF NOT TAXI_HEADER_SUBSCREEN IS INITIAL AND
     NOT TAXI_BODY_SUBSCREEN IS INITIAL.
    CH_HEADER_SUBSCREEN = TAXI_HEADER_SUBSCREEN.
    CH_BODY_SUBSCREEN   = TAXI_BODY_SUBSCREEN.
  ELSE.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.