require "rails_helper"

RSpec.describe DcCoverage, :type => :model do
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

  it "destroys dependent spacial_map_locations" do
    dc_coverage = @record.dc_coverages.create(coverage: "12 North Lane")

    expect {dc_coverage.destroy}.to change {CoverageMapLocation.count}.by(-1)
  end

  describe '#update_map_locations' do
    it "can create spacial_map_locations from coverage" do
      dc_coverage = @record.dc_coverages.create(coverage: "12 North Lane; 34 South Lane")

      expect(CoverageMapLocation.count).to eq(2)
    end

    it "can delete spacial_map_locations if removed from spacial" do
      dc_coverage = @record.dc_coverages.create(coverage: "12 North Lane; 34 South Lane")

      expect(CoverageMapLocation.count).to eq(2)
      expect(CoverageMapLocation.pluck(:placename)).to include("12 North Lane", "34 South Lane")

      dc_coverage.update_attributes(coverage: "12 North Lane")

      expect(CoverageMapLocation.count).to eq(1)
      expect(CoverageMapLocation.pluck(:placename)).to include("12 North Lane")
      expect(CoverageMapLocation.pluck(:placename)).to_not include("34 South Lane")
    end

    it "verifies that all spacial_map_locations match spacial" do
      dc_coverage = @record.dc_coverages.create(coverage: "12 North Lane; 34 South Lane")

      expect(CoverageMapLocation.count).to eq(2)
      expect(CoverageMapLocation.first.verified).to_not be(nil)
      expect(CoverageMapLocation.last.verified).to_not be(nil)
    end

    it "skips the API call if the location data has already been geocoded" do
      expect(HTTParty).to receive(:get)

      @record.dc_coverages.create(coverage: "12 North Lane")

      expect(HTTParty).to_not receive(:get)

      @record.dc_coverages.create(coverage: "12 North Lane")
    end

    it "skips the API call if the location data already includes coordinates" do
      expect(HTTParty).to_not receive(:get)

      @record.dc_coverages.create(coverage: "45.3421, 67.4325")

      expect(CoverageMapLocation.first.placename).to eq("45.3421, 67.4325")
      expect(CoverageMapLocation.first.latitude).to eq(0.453421e2)
      expect(CoverageMapLocation.first.longitude).to eq(0.674325e2)
    end
  end
end
