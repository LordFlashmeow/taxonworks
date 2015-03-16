require 'rails_helper'

describe 'TaxonNameRelationships', :type => :feature do
   let(:page_index_name) { 'Taxon name relationships' }

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { taxon_name_relationships_path }
  end 

  describe 'GET /taxon_name_relationships' do
    before { 
     sign_in_user_and_select_project 
      visit taxon_name_relationships_path }

    specify 'an index name is present' do
      expect(page).to have_content(page_index_name)
    end
  end
end





