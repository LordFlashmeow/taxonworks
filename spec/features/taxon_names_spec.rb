require 'rails_helper'
include FormHelper

describe 'TaxonNames', :type => :feature do
  Capybara.default_wait_time = 15 # slows down Capybara enough to see what's happening on the form

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { taxon_names_path }
    let(:page_index_name) { 'Taxon Names' }
  end

  describe 'GET /taxon_names' do
    before {
      sign_in_user_and_select_project
      visit taxon_names_path }

    specify 'an index name is present' do
      expect(page).to have_content('Taxon Names')
    end
  end

  context 'signed in as a user, with some records created' do
    let(:p) { FactoryGirl.create(:root_taxon_name, user_project_attributes(@user, @project).merge(source: nil)) }
    before {
      sign_in_user_and_select_project
      5.times {
        FactoryGirl.create(:iczn_family, user_project_attributes(@user, @project).merge(parent: p, source: nil))
      }
    }

    describe 'GET /taxon_names/list' do
      before do
        visit list_taxon_names_path
      end

      specify 'that it renders without error' do
        expect(page).to have_content 'Listing Taxon Names'
      end
    end

    describe 'GET /taxon_names/n' do
      before {
        visit taxon_name_path(TaxonName.second)
      }

      specify 'there is a \'previous\' link' do
        expect(page).to have_link('Previous')
      end

      specify 'there is a \'next\' link' do
        expect(page).to have_link('Next')
      end
    end
  end

  context 'new link is present on taxon names page' do
    before { sign_in_user_and_select_project }

    specify 'new link is present' do
      visit taxon_names_path # when I visit the taxon_names_path
      expect(page).to have_link('New') # it has a new link
    end
  end

  context 'creating a new TaxonName' do
    before {
      sign_in_user_and_select_project
      visit taxon_names_path # when I visit the taxon_names_path
      FactoryGirl.create(:root_taxon_name, user_project_attributes(@user, @project).merge(source: nil))
    }
    specify 'testing new TaxonName', js: true do
      click_link('New') # when I click the new link

      fill_in('Name', with: 'Fooidae') # and I fill out the name field with "Fooidae"
      # and I select 'family (ICZN)' from the Rank select *
      select('family (ICZN)', from: 'taxon_name_rank_class')

      fill_autocomplete('parent_id_for_name', with: 'root')

      click_button('Create Taxon name') # when I click the 'Create Taxon name' button
      # then I get the message "Taxon name 'Foodiae' was successfully created."
      expect(page).to have_content("Taxon name 'Fooidae' was successfully created.")
    end
  end

  context 'editing an original combination' do
    before {
      sign_in_user_and_select_project
      # create the parent genera :
      # With a species created (you'll need a genus 'Aus', family, root)
      # With a different genus ('Bus') created under the same family
      @root    = FactoryGirl.create(:root_taxon_name,
                                    user_project_attributes(@user,
                                                            @project).merge(source:     nil))
      @family    = Protonym.new(user_project_attributes(@user,
                                                        @project).merge(parent:     @root,
                                                                        name:       'Rootidae',
                                                                        rank_class: Ranks.lookup(:iczn, 'Family')))
      @family.save
      @genus_a = Protonym.new(user_project_attributes(@user,
                                                      @project).merge(parent:     @family,
                                                                      name:       'Aus',
                                                                      rank_class: Ranks.lookup(:iczn, 'Genus')))
      @genus_a.save
      @genus_b = Protonym.new(user_project_attributes(@user,
                                                      @project).merge(parent:     @family,
                                                                      name:       'Bus',
                                                                      rank_class: Ranks.lookup(:iczn, 'Genus')))
      @genus_b.save
      visit taxon_names_path # when I visit the taxon_names_path
    }
    specify 'change the original combination of a species to a different genus', js: true do
      # create the original combination Note: couldn't figure out how to do it directly so just used the web interface
      click_link('New')
      fill_in('Name', with: 'species1')
      select('species (ICZN)', from: 'taxon_name_rank_class')
      fill_autocomplete('parent_id_for_name', with: 'Aus')
      click_button('Create Taxon name')
      expect(page).to have_content("Taxon name 'species1' was successfully created.")
      # Note that we're now on the show page for species1 # When I show that species
      expect(page).to have_content('Cached original combination: species1')
      # TODO when cached values are correctly updating, the above may need to change to 'Aus species1'
      expect(page).to have_link('Edit original combination')  # There is an 'Edit original combination link'
      click_link('Edit original combination') # When I click that link
      expect(page).to have_content('Editing original combination for Aus species1')
      fill_autocomplete('subject_taxon_name_id_for_tn_rel_0', with: 'Bus')
      # select 'Bus' for the original genus ajax select
      click_button('Save changes') # click 'Save changes'
      # I am returned to show for the species in question
      expect(page).to have_content('Successfully updated the original combination.') # success msg
      # TODO The following test needs to be added back in once the protonym cached values are updating correctly
      # expect(page).to have_content('Cached original combination: Bus species1')  # show page original genus is changed
    end
    pending "Fix 'edit original combination' to update the cached values" do
      expect(true).to be_falsey
      #This is just a place holder for commented out sections of the above test
    end

  end
end





