@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header Root CDS View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_SALESORDHDR
  as select from ZI_SALESORDHDR
  composition [0..*] of ZE_SALESORDITEM as _item
{
  key Salesorder,
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
      _item
}
