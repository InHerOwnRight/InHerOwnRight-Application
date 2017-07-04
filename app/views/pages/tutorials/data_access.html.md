### Data access

PACSCL and the In Her Own Right participants are committed to providing full access to the project metadata.

</br>

#### API access

The In Her Own Right project exposes an API endpoint conforming with <a href="http://www.openarchives.org/" target="_blank">OAI-PMH</a> metadata harvesting standards. Records can be retrieved using any client or browser using standard OAI-PMH verbs.

##### Sample Requests:

Return all records from collection:

`curl "http://pacscl.neomindlabs.com/oai?verb=ListRecords&metadataPrefix=oai_dc"`

Return a specific record:

`curl "http://pacscl.neomindlabs.com/oai?verb=GetRecord&identifier=oai:pacscl/1&metadataPrefix=oai_dc"`


<div class="row">
  <div class="col-md-8">
  <h4>Tools for using the data</h4>
If you're new to working with raw data, consider these tools as a starting place.<br/>
<em>(For an extensive list of data tools for digital humanities, check out <a href="http://dirtdirectory.org/">DIRT Digital Research Tools</a>).</em>
<br/><br/>
<div style="margin: 0px 40px 0px 50px"><h4>Text analysis</h4>
<a href="https://voyant-tools.org">Voyant Tools</a> - web-based reading and analysis environment for digital texts.<br/><br/>

<h4>Timeline</h4>
<a href="http://timeline.knightlab.com/">TimelineJS</a> - create a timeline from spreadsheet data.<br/><br/>

<h4>Mapping</h4>
<a href="https://storymap.knightlab.com/">StoryMap</a> - combine images and maps to tell stories.<br/>
<a href="https://www.google.com/maps/about/mymaps/">Google My Maps</a> - create and share maps.<br/><br/>
</div>
</div>
<div class="col-md-4">
<h4>Tutorials on using tools</h4>
<i>forthcoming</i><br/><br/>
<h4>Examples of data use</h4>
<i>forthcoming</i><br/><br/>
</div>
</div>



