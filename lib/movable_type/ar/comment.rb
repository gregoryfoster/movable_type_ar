module MovableType
  module AR
    class Comment < MovableType::AR::Database
      set_table_name  :mt_comment
      set_primary_key :comment_id
  
      belongs_to :blog,      :foreign_key => :comment_blog_id
      belongs_to :entry,     :foreign_key => :comment_entry_id
      belongs_to :creator,   :foreign_key => :comment_created_by,   :class_name => 'MovableType::AR::Author'
      belongs_to :updator,   :foreign_key => :comment_modified_by,  :class_name => 'MovableType::AR::Author'
      belongs_to :commenter, :foreign_key => :comment_commenter_id, :class_name => 'MovableType::AR::Author'
  
      validates_presence_of :comment_blog_id, :comment_entry_id
      validates_length_of :comment_ip,     :maximum => 16,  :allow_nil => true
      validates_length_of :comment_author, :maximum => 100, :allow_nil => true
      validates_length_of :comment_email,  :maximum => 75,  :allow_nil => true
      validates_length_of :comment_url,    :maximum => 255, :allow_nil => true


      # Create a new comment with the given comment's values.
      def self.create(target_entry, source_comment)
        target_comment = MovableType::AR::Comment.new({ :comment_blog_id => target_entry.entry_blog_id, :comment_entry_id => target_entry.entry_id })
        target_comment.sync!(source_comment)
        target_comment
      end
  
  
      # Synchronize this comment with the given comment's values.
      def sync(source_comment)
        [ :comment_ip, :comment_author, :comment_email, :comment_url, :comment_text, 
          :comment_created_on, :comment_modified_on, :comment_created_by, :comment_modified_by, 
          :comment_commenter_id, :comment_visible, :comment_junk_score, :comment_junk_status, 
          :comment_last_moved_on, :comment_junk_log ].each do |attribute|
          self[attribute] = source_comment[attribute]
        end
      end

      # Synchronize this comment with the given comment's values and save.
      def sync!(source_comment)
        self.sync(source_comment)
        self.save
      end
  
  
      # Output a string representation of the comment.  In this case, we're outputting
      # the MT3.2 export format.
      def to_s
        output = 
            'COMMENT:' + "\n" +
            'AUTHOR: ' + self.author.author_name + "\n" +
            'EMAIL: ' + self.comment_email + "\n" +
            'IP: ' + self.comment_ip + "\n" +
            'URL: ' + self.comment_url + "\n" +
            'DATE: ' + self.comment_created_on.strftime(EXPORT_DATE_FORMAT) + "\n" +
            self.comment_text + "\n" +
            ATTRIBUTE_BREAK
        output
      end
  
    end #class
  end #module
end #module
