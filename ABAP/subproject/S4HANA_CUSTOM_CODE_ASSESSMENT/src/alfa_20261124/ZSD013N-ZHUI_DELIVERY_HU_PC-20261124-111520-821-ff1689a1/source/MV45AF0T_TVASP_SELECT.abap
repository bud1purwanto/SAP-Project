*eject
*---------------------------------------------------------------------*
*       FORM TVASP_SELECT                                             *
*---------------------------------------------------------------------*
*       Auftragssperrentabelle lesen und Sperre prüfen                *
*---------------------------------------------------------------------*
form tvasp_select using us_kunnr
                        us_aufsp
                        us_auart
                        us_dialog
                        ch_subrc.
  data: blocked_we like kuwev-kunnr.
  ch_subrc = 0.
  check us_aufsp ne space.

  if us_aufsp = space.
    clear: tvasp.
    exit.
  endif.

  select single * from tvasp where aufsp = us_aufsp and
                                   auart = us_auart.

  if sy-subrc = 0.
* Auftragssperre
    clear tvast.
    select single * from tvast where aufsp = us_aufsp and
                                     spras = sy-langu.
    if us_dialog = charx.
      case t180-trtyp.
        when charh.
        if not kuwev-kunnr is initial.
          blocked_we = kuwev-kunnr.
* Bei unzulässigem Auftraggeber den bereits ermittelten Warenempfänger
* löschen
          clear kuwev.
           if us_kunnr is initial.
* Error nur im Anlegen
             message e423 with blocked_we tvast-vtext.
            else.
             message e423 with us_kunnr tvast-vtext.
           endif.
         else.
          clear kuwev.
           message e423 with us_kunnr tvast-vtext.
         endif.
        when charv.
          if kuagv-kunnr = vbak-kunnr and
             rv02p-agupd is initial.
            message i423 with us_kunnr tvast-vtext.
          else.
            message e423 with us_kunnr tvast-vtext.
          endif.
          ch_subrc = 423.
        when chara.
          if not vbuk-gbstk eq charc.
            message i423 with us_kunnr tvast-vtext.
            ch_subrc = 423.
          else.
            ch_subrc = 423.
          endif.
      endcase.
    else.
      if kopieren = charx.
ENHANCEMENT-POINT TVASP_SELECT_10 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT TVASP_SELECT_11 SPOTS ES_SAPMV45A.

        message a423 with us_kunnr tvast-vtext.
      else.
        message i423 with us_kunnr tvast-vtext.
        ch_subrc = 423.
        exit.
      endif.
    endif.
  endif.

endform.