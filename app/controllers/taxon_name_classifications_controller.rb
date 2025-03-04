class TaxonNameClassificationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_taxon_name_classification, only: [:update, :destroy, :show, :api_show, :edit]
  after_action -> { set_pagination_headers(:taxon_name_classifications) }, only: [:index, :api_index], if: :json_request?

  # GET /taxon_name_classifications
  # GET /taxon_name_classifications.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = TaxonNameClassification.recent_from_project_id(sessions_current_project_id)
          .order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @taxon_name_classifications = Queries::TaxonNameClassification::Filter.new(params)
          .all
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  # GET /taxon_name_classifications/id.json
  def show
  end

  def edit
    redirect_to new_taxon_name_task_path(taxon_name_id: @taxon_name_classification.taxon_name)
  end

  # POST /taxon_name_classifications
  # POST /taxon_name_classifications.json
  def create
    @taxon_name_classification = TaxonNameClassification.new(taxon_name_classification_params)

    respond_to do |format|
      if @taxon_name_classification.save
        format.html {
          redirect_to url_for(@taxon_name_classification.taxon_name.metamorphosize),
                      notice: 'Taxon name classification was successfully created.'
        }
        format.json { render :show, status: :created, location: @taxon_name_classification.metamorphosize }
      else
        format.html {
          redirect_back(fallback_location: (request.referer || root_path),
                        notice: 'Taxon name classification was NOT successfully created.')
        }
        format.json { render json: @taxon_name_classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxon_name_classifications/1
  # PATCH/PUT /taxon_name_classifications/1.json
  def update
    respond_to do |format|
      if @taxon_name_classification.update(taxon_name_classification_params)
        @taxon_name_classification = TaxonNameClassification.find(@taxon_name_classification.id)
        format.html {
          redirect_back(fallback_location: (request.referer || root_path),
                        notice: 'Taxon name classification was successfully updated.')
        }
        format.json { render :show, status: :ok, location: @taxon_name_classification.metamorphosize }
      else
        format.html {
          redirect_back(fallback_location: (request.referer || root_path),
                        notice: 'Taxon name classification was NOT successfully updated.')
        }
        format.json { render json: @taxon_name_classification.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    taxon_name_id = params[:taxon_name_classification].try(:[], :taxon_name_id)
    taxon_name = TaxonName.where(
      id: taxon_name_id,
      project_id: sessions_current_project_id,
    ).first

    if taxon_name
      redirect_to new_taxon_name_task_path(taxon_name_id: taxon_name.id)
    else
      redirect_to new_taxon_name_task_path, notice: 'Create TaxonNameClassifications in the context of a TaxonName.'
    end
  end

  # DELETE /taxon_name_classifications/1
  # DELETE /taxon_name_classifications/1.json
  def destroy
    @taxon_name_classification.destroy
    respond_to do |format|
      if @taxon_name_classification.destroyed?
        format.html { destroy_redirect @taxon_name_classification, notice: 'Taxon name classification was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { destroy_redirect @taxon_name_classification, notice: 'Taxon name classification was not destroyed, ' + @taxon_name_classification.errors.full_messages.join('; ') }
        format.json { render json: @taxon_name_classification.errors, status: :unprocessable_entity }
      end
    end
  end

  def list
    @taxon_name_classifications = TaxonNameClassification.with_project_id(sessions_current_project_id)
      .order(:id).page(params[:page])
  end

  # GET /taxon_name_classifications/search
  def search
    if params[:id].blank?
      redirect_to taxon_name_classification_path,
        notice: 'You must select an item from the list with a click or ' \
        'tab press before clicking show.'
    else
      redirect_to taxon_name_classification_path(params[:id])
    end
  end

  def autocomplete
    # TODO: make reasonable, if used
    @taxon_name_classifications = TaxonNameClassification.where(id: params[:term]).with_project_id(params[:project_id])
    data = @taxon_name_classifications.collect do |t|
      { id: t.id,
       label: TaxonNameClassificationsHelper.taxon_name_classification_tag(t),
       response_values: {
        params[:method] => t.id,
      },
       label_html: TaxonNameClassificationsHelper.taxon_name_classification_tag(t)
 #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
         }
    end

    render json: data
  end

  # GET /taxon_name_classifications/download
  def download
    _data Export::Download.generate_csv(TaxonNameClassification.where(project_id: sessions_current_project_id)),
          type: 'text', filename: "taxon_name_classifications_#{DateTime.now}.csv"
  end

  def taxon_name_classification_types
    render json: TAXON_NAME_CLASSIFICATION_JSON
  end

  # GET /api/v1/taxon_name_classifications
  def api_index
    @taxon_name_classifications = Queries::TaxonNameClassification::Filter.new(params.merge!(api: true)).all
      .where(project_id: sessions_current_project_id)
      .order('taxon_name_classifications.id')
      .page(params[:page])
      .per(params[:per])
    render '/taxon_name_classifications/api/v1/index'
  end

  # GET /api/v1/taxon_name_classifications//:id
  def api_show
    render '/taxon_name_classifications/api/v1/show'
  end

  private

  def set_taxon_name_classification
    @taxon_name_classification = TaxonNameClassification.with_project_id(sessions_current_project_id).find(params[:id])
  end

  def taxon_name_classification_params
    params.require(:taxon_name_classification).permit(
      :taxon_name_id, :type,
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages],
    )
  end
end
