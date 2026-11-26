*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_KGGP                                        *
*----------------------------------------------------------------------*
FORM FCODE_KGGP.

CALL FUNCTION 'SD_EHS_HAZMAT_CHECK'
     EXPORTING
          IF_STARTMODUS                  = 8
     TABLES
         IT_VBAP                         = XVBAP
          IT_VBEP                        = XVBEP
          IT_VBPA                        = XVBPA
* Begin Correction 23.05.2007 1057243 ***********************************
          IT_VBUP                        = XVBUP
* End Correction 23.05.2007 1057243 *************************************
     CHANGING
          CS_VBAK                        = VBAK
          CF_DATALOSS                    = R185D-DATALOSS
          C_GGP_STATUS                   = RV45A_UV-VGGP
     EXCEPTIONS
          PRUEFUNG_NICHT_AKTIV           = 1
          KEINE_GG_RELEVANTEN_POSITIONEN = 2
          gg_vollstaendig_sichern        = 3
          gg_unvollstaendig_sichern      = 4
          gg_sichern_verbieten           = 5
          OTHERS                         = 6.

  case sy-subrc.

   when 2.
*  message bringen: "Im Beleg sind keine gefahrgutrelevanten Positionen
*                    enthalten"
     message i202(CB01).
   when 3.
*    ch_subrc = 0.
   when 4.
*    ch_subrc = 1.
   when 5.
*    ch_subrc = 2.

endcase.

ENDFORM.