*---------------------------------------------------------------------*
*       FORM ZEILE_SETZEN                                             *
*---------------------------------------------------------------------*
*       Zur Anzeige auf dem folgenden Dynpro wird die aktuelle        *
*       Zeile (A_ZEILE) ermittelt.                                    *
*---------------------------------------------------------------------*
form zeile_setzen.
* a_zeile = current line (more or less line on dynpro)
* m_zeile = lines in YMSEG
* o_zeile = lines in OMSEG (subsequent adjustment only)
  if not xpf02 is initial and not fcausw-xlist is initial.
    a_zeile = aufsetzen_1.
    if a_zeile is initial.
      a_zeile = 1.
    endif.
    exit.
  endif.
  assign m_zeile to <f>.
  if not fcausw-xselp is initial.
    assign f_zeile to <f>.
  endif.
* In case of subsequent adjustment the main items are not in YMSEG but
* in OMSEG, so it is necessary to add OMSEG counter (o_zeile) to
* mseg-zeile in order to get the 'real' current line.
* In case of MB01 omseg is always empty at this stage as main items are
* in YMSEG as well.
  if pcode is initial.
    if not fcausw-xneup is initial.
      a_zeile = mseg-zeile.
      mseg-zeile = m_zeile + o_zeile + 1.
*     If a main item is changed, renumberich of all subitem's URZEI
*     necessary in subsequent adjustment cancel (mseg-mblnr is set).
*     Kzbew=O parenthesis to make sure it is a main item.
ENHANCEMENT-POINT ZEILE_SETZEN_01 SPOTS ES_SAPMM07M.
      if not mseg-zeile = a_zeile and a_zeile = mseg-urzei
                                  and not mseg-mblnr is initial and
         not ( t158-kzbew = o and mseg-kzbew is initial ).
        loop at fuss where mblnr = mseg-mblnr
                     and   urzei = mseg-urzei.
          fuss-urzei = mseg-zeile.
          modify fuss.
        endloop.
        mseg-urzei = mseg-zeile.
      endif.
      a_zeile = m_zeile.
      if fcausw-xlist is initial and aufsetzen is initial.
        aufsetzen = mseg-zeile.
      endif.
* bei Stücklisten (Leergut,..) muß die Zeilennummer der abhängigen
* Positionen ebenfalls geändert werden
      if fuss-upvor ne space.
        perform abhaengige_zeilen_setzen.
      endif.
    else.
      if fuss-zeile ne 0.
        a_zeile = fuss-zeile.
      else.
        if rm07m-zeile is initial.
          if not fcausw-xlist is initial.
            if aufsetzen_1 is initial.
              if l_zeile < <f>.
                a_zeile = l_zeile + 1.
              else.
                a_zeile = 1.
              endif.
            else.
              if aufsetzen_1 > <f>.
                aufsetzen_1 = 1.
              endif.
              a_zeile = aufsetzen = aufsetzen_1.
            endif.
          else.
            if aufsetzen is initial.
              if a_zeile < <f>.
                a_zeile = a_zeile + 1.
              else.
                a_zeile = 1.
              endif.
            else.
              a_zeile = aufsetzen.
            endif.
          endif.
          if a_zeile is initial.
            a_zeile = 1.
          endif.
        else.
          if rm07m-zeile > <f>.
            a_zeile = 1.
          else.
            a_zeile = rm07m-zeile.
          endif.
          clear rm07m-zeile.
        endif.
      endif.
    endif.
  else.
    perform blaettern.
    clear pcode.
  endif.
  if not rm07m-zeile is initial and fuss-zeile is initial.
    aufsetzen = rm07m-zeile.
    clear rm07m-zeile.
  endif.
endform.
*eject