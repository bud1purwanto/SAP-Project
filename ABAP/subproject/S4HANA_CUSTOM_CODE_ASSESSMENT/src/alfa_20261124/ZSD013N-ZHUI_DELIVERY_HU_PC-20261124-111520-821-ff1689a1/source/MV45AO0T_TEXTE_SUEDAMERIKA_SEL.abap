*---------------------------------------------------------------------*
*       MODULE TEXTE_SUEDAMERIKA_SELECT                               *
*---------------------------------------------------------------------*
*       Texte zu den Suedamerika-Feldern lesen                        *
*---------------------------------------------------------------------*
MODULE texte_suedamerika_select OUTPUT.
  PERFORM j_1afitpt_select  USING vbkd-j_1afitp
                                  sy-subrc.
  PERFORM j_1atxrelt_select USING vbkd-j_1atxrel
                                  sy-subrc.
  PERFORM tvko_select       USING vbak-vkorg
                                  space
                                  sy-subrc.
  PERFORM j_1adtypt_select  USING t001-bukrs
                                  vbkd-j_1adtyp
                                  sy-subrc.
  PERFORM j_1btxsdct_select USING vbap-j_1btxsdc
                                  sy-subrc.
  PERFORM j_1bagt_select    USING vbap-j_1bcfop
                                  sy-subrc.
  PERFORM j_1arfzt_select   USING vbkd-j_1arfz
                                  sy-subrc.
  PERFORM j_1agicdu_select  USING t001-land1
                                  vbkd-j_1agicd
                                  sy-subrc.
  PERFORM t005u_select      USING t001-land1
                                  vbkd-j_1aregio
                                  sy-subrc.
  PERFORM j_1batl1t_select  USING vbap-j_1btaxlw1
                                  sy-subrc.
  PERFORM j_1batl2t_select  USING vbap-j_1btaxlw2
                                  sy-subrc.
  PERFORM j_1batl3t_select  USING vbap-j_1btaxlw3
                                  sy-subrc.
  PERFORM j_1batl4t_select  USING vbap-j_1btaxlw4
                                sy-subrc.
  PERFORM j_1batl5t_select  USING vbap-j_1btaxlw5
                                sy-subrc.
  PERFORM j_1ainft21_select USING vbkd-j_1aindxp
                                  sy-subrc.

ENDMODULE.                    "TEXTE_SUEDAMERIKA_SELECT OUTPUT