"! <p class="shorttext synchronized" lang="en">CA-TBX: GOS Mail class enhance for attachm. name preparation</p>
CLASS zcl_ca_gos_boas_mail DEFINITION PUBLIC
                                      INHERITING FROM zcl_ca_mail
                                      CREATE PUBLIC.
* P U B L I C   S E C T I O N
  PUBLIC SECTION.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   i n s t a n c e   m e t h o d s
    METHODS:
      assemble_attachm_name REDEFINITION.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_CA_GOS_BOAS_MAIL IMPLEMENTATION.


  METHOD assemble_attachm_name.
    "-----------------------------------------------------------------*
    "   Assemble attachment name without extension
    "-----------------------------------------------------------------*
    "Get settings
    SELECT SINGLE prio_attch_name INTO  @DATA(lv_prio_attch_name)
                                  FROM  zca_gos_boas
                                  WHERE bo_name EQ @io_doc->mbo_document-typeid.
    IF sy-subrc NE 0.
      lv_prio_attch_name = '0'.
    ENDIF.

    CASE lv_prio_attch_name.
      WHEN '0'.    "standard
        "Do nothing - if return variable is initial -> standard is executed

      WHEN '1'.    "first user descr, second original file name
        IF io_doc->ms_data-descr IS NOT INITIAL.
          result = |{ io_doc->mbo_document-instid }_{ io_doc->ms_data-descr }|.

        ELSEIF io_doc->ms_data-filename IS NOT INITIAL.
          result = |{ io_doc->mbo_document-instid }_{ io_doc->ms_data-filename }|.
        ENDIF.

      WHEN '2'.    "first original file name, second user descr
        IF io_doc->ms_data-filename IS NOT INITIAL.
          result = |{ io_doc->mbo_document-instid }_{ io_doc->ms_data-filename }|.

        ELSEIF io_doc->ms_data-descr IS NOT INITIAL.
          result = |{ io_doc->mbo_document-instid }_{ io_doc->ms_data-descr }|.
        ENDIF.
    ENDCASE.

    IF result IS INITIAL.
      "As fallback use short description of the document type with counter, if this
      "document type was attached multiple times
      IF io_doc->ms_doc_type_descr-objecttext IS NOT INITIAL.
        result = |{ io_doc->mbo_document-instid }_{ io_doc->ms_doc_type_descr-objecttext }_{ iv_doc_cnt }|.

      ELSE.
        result = super->assemble_attachm_name( iv_doc_cnt = iv_doc_cnt
                                               io_doc     = io_doc ).
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "assemble_attachm_name
ENDCLASS.
