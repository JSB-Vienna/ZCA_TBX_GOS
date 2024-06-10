"! <p class="shorttext synchronized" lang="en">CA-TBX: GOS: ALV selection list with attachments (base impl)</p>
CLASS zcl_ca_gos_boas_sellist_base DEFINITION PUBLIC
                                              INHERITING FROM zcl_ca_salv_wrapper
                                              CREATE PUBLIC
                                              ABSTRACT.

* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n t e r f a c e s
    INTERFACES:
      zif_ca_gos_boas_sellist.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Constructor</p>
      "!
      "! @parameter io_gos_cons    | <p class="shorttext synchronized" lang="en">GOS: Consumer implementation for BO attachment selection</p>
      "! @parameter io_popup_ctlr  | <p class="shorttext synchronized" lang="en">Popup controller</p>
      "! @parameter io_cnt_sellist | <p class="shorttext synchronized" lang="en">Parent container for ALV</p>
      "! @parameter io_cnt_docview | <p class="shorttext synchronized" lang="en">Container for document display</p>
      constructor
        IMPORTING
          io_gos_cons    TYPE REF TO zif_ca_gos_boas
          io_popup_ctlr  TYPE REF TO zcl_ca_scr_fw_window_ctlr
          io_cnt_sellist TYPE REF TO cl_gui_container
          io_cnt_docview TYPE REF TO cl_gui_container OPTIONAL,

      on_link_click REDEFINITION.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   a l i a s e s
    ALIASES:
      mo_gos_cons          FOR  zif_ca_gos_boas_sellist~mo_gos_cons,
      mo_popup_ctlr        FOR  zif_ca_gos_boas_sellist~mo_popup_ctlr,
      mo_cnt_docview       FOR  zif_ca_gos_boas_sellist~mo_cnt_docview.
*      get_selected_entry   FOR  zif_ca_gos_boas_sellist~get_selected_entry.

*   c o n s t a n t s
    CONSTANTS:
      "! <p class="shorttext synchronized" lang="en">Fieldname: Flag for attach / don't attach</p>
      c_fn_attach          TYPE fieldname         VALUE 'ATTACH'  ##no_text.
*      "! <p class="shorttext synchronized" lang="en">Fieldname: Purchasing object item number</p>
*      c_fn_po_item         TYPE fieldname         VALUE 'PO_ITEM'  ##no_text.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.
*   a l i a s e s
    ALIASES:
      mr_sel_list          FOR  zif_ca_gos_boas_sellist~mr_sel_list.

ENDCLASS.



CLASS ZCL_CA_GOS_BOAS_SELLIST_BASE IMPLEMENTATION.


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    super->constructor(
                ir_table              = zif_ca_gos_boas_sellist~mr_sel_list
                iv_list_title         = COND #(
                                          WHEN io_popup_ctlr->mo_window->mv_mode
                                                             EQ io_popup_ctlr->mo_scr_options->mode-modify
                                          THEN 'Mark documents to be attached'(lt1)
                                          ELSE 'Display marked documents'(lt2) )
                iv_register_events    = abap_true
                iv_layout_restriction = if_salv_c_layout=>restrict_none "usr_dep ).
                io_container          = io_cnt_sellist
                iv_cnt_name           = 'ALV_ARCH_DOCS' ) ##no_text.

    mo_gos_cons    = io_gos_cons.
    mo_popup_ctlr  = io_popup_ctlr.
    mo_cnt_docview = io_cnt_docview.
  ENDMETHOD.                    "constructor


  METHOD on_link_click.
    "-----------------------------------------------------------------*
    "   Handle click at link/hotspot
    "-----------------------------------------------------------------*
    "Local data definitions
    FIELD-SYMBOLS:
      <lo_archive_doc>     TYPE REF TO zif_ca_archive_doc.

    DATA:
      lx_error             TYPE REF TO zcx_ca_error.

    TRY.
        DATA(lr_sel_list) = zif_ca_gos_boas_sellist~get_selected_entry( row ).    "Get line reference
        ASSIGN lr_sel_list->* TO FIELD-SYMBOL(<ls_sellist>).

        CASE column.
          WHEN c_fn_attach.
            IF mo_popup_ctlr->mo_window->mv_mode EQ mo_popup_ctlr->mo_scr_options->mode-modify.
              "Exchange space to X and X to space
              ASSIGN COMPONENT c_fn_attach OF STRUCTURE <ls_sellist> TO FIELD-SYMBOL(<lv_attach>).
              TRANSLATE <lv_attach> USING ' XX ' ##no_text.
              mo_salv->refresh( ).
            ENDIF.

          WHEN 'OBJECTTEXT_DT' ##no_text.
            ASSIGN COMPONENT 'O_ARCHIVE_DOC' OF STRUCTURE <ls_sellist> TO <lo_archive_doc>.
            <lo_archive_doc>->display( ).
        ENDCASE.

      CATCH zcx_ca_ui INTO lx_error.
        MESSAGE lx_error TYPE c_msgty_s.

      CATCH zcx_ca_error INTO lx_error.
        MESSAGE lx_error TYPE c_msgty_s DISPLAY LIKE c_msgty_e.
    ENDTRY.
  ENDMETHOD.                    "on_link_click


  METHOD zif_ca_gos_boas_sellist~get_marked_docs.
    "-----------------------------------------------------------------*
    "   Get selected line
    "-----------------------------------------------------------------*

  ENDMETHOD.                    "zif_ca_gos_boas_sellist~get_marked_docs


  METHOD zif_ca_gos_boas_sellist~get_selected_entry.
    "-----------------------------------------------------------------*
    "   Get selected line
    "-----------------------------------------------------------------*

  ENDMETHOD.                    "zif_ca_gos_boas_sellist~get_selected_entry
ENDCLASS.
