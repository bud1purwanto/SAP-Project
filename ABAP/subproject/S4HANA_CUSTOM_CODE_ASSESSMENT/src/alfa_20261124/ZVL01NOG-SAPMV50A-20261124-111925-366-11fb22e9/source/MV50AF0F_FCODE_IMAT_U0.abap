***INCLUDE MV50AF0F_FCODE_IMAT_U0 .
*---------------------------------------------------------------------*
*       FORM FCODE_IMAT_U0                                            *
*---------------------------------------------------------------------*
*       Anzeige Material vom Übersichtsbild aus                       *
*---------------------------------------------------------------------*
FORM FCODE_IMAT_U0.


  PERFORM XLIPS_DETAIL(SAPFV50P).
* Wenn keine Position selektiert wurde, sitzt Fcode_gleiche_Seite
  IF FCODE NE FCODE_GLEICHE_SEITE.
    GET PARAMETER ID 'BST' FIELD MMBEVER.                  "v_n_1101485
    SET PARAMETER ID 'VNR' FIELD MMBEVER.
    SET PARAMETER ID 'MAT' FIELD LIPS-MATNR.
    SET PARAMETER ID 'WRK' FIELD LIPS-WERKS.
    IF NOT LIPS-LGORT IS INITIAL.
      SET PARAMETER ID 'LAG' FIELD LIPS-LGORT.
    ENDIF.
    IF NOT LIPS-CHARG IS INITIAL.
      SET PARAMETER ID 'CHA' FIELD LIPS-CHARG.
    ENDIF.                                                 "^_n_1101485
  ENDIF.

ENDFORM.