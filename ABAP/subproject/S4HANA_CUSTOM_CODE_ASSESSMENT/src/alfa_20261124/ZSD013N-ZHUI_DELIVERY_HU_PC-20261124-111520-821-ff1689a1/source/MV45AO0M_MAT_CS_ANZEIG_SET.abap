*----------------------------------------------------------------------*
*   INCLUDE MV45AO0M_MAT_CS_ANZEIG_SET                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MAT_CS_ANZEIG_SET  OUTPUT
*&---------------------------------------------------------------------*
MODULE MAT_CS_ANZEIG_SET OUTPUT.

  DATA: WA LIKE LINE OF TCTRL_MAT_CS_ANZEIG-COLS.

  LOOP AT TCTRL_MAT_CS_ANZEIG-COLS INTO WA.
    CASE WA-SCREEN-GROUP3.
      WHEN 'PRS'.
        IF TCSP-KALSM_PR IS INITIAL.
          WA-INVISIBLE = 1.
        ENDIF.
      WHEN 'MVF'.
        IF TCSP-CS_KZATP IS INITIAL.
          WA-INVISIBLE = 1.
        ENDIF.
      WHEN 'MBN'.
        IF TVAK-ERMAT NE CHARA.
          WA-INVISIBLE = 1.
        ENDIF.
    ENDCASE.
    MODIFY TCTRL_MAT_CS_ANZEIG-COLS FROM WA.
  ENDLOOP.

ENDMODULE.                             " MAT_CS_ANZEIG_SET  OUTPUT