## Sunspot::NoAdapterError in ImportPacsclCollectionsController#create
 
If you're re-importing collections and get this error, you need to rebuild the sunspot index and try again.i
It is likely related to old collections still being referenced. (I saw it after deleting all PacsclCollection records)y
