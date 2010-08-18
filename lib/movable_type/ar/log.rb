module MovableType
  module AR
    class Log < MovableType::AR::Database
      set_table_name  :mt_log
      set_primary_key :log_id
  
      belongs_to :blog,    :foreign_key => :log_blog_id
      belongs_to :creator, :foreign_key => :log_created_by,  :class_name => 'MovableType::AR::Author'
      belongs_to :updator, :foreign_key => :log_modified_by, :class_name => 'MovableType::AR::Author'
  
      validates_presence_of :log_blog_id
      validates_length_of :log_message, :maximum => 255, :allow_nil => true, :allow_blank => true
      validates_length_of :log_ip,      :maximum => 15,  :allow_nil => true, :allow_blank => true

    end #class
  end #module
end #module
