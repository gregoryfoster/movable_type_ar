module MovableType
  module AR
    class Fileinfo < MovableType::AR::Database
      set_table_name  :mt_fileinfo
      set_primary_key :fileinfo_id
  
      belongs_to :blog,         :foreign_key => :fileinfo_blog_id
      belongs_to :entry,        :foreign_key => :fileinfo_entry_id
      belongs_to :template,     :foreign_key => :fileinfo_template_id
      belongs_to :template_map, :foreign_key => :fileinfo_templatemap_id, :class_name => 'MovableType::AR::Templatemap'
      belongs_to :category,     :foreign_key => :fileinfo_category_id
  
      validates_presence_of :fileinfo_blog_id
      validates_length_of :fileinfo_url,          :maximum => 255, :allow_nil => true
      validates_length_of :fileinfo_archive_type, :maximum => 255, :allow_nil => true
      validates_length_of :fileinfo_startdate,    :maximum => 80,  :allow_nil => true

    end #class
  end #module
end #module
