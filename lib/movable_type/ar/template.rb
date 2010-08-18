module MovableType
  module AR
    class Template < MovableType::AR::Database
      set_table_name  :mt_template
      set_primary_key :template_id
  
      belongs_to :blog,         :foreign_key => :template_blog_id
      belongs_to :creator,      :foreign_key => :template_created_by,  :class_name => 'MovableType::AR::Author'
      belongs_to :updator,      :foreign_key => :template_modified_by, :class_name => 'MovableType::AR::Author'
      has_one    :fileinfo,     :foreign_key => :fileinfo_template_id
      has_many   :templatemaps, :foreign_key => :templatemap_template_id, :dependent => :destroy
  
      validates_presence_of :template_blog_id, :template_name, :template_type
      validates_length_of :template_name,        :maximum => 50,  :allow_nil => false, :allow_blank => true
      validates_length_of :template_type,        :maximum => 25,  :allow_nil => false, :allow_blank => true
      validates_length_of :template_outfile,     :maximum => 255, :allow_nil => true
      validates_length_of :template_linked_file, :maximum => 255, :allow_nil => true
      validates_length_of :template_linked_file_mtime, :maximum => 10, :allow_nil => true


      # Create a new template with the given template's values.
      def self.create(target_blog, source_template)
        target_template = MovableType::AR::Template.new({ :template_blog_id => target_blog.blog_id })
        target_template.sync!(source_template)
    
        # Copy templatemaps.
        source_template.templatemaps.each do |source_templatemap|
          target_template.templatemaps << MovableType::AR::Templatemap.create(target_template, source_templatemap)
        end

        target_template
      end
  

      # Synchronize this template with the given template's values.
      def sync(source_template)
        [ :template_name, :template_type, :template_outfile, :template_rebuild_me, :template_text,
          :template_linked_file, :template_linked_file_mtime, :template_linked_file_size,
          :template_created_on, :template_modified_on, :template_created_by, :template_modified_by,
          :template_build_dynamic ].each do |attribute|
          self[attribute] = source_template[attribute]
        end
    
        # Linked files must be placed in the filesystem appropriately.
        unless self.linked_file.blank?
          blog_root_regex = Regexp.new('(/var/domain/.*/(beta|www))')
          source_blog_root = blog_root_regex.match(source_template.blog.blog_site_path)[1]
          target_blog_root = blog_root_regex.match(self.blog.blog_site_path)[1]
          self[:template_linked_file].gsub!(source_blog_root, target_blog_root)
        end
    
        # Copy templatemaps ONLY if this template has been previously saved.
        unless self.new_record?
          # Delete existing templatemaps.
          self.templatemaps.destroy_all
      
          # Copy templatemaps.
          source_template.templatemaps.each do |source_templatemap|
            self.templatemaps << MovableType::AR::Templatemap.create(self, source_templatemap)
          end
        end
      end
  
  
      # Synchronize this template with the given template's values and save.
      def sync!(source_template)
        self.sync(source_template)
        self.save
      end


      # Determine if this template is more recently modified than the given template.
      def more_recently_modified?(target_template)
        self.template_modified_on > target_template.template_modified_on
      end
  
    end #class
  end #module
end #module
