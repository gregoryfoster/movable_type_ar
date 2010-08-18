module MovableType
  module AR
    class Ipbanlist < MovableType::AR::Database
      set_table_name  :mt_ipbanlist
      set_primary_key :ipbanlist_id
  
      belongs_to :blog,    :foreign_key => :ipbanlist_blog_id
      belongs_to :creator, :foreign_key => :ipbanlist_created_by,  :class_name => 'MovableType::AR::Author'
      belongs_to :updator, :foreign_key => :ipbanlist_modified_by, :class_name => 'MovableType::AR::Author'
  
      validates_presence_of :ipbanlist_blog_id, :ipbanlist_ip
      validates_length_of :ipbanlist_ip, :maximum => 15, :allow_nil => false, :allow_blank => true

    end #class
  end #module
end #module
