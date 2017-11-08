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

describe TypeMaterialsController, :type => :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # TypeMaterial. As you add validations to TypeMaterial, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryBot.build(:valid_type_material).attributes)
  }

  let(:invalid_attributes) {
    strip_housekeeping_attributes(FactoryBot.build(:invalid_type_material).attributes)
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TypeMaterialsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET list" do
    it "with no other parameters, assigns 20/page type_materials as @controlled_vocabulary_terms" do
      type_material = TypeMaterial.create! valid_attributes
      get :list, params: {}, session: valid_session
      expect(assigns(:type_materials)).to include(type_material)
    end

    it "renders the list template" do
      get :list, params: {}, session: valid_session
      expect(response).to render_template("list")
    end
  end

  describe "GET index" do
    it "assigns all type_materials as @type_materials" do
      type_material = TypeMaterial.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects)).to eq([type_material])
    end
  end

  describe "GET show" do
    it "assigns the requested type_material as @type_material" do
      type_material = TypeMaterial.create! valid_attributes
      get :show, params: {id: type_material.to_param}, session: valid_session
      expect(assigns(:type_material)).to eq(type_material)
    end
  end

  describe "GET new" do
    it "assigns a new type_material as @type_material" do
      get :new, params: {}, session: valid_session
      expect(assigns(:type_material)).to be_a_new(TypeMaterial)
    end
  end

  describe "GET edit" do
    it "assigns the requested type_material as @type_material" do
      type_material = TypeMaterial.create! valid_attributes
      get :edit, params: {id: type_material.to_param}, session: valid_session
      expect(assigns(:type_material)).to eq(type_material)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TypeMaterial" do
        expect {
          post :create, params: {:type_material => valid_attributes}, session: valid_session
        }.to change(TypeMaterial, :count).by(1)
      end

      it "assigns a newly created type_material as @type_material" do
        post :create, params: {:type_material => valid_attributes}, session: valid_session
        expect(assigns(:type_material)).to be_a(TypeMaterial)
        expect(assigns(:type_material)).to be_persisted
      end

      it "redirects to the created type_material" do
        post :create, params: {:type_material => valid_attributes}, session: valid_session
        expect(response).to redirect_to(TypeMaterial.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved type_material as @type_material" do
        allow_any_instance_of(TypeMaterial).to receive(:save).and_return(false)
        post :create, params: {:type_material => invalid_attributes}, session: valid_session
        expect(assigns(:type_material)).to be_a_new(TypeMaterial)
      end

      it "re-renders the 'new' template" do
        allow_any_instance_of(TypeMaterial).to receive(:save).and_return(false)
        post :create, params: {:type_material => invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        strip_housekeeping_attributes(FactoryBot.build(:new_valid_type_material).attributes)
      }

      it "updates the requested type_material" do
        type_material = TypeMaterial.create! valid_attributes
        put :update, params: {id: type_material.to_param, :type_material => new_attributes}, session: valid_session
        type_material.reload
        # skip("Add assertions for updated state")
        expect(assigns(:type_material)).to eq(type_material)
      end

      it "assigns the requested type_material as @type_material" do
        type_material = TypeMaterial.create! valid_attributes
        put :update, params: {id: type_material.to_param, :type_material => valid_attributes}, session: valid_session
        expect(assigns(:type_material)).to eq(type_material)
      end

      it "redirects to the type_material" do
        type_material = TypeMaterial.create! valid_attributes
        put :update, params: {id: type_material.to_param, :type_material => valid_attributes}, session: valid_session
        expect(response).to redirect_to(type_material)
      end
    end

    describe "with invalid params" do
      it "assigns the type_material as @type_material" do
        type_material = TypeMaterial.create! valid_attributes
        put :update, params: {id: type_material.to_param, :type_material => invalid_attributes}, session: valid_session
        expect(assigns(:type_material)).to eq(type_material)
      end

      it "re-renders the 'edit' template" do
        type_material = TypeMaterial.create! valid_attributes
        put :update, params: {id: type_material.to_param, :type_material => invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested type_material" do
      type_material = TypeMaterial.create! valid_attributes
      expect {
        delete :destroy, params: {id: type_material.to_param}, session: valid_session
      }.to change(TypeMaterial, :count).by(-1)
    end

    it "redirects to the type_materials list" do
      type_material = TypeMaterial.create! valid_attributes
      delete :destroy, params: {id: type_material.to_param}, session: valid_session
      expect(response).to redirect_to(type_materials_url)
    end
  end

end
