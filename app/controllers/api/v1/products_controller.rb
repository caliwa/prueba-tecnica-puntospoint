class Api::V1::ProductsController < ApplicationController
  rate_limit to: 10, within: 30.seconds, with: -> { render json: { error: "Demasiadas peticiones" }, status: 429 }, store: cache_store
  before_action :authenticate_user!
  before_action :authorize_admin!, except: [ :create ]
  before_action :set_product, only: %i[show update destroy]

  # GET /api/v1/products (Solo Admins)
  def index
    ReportPurchaseJob.perform_async
    @products = Product.all
    render json: @products, status: :ok
  end

  # GET /api/v1/products/:id (Solo Admins)
  def show
    render json: @product, status: :ok
  end

  # POST /api/v1/products
  def create
    @product = current_user.products.build(product_params)

    if @product.save
      render json: @product, status: :created
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/products/:id (Solo Admins)
  def update
    if @product.update(product_params)
      render json: @product, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/products/:id (Solo Admins)
  def destroy
    if @product.purchase_items.exists?
      render json: { error: "No se puede eliminar el producto: tiene compras asociadas." }, status: :unprocessable_entity
    else
      @product.destroy
      head :no_content
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Producto no encontrado" }, status: :not_found
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :barcode, :brand, :model, :status)
  end
end
