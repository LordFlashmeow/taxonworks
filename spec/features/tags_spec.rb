require 'rails_helper'

describe 'Tags', :type => :feature do
  let(:index_path) { tags_path }
  let(:page_index_name) { 'tags' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project

      o = CollectingEvent.create!(verbatim_label: 'Cow', by: @user, project: @project)

      keywords = []
      ['slow', 'medium', 'fast'].each do |n|
        keywords.push FactoryGirl.create(:valid_keyword, name: n, by: @user, project: @project)
      end

      (0..2).each do |i|
        Tag.create!(tag_object: o, keyword: keywords[i], by: @user, project: @project)
      end
    }

    describe 'GET /tags' do
      before { visit tags_path }

      it_behaves_like 'a_data_model_with_annotations_index'
    end

    describe 'GET /tags/list' do
      before { visit list_tags_path }

      it_behaves_like 'a_data_model_with_standard_list'
    end

    # pending 'clicking a tag link anywhere renders the tagged object in <some> view'

    describe 'the structure of tag_splat' do
      specify 'has a splat' do
        o = CollectingEvent.first
        # visit_me = "tags/new?tag[tag_object_attribute]=&tag[tag_object_id]=#{o.id}&tag[tag_object_type]=#{o.class}"
        visit("collecting_events/#{o.id}")
        expect(find('#tag_splat').value).to have_text('*')
      end
    end
  end
end

