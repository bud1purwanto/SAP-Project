*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TCTRL_MAT_GRP_ANZEIG_                             *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  TCTRL_MAT_GRP_ANZEIG_PAGING
*&---------------------------------------------------------------------*
*       Blaettern
*----------------------------------------------------------------------*
FORM TCTRL_MAT_GRP_ANZEIG_PAGING USING    VALUE(P_0083).
  DATA: I TYPE I,
        J TYPE I.

  CASE FCODE.
    WHEN 'P--'. TCTRL_MAT_GRP_ANZEIG-TOP_LINE = 1.
    WHEN 'P-'.
      TCTRL_MAT_GRP_ANZEIG-TOP_LINE =
       TCTRL_MAT_GRP_ANZEIG-TOP_LINE -
       TCTRL_MAT_GRP_ANZEIG_LINCNT.
      IF TCTRL_MAT_GRP_ANZEIG-TOP_LINE LE 0.
        TCTRL_MAT_GRP_ANZEIG-TOP_LINE = 1.
      ENDIF.
    WHEN 'P+'.
      I = TCTRL_MAT_GRP_ANZEIG-TOP_LINE +
           TCTRL_MAT_GRP_ANZEIG_LINCNT.
      J = TCTRL_MAT_GRP_ANZEIG-LINES -
           TCTRL_MAT_GRP_ANZEIG_LINCNT + 1.
      IF J LE 0.
        J = 1.
      ENDIF.
      IF I LE J.
        TCTRL_MAT_GRP_ANZEIG-TOP_LINE = I.
      ELSE.
        TCTRL_MAT_GRP_ANZEIG-TOP_LINE = J.
      ENDIF.
    WHEN 'P++'.
      TCTRL_MAT_GRP_ANZEIG-TOP_LINE =
       TCTRL_MAT_GRP_ANZEIG-LINES -
       TCTRL_MAT_GRP_ANZEIG_LINCNT + 1.
      IF TCTRL_MAT_GRP_ANZEIG-TOP_LINE LE 0.
        TCTRL_MAT_GRP_ANZEIG-TOP_LINE = 1.
      ENDIF.
  ENDCASE.

ENDFORM.                               " TCTRL_MAT_GRP_ANZEIG_PAGING