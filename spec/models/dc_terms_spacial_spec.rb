require "rails_helper"

RSpec.describe DcTermsSpacial, :type => :model do
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
    dc_terms_spacial = @record.dc_terms_spacials.create(spacial: "12 North Lane")

    expect {dc_terms_spacial.destroy}.to change {SpacialMapLocation.count}.by(-1)
  end

  describe '#update_map_locations' do
    it "can create spacial_map_locations from spacial" do
      dc_terms_spacial = @record.dc_terms_spacials.create(spacial: "12 North Lane; 34 South Lane")

      expect(SpacialMapLocation.count).to eq(2)
    end

    it "can delete spacial_map_locations if removed from spacial" do
      dc_terms_spacial = @record.dc_terms_spacials.create(spacial: "12 North Lane; 34 South Lane")

      expect(SpacialMapLocation.count).to eq(2)
      expect(SpacialMapLocation.pluck(:placename)).to include("12 North Lane", "34 South Lane")

      dc_terms_spacial.update_attributes(spacial: "12 North Lane")

      expect(SpacialMapLocation.count).to eq(1)
      expect(SpacialMapLocation.pluck(:placename)).to include("12 North Lane")
      expect(SpacialMapLocation.pluck(:placename)).to_not include("34 South Lane")
    end

    it "verifies that all spacial_map_locations match spacial" do
      dc_terms_spacial = @record.dc_terms_spacials.create(spacial: "12 North Lane; 34 South Lane")

      expect(SpacialMapLocation.count).to eq(2)
      expect(SpacialMapLocation.first.verified).to_not be(nil)
      expect(SpacialMapLocation.last.verified).to_not be(nil)
    end

    it "skips the API call if the location data has already been geocoded" do
      expect(HTTParty).to receive(:get)

      @record.dc_terms_spacials.create(spacial: "12 North Lane")

      expect(HTTParty).to_not receive(:get)

      @record.dc_terms_spacials.create(spacial: "12 North Lane")
    end

    it "skips the API call if the location data already includes coordinates" do
      expect(HTTParty).to_not receive(:get)

      @record.dc_terms_spacials.create(spacial: "45.3421, 67.4325")

      expect(SpacialMapLocation.first.placename).to eq("45.3421, 67.4325")
      expect(SpacialMapLocation.first.latitude).to eq(0.453421e2)
      expect(SpacialMapLocation.first.longitude).to eq(0.674325e2)
    end
  end
end
