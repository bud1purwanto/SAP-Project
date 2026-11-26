*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PRODUCT_SELECTION_SET                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PRODUCT_SELECTION_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRODUCT_SELECTION_SET.

*     DATA: XLIPS_PS LIKE XLIPS OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF XLIPS_PS OCCURS 0 ,
                 VBELN        LIKE LIPS-VBELN,
                 POSNR        LIKE LIPS-POSNR,
                 VGBEL        LIKE LIPS-VGBEL,
                 VGPOS        LIKE LIPS-VGPOS,
                 LGMNG        LIKE LIPS-LGMNG,
                 LGMNG_FLO    LIKE LIPS-LGMNG,
                 LFIMG        LIKE LIPS-LFIMG,                   "#&
                 LFIMG_FLO    LIKE LIPS-LFIMG,                   "#&
                 KCMENG       LIKE LIPS-KCMENG,
                 KCMENG_FLO   LIKE LIPS-KCMENG,
                 KCMENGVME    LIKE LIPS-KCMENGVME,
                 KCMENGVMEF   LIKE LIPS-KCMENGVME,
                 KZFME        LIKE LIPS-KZFME,
                 UEPVW        LIKE LIPS-UEPVW,
                 UEPOS        LIKE LIPS-UEPOS,
                 PROSA        LIKE LIPS-PROSA,
*                    MAIN_MISSING,
                 UPDKZ        LIKE XLIPS-UPDKZ,
        END   OF XLIPS_PS.

  DATA: LS_XLIPS    LIKE XLIPS,
        LS_XLIPS_PS LIKE XLIPS_PS.

* Includieren der Datendeklaration für die ATP Schnittstelle
  INCLUDE shp_atp_intdata.


  LOOP AT XLIPS INTO LS_XLIPS
                              WHERE VBELN EQ LIKP-VBELN AND
                                    UPDKZ NE UPDKZ_DELETE AND (
                                    UEPVW CA PRODUKTSELEKTION OR
                                    PROSA CA GC_PROSA-MAIN ).
    MOVE-CORRESPONDING LS_XLIPS TO XLIPS_PS.
    COLLECT XLIPS_PS.
  ENDLOOP.
  CHECK SY-SUBRC EQ 0.

  DATA: SUMMELAGERM     TYPE F,
        SUMMELAGERM_VME TYPE F,
        DA_TABIX LIKE SY-TABIX,
        LS_VBAP  LIKE XVBAP,
        LS_VBUP  LIKE XVBUP,
        LF_SUBRC LIKE SY-SUBRC,
        LF_RCODE LIKE SY-SUBRC,
        LF_MSGTY LIKE SY-MSGTY.

  DATA ATP_TYPE TYPE LES_ATP_TYPE.
  CALL FUNCTION 'LE_ATP_GET_VERSION'
        IMPORTING
            ATP_TYPE         = ATP_TYPE.

*-----search for missing main items
  LOOP AT XLIPS_PS INTO LS_XLIPS_PS
                              WHERE UEPVW CA PRODUKTSELEKTION.

    READ TABLE XLIPS_PS WITH KEY VBELN = LS_XLIPS_PS-VBELN
                                 POSNR = LS_XLIPS_PS-UEPOS.

    CHECK SY-SUBRC NE 0 OR
          LS_XLIPS_PS-UEPOS IS INITIAL OR
          LS_XLIPS_PS-UEPOS EQ LS_XLIPS_PS-POSNR.

*          XLIPS_PS-MAIN_MISSING = 'X'.
*          MODIFY XLIPS_PS TRANSPORTING MAIN_MISSING.

*----------was the main item expected to be delivered ?
*----------( c tables are always read subsidiary for x tables,
*----------  since this seems to be the only way to cover all cases )
    CLEAR: LF_SUBRC, LS_VBAP, LS_VBUP.
*----------get the main item number
    READ TABLE XVBAP INTO LS_VBAP
                     WITH KEY VBELN = LS_XLIPS_PS-VGBEL
                              POSNR = LS_XLIPS_PS-VGPOS
         TRANSPORTING UEPOS.
    IF SY-SUBRC NE 0.
      READ TABLE CVBAP INTO LS_VBAP
                    WITH KEY VBELN = LS_XLIPS_PS-VGBEL
                             POSNR = LS_XLIPS_PS-VGPOS
        TRANSPORTING UEPOS.
      ADD SY-SUBRC TO LF_SUBRC.
    ENDIF.
*----------to be delivered ?
    IF LF_SUBRC EQ 0.
      READ TABLE XVBUP INTO LS_VBUP
                       WITH KEY VBELN =  LS_XLIPS_PS-VGBEL
                                POSNR =  LS_VBAP-UEPOS
                 BINARY SEARCH
                 TRANSPORTING LFSTA.
    ENDIF.
    IF LS_VBUP-LFSTA EQ SPACE AND                           "v_n_1037684
       LF_SUBRC      EQ 0     AND
       SY-SUBRC      EQ 0.
      LOOP AT XLIPS WHERE VBELN EQ LIKP-VBELN AND
                          UPDKZ NE UPDKZ_DELETE AND (
                          POSNR EQ LS_XLIPS_PS-POSNR OR
                          UECHA EQ LS_XLIPS_PS-POSNR ).
        CLEAR XLIPS-UEPVW.
        MODIFY XLIPS INDEX SY-TABIX.
      ENDLOOP.
    ELSEIF LS_VBUP-LFSTA NE SPACE AND
           LF_SUBRC      EQ 0     AND
           SY-SUBRC      EQ 0.                              "^_n_1037684

*----------message
    CVBAK-VBELN = LS_XLIPS_PS-VGBEL.

*           PERFORM MESSAGE_HANDLING USING  LS_XLIPS_PS-VGPOS
*                                       '270'
*                                       'E'
*                                       'VL'
*                                       LS_XLIPS_PS-VGBEL
*                                       LS_XLIPS_PS-VGPOS
*                                       SPACE
*                                       SPACE.
    PERFORM MESSAGE_HANDLING_VARIABEL
                USING
                   LS_XLIPS_PS-VGPOS
                   '270'
                   'E'
                   'VL'
                   LS_XLIPS_PS-VGBEL
                   LS_XLIPS_PS-VGPOS
                   SPACE
                   SPACE
                   GS_MHPAR
                   V50AGL-MSGVS
                CHANGING
                   LF_MSGTY
                   LF_RCODE.

    CHECK LF_MSGTY EQ 'E' .

*---------delete delivery item and all sub items
    LOOP AT XLIPS WHERE VBELN EQ LIKP-VBELN AND
                        UPDKZ NE UPDKZ_DELETE AND (
                        POSNR EQ LS_XLIPS_PS-POSNR OR
                        UECHA EQ LS_XLIPS_PS-POSNR )
                                               .
      DA_TABIX = SY-TABIX.
      REFRESH ILIPS.
      CLEAR: XLIPS-BDART,
             XLIPS-PLART,
             XLIPS-BEDAR_LF.
      LIPS = XLIPS.

      IF ATP_TYPE EQ CHAR0.
        CALL FUNCTION 'RV_REQ_DELETE_BY_NUMBER'
           EXPORTING
                BELEG_ALT = XLIPS-VGBEL
                BELEG_NEU = XLIPS-VBELN
                POS_ALT   = XLIPS-VGPOS
                POS_NEU   = XLIPS-POSNR.
      ELSE.
        CALL FUNCTION 'LE_ATP_RV_REQ_DELETE_BY_NUMBER'
             EXPORTING
                  beleg_alt = XLIPS-VGBEL
                  beleg_neu = XLIPS-VBELN
                  pos_alt   = XLIPS-VGPOS
                  pos_neu   = XLIPS-POSNR.
      ENDIF.

      PERFORM XLIPS_LOESCHEN(SAPFV50P) USING CHARX DA_TABIX.
      MOVE-CORRESPONDING LIKP TO XLIKP .
      IF V50AGL-SAMMELGANG = CHARX.
        MODIFY XLIKP.
      ENDIF.
    ENDLOOP.                           "xlips
    DELETE XLIPS_PS.
    ENDIF.                                                    "n_1037684
  ENDLOOP.                             "xlips_ps

*----update main item quantity in case outcome 'B'
  LOOP AT XLIPS WHERE VBELN EQ LIKP-VBELN AND
                      UPDKZ NE UPDKZ_DELETE AND
                      PROSA EQ CHARC.
    DA_TABIX = SY-TABIX.
    SUMMELAGERM     = 0.
    SUMMELAGERM_VME = 0.
    LOOP AT XLIPS_PS INTO LS_XLIPS_PS WHERE
                  UEPOS EQ XLIPS-POSNR AND
                  UEPVW EQ CHARA.
*-------------------an aleady happened batch determination
*-------------------is taken into account

      SUMMELAGERM = SUMMELAGERM + LS_XLIPS_PS-LGMNG_FLO  +
                                  LS_XLIPS_PS-KCMENG_FLO .

      IF LS_XLIPS_PS-KZFME CA KZFME_WS.
        SUMMELAGERM_VME = SUMMELAGERM_VME       +
                          LS_XLIPS_PS-LFIMG_FLO +          "#&
                          LS_XLIPS_PS-KCMENGVMEF.
      ENDIF.
    ENDLOOP.
*          READ TABLE XLIPS INDEX DA_TABIX.
*---------this is the same main item procedure like we do
*---------when carrying out productselection in delivery,
    XLIPS-KCMENG       = SUMMELAGERM.
    XLIPS-KCMENG_FLO   = SUMMELAGERM.
    XLIPS-KCMENGVME    = SUMMELAGERM_VME.
    XLIPS-KCMENGVMEF   = SUMMELAGERM_VME.
    XLIPS-LGMNG        = 0.
    XLIPS-LGMNG_FLO    = 0.
    PERFORM KORR_MENGE_SETZEN(SAPMV50A) USING DA_TABIX
                                              0.
    IF XLIPS_LOESCHEN_MENGE_0 EQ CHARX AND SUMMELAGERM EQ 0.
      LIPS = XLIPS.                                         "46A
      PERFORM XLIPS_LOESCHEN(SAPFV50P) USING CHARX DA_TABIX.
    else.                                                    "v_n_701297
      if v50agl-sammelgang is initial.    "only for dialog
        move-corresponding xlips to lips.
        perform lips_referenz_lesen(sapfv50p).
        modify xlips transporting ofmng.
      endif.
    ENDIF.                                                   "^_n_701297

    IF ATP_TYPE EQ CHARO.
      PERFORM AVBBD_PROSA_VERRECHNEN(SAPFV50V).
    ELSE.
      PERFORM AVBBD_PROSA_VERRECHNEN_NEU.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " PRODUCT_SELECTION_SET