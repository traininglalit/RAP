@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header Proj CDS View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_VALIDATE_DROPDOWN'
define root view entity ZC_SALESORDHDR
  provider contract transactional_query
  as projection on ZR_SALESORDHDR
{
  key     Salesorder,
          Createdon,
          Creationtime,
          Personname,
          Quotationdate,
          Quotationbiddate,
          Documentdate,
          Documentcat,
          Transactiongrp,
          Salesordtype,
          Orderreason,
          Warrantydate,
          Netamount,
          Currency,
          Totalamount,
          @Semantics.amount.currencyCode: 'Currency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_CALCULATEAMT'
  virtual calculateAmt : abap.dec( 15, 2 ),
          /* Associations */
          _item : redirected to composition child ZC_SALESORDITEM
}
