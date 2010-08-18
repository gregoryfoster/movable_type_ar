module MovableType
  module AR
    class Permission < MovableType::AR::Database
      set_table_name  :mt_permission
      set_primary_key :permission_id
  
      belongs_to :author, :foreign_key => :permission_author_id
      belongs_to :blog,   :foreign_key => :permission_blog_id
  
      validates_presence_of :permission_author_id, :permission_blog_id
      validates_length_of :permission_entry_prefs, :maximum => 255, :allow_nil => true

    end #class
  end #module
end #module
