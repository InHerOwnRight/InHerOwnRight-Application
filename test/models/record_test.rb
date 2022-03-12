require 'test_helper'


class RecordTest < ActiveSupport::TestCase

  test "#create_from_raw_record should skip undesirable coverage terms" do
    oai_identifier = "oai:digitalcollections.tricolib.brynmawr.edu:bmc_26309"
    xml_metadata = "<metadata><oai_dc:dc xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:ext='http://exslt.org/common' xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/' xsi:schemaLocation='http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd' xmlns:srw_dc='info:srw/schema/1/dc-schema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>\n  <dc:title>Mary Worthington diary, 1907</dc:title>\n  <dc:creator>Worthington, Mary Whitall, d. 1912 (author)</dc:creator>\n  <dc:subject>Women college students</dc:subject>\n  <dc:subject>Female friendship</dc:subject>\n  <dc:subject>Academic rites and ceremonies</dc:subject>\n  <dc:subject>May Day</dc:subject>\n  <dc:subject>College sports</dc:subject>\n  <dc:subject>Women--Suffrage</dc:subject>\n  <dc:subject>Women--Societies and clubs</dc:subject>\n  <dc:subject>College theater</dc:subject>\n  <dc:subject>Vacations</dc:subject>\n  <dc:subject>Voyages and travels</dc:subject>\n  <dc:subject>Worthington, Mary Whitall, d. 1912</dc:subject>\n  <dc:subject>Thomas, M. Carey (Martha Carey), 1857-1935</dc:subject>\n  <dc:subject>Bryn Mawr College--Students</dc:subject>\n  <dc:subject>Bryn Mawr College--Alumni and alumnae</dc:subject>\n  <dc:description>Mary Whitall Worthington's diary covering her freshman year at Bryn Mawr in the spring\n    of 1907. Mary recorded descriptions of many College traditions including May Day, her class\n    dinner, a bonfire, and the garden party. She writes about attending athletic events and plays at\n    both Bryn Mawr and Haverford, spending time with friends, and the early stages of working with\n    the Bryn Mawr chapter of the College Women's Equal Suffrage League. This diary also includes a\n    recounting of her summer vacation, giving a good idea of her several groups of friends. She\n    discusses her interest in biology as well as her advocacy for women's suffrage and social\n    reform. Throughout her diary, Mary includes photographs of friends, place cards and programs\n    from events, drawings and poems by friends, and a letter from her brother.</dc:description>\n  <dc:date> 1907</dc:date>\n  <dc:type> diaries</dc:type>\n  <dc:type>Text</dc:type>\n  <dc:type>Manuscript</dc:type>\n  <dc:format>application/pdf</dc:format>\n  <dc:format>274 pages</dc:format>\n  <dc:identifier>local:  BMC-9LS-Worthington_f9</dc:identifier>\n  <dc:identifier>\n    http://tricontentdm.brynmawr.edu:80/cdm/ref/collection/BMC_MWW/id/702</dc:identifier>\n  <dc:language> eng</dc:language>\n  <dc:relation>Mary Whitall Worthington papers, 1906-1911-- http://archives.tricolib.brynmawr.edu/repositories/6/resources/8664</dc:relation>\n  <dc:coverage>Bryn Mawr (Pa.)</dc:coverage>\n  <dc:coverage>North and Central America--United States--Pennsylvania--Montgomery--Bryn Mawr</dc:coverage>\n  <dc:rights>NO COPYRIGHT - UNITED\n    STATES</dc:rights>\n<dc:identifier.thumbnail>https://digitalcollections.tricolib.brynmawr.edu/islandora/object/bmc%3A26309/datastream/TN/view/Mary%20Worthington%20diary%2C%201907.jpg</dc:identifier.thumbnail><dc:identifier.url>https://digitalcollections.tricolib.brynmawr.edu/object/bmc26309</dc:identifier.url></oai_dc:dc></metadata>"
    raw_record = RawRecord.create(oai_identifier: oai_identifier, xml_metadata: xml_metadata)

    record = Record.create_from_raw_record(raw_record)

    assert_equal 1, record.dc_coverages.count
    assert_equal 1, record.dc_terms_spacials.count

    assert_equal false, record.dc_coverages.any?{|coverage| /\A\s*North and Central America--/.match(coverage.coverage)}
    assert_equal false, record.dc_terms_spacials.any?{|spacial| /\A\s*North and Central America--/.match(spacial.spacial)}
  end

  test "#create_dc_terms_spacial should skip undesirable coverage terms" do
  end

end
