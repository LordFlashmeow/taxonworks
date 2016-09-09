require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe ConfidencesController, type: :controller do
  before(:each){
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # Confidence. As you add validations to Confidence, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryGirl.build(:valid_confidence).attributes)
  }

  let(:invalid_attributes) {
    valid_attributes.merge(confidence_level_id: nil)
  }

  let!(:specimen) { FactoryGirl.create(:valid_specimen) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ConfidencesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all confidences as @recent_objects" do
      confidence = Confidence.create! valid_attributes
      get :index, {}, session: valid_session
      expect(assigns(:recent_objects)).to eq([confidence])
    end
  end

  # describe "GET #show" do
  #   it "assigns the requested confidence as @confidence" do
  #     confidence = Confidence.create! valid_attributes
  #     get :show, {id: confidence.to_param}, session: valid_session
  #     expect(assigns(:confidence)).to eq(confidence)
  #   end
  # end

  # describe "GET #new" do
  #   it "assigns a new confidence as @confidence" do
  #     get :new, {}, session: valid_session
  #     expect(assigns(:confidence)).to be_a_new(Confidence)
  #   end
  # end

  # describe "GET #edit" do
  #   it "assigns the requested confidence as @confidence" do
  #     confidence = Confidence.create! valid_attributes
  #     get :edit, {id: confidence.to_param}, session: valid_session
  #     expect(assigns(:confidence)).to eq(confidence)
  #   end
  # end

  before {
    request.env['HTTP_REFERER'] = list_collection_objects_path
  }

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Confidence" do
        expect {
          post :create, {confidence: valid_attributes}, session: valid_session
        }.to change(Confidence, :count).by(1)
      end

      it "assigns a newly created confidence as @confidence" do
        post :create, {confidence: valid_attributes}, session: valid_session
        expect(assigns(:confidence)).to be_a(Confidence)
        expect(assigns(:confidence)).to be_persisted
      end

      it "redirects to the created confidence" do
        post :create, {confidence: valid_attributes}, session: valid_session
        expect(response).to redirect_to(collection_object_path(Specimen.last))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved confidence as @confidence" do
        allow_any_instance_of(Confidence).to receive(:save).and_return(false)
        post :create, {confidence: invalid_attributes}, session: valid_session
        expect(assigns(:confidence)).to be_a_new(Confidence)
      end

      it "re-renders the :back template" do
        allow_any_instance_of(Confidence).to receive(:save).and_return(false)
        post :create, {confidence: invalid_attributes}, session: valid_session
        expect(response).to redirect_to(list_collection_objects_path)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_confidence_level) { FactoryGirl.create(:valid_confidence_level) }
      let(:new_attributes) {
        { confidence_level_id: new_confidence_level.to_param  }
      }

      it "updates the requested confidence" do
        confidence = Confidence.create! valid_attributes
        put :update, {id: confidence.to_param, confidence: new_attributes}, session: valid_session
        confidence.reload
        expect(confidence.confidence_level).to eq(new_confidence_level)
      end

      it "assigns the requested confidence as @confidence" do
        confidence = Confidence.create! valid_attributes
        put :update, {id: confidence.to_param, confidence: valid_attributes}, session: valid_session
        expect(assigns(:confidence)).to eq(confidence)
      end

      it "redirects to the confidence" do
        confidence = Confidence.create! valid_attributes
        put :update, {id: confidence.to_param, confidence: valid_attributes}, session: valid_session
        expect(response).to redirect_to(confidence)
      end
    end

    context "with invalid params" do
      it "assigns the confidence as @confidence" do
        confidence = Confidence.create! valid_attributes
        allow_any_instance_of(Confidence).to receive(:save).and_return(false)
        put :update, {id: confidence.to_param, confidence: invalid_attributes}, session: valid_session
        expect(assigns(:confidence)).to eq(confidence)
      end

      it "re-renders the 'edit' template" do
        confidence = Confidence.create! valid_attributes
        allow_any_instance_of(Confidence).to receive(:save).and_return(false)
        put :update, {id: confidence.to_param, confidence: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do

    before {
      @confidence = Confidence.create! valid_attributes
      request.env["HTTP_REFERER"] = list_collection_objects_path
    }

    it "destroys the requested confidence" do
      expect {
        delete :destroy, {id: @confidence.to_param}, session: valid_session
      }.to change(Confidence, :count).by(-1)
    end

    it "redirects to the confidences list" do
      delete :destroy, {id: @confidence.to_param}, session: valid_session
      expect(response).to redirect_to(confidences_url)
    end
  end

end
