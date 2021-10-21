## Sunspot::NoAdapterError in ImportPacsclCollectionsController#create
 
If you're re-importing collections and get this error, you need to rebuild the sunspot index and try again.i
It is likely related to old collections still being referenced. (I saw it after deleting all PacsclCollection records)y

## Update visualization at /visualization

### InHORVisualization.js

Unzip the visualization file, and identify the new JS source within Example/RGraph, then copy it into place like this:

    cp Examples/RGraph/InHORVisualization-edited-final-20211015.js ~/Projects/pacscl-rails/app/assets/javascripts/visualizations/InHORVisualization.js

Add the following lines to the end of the file:

    $( document ).on('turbolinks:load', function() {
      init();
    })

### InHORVisualization.html

Copy the contents of Examples/RGraph/InHORVisualization-edited-final-yyyymmdd.html into app/views/visualization/index.html.erb
Edit the script tag that references "InHORVisualization-edited-final.js" to match the filename you targeted in the previous step, e.g. "InHORVisualization.js"

### Other files

In the root folder, copy the files jit-yc.js and jit.js into app/assets/javascripts/
In the Extras folder, copy the file excanvas.js into app/assets/javascripts/
Copy the contents of the Examples/css folder into app/assets/stylesheets/visualizations/. There should be 3 CSS files and 3 pngs
