class SearchHistoryController < ApplicationController
  include Blacklight::SearchHistory

  helper BlacklightRangeLimit::ViewHelperOverride
  helper BlacklightMaps::RenderConstraintsOverride
  helper RangeLimitHelper
end
