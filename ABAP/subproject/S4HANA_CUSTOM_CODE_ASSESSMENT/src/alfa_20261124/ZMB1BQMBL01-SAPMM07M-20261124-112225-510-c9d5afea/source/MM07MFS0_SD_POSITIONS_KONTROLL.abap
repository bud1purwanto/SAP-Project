*----------------------------------------------------------------------*
*       Form  SD_POSITIONS_KONTROLLE
*----------------------------------------------------------------------*
*       In der T160M kann eingestellt werden, daß eine
*       Warnung oder Fehlermeldung ausgegeben wird, wenn
*       HU-pflichtige und Nicht-HU-pflichtige Positionen in einem
*       Beleg vorhanden sind.
*----------------------------------------------------------------------*
form sd_positions_kontrolle.

* XDELIV-check only make sense, if there is a storage lacation
* (subcontractor components have no strg.loc. -> No check needed)
  check not mseg-lgort is initial.

  if not xdeliv = '1'.  "MB-CREATE: Kennz. keine Lieferung anlegen sitzt
*   Prüfen der Positionen 2 bis n.
    if not status is initial.
      case status.
        when 1.
          if dm07m-umxhupf is initial and vm07m-xhupf is initial.
            call function 'ME_CHECK_T160M'
                 exporting
                      i_arbgb = 'M7'
                      i_msgnr = '454'
                      i_msgvs = msgvs
                 exceptions
                      nothing = 00
                      warning = 01
                      error   = 02.
            case sy-subrc.
              when 0.
                message e454.
              when 1.
                message w454.
              when 2.
                message e454.
            endcase.
          endif.
        when 2.
        when 3.
          if not dm07m-umxhupf is initial or not vm07m-xhupf is initial.
            call function 'ME_CHECK_T160M'
                 exporting
                      i_arbgb = 'M7'
                      i_msgnr = '454'
                      i_msgvs = msgvs
                 exceptions
                      nothing = 00
                      warning = 01
                      error   = 02.
            case sy-subrc.
              when 0.
                clear xdeliv.
                message e454.
              when 1.
                message w454.
              when 2.
                clear xdeliv.
                message e454.
            endcase.
          endif.
      endcase.
    endif.

*   Status setzen bei Verarbeitung der ersten Position
    if status is initial.
      if not dm07m-umxhupf is initial or not vm07m-xhupf is initial.
        status = 1.                    "1.Position ist HU-pflichtig
      elseif rm07m-xdeliv = x.
        status = 2.            "MBRL mit Kennzeichen 'Lieferung anlegen'
      else.
        status = 3.            "1.Position ist nicht HU-pflichtig
      endif.
    endif.
  endif.

endform.                               " SD_POSITIONS_KONTROLLE