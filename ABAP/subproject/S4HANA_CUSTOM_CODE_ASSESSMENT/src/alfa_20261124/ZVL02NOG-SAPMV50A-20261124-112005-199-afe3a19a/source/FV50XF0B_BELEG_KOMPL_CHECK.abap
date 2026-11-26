***INCLUDE FV50XF0B_BELEG_KOMPL_CHECK .
*---------------------------------------------------------------------*
*       FORM BELEG_KOMPLETTLIEFERUNGSCHECK                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IS_VBELN                                                      *
*---------------------------------------------------------------------*
FORM BELEG_KOMPLETTLIEFERUNGSCHECK USING
                                   IS_VBELN LIKE LIKP-VBELN.

  DATA: BKP_VBELN LIKE LIKP-VBELN.
  DATA: LV_SUBRC LIKE SY-SUBRC.
  DATA: LS_R_AUTLF_DEL LIKE GT_R_AUTLF_DEL.                 "hp_339937

* REFRESH GT_R_AUTLF_DEL.                         "HP_339937/HP_373202
  CLEAR   GT_R_AUTLF_DEL.
  LV_SUBRC = 0.

* Do not perform check in decentral WMS (no order document available)
  CHECK V50AGL-CREATE_DECENTRAL EQ SPACE.
  CHECK XLIKP-VERURSYS EQ SPACE.

  CHECK V50AGL-SPLIT EQ SPACE. "not here: complete delivery check

  CHECK XLIKP-AUTLF NE SPACE.

  READ TABLE XVBUK WITH KEY VBELN = XLIKP-VBELN
                   BINARY SEARCH.
  CHECK XVBUK-WBSTK CA ' A'.

  IF V50AGL-SAMMELGANG = SPACE.
*   VL01 und VL02
    LOOP AT XVBUK WHERE VBTYP CA VBTYP_VERK.
      IF ( XVBUK-LFGSK NE CHARC AND XVBUK-LFSTK NE CHARC ). "INS 31G
        PERFORM FINCHDEL_HANDLING(SAPFV50P) USING
        XLIPS-VBELN '01' 'W' 'VL' '049'
        SPACE SPACE SPACE SPACE GT_FINCHDEL.
*        VBELN PRUEFUNG MSGTY MSGID
*        MSGNO MSGV1 MSGV2 MSGV3 MSGV4 FINCHDEL
*        message w049.
        EXIT.
      ENDIF.
    ENDLOOP.
  ELSE.
*   Sammelgang
*   prüfen ob Vollieferung für einen beteiligten Auftrag verletzt
    LOOP AT CVBLS WHERE VBELN_LIF EQ IS_VBELN.
      VBUKKEY-MANDT = XLIKP-MANDT.
      VBUKKEY-VBELN = CVBLS-VBELN.
      READ TABLE XVBUK WITH KEY VBUKKEY BINARY SEARCH.
      IF SY-SUBRC NE 0.                                   "45A
        EXIT.
      ENDIF.
*    IF XVBUK-LFGSK NE CHARC.                             "DEL 31G
      IF ( XVBUK-LFGSK NE CHARC AND XVBUK-LFSTK NE CHARC ). "INS 31G
*       fill table with delivery items which should be deleted
        Read table cvbak transporting no fields               "hp_339937
                         WITH KEY VBELN = CVBLS-VBELN
                                  AUTLF = CHARX.
        if sy-subrc = 0.
          LS_R_AUTLF_DEL-SIGN   = 'I'.
          LS_R_AUTLF_DEL-OPTION = 'EQ'.
          LS_R_AUTLF_DEL-LOW    = CVBLS-VBELN.
          READ TABLE GT_R_AUTLF_DEL TRANSPORTING NO FIELDS
                              WITH KEY LOW = LS_R_AUTLF_DEL-LOW
                              BINARY SEARCH.
          IF SY-SUBRC GE 4.
            INSERT LS_R_AUTLF_DEL INTO GT_R_AUTLF_DEL
                                index sy-tabix.
          endif.
        endif.
        BKP_VBELN = XVBUK-VBELN.
        LV_SUBRC = 4.
      ENDIF.
      IF TVSHP-KZAUTLF = SPACE.
        LOOP AT CVBLS WHERE VBELN EQ CVBLS-VBELN
                   AND VBELN_LIF NE IS_VBELN.
*         fill table with delivery items which should be deleted
          Read table cvbak transporting no fields   "hp_339937
                           with key vbeln   = cvbls-vbeln
                                    AUTLF = CHARX.
          if sy-subrc = 0.
            LS_R_AUTLF_DEL-SIGN   = 'I'.
            LS_R_AUTLF_DEL-OPTION = 'EQ'.
            LS_R_AUTLF_DEL-LOW    = CVBLS-VBELN.
            READ TABLE GT_R_AUTLF_DEL TRANSPORTING NO FIELDS
                                WITH KEY LOW = LS_R_AUTLF_DEL-LOW
                                BINARY SEARCH.
            IF SY-SUBRC GE 4.
              INSERT LS_R_AUTLF_DEL INTO GT_R_AUTLF_DEL
                                  index sy-tabix.
            endif.
          endif.
          BKP_VBELN = CVBLS-VBELN.
          LV_SUBRC = 8.
        ENDLOOP.
        CHECK LV_SUBRC NE 8.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.