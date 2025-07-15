# spec/requests/authentication_spec.rb
require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  # Define un schema reutilizable para el cuerpo de la petición de usuario
  let(:user_schema) do
    {
      type: :object,
      properties: {
        user: {
          type: :object,
          properties: {
            email: { type: :string, example: 'user@example.com' },
            password: { type: :string, example: 'password123' },
            password_confirmation: { type: :string, example: 'password123', 'x-nullable': true },
            type: { type: :string, example: 'Customer', 'x-nullable': true, description: 'Puede ser Customer o Admin' }
          },
          required: %w[email password]
        }
      },
      required: [ 'user' ]
    }
  end

  # Define un schema reutilizable para la respuesta de un usuario serializado
  let(:user_response_schema) do
    {
      type: :object,
      properties: {
        id: { type: :integer, example: 1 },
        email: { type: :string, example: 'user@example.com' },
        type: { type: :string, example: 'Customer' },
        created_at: { type: :string, format: 'date-time' },
        updated_at: { type: :string, format: 'date-time' }
      }
    }
  end

  path '/signup' do
    post('Crear una nueva cuenta de usuario') do
      tags 'Authentication'
      summary 'Registra un nuevo usuario en el sistema.'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: user_schema

      response(200, 'successful') do
        let(:user) { { user: { email: 'test@example.com', password: 'password', password_confirmation: 'password', type: 'Customer' } } }
        schema type: :object,
               properties: {
                 status: { type: :object, properties: { code: { type: :integer, example: 200 }, message: { type: :string } } },
                 data: { '$ref' => '#/components/schemas/user_response' }
               }
        run_test!
      end

      response(422, 'unprocessable_entity') do
        let(:user) { { user: { email: 'test', password: 'p' } } }
        schema type: :object,
               properties: {
                 status: { type: :object, properties: { code: { type: :integer, example: 422 }, message: { type: :string } } }
               }
        run_test!
      end
    end
  end

  path '/login' do
    post('Iniciar sesión de usuario') do
      tags 'Authentication'
      summary 'Autentica a un usuario y retorna un token JWT en el header de autorización.'
      description "Proporciona email y password para obtener un token. **Nota:** Tu `SessionsController` actual tiene un filtro `authorize_admin!` que podría restringir el login solo a administradores. Esta documentación asume un comportamiento de login estándar."
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
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
        }
      }

      response(200, 'successful') do
        header 'Authorization', type: :string, description: 'Bearer token para autenticación.'
        let(:user) { create(:user) } # Asume que tienes FactoryBot configurado
        let(:user_params) { { user: { email: user.email, password: user.password } } }
        schema type: :object,
               properties: {
                 status: { type: :object, properties: { code: { type: :integer, example: 200 }, message: { type: :string } } },
                 data: { '$ref' => '#/components/schemas/user_response' }
               }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:user) { { user: { email: 'wrong@test.com', password: 'wrong' } } }
        run_test!
      end
    end
  end

  path '/logout' do
    delete('Cerrar sesión de usuario') do
      tags 'Authentication'
      summary 'Invalida el token JWT del usuario actual.'
      produces 'application/json'
      security [ Bearer: [] ]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 status: { type: :integer, example: 200 },
                 message: { type: :string }
               }
        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'invalid_token' }
        run_test!
      end
    end
  end
end
