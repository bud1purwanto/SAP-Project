*&---------------------------------------------------------------------*
*&  Include           BADI_SD_TO_FM_ITEM_NUMBER_PR                     *
*&---------------------------------------------------------------------*

 CALL FUNCTION 'GET_HANDLE_SD_TO_FM'
   IMPORTING
     handle = inst_badi_sd_to_fm
     active = active_badi_sd_to_fm.

 IF active_badi_sd_to_fm EQ charx AND
    NOT vbuk-fmstk EQ chara.
*---- Proceed if the BAdI for FM is active, and released for FM
   IF vbak-vbkla(2) NE 'CR'.
     CONSTANTS: con_modus_sim   TYPE mccontrol-modus  VALUE 'B'.
     RANGES: mcinf FOR tmc4-mcinf.
     DATA:
          BEGIN OF wa_mcinf OCCURS 0,
             sign(1),
             option(2),
             low  TYPE mcinf,
             high TYPE mcinf,
          END   OF wa_mcinf.

     IF   NOT rv45a-banfn IS INITIAL
          OR NOT rv45a-bnfpo IS INITIAL.
*---- Proceed when a PR or PO is created

       MOVE 'I'    TO wa_mcinf-sign.
       MOVE 'BT'   TO wa_mcinf-option.
       MOVE 'S008' TO wa_mcinf-low.
       MOVE 'S008' TO wa_mcinf-high.
       COLLECT wa_mcinf INTO mcinf.

       CALL FUNCTION 'MCV_STATISTICS_ORDER'
         EXPORTING
           trtyp       = t180-trtyp
           xvbak       = vbak          "XVBAK
           yvbak       = yvbak
           xvbak_updkz = xvbak_updkz
           yvbak_updkz = yvbak_updkz
           modus       = con_modus_sim "Simulation
         TABLES
           xkomv       = xkomv
           xvbap       = xvbap
           xvbep       = xvbep
           xvbkd       = xvbkd
           xvbpa       = xvbpa
           xvbfa       = xvbfa
           xvbuk       = xvbuk
           xvbup       = xvbup
           yvbap       = yvbap
           yvbep       = yvbep
           yvbkd       = yvbkd
           yvbpa       = yvbpa
           yvbfa       = yvbfa
           yvbuk       = yvbuk
           yvbup       = yvbup
           vbapf       = xvbapf     "VBAPF
           mcinf       = mcinf
           xfpla       = xfpla
           yfpla       = yfpla
           xfplt       = xfplt
           yfplt       = yfplt.

*---- Global table which stores the account assignment has to be cleared
       CALL FUNCTION 'FM_CO_ASS_INPUT_INIT'
         EXPORTING
           i_obart = 'VB'.

*---- Perform last_check
       DATA:
       l_gjahr LIKE fmioi-gjahr,
          BEGIN OF trwin OCCURS 5,
            function LIKE trwpr-function,
          END OF trwin.
       l_gjahr = sy-datum(4).

       CALL FUNCTION 'RWIN_CHECK'
         EXPORTING
           gjahr   = l_gjahr
           process = 'AVC     '
           event   = 'PRUEFEN'
         TABLES
           tkomp   = trwin
         EXCEPTIONS
           OTHERS  = 0.
       LOOP AT trwin.
         CALL FUNCTION trwin-function
           EXPORTING
             i_awtyp = 'VBRK'.
       ENDLOOP.

*---- Get the errors for SD
*---- Set up the error level before sending
       DATA: lt_mesg  TYPE STANDARD TABLE OF mesg INITIAL SIZE 10,
               ls_mesg  LIKE LINE OF lt_mesg,
               lf_lines TYPE i.

*---- Copy messages from CO_HANDLER to application log
       CALL FUNCTION 'MESSAGES_GIVE'
         TABLES
           t_mesg = lt_mesg
         EXCEPTIONS
           OTHERS = 1.

       DESCRIBE TABLE lt_mesg LINES lf_lines.
       IF lf_lines > 0.
         LOOP AT lt_mesg INTO ls_mesg.
           IF ls_mesg-msgty = 'E'.
*---- No errors allowed in the post event of last_check, raise message
*---- type X if this occurs
             MESSAGE x057(fi) WITH ls_mesg-arbgb ls_mesg-txtnr.
             EXIT.
           ENDIF.
           CLEAR obligo_error.
         ENDLOOP.

           PERFORM obligo_protocol(sapfv45e) CHANGING da_subrc.
           IF NOT da_subrc IS INITIAL.
             fcode = fcode_gleiche_seite.
             PERFORM fcode_bearbeiten.
             EXIT.
         ENDIF.
       ENDIF.
     ENDIF.
*
* Note 988839: also perform AVC last check for CRM orders
   ELSEIF   NOT rv45a-banfn IS INITIAL
         OR NOT rv45a-bnfpo IS INITIAL.
*---- Proceed when a PR or PO is created

*---- Global table which stores the account assignment has to be cleared
     CALL FUNCTION 'FM_CO_ASS_INPUT_INIT'
       EXPORTING
         i_obart = 'VB'.

*---- Perform last_check
     CALL FUNCTION 'RWIN_CHECK'
       EXPORTING
         gjahr   = l_gjahr
         process = 'AVC     '
         event   = 'PRUEFEN'
       TABLES
         tkomp   = trwin
       EXCEPTIONS
         OTHERS  = 0.
     LOOP AT trwin.
       CALL FUNCTION trwin-function
         EXPORTING
           i_awtyp = 'VBRK'.
     ENDLOOP.

* But do not react on AVC messages at all (even not for
* enqueue errors of message type A)
*
   ENDIF.
*---- Call FM_OPEN_ITEM_NUMBER whether PR/PO or not
   IF 1 = 2.                                                "768353
     CALL FUNCTION 'FM_OPEN_ITEM_NUMBER'
       EXPORTING
         i_belnr = vbak-vbeln
         i_orgvg = 'SDOR'.                                  "#EC *
   ENDIF.

   REFRESH trwin. CLEAR trwin.
   l_gjahr = sy-datum(4).
   CALL FUNCTION 'RWIN_CHECK'
     EXPORTING
       gjahr   = l_gjahr
       process = 'SDOR    '
       event   = 'OINUMBER'
     TABLES
       tkomp   = trwin
     EXCEPTIONS
       OTHERS  = 0.
   LOOP AT trwin.
     CALL FUNCTION trwin-function
       EXPORTING
         i_belnr = vbak-vbeln
         i_orgvg = 'SDOR'.
   ENDLOOP.

 ENDIF.