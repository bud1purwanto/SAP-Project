* @vsa_cd anfang
*&---------------------------------------------------------------------*
*&      Form  LGORT_CD_GET_DISTRIBUTION
*&---------------------------------------------------------------------*
*       text: Aufruf eines FB aus cross-docking, um die Lagerortver-
*             teilung zu bekommen
*----------------------------------------------------------------------*
FORM LGORT_CD_GET_DISTRIBUTION TABLES P_CD_MSEG STRUCTURE MSEG
*                         USING  p_nicht_relevant TYPE c. " P9BK157624
                         USING  p_nicht_relevant TYPE c   " P9BK157624
                         changing rc like sy-subrc.       " P9BK157624
  REFRESH P_CD_MSEG.
  MOVE MSEG TO P_CD_MSEG.
  APPEND P_CD_MSEG.
  CHECK xmigo IS INITIAL.
  CALL FUNCTION 'W_FRM_GR_ASSIGNMENT_SIMULATE'
       EXPORTING
            NO_RELEVANCE  = P_NICHT_RELEVANT
       TABLES
            T_MSEG        = P_CD_MSEG
       EXCEPTIONS
            NOTHING_TO_DO = 1
            OTHERS        = 2.
  rc = sy-subrc.                                          " P9BK157624

ENDFORM.                               " LGORT_CD_GET_DISTRIBUTION