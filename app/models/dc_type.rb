class DcType < ActiveRecord::Base
  belongs_to :record

  self.inheritance_column = 'class_type'

  searchable do
    text :type
  end

end