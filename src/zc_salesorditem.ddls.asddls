@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Proj CDS View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_SALESORDITEM
  as projection on ZE_SALESORDITEM
{
  key Salesorder,
  key Salesitem,
      Material,
      Batchnumber,
      Materialgroup,
      Refmaterial,
      Netitemamount,
      Currency,
      /* Associations */
      _header : redirected to parent ZC_SALESORDHDR
}
