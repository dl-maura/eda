# we will use /about as our test of basic layout elements

require 'spec_helper'

describe 'layout requests' do
  subject { page }

  describe 'get sample page' do
    before { visit about_url }

    it { should have_selector( 'header' ) }

    it { should have_selector( 'header h1' ) }

    it { should have_selector( 'header nav.main' ) }
    it { should have_selector( 'header nav.main a[href="' + root_url + '"]', { text: 'Home' } ) }
    it { should have_selector( 'header nav.main a[href="' + about_url + '"]', { text: 'About' } ) }

    it { should have_selector( 'header nav.user' ) }

    # without being signed in yet
    it { should have_selector( 'header nav.user a[href="' + new_user_session_url + '"]', { text: 'Sign In' } ) }

    it { should have_selector( 'footer' ) }

    it { should have_selector( 'footer a[title="Berkman Center for Internet and Society"]' ) }

    it { should have_selector( 'footer nav.footer' ) }

    it { should have_selector( 'footer nav.footer a[href="' + terms_url + '"]', { text: 'Terms & Conditions' } ) }
    it { should have_selector( 'footer nav.footer a[href="' + privacy_url + '"]', { text: 'Privacy' } ) }
    it { should have_selector( 'footer nav.footer a[href="' + contact_url + '"]', { text: 'Contact Us' } ) }
  end

end

