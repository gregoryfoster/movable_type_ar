module MovableType
  module AR
    class Entry < MovableType::AR::Database
      include Comparable
      set_table_name  :mt_entry
      set_primary_key :entry_id
  
      belongs_to :blog,       :foreign_key => :entry_blog_id
      belongs_to :author,     :foreign_key => :entry_author_id
      belongs_to :category,   :foreign_key => :entry_category_id
      has_many   :comments,   :foreign_key => :comment_entry_id,   :dependent => :destroy
      belongs_to :creator,    :foreign_key => :entry_created_by,   :class_name => 'MovableType::AR::Author'
      belongs_to :updator,    :foreign_key => :entry_modified_by,  :class_name => 'MovableType::AR::Author'
      has_many   :fileinfos,  :foreign_key => :fileinfo_entry_id
      has_many   :placements, :foreign_key => :placement_entry_id, :dependent => :destroy
      has_one    :primary_placement, :foreign_key => :placement_entry_id, :class_name => 'MovableType::AR::Placement',
                     :conditions => { :placement_is_primary => true }, :dependent => :destroy
      has_many   :trackbacks, :foreign_key => :trackback_entry_id
  
      validates_presence_of :entry_blog_id, :entry_author_id
      validates_length_of :entry_convert_breaks, :maximum => 30,  :allow_nil => true
      validates_length_of :entry_title,          :maximum => 255, :allow_nil => true
      validates_length_of :entry_basename,       :maximum => 255, :allow_nil => true
      validates_length_of :entry_atom_id,        :maximum => 255, :allow_nil => true

      # Entry Status Codes: 1 Unpublished, 2 Published, 4 Scheduled

      # Create a new entry with the given entry's values.
      def self.create(target_blog, source_entry)
        target_entry = MovableType::AR::Entry.new({ :entry_blog_id => target_blog.blog_id })
        target_entry.sync!(source_entry)
    
        # Copy placements.
        source_entry.placements.each do |source_placement|
          target_entry.placements << MovableType::AR::Placement.create(target_entry, source_placement)
        end

        # Copy comments.
        source_entry.comments.each do |source_comment|
          target_entry.comments << MovableType::AR::Comment.create(target_entry, source_comment)
        end
    
        target_entry
      end
  
  
      # Synchronize this entry with the given entry's values.
      def sync(source_entry)
        [ :entry_status, :entry_author_id, :entry_allow_comments, :entry_allow_pings, 
          :entry_convert_breaks, :entry_title, :entry_excerpt, :entry_text, :entry_text_more,
          :entry_to_ping_urls, :entry_pinged_urls, :entry_keywords, :entry_tangent_cache,
          :entry_created_on, :entry_modified_on, :entry_created_by, :entry_modified_by,
          :entry_basename, :entry_week_number ].each do |attribute|
          self[attribute] = source_entry[attribute]
        end

        # Sync placements ONLY if this entry has been previously saved.
        unless self.new_record?
          # Add or update placements.
          source_entry.placements.each do |source_placement|
            # Category may not exist yet; copy if so.
            target_category = MovableType::AR::Category.find(:first, :conditions => { :category_blog_id => self.entry_blog_id, :category_label => source_placement.category.category_label })
            target_category = MovableType::AR::Category.create(self.blog, source_placement.category) if target_category.blank?
            target_placement = self.placements.find(:first, :conditions => { :placement_category_id => target_category.category_id })
            target_placement.blank? ?
                self.placements << MovableType::AR::Placement.create(self, source_placement) :
                target_placement.sync!(source_placement)
          end
      
          # Remove old placements.
          if self.placements.size > source_entry.placements.size
            self.placements.each do |target_placement|
              source_category = MovableType::AR::Category.find(:first, :conditions => { :category_blog_id => source_entry.entry_blog_id, :category_label => target_placement.category.category_label })
              if source_category.blank?
                self.placements.delete(target_placement)
                next
              end
          
              source_placement = source_entry.placements.find(:first, :conditions => { :placement_category_id => source_category.category_id })
              self.placements.delete(target_placement) if source_placement.blank?
            end
          end
      
          # Comments need to be synchronized separately (should always flow from production -> beta).
        end
      end
  
  
      # Synchronize this entry with the given entry's values and save.
      def sync!(source_entry)
        self.sync(source_entry)
        self.save
      end


      def sync_comments(source_entry)
        # Add or update comments.
        source_entry.comments.each do |source_comment|
          target_comment = self.comments.find(:first, :conditions => { :comment_created_on => source_comment.comment_created_on })
          target_comment.blank? ? 
              self.comments << MovableType::AR::Comment.create(self, source_comment) : 
              target_comment.sync!(source_comment)
        end

        # Remove old comments.
        if self.comments.size > source_entry.comments.size
          self.comments.each do |target_comment|
            source_comment = source_entry.comments.find(:first, :conditions => { :comment_created_on => target_comment.comment_created_on })
            self.comments.delete(target_comment) if source_comment.blank?
          end
        end
      end


      # Determine if this entry has been tagged with ANY of the given categories.
      # Accepts a single Category instance or an Array of Category instances.
      def has_category?(target_categories)
        target_categories = [ target_categories ] if target_categories.class == Category
        target_categories.each do |target_category|
          placement = MovableType::AR::Placement.find(:first, :conditions => { :placement_blog_id => self.entry_blog_id, :placement_entry_id => self.entry_id, :placement_category_id => target_category.category_id })
          return true unless placement.blank?
        end
        false
      end
  
  
      # Determine if this entry has been tagged with ALL of the given categories.
      # Accepts a single Category instance or an Array of Category instances.
      def has_categories?(target_categories)
        target_categories = [ target_categories ] if target_categories.class == Category
        target_categories.each do |target_category|
          placement = MovableType::AR::Placement.find(:first, :conditions => { :placement_blog_id => self.entry_blog_id, :placement_entry_id => self.entry_id, :placement_category_id => target_category.category_id })
          return false if placement.blank?
        end
        true
      end
  
  
      # Determine if this entry is more recently modified than the given entry.
      def more_recently_modified?(target_entry)
        self.entry_modified_on > target_entry.entry_modified_on
      end
  
  
      # Entry Status Codes: 1 Unpublished, 2 Published, 4 Scheduled
      def status_string
        case self.entry_status
          when 1: 'Draft'
          when 2: 'Publish'
          when 4: 'Scheduled'
        end
      end
  
  
      # Output a string representation of the entry.  In this case, we're outputting
      # the MT3.2 export format.
      def to_s
        output = 
            'AUTHOR: ' + self.author.author_name + "\n" +
            'TITLE: ' + self.entry_title + "\n" +
            'STATUS: ' + self.status_string + "\n" +
            'ALLOW COMMENTS: ' + self.entry_allow_comments.to_s + "\n" +
            'CONVERT BREAKS: ' + self.entry_convert_breaks + "\n" +
            'ALLOW PINGS: ' + self.entry_allow_pings.to_s + "\n\n" +
            'DATE: ' + self.entry_created_on.strftime(EXPORT_DATE_FORMAT) + "\n" +
            EXPORT_ATTRIBUTE_BREAK

        output += 'BODY:' + "\n"
        output += self.entry_text.blank? ? "\n" : self.entry_text.chomp + "\n\n"
        output += EXPORT_ATTRIBUTE_BREAK
    
        output += 'EXTENDED BODY:' + "\n"
        output += self.entry_text_more.blank? ? "\n" : self.entry_text_more.chomp + "\n\n"
        output += EXPORT_ATTRIBUTE_BREAK

        output += 'EXCERPT:' + "\n"
        output += self.entry_excerpt.blank? ? "\n" : self.entry_excerpt.chomp + "\n\n"
        output += EXPORT_ATTRIBUTE_BREAK

        output += 'KEYWORDS:' + "\n"
        output += self.entry_keywords.blank? ? "\n" : self.entry_keywords.chomp + "\n\n"
        output += EXPORT_ATTRIBUTE_BREAK

        # Append comments.
        output += self.comments.collect { |comment| comment.to_s }.join
        
        output += EXPORT_ENTRY_BREAK
        output
      end
  

      # Override comparison operators.
      def <=>(other)
        unique_info <=> other.unique_info
      end
  
      def hash
        unique_info.hash
      end
  
      def eql?(other)
        self.class == other.class && 
        self.blog.blog_name == other.blog.blog_name &&
        self.entry_title == other.entry_title
      end

      # An array of information that uniquely identifies this object.
      def unique_info
        [ self.blog.blog_name, self.entry_title ]
      end
  
    end #class
  end #module
end #module
