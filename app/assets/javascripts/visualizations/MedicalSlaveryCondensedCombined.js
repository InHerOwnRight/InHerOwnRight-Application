var labelType, useGradients, nativeTextSupport, animate;

(function() {
  var ua = navigator.userAgent,
      iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
      typeOfCanvas = typeof HTMLCanvasElement,
      nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
      textSupport = nativeCanvasSupport
        && (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
  //I'm setting this based on the fact that ExCanvas provides text support for IE
  //and that as of today iPhone/iPad current text support is lame
  labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML';
  nativeTextSupport = labelType == 'Native';
  useGradients = nativeCanvasSupport;
  animate = !(iStuff || !nativeCanvasSupport);
})();

var Log = {
  elem: false,
  write: function(text){
    if (!this.elem)
      this.elem = document.getElementById('log');
    this.elem.innerHTML = text;
    this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
  }
};


function init(){
    //init data
    var json = {
        id: "190_0",
        name: "In Her Own Right",
        children: [{
        id: "Medical Women",
        name: "Medical Women",
        children: [{
            id: "https://id.loc.gov/authorities/subjects/sh85082916.html",
            name: "Medical education",
            data: {
                relation: "<h1>Medical education</h1>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Medical+education&search_field=all_fields' target='new'>Medical education.</a>"
            },
            children: [{
            id: "https://id.loc.gov/authorities/subjects/sh85093422.html",
            name: "Nursing schools",
            data: {
                relation: "<h1>Nursing schools</h1><br><h2>Nursing schools</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Nursing+schools&search_field=all_fields' target='new'>Nursing schools.</a><br><h2>Nursing schools--Pennsylvania--Philadelphia</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Nursing+schools--Pennsylvania--Philadelphia&search_field=all_fields' target='new'>Nursing schools--Pennsylvania--Philadelphia.</a><br><h2>Nursing--Study and teaching (Continuing education)</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Nursing--Study+and+teaching+(Continuing+education)&search_field=all_fields' target='new'>Nursing--Study and teaching (Continuing education).</a><br><h2>Mercy-Douglass Hospital (Philadelphia, Pa.). School of Nursing</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Mercy-Douglass+Hospital+(Philadelphia,+Pa.).+School+of+Nursing&search_field=all_fields' target='new'>Mercy-Douglass Hospital (Philadelphia, Pa.). School of Nursing.</a><br><h2>Johns Hopkins Hospital. School of Nursing</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Johns+Hopkins+Hospital.+School+of+Nursing&search_field=all_fields' target='new'>Johns Hopkins Hospital. School of Nursing.</a><br><h2>African American nursing schools</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=African+American+nursing+schools&search_field=all_fields' target='new'>African American nursing schools.</a>"
            },
            children: []
        }, {
            id: "http://id.loc.gov/authorities/subjects/sh85147645",
            name: "Women medical students",
            data: {
                relation: "<h1>Women medical students</h1><br><h2>Women medical students</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+medical+students&search_field=all_fields' target='new'>Women medical students.</a><h2>Women medical students--Clothing</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+medical+students--Clothing&search_field=all_fields' target='new'>Women medical students--Clothing.</a><br><h2>Women medical students--India</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+medical+students--India&search_field=all_fields' target='new'>Women medical students--India.</a><br><h2>Women medical students--Recruiting</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+medical+students--Recruiting&search_field=all_fields' target='new'>Women medical students--Recruiting.</a><br><h2>Women medical students--Social life and customs</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+medical+students--Social+life+and+customs&search_field=all_fields' target='new'>Women medical students--Social life and customs.</a><br><h2>Bennett Medical College</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Bennett+Medical+College&search_field=all_fields' target='new'>Bennett Medical College.</a><br><h2>Interns (Medicine)</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Interns+(Medicine)&search_field=all_fields' target='new'>Interns (Medicine).</a><br><h2>New York Medical College and Hospital for Women</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=New+York+Medical+College+and+Hospital+for+Women&search_field=all_fields' target='new'>New York Medical College and Hospital for Women.</a>"
            },
            children: []
        },{
            id: "https://lccn.loc.gov/n50080178",
            name: "Woman's Medical College of Pennsylvania",
            data: {
                relation: "<h1>Woman's Medical College of Pennsylvania</h1><br><h2>Woman's Medical College of Pennsylvania</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+College+of+Pennsylvania&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Medical College of Pennsylvania--Administration</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+College+of+Pennsylvania--Administration&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Medical College of Pennsylvania--Admission</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+College+of+Pennsylvania--Admission&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Medical College of Pennsylvania--Alumni and alumnae</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+College+of+Pennsylvania--Alumni+and+alumnae&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Medical College of Pennsylvania--Buildings</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+College+of+Pennsylvania--Buildings&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Medical College of Pennsylvania--Curricula</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+College+of+Pennsylvania--Curricula&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Medical College of Pennsylvania--Faculty</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+College+of+Pennsylvania--Faculty&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Medical College of Pennsylvania--Graduate students</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+College+of+Pennsylvania--Graduate+students&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Medical College of Pennsylvania--History</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+College+of+Pennsylvania--History&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Medical College of Pennsylvania--Student housing</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+College+of+Pennsylvania--Student+housing&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Medical College of Pennsylvania--Students</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+College+of+Pennsylvania--Students&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Medical college of the New York Infirmary</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Medical+college+of+the+New+York+Infirmary&search_field=all_fields' target='new'>click here.</a><br><h2>Hospital and Dispensary of the Alumnae of the Woman's Medical College of Pennsylvania</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Hospital+and+Dispensary+of+the+Alumnae+of+the+Woman's+Medical+College+of+Pennsylvania&search_field=all_fields' target='new'>click here.</a>"
            },
            children: []
        },{
            id: "https://lccn.loc.gov/n95803086",
            name: "Female Medical College of Pennsylvania",
            data: {
                relation: "<h1>Female Medical College of Pennsylvania</h1><h2>Female Medical College of Pennsylvania</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Female+Medical+College+of+Pennsylvania&search_field=all_fields' target='new'>click here.</a><br><h2>Female Medical College of Pennsylvania--Students</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Female+Medical+College+of+Pennsylvania--Students&search_field=all_fields' target='new'>click here.</a>"
            },
            children: []
        },{
            id: "https://id.loc.gov/authorities/subjects/sh85120606.html",
            name: "Sex discrimination in medical education",
            data: {
                relation: "<h1>Sex discrimination in medical education</h1><h2>Sex discrimination in medical education</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Sex+discrimination+in+medical+education&search_field=all_fields' target='new'>click here.</a>"
            }}],
        },
                   {
            id: "http://id.loc.gov/authorities/subjects/sh85147591",
            name: "Women in medicine",
            data: {
                relation: "<h1>Women in medicine</h1><h2>Women in medicine</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+in+medicine&search_field=all_fields' target='new'>click here.</a><br><h2>Women in medicine--History</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+in+medicine--History&search_field=all_fields' target='new'>click here.</a><br><h2>Women in medicine--South Carolina</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+in+medicine--South+Carolina&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's hospitals--Medical staff</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+hospitals--Medical+staff&search_field=all_fields' target='new'>click here.</a><br><h2>Woman's Hospital of Philadelphia</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Woman's+Hospital+of+Philadelphia&search_field=all_fields' target='new'>click here.</a><br><h2>American Women's Hospitals</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=American+Women's+Hospitals&search_field=all_fields' target='new'>click here.</a>"
            },
            children: [{
                id: "https://id.loc.gov/authorities/subjects/sh85093349.html",
            name: "Nurses",
            data: {
                relation: "<h1>Nurses</h1><h2>Nurses</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Nurses&search_field=all_fields' target='new'>click here.</a><br><h2>Nurses--Training of</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Nurses--Training+of&search_field=all_fields' target='new'>click here.</a><br><h2>Nurses, Black</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Nurses,+Black&search_field=all_fields' target='new'>click here.</a><br><h2>Nurses, Foreign</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Nurses,+Foreign&search_field=all_fields' target='new'>click here.</a><br><h2>Nursing</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Nursing&search_field=all_fields' target='new'>click here.</a><br><h2>African American nurses</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=African+American+nurses&search_field=all_fields' target='new'>click here.</a><br><h2>Women nurses</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+nurses&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },{
                id: "http://id.loc.gov/authorities/subjects/sh85147674",
            name: "Women physicians",
            data: {
                relation: "<h1>Women physicians</h1><h2>Women physicians</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+physicians&search_field=all_fields' target='new'>click here.</a><br><h2>Women physicians--China</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+physicians--China&search_field=all_fields' target='new'>click here.</a><br><h2>Women physicians--India</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+physicians--India&search_field=all_fields' target='new'>click here.</a><br><h2>Women physicians--Obituaries</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+physicians--Obituaries&search_field=all_fields' target='new'>click here.</a><br><h2>Women physicians--Philadelphia (Pa.)</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+physicians--Philadelphia+(Pa.)&search_field=all_fields' target='new'>click here.</a><br><h2>Women physicians--Syria</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+physicians--Syria&search_field=all_fields' target='new'>click here.</a><br><h2>African American women physicians</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=African+American+women+physicians&search_field=all_fields' target='new'>click here.</a><br><h2>Indian women physicians</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Indian+women+physicians&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
                  {
                id: "https://id.loc.gov/authorities/subjects/sh85083102.html",
            name: "Medicine--Societies, etc",
            data: {
                relation: "<h1>Medicine--Societies, etc</h1><h2>Medicine--Societies, etc</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Medicine--Societies,+etc&search_field=all_fields' target='new'>click here.</a><br><h2>Connecticut State Medical Society</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Connecticut+State+Medical+Society&search_field=all_fields' target='new'>click here.</a><br><h2>Willimantic County Medical Society</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Willimantic+County+Medical+Society&search_field=all_fields' target='new'>click here.</a><br><h2>Windham County Medical Society</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Windham+County+Medical+Society&search_field=all_fields' target='new'>click here.</a><br><h2>New York State Nurses Association</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=New+York+State+Nurses+Association&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
                      {
                id: "https://id.loc.gov/authorities/subjects/sh85083129.html",
            name: "Clinical medicine",
            data: {
                relation: "<h1>Clinical medicine</h1><h2>Clinical medicine</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Clinical+medicine&search_field=all_fields' target='new'>click here.</a><br><h2>Clinical medicine--Hospital reports</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Clinical+medicine--Hospital+reports&search_field=all_fields' target='new'>click here.</a><br><h2>Clinical medicine--Study and teaching</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Clinical+medicine--Study+and+teaching&search_field=all_fields' target='new'>click here.</a><br><h2>Clinics</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Clinics&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
        {
                id: "http://id.loc.gov/authorities/subjects/sh85058092",
            name: "Gynecology",
            data: {
                relation: "<h1>Gynecology</h1><h2>Gynecology</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=&search_field=all_fields' target='new'>click here.</a><br><h2>Gynecology--Study and teaching</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
            {
                id: "https://id.loc.gov/authorities/subjects/sh85093768.html",
            name: "Obstetrics",
            data: {
                relation: "<h1>Obstetrics</h1><h2>Obstetrics</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=&search_field=all_fields' target='new'>click here.</a><br><h2>Obstetrics--Study and teaching</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
            {
                id: "https://id.loc.gov/authorities/subjects/sh85093533.html",
            name: "Nymphomania",
            data: {
                relation: "<h1>Nymphomania</h1><h2>Nymphomania</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
            {
                id: "https://id.loc.gov/authorities/subjects/sh85083164.html",
            name: "Traditional medicine",
            data: {
                relation: "<h1>Traditional medicine</h1><h2>Traditional medicine</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
            {
                id: "https://id.loc.gov/authorities/subjects/sh85146322.html",
            name: "Wet nurses",
            data: {
                relation: "<h1>Wet nurses</h1><h2>Wet nurses</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Wet+nurses&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
            {
                id: "https://id.loc.gov/authorities/subjects/sh85038396.html",
            name: "Discrimination in medical care",
            data: {
                relation: "<h1>Discrimination in medical care</h1><h2>Discrimination in medical care</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Discrimination+in+medical+care&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
            {
                id: "https://id.loc.gov/authorities/subjects/sh85141607.html",
            name: "Uterus",
            data: {
                relation: "<h1>Uterus</h1><h2>Uterus</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Uterus&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
            {
                id: "http://id.loc.gov/authorities/subjects/sh85085055",
            name: "Midwives",
            data: {
                relation: "<h1>Midwives</h1><h2>Midwives</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Midwives&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
            {
                id: "https://id.loc.gov/authorities/subjects/sh85144361.html",
            name: "Volunteer workers in medical care",
            data: {
                relation: "<h1>Volunteer workers in medical care</h1><h2>Volunteer workers in medical care</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Volunteer+workers+in+medical+care&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
            {
                id: "https://id.loc.gov/authorities/subjects/sh85086024.html",
            name: "Missionaries, Medical",
            data: {
                relation: "<h1>Missionaries, Medical</h1><h2>Missionaries, Medical</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Missionaries,+Medical&search_field=all_fields' target='new'>click here.</a><br><h2>Missionaries, Medical--China</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Missionaries,+Medical--China&search_field=all_fields' target='new'>click here.</a><br><h2>Missionaries, Medical--Egypt</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Missionaries,+Medical--Egypt&search_field=all_fields' target='new'>click here.</a><br><h2>Missionaries, Medical--India</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Missionaries,+Medical--India&search_field=all_fields' target='new'>click here.</a><br><h2>Missionaries, Medical--Japan</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Missionaries,+Medical--Japan&search_field=all_fields' target='new'>click here.</a><br><h2>Missionaries, medical--Scholarships, fellowships, etc.</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Missionaries,+medical--Scholarships,+fellowships,+etc.&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },      ],
                       }],
        data: {
            relation: "<h2>Medical Women</h2>"
        },

    }, {
        id: "Slavery and Abolition",
        name: "Slavery and Abolition",
        children: [{
            id: "http://id.loc.gov/authorities/subjects/sh85123347",
            name: "Enslaved People",
            data: {
                relation: "<h1>Enslaved People/Slaves</h1><br><b>Note:</b> Many of the subjects in In Her Own Right are dependent on terminology provided by the Library of Congress. Therefore, for clarity, the term 'slaves' is used below in place of the term 'enslaved people'. See the Harmful Language Statement at the bottom of our <a href='http://inherownright.org/spotlight/teachers-and-students/feature/search-tips'>Search Tips page</a> for more details. <h2>Slaves</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slaves&search_field=all_fields' target='new'>Slaves</a><br><h2>Slaves--Education</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slaves--Education&search_field=all_fields' target='new'>Slaves--Education.</a><br><h2>Slaves--Emancipation</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slaves--Emancipation&search_field=all_fields' target='new'>Slaves--Emancipation.</a><br><h2>Slaves--United States</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slaves--United+States&search_field=all_fields' target='new'>Slaves--United States.</a><br><h2>Women slaves</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+slaves&search_field=all_fields' target='new'>Women slaves.</a><br><br><h1>Fugitive Slaves</h1><br><h2>Fugitive slaves</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Fugitive+slaves&search_field=all_fields' target='new'>Fugitive Slaves.</a><br><h2>Fugitive slave law (United States : 1850)</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Fugitive+slave+law+(United+States+:+1850)&search_field=all_fields' target='new'>Fugitive slave law (United States : 1850).</a><br><br><h1>Slave Trade</h1><br><h2>Slave trade</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slave+trade&search_field=all_fields' target='new'>Slave Trade.</a><br><h2>Slaveholders</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slaveholders&search_field=all_fields' target='new'>Slaveholders.</a><br><br><h1>Slavery</h1><br><h2>Slavery</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slavery&search_field=all_fields' target='new'>Slavery.</a><br><h2>Slavery and the church</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slavery+and+the+church&search_field=all_fields' target='new'>Slavery and the church.</a><br><h2>Slavery and the church--Society of Friends</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slavery+and+the+church--Society+of+Friends&search_field=all_fields' target='new'>Slavery and the church--Society of Friends.</a><br><h2>Slavery--Law and legislation</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slavery--Law+and+legislation&search_field=all_fields' target='new'>Slavery--Law and legislation.</a><br><h2>Slavery--Public opinion</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slavery--Public+opinion&search_field=all_fields' target='new'>Slavery--Public opinion.</a><br><h2>Slavery--West Indies</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Slavery--West+Indies&search_field=all_fields' target='new'>Slavery--West Indies.</a>"
            },
            children: [],
        },
                   {
            id: "http://id.loc.gov/authorities/subjects/sh85123315",
            name: "Antislavery Movements",
            data: {
                relation: "<h1>Antislavery Movements</h1><br><h2>Antislavery movements</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Antislavery+movements&search_field=all_fields' target='new'>click here.</a><br><h2>Antislavery movements in literature</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Antislavery+movements+in+literature&search_field=all_fields' target='new'>click here.</a><br><h2>Antislavery movements--Pennsylvania--Philadelphia</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Antislavery+movements--Pennsylvania--Philadelphia&search_field=all_fields' target='new'>click here.</a><br><h2>Antislavery movements--Periodicals</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Antislavery+movements--Periodicals&search_field=all_fields' target='new'>click here.</a><br><h2>Antislavery movements--United States</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Antislavery+movements--United+States&search_field=all_fields' target='new'>click here.</a>"
            },
            children: [{
                id: "https://id.loc.gov/authorities/subjects/sh85000188.html",
            name: "Abolitionists",
            data: {
                relation: "<h1>Abolitionists</h1><br><h2>Abolitionists</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Abolitionists&search_field=all_fields' target='new'>click here.</a><br><h2>Abolitionists--Great Britain--History</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Abolitionists--Great+Britain--History&search_field=all_fields' target='new'>click here.</a><br><h2>Abolitionists--Pennsylvania-- Philadelphia</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Abolitionists--Pennsylvania--+Philadelphia&search_field=all_fields' target='new'>click here.</a><br><h2>African American abolitionists</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=African+American+abolitionists&search_field=all_fields' target='new'>click here.</a><br><h2>African American abolitionists--Pennsylvania--Philadelphia</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=African+American+abolitionists--Pennsylvania--Philadelphia&search_field=all_fields' target='new'>click here.</a><br><h2>Quaker abolitionists</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Quaker+abolitionists&search_field=all_fields' target='new'>click here.</a><br><h2>Women abolitionists</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women+abolitionists&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },{
                id: "Anti-Slavery Societies",
            name: "Anti-Slavery Societies",
            data: {
                relation: "<h1>Anti-Slavery Societies</h1><br><h2>Anti-slavery Convention</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Anti-slavery+Convention&search_field=all_fields' target='new'>click here.</a><br><h2>American Anti-Slavery Society</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=American+Anti-Slavery+Society&search_field=all_fields' target='new'>click here.</a><br><h2>New-England Anti-Slavery Society</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=New-England+Anti-Slavery+Society&search_field=all_fields' target='new'>click here.</a><br><h2>Pennsylvania Anti-Slavery Society</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Pennsylvania+Anti-Slavery+Society&search_field=all_fields' target='new'>click here.</a><br><h2>Pennsylvania Society for Promoting the Abolition of Slavery</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Pennsylvania+Society+for+Promoting+the+Abolition+of+Slavery&search_field=all_fields' target='new'>click here.</a><br><h2>Philadelphia Female Anti-slavery Society</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Philadelphia+Female+Anti-slavery+Society&search_field=all_fields' target='new'>click here.</a><br><h2>Rochester Ladies' Anti-slavery Society</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Rochester+Ladies'+Anti-slavery+Society&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
                  {
                id: "https://id.loc.gov/authorities/subjects/sh85140205.html",
            name: "American Civil War, 1861-1865",
            data: {
                relation: "<h1>American Civil War, 1861-1865</h1><br><h2>American Civil War, 1861-1865</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=American+Civil+War,+1861-1865&search_field=all_fields' target='new'>click here.</a><br><h2>John Brown's Raid (Harpers Ferry, West Virginia : 1859)</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=John+Brown's+Raid+(Harpers+Ferry,+West+Virginia+:+1859)&search_field=all_fields' target='new'>click here.</a><br><h2>Emancipation Proclamation</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Emancipation+Proclamation&search_field=all_fields' target='new'>click here.</a><br><h2>Emancipation Proclamation (United States. President (1861-1865 : Lincoln)</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Emancipation+Proclamation+(United+States.+President+(1861-1865+:+Lincoln)&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
                      {
                id: "http://id.loc.gov/authorities/names/n87870617",
            name: "Great Britain. Act for the abolition of slavery throughout the British Colonies",
            data: {
                relation: "<h1>Great Britain. Act for the abolition of slavery throughout the British Colonies</h1><br><h2>Great Britain. Act for the abolition of slavery throughout the British Colonies</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Great+Britain.+Act+for+the+abolition+of+slavery+throughout+the+British+Colonies&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
        {
                id: "http://id.loc.gov/authorities/names/no2010112186",
            name: "Civil Rights Act of 1866 (United States)",
            data: {
                relation: "<h1>Civil Rights Act of 1866 (United States)</h1><br><h2>Civil Rights Act of 1866 (United States)</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Civil+Rights+Act+of+1866+(United+States)&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
            {
                id: "http://id.loc.gov/authorities/subjects/sh85139597",
            name: "Underground Railroad",
            data: {
                relation: "<h1>Underground Railroad</h1><br><h2>Underground Railroad</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Underground+Railroad&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
                      ],
                       },
                   {
            id: "Freedmen and Freedmen's Societies",
            name: "Freedmen and Freedmen's Societies",
            data: {
                relation: "<h1>Freedmen and Freedmen's Societies</h1>"
            },
            children: [{
                id: "http://id.loc.gov/authorities/subjects/sh85051692",
            name: "Freedmen",
            data: {
                relation: "<h1>Freedmen</h1><br><h2>Freedmen</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Freedmen&search_field=all_fields' target='new'>click here.</a><br><h2>Freedmen--Charities</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Freedmen--Charities&search_field=all_fields' target='new'>click here.</a><br><h2>Freedmen--Economic conditions</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Freedmen--Economic+conditions&search_field=all_fields' target='new'>click here.</a><br><h2>Freedmen--Education</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Freedmen--Education&search_field=all_fields' target='new'>click here.</a><br><h2>Freedmen--Employment</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Freedmen--Employment&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },{
                id: "Freedmen's Societies",
            name: "Freedmen's Societies",
            data: {
                relation: "<h1>Freedmen's Societies</h1><br><h2>American Freedman's Union Commission</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=American+Freedman's+Union+Commission&search_field=all_fields' target='new'>click here.</a><br><h2>American Freedmen's Aid Commission</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=American+Freedmen's+Aid+Commission&search_field=all_fields' target='new'>click here.</a><br><h2>Friends' Association of Philadelphia for the Aid and Elevation of the Freedmen</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Friends'+Association+of+Philadelphia+for+the+Aid+and+Elevation+of+the+Freedmen&search_field=all_fields' target='new'>click here.</a><br><h2>National Freedman's Relief Association</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=National+Freedman's+Relief+Association&search_field=all_fields' target='new'>click here.</a><br><h2>National Freedmen's Relief Association</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=National+Freedmen's+Relief+Association&search_field=all_fields' target='new'>click here.</a><br><h2>New York National Freedman's Relief Association</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=New+York+National+Freedman's+Relief+Association&search_field=all_fields' target='new'>click here.</a><br><h2>Pennsylvania Freedmen's Relief Association</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Pennsylvania+Freedmen's+Relief+Association&search_field=all_fields' target='new'>click here.</a><br><h2>United States. Bureau of Refugees, Freedmen, and Abandoned Lands</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=United+States.+Bureau+of+Refugees,+Freedmen,+and+Abandoned+Lands&search_field=all_fields' target='new'>click here.</a><br><h2>Women's Association of Philadelphia for the Relief of the Freedman</h2>Explore digitized materials related to <a  href='http://inherownright.org/catalog?f%5Bsubject_sm%5D%5B%5D=Women's+Association+of+Philadelphia+for+the+Relief+of+the+Freedman&search_field=all_fields' target='new'>click here.</a>"
            },
                children: []
        },
                      ],
                       }],
        data: {
            relation: "<h2>Slavery and Abolition</h2>"
        },

    },   ],
        data: {
            relation: "<h1>In Her Own Right</h1><br><h3>Visit our <a href='http://inherownright.org/spotlight/about'>About</a> page to learn more about the project.</h3>"
        }
    };
    //end

    //init RGraph
    var rgraph = new $jit.RGraph({
        //Where to append the visualization
        injectInto: 'infovis',
        //Optional: create a background canvas that plots
        //concentric circles.
        background: {
          CanvasStyles: {
            strokeStyle: '#616161'
          }
        },
        //Add navigation capabilities:
        //zooming by scrolling and panning.
        Navigation: {
          enable: true,
          panning: true,
          zooming: 10
        },
        //Set Node and Edge styles.
        Node: {
            color: '#e0d485'
        },

        Edge: {
          color: '#C17878',
          lineWidth:1.5
        },

        onBeforeCompute: function(node){
            Log.write("centering " + node.name + "...");
            //Add the relation list in the right column.
            //This list is taken from the data property of each JSON node.
            $jit.id('inner-details').innerHTML = node.data.relation;
        },

        //Add the name of the node in the correponding label
        //and a click handler to move the graph.
        //This method is called once, on label creation.
        onCreateLabel: function(domElement, node){
            domElement.innerHTML = node.name;
            domElement.onclick = function(){
                rgraph.onClick(node.id, {
                    onComplete: function() {
                        Log.write("done");
                    }
                });
            };
        },
        //Change some label dom properties.
        //This method is called each time a label is plotted.
        onPlaceLabel: function(domElement, node){
            var style = domElement.style;
            style.display = '';
            style.cursor = 'pointer';

            if (node._depth <= 1) {
                style.fontSize = "1em";
                style.color = "#ccc";

            } else if(node._depth == 2){
                style.fontSize = "0.9em";
                style.color = "#ccc";

            } else {
                style.display = 'none';
            }

            var left = parseInt(style.left);
            var w = domElement.offsetWidth;
            style.left = (left - w / 2) + 'px';
        }
    });
    //load JSON data
    rgraph.loadJSON(json);
    //trigger small animation
    rgraph.graph.eachNode(function(n) {
      var pos = n.getPos();
      pos.setc(-200, -200);
    });
    rgraph.compute('end');
    rgraph.fx.animate({
      modes:['polar'],
      duration: 2000
    });
    //end
    //append information about the root relations in the right column
    $jit.id('inner-details').innerHTML = rgraph.graph.getNode(rgraph.root).data.relation;
}
