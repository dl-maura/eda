# == Schema Information
#
# Table name: images
#
#  id          :integer          not null, primary key
#  url         :text
#  metadata    :text
#  credits     :text
#  full_width  :integer
#  full_height :integer
#  web_width   :integer
#  web_height  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Image < ActiveRecord::Base
    has_many :image_sets, class_name: 'ImageSet', foreign_key: 'nestable_id'
    attr_accessible :credits, :url, :metadata, :web_width, :web_height, :title
    serialize :metadata
    
    include Rails.application.routes.url_helpers
    include ImagesHelper

    def published
        # Not published if Amherst or blank
        image = ::Image.find(id)
        !image.blank? && image.collection && image.collection.name != 'Amherst College'
    end

    def blank?
        url.nil? || url.empty?
    end

    def collection
        #cache_key = "imagecollection-image-#{id}-#{updated_at.try(:utc).try(:to_s, :number)}"
        #Rails.cache.fetch(cache_key) do
        Collection.all.find{|c| !c.leaves_containing(self).empty?}
        #end
    end

    def oai_dc_identifier
        collection = ::Image.find(id).collection
        leaf = collection.leaves_containing(self).first
        collection_image_set_url(collection, leaf, image: self.id)
    end

    def mods_full_image
      large_jpg_url(self)
    end

    def mods_thumbnail
      preview_url(self)
    end

    def sets
        output = OaiRepository.sets.dup.select do |set|
            set[:spec] == 'image' || set[:spec] == "collection:#{collection.name.parameterize}"
        end
        output.map{|o| o.delete(:model); OAI::Set.new(o)}
    end

    def text_credits
        ActionController::Base.helpers.strip_tags(credits.gsub('<br />', "\n"))
    end

    def to_mods
      franklin = Edition.find_by_work_number_prefix('F')
      johnson = Edition.find_by_work_number_prefix('J')
      franklin_works = franklin.works.in_image(self)
      johnson_works = johnson.works.in_image(self)

      xml = ::Builder::XmlMarkup.new
      xml.tag! 'mods',
        {'xmlns' => "http://www.loc.gov/mods/v3" ,
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance" ,
        'xsi:schemaLocation' => "http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd"} do

        franklin_titles = franklin_works.map(&:title).uniq
        johnson_titles = johnson_works.map(&:title).uniq - franklin_titles
        xml.tag! :titleInfo do
          franklin_titles.each do |title|
            xml.tag! :title, title 
          end
          johnson_titles.each do |title|
            xml.tag! :title, title, type: 'alternative'
          end
        end

        xml.tag! :name, type: 'personal' do 
          xml.tag! :namePart, 'Dickinson, Emily'
          xml.tag! :namePart, '1830-1886', type: 'date'
          xml.tag! :role do
            xml.tag! :roleTerm, 'creator', authority: 'marcrelator', type: 'text'
          end
        end

        xml.tag! :typeOfResource, 'text'

        xml.tag! :genre, 'Poems-United States-19th century'

        xml.tag! :originInfo do
          years = (franklin_works.all + johnson_works.all).map{|w| w.date.year}.uniq
          years.each do |year|
            xml.tag! :dateCreated, year, qualifier: 'questionable'
          end
        end

        xml.tag! :language do
          xml.tag! :languageTerm, 'eng', authority: 'iso639-2b', type: 'code'
        end

        xml.tag! :note, title

        xml.tag! :subject, authority: 'lcsh' do
          xml.tag! :topic, 'American poetry-19th century'
        end

        franklin_works.each do |work|
          xml.tag! :relatedItem, type: 'isReferencedBy' do
            xml.tag! :note, "#{franklin.name}, #{work.full_id}"
          end
        end
        johnson_works.each do |work|
          xml.tag! :relatedItem, type: 'isReferencedBy' do
            xml.tag! :note, "#{johnson.name}, #{work.full_id}"
          end
        end

        xml.tag! :relatedItem, type: 'series' do
          xml.tag! :titleInfo do
            xml.tag! :title, 'Emily Dickinson Archive'
          end
        end

        xml.tag! :location do
          xml.tag! :url,
            edition_image_set_url(franklin, franklin.image_set.leaves_containing(self).first),
            displayLabel: "View in the Emily Dickinson Archive",
            usage: 'primary display',
            access: 'object in context'
          xml.tag! :url, mods_full_image, :displayLabel => "Full Image"
          xml.tag! :url, mods_thumbnail, :displayLabel => "Thumbnail"
          xml.tag! :physicalLocation, collection.metadata['Long Name']
        end
      end
      xml.target!
    end
end
