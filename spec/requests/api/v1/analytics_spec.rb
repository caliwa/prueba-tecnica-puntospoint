# spec/requests/api/v1/analytics_spec.rb
require 'swagger_helper'

RSpec.describe 'API V1 Analytics', type: :request do
  let(:Authorization) { "Bearer <YOUR_JWT_TOKEN>" }

  path '/api/v1/analytics/most_purchased_products_by_category' do
    get('Productos más comprados por categoría') do
      tags 'Analytics'
      # summary 'Obtiene el producto más vendido (por cantidad) para cada categoría.'
      produces 'application/json'
      security [ Bearer: [] ]

      response(200, 'successful') do
        schema type: :object,
               description: 'Un objeto donde cada clave es el nombre de una categoría.',
               additionalProperties: {
                 type: :object,
                 properties: {
                   id: { type: :integer, example: 101 },
                   name: { type: :string, example: 'Producto X' },
                   total_quantity_sold: { type: :integer, example: 150 }
                 }
               },
               example: {
                 "Categoría A": { id: 101, name: "Producto X", total_quantity_sold: 150 },
                 "Categoría B": { id: 205, name: "Producto Y", total_quantity_sold: 98 }
               }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/analytics/top_revenue_products_by_category' do
    get('Top 3 productos con más ingresos por categoría') do
      tags 'Analytics'
      # summary 'Obtiene los 3 productos que más han recaudado ($) por cada categoría.'
      produces 'application/json'
      security [ Bearer: [] ]

      response(200, 'successful') do
        schema type: :object,
               description: 'Un objeto donde cada clave es el nombre de una categoría y el valor es un array con los 3 productos top.',
               additionalProperties: {
                 type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 102 },
                     name: { type: :string, example: 'Producto Z' },
                     total_revenue: { type: :number, format: :float, example: 1500.50 }
                   }
                 }
               },
               example: {
                 "Categoría A": [
                   { id: 102, name: "Producto Z", total_revenue: 1500.50 },
                   { id: 105, name: "Producto W", total_revenue: 1200.00 },
                   { id: 101, name: "Producto X", total_revenue: 950.75 }
                 ]
               }
        run_test!
      end

      response(401, 'unauthorized') do
        run_test!
      end
    end
  end

  path '/api/v1/analytics/purchases_list' do
    get('Listado de compras con filtros') do
      tags 'Analytics'
      # summary 'Obtiene un listado de compras aplicando filtros opcionales.'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :purchase_date_from, in: :query, type: :string, format: :date, description: 'Fecha de inicio (YYYY-MM-DD)', required: false
      parameter name: :purchase_date_to, in: :query, type: :string, format: :date, description: 'Fecha de fin (YYYY-MM-DD)', required: false
      parameter name: :category_id, in: :query, type: :integer, description: 'ID de la categoría para filtrar productos.', required: false
      parameter name: :customer_id, in: :query, type: :integer, description: 'ID del cliente (Customer).', required: false

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   customer_name: { type: :string },
                   purchase_date: { type: :string, format: :date },
                   total: { type: :number, format: :float },
                   status: { type: :string },
                   payment_method: { type: :string },
                   shipping_address: { type: :string },
                   items: {
                     type: :array,
                     items: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         product_name: { type: :string },
                         quantity: { type: :integer },
                         unit_price: { type: :number, format: :float },
                         total_price: { type: :number, format: :float },
                         discount_amount: { type: :number, format: :float },
                         tax_amount: { type: :number, format: :float }
                       }
                     }
                   }
                 }
               }
        run_test!
      end

      response(401, 'unauthorized') do
        run_test!
      end
    end
  end

  path '/api/v1/analytics/purchase_counts_by_granularity' do
    get('Conteo de compras agrupadas por tiempo') do
      tags 'Analytics'
      # summary 'Obtiene la cantidad de compras agrupadas por hora, día, semana, mes o año.'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :granularity, in: :query, type: :string, enum: %w[hour day week month year], description: 'Nivel de agrupación de tiempo.', required: true
      parameter name: :purchase_date_from, in: :query, type: :string, format: :date, description: 'Fecha de inicio (YYYY-MM-DD)', required: false
      parameter name: :purchase_date_to, in: :query, type: :string, format: :date, description: 'Fecha de fin (YYYY-MM-DD)', required: false
      parameter name: :category_id, in: :query, type: :integer, description: 'ID de la categoría para filtrar productos.', required: false
      parameter name: :customer_id, in: :query, type: :integer, description: 'ID del cliente (Customer).', required: false

      response(200, 'successful') do
        schema type: :object,
               description: 'Un objeto donde cada clave es el período de tiempo formateado y el valor es el conteo de compras.',
               additionalProperties: { type: :integer },
               example: {
                 "2025-07-14": 22,
                 "2025-07-15": 15
               }
        run_test!
      end

      response(400, 'bad_request') do
        let(:granularity) { 'invalid_granularity' }
        schema type: :object, properties: { error: { type: :string } }
        run_test!
      end

      response(401, 'unauthorized') do
        run_test!
      end
    end
  end
end
