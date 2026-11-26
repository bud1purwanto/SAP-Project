*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_AUGRTAB_LFGRP                                *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KORR_AUGRTAB_LFGRP
*&---------------------------------------------------------------------*
*       Aufsummieren der Liefergruppen-Positionen
*
*       Summiert die Einträge der aupstab in der augrtab auf
*
*----------------------------------------------------------------------*
FORM korr_augrtab_lfgrp TABLES aupstab TYPE vlkor_aupstab
                               augrtab TYPE vlkor_augrtab.

  FIELD-SYMBOLS: <ls_xlips>     LIKE LINE OF xlips,               "AIP
                 <ls_augrtab>   LIKE LINE OF augrtab,             "AIP
                 <ls_xlips_ref> LIKE LINE OF xlips_ref.           "AIP


  DATA: lf_uepvw TYPE uepvw.

* loop at aupstab where grkor > 0 or kits are involved.
* SPE OUTB collect kits and del. groups in augrtab
* all items of a kit have to be part of the (same) del. group, if any
  LOOP AT aupstab.
    MOVE-CORRESPONDING aupstab TO augrtab.
    CLEAR: augrtab-uepos, augrtab-uepvw.

*   substruc. count as delivery group, clear spe_struc to collect GRKOR
    IF NOT aupstab-grkor IS INITIAL.
      CLEAR augrtab-spe_struc.
    ENDIF.

    COLLECT augrtab.
  ENDLOOP.

* ----- begin of AIP

* we have to match the information of xlips_ref into augrtab
  LOOP AT augrtab ASSIGNING <ls_augrtab>.

    IF <ls_augrtab>-grkor IS NOT INITIAL.
      LOOP AT xlips ASSIGNING <ls_xlips>
                    WHERE vgbel =  <ls_augrtab>-vbeln
                    AND   grkor =  <ls_augrtab>-grkor
                    AND   updkz <> updkz_delete.
        EXIT.
      ENDLOOP.
    ELSE.
      LOOP AT xlips ASSIGNING <ls_xlips>
                    WHERE vgbel     =  <ls_augrtab>-vbeln
                    AND   spe_struc =  <ls_augrtab>-spe_struc
                    AND   updkz     <> updkz_delete.
        EXIT.
      ENDLOOP.
    ENDIF.

    CHECK sy-subrc = 0.
    CHECK <ls_xlips>-vgsys IS NOT INITIAL.

    READ TABLE xlips_ref ASSIGNING <ls_xlips_ref>
                         WITH TABLE KEY handle = <ls_xlips>-handle.
    CHECK sy-subrc = 0.  "more tolerance towards inconsistent data

*   SPE kit, if part of a delivery group, it is checked as those!
    IF <ls_augrtab>-grkor > 0.
      <ls_augrtab>-anzaup = <ls_xlips_ref>-anz_pos_grkor.
    ELSEIF <ls_augrtab>-spe_struc > 0.
      <ls_augrtab>-anzaup = <ls_xlips_ref>-spe_anz_pos_stru.
    ENDIF.

  ENDLOOP.

* ----- end   of AIP



ENDFORM.                               " KORR_AUGRTAB_LFGRP