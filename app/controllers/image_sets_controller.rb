class ImageSetsController < ApplicationController
    before_filter :authenticate_user!, only: :rebuild
    before_filter :load_edition, except: [:index, :show]
    before_filter :load_image_set, only: [:show, :update, :edit, :destroy]
    before_filter :check_edition_owner, only: :rebuild

    include TheSortableTreeController::Rebuild
    include TheSortableTreeController::ExpandNode

    def index
        load_edition
        @image_sets = @edition.image_set.children.includes(:nestable)
    end

    def collections
        @image_sets = Collection.scoped
    end

    def show
        if params[:edition_id]
            load_edition
        else
            @edition = Eda::Application.config.emily['default_edition']
        end
        unless user_signed_in? && @note = current_user.note_for(@image_set)
            @note = @image_set.notes.new
        end

        if @image_set.leaf?
            pull_works_for_edition_image_set(@edition, @image_set)
            @next_image = @image_set.root.leaf_after(@image_set)
            @previous_image = @image_set.root.leaf_before(@image_set)

            load_page_order_options

            render "image_sets/works"
        else
            render
        end
    end

    def new
        @image_set = ImageSet.new
    end

    def create
        @image_set = ImageSet.new(params[:image_set])
        @image_set.move_to_child_of @edition.image_set
        if @image_set.save
            flash[:notice] = t :successful_creation
            redirect_to edition_image_sets_path(@edition)
        else
            flash[:alert] = t :form_error, count: @image_set.errors.count
            render :new
        end
    end

    def edit
    end

    def update
        @image_set.update_attributes(params[:image_set])
        if @image_set.save
            flash[:notice] = t :successful_update
            redirect_to edition_image_sets_path(@edition)
        else
            flash[:alert] = t :form_error, count: @image_set.errors.count
            redirect_to edit_edition_image_set_path(@edition, @image_set)
        end
    end

    def destroy
    end
    
    private

    def load_image_set
        @image_set = ImageSet.find(params[:id])
    end

    def load_page_order_options
      default_edition = Eda::Application.config.emily['default_edition']

      @collection = nil
      @library_image_set = nil
      Collection.all.each do |c|
        c_leaves = c.leaves_containing @image_set.image
        if c_leaves.count > 0
          @collection = c
          @library_image_set = edition_image_set_path( @edition, c_leaves.first )
          break;
        end
      end

      @edition_image_set = nil
      e_leaves = @edition.image_set.leaves_containing @image_set.image
      if e_leaves.count > 0
        @edition_image_set = edition_image_set_path( @edition, e_leaves.first )
      else
        # use default edition
        # or should we hide the selector?
        e_leaves = default_edition.image_set.leaves_containing @image_set.image
        @edition_image_set = edition_image_set_path( default_edition, e_leaves.first )
      end

    end
end

