*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_TRANSACTION_CAL                             *
*----------------------------------------------------------------------*
* This form routine is called when the delivery processing should be
* left to call another delivery or a follwing function transaction.
* BELEG_SICHERN can be processed to prevent data loss.

form fcode_transaction_call.

  data: lf_docnumber(10) type c,
        lf_textline1(50) type c,
        lf_textline2(50) type c,
        lf_title(50) type c,
        lf_answer type c,
        lf_save_fcode type fcode.

  lf_title = 'Belegbearbeitung beenden'(066).

* Fill fcode from T185 if empty (necessary in case this form is called
* from SAPMV50B)
  if fcode is initial.
    fcode = t185-fcode.
  endif.

* Check, whether authorisation for selected transaction is given
  case fcode.
    when 'FT41_T'.
      authority-check object 'L_TCODE'
               id 'TCD' field 'LT03'.
      if sy-subrc ne 0.
        message i028(vla).
        exit.
      endif.
  endcase.

* Send a dialog box in case of possible dataloss
  if r185d-dataloss ne space and t180-trtyp ne chara.

    lf_textline1 = 'Lieferung &1 wurde verändert.'(064).
    lf_textline2 = 'Wollen Sie die Daten sichern?'(065).
    write likp-vbeln to lf_docnumber no-zero.
    replace '&1' with lf_docnumber into lf_textline1.
    condense lf_textline1.

    call function 'POPUP_TO_CONFIRM_STEP'
         exporting
              defaultoption  = 'Y'
              textline1      = lf_textline1
              textline2      = lf_textline2
              titel          = lf_title
              start_column   = 25
              start_row      = 6
              cancel_display = 'X'
         importing
              answer         = lf_answer.

    case lf_answer.
      when 'J'.
*       In case of output processing the delivery must be posted
*       synchronously. Otherwise, the output processing does not find
*       the current delivery data
        if fcode eq 'VL70_T' or
           fcode eq 'VL71_T' or
           fcode eq 'VL75_T'.
          perform synchron.
          set parameter id 'NAC' field space.
        endif.
*       If a WM transfer order is going to be created synchronous
*       posting is meaningful. Otherwise the user has to wait until the
*       posting process is finished.
        if fcode eq 'FT41_T'.                               "46B
          perform synchron.
        endif.
        lf_save_fcode = fcode.
        fcode = 'SAVE&EXIT'.
        perform beleg_sichern using charx.
        fcode = lf_save_fcode.
      when 'A'.
        exit.
      when 'N'.
        call function 'DEQUEUE_ALL'.
    endcase.
  else.
*   If no data have been changed, at least send a warning that the
*   dialog is left without a chance to return (not on the initial
*   screen)
    if ( fcode eq 'VL04_T'  or
         fcode eq 'VL02_T'  or
         fcode eq 'VL03_T'  or
         fcode eq 'VL32_T'  or
         fcode eq 'VL33_T'  or
         fcode eq 'VL06_T'  or
         fcode eq 'VL06I_T' or
         fcode eq 'VL71_T'  or
         fcode eq 'VL75_T'  or
         fcode eq 'VL70_T'  or
         fcode eq 'FT41_T' ) and
       ( sy-dynnr lt '4000' and
         sy-dynnr ne '0107' ).
      lf_textline1 = 'Der Dialog wird verlassen.'(068).
      lf_textline2 = 'Wollen Sie zur Folgefunktion wechseln?'(069).
      call function 'POPUP_TO_CONFIRM_STEP'
           exporting
                defaultoption  = 'Y'
                textline1      = lf_textline1
                textline2      = lf_textline2
                titel          = lf_title
                start_column   = 25
                start_row      = 6
                cancel_display = ' '
           importing
                answer         = lf_answer.
      case lf_answer.
        when 'J'.
        when 'N'.
          exit.
      endcase.
    endif.
  endif.

* lines deleted                                               "n_1057535

  case fcode.
    when 'CRMA_T'.
      leave to transaction 'VL01N'.
    when 'CROA_T'.
      leave to transaction 'VL01NO'.
    when 'VL02_T'.
      leave to transaction 'VL02N'.
    when 'VL03_T'.
      leave to transaction 'VL03N'.
    when 'AROD_T'.
      leave to transaction 'VLODAR'.
    when 'VL31_T'.
      leave to transaction 'VL31N'.
    when 'VL32_T'.
      leave to transaction 'VL32N'.
    when 'VL33_T'.
      leave to transaction 'VL33N'.
    when 'ARID_T'.
      leave to transaction 'VLIDAR'.
    when 'VL04_T'.
      leave to transaction 'VL10'.
    when 'VL06_T'.
      leave to transaction 'VL06O'.
    when 'VL06I_T'.
      leave to transaction 'VL06I'.
    when 'VL70_T'.
      leave to transaction 'VL70'.
    when 'VL71_T'.
      leave to transaction 'VL71'.
    when 'VL75_T'.
      leave to transaction 'VL75'.
    when 'FT41_T'.
      set parameter id 'LGN' field likp-lgnum.
      if likp-vbtyp eq vbtyp_mmli.
        set parameter id 'VLM' field likp-vbeln.
      else.
        set parameter id 'VL'  field likp-vbeln.
      endif.
      leave to transaction 'LT03'.
  endcase.

endform.