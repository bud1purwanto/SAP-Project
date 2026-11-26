*&---------------------------------------------------------------------*
*&  Include           BADI_SD_TO_FM_CALL_S008                          *
*&---------------------------------------------------------------------*

 CALL FUNCTION 'GET_HANDLE_SD_TO_FM'
   IMPORTING
     HANDLE = INST_BADI_SD_TO_FM
     ACTIVE = ACTIVE_BADI_SD_TO_FM.
 IF ACTIVE_BADI_SD_TO_FM EQ CHARX.

   Statics:  T160M_buffer type T160M.

   IF VBAK-VBKLA(2) NE 'CR'.

     IF t180-trtyp EQ 'H'.

       CALL FUNCTION 'RV_XVBUK_MAINTAIN'
         EXPORTING
           F_VBELN       = VBAK-VBELN
           F_VBTYP       = VBAK-VBTYP
           F_VBAK        = VBAK
         IMPORTING
           E_VBUK_CHANGE = DA_CHANGE
         TABLES
           FXVBUP        = XVBUP
           FXVBUK        = XVBUK
           FXVBUV        = XVBUV
           FYVBUK        = YVBUK.

       IF NOT DA_CHANGE IS INITIAL.
         UPD_VBUK = CHARU.
       ENDIF.
       PERFORM xvbuk_lesen(sapfv45k) USING vbak-vbeln.
     ENDIF.

     CALL METHOD INST_BADI_SD_TO_FM->MV45AF0B_CALL_S008
       EXPORTING
         CALL_FUNCTION = CALL_FUNCTION
       CHANGING
         XVBAK         = VBAK
         YVBAK         = YVBAK
         XKOMV         = XKOMV[]
         XVBAP         = XVBAP[]
         XVBEP         = XVBEP[]
         XVBKD         = XVBKD[]
         XVBPA         = XVBPA[]
         XVBFA         = XVBFA[]
         XVBUK         = XVBUK[]
         XVBUP         = XVBUP[]
         YVBAP         = YVBAP[]
         YVBEP         = YVBEP[]
         YVBKD         = YVBKD[]
         YVBPA         = YVBPA[]
         YVBFA         = YVBFA[]
         YVBUK         = YVBUK[]
         YVBUP         = YVBUP[]
         VBAPF         = XVBAPF[]
         XFPLA         = XFPLA[]
         YFPLA         = YFPLA[]
         XFPLT         = XFPLT[]
         YFPLT         = YFPLT[]
         XVBAK_UPDKZ   = XVBAK_UPDKZ
         YVBAK_UPDKZ   = YVBAK_UPDKZ
         TRTYP         = T180-TRTYP
         da_answer     = da_answer.

     IF da_answer EQ CHAR2.
* Leave if obligo error occured
       obligo_error = CHARN.
         PERFORM OBLIGO_PROTOCOL(SAPFV45E) CHANGING DA_SUBRC.
         IF NOT DA_SUBRC IS INITIAL.
           FCODE = FCODE_GLEICHE_SEITE.
           PERFORM FCODE_BEARBEITEN.
           EXIT.
       ENDIF.
     ENDIF.
     ELSE.
       IF T160M_BUFFER IS INITIAL.
         SELECT SINGLE * INTO T160M_BUFFER FROM T160M
                 WHERE MSGVS = SPACE
                   AND ARBGB = 'V4'
                   AND MSGNR = '339'.
       ENDIF.
       IF SY-SUBRC = 0 AND NOT T160M_BUFFER-MSGTP IS INITIAL.
         MESSAGE ID 'V4' TYPE T160M_BUFFER-MSGTP NUMBER '339'.
       ENDIF.
     ENDIF.
   ENDIF.