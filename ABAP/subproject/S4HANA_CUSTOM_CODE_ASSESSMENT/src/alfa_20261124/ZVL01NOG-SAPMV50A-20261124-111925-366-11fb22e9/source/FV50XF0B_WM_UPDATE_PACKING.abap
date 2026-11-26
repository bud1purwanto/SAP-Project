*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_WM_UPDATE_PACKING                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  WM_UPDATE_PACKING
*&---------------------------------------------------------------------*
*     falls HUs geändert wurden die auf Lagereinheiten verweisen,
*     muß das WM upgedated werden
*.... if HUs has been changed with WM relevant INFO, WM has to be
*     updated
*----------------------------------------------------------------------*
FORM WM_UPDATE_PACKING.
  DATA: LT_REPACK TYPE VSEP_T_REPACK, LT_BESTAND TYPE VSEP_T_VEPOMM.
  DATA: LS_HU_MM TYPE HUM_MM_KOPFDATEN.
        DATA: LS_REPACK TYPE LTAP_REPA, LT_REP TYPE VSEP_T_REPACK,
              LS_T320 TYPE T320, LF_WERKS TYPE WERKS_D,
              LF_LGORT TYPE LGORT_D, LF_LGNUM TYPE LGNUM.

  CALL FUNCTION 'HU_DETERMINE_CHANGED_QUANTITY'
           IMPORTING
                ES_HUM_MM  =  LS_HU_MM
                ET_REPACK  =  LT_REPACK
                ET_BESTAND =  LT_BESTAND
           EXCEPTIONS
                OTHERS = 99.
  IF NOT SY-SUBRC IS INITIAL.
    MESSAGE ID SY-MSGID TYPE 'A' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF NOT LT_REPACK IS INITIAL.
    SORT LT_REPACK BY WERKS LGORT.
    LOOP AT LT_REPACK INTO LS_REPACK.
      IF ( LS_REPACK-WERKS NE LF_WERKS OR
           LS_REPACK-LGORT NE LF_LGORT ).
        CALL FUNCTION 'L_LGORT_LGNUM_CHECK'
                 EXPORTING
                      I_WERKS  = LS_REPACK-WERKS
                      I_LGORT  = LS_REPACK-LGORT
                 IMPORTING
                      E_T320   = LS_T320
                 EXCEPTIONS
                      LGNUM_DATA_DOES_NOT_EXIST = 01
                      OTHERS                    = 99.
        IF LF_LGNUM NE LS_T320-LGNUM AND LF_LGNUM NE SPACE.
          IF LT_REP IS INITIAL.
            APPEND LS_REPACK TO LT_REP.
            CONTINUE.
          ENDIF.
          CALL FUNCTION 'L_TO_REPACK'
                   EXPORTING
                        I_LGNUM     = LF_LGNUM
*                   importing
*                        e_tanum     = lf_tanum
                   TABLES
                        T_LTAP_REPA = LT_REP
                   EXCEPTIONS
                        NO_ITEM_CREATED = 01.
          IF NOT SY-SUBRC IS INITIAL.
            MESSAGE ID  SY-MSGID TYPE 'A' NUMBER SY-MSGNO
                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            CLEAR: PACKDATEN_VERBUCHEN.
            EXIT.
          ENDIF.
          REFRESH: LT_REP.
        ELSE.
          APPEND LS_REPACK TO LT_REP.
          LF_LGNUM = LS_T320-LGNUM.
          LF_WERKS = LS_REPACK-WERKS.
          LF_LGORT = LS_REPACK-LGORT.
        ENDIF.
      ELSE.
        APPEND LS_REPACK TO LT_REP.
        LF_LGORT = LS_REPACK-LGORT.
        LF_WERKS = LS_REPACK-WERKS.
      ENDIF.
    ENDLOOP.
    IF NOT LT_REP IS INITIAL.
      CALL FUNCTION 'L_TO_REPACK'
               EXPORTING
                    I_LGNUM     = LF_LGNUM
*                 importing
*                     e_tanum     = lf_tanum
               TABLES
                    T_LTAP_REPA = LT_REP
               EXCEPTIONS
                    NO_ITEM_CREATED = 01.
      IF NOT SY-SUBRC IS INITIAL.
        MESSAGE ID  SY-MSGID TYPE 'A' NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      REFRESH: LT_REP.
    ENDIF.
  ENDIF.
ENDFORM.                    " WM_UPDATE_PACKING