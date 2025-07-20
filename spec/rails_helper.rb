require 'rails_helper'

# --- NOTA ---
# Este es un archivo consolidado de ejemplo. La mejor práctica es separar
# las especificaciones por controlador en diferentes archivos.
# (ej. analytics_spec.rb, categories_spec.rb, authentication_spec.rb)

# ==============================================================================
# SPEC PARA AUTHENTICATION (DEVISE)
# ==============================================================================
RSpec.describe 'Authentication API', type: :request do
  # Path para el registro de usuarios
  path '/signup' do
    post('Create a new user account') do
      tags 'Authentication'
      summary 'Crear una nueva cuenta de usuario'
      description 'Registro de nuevo usuario. Acepta Customer o Admin como tipo.'
      consumes 'application/json'
      produces 'application/json'

      # Definición del cuerpo de la petición (payload)
      parameter name: :user_payload, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'new_user@example.com' },
              password: { type: :string, example: 'password123' },
              password_confirmation: { type: :string, example: 'password123' },
              type: { type: :string, example: 'Customer', description: 'Puede ser Customer o Admin' }
            },
            required: %w[email password]
          }
        },
        required: [ :user ]
      }

      response(200, 'Usuario creado exitosamente') { run_test! }
      response(422, 'Error de validación') { run_test! }
    end
  end

  # Path para el inicio de sesión
  path '/login' do
    post('Login user') do
      tags 'Authentication'
      summary 'Iniciar sesión de usuario'
      description 'Autenticación de usuario con email y password. Retorna un token JWT en el header Authorization.'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :login_payload, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'admin@example.com' },
              password: { type: :string, example: 'password123' }
            },
            required: %w[email password]
          }
        },
        required: [ :user ]
      }

      response(200, 'Login exitoso') do
        # Rswag usa esto para documentar el header de respuesta
        header 'Authorization', type: :string, description: 'Bearer token JWT para autenticación.'
        run_test!
      end
      response(401, 'Credenciales inválidas') { run_test! }
    end
  end

  # Path para cerrar sesión
  path '/logout' do
    delete('Logout user') do
      tags 'Authentication'
      summary 'Cerrar sesión de usuario'
      # Esta ruta SÍ requiere autenticación para saber a quién desloguear
      security [ bearer_auth: [] ]

      response(200, 'Logout exitoso') { run_test! }
      response(401, 'No autorizado') { run_test! }
    end
  end
end


# ==============================================================================
# SPEC PARA ANALYTICS
# ==============================================================================
RSpec.describe 'Analytics API', type: :request do
  # Todas las rutas de Analytics requieren autenticación
  let(:user) { create(:user) } # Asume FactoryBot
  let(:Authorization) { "Bearer #{generate_jwt_token_for(user)}" } # Asume que tienes un helper para esto

  path '/api/v1/analytics/most_purchased_products_by_category' do
    get('Productos más comprados por categoría') do
      tags 'Analytics'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response(200, 'successful') { run_test! }
      response(401, 'unauthorized') { run_test! }
    end
  end

  path '/api/v1/analytics/top_revenue_products_by_category' do
    get('Top 3 productos con más ingresos por categoría') do
      tags 'Analytics'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response(200, 'successful') { run_test! }
      response(401, 'unauthorized') { run_test! }
    end
  end

  path '/api/v1/analytics/purchases_list' do
    get('Listado de compras con filtros') do
      tags 'Analytics'
      produces 'application/json'
      security [ bearer_auth: [] ]

      # Definición de parámetros de consulta (query params)
      parameter name: :purchase_date_from, in: :query, type: :string, format: :date, required: false
      parameter name: :purchase_date_to, in: :query, type: :string, format: :date, required: false
      parameter name: :category_id, in: :query, type: :integer, required: false
      parameter name: :customer_id, in: :query, type: :integer, required: false

      response(200, 'successful') { run_test! }
      response(401, 'unauthorized') { run_test! }
    end
  end

  path '/api/v1/analytics/purchase_counts_by_granularity' do
    get('Conteo de compras agrupadas por tiempo') do
      tags 'Analytics'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :granularity, in: :query, type: :string, enum: %w[hour day week month year], required: true
      parameter name: :purchase_date_from, in: :query, type: :string, format: :date, required: false
      parameter name: :purchase_date_to, in: :query, type: :string, format: :date, required: false

      response(200, 'successful') { run_test! }
      response(400, 'bad_request') { run_test! }
      response(401, 'unauthorized') { run_test! }
    end
  end
end

# ==============================================================================
# SPEC PARA CATEGORIES (Ejemplo de un CRUD)
# ==============================================================================
RSpec.describe 'Categories API', type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { "Bearer #{generate_jwt_token_for(user)}" }

  path '/api/v1/categories' do
    get('List all categories') do
      tags 'Categories'
      produces 'application/json'
      security [ bearer_auth: [] ]
      response(200, 'successful') { run_test! }
      response(401, 'unauthorized') { run_test! }
    end

    post('Create a category') do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Nueva Categoría' },
          status: { type: :string, example: 'active' }
        },
        required: [ 'name' ]
      }

      response(201, 'created') { run_test! }
      response(422, 'unprocessable entity') { run_test! }
    end
  end

  path '/api/v1/categories/{id}' do
    # Definición del parámetro que va en la URL
    parameter name: 'id', in: :path, type: :string, description: 'category id'

    get('Show a category') do
      tags 'Categories'
      produces 'application/json'
      security [ bearer_auth: [] ]
      response(200, 'successful') { run_test! }
      response(404, 'not found') { run_test! }
    end

    patch('Update a category') do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Categoría Actualizada' },
          status: { type: :string, example: 'inactive' }
        }
      }

      response(200, 'successful') { run_test! }
      response(404, 'not found') { run_test! }
    end

    delete('Delete a category') do
      tags 'Categories'
      security [ bearer_auth: [] ]
      response(204, 'no content') { run_test! }
      response(404, 'not found') { run_test! }
    end
  end
end
