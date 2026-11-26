*----------------------------------------------------------------------*
*   INCLUDE MV45AO0M_MAT_GRP_ANZEIG_SET                                *
*----------------------------------------------------------------------*

MODULE MAT_GRP_ANZEIG_SET OUTPUT.

  DATA: DA_WA LIKE LINE OF TCTRL_MAT_GRP_ANZEIG-COLS.

  LOOP AT TCTRL_MAT_GRP_ANZEIG-COLS INTO DA_WA.
    CASE DA_WA-SCREEN-GROUP3.
      WHEN 'MBN'.
        IF TVAK-ERMAT NE CHARA.
          DA_WA-INVISIBLE = 1.
        ENDIF.
      WHEN 'MAT'.
        IF TVAK-ERMAT EQ CHARA.
          DA_WA-INVISIBLE = 1.
        ENDIF.
    ENDCASE.
    MODIFY TCTRL_MAT_GRP_ANZEIG-COLS FROM DA_WA.
  ENDLOOP.

ENDMODULE.                             " MAT_GRP_ANZEIG_SET  OUTPUT























