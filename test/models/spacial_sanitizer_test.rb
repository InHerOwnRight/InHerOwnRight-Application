require 'test_helper'

class SpacialSanitizerTest < ActiveSupport::TestCase

  test "#remove_location_hints should work" do
    spacial = "East Bradford (Pa. : Township)"
    expected_result = "East Bradford (Pa.)"
    result = SpacialSanitizer.remove_location_hints(spacial)
    assert_equal expected_result, result

    # it should work in lower case too
    result = SpacialSanitizer.remove_location_hints(spacial.downcase)
    assert_equal expected_result.downcase, result
  end

  test "execute should remove location hints" do
    placename = "East Bradford (Pa. : Township)"
    expected_result = "united states pennsylvania east bradford"
    assert_equal expected_result, SpacialSanitizer.execute(placename)
  end

end
