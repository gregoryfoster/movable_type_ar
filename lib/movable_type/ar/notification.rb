module MovableType
  module AR
    class Notification < MovableType::AR::Database
      set_table_name  :mt_notification
      set_primary_key :notification_id
  
      belongs_to :blog,    :foreign_key => :notification_blog_id
      belongs_to :creator, :foreign_key => :notification_created_by,  :class_name => 'MovableType::AR::Author'
      belongs_to :updator, :foreign_key => :notification_modified_by, :class_name => 'MovableType::AR::Author'
  
      validates_presence_of :notification_blog_id
      validates_length_of :notification_name,  :maximum => 50,  :allow_nil => true
      validates_length_of :notification_email, :maximum => 75,  :allow_nil => true
      validates_length_of :notification_url,   :maximum => 255, :allow_nil => true

    end #class
  end #module
end #module
