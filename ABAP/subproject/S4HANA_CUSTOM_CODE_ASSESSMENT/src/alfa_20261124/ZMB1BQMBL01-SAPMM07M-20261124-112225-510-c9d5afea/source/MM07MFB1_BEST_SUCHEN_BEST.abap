*eject
*----------------------------------------------------------------------*
*               FORM BEST_SUCHEN_BEST                                  *
*----------------------------------------------------------------------*
*    Bestellungen suchen über Bestellkriterien                         *
*----------------------------------------------------------------------*
FORM best_suchen_best.
  IF am07m-matnv IS INITIAL.
    IF NOT am07m-lifnr IS INITIAL.
      SUBMIT rm06el00 AND RETURN WITH el_lifnr INCL am07m-lifnr
                                 WITH s_werks  IN   rwerks
                                 WITH s_pstyp  IN   rpstyp
                                 WITH s_eindt  IN   reindt
                                 WITH selpa    INCL t156-selpa
                                 WITH s_idnlf  IN   ridnlf
                                 WITH s_ean11  IN   rean11.
    ELSE.
      IF NOT rm07m-ean11 IS INITIAL.
        REFRESH rmatnv.
        REFRESH xmat1n.
        SELECT * FROM m_mat1n INTO TABLE xmat1n
                              WHERE ean11 = rm07m-ean11
                              AND   spras = sy-langu.
        CASE sy-dbcnt.
          WHEN 0.
            MESSAGE e839.
          WHEN OTHERS.
            LOOP AT xmat1n.
              rmatnv-low    = xmat1n-matnr.
              rmatnv-sign   = 'I'.
              rmatnv-option = 'EQ'.
              APPEND rmatnv.
            ENDLOOP.
            SUBMIT rm06em00 AND RETURN WITH em_matnr  IN rmatnv
                               WITH  s_lifnr  IN   rlifnr
                               WITH  s_reswk  IN   rreswk
                               WITH  em_werks IN   rwerks
                               WITH  selpa    INCL t156-selpa
                               WITH  s_pstyp  IN   rpstyp
                               WITH  s_eindt  IN   reindt
                               WITH  s_idnlf  IN   ridnlf
                               WITH  s_ean11  IN   rean11.
        ENDCASE.
      ELSE.
        SUBMIT rm06ew00 AND RETURN WITH ew_reswk IN   rreswk
                                   WITH s_werks  IN   rwerks
                                   WITH s_pstyp  IN   rpstyp
                                   WITH s_eindt  IN   reindt     "357116
                                   WITH selpa    INCL t156-selpa.
      ENDIF.
    ENDIF.
  ELSE.
    REFRESH rmatnv.
    rmatnv-low    = am07m-matnv.
    rmatnv-sign   = 'I'.
    rmatnv-option = 'EQ'.
    APPEND rmatnv.
    IF pstyp EQ u.
      CLEAR rwerks.
      REFRESH rwerks.
    ENDIF.
    IF t156-kzbwa NE kzbwa-02.
* PFAFFP: begin: Umlagerbestellung in einem Schritt
*     IF T156-KZBWA = KZBWA-01.
      IF t156-kzbwa = kzbwa-01 OR t156-kzbwa = kzbwa-05.
* end
        CLEAR rwerks.
        REFRESH rwerks.
      ENDIF.
      SUBMIT rm06em00 AND RETURN WITH em_matnr  IN   rmatnv
                                 WITH  s_lifnr  IN   rlifnr
                                 WITH  em_werks IN   rwerks
                                 WITH  s_reswk  IN   rreswk
                                 WITH  selpa    INCL t156-selpa
                                 WITH  s_pstyp  IN   rpstyp
                                 WITH  s_eindt  IN   reindt
                                 WITH  s_idnlf  IN   ridnlf
                                 WITH  s_ean11  IN   rean11.
    ELSE.
      SUBMIT rm07lb00 AND RETURN WITH matnr  =   am07m-matnv
                                 WITH werks IN   rreswk.

    ENDIF.
  ENDIF.
  IMPORT wueb-calkz wueb-nrcfd wueb FROM MEMORY ID 'WUEB'.

ENDFORM.