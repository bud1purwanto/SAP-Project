*&---------------------------------------------------------------------*
*&      Form  FCODE_EID4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FCODE_EID4.

perform xvbep_detail(SAPFV45E).

call function 'SD_EHS_GET_STATUS'
     EXCEPTIONS
          EHS_NICHT_AKTIV  = 1
          EHS_VBEPDG_AKTIV = 2
          EHS_ALLES_AKTIV  = 3
          OTHERS           = 4.

if sy-subrc = 2 or
   sy-subrc = 3.
* wenn das Material kein Gefahrgutkennzeichenprofil besitzt, werden
* keine Gefahrgutzusatzdaten angezeigt
   if vbapd-profl is initial.
      message i212(v2).
      FCODE = FCODE_GLEICHE_SEITE.
      PERFORM FCODE_BEARBEITEN.
   endif.

endif.

ENDFORM.                    " FCODE_EID4






































