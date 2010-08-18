module MovableType
  module AR
    class Placement < MovableType::AR::Database
      set_table_name  :mt_placement
      set_primary_key :placement_id
  
      belongs_to :entry,              :foreign_key => :placement_entry_id
      belongs_to :blog,               :foreign_key => :placement_blog_id
      belongs_to :category,           :foreign_key => :placement_category_id
      belongs_to :primary_placements, :foreign_key => :placement_category_id
  
      validates_presence_of :placement_entry_id, :placement_blog_id, :placement_category_id, :placement_is_primary


      # Create a new placement with the given placement's values.
      def self.create(target_entry, source_placement)
        target_placement = MovableType::AR::Placement.new({ :placement_blog_id => target_entry.entry_blog_id, :placement_entry_id => target_entry.entry_id })
        target_placement.sync(source_placement)
        target_category = MovableType::AR::Category.find(:first, :conditions => { :category_blog_id => target_entry.entry_blog_id, :category_label => source_placement.category.category_label })
        target_category = MovableType::AR::Category.create(target_entry.blog, source_placement.category) if target_category.blank?
        target_placement.placement_category_id = target_category.category_id
        target_placement.save
        target_placement
      end
  
  
      # Synchronize this placement with the given placement's values.
      def sync(source_placement)
        self.placement_is_primary = source_placement.placement_is_primary
      end


      # Synchronize this placement with the given placement's values and save.
      def sync!(source_placement)
        self.sync(source_placement)
        self.save
      end

    end #class
  end #module
end #module
