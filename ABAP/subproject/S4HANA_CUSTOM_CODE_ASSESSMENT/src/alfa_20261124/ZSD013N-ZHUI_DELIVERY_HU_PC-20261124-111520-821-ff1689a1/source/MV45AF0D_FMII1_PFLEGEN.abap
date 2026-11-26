*---------------------------------------------------------------------*
*       FORM FMII1_PFLEGEN                                            *
*---------------------------------------------------------------------*
*       Bearbeiten Dokumente aus Positionsebene                       *
*---------------------------------------------------------------------*
FORM fmii1_pflegen USING   us_t185f
                           us_t185
                           us_t185v.

  DATA:
  da_exit,
  da_dataloss,
  da_actyp VALUE 'M',
  da_sav.


  DATA: object        TYPE balobj_d   VALUE 'SD-SLS',
        subobject     TYPE balsubobj  VALUE 'OBLIGO',
        lt_mesg  TYPE STANDARD TABLE OF mesg,
        ls_mesg  TYPE mesg.


  IF t180-trtyp = chara.
    da_actyp = chard.
  ENDIF.

* Wenn Ergebnisrechnung nicht aktiv ist, ist COBL nicht gefüllt
  PERFORM cobl_fuellen(sapfv45p) USING vbak
                                       vbap
                                       vbkd
                              CHANGING cobl.


  CALL FUNCTION 'APPL_LOG_INIT'
    EXPORTING
      object              = object
      subobject           = subobject
    EXCEPTIONS
      object_not_found    = 1
      subobject_not_found = 2.

  CALL FUNCTION 'MESSAGES_INITIALIZE'.


  CALL FUNCTION 'FM_CO_ASS_INPUT_MAINTAIN_SD'
    EXPORTING
      i_cobl                  = cobl
      i_vbak                  = vbak
      i_vbap                  = vbap
      i_actyp                 = da_actyp
    IMPORTING
      e_flg_assignment_change = da_dataloss
      e_exit                  = da_exit.


  CALL FUNCTION 'MESSAGES_GIVE'
    TABLES
      t_mesg = lt_mesg
    EXCEPTIONS
      OTHERS = 1.

  CLEAR ls_mesg.
  LOOP AT lt_mesg INTO ls_mesg WHERE msgty = 'E'.
    MESSAGE_COLLECT subobject ls_mesg-msgty.
    message_collect_lord.
  ENDLOOP.

*Note 1607028
  CALL FUNCTION 'MESSAGES_STOP'.


  IF NOT da_dataloss IS INITIAL.

    da_sav = VBAP_ENDE_VERFUEGBARKEIT.
    VBAP_ENDE_VERFUEGBARKEIT = CHARX.

    r185d-dataloss = da_dataloss.

* Evtl. erzeugte Banfen wegen Obligo anpassen
    loop at xvbep where updkz ne updkz_delete
                  and   posnr eq vbap-posnr
                  and   wmeng gt 0
                  and   bnfpo ne space.
      svbep-tabix = sy-tabix.
      perform vbep_bearbeiten_vorbereiten(SAPFV45E).
      perform vbep_bearbeiten_beschaffung(SAPFV45E).
    endloop.

    VBAP_ENDE_VERFUEGBARKEIT = da_sav.
  ENDIF.

  IF da_exit IS INITIAL.
    PERFORM fmii1_pruefen_vollst(sapfv45p) USING charx.
  ENDIF.
ENDFORM.                    "fmii1_pflegen