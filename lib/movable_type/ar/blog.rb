module MovableType
  module AR
    class Blog < MovableType::AR::Database
      set_table_name  :mt_blog
      set_primary_key :blog_id
  
      has_many :categories,    :foreign_key => :category_blog_id
      has_many :entries,       :foreign_key => :entry_blog_id
      has_many :comments,      :foreign_key => :comment_blog_id
      has_many :fileinfos,     :foreign_key => :fileinfo_blog_id
      has_many :ipbanlists,    :foreign_key => :ipbanlist_blog_id
      has_many :logs,          :foreign_key => :log_blog_id
      has_many :notifications, :foreign_key => :notification_blog_id
      has_many :permissions,   :foreign_key => :permission_blog_id
      has_many :templates,     :foreign_key => :template_blog_id
      has_many :templatemaps,  :foreign_key => :templatemap_blog_id
      has_many :trackbacks,    :foreign_key => :trackback_blog_id
  
      validates_presence_of :blog_name
      validates_length_of :blog_name, :maximum => 255, :allow_nil => false, :allow_blank => true
      validates_length_of :blog_site_path, :maximum => 255, :allow_nil => true
      validates_length_of :blog_site_url, :maximum => 255, :allow_nil => true
      validates_length_of :blog_archive_path, :maximum => 255, :allow_nil => true
      validates_length_of :blog_archive_url, :maximum => 255, :allow_nil => true
      validates_length_of :blog_archive_type, :maximum => 255, :allow_nil => true
      validates_length_of :blog_archive_type_preferred, :maximum => 25, :allow_nil => true
      validates_length_of :blog_language, :maximum => 5, :allow_nil => true
      validates_length_of :blog_file_extension, :maximum => 10, :allow_nil => true
      validates_length_of :blog_sort_order_posts, :maximum => 8, :allow_nil => true
      validates_length_of :blog_sort_order_comments, :maximum => 8, :allow_nil => true
      validates_length_of :blog_convert_paras, :maximum => 30, :allow_nil => true
      validates_length_of :blog_convert_paras_comments, :maximum => 30, :allow_nil => true
      validates_length_of :blog_mt_update_key, :maximum => 30, :allow_nil => true
      validates_length_of :blog_archive_tmpl_monthly, :maximum => 255, :allow_nil => true
      validates_length_of :blog_archive_tmpl_weekly, :maximum => 255, :allow_nil => true
      validates_length_of :blog_archive_tmpl_daily, :maximum => 255, :allow_nil => true
      validates_length_of :blog_archive_tmpl_individual, :maximum => 255, :allow_nil => true
      validates_length_of :blog_archive_tmpl_category, :maximum => 255, :allow_nil => true
      validates_length_of :blog_google_api_key, :maximum => 32, :allow_nil => true
      validates_length_of :blog_sanitize_spec, :maximum => 255, :allow_nil => true
      validates_length_of :blog_cc_license, :maximum => 255, :allow_nil => true
      validates_length_of :blog_remote_auth_token, :maximum => 50, :allow_nil => true
  
  
      def subdomain_root
        self.blog_site_path.split(File::SEPARATOR)[0..-2].join(File::SEPARATOR)
      end

    end #class
  end #module
end #module
