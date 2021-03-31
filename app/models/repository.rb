class Repository < ActiveRecord::Base
  has_many :raw_records
  has_many :records, through: :raw_records
  has_many :pacscl_collections

  def islandora?
    islandora_repos = ["Bryn Mawr College", "Haverford College"]
    islandora_repos.include?(short_name)
  end
end
