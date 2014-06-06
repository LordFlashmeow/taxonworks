require 'spec_helper'

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

describe RangedLotCategoriesController do

  # This should return the minimal set of attributes required to create a valid
  # RangedLotCategory. As you add validations to RangedLotCategory, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RangedLotCategoriesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all ranged_lot_categories as @ranged_lot_categories" do
      ranged_lot_category = RangedLotCategory.create! valid_attributes
      get :index, {}, valid_session
      assigns(:ranged_lot_categories).should eq([ranged_lot_category])
    end
  end

  describe "GET show" do
    it "assigns the requested ranged_lot_category as @ranged_lot_category" do
      ranged_lot_category = RangedLotCategory.create! valid_attributes
      get :show, {:id => ranged_lot_category.to_param}, valid_session
      assigns(:ranged_lot_category).should eq(ranged_lot_category)
    end
  end

  describe "GET new" do
    it "assigns a new ranged_lot_category as @ranged_lot_category" do
      get :new, {}, valid_session
      assigns(:ranged_lot_category).should be_a_new(RangedLotCategory)
    end
  end

  describe "GET edit" do
    it "assigns the requested ranged_lot_category as @ranged_lot_category" do
      ranged_lot_category = RangedLotCategory.create! valid_attributes
      get :edit, {:id => ranged_lot_category.to_param}, valid_session
      assigns(:ranged_lot_category).should eq(ranged_lot_category)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new RangedLotCategory" do
        expect {
          post :create, {:ranged_lot_category => valid_attributes}, valid_session
        }.to change(RangedLotCategory, :count).by(1)
      end

      it "assigns a newly created ranged_lot_category as @ranged_lot_category" do
        post :create, {:ranged_lot_category => valid_attributes}, valid_session
        assigns(:ranged_lot_category).should be_a(RangedLotCategory)
        assigns(:ranged_lot_category).should be_persisted
      end

      it "redirects to the created ranged_lot_category" do
        post :create, {:ranged_lot_category => valid_attributes}, valid_session
        response.should redirect_to(RangedLotCategory.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved ranged_lot_category as @ranged_lot_category" do
        # Trigger the behavior that occurs when invalid params are submitted
        RangedLotCategory.any_instance.stub(:save).and_return(false)
        post :create, {:ranged_lot_category => {  }}, valid_session
        assigns(:ranged_lot_category).should be_a_new(RangedLotCategory)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        RangedLotCategory.any_instance.stub(:save).and_return(false)
        post :create, {:ranged_lot_category => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested ranged_lot_category" do
        ranged_lot_category = RangedLotCategory.create! valid_attributes
        # Assuming there are no other ranged_lot_categories in the database, this
        # specifies that the RangedLotCategory created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        RangedLotCategory.any_instance.should_receive(:update).with({ "these" => "params" })
        put :update, {:id => ranged_lot_category.to_param, :ranged_lot_category => { "these" => "params" }}, valid_session
      end

      it "assigns the requested ranged_lot_category as @ranged_lot_category" do
        ranged_lot_category = RangedLotCategory.create! valid_attributes
        put :update, {:id => ranged_lot_category.to_param, :ranged_lot_category => valid_attributes}, valid_session
        assigns(:ranged_lot_category).should eq(ranged_lot_category)
      end

      it "redirects to the ranged_lot_category" do
        ranged_lot_category = RangedLotCategory.create! valid_attributes
        put :update, {:id => ranged_lot_category.to_param, :ranged_lot_category => valid_attributes}, valid_session
        response.should redirect_to(ranged_lot_category)
      end
    end

    describe "with invalid params" do
      it "assigns the ranged_lot_category as @ranged_lot_category" do
        ranged_lot_category = RangedLotCategory.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        RangedLotCategory.any_instance.stub(:save).and_return(false)
        put :update, {:id => ranged_lot_category.to_param, :ranged_lot_category => {  }}, valid_session
        assigns(:ranged_lot_category).should eq(ranged_lot_category)
      end

      it "re-renders the 'edit' template" do
        ranged_lot_category = RangedLotCategory.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        RangedLotCategory.any_instance.stub(:save).and_return(false)
        put :update, {:id => ranged_lot_category.to_param, :ranged_lot_category => {  }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested ranged_lot_category" do
      ranged_lot_category = RangedLotCategory.create! valid_attributes
      expect {
        delete :destroy, {:id => ranged_lot_category.to_param}, valid_session
      }.to change(RangedLotCategory, :count).by(-1)
    end

    it "redirects to the ranged_lot_categories list" do
      ranged_lot_category = RangedLotCategory.create! valid_attributes
      delete :destroy, {:id => ranged_lot_category.to_param}, valid_session
      response.should redirect_to(ranged_lot_categories_url)
    end
  end

end
