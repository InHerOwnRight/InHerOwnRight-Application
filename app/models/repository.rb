class Repository < ActiveRecord::Base
  has_many :raw_records
  has_many :records, through: :raw_records
  has_many :pacscl_collections

  def islandora?
    islandora_repos = ["Bryn Mawr College", "Haverford College", "Swarthmore - Friends", "Swarthmore - Peace"]
    islandora_repos.include?(short_name)
  end

  def image_relevance_test
    case self.short_name
    when"Drexel University"
      Proc.new do |record,image_path,dc_identifier|
        /^local:/.match(dc_identifier.identifier) && !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier[7..-1])
      end
    when "National Archives"
      Proc.new do |record,image_path,dc_identifier|
        !dc_identifier.identifier.blank? && \
          (image_path[/NARA\/([^"]+)_lg.png/, 1] == dc_identifier.identifier || image_path[/NARA\/([^"]+)_thumb.png/, 1] == dc_identifier.identifier)
      end
    when "Presbyterian Historical Society"
      Proc.new do |record,image_path,dc_identifier|
        !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) || \
        !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier.gsub(/ /, ''))
      end
    when "Haverford College"
      Proc.new do |record,image_path,dc_identifier|
        (!record.oai_identifier.blank? && \
          /^oai:tricontentdm.brynmawr.edu:HC_DigReq\//.match(record.oai_identifier) && \
          image_path.include?(record.oai_identifier[40..-1]) ) \
        || \
        (!dc_identifier.identifier.blank? && \
          image_path.include?(dc_identifier.identifier)) \
      end
    else
      # "Barbara Bates Center", "Library Company", "Temple University", "University of Delaware", "The German Society"
      # "Bryn Mawr College", "College of Physicians", "Catholic Historical Research Center", "Legacy Foundation"
      # "Alice Paul Institute", "Chester County History Center", "United Lutheran Seminary"
      Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    end # case
  end

end
