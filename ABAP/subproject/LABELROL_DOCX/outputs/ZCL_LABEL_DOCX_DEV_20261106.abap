
*==== ZCL_LABEL_DOCX================CCDEF
*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

*==== ZCL_LABEL_DOCX================CCIMP
*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

*==== ZCL_LABEL_DOCX================CCMAC
*"* use this source file for any macro definitions you need
*"* in the implementation part of the class

*==== ZCL_LABEL_DOCX================CI
PRIVATE SECTION.

  DATA MO_ZIP TYPE REF TO CL_ABAP_ZIP .
  DATA MO_TEMPL_DATA_NC TYPE REF TO IF_IXML_NODE_COLLECTION .
*==== ZCL_LABEL_DOCX================CM001
*&---------------------------------------------------------------------*
*&  Appl. Area :  MM                                                   *
*&  Created by :  Oskar Pra                                            *
*&  Created on :  05 October 2023                                      *
*&---------------------------------------------------------------------*

METHOD CONVERT_DATA_TO_NC.

  DATA LV_DATA_XML_STR TYPE STRING.
  CALL TRANSFORMATION ID
  SOURCE DATA = IV_DATA
        RESULT XML LV_DATA_XML_STR.

  DATA
          : LO_IXML TYPE REF TO IF_IXML
          , LO_STREAM_FACTORY TYPE REF TO IF_IXML_STREAM_FACTORY
          , LO_ISTREAM TYPE REF TO IF_IXML_ISTREAM
          , LO_DOCUMENT TYPE REF TO IF_IXML_DOCUMENT
          , LO_PARSER TYPE REF TO IF_IXML_PARSER
          .

  LO_IXML = CL_IXML=>CREATE( ).
  LO_STREAM_FACTORY = LO_IXML->CREATE_STREAM_FACTORY( ).
  LO_ISTREAM = LO_STREAM_FACTORY->CREATE_ISTREAM_CSTRING( LV_DATA_XML_STR ).
  LO_DOCUMENT = LO_IXML->CREATE_DOCUMENT( ).
  LO_PARSER = LO_IXML->CREATE_PARSER(
        STREAM_FACTORY = LO_STREAM_FACTORY
        ISTREAM = LO_ISTREAM
        DOCUMENT = LO_DOCUMENT ).
  LO_PARSER->PARSE( ).
  MO_TEMPL_DATA_NC = LO_DOCUMENT->GET_ELEMENTS_BY_TAG_NAME_NS( NAME = 'DATA' ).

ENDMETHOD.
*==== ZCL_LABEL_DOCX================CM002
*&---------------------------------------------------------------------*
*&  Appl. Area :  MM                                                   *
*&  Created by :  Oskar Pra                                            *
*&  Created on :  05 October 2023                                      *
*&---------------------------------------------------------------------*

METHOD GET_DOCUMENT.

  INCLUDE OLE2INCL .

  DATA
        : LO_DOCX TYPE REF TO ZCL_LABEL_DOCX
        , LV_CONTENT TYPE XSTRING
        , LV_RES_XML_XSTR TYPE XSTRING
        , LV_DOC_XML_XSTR TYPE XSTRING
        , LV_RETCODE TYPE I
        .

  CREATE OBJECT LO_DOCX .
  CREATE OBJECT LO_DOCX->MO_ZIP.

  LO_DOCX->CONVERT_DATA_TO_NC( IV_DATA ).

  LO_DOCX->MO_ZIP->LOAD( IV_TEMPLATE ).

  LO_DOCX->MO_ZIP->GET( EXPORTING  NAME =  LO_DOCX->MC_DOCUMENT
                  IMPORTING CONTENT = LV_CONTENT ).

  LO_DOCX->PROTECT_SPACE(
    EXPORTING
      IV_CONTENT = LV_CONTENT
    RECEIVING
      RV_CONTENT = LV_DOC_XML_XSTR )   .

  CALL TRANSFORMATION ZDOCX_DEL_REPEATED_TEXT
        SOURCE XML LV_DOC_XML_XSTR
        RESULT XML LV_DOC_XML_XSTR.

  CALL TRANSFORMATION ZDOCX_FILL_TEMPLATE
        SOURCE XML LV_DOC_XML_XSTR
        PARAMETERS DATA = LO_DOCX->MO_TEMPL_DATA_NC
        RESULT XML LV_RES_XML_XSTR.

  CALL TRANSFORMATION ZDOCX_DEL_WSDT
    SOURCE XML LV_RES_XML_XSTR
    RESULT XML LV_RES_XML_XSTR.

  LO_DOCX->RESTORE_SPACE(
    EXPORTING
      IV_CONTENT = LV_RES_XML_XSTR
    RECEIVING
      RV_CONTENT = LV_CONTENT )  .

  IF IV_PROTECT IS NOT INITIAL .
    LO_DOCX->PROTECT( ).
  ENDIF.

  LO_DOCX->MO_ZIP->DELETE( NAME = LO_DOCX->MC_DOCUMENT ).
  LO_DOCX->MO_ZIP->ADD( NAME    = LO_DOCX->MC_DOCUMENT
             CONTENT = LV_CONTENT ).

  RV_DOCUMENT = LO_DOCX->MO_ZIP->SAVE( ).

  IF  IV_NO_SAVE IS NOT INITIAL.
    RETURN.
  ENDIF.

  DATA
        : LT_FILE_TAB  TYPE SOLIX_TAB
        , LV_BYTECOUNT TYPE I
        , LV_PATH      TYPE STRING
        .

  LT_FILE_TAB = CL_BCS_CONVERT=>XSTRING_TO_SOLIX( IV_XSTRING  = RV_DOCUMENT ).
  LV_BYTECOUNT = XSTRLEN( RV_DOCUMENT ).

  IF IV_PATH IS INITIAL.
    IF IV_ON_DESKTOP IS NOT INITIAL.
      CL_GUI_FRONTEND_SERVICES=>GET_DESKTOP_DIRECTORY( CHANGING DESKTOP_DIRECTORY = LV_PATH ).
    ELSE.
      CL_GUI_FRONTEND_SERVICES=>GET_TEMP_DIRECTORY( CHANGING TEMP_DIR = LV_PATH ).
    ENDIF.
    CL_GUI_CFW=>FLUSH( ).
  ELSE.
    LV_PATH = IV_PATH.
  ENDIF.

  CONCATENATE LV_PATH '\' IV_FOLDER '\'  IV_FILE_NAME  INTO LV_PATH.

  CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD( EXPORTING BIN_FILESIZE = LV_BYTECOUNT
                                                    FILENAME     = LV_PATH
                                                    FILETYPE     = 'BIN'
                                           CHANGING DATA_TAB     = LT_FILE_TAB
                                                   EXCEPTIONS
                                                    OTHERS       = 1
      ).

  IF SY-SUBRC NE 0.
    DATA: V_MSG(50).
    CONCATENATE 'File' IV_FILE_NAME 'still in use, please close first!' INTO V_MSG SEPARATED BY SPACE.
    MESSAGE V_MSG TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
*    RETURN.
  ENDIF.


* Prinitng Using OLE2 Object *

  IF IV_NO_EXECUTE IS INITIAL.
    DATA
          : V_WORD TYPE OLE2_OBJECT
          , V_DOCUMENTS TYPE OLE2_OBJECT
          , V_NEWDOC TYPE OLE2_OBJECT
          , V_ACTDOC TYPE OLE2_OBJECT
          .

    CREATE OBJECT V_WORD 'Word.Application'.
    SET PROPERTY OF V_WORD 'Visible' = 0.

    CALL METHOD OF
        V_WORD
        'Documents' = V_DOCUMENTS.

    CALL METHOD OF
        V_DOCUMENTS
        'OPEN'

      EXPORTING
        #1          = LV_PATH
        #2          = 0
        #12         = 0.

    CALL METHOD OF
        V_WORD
        'ActiveDocument' = V_ACTDOC.

    CALL METHOD OF
        V_ACTDOC
        'PrintOut'

      EXPORTING
        #1         = 0.

    CALL FUNCTION 'FLUSH'.

    CALL METHOD OF
        V_WORD
        'Quit'.

    CALL METHOD OF
        V_ACTDOC
        'CLOSE'

      EXPORTING
        #1       = 0.

    CALL METHOD OF
        V_DOCUMENTS
        'CLOSE'

      EXPORTING
        #1          = 0.

    FREE: V_WORD, V_ACTDOC, V_DOCUMENTS, V_NEWDOC.

  ENDIF.

ENDMETHOD.
*==== ZCL_LABEL_DOCX================CM003
*&---------------------------------------------------------------------*
*&  Appl. Area :  MM                                                   *
*&  Created by :  Oskar Pra                                            *
*&  Created on :  05 October 2023                                      *
*&---------------------------------------------------------------------*

METHOD PROTECT.

  DATA: LV_CONTENT       TYPE XSTRING,
        LO_IXML          TYPE REF TO IF_IXML,
        LO_STREAMFACTORY TYPE REF TO IF_IXML_STREAM_FACTORY,
        LO_ISTREAM       TYPE REF TO IF_IXML_ISTREAM,
        LO_PARSER        TYPE REF TO IF_IXML_PARSER,
        LR_ELEMENT       TYPE REF TO IF_IXML_ELEMENT
        .


  DATA
        : LR_SETTINGS TYPE REF TO IF_IXML_DOCUMENT
        .

*--------------------------------------------------------------------*
* Load XML file from archive into an input stream,
* and parse that stream into an ixml object
*--------------------------------------------------------------------*

  MO_ZIP->GET( EXPORTING  NAME =  'word/settings.xml'
                      IMPORTING CONTENT = LV_CONTENT ).

  LO_IXML           = CL_IXML=>CREATE( ).
  LO_STREAMFACTORY  = LO_IXML->CREATE_STREAM_FACTORY( ).
  LO_ISTREAM        = LO_STREAMFACTORY->CREATE_ISTREAM_XSTRING( LV_CONTENT ).
  LR_SETTINGS       = LO_IXML->CREATE_DOCUMENT( ).
  LO_PARSER         = LO_IXML->CREATE_PARSER( STREAM_FACTORY = LO_STREAMFACTORY
                                              ISTREAM        = LO_ISTREAM
                                              DOCUMENT       = LR_SETTINGS ).
*    lo_parser->set_normalizing( 'X' ).
  LO_PARSER->SET_VALIDATING( MODE = IF_IXML_PARSER=>CO_NO_VALIDATION ).
  LO_PARSER->PARSE( ).

  DATA LR_ITERATOR TYPE REF TO IF_IXML_NODE_ITERATOR.
  LR_ITERATOR = LR_SETTINGS->CREATE_ITERATOR( ).

  DO.
    DATA LR_NODE TYPE REF TO IF_IXML_NODE.
    LR_NODE = LR_ITERATOR->GET_NEXT( ).

    IF LR_NODE IS INITIAL.
      EXIT.
    ENDIF.

    CHECK LR_NODE->GET_TYPE( ) = IF_IXML_NODE=>CO_NODE_ELEMENT.

    DATA
          : LV_NODE_NAME TYPE STRING
          .

    LV_NODE_NAME = LR_NODE->GET_NAME( ).

    CHECK  LV_NODE_NAME = 'settings'.

    LR_ELEMENT = LR_SETTINGS->CREATE_ELEMENT_NS( NAME = 'documentProtection'
                                              PREFIX = 'w' ).

    LR_ELEMENT->SET_ATTRIBUTE_NS( NAME = 'edit'
                               PREFIX = 'w'
                               VALUE = 'readOnly' ).

    LR_ELEMENT->SET_ATTRIBUTE_NS( NAME = 'enforcement'
                               PREFIX = 'w'
                               VALUE = '1' ).

    LR_ELEMENT->SET_ATTRIBUTE_NS( NAME = 'cryptProviderType'
                         PREFIX = 'w'
                         VALUE = 'rsaFull' ).

    LR_ELEMENT->SET_ATTRIBUTE_NS( NAME = 'cryptAlgorithmClass'
                        PREFIX = 'w'
                        VALUE = 'hash' ).

    LR_ELEMENT->SET_ATTRIBUTE_NS( NAME = 'cryptAlgorithmType'
                             PREFIX = 'w'
                             VALUE = 'typeAny' ).

    LR_ELEMENT->SET_ATTRIBUTE_NS( NAME = 'cryptAlgorithmSid'
                               PREFIX = 'w'
                               VALUE = '4' ).

    LR_ELEMENT->SET_ATTRIBUTE_NS( NAME = 'cryptSpinCount'
                              PREFIX = 'w'
                              VALUE = '100000' ).

    LR_ELEMENT->SET_ATTRIBUTE_NS( NAME = 'hash'
                              PREFIX = 'w'
                              VALUE = 'zApjmCLBrWyDDRNiRAmxszP+gYc=' ).

    LR_ELEMENT->SET_ATTRIBUTE_NS( NAME = 'salt'
                               PREFIX = 'w'
                               VALUE = 'erqLP912rJurhcV4a1bb8A==' ).


    LR_NODE->APPEND_CHILD( LR_ELEMENT ) .

    EXIT.

  ENDDO.


  DATA
        : LO_OSTREAM        TYPE REF TO IF_IXML_OSTREAM
        , LO_RENDERER       TYPE REF TO IF_IXML_RENDERER

        .

* STEP 1: Create [Content_Types].xml into the root of the ZIP
  LO_IXML = CL_IXML=>CREATE( ).

  CLEAR LV_CONTENT.


  LO_STREAMFACTORY = LO_IXML->CREATE_STREAM_FACTORY( ).
  LO_OSTREAM = LO_STREAMFACTORY->CREATE_OSTREAM_XSTRING( STRING = LV_CONTENT ).
  LO_RENDERER = LO_IXML->CREATE_RENDERER( OSTREAM  = LO_OSTREAM DOCUMENT = LR_SETTINGS ).
  LO_RENDERER->RENDER( ).

  MO_ZIP->DELETE( NAME = 'word/settings.xml' ).
  MO_ZIP->ADD( NAME    = 'word/settings.xml'
             CONTENT = LV_CONTENT ).


ENDMETHOD.
*==== ZCL_LABEL_DOCX================CM004
*&---------------------------------------------------------------------*
*&  Appl. Area :  MM                                                   *
*&  Created by :  Oskar Pra                                            *
*&  Created on :  05 October 2023                                      *
*&---------------------------------------------------------------------*

METHOD PROTECT_SPACE.

  DATA
        : LV_STRING TYPE STRING
        , LT_CONTENT_SOURCE TYPE TABLE OF STRING
        , LT_CONTENT_DEST TYPE TABLE OF STRING
        , LV_FROM_XSTRING92(3) TYPE X VALUE 'E29892'
        , LV_FROM_XSTRING90(3) TYPE X VALUE 'E29890'
        , LV_TO_STRING92(8) TYPE X VALUE '5B4532393839325D'
        , LV_TO_STRING90(8) TYPE X VALUE '5B4532393839305D'
        , LV_CONTENT TYPE XSTRING
        .

  LV_CONTENT = IV_CONTENT.

  REPLACE ALL OCCURRENCES OF LV_FROM_XSTRING92 IN LV_CONTENT WITH LV_TO_STRING92 IN BYTE MODE .
  REPLACE ALL OCCURRENCES OF LV_FROM_XSTRING90 IN LV_CONTENT WITH LV_TO_STRING90 IN BYTE MODE .

  LV_STRING =  CL_ABAP_CODEPAGE=>CONVERT_FROM( LV_CONTENT ).

  SPLIT LV_STRING AT '<' INTO TABLE LT_CONTENT_SOURCE.

  FIELD-SYMBOLS
                 : <LS_CONTENT> TYPE STRING
                 , <LV_SOURCE> TYPE STRING
                 , <LV_DEST> TYPE STRING.

  LOOP AT LT_CONTENT_SOURCE ASSIGNING <LS_CONTENT>.
    IF <LS_CONTENT> IS NOT INITIAL.
      <LS_CONTENT> = '<' && <LS_CONTENT>.
    ENDIF.
  ENDLOOP.

  DATA
        : LV_STR1 TYPE STRING
        , LV_STR2 TYPE STRING
        .
  LOOP AT LT_CONTENT_SOURCE ASSIGNING <LV_SOURCE>.
    FIND REGEX '<w:t(\s|>)' IN   <LV_SOURCE>.
    IF SY-SUBRC NE 0.
      APPEND <LV_SOURCE> TO LT_CONTENT_DEST.
    ELSE.

      SPLIT <LV_SOURCE> AT '>' INTO LV_STR1 LV_STR2.
      LV_STR1 = LV_STR1 && '>'.
      APPEND LV_STR1 TO LT_CONTENT_DEST.
      REPLACE ALL OCCURRENCES OF REGEX '\s' IN LV_STR2 WITH '[SPACE]'.

      REPLACE ALL OCCURRENCES OF  '&#171;' IN LV_STR2 WITH '[171]'.
      REPLACE ALL OCCURRENCES OF  '&#187;' IN LV_STR2 WITH '[187]'.
      REPLACE ALL OCCURRENCES OF  '&#39;' IN LV_STR2 WITH '[39]'.

      APPEND LV_STR2 TO LT_CONTENT_DEST.
    ENDIF.
  ENDLOOP.

  CLEAR LV_STRING.
  LOOP AT LT_CONTENT_DEST ASSIGNING <LV_DEST>.
    LV_STRING = LV_STRING && <LV_DEST>.
  ENDLOOP.

  RV_CONTENT =  CL_ABAP_CODEPAGE=>CONVERT_TO( LV_STRING ).

ENDMETHOD.
*==== ZCL_LABEL_DOCX================CM005
*&---------------------------------------------------------------------*
*&  Appl. Area :  MM                                                   *
*&  Created by :  Oskar Pra                                            *
*&  Created on :  05 October 2023                                      *
*&---------------------------------------------------------------------*

METHOD RESTORE_SPACE.
  DATA
     : LV_STRING TYPE STRING
     , LT_STRING TYPE TABLE OF STRING
     , LT_DATA TYPE TABLE OF TEXT255
     .

  LV_STRING =  CL_ABAP_CODEPAGE=>CONVERT_FROM( IV_CONTENT ).

  REPLACE ALL OCCURRENCES OF '[171]'  IN LV_STRING WITH  '&#171;'.
  REPLACE ALL OCCURRENCES OF  '[187]' IN LV_STRING WITH '&#187;' .
  REPLACE ALL OCCURRENCES OF  '[39]' IN LV_STRING WITH '&#39;' .

  SPLIT LV_STRING AT '[SPACE]' INTO TABLE LT_STRING.

  DATA
        : LV_LEN TYPE I
        , LV_BUF TYPE TEXT255
        , LV_POS TYPE I
        , LV_REM TYPE I
        , LV_254 TYPE I VALUE 254
        , LV_255 TYPE I VALUE 255
        .

  FIELD-SYMBOLS
                 : <LV_STR> TYPE STRING
                 , <LV_DATA> TYPE TEXT255
                 .

  LV_POS = 0.
  LV_REM = LV_255.
  LOOP AT LT_STRING ASSIGNING <LV_STR>.

    LV_LEN = STRLEN( <LV_STR> ).

    WHILE LV_LEN > 0.
      IF LV_LEN > LV_REM.
        LV_BUF+LV_POS(LV_REM) = <LV_STR>(LV_REM).
        APPEND LV_BUF TO LT_DATA.

        <LV_STR> = <LV_STR>+LV_REM.
        LV_POS = 0.
        LV_REM = LV_255.
        CLEAR LV_BUF.
      ELSE.
        LV_BUF+LV_POS = <LV_STR>.
        LV_POS = LV_POS + LV_LEN.
        LV_REM = LV_REM - LV_LEN.
        CLEAR <LV_STR>.

      ENDIF.
      LV_LEN = STRLEN( <LV_STR> ).

    ENDWHILE.


    IF LV_POS < LV_254.
      LV_POS = LV_POS + 1.
      LV_REM = LV_REM - 1.
    ELSEIF LV_POS  = LV_254.
      APPEND LV_BUF TO LT_DATA.
      LV_POS = 0.
      LV_REM = LV_255.
      CLEAR LV_BUF.
    ELSE.
      APPEND LV_BUF TO LT_DATA.
      LV_POS = 1.
      LV_REM = LV_254.
      CLEAR LV_BUF.

    ENDIF.
  ENDLOOP.

  APPEND LV_BUF TO LT_DATA.

  CLEAR LV_STRING.

  LOOP AT LT_DATA ASSIGNING <LV_DATA>.
    CONCATENATE LV_STRING <LV_DATA> INTO LV_STRING RESPECTING BLANKS.
  ENDLOOP.

  RV_CONTENT =  CL_ABAP_CODEPAGE=>CONVERT_TO( LV_STRING ).

  DATA
            : LV_FROM_XSTRING92(3) TYPE X VALUE 'E29892'
            , LV_FROM_XSTRING90(3) TYPE X VALUE 'E29890'
            , LV_TO_STRING92(8) TYPE X VALUE '5B4532393839325D'
            , LV_TO_STRING90(8) TYPE X VALUE '5B4532393839305D'
            .

  REPLACE ALL OCCURRENCES OF LV_TO_STRING92 IN RV_CONTENT WITH LV_FROM_XSTRING92 IN BYTE MODE .
  REPLACE ALL OCCURRENCES OF LV_TO_STRING90 IN RV_CONTENT WITH LV_FROM_XSTRING90 IN BYTE MODE .

ENDMETHOD.
*==== ZCL_LABEL_DOCX================CO
PROTECTED SECTION.

  CONSTANTS MC_DOCUMENT TYPE STRING VALUE 'word/document.xml'. "#EC NOTEXT

  METHODS CONVERT_DATA_TO_NC
    IMPORTING
      !IV_DATA TYPE DATA .
  METHODS PROTECT .
  METHODS PROTECT_SPACE
    IMPORTING
      !IV_CONTENT TYPE XSTRING
    RETURNING
      VALUE(RV_CONTENT) TYPE XSTRING .
  METHODS RESTORE_SPACE
    IMPORTING
      !IV_CONTENT TYPE XSTRING
    RETURNING
      VALUE(RV_CONTENT) TYPE XSTRING .
*==== ZCL_LABEL_DOCX================CP
CLASS-POOL .
*"* class pool for class ZCL_LABEL_DOCX

*"* local type definitions
INCLUDE ZCL_LABEL_DOCX================CCDEF.

*"* class ZCL_LABEL_DOCX definition
*"* public declarations
  INCLUDE ZCL_LABEL_DOCX================CU.
*"* protected declarations
  INCLUDE ZCL_LABEL_DOCX================CO.
*"* private declarations
  INCLUDE ZCL_LABEL_DOCX================CI.
ENDCLASS. "ZCL_LABEL_DOCX definition

*"* macro definitions
INCLUDE ZCL_LABEL_DOCX================CCMAC.
*"* local class implementation
INCLUDE ZCL_LABEL_DOCX================CCIMP.

CLASS ZCL_LABEL_DOCX IMPLEMENTATION.
*"* method's implementations
  INCLUDE METHODS.
ENDCLASS. "ZCL_LABEL_DOCX implementation

*==== ZCL_LABEL_DOCX================CT
*"* dummy include to reduce generation dependencies between
*"* class ZCL_LABEL_DOCX and it's users.
*"* touched if any type reference has been changed
*==== ZCL_LABEL_DOCX================CU
CLASS ZCL_LABEL_DOCX DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

PUBLIC SECTION.

  CLASS-METHODS GET_DOCUMENT
    IMPORTING
      !IV_TEMPLATE TYPE XSTRING OPTIONAL
      !IV_ON_DESKTOP TYPE XFELD DEFAULT 'X'
      !IV_FOLDER TYPE STRING DEFAULT 'report'
      !IV_PATH TYPE STRING DEFAULT ''
      !IV_FILE_NAME TYPE STRING DEFAULT 'report.docx'
      !IV_NO_EXECUTE TYPE XFELD DEFAULT ''
      !IV_PROTECT TYPE XFELD DEFAULT ''
      !IV_NO_SAVE TYPE XFELD DEFAULT ''
      !IV_DATA TYPE DATA
    RETURNING
      VALUE(RV_DOCUMENT) TYPE XSTRING .