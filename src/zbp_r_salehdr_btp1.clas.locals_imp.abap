CLASS lhc_ZR_SALEHDR_BTP1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_salehdr_btp1 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zr_salehdr_btp1 RESULT result.

    METHODS excelUpload FOR MODIFY
      IMPORTING keys FOR ACTION zr_salehdr_btp1~excelUpload.

ENDCLASS.

CLASS lhc_ZR_SALEHDR_BTP1 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD excelUpload.
    TYPES: BEGIN OF lty_excel,
             "Header Fields
             salesorder       TYPE zr_salehdr_btp1-Salesorder,
             salesordtype     TYPE zr_salehdr_btp1-Salesordtype,
             personname       TYPE zr_salehdr_btp1-Personname,
             createdon        TYPE zr_salehdr_btp1-Createdon,
             creationtime     TYPE zr_salehdr_btp1-Creationtime,
             quotationdate    TYPE zr_salehdr_btp1-Quotationdate,
             quotationbiddate TYPE zr_salehdr_btp1-Quotationbiddate,
             documentdate     TYPE zr_salehdr_btp1-Documentdate,
             documentcat      TYPE zr_salehdr_btp1-Documentcat,
             transactiongrp   TYPE zr_salehdr_btp1-Transactiongrp,
             orderreason      TYPE zr_salehdr_btp1-Orderreason,
             warrantydate     TYPE zr_salehdr_btp1-Warrantydate,
             netamount        TYPE zr_salehdr_btp1-Netamount,
             currency         TYPE zr_salehdr_btp1-Currency,
             totalamount      TYPE zr_salehdr_btp1-Totalamount,
             "Item Fields
             salesorderitem   TYPE ze_saleitm_btp1-Salesorder,
             salesitem        TYPE ze_saleitm_btp1-Salesitem,
             itemuuid         TYPE ze_saleitm_btp1-Itemuuid,
             material         TYPE ze_saleitm_btp1-Material,
             batchnumber      TYPE ze_saleitm_btp1-Batchnumber,
             materialgroup    TYPE ze_saleitm_btp1-Materialgroup,
             refmaterial      TYPE ze_saleitm_btp1-Refmaterial,
             netitemamount    TYPE ze_saleitm_btp1-Netitemamount,
             currencyitem     TYPE ze_saleitm_btp1-Currency,
           END OF lty_excel,

           BEGIN OF lty_item,
             salesorder    TYPE ze_saleitm_btp1-Salesorder,
             salesitem     TYPE ze_saleitm_btp1-Salesitem,
             itemuuid      TYPE ze_saleitm_btp1-Itemuuid,
             material      TYPE ze_saleitm_btp1-Material,
             batchnumber   TYPE ze_saleitm_btp1-Batchnumber,
             materialgroup TYPE ze_saleitm_btp1-Materialgroup,
             refmaterial   TYPE ze_saleitm_btp1-Refmaterial,
             netitemamount TYPE ze_saleitm_btp1-Netitemamount,
             currency      TYPE ze_saleitm_btp1-Currency,
           END OF lty_item,

           ltty_item TYPE lty_item,

           BEGIN OF lty_deep,
             "Header Fields
             salesorder       TYPE zr_salehdr_btp1-Salesorder,
             salesordtype     TYPE zr_salehdr_btp1-Salesordtype,
             personname       TYPE zr_salehdr_btp1-Personname,
             createdon        TYPE zr_salehdr_btp1-Createdon,
             creationtime     TYPE zr_salehdr_btp1-Creationtime,
             quotationdate    TYPE zr_salehdr_btp1-Quotationdate,
             quotationbiddate TYPE zr_salehdr_btp1-Quotationbiddate,
             documentdate     TYPE zr_salehdr_btp1-Documentdate,
             documentcat      TYPE zr_salehdr_btp1-Documentcat,
             transactiongrp   TYPE zr_salehdr_btp1-Transactiongrp,
             orderreason      TYPE zr_salehdr_btp1-Orderreason,
             warrantydate     TYPE zr_salehdr_btp1-Warrantydate,
             netamount        TYPE zr_salehdr_btp1-Netamount,
             currency         TYPE zr_salehdr_btp1-Currency,
             totalamount      TYPE zr_salehdr_btp1-Totalamount,
             "Item Fields
             item             TYPE TABLE OF ltty_item WITH EMPTY KEY,
           END OF lty_deep.

    DATA: lt_excel         TYPE STANDARD TABLE OF lty_excel,
          lv_excel_content TYPE xstring,
          lt_deep          TYPE STANDARD TABLE OF lty_deep,
          ls_deep          TYPE lty_deep,
          ls_item          TYPE lty_item.

    lv_excel_content = VALUE #( keys[ 1 ]-%param-_filestream-FileStream OPTIONAL ).
    DATA(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_excel_content )->read_access( ).
    DATA(lo_workbook) = lo_xlsx->get_workbook( )->worksheet->at_position( iv_position = 1 ).

    DATA(lo_selection_parameter) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
    )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( iv_alphabetic_value = 'A' )
    )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( iv_alphabetic_value = 'V' )
    )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 3 )  )->get_pattern( ).

    lo_workbook->select( lo_selection_parameter )->row_stream( )->operation->write_to(
      EXPORTING
        it_internal_table = REF #( lt_excel )
         )->set_value_transformation(
  xco_cp_xlsx_read_access=>value_transformation->string_value )->if_xco_xlsx_ra_operation~execute( ).

    SORT lt_excel BY salesorder.
    LOOP AT lt_excel INTO DATA(ls_excel) GROUP BY ( salesorder = ls_excel-salesorder ) ASCENDING
                                         ASSIGNING FIELD-SYMBOL(<fs_group>).
      CLEAR: ls_deep,
             ls_item.
      LOOP AT GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fs_group1>).
        ls_deep-salesorder = <fs_group1>-salesorder.
        ls_deep-salesordtype = <fs_group1>-salesordtype.
        ls_deep-personname      = <fs_group1>-personname.
        ls_deep-createdon        = <fs_group1>-createdon.
        ls_deep-creationtime     = <fs_group1>-creationtime.
        ls_deep-quotationdate    = <fs_group1>-quotationdate.
        ls_deep-quotationbiddate = <fs_group1>-quotationbiddate.
        ls_deep-documentdate    = <fs_group1>-documentdate.
        ls_deep-documentcat      = <fs_group1>-documentcat.
        ls_deep-transactiongrp   = <fs_group1>-transactiongrp.
        ls_deep-orderreason     = <fs_group1>-orderreason.
        ls_deep-warrantydate    = <fs_group1>-warrantydate.
        ls_deep-netamount        = <fs_group1>-netamount.
        ls_deep-currency        = <fs_group1>-currency.
        ls_deep-totalamount         = <fs_group1>-totalamount.

        ls_item-salesorder = <fs_group1>-salesorder.
        ls_item-salesitem = <fs_group1>-salesitem.
*  itemuuid = <fs_g
        ls_item-material = <fs_group1>-material.
        ls_item-batchnumber = <fs_group1>-batchnumber.
        ls_item-materialgroup = <fs_group1>-materialgroup.
        ls_item-refmaterial = <fs_group1>-refmaterial.
        ls_item-netitemamount = <fs_group1>-netitemamount.
        ls_item-currency = <fs_group1>-currency.

        APPEND ls_item TO ls_deep-item.
      ENDLOOP.
      APPEND ls_deep TO lt_deep.
    ENDLOOP.
    DATA(lv_cid) = cl_system_uuid=>create_uuid_x16_static( ).
    LOOP AT lt_deep INTO DATA(ls_create).
      MODIFY ENTITIES OF zr_salehdr_btp1 IN LOCAL MODE
      ENTITY zr_salehdr_btp1
      CREATE FROM VALUE #(
                         (
                         %cid = lv_cid
                         %key-Salesorder = ls_create-salesorder
                         %control-Salesorder = if_abap_behv=>mk-on
                   salesordtype = ls_create-salesordtype
                   %control-Salesordtype = if_abap_behv=>mk-on
                   personname      = ls_create-personname
                   %control-Personname = if_abap_behv=>mk-on
                   createdon   = ls_create-createdon
                   %control-Createdon = if_abap_behv=>mk-on
                   creationtime     = ls_create-creationtime
                   %control-Creationtime = if_abap_behv=>mk-on

                         )
                         )
                         MAPPED DATA(ls_mapped)
                         REPORTED DATA(lt_reported)
                         FAILED DATA(lt_failed).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
