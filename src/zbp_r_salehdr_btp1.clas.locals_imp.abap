CLASS lsc_zr_salehdr_btp1 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zr_salehdr_btp1 IMPLEMENTATION.

  METHOD save_modified.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
    CALL METHOD zcl_cleardata_btp1=>clear_data( ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZR_SALEHDR_BTP1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_salehdr_btp1 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zr_salehdr_btp1 RESULT result.

    METHODS excelUpload FOR MODIFY
      IMPORTING keys FOR ACTION zr_salehdr_btp1~excelUpload.
    METHODS clearData FOR MODIFY
      IMPORTING keys FOR ACTION zr_salehdr_btp1~clearData RESULT result.

    METHODS processData FOR MODIFY
      IMPORTING keys FOR ACTION zr_salehdr_btp1~processData RESULT result.
    METHODS clearData1 FOR MODIFY
      IMPORTING keys FOR ACTION zr_salehdr_btp1~clearData1 RESULT result.

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
          lt_hdr           TYPE TABLE FOR CREATE zr_salehdr_btp1,
          lt_item          TYPE TABLE FOR CREATE zr_salehdr_btp1\_item,
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
        ls_deep-personname      = cl_abap_context_info=>get_user_technical_name( ). "<fs_group1>-personname.
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
        ls_deep-totalamount     = <fs_group1>-totalamount.

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
*********************************************************************
      "This part is applicable when you want to create header item from internal table
*    APPEND VALUE #(
*               %cid = lv_cid
*        salesorder = ls_create-salesorder
*        salesordtype = ls_create-salesordtype
*        personname      = ls_create-personname
*        createdon        = ls_create-createdon
*        creationtime     = ls_create-creationtime
*        quotationdate    = ls_create-quotationdate
*        quotationbiddate = ls_create-quotationbiddate
*        documentdate    = ls_create-documentdate
*        documentcat      = ls_create-documentcat
*        transactiongrp   = ls_create-transactiongrp
*        orderreason     = ls_create-orderreason
*        warrantydate    = ls_create-warrantydate
*        netamount        = ls_create-netamount
*        currency        = ls_create-currency
*        totalamount     = ls_create-totalamount
*                  ) TO lt_hdr.
*********************************************************************
      APPEND VALUE #(
                     salesorder = ls_create-salesorder
                     %cid_ref   = lv_cid
                    ) TO lt_item.

      lt_item[ 1 ]-%target = CORRESPONDING #( ls_create-item ).
      LOOP AT lt_item[ 1 ]-%target ASSIGNING FIELD-SYMBOL(<fs_target>).
        <fs_target>-%cid = <fs_target>-Itemuuid = cl_system_uuid=>create_uuid_x16_static( ).
      ENDLOOP.

      MODIFY ENTITIES OF zr_salehdr_btp1 IN LOCAL MODE
      ENTITY zr_salehdr_btp1
      CREATE FROM VALUE #(
                         (
                         %cid                      = lv_cid
                         %key-Salesorder           = ls_create-salesorder
                         %control-Salesorder       = if_abap_behv=>mk-on
                         salesordtype              = ls_create-salesordtype
                         %control-Salesordtype     = if_abap_behv=>mk-on
                         personname                = ls_create-personname
                         %control-Personname       = if_abap_behv=>mk-on
                         createdon                 = ls_create-createdon
                         %control-Createdon        = if_abap_behv=>mk-on
                         creationtime              = ls_create-creationtime
                         %control-Creationtime     = if_abap_behv=>mk-on
                         quotationdate             = ls_create-quotationdate
                         %control-quotationdate    = if_abap_behv=>mk-on
                         quotationbiddate          = ls_create-quotationbiddate
                         %control-quotationbiddate = if_abap_behv=>mk-on
                         documentdate              = ls_create-documentdate
                         %control-documentdate     = if_abap_behv=>mk-on
                         documentcat               = ls_create-documentcat
                         %control-documentcat      = if_abap_behv=>mk-on
                         transactiongrp            = ls_create-transactiongrp
                         %control-transactiongrp   = if_abap_behv=>mk-on
                         orderreason               = ls_create-orderreason
                         %control-orderreason      = if_abap_behv=>mk-on
                         warrantydate              = ls_create-warrantydate
                         %control-warrantydate     = if_abap_behv=>mk-on
                         netamount                 = ls_create-netamount
                         %control-netamount        = if_abap_behv=>mk-on
                         currency                  = ls_create-currency
                         %control-currency         = if_abap_behv=>mk-on
                         totalamount               = ls_create-totalamount
                         %control-totalamount      = if_abap_behv=>mk-on
                         )
                         )
                         CREATE BY \_item
                         FIELDS ( salesorder salesitem itemuuid material batchnumber materialgroup refmaterial
                                  netitemamount currency )
                         WITH lt_item
                         MAPPED DATA(lt_mapped)
                         REPORTED DATA(lt_reported)
                         FAILED DATA(lt_failed).
    ENDLOOP.
    "Below code is the create header item from internal table
*      MODIFY ENTITIES OF zr_salehdr_btp1 IN LOCAL MODE
*      ENTITY zr_salehdr_btp1
*      CREATE FIELDS ( Salesorder salesordtype personname createdon creationtime quotationdate quotationbiddate
*                documentdate documentcat transactiongrp orderreason warrantydate netamount currency totalamount
*                         )
*      WITH lt_hdr
*                         CREATE BY \_item
*                         FIELDS ( salesorder salesitem itemuuid material batchnumber materialgroup refmaterial
*                                  netitemamount currency )
*                         WITH lt_item
*                         MAPPED DATA(lt_mapped)
*                         REPORTED DATA(lt_reported)
*                         FAILED DATA(lt_failed).
  ENDMETHOD.

  METHOD clearData.
    DATA: lv_user TYPE sy-uname.
*    lv_user = cl_abap_context_info=>get_user_technical_name( ).
*    CALL METHOD zcl_cleardata_btp1=>clear_data( lv_user ).
*    SELECT *
*    FROM zdb_salehdr_btp1
*    WHERE Personname = @lv_user
*    INTO TABLE @DATA(lt_hdr).
*
*    IF lt_hdr IS NOT INITIAL.
*      SELECT *
*      FROM zdb_saleitm_btp1
*      FOR ALL ENTRIES IN @lt_hdr
*      WHERE Salesorder = @lt_hdr-Salesorder
*      INTO TABLE @DATA(lt_item).
*    ENDIF.
*    DELETE zdb_salehdr_btp1 FROM TABLE @lt_hdr.
*    DELETE zdb_saleitm_btp1 FROM TABLE @lt_item.
  ENDMETHOD.

  METHOD processData.

    DATA:
      ls_business_data TYPE zsrv_api_salesorder=>tys_sales_order_type,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_create,
      lo_response      TYPE REF TO /iwbep/if_cp_response_create.


    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    SELECT *
    FROM zc_salehdr_btp1
    WHERE Personname = @lv_user
    INTO TABLE @DATA(lt_hdr).

    IF lt_hdr IS NOT INITIAL.
      SELECT *
      FROM zc_saleitm_btp1
      FOR ALL ENTRIES IN @lt_hdr
      WHERE Salesorder = @lt_hdr-Salesorder
      INTO TABLE @DATA(lt_item).
    ENDIF.


    TRY.
        " Create http client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = '<Comm Scenario>'
                                                     comm_system_id = '<Comm System Id>'
                                                     service_id     = '<Service Id>' ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v4_remote_proxy(
          EXPORTING
             is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                 proxy_model_id      = 'ZSRV_API_SALESORDER'
                                                 proxy_model_version = '0001' )
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/sap/opu/odata4/sap/api_salesorder/srvd_a2x/sap/salesorder/0001' ).
        ASSERT lo_http_client IS BOUND.


* Prepare business data
        ls_business_data = VALUE #(
                  sales_order                 = 'SalesOrder'
                  sales_order_type_2          = 'SalesOrderType2'
                  sales_order_processing_typ  = 'SalesOrderProcessingTyp'
                  sold_to_party               = 'SoldToParty'
                  sales_organization          = 'SalesOrganization'
                  distribution_channel        = 'DistributionChannel'
                  reference_distribution_cha  = 'ReferenceDistributionCha'
                  organization_division       = 'OrganizationDivision'
                  sales_office                = 'SalesOffice'
                  sales_group                 = 'SalesGroup'
                  sales_district              = 'SalesDistrict'
                  created_by_user             = 'CreatedByUser'
                  creation_date               = '20170101'
                  creation_time               = 123000
                  last_change_date_time       = 20170101123000
                  last_changed_by_user        = 'LastChangedByUser'
                  purchase_order_by_customer  = 'PurchaseOrderByCustomer'
                  purchase_order_by_ship_to   = 'PurchaseOrderByShipTo'
                  customer_purchase_order_ty  = 'CustomerPurchaseOrderTy'
                  customer_purchase_order_da  = '20170101'
                  business_solution_order     = 'BusinessSolutionOrder'
                  reference_sddocument        = 'ReferenceSddocument'
                  reference_sddocument_categ  = 'ReferenceSddocumentCateg'
                  sddocument_reason           = 'SddocumentReason'
                  sales_order_date            = '20170101'
                  requested_delivery_date     = '20170101'
                  pricing_date                = '20170101'
                  services_rendered_date      = '20170101'
                  billing_document_date       = '20170101'
                  proposed_billing_document   = 'ProposedBillingDocument'
                  total_net_amount            = 5550
                  transaction_currency        = 'TransactionCurrency'
                  delivery_date_type_rule     = 'DeliveryDateTypeRule'
                  shipping_condition          = 'ShippingCondition'
                  complete_delivery_is_defin  = abap_true
                  sls_doc_is_rlvt_for_proof   = abap_true
                  shipping_type               = 'ShippingType'
                  receiving_point             = 'ReceivingPoint'
                  means_of_transport_type     = 'MeansOfTransportType'
                  means_of_transport_ref_mat  = 'MeansOfTransportRefMat'
                  special_processing_code     = 'SpecialProcessingCode'
                  incoterms_classification    = 'IncotermsClassification'
                  incoterms_version           = 'IncotermsVersion'
                  incoterms_location_1        = 'IncotermsLocation1'
                  incoterms_location_2        = 'IncotermsLocation2'
                  sdpricing_procedure         = 'SdpricingProcedure'
                  customer_price_group        = 'CustomerPriceGroup'
                  price_list_type             = 'PriceListType'
                  fixed_value_date            = '20170101'
                  tax_departure_country       = 'TaxDepartureCountry'
                  vatregistration_country     = 'VatregistrationCountry'
                  is_eutriangular_deal        = abap_true
                  customer_payment_terms      = 'CustomerPaymentTerms'
                  payment_method              = 'PaymentMethod'
                  billing_company_code        = 'BillingCompanyCode'
                  controlling_area            = 'ControllingArea'
                  customer_account_assignmen  = 'CustomerAccountAssignmen'
                  assignment_reference        = 'AssignmentReference'
                  accounting_doc_external_re  = 'AccountingDocExternalRe'
                  customer_credit_account     = 'CustomerCreditAccount'
                  header_billing_block_reaso  = 'HeaderBillingBlockReaso'
                  delivery_block_reason       = 'DeliveryBlockReason'
                  sales_order_approval_reaso  = 'SalesOrderApprovalReaso'
                  customer_group              = 'CustomerGroup'
                  additional_customer_group   = 'AdditionalCustomerGroup'
                  additional_customer_grou_2  = 'AdditionalCustomerGrou2'
                  additional_customer_grou_3  = 'AdditionalCustomerGrou3'
                  additional_customer_grou_4  = 'AdditionalCustomerGrou4'
                  additional_customer_grou_5  = 'AdditionalCustomerGrou5'
                  overall_sdprocess_status    = 'OverallSdprocessStatus'
                  overall_delivery_block_sta  = 'OverallDeliveryBlockSta'
                  overall_billing_block_stat  = 'OverallBillingBlockStat'
                  overall_delivery_status     = 'OverallDeliveryStatus'
                  total_credit_check_status   = 'TotalCreditCheckStatus'
                  overall_sddocument_rejecti  = 'OverallSddocumentRejecti'
                  total_block_status          = 'TotalBlockStatus'
                  hdr_general_incompletion_s  = 'HdrGeneralIncompletionS'
                  ovrl_itm_general_incomplet  = 'OvrlItmGeneralIncomplet'
                  overall_sddoc_reference_st  = 'OverallSddocReferenceSt'
                  sales_doc_approval_status   = 'SalesDocApprovalStatus'
                  overall_chml_cmplnc_status  = 'OverallChmlCmplncStatus'
                  overall_dangerous_goods_st  = 'OverallDangerousGoodsSt'
                  overall_safety_data_sheet   = 'OverallSafetyDataSheet'
                  overall_trd_cmplnc_embargo  = 'OverallTrdCmplncEmbargo'
                  ovrl_trd_cmplnc_snctnd_lis  = 'OvrlTrdCmplncSnctndLis'
                  ovrl_trd_cmplnc_legal_ctrl  = 'OvrlTrdCmplncLegalCtrl'
                  sales_order_down_payment_s  = 'SalesOrderDownPaymentS'
                  overall_ord_reltd_billg_st  = 'OverallOrdReltdBillgSt' ).

        " Navigate to the resource and create a request for the create operation
        lo_request = lo_client_proxy->create_resource_for_entity_set( 'SALES_ORDER' )->create_request_for_create( ).

        " Set the business data for the created entity
        lo_request->set_business_data( ls_business_data ).

        " Execute the request
        lo_response = lo_request->execute( ).

        " Get the after image
*lo_response->get_business_data( IMPORTING es_business_data = ls_business_data ).

      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection


      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception

      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        RAISE SHORTDUMP lx_web_http_client_error.

    ENDTRY.
  ENDMETHOD.

  METHOD clearData1.
    DATA: lv_user TYPE sy-uname.
    lv_user = cl_abap_context_info=>get_user_technical_name( ).
    CALL METHOD zcl_cleardata_btp1=>clear_data( lv_user ).
  ENDMETHOD.

ENDCLASS.
