class Work < ActiveRecord::Base
    belongs_to :edition
    belongs_to :image_group
    has_many :image_group_images, :through => :image_group
    has_many :stanzas, :order => 'position'
    has_many :lines, :through => :stanzas, :order => 'number'
    has_many :pages
    has_many :line_modifiers
    has_many :divisions
    has_many :emendations
    has_many :alternates
    has_many :revisions
    has_many :appearances, :class_name => 'WorkAppearance'
    attr_accessible :date, :metadata, :number, :title, :variant
    after_initialize :setup_defaults

    serialize :metadata

    searchable do
        integer :edition_id
        string(:number) { |work| work.number.to_s }
        text :title
        text :lines do
            lines.map{|l| l.text }
        end
    end

    def line(number)
        lines.find_by_number(number)
    end

    #def number
    #    "#{edition.work_number_prefix}#{read_attribute(:number)}"
    #end
        
    def apps_at_address(line, char_index)
        (divisions + emendations + revisions + alternates).select do |apparatus|
            apparatus.line_num == line && apparatus.start_address == char_index
        end
    end

    def holder_code=(code)
        self.metadata['holder_code'] = code
    end

    def holder_subcode=(subcode)
        self.metadata['holder_subcode'] = subcode
    end

    def holder_id=(id)
        self.metadata['holder_id'] = id
    end

    def fascicle=(fascicle)
        self.metadata['fascicle'] = fascicle
    end

    def fascicle_position=(position)
        self.metadata['fascicle_position'] = position
    end

    def image_after(image)
        igis = image_group_images.where(:image_id => image.id)
        return unless igis.count > 0
        image_position = igis.first.position
        next_images = image_group_images.where{position > image_position}
        return unless next_images.count > 0
        next_images.order(:position).first.image
    end

    private
    
    def setup_defaults
        self.metadata ||= {}
    end
end
