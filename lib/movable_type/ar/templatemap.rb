module MovableType
  module AR
    class Templatemap < MovableType::AR::Database
      set_table_name  :mt_templatemap
      set_primary_key :templatemap_id
  
      belongs_to :blog,     :foreign_key => :templatemap_blog_id
      belongs_to :template, :foreign_key => :templatemap_template_id
  
      validates_presence_of :templatemap_blog_id, :templatemap_template_id
      validates_length_of :templatemap_archive_type,  :maximum => 25,  :allow_nil => false, :allow_blank => true
      validates_length_of :templatemap_file_template, :maximum => 255, :allow_nil => true


      def self.create(target_template, source_templatemap)
        target_templatemap = MovableType::AR::Templatemap.new({ :templatemap_blog_id => target_template.blog.blog_id, :templatemap_template_id => target_template.templatemap_id })
        target_templatemap.sync!(source_templatemap)
        target_templatemap
      end
  

      # Synchronize this templatemap with the given templatemap's values.
      def sync(source_templatemap)
        [ :templatemap_archive_type, :templatemap_file_template, :templatemap_is_preferred ].each do |attribute|
          self[attribute] = source_templatemap[attribute]
        end
      end
  
  
      # Synchronize this templatemap with the given templatemap's values and save.
      def sync!(source_templatemap)
        self.sync(source_templatemap)
        self.save
      end

    end #class
  end #module
end #module
