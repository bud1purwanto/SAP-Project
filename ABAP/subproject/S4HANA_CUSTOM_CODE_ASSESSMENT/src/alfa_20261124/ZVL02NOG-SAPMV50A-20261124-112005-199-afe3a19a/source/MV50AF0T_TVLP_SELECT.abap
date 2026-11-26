*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVLP_SELECT                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVLP_SELECT                                              *
*---------------------------------------------------------------------*
*       Lieferpositionstypentabelle mit Texttabelle lesen             *
*---------------------------------------------------------------------*
FORM tvlp_select USING tl_pstyv LIKE tvlp-pstyv
                       tl_subrc LIKE sy-subrc.

  tl_subrc = 0.
  CHECK: tl_pstyv NE tvlp-pstyv.

  SELECT SINGLE * FROM tvlp WHERE pstyv EQ tl_pstyv.

  IF sy-subrc NE 0.
    CLEAR tvlp.
    tl_subrc = sy-subrc.
    PERFORM message_handling(sapmv50a) USING cvbap-posnr
                                             '324'
                                             'E'
                                             'VL'
                                             tl_pstyv
                                             space
                                             space
                                             space.
    EXIT.                                                   "wbr 46c
  ENDIF.


  SELECT SINGLE * FROM tvapt WHERE spras EQ sy-langu
                               AND pstyv EQ tl_pstyv.

  IF sy-subrc NE 0.
    tl_subrc = 0.
    CLEAR tvapt.
  ENDIF.

ENDFORM.                    "TVLP_SELECT
*eject