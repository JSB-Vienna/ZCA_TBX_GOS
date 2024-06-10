"! <p class="shorttext synchronized" lang="en">CA-TBX: GOS: ALV selection list with attachments</p>
CLASS zcl_ca_gos_boas_sellist DEFINITION PUBLIC
                                         INHERITING FROM zcl_ca_gos_boas_sellist_base
                                         CREATE PUBLIC.

* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   s t a t i c   m e t h o d s
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Class constructor</p>
      class_constructor.

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

      process REDEFINITION,

      free REDEFINITION,

      zif_ca_gos_boas_sellist~get_marked_docs REDEFINITION,

      zif_ca_gos_boas_sellist~get_selected_entry REDEFINITION.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   i n s t a n c e   m e t h o d s
    METHODS:
      prepare_alv REDEFINITION.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.
*   s t a t i c   a t t r i b u t e s
    CLASS-DATA:
*     t a b l e s
      "! <p class="shorttext synchronized" lang="en">GOS: ALV selection list with mail attachments</p>
      mt_sel_list     TYPE zca_tt_gos_boas_sellist.

ENDCLASS.



CLASS ZCL_CA_GOS_BOAS_SELLIST IMPLEMENTATION.


  METHOD class_constructor.
    "-----------------------------------------------------------------*
    "   Class constructor
    "-----------------------------------------------------------------*
    zif_ca_gos_boas_sellist~mr_sel_list = REF #( mt_sel_list ).
  ENDMETHOD.                    "class_constructor


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    super->constructor( io_gos_cons    = io_gos_cons
                        io_popup_ctlr  = io_popup_ctlr
                        io_cnt_sellist = io_cnt_sellist
                        io_cnt_docview = io_cnt_docview ).
  ENDMETHOD.                    "constructor


  METHOD free.
    "-----------------------------------------------------------------*
    "   Release used objects
    "-----------------------------------------------------------------*
    super->free( ).

    FREE mt_sel_list.
  ENDMETHOD.                    "save


  METHOD prepare_alv.
    "-----------------------------------------------------------------*
    "   Do other ALV preparations
    "-----------------------------------------------------------------*
    TRY.
        "Set a medium title size
        mo_salv->get_display_settings(
                          )->set_list_header_size(
                                  cl_salv_display_settings=>c_header_size_medium ).

        "Deactivate all functions
        mo_salv->get_functions( )->set_all( abap_false ).

        "Adjust columns
        LOOP AT mt_cols ASSIGNING FIELD-SYMBOL(<ls_col>).
          DATA(lo_col) = CAST cl_salv_column_table( <ls_col>-r_column ).

          CASE <ls_col>-columnname.
            WHEN c_fn_attach.
              lo_col->set_key( ).
              lo_col->set_key_presence_required( ).
              lo_col->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).

            WHEN 'OBJECTTEXT_DT' ##no_text.
              lo_col->set_cell_type( if_salv_c_cell_type=>hotspot ).

            WHEN 'DOC_TYPE_DC' ##no_text.
              lo_col->set_alignment( lo_col->centered ).

            WHEN 'AR_DATE_CN' ##no_text.
              "do noting - but don't mark as technical

            WHEN 'AR_TIME_CN'  OR 'NAME'          OR 'AR_OBJECT_DT' OR
                 'STEXT'       OR 'OBJECTTEXT_DC' OR 'FILENAME_CN' ##no_text.
              lo_col->set_visible( abap_false ).

            WHEN OTHERS.
              lo_col->set_technical( abap_true ).
          ENDCASE.
        ENDLOOP.

        "Set column order
        DATA(lo_cols) = mo_salv->get_columns( ).
        lo_cols->set_key_fixation( ).
        lo_cols->set_column_position( columnname = c_fn_attach       "Button to mark/unmark
                                      position   = 1 ) ##no_text.
        lo_cols->set_column_position( columnname = 'OBJECTTEXT_DT' "Short descr. doc. type
                                      position   = 2 ) ##no_text.
        lo_cols->set_column_position( columnname = 'DOC_TYPE_DC'   "Sort values
                                      position   = 3 ) ##no_text.
        lo_cols->set_column_position( columnname = 'AR_DATE_CN'    "Archiving date
                                      position   = 4 ) ##no_text.


        DATA(lo_sorts) = mo_salv->get_sorts( ).
        lo_sorts->clear( ).
        lo_sorts->add_sort( columnname = 'NAME'          "Techn. name BO
                            position   = 1
                            sequence   = if_salv_c_sort=>sort_up ) ##no_text.
        lo_sorts->add_sort( columnname = 'AR_DATE_CN'    "Archiving date
                            position   = 2
                            sequence   = if_salv_c_sort=>sort_down ) ##no_text.
        lo_sorts->add_sort( columnname = 'AR_TIME_CN'    "Archiving time
                            position   = 3
                            sequence   = if_salv_c_sort=>sort_down ) ##no_text.

      CATCH cx_salv_error INTO DATA(lx_error).
        RAISE EXCEPTION TYPE zcx_ca_salv_wrapper
          EXPORTING
            previous = lx_error.
    ENDTRY.
  ENDMETHOD.                    "prepare_alv


  METHOD process.
    "-----------------------------------------------------------------*
    "   Controls entire processing
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lx_error             TYPE REF TO cx_root.

    TRY.
        "This methods reads all connections and returns the marked documents
        DATA(lt_marked_docs) = mo_gos_cons->mo_arch_cont->get_marked_docs( ).

        LOOP AT mo_gos_cons->mo_arch_cont->mt_docs ASSIGNING FIELD-SYMBOL(<lo_doc>).
          APPEND VALUE #(
              s_bo_desc         = mo_gos_cons->mo_arch_cont->ms_bo_desc
              s_doc_type_descr  = <lo_doc>->ms_doc_type_descr
              s_doc_class_descr = <lo_doc>->ms_doc_class_descr
              s_conn            = <lo_doc>->ms_data
              objecttext_dt = COND #(
                                WHEN <lo_doc>->ms_data-descr IS NOT INITIAL
                                  THEN <lo_doc>->ms_data-descr
                                  ELSE <lo_doc>->ms_doc_type_descr-objecttext )
              attach        =
                 boolc( line_exists(
                            lt_marked_docs[
                                  table_line->ms_data-sap_object = <lo_doc>->ms_data-sap_object
                                  table_line->ms_data-object_id  = <lo_doc>->ms_data-object_id
                                  table_line->ms_data-archiv_id  = <lo_doc>->ms_data-archiv_id
                                  table_line->ms_data-arc_doc_id = <lo_doc>->ms_data-arc_doc_id ] ) )
              o_archive_doc      = <lo_doc> ) TO mt_sel_list.
        ENDLOOP.

        prepare_alv( ).

        mo_salv->display( ).

      CATCH zcx_ca_dbacc INTO lx_error.
        MESSAGE lx_error TYPE c_msgty_i.

      CATCH cx_salv_error
            zcx_ca_param  INTO lx_error.
        MESSAGE lx_error TYPE c_msgty_s DISPLAY LIKE c_msgty_e.
    ENDTRY.
  ENDMETHOD.                    "process


  METHOD zif_ca_gos_boas_sellist~get_marked_docs.
    "-----------------------------------------------------------------*
    "    Determine marked documents and save into DB. Is only
    "    called by ZCL_CA_GOS_BOAS_POPUP->ON_PROCESS_FCODE.
    "-----------------------------------------------------------------*
    LOOP AT mt_sel_list ASSIGNING FIELD-SYMBOL(<ls_sel_list>)
                           WHERE attach EQ abap_true.
      INSERT CORRESPONDING #(
               <ls_sel_list>-o_archive_doc->ms_data ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.                    "zif_ca_gos_boas_sellist~get_marked_docs


  METHOD zif_ca_gos_boas_sellist~get_selected_entry.
    "-----------------------------------------------------------------*
    "   Get selected line
    "-----------------------------------------------------------------*
    READ TABLE mt_sel_list REFERENCE INTO result
                           INDEX iv_row.
    IF sy-subrc NE 0.
      "Marked/selected row not found -> Action not possible
      RAISE EXCEPTION TYPE zcx_ca_ui
        EXPORTING
          textid = zcx_ca_ui=>sel_row_not_found.
    ENDIF.
  ENDMETHOD.                    "zif_ca_gos_boas_sellist~get_selected_entry
ENDCLASS.
