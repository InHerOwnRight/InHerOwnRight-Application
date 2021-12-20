## Sunspot::NoAdapterError in ImportPacsclCollectionsController#create
 
If you're re-importing collections and get this error, you need to rebuild the sunspot index and try again.i
It is likely related to old collections still being referenced. (I saw it after deleting all PacsclCollection records)y

## Delete Records, given a list of slugs

slugs = ["oai-digitalcollections-tricolib-brynmawr-edu-sc_212841", "oai-digitalcollections-tricolib-brynmawr-edu-sc_212839"]
records = slugs.map{|slug| Record.find_by_slug(slug)}.compact
raw_records = record.map(&:raw_record).compact
records.each(&:delete)
raw_records.each(&:delete)


## Reprocess image files after updating S3

slugs = ["oai-idea-library-drexel-edu-lca_147825","oai-digitalcollections-tricolib-brynmawr-edu-sc_158919","oai-digitalcollections-tricolib-brynmawr-edu-sc_158920","oai-digitalcollections-tricolib-brynmawr-edu-sc_213057","oai-digitalcollections-tricolib-brynmawr-edu-sc_212860","oai-digitalcollections-tricolib-brynmawr-edu-sc_212842","oai-digital-library-temple-edu-p15037coll19-741","oai-digital-library-temple-edu-p15037coll19-744"]
records = slugs.map{ |slug| Record.find_by_slug(slug) }.compact
records.each(&:rescan_images!)

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
Replace the 2 CSS include tags and 2 Javscript tags with Rails helpers that load the assets from the asset pipeline (stylesheet_link_tag and javascript_include_tag).

### Other files

In the root folder, copy the files jit-yc.js and jit.js into app/assets/javascripts/
In the Extras folder, copy the file excanvas.js into app/assets/javascripts/
Copy the contents of the Examples/css folder into app/assets/stylesheets/visualizations/. There should be 3 CSS files and 3 pngs
