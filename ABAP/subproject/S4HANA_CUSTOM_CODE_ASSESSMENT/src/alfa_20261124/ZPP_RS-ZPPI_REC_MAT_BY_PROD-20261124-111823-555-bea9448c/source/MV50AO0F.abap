************************************************************************
*                                                                      *
* PBO Module Versand                                                   *
*     Module alphabetisch geordnet; hier mit "F" beginnend             *
*
* note 36970 ALRK078689 Performance of decentralized shipping
************************************************************************

*---------------------------------------------------------------------*
*       MODULE FELDAUSWAHL OUTPUT                                     *
*---------------------------------------------------------------------*
*       Aufruf der Feldauswahl                                        *
*---------------------------------------------------------------------*
MODULE feldauswahl OUTPUT.

  PERFORM feldauswahl.

ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE FELDAUSWAHL_DOCUBATCH_TC OUTPUT                        *
*---------------------------------------------------------------------*
*       Aufruf der Feldauswahl                                        *
*---------------------------------------------------------------------*
MODULE feldauswahl_docubatch_tc OUTPUT.

  PERFORM feldauswahl_docubatch_tc.

ENDMODULE.                    "FELDAUSWAHL_DOCUBATCH_TC OUTPUT

*&---------------------------------------------------------------------*
*&      Module  UC_F1_FROM_SUBSCREEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE uc_f1_from_subscreen INPUT.

  PERFORM uc_f1_from_subscreen(sapfv50u).

ENDMODULE.                             " UC_F1_FROM_SUBSCREEN  INPUT

*&---------------------------------------------------------------------*
*&      Module  FOREIGN_TRADE_HEAD_PREPARE  OUTPUT
*&---------------------------------------------------------------------*
MODULE foreign_trade_head_prepare OUTPUT.

  PERFORM foreign_trade_head_prepare TABLES xlips
                                     USING  fcode
                                            t180-trtyp
                                            tvst-aland
                                            likp-vbtyp
                                            likp-exnum
                                            likp-lifnr
                                            vbuk-fkstk
                                            kuwev-kunnr
                                            kuwev-land1
                                            kuwev-name1.

ENDMODULE.                 " FOREIGN_TRADE_HEAD_PREPARE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FOREIGN_TRADE_ITEM_PREPARE  OUTPUT
*&---------------------------------------------------------------------*
MODULE foreign_trade_item_prepare OUTPUT.

  PERFORM foreign_trade_item_prepare USING  fcode
                                            t180-trtyp
                                            tvst-aland
                                            likp-vbtyp
                                            kuwev-land1
                                            likp-exnum
                                            lips-posnr
                                            lips-werks
                                            lips-matnr
                                            lips-arktx
                                            lips-charg
                                            xvbup-fksta.

ENDMODULE.                 " FOREIGN_TRADE_ITEM_PREPARE  OUTPUT
ENHANCEMENT-POINT MV50AO0F_01 SPOTS ES_SAPMV50A STATIC .