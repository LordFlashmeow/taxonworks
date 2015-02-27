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

describe CollectionObjectsController, :type => :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # Georeference. As you add validations to Georeference be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryGirl.build(:valid_collection_object).attributes)
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CollectionObjectsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET list" do
    it "with no other parameters, assigns 20/page collection_objects as @collection_objects" do
      collection_object = CollectionObject.create! valid_attributes
      get :list, {}, valid_session
      expect(assigns(:collection_objects)).to include(collection_object)
    end

    it "renders the list template" do
      get :list, {}, valid_session
      expect(response).to render_template("list")
    end
  end

  describe "GET index" do
    it "assigns all collection_objects as @recent_objects" do
      collection_object = CollectionObject.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:recent_objects)).to eq([collection_object])
    end
  end

  describe "GET show" do
    it "assigns the requested collection_object as @collection_object" do
      collection_object = CollectionObject.create! valid_attributes
      get :show, {:id => collection_object.to_param}, valid_session
      expect(assigns(:collection_object)).to eq(collection_object)
    end
  end

  describe "GET new" do
    it "assigns a new collection_object as @collection_object" do
      get :new, {}, valid_session
      expect(assigns(:collection_object)).to be_a_new(CollectionObject)
    end
  end

  describe "GET edit" do
    it "assigns the requested collection_object as @collection_object" do
      collection_object = CollectionObject.create! valid_attributes
      get :edit, {:id => collection_object.to_param}, valid_session
      expect(assigns(:collection_object)).to eq(collection_object)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new CollectionObject" do
        expect {
          post :create, {:collection_object => valid_attributes}, valid_session
        }.to change(CollectionObject, :count).by(1)
      end

      it "assigns a newly created collection_object as @collection_object" do
        post :create, {:collection_object => valid_attributes}, valid_session
        expect(assigns(:collection_object)).to be_a(CollectionObject)
        expect(assigns(:collection_object)).to be_persisted
      end

      it "redirects to the created collection_object" do
        post :create, {:collection_object => valid_attributes}, valid_session
        expect(response).to redirect_to(CollectionObject.last.metamorphosize)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved collection_object as @collection_object" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CollectionObject).to receive(:save).and_return(false)
        post :create, {:collection_object => {"total" => "invalid value"}}, valid_session
        expect(assigns(:collection_object)).to be_a_new(CollectionObject)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CollectionObject).to receive(:save).and_return(false)
        post :create, {:collection_object => {"total" => "invalid value"}}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested collection_object" do
        collection_object = CollectionObject.create! valid_attributes
        # Assuming there are no other collection_objects in the database, this
        # specifies that the CollectionObject created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(CollectionObject).to receive(:update).with({"total" => "1"})
        put :update, {:id => collection_object.to_param, :collection_object => {"total" => "1"}}, valid_session
      end

      it "assigns the requested collection_object as @collection_object" do
        collection_object = CollectionObject.create! valid_attributes
        put :update, {:id => collection_object.to_param, :collection_object => valid_attributes}, valid_session
        expect(assigns(:collection_object)).to eq(collection_object.metamorphosize)
      end

      it "redirects to the collection_object" do
        collection_object = CollectionObject.create! valid_attributes
        put :update, {:id => collection_object.to_param, :collection_object => valid_attributes}, valid_session
        expect(response).to redirect_to(collection_object.becomes(CollectionObject))
      end
    end

    describe "with invalid params" do
      it "assigns the collection_object as @collection_object" do
        collection_object = CollectionObject.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CollectionObject).to receive(:save).and_return(false)
        put :update, {:id => collection_object.to_param, :collection_object => {"total" => "invalid value"}}, valid_session
        expect(assigns(:collection_object)).to eq(collection_object)
      end

      it "re-renders the 'edit' template" do
        collection_object = CollectionObject.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CollectionObject).to receive(:save).and_return(false)
        put :update, {:id => collection_object.to_param, :collection_object => {"total" => "invalid value"}}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested collection_object" do
      collection_object = CollectionObject.create! valid_attributes
      expect {
        delete :destroy, {:id => collection_object.to_param}, valid_session
      }.to change(CollectionObject, :count).by(-1)
    end

    it "redirects to the collection_objects list" do
      collection_object = CollectionObject.create! valid_attributes
      delete :destroy, {:id => collection_object.to_param}, valid_session
      expect(response).to redirect_to(collection_objects_url)
    end
  end

end
