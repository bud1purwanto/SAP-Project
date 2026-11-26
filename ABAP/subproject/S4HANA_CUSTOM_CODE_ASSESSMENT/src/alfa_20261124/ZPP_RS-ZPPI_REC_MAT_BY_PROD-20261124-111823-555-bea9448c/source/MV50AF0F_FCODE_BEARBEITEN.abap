*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_BEARBEITEN                                  *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_BEARBEITEN                                         *
*---------------------------------------------------------------------*
*       Aufruf des Funktionsbausteins 'FOLGEBILD'                     *
*       Standardroutine zur Funktionscodebehandlung                   *
*       Der Fcode wird mit dem Folgefcode besetzt                     *
*---------------------------------------------------------------------*

form fcode_bearbeiten.

  data: fb_fcode like fcode.

ENHANCEMENT-POINT SAPMV50A_12 SPOTS ES_SAPMV50A STATIC.
  clear: flag-no.
  fb_fcode = fcode.
  old_fcode = fcode.
ENHANCEMENT-POINT SAPMV50A_11 SPOTS ES_SAPMV50A .


ENHANCEMENT-POINT MV50AF0F_FCODE_BEARBEITEN_01 SPOTS ES_SAPMV50A.
* Routines for transforming function codes
  if    t180-bldgr eq gc_new_dialog_outb
     or t180-bldgr eq gc_new_dialog_inb.
    perform transform_doubleclick         changing fcode.
    perform taxi_filter_and_convert_fcode changing fcode.
    perform transform_view_fcode          changing fcode.
    perform transform_tc_fcode            changing fcode
                                                   gf_pushbutton_line.
  endif.

*... Wurde bereits erfolgreich im MM gebucht?
  if wa_zaehl > 0          and         "WA-Zaehler noch Null?
     fcode(4) <> 'SIC1'    and         "und FCODE nicht 'Sichern'!!!
     fcode(4) <> 'LT06'.               "und FCODE nicht 'LT06'
    message a621.                      "wenn nein, Abbruch!!!
  endif.

* Blaettern auf Textbildern
  if ( sy-dynnr = '0330' or
       sy-dynnr = '0530' )
     and
     ( fcode = 'P+  ' or
       fcode = 'P++ ' or
       fcode = 'P-  ' or
       fcode = 'P-- ' ).
    export fcode to memory id 'TEXTFCODE'.
  endif.

  if fcode(4) eq fcode_beleg_loeschen  "46A BEY
     and sy-binpt eq charx.
    perform funktion_ausfuehren.
  endif.

  if fcode = space.
    fcode = fcode_gleiche_seite.
  endif.

  "Prevent safety dialog box in display mode
  if t180-trtyp eq chara.                                   "v_n_1374189
    clear r185d-dataloss.
  endif.                                                    "^_n_1374189

ENHANCEMENT-POINT FCODE_BEARBEITEN_01 SPOTS ES_SAPMV50A.
  call function 'SCREEN_SEQUENCE_CONTROL'
       exporting
            programm        = 'SAPMV50A'
            kopfgruppe      = tvlk-kopgr
            positionsgruppe = tvlp-posgr
            funktion        = fcode
       importing
            aktyp           = t185f-aktyp
            cua_status      = t185v-status
            cua_titel       = t185v-ctitel
            cua_para1       = t185v-para1
            cua_para2       = t185v-para2
            cua_para3       = t185v-para3
            cua_para4       = t185v-para4
            folgefunktion   = fcode
            dunkel          = t185-dunkel
            leave           = flag-leave
            panel           = t185v-panel
            dynprobaustein1 = taxi_header_subscreen  "46A BEY
            dynprobaustein2 = taxi_body_subscreen.

ENHANCEMENT-SECTION     FCODE_BEARBEITEN_02 SPOTS ES_SAPMV50A.
  if flag-leave ne space.
    t185f-fcode = fcode.
*   Text memory has to be refreshed if in CALL TRANSACTION mode
    if sy-calld ne space.
      perform text_memory_init.
    endif.
    leave.
  endif.
END-ENHANCEMENT-SECTION.
  if uc_process ne space.
    perform uncompleteness_protocol(sapfv50u).
  endif.

endform.