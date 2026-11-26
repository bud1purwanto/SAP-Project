*eject
*---------------------------------------------------------------------*
*       FORM PREFETCH_AUSFUEHREN                                      *
*---------------------------------------------------------------------*
*       Der Materialstamm wird per PREFEETCH gelesen.                 *
*---------------------------------------------------------------------*
FORM PREFETCH_AUSFUEHREN USING I_KZSPR LIKE MTCOM-KZSPR
                               I_KZRFB LIKE MTCOM-KZRFB.

  DATA KZSPR LIKE MTCOM-KZSPR. KZSPR = I_KZSPR.
  DATA KZRFB LIKE MTCOM-KZRFB. KZRFB = I_KZRFB.
  READ TABLE PREFETCH02 INDEX 1.
  IF SY-SUBRC IS INITIAL.
    select single * from tcurm.                            "note 447965
    IF NOT TCURM-MBEQU IS INITIAL.
      IF NOT KZSPR IS INITIAL.
        KZSPR = S.
      ENDIF.
      CLEAR KZRFB.
    ENDIF.
    DATA: KZSPM LIKE MTCOM-KZSPM.
    IF NOT MBVAL IS INITIAL AND XWERT IS INITIAL.
      KZSPM = N.
    ELSE.
      CLEAR KZSPM.
    ENDIF.
    CALL FUNCTION 'MATERIAL_PRE_READ_MBEFU'
         EXPORTING
              KZSPR  = KZSPR
              KZRFB  = KZRFB
              KZSPM  = KZSPM
              XVPER  = SPACE
              XVVPR  = SPACE
              XVJAH  = SPACE
              XVVJA  = SPACE
         TABLES
              IPRE02     = PREFETCH02
              IPRE02_ALL = PREFETCH34.
    READ TABLE PREFETCH01 INDEX 1.
    IF SY-SUBRC IS INITIAL.
      CALL FUNCTION 'MATERIAL_PRE_READ_QMAT'
           EXPORTING
                I_KZRFB     = I_KZRFB
           TABLES
                T_IPRE01TAB = PREFETCH01.
    ENDIF.
  ENDIF.
  READ TABLE PREFETCH03 INDEX 1.
  IF SY-SUBRC IS INITIAL.
    IF TCURM-MBEQU IS INITIAL.
      KZRFB = I_KZRFB.
    ELSE.
      CLEAR KZRFB.
    ENDIF.
    CALL FUNCTION 'MATERIAL_PRE_READ_MAKT'
         EXPORTING
              KZRFB  = KZRFB
         TABLES
              IPRE03 = PREFETCH03.
  ENDIF.

ENDFORM.