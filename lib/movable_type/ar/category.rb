module MovableType
  module AR
    class Category < MovableType::AR::Database
      # Remember to watch out for the badly named :category_parent field in this table.
      # Would be better named :category_parent_id; this is the reason for naming the
      # corresponding association :parental instead of the more intuitive :parent.
      include Comparable
      set_table_name  :mt_category
      set_primary_key :category_id
  
      belongs_to :blog,       :foreign_key => :category_blog_id
      belongs_to :author,     :foreign_key => :category_author_id
      belongs_to :parental,   :foreign_key => :category_parent,   :class_name => 'MovableType::AR::Category'
      has_many   :children,   :foreign_key => :category_parent,   :class_name => 'MovableType::AR::Category'
      has_many   :entries,    :foreign_key => :entry_category_id, :class_name => 'MovableType::AR::Entry'
      has_many   :fileinfos,  :foreign_key => :fileinfo_category_id
      has_many   :placements, :foreign_key => :placement_category_id, :dependent => :destroy
      has_many   :primary_placements, :foreign_key => :placement_category_id, :class_name => 'MovableType::AR::Placement', 
                     :conditions => { 'placement_is_primary' => true }, :dependent => :destroy
      has_many   :trackbacks, :foreign_key => :trackback_category_id
  
      validates_presence_of :category_blog_id, :category_author_id, :category_label
      validates_length_of :category_label, :maximum => 100, :allow_nil => false, :allow_blank => true


      # Create a new category with the given category's values.
      def self.create(target_blog, source_category)
        target_category = MovableType::AR::Category.new({ :category_blog_id => target_blog.blog_id })
        target_category.sync!(source_category)
        target_category
      end
  
  
      # Synchronize this category with the given category's values.
      def sync(source_category)
        [ :category_allow_pings, :category_label, :category_description, 
          :category_author_id, :category_ping_urls ].each do |attribute|
          self[attribute] = source_category[attribute]
        end
    
        # The target parent category may not exist yet.
        if source_category.parental.blank?
          self.category_parent = 0
        else
          parent_category = MovableType::AR::Category.find(:first, :conditions => { :category_blog_id => self.category_blog_id, :category_label => source_category.parental.label })
          parent_category = MovableType::AR::Category.create(self.blog, source_category.parental) if parent_category.blank?
          self.category_parent = parent_category.category_id
        end
      end
  
  
      # Synchronize this category with the given category's values and save.
      def sync!(source_category)
        self.sync(source_category)
        self.save
      end
  
  
      # Determine whether this category has the target category as its immediate
      # parent or ancestor.
      def has_ancestor?(target_category)
        return false if self.category_parent == 0
        return true  if self.category_parent == target_category.category_id
        return self.parental.has_ancestor?(target_category)
      end
  
  
      # Gather a collection of all descendant categories that have the current
      # category as an ancestor.
      def descendants
        current_descendants = []
        return current_descendants if self.children.empty?
        self.children.each do |child_category|
          current_descendants.push([ child_category, child_category.descendants ])
        end
        current_descendants.flatten
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
        self.category_label == other.category_label &&
        self.category_description == other.category_description &&
        (self.category_parent.blank? ? other.category_parent.blank? : self.parental.category_label == other.parental.category_label)
      end

      # An array of information that uniquely identifies this object.
      def unique_info
        self.category_parent == 0 ?
          [ self.blog.blog_name, self.category_label, self.category_description, nil ] :
          [ self.blog.blog_name, self.category_label, self.category_description, self.parental.category_label ]
      end

    end #class
  end #module
end #module
