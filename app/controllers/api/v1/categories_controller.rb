class Api::V1::CategoriesController < ApplicationController
  rate_limit to: 10, within: 30.seconds, with: -> { render json: { error: "Demasiadas peticiones" }, status: 429 }, store: cache_store
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_category, only: %i[show update destroy]

  # GET /api/v1/categories
  def index
    @categories = Category.all
    render json: @categories, status: :ok
  end

  # GET /api/v1/categories/:id
  def show
    render json: @category, status: :ok
  end

  # POST /api/v1/categories
  def create
    @category = Category.new(category_params)

    if @category.save
      render json: @category, status: :created
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/categories/:id
  def update
    if @category.update(category_params)
      render json: @category, status: :ok
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/categories/:id
  def destroy
    # Usamos el método helper del modelo para verificar si se puede borrar
    if @category.can_be_deleted?
      @category.destroy
      head :no_content
    else
      render json: { error: "No se puede eliminar la categoría: tiene productos o subcategorías asociadas." }, status: :unprocessable_entity
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Categoria no encontrada" }, status: :not_found
  end

  def category_params
    params.require(:category).permit(:name, :description, :status)
  end
end
