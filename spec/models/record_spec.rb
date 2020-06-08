require "rails_helper"

RSpec.describe Record, :type => :model do
  before (:each) do
    repository = Repository.create
    raw_record = repository.raw_records.create
    @record = raw_record.create_record(oai_identifier: "TEST_001")
  end

  before do
    osmi_response = "[\
      {\
          \"place_id\": 258653563,\
          \"licence\": \"Data © OpenStreetMap contributors, ODbL 1.0. https://osm.org/copyright\",\
          \"osm_type\": \"way\",\
          \"osm_id\": 11784830,\
          \"boundingbox\": [\
              \"40.661056306122\",\
              \"40.661156306122\",\
              \"-74.299787102041\",\
              \"-74.299687102041\"\
          ],\
          \"lat\": \"40.66110630612245\",\
          \"lon\": \"-74.29973710204081\",\
          \"display_name\": \"345, North Union Avenue, Park Village, Cranford, Union County, New Jersey, 07016, United States of America\",\
          \"class\": \"place\",\
          \"type\": \"house\",\
          \"importance\": 0.5209999999999999\
      }\
    ]"
    allow(HTTParty).to receive(:get).and_return(osmi_response)
  end

  it "destroys dependent dc_terms_spacials" do
    @record.dc_terms_spacials.create(spacial: "12 North Lane")

    expect {@record.destroy}.to change {DcTermsSpacial.count}.by(-1)
  end

  it "destroys dependent dc_coverage" do
    @record.dc_coverages.create(coverage: "12 North Lane")

    expect {@record.destroy}.to change {DcCoverage.count}.by(-1)
  end

  it "destroys dependent spacial_map_locations" do
    dc_terms_spacial = @record.dc_terms_spacials.create(spacial: "12 North Lane")

    expect {@record.destroy}.to change {SpacialMapLocation.count}.by(-1)
  end

  it "destroys dependent coverage_map_locations" do
    dc_coverage = @record.dc_coverages.create(coverage: "12 North Lane")

    expect {@record.destroy}.to change {CoverageMapLocation.count}.by(-1)
  end

  it 'ignores duplicates if same location data exists in dc_coverage and dc_terms_spacial' do
    dc_coverage = @record.dc_coverages.create(coverage: "12 North Lane")
    dc_coverage = @record.dc_terms_spacials.create(spacial: "12 North Lane")
    @record.reload

    expect(@record.map_locations.pluck(:placename).count).to eq(1)
  end
end
