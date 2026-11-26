*&---------------------------------------------------------------------*
*&  Include           ARCH_PREPROC_PRG_STANDARD1
*&---------------------------------------------------------------------*
* Standard 1 for archiving prepr- and postprocessing programs includes:
* - radio button group for 'processing options'
*&---------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK sb1
                          WITH FRAME TITLE sb1_text.        "#EC NEEDED
* test mode parameter
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_pretst TYPE arch_processing_options-preproc_testmode
                    RADIOBUTTON GROUP sb1  DEFAULT 'X'.
SELECTION-SCREEN COMMENT (30) FOR FIELD p_pretst.
SELECTION-SCREEN END OF LINE.

* production mode parameter
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_preprd TYPE arch_processing_options-preproc_prodmode
                    RADIOBUTTON GROUP sb1.
SELECTION-SCREEN COMMENT (30) FOR FIELD p_preprd.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK sb1.


INCLUDE ARCH_PREPROC_RELOAD_PRG_FORMS.