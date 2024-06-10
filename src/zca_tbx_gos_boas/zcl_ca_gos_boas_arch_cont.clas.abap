"! <p class="shorttext synchronized" lang="en">CA-TBX: GOS: Enhanced BO archive content handler</p>
CLASS zcl_ca_gos_boas_arch_cont DEFINITION PUBLIC
                                           INHERITING FROM zcl_ca_archive_content
                                           FINAL
                                           CREATE PUBLIC.
* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   c o n s t a n t s
    CONSTANTS:
      "! <p class="shorttext synchronized" lang="en">Type Id</p>
      c_my_typeid_gos_boas TYPE sibftypeid VALUE 'ZCL_CA_GOS_BOAS_ARCH_CONT' ##no_text.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Constructor</p>
      "!
      "! @parameter is_lpor      | <p class="shorttext synchronized" lang="en">Workflow instance key</p>
      "! @parameter is_bo_key    | <p class="shorttext synchronized" lang="en">Business object/class key - BOR Compatible</p>
      "! @raising   zcx_ca_param | <p class="shorttext synchronized" lang="en">Common exception: Parameter error (INHERIT from this excep!)</p>
      "! @raising   zcx_ca_dbacc | <p class="shorttext synchronized" lang="en">Common exception: Database access</p>
      constructor
        IMPORTING
          is_lpor   TYPE sibflpor  OPTIONAL
          is_bo_key TYPE sibflporb OPTIONAL
        RAISING
          zcx_ca_param
          zcx_ca_dbacc,

      "! <p class="shorttext synchronized" lang="en">Get in GOS marked documents</p>
      "!
      "! @parameter rt_docs | <p class="shorttext synchronized" lang="en">ArchiveLink document instances</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      get_marked_docs
*      "! @parameter it_filter_al  | <p class="shorttext synchronized" lang="en">Filter for ArchiveLink result (use C_AL_FILT_*)</p>
*      "! @parameter is_filter_dms | <p class="shorttext synchronized" lang="en">Filter for DMS result - at least DOKOB (use C_DMS_FILT_*)</p>
*        IMPORTING
*          it_filter_al   TYPE cl_alink_connection=>toarange_d_tab OPTIONAL
*          is_filter_dms  TYPE zca_s_dms_filter OPTIONAL
        RETURNING
          VALUE(rt_docs) TYPE zca_tt_archive_docs
        RAISING
          zcx_ca_archive_content.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_CA_GOS_BOAS_ARCH_CONT IMPLEMENTATION.


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    super->constructor( is_lpor   = is_lpor
                        is_bo_key = is_bo_key ).

    "Set new LPOR type
    ms_lpor-typeid = c_my_typeid_gos_boas.
  ENDMETHOD.                    "constructor


  METHOD get_marked_docs.
    "-----------------------------------------------------------------*
    "   Get in GOS marked documents
    "-----------------------------------------------------------------*
    "Local data definitions
    FIELD-SYMBOLS:
      <ls_marked>        TYPE zca_gos_bomd.

    DATA:
      lt_filter_al  TYPE cl_alink_connection=>toarange_d_tab,
      ls_filter_dms TYPE zca_s_dms_filter.

    "Enhance filter by object keys of marked documents. Otherwise it
    "comes to an overflow, because much to much documents would be read.
    DATA(lv_gen_key) = CONV saeobjid( ms_bo_key-instid && '%' ).

    SELECT * INTO  TABLE @DATA(lt_marked)
             FROM  zca_gos_bomd
             WHERE sap_object EQ   @ms_bo_key-typeid
               AND object_id  LIKE @lv_gen_key.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    "Called by print / mail program?
    "Explanation: If the table is already filled the class instance is normally
    "created by the GOS consumer class. Within a print or mail programs the GET method
    "shouldn't be necessary, but should only access the marked documents by this method.
    IF mt_docs IS INITIAL.
      "Prepare ArchiveLink filter
      LOOP AT lt_marked ASSIGNING <ls_marked>
                        WHERE dokob IS INITIAL
                          AND objky IS INITIAL.
        APPEND VALUE #( dsign   = mo_sel_options->sign-incl
                        doption = mo_sel_options->option-eq
                        name    = mo_arch_filter->al_filter-arch_id
                        dlow    = <ls_marked>-archiv_id ) TO lt_filter_al.
        APPEND VALUE #( dsign   = mo_sel_options->sign-incl
                        doption = mo_sel_options->option-eq
                        name    = mo_arch_filter->al_filter-doc_id
                        dlow    = <ls_marked>-arc_doc_id ) TO lt_filter_al.
      ENDLOOP.

      SORT lt_filter_al.
      DELETE ADJACENT DUPLICATES FROM lt_filter_al.

      "Prepare DMS filter
      ls_filter_dms-t_sel_drad = CORRESPONDING #( lt_marked ).
      SORT ls_filter_dms-t_sel_drad.
      DELETE ADJACENT DUPLICATES FROM ls_filter_dms-t_sel_drad COMPARING ALL FIELDS.
      DELETE ls_filter_dms-t_sel_drad WHERE dokob IS INITIAL
                                         OR objky IS INITIAL.

      "Get documents from AL and DMS
      get( iv_refresh       = abap_true
           it_filter_al     = lt_filter_al
           is_filter_dms    = ls_filter_dms
           iv_only_act_vers = abap_false           "Always every version to catch up
           iv_only_rel_vers = abap_false ).        "any marked document
    ENDIF.

    "Now all docs are available -> pick the marked docs only
    LOOP AT lt_marked ASSIGNING <ls_marked>.
      READ TABLE mt_docs INTO DATA(lo_doc)
                 WITH KEY table_line->ms_data-archiv_id  = <ls_marked>-archiv_id
                          table_line->ms_data-arc_doc_id = <ls_marked>-arc_doc_id.
      IF sy-subrc EQ 0.
        APPEND lo_doc TO rt_docs.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "get_marked_docs
ENDCLASS.
