"! <p class="shorttext synchronized" lang="en">CA-TBX: MM GOS: PO consumer to select attachm. (abstract)</p>
CLASS zcl_mm_gos_boas_consumer DEFINITION PUBLIC
                                          ABSTRACT
                                          CREATE PUBLIC.

* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n t e r f a c e s
    INTERFACES:
      if_mmpur_constants_ind,
      if_xo_const_message,
      zif_ca_gos_boas.

*   a l i a s e s
    ALIASES:
*     Message types
      c_msgty_e            FOR  if_xo_const_message~error,
      c_msgty_i            FOR  if_xo_const_message~info,
      c_msgty_s            FOR  if_xo_const_message~success,
      c_msgty_w            FOR  if_xo_const_message~warning,
*     Purchase object types
      c_bstyp_a            FOR  if_mmpur_constants_ind~bstyp_a,    "Request for quotation
      c_bstyp_f            FOR  if_mmpur_constants_ind~bstyp_f,    "Purchase order
      c_bstyp_i            FOR  if_mmpur_constants_ind~bstyp_i,    "Info record
      c_bstyp_k            FOR  if_mmpur_constants_ind~bstyp_k,    "Contract
      c_bstyp_l            FOR  if_mmpur_constants_ind~bstyp_l,    "Scheduling agreement
      c_bstyp_q            FOR  if_mmpur_constants_ind~bstyp_q,    "Service entry sheet
*     Purchase item category
      c_pstyp_subcontr      FOR  if_mmpur_constants_ind~pstyp_3,    "Subcontracting (techn. value)
*     GOS objects and methods
      mo_gos_svc           FOR  zif_ca_gos_boas~mo_gos_svc,
      mo_al_cont           FOR  zif_ca_gos_boas~mo_arch_cont,
      factory              FOR  zif_ca_gos_boas~factory,
      has_content          FOR  zif_ca_gos_boas~has_content,
      activate_service     FOR  zif_ca_gos_boas~activate_service,
      execute_consumer     FOR  zif_ca_gos_boas~execute_consumer,
      on_handle_fcode      FOR  zif_ca_gos_boas~on_fcode_triggered,
      svc_closed           FOR  zif_ca_gos_boas~svc_closed,
      svc_saved            FOR  zif_ca_gos_boas~svc_saved.

*   c o n s t a n t s
    CONSTANTS:
*     ArchiveLink filter parameter names
      "! <p class="shorttext synchronized" lang="en">DMS Filter value for business object</p>
      c_dms_filt_bo_ekpo TYPE fieldname         VALUE 'EKPO'  ##no_text,
      "! <p class="shorttext synchronized" lang="en">DMS Filter value for business object</p>
      c_dms_filt_bo_mara TYPE fieldname         VALUE 'MARA'  ##no_text.

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
          zcx_ca_dbacc.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   a l i a s e s
    ALIASES:
      mo_popup             FOR  zif_ca_gos_boas~mo_popup.

*   l o c a l   t y p e   d e f i n i t i o n
    TYPES:
      "! <p class="shorttext synchronized" lang="en">Item values for BOM extraction</p>
      BEGIN OF gty_s_item,
        po_item   TYPE ebelp,
        purch_org TYPE ekorg,
        vendor    TYPE lifnr,
        info_rec  TYPE infnr,
        plant     TYPE werks_d,
        material  TYPE matnr,
        item_cat  TYPE pstyp,
      END   OF gty_s_item,
      "! <p class="shorttext synchronized" lang="en">Item values for BOM extraction</p>
      gty_tt_items  TYPE STANDARD TABLE OF gty_s_item,

      "! <p class="shorttext synchronized" lang="en">Item values for BOM extraction</p>
      gty_tt_filter TYPE cl_alink_connection=>toarange_d_tab.

*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     o b j e c t   r e f e r e n c e s
      "! <p class="shorttext synchronized" lang="en">Function code constants (with suggested icons)</p>
      mo_fcodes     TYPE REF TO zcl_ca_c_fcodes,

*     s t r u c t u r e s
      "! <p class="shorttext synchronized" lang="en">MM: GOS attachm. sel. - settings per doc. type</p>
      ms_gos_boasdt TYPE zmm_gos_boasdt.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Checks the relation of document type to document category</p>
      "!
      "! @parameter iv_bstyp        | <p class="shorttext synchronized" lang="en">Purchasing document category</p>
      "! @parameter iv_bsart        | <p class="shorttext synchronized" lang="en">Purchasing Document Type</p>
      "! @raising   zcx_mm_gos_boas | <p class="shorttext synchronized" lang="en">MM GOS: Errors while selecting attachments to BO</p>
      check_rel_doc_type_to_doc_cat
        IMPORTING
          iv_bstyp TYPE bstyp
          iv_bsart TYPE esart
        RAISING
          zcx_mm_gos_boas,

      "! <p class="shorttext synchronized" lang="en">Checks if the document is defined</p>
      "!
      "! @parameter iv_bsart        | <p class="shorttext synchronized" lang="en">Purchasing Document Type</p>
      "! @raising   zcx_mm_gos_boas | <p class="shorttext synchronized" lang="en">MM GOS: Errors while selecting attachments to BO</p>
      get_doc_type_settings
        IMPORTING
          iv_bsart TYPE esart
        RAISING
          zcx_mm_gos_boas,

      "! <p class="shorttext synchronized" lang="en">Build filter for DMS access / search</p>
      "!
      "! @parameter rs_filter_dms   | <p class="shorttext synchronized" lang="en">Filter for DMS</p>
      "! @raising   zcx_mm_gos_boas | <p class="shorttext synchronized" lang="en">MM GOS: Errors while selecting attachments to BO</p>
      build_filter_dms
        RETURNING
          VALUE(rs_filter_dms) TYPE zca_s_dms_filter
        RAISING
          zcx_mm_gos_boas,

      "! <p class="shorttext synchronized" lang="en">Get material numbers of BOM</p>
      "!
      "! @parameter it_items      | <p class="shorttext synchronized" lang="en">Relevant purchasing object items</p>
      "! @parameter et_bom_items  | <p class="shorttext synchronized" lang="en">Additional BOM items for displaying in selection list</p>
      "! @parameter es_filter_dms | <p class="shorttext synchronized" lang="en">Filter for DMS</p>
      get_filter_from_bom
        IMPORTING
          it_items      TYPE gty_tt_items
        EXPORTING
          et_bom_items  TYPE gty_tt_items
          es_filter_dms TYPE zca_s_dms_filter.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_MM_GOS_BOAS_CONSUMER IMPLEMENTATION.


  METHOD build_filter_dms.
    "-----------------------------------------------------------------*
    "   Build filter for DMS access / search
    "-----------------------------------------------------------------*
    "Set object types - is for all currently used BOs identical
    rs_filter_dms-t_filter =
                    VALUE #(   dsign   = mo_al_cont->mo_sel_options->sign-incl
                               doption = mo_al_cont->mo_sel_options->option-eq
                               "Doc. type DOKAR as customized
                             ( name    = mo_al_cont->mo_arch_filter->dms_filter-doc_type
                               dlow    = ms_gos_boasdt-dokar )
                               "Only with status 'Released'
                             ( name    = mo_al_cont->mo_arch_filter->dms_filter-doc_state "internal state
                               dlow    = 'FR' ) ) ##no_text.
  ENDMETHOD.                    "build_filter_dms


  METHOD check_rel_doc_type_to_doc_cat.
    "-----------------------------------------------------------------*
    "   Checks the relation of document type to document category
    "-----------------------------------------------------------------*
    SELECT COUNT(*) FROM t161                            "#EC CI_BYPASS
                    WHERE bstyp EQ iv_bstyp
                      AND bsart EQ iv_bsart.
    IF sy-subrc NE 0.
      "Document type &1 not allowed with doc.  category &2 (Please check input)
      RAISE EXCEPTION TYPE zcx_mm_gos_boas
        EXPORTING
          textid   = zcx_mm_gos_boas=>rel_doc_type_2_cat
          mv_msgty = c_msgty_i
          mv_msgv1 = CONV #( iv_bsart )
          mv_msgv2 = CONV #( iv_bstyp ).
    ENDIF.
  ENDMETHOD.                    "check_rel_doc_type_to_doc_cat


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    mo_gos_svc = io_gos_svc.
    SET HANDLER: mo_gos_svc->on_svc_closed FOR me,
                 mo_gos_svc->on_svc_saved  FOR me.

    mo_al_cont = NEW #( is_bo_key = mo_gos_svc->ms_bo_key ).
    mo_fcodes  = zcl_ca_c_fcodes=>get_instance( ).
  ENDMETHOD.                    "constructor


  METHOD get_doc_type_settings.
    "-----------------------------------------------------------------*
    "   Checks if the document is defined
    "-----------------------------------------------------------------*
    SELECT SINGLE * INTO  @ms_gos_boasdt
                    FROM  zmm_gos_boasdt
                    WHERE bo_name EQ @mo_gos_svc->ms_bo_key-typeid
                      AND bsart   EQ @iv_bsart.
    IF sy-subrc NE 0.
      "Document type &1 is not defined
      RAISE EXCEPTION TYPE zcx_mm_gos_boas
        EXPORTING
          textid   = zcx_mm_gos_boas=>doc_type_not_def
          mv_msgty = c_msgty_i
          mv_msgv1 = CONV #( iv_bsart ).
    ENDIF.
  ENDMETHOD.                    "get_doc_type_settings


  METHOD get_filter_from_bom.
    "-----------------------------------------------------------------*
    "   Get material numbers of BOM
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lx_error TYPE REF TO zcx_ca_param,
      lt_stpo  TYPE t_stpo_api02,
      ls_rc27i TYPE rc27i,
      ls_mkal  TYPE mkal,
      lv_matnr TYPE matnr.

    IF it_items IS INITIAL.
      RETURN.
    ENDIF.

    "Get info records
    SELECT infnr, ekorg, werks, verid INTO  TABLE @DATA(lt_eine)
                                      FROM  eine
                                            FOR ALL ENTRIES IN @it_items
                                      WHERE infnr EQ @it_items-info_rec
                                        AND ekorg EQ @it_items-purch_org
                                        AND esokz EQ @c_pstyp_subcontr
                                        AND werks EQ @it_items-plant
                                        AND loekz EQ @abap_false
                                        AND verid NE @space.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    "Set the material no. and the parts of the BOM itself
    LOOP AT it_items ASSIGNING FIELD-SYMBOL(<ls_item>).
      TRY.
          DATA(ls_eine) = lt_eine[ infnr = <ls_item>-info_rec
                                   ekorg = <ls_item>-purch_org
                                   werks = <ls_item>-plant ].

          CALL FUNCTION 'CM_FV_MKAL_BT_INITIALIZE'.

          CALL FUNCTION 'CM_FV_MKAL_PROV'
            EXPORTING
              matnr          = <ls_item>-material
              werks          = <ls_item>-plant
              verid          = ls_eine-verid
              sttag          = sy-datlo
              trtyp          = 'A' ##no_text
              rc27i_imp      = ls_rc27i
            IMPORTING
              mkal_exp       = ls_mkal
            EXCEPTIONS
              no_mkal_found  = 1
              no_mkal_select = 2
              OTHERS         = 3.
          IF sy-subrc NE 0.
            lx_error = CAST #( zcx_ca_error=>create_exception(
                                           iv_excp_cls = zcx_mm_gos_boas=>c_zcx_mm_gos_boas
                                           iv_function = 'CM_FV_MKAL_PROV'
                                           iv_subrc    = sy-subrc ) )  ##no_text.
            mo_gos_svc->mo_log->add_msg_exc( ix_excep     = lx_error
                                             iv_probclass = mo_gos_svc->mo_log_options->problem_class-info ).
            CONTINUE.
          ENDIF.

          CALL FUNCTION 'CSAP_MAT_BOM_READ'
            EXPORTING
              material    = ls_mkal-matnr
              plant       = ls_mkal-werks
              bom_usage   = ls_mkal-stlan
              alternative = ls_mkal-stlal
            TABLES
              t_stpo      = lt_stpo
            EXCEPTIONS
              error       = 1
              OTHERS      = 2.
          IF sy-subrc NE 0.
            lx_error = CAST #( zcx_ca_error=>create_exception(
                                           iv_excp_cls = zcx_mm_gos_boas=>c_zcx_mm_gos_boas
                                           iv_function = 'CSAP_MAT_BOM_READ'
                                           iv_subrc    = sy-subrc ) )  ##no_text.
            mo_gos_svc->mo_log->add_msg_exc( ix_excep     = lx_error
                                             iv_probclass = mo_gos_svc->mo_log_options->problem_class-info ).
            CONTINUE.
          ENDIF.

          "Append compponents to filter
          LOOP AT lt_stpo ASSIGNING FIELD-SYMBOL(<ls_stpo>)
                          WHERE mat_provis EQ 'L'.
            TRY.
                "Reconvert material number back into internal format (the method
                "determine and uses the conversion exit)
                zcl_ca_conv=>external_2_internal(
                                            EXPORTING
                                              external_value = <ls_stpo>-component
                                            IMPORTING
                                              internal_value = lv_matnr ).

                APPEND VALUE #( dokob = c_dms_filt_bo_mara
                                objky = lv_matnr ) TO es_filter_dms-t_sel_drad.

                APPEND VALUE #( po_item  = <ls_item>-po_item
                                plant    = <ls_item>-plant
                                material = lv_matnr
                                item_cat = 'L' ) TO et_bom_items.

              CATCH zcx_ca_conv INTO lx_error.
                mo_gos_svc->mo_log->add_msg_exc( ix_excep     = lx_error
                                                 iv_probclass = mo_gos_svc->mo_log_options->problem_class-info ).
                CONTINUE.
            ENDTRY.
          ENDLOOP.

        CATCH cx_sy_itab_line_not_found.
          "No valid info record available
          "No entry exists for & in Table &
          mo_gos_svc->mo_log->add_msg(
                        iv_msgty     = c_msgty_w
                        iv_msgid     = 'SD'
                        iv_msgno     = '850'
                        iv_msgv1     = |{ <ls_item>-info_rec ALPHA = OUT } { <ls_item>-purch_org } { <ls_item>-plant }|
                        iv_probclass = mo_gos_svc->mo_log_options->problem_class-info ).
          CONTINUE.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.                    "get_filter_from_bom


  METHOD zif_ca_gos_boas~activate_service.
    "-----------------------------------------------------------------*
    "   Check service activation in customizing
    "-----------------------------------------------------------------*
    "No further details to be checked here - has to be done in subclass!!
    result = abap_false.
  ENDMETHOD.                    "zif_ca_gos_boas~activate_service


  METHOD zif_ca_gos_boas~execute_consumer.
    "-----------------------------------------------------------------*
    "   Starting main function of consumer, controlling the process
    "-----------------------------------------------------------------*
    DATA(lo_popup) = NEW zcl_mm_gos_boas_popup( me ).
    "DO IT HERE!!! Ohterwise the move is avoided by the DISPLAY method
    mo_popup = CAST #( lo_popup ).

    SET HANDLER on_handle_fcode FOR lo_popup.
    lo_popup->display( ).
  ENDMETHOD.                    "zif_ca_gos_boas~execute_consumer


  METHOD zif_ca_gos_boas~factory.
    "-----------------------------------------------------------------*
    "   Creating consumer instance
    "-----------------------------------------------------------------*
    TRY.
        CREATE OBJECT result TYPE (io_gos_svc->ms_gos_boas-class_name_consumer)
          EXPORTING
            io_gos_svc = io_gos_svc.

      CATCH zcx_ca_archive_content INTO DATA(lx_error).
        "Error when creating consumer &1 -> see previous exception
        RAISE EXCEPTION TYPE zcx_ca_gos_boas
          EXPORTING
            textid   = zcx_ca_gos_boas=>error_creating_consumer
            previous = lx_error
            mv_msgv1 = CONV #( translate( val  = sy-repid
                                          from = `=`
                                          to   = ``) ).
    ENDTRY.
  ENDMETHOD.                    "zif_ca_gos_boas~factory


  METHOD zif_ca_gos_boas~has_content.
    "-----------------------------------------------------------------*
    "   Checks if any content is connected to the current BO
    "-----------------------------------------------------------------*
    TRY.
        "Create filter from settings in MS_GOS_BOAS
        mo_al_cont->get( iv_refresh       = abap_true
                         "it_filter_al     = build_filter_archive_link( )
                         is_filter_dms    = build_filter_dms( )
                         iv_only_act_vers = abap_false
                         iv_only_rel_vers = abap_false ).
        result = mo_al_cont->has_content( ).

      CATCH zcx_ca_gos_boas INTO DATA(lx_catched).
        DATA(lx_error) =
             CAST zcx_ca_archive_content(
                    zcx_ca_error=>create_exception(
                             iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                             ix_error    = lx_catched ) )  ##no_text.
        IF lx_error IS BOUND.
          RAISE EXCEPTION lx_error.
        ENDIF.
    ENDTRY.
  ENDMETHOD.                    "zif_ca_gos_boas~has_content


  METHOD zif_ca_gos_boas~on_fcode_triggered.
    "-----------------------------------------------------------------*
    "   Receiving last action forwarding to GOS service
    "-----------------------------------------------------------------*
    "Inform service class
    CASE iv_fcode.
      WHEN mo_fcodes->save.
        RAISE EVENT svc_saved
          EXPORTING
            it_gos_bomd = mo_popup->get_result( ).

      WHEN OTHERS.
        RAISE EVENT svc_closed.
    ENDCASE.
  ENDMETHOD.                    "zif_ca_gos_boas~on_handle_fcode
ENDCLASS.
