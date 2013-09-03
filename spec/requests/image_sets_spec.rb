require 'spec_helper'

include ImagesHelper;

describe ( 'image_sets requests' ) {
  let ( :awake ) { 'Awake ye muses nine, sing me a strain divine' }

  subject { page }

  describe ( 'get /editions/:edition_id/image_sets/:id' ) {


    context ( 'leaf/page view' ) {
      # require test:seed
      let ( :w ) { Work.find_by_title( awake ) }

      context 'with valid work, stanzas, image', :js => true do
        before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

        it ( 'should have three main sections' ){ 
          should have_selector( '#search-panel' );

          should have_selector( '#interactive-image-panel' );

          should have_selector( '#work-panel' );
        }
      end

      context 'with valid next image' do
        let ( :image_set ) { w.image_set.children.first }

        before { visit edition_image_set_path( w.edition, image_set ) }

        it ( 'should have a valid next page' ) {
          next_image_set  = image_set.root.leaf_after( image_set )

          next_image_set.should_not == nil;

          page.should have_selector( "a[title='Next Page'][href*='#{edition_image_set_path( w.edition, next_image_set )}']" )
        }
      end

      context ( 'with work no stanzas, no image' ) {
        let ( :w ) { Work.find_by_title 'no_stanzas' }

        before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

        it {
          should have_title 'Emily Dickinson Archive'
        }

        it ( 'should have missing image' ) {
          should have_selector 'img[src*="missing_image.jpg"]'
        }

        it ( 'should have work title' ) {
          should have_text "#{w.number}#{w.variant}"
        }
      }

      describe ( 'search panel' ) do
        before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

        context 'without search q' do
          it ( 'should have search works form' ) {
            should have_selector( '.search-works' );
            should have_selector( '.search-works form input[name="q"]' );
          }
        end

        context 'with search submit' do
          before {
            fill_in( 'Search for:', { with: 'awake' } );
            click_button( 'Search' );
          }

          it ( 'should have performed a search' ) {
            should have_selector( '.search-works form input[name="q"][value="awake"]' );

            should have_selector( '.search-works-results' );

            should have_css( '.search-works-results a', { count: 1 } );
          }
        end
      end

      describe ( 'browse panel' ) {
        before { visit edition_image_set_path( w.edition, w.image_set.children.first ) }

        it { 
          should have_selector( '.browse-works' );
        }
      }

    }




    context ( 'non-leaf/sbs view' ) {
      describe ( 'get /editions/:edition_id/image_sets/:id' ) {

        describe ( 'with valid image set having multiple images' ) {
          let ( :w ) { Work.find_by_title( awake ) }

          before { visit edition_image_set_path( w.edition, w.image_set ) }

          it { 
            should have_title w.image_set.name
          }

          it ( 'should have img tags for all ImageSet images' ) {
            should have_selector( "img[src*='#{preview_url( w.image_set.children[0].image )}']" );
            should have_selector( "img[src*='#{preview_url( w.image_set.children[1].image )}']" );
            should have_selector( "img[src*='#{preview_url( w.image_set.children[2].image )}']" );
          }
        }
      }
    }
  }
}


