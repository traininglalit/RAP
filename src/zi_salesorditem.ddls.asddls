@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Intf CDS View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SALESORDITEM
  as select from zdb_salesorditem
{
  key salesorder    as Salesorder,
  key salesitem     as Salesitem,
      material      as Material,
      batchnumber   as Batchnumber,
      materialgroup as Materialgroup,
      refmaterial   as Refmaterial,
      netitemamount as Netitemamount,
      currency      as Currency
}
