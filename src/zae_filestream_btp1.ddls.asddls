@EndUserText.label: 'Abstract Entity for excel upload'
define root abstract entity ZAE_FILESTREAM_BTP1
{
  @Semantics.largeObject: {
  mimeType   : 'MimeType',
  fileName   : 'FileName'
  }
  @EndUserText.label: 'Upload Excel'
  FileStream : abap.rawstring( 0 );
  @Semantics.mimeType: true
  @UI.hidden : true
  MimeType   : abap.char( 128 );
  @UI.hidden : true
  FileName   : abap.char( 120 );
}
