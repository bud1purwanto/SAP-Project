*eject
*---------------------------------------------------------------------*
*       FORM XVBPA_PRUFEN
*---------------------------------------------------------------------*
*       Die Belegpartnertabelle wird nach Aufbau geprüft
*---------------------------------------------------------------------*
FORM XVBPA_PRUEFEN USING US_POSNR.

  DATA: DA_PARGR LIKE TVAK-PARGR.

  DATA: begin of temp_xvbpa occurs 2.
        include structure vbpavb.
  DATA: end   of temp_xvbpa.

  DATA: da_no_dialog(1) type c.

* 1. temporäre xvbpa erstellen                                         *
  if call_function = charx.
     loop at xvbpa where posnr = us_posnr.
          append xvbpa to temp_xvbpa.
     endloop.
  endif.

  IF US_POSNR IS INITIAL.
    DA_PARGR = TVAK-PARGR.
  ELSE.
    PERFORM TVAP_SELECT(SAPMV45A) USING VBAP-PSTYV
                                        CHARX
                                        SY-SUBRC.
    DA_PARGR = TVAP-PARGR.
  ENDIF.

  perform xvbpa_partner_check(sapmv45a) tables xvbpa
                                        using  da_pargr
                                               us_posnr.

* In case of call from BAPI: Do not process dialogs
  IF call_bapi EQ charx.
     call function 'DIALOG_GET_STATUS'
          importing
             dialog_status = da_no_dialog.
  ENDIF.

  CALL FUNCTION 'KOPIERTE_PARTNER_PRUEFEN'
       EXPORTING
            PARTNERGRUPPE            = DA_PARGR
            POSITION                 = US_POSNR
            REFERENZ_BELEG           = VBAK-VBELN
            VERKAUFSORGANISATION     = VBAK-VKORG
            VERTRIEBSWEG             = VBAK-VTWEG
            SPARTE                   = VBAK-SPART
            ALLE_PARTNER_VORSCHLAGEN = CHARX
            KNREF_NACHLESEN          = CHARX
            fiv_hityp_pr             = vbak-hityp_pr
            KOPIEREN                 = CHARX
            FIF_VBTYP                = VBAK-VBTYP
            no_dialog                = da_no_dialog
       TABLES
            TABELLE_XVBPA            = XVBPA
            VBUV_TAB                 = XVBUV.

   sort xvbpa by VBELN POSNR PARVW.

* 2. xvbpa korrigieren, da obiger FB falsche UPDKZ liefert             *
  if call_function = charx.
     loop at xvbpa where posnr = us_posnr and
                         updkz eq chari.
          read table temp_xvbpa with key vbeln = xvbpa-vbeln
                                         posnr = xvbpa-posnr
                                         parvw = xvbpa-parvw.
          if sy-subrc = 0.
             xvbpa-updkz = temp_xvbpa-updkz.
             modify xvbpa.
          endif.
     endloop.
     refresh temp_xvbpa. clear temp_xvbpa.
  endif.

  LOOP AT XVBPA WHERE ADRDA CA 'BCEF' AND
                      UPDKZ NE 'D' AND
                      POSNR EQ US_POSNR.


      PERFORM SADR_SELECT USING XVBPA-ADRNR
*#MOSbegin----------------------------------rearrange address management
                                XVBPA-ADRNP
                                XVBPA-ADRDA.
*#MOSend------------------------------------rearrange address management
      IF XVBADR-NAME1 NE ' '.
        XVBPA-NAME1 = XVBADR-NAME1. MODIFY XVBPA.
      ENDIF.
      IF XVBADR-LAND1 NE ' '.
        XVBPA-LAND1 = XVBADR-LAND1. MODIFY XVBPA.
      ENDIF.
      IF XVBADR-SPRAS NE ' '.
        XVBPA-SPRAS = XVBADR-SPRAS. MODIFY XVBPA.
      ENDIF.
      IF XVBADR-LZONE NE ' '.
        XVBPA-LZONE = XVBADR-LZONE. MODIFY XVBPA.
      ENDIF.
      PERFORM XVBUV_LOESCH_VOR_PRUEFEN_VBPA(SAPFV45F)
                          USING XVBPA-POSNR XVBPA-PARVW.
      CALL FUNCTION 'RV_CHECK_DOCUMENT_INPUT'
           EXPORTING
                FEHGR     = XVBPA-FEHGR
                VBXX_WA   = XVBPA
                TBNAM     = 'VBPA      '
           TABLES
                VBUV_TAB  = XVBUV
                VBUV_LAST = HVBUV.


  ENDLOOP.

ENDFORM.