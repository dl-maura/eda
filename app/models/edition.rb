# == Schema Information
#
# Table name: editions
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  author             :string(255)
#  date               :datetime
#  work_number_prefix :string(255)
#  completeness       :float
#  description        :text
#  owner_id           :integer
#  work_set_id        :integer
#  image_set_id       :integer
#  parent_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Edition < ActiveRecord::Base
    belongs_to :owner, :class_name => 'User'
    belongs_to :parent, :class_name => 'Edition'
    belongs_to :image_set
    belongs_to :work_set

    has_many :works, after_add: :add_work_to_work_set

    attr_accessible :author, :completeness, :date, :description, :name,
        :work_number_prefix, :parent_id, :public

    scope :is_public, where(public: true)
    scope :for_user, lambda { |user|
        if user.nil?
            is_public
        else
            joins{owner.outer}.where{(owner.id == my{user.id}) | (public == true)}
        end
    }
    default_scope order(:completeness)

    before_create :setup_sets

    def images
        image_set.all_images
    end

    def all_works
        if is_child?
            this_editions_works = works.all
            Work.where(id:
               parent.works.all.map(&:id) -
               this_editions_works.map(&:revises_work_id) +
               this_editions_works.map(&:id)
            )
        else
            works
        end
    end

    def inherited_everything_yet?
        !(work_set.empty? || image_set.empty?)
    end

    def copy_everything_from_parent!
        return unless is_child?
        copy_tree_from_parent!(:work_set) if work_set.empty?
        copy_tree_from_parent!(:image_set) if image_set.empty?
    end

    def is_child?
        !parent.nil?
    end

    private

    def add_work_to_work_set(work)
        ws = WorkSet.new
        ws.work = work
        ws.save!
        ws.move_to_child_of work_set
    end

    def copy_tree_from_parent!(relation)
        root = parent.send(relation)
        root_clone = root.dup
        h = {root => root_clone}

        descendants = root.descendants.all
        descendants.each do |item|
            h[item] = item.dup
        end
        descendants.each do |item|
            clone = h[item]
            clone.parent = h[item.parent]
            clone.lft = item.lft
            clone.rgt = item.rgt
            clone.save!
        end

        self.send("#{relation}=", root_clone)
        save!
    end

    def setup_sets
        if is_child?
            copy_tree_from_parent!(:image_set)
        else
            self.image_set = ImageSet.new
        end
        self.work_set = WorkSet.new
    end
end
