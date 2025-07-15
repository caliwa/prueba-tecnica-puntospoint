class Api::V1::CustomersController < ApplicationController
  rate_limit to: 10, within: 30.seconds, with: -> { render json: { error: "Demasiadas peticiones" }, status: 429 }, store: cache_store
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_customer, only: %i[show update destroy]

  # GET /api/v1/customers
  def index
    @customers = Customer.all
    render json: @customers, status: :ok
  end

  # GET /api/v1/customers/:id
  def show
    render json: @customer, status: :ok
  end

  # POST /api/v1/customers
  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      render json: @customer, status: :created
    else
      render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/customers/:id
  def update
    if @customer.update(customer_params)
      render json: @customer, status: :ok
    else
      render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/customers/:id
  def destroy
    if @customer.can_be_deleted?
      @customer.destroy
      head :no_content
    else
      render json: { error: "No se puede eliminar el cliente: tiene un historial de compras existente." }, status: :unprocessable_entity
    end
  end
  private

  def set_customer
    @customer = Customer.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Cliente no encontrado." }, status: :not_found
  end

  def customer_params
    params.require(:customer).permit(:name, :surname, :email, :phone, :address, :registration_date, :status)
  end
end
