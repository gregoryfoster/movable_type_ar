module MovableType
  module AR
    class Trackback < MovableType::AR::Database
      set_table_name  :mt_trackback
      set_primary_key :trackback_id
  
      belongs_to :blog,     :foreign_key => :trackback_blog_id
      belongs_to :entry,    :foreign_key => :trackback_entry_id
      belongs_to :category, :foreign_key => :trackback_category_id
      belongs_to :creator,  :foreign_key => :trackback_created_by,  :class_name => 'MovableType::AR::Author'
      belongs_to :updator,  :foreign_key => :trackback_modified_by, :class_name => 'MovableType::AR::Author'
  
      validates_presence_of :trackback_blog_id, :trackback_entry_id, :trackback_category_id
      validates_length_of :trackback_title,      :maximum => 255, :allow_nil => true, :allow_blank => true
      validates_length_of :trackback_rss_file,   :maximum => 255, :allow_nil => true, :allow_blank => true
      validates_length_of :trackback_url,        :maximum => 255, :allow_nil => true, :allow_blank => true
      validates_length_of :trackback_passphrase, :maximum => 30,  :allow_nil => true, :allow_blank => true

    end #class
  end #module
end #module
