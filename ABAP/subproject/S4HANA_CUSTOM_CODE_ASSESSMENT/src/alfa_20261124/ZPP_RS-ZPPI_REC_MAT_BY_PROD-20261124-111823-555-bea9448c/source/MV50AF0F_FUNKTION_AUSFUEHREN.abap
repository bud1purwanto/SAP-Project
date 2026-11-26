***INCLUDE MV50AF0F_FUNKTION_AUSFUEHREN .
*---------------------------------------------------------------------*
*       FORM FUNKTION_AUSFUEHREN                                      *
*---------------------------------------------------------------------*
form funktion_ausfuehren.

  data: fb_fcode like fcode,
        flag-leave_screen.

* Routines for transforming function codes
  if    t180-bldgr eq gc_new_dialog_outb
     or t180-bldgr eq gc_new_dialog_inb.
    perform transform_doubleclick         changing fcode.
    perform taxi_filter_and_convert_fcode changing fcode.
    perform transform_view_fcode          changing fcode.
    perform transform_tc_fcode            changing fcode
                                                   gf_pushbutton_line.
*   Terminate incompleteness log processing if cancel button is pressed
    if fcode eq 'ABBR_T' and uc_process ne space.
      fcode = 'UCCL'.
      exit.
    endif.
  endif.

*... Wurde bereits erfolgreich im MM gebucht?
  if wa_zaehl > 0.                     "WA-Zaehler noch Null?
    message a621.                      "wenn nein, Abbruch!!!
  endif.

* New dialog: ABBR_T is a function with T185F-FCINT = 1
  if ( fcode(4) eq fcode_abbrechen or
       fcode(4) eq 'RUE1' )         and
     ( t180-bldgr ne gc_new_dialog_outb and
       t180-bldgr ne gc_new_dialog_inb ).
    perform fcode_bearbeiten.
  endif.
  if fcode(4) eq 'POLO' or
     fcode(4) eq 'POLE'.
    perform xlips_loeschen_start(sapfv50p).

  endif.
  "Prevent safety dialog box in display mode
  if t180-trtyp eq chara.                                   "v_n_1374189
    clear r185d-dataloss.
  endif.                                                    "^_n_1374189
  fb_fcode = fcode.
  call function 'FUNCTION_EXECUTE'
       exporting
            programm        = 'SAPMV50A'
            kopfgruppe      = tvlk-kopgr
            positionsgruppe = tvlp-posgr
            funktion        = fcode
       importing
            cua_status      = t185v-status
            cua_titel       = t185v-ctitel
            cua_para1       = t185v-para1
            cua_para2       = t185v-para2
            cua_para3       = t185v-para3
            cua_para4       = t185v-para4
            folgefunktion   = fcode
            dunkel          = t185-dunkel
            leave           = flag-leave
            leave_screen    = flag-leave_screen.

  if flag-leave ne space.
    t185f-fcode = fcode.
*   Text memory has to be refreshed if in CALL TRANSACTION mode
    if sy-calld ne space.
      perform text_memory_init.
    endif.
    leave.
  endif.
  if flag-leave_screen ne space.
    t185f-fcode = fcode.
*---APO integration:-----------
    perform leave_screen.
*    leave screen.
  endif.

* If new delivery document has been read skip PAI flow logic of current
* dynpro (not relevant for APO exit logic!)
  if fb_fcode eq 'NEWD_T'.                                  "HP_375327
    leave screen.
  endif.

endform.                               "FUNKTION_AUSFUEHREN