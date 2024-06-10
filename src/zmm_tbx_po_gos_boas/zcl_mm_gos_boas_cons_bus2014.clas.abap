"! <p class="shorttext synchronized" lang="en">CA-TBX: MM GOS: Outline agreem. consumer to select attachm.</p>
CLASS zcl_mm_gos_boas_cons_bus2014 DEFINITION PUBLIC
                                              INHERITING FROM zcl_mm_gos_boas_consumer
                                              FINAL
                                              CREATE PUBLIC.

* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     t a b l e s
      "! <p class="shorttext synchronized" lang="en">Outline agreement items</p>
      mt_items TYPE bapimeout_t_item READ-ONLY,

*     s t r u c t u r e s
      "! <p class="shorttext synchronized" lang="en">Outline agreement header</p>
      ms_hdr   TYPE bapimeoutheader READ-ONLY.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Constructor</p>
      "!
      "! @parameter io_gos_svc   | <p class="shorttext synchronized" lang="en">GOS: BO Attachment selection for mails (service)</p>
      "! @raising   zcx_ca_param | <p class="shorttext synchronized" lang="en">Common exception: Parameter error (INHERIT from this excep!)</p>
      "! @raising   zcx_ca_dbacc | <p class="shorttext synchronized" lang="en">Common exception: Database access</p>
      constructor
        IMPORTING
          io_gos_svc TYPE REF TO zcl_ca_gos_boas_svc
        RAISING
          zcx_ca_param
          zcx_ca_dbacc,

      activate_service REDEFINITION.

* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   i n s t a n c e   m e t h o d s
    METHODS:
      build_filter_dms REDEFINITION.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_MM_GOS_BOAS_CONS_BUS2014 IMPLEMENTATION.


  METHOD activate_service.
    "-----------------------------------------------------------------*
    "   Check service activation in customizing
    "-----------------------------------------------------------------*
    "No further details to be checked
    result = abap_false.

    "Get detail settings to document type
    get_doc_type_settings( ms_hdr-doc_type ).

    check_rel_doc_type_to_doc_cat( iv_bstyp = c_bstyp_k
                                       iv_bsart = ms_gos_boasdt-bsart ).

    result = abap_true.
  ENDMETHOD.                    "zif_ca_gos_boas~activate_service


  METHOD build_filter_dms.
    "-----------------------------------------------------------------*
    "   Build filter for DMS access / search
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lt_items      TYPE gty_tt_items,    "Purchasing subcontracting items
      lt_bom_items  TYPE gty_tt_items,    "BOM items to subcontr. items
      ls_filter_dms TYPE zca_s_dms_filter.

    "Initialize filter with specific parameters for DMS access
    rs_filter_dms = super->build_filter_dms( ).

    "Set the concatenated key PO number + item
    LOOP AT mt_items ASSIGNING FIELD-SYMBOL(<ls_item>)
                         WHERE delete_ind EQ abap_false.
      APPEND VALUE #( dokob = c_dms_filt_bo_ekpo
                      objky = ms_hdr-number && <ls_item>-item_no ) TO rs_filter_dms-t_sel_drad.

      IF <ls_item>-material IS NOT INITIAL.
        APPEND VALUE #( dokob = c_dms_filt_bo_mara
                        objky = <ls_item>-material ) TO rs_filter_dms-t_sel_drad.

        IF <ls_item>-item_cat EQ c_pstyp_subcontr AND   "subcontracting item
           <ls_item>-info_rec IS NOT INITIAL.           "has info record
          APPEND VALUE #( po_item   = <ls_item>-item_no
                          purch_org = ms_hdr-purch_org
                          vendor    = ms_hdr-vendor
                          info_rec  = <ls_item>-info_rec
                          plant     = <ls_item>-plant
                          material  = <ls_item>-material ) TO lt_items.
        ENDIF.
      ENDIF.
    ENDLOOP.

    "Resolve BOM and attach corresponding materials to filter
    get_filter_from_bom(
                      EXPORTING
                        it_items      = lt_items
                      IMPORTING
                        et_bom_items  = lt_bom_items
                        es_filter_dms = ls_filter_dms ).

    "Add new entries and erase duplicates
    APPEND LINES OF ls_filter_dms-t_sel_drad TO rs_filter_dms-t_sel_drad.
    SORT rs_filter_dms-t_sel_drad.
    DELETE ADJACENT DUPLICATES FROM rs_filter_dms-t_sel_drad COMPARING ALL FIELDS.

    LOOP AT lt_bom_items ASSIGNING FIELD-SYMBOL(<ls_bom_item>).
      APPEND VALUE #( item_no  = <ls_bom_item>-po_item
                      plant    = <ls_bom_item>-plant
                      material = <ls_bom_item>-material
                      item_cat = <ls_bom_item>-item_cat ) TO mt_items.
    ENDLOOP.
    SORT mt_items BY item_no
                         item_cat
                         material.
    DELETE ADJACENT DUPLICATES FROM mt_items COMPARING item_no material.
  ENDMETHOD.                    "build_filter_dms


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lt_return            TYPE bapiret2_t.

    super->constructor( io_gos_svc ).

    "Get document type of outline agreement
    CALL FUNCTION 'BAPI_CONTRACT_GETDETAIL'
      EXPORTING
        purchasingdocument = CONV ebeln( mo_gos_svc->ms_bo_key-instid )
      IMPORTING
        header             = ms_hdr
      TABLES
        item               = mt_items
        return             = lt_return.

    DATA(lx_error) =
         CAST zcx_mm_gos_boas(
                zcx_ca_error=>create_exception(
                         iv_excp_cls = zcx_mm_gos_boas=>c_zcx_mm_gos_boas
                         iv_function = 'BAPI_CONTRACT_GETDETAIL'
                         it_return   = lt_return ) )  ##no_text.
    IF lx_error IS BOUND.
      RAISE EXCEPTION lx_error.
    ENDIF.
  ENDMETHOD.                    "constructor
ENDCLASS.
