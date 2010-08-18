module MovableType
  module AR
    class Author < MovableType::AR::Database
      set_table_name  :mt_author
      set_primary_key :author_id
  
      belongs_to :creator,          :foreign_key => :author_created_by,  :class_name => 'MovableType::AR::Author'
      has_many   :authors_created,  :foreign_key => :author_created_by,  :class_name => 'MovableType::AR::Author'
      belongs_to :updator,          :foreign_key => :author_modified_by, :class_name => 'MovableType::AR::Author'
      has_many   :authors_updated,  :foreign_key => :author_modified_by, :class_name => 'MovableType::AR::Author'
      has_many :categories_created, :foreign_key => :category_author_id, :class_name => 'MovableType::AR::Category'
      has_many :entries_created,    :foreign_key => :entry_created_by, :class_name => 'MovableType::AR::Entry'
      has_many :entries_updated,    :foreign_key => :entry_updated_by, :class_name => 'MovableType::AR::Entry'
      has_many :ipbanlists_created, :foreign_key => :ipbanlist_created_by, :class_name => 'MovableType::AR::Ipbanlist'
      has_many :ipbanlists_updated, :foreign_key => :ipbanlist_updated_by, :class_name => 'MovableType::AR::Ipbanlist'
      has_many :logs_created,       :foreign_key => :log_created_by, :class_name => 'MovableType::AR::Log'
      has_many :logs_updated,       :foreign_key => :log_updated_by, :class_name => 'MovableType::AR::Log'
      has_many :notifications_created, :foreign_key => :notification_created_by, :class_name => 'MovableType::AR::Notification'
      has_many :notifications_updated, :foreign_key => :notification_updated_by, :class_name => 'MovableType::AR::Notification'
      has_many :permissions,        :foreign_key => :permission_author_id
      has_many :templates_created,  :foreign_key => :template_created_by, :class_name => 'MovableType::AR::Template'
      has_many :templates_updated,  :foreign_key => :template_updated_by, :class_name => 'MovableType::AR::Template'
      has_many :trackbacks_created, :foreign_key => :trackback_created_by, :class_name => 'MovableType::AR::Trackback'
      has_many :trackbacks_updated, :foreign_key => :trackback_updated_by, :class_name => 'MovableType::AR::Trackback'
  
      validates_presence_of :author_name, :author_password, :author_type
      validates_length_of   :author_name,     :maximum => 50,  :allow_nil => false, :allow_blank => true
      validates_length_of   :author_nickname, :maximum => 50,  :allow_nil => true
      validates_length_of   :author_password, :maximum => 60,  :allow_nil => false, :allow_blank => true
      validates_length_of   :author_email,    :maximum => 75,  :allow_nil => true
      validates_length_of   :author_url,      :maximum => 255, :allow_nil => true
      validates_length_of   :author_hint,     :maximum => 75,  :allow_nil => true
      validates_length_of   :author_preferred_language,   :maximum => 50, :allow_nil => true
      validates_length_of   :author_remote_auth_username, :maximum => 50, :allow_nil => true
      validates_length_of   :author_remote_auth_token,    :maximum => 50, :allow_nil => true
      validates_length_of   :author_api_password,         :maximum => 50, :allow_nil => true
  
    end #class
  end #module
end #module