*&---------------------------------------------------------------------*
*&  Include           /SPE/MV50AF01                                    *
*&---------------------------------------------------------------------*
FORM spe_message_handling USING if_vbeln TYPE vbap-vbeln
                                if_posnr TYPE vbap-posnr
                                if_msgno TYPE sy-msgno
                                if_msgty TYPE sy-msgty
                                if_msgid TYPE sy-msgid
                                if_msgv1 TYPE clike
                                if_msgv2 TYPE clike
                                if_msgv3 TYPE clike
                                if_msgv4 TYPE clike.

  DATA: l_vbeln type vbak-vbeln.

* Save and set VBELN
  l_vbeln = cvbak-vbeln.
  cvbak-vbeln = if_vbeln.

* Call message handling
  PERFORM message_handling USING if_posnr
                                 if_msgno
                                 if_msgty
                                 if_msgid
                                 if_msgv1
                                 if_msgv2
                                 if_msgv3
                                 if_msgv4.

* Restore VBELN
  cvbak-vbeln = l_vbeln.

ENDFORM.                    "spe_message_handling