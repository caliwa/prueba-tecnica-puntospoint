# spec/requests/authentication_spec.rb
require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  # Define schemas como constantes para que estén disponibles en todo el contexto
  USER_SCHEMA = {
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
  }.freeze

  USER_RESPONSE_SCHEMA = {
    type: :object,
    properties: {
      id: { type: :integer, example: 1 },
      email: { type: :string, example: 'user@example.com' },
      type: { type: :string, example: 'Customer' },
      created_at: { type: :string, format: 'date-time' },
      updated_at: { type: :string, format: 'date-time' }
    }
  }.freeze

  LOGIN_SCHEMA = {
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
    required: [ 'user' ]
  }.freeze

  path '/users' do
    post('Crear una nueva cuenta de usuario') do
      tags 'Authentication'
      description 'Registro de nuevo usuario. Acepta Customer o Admin como tipo.'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: USER_SCHEMA

      response(200, 'Usuario creado exitosamente') do
        let(:user) { { user: { email: 'test@example.com', password: 'password123', password_confirmation: 'password123', type: 'Customer' } } }
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 200 },
                     message: { type: :string, example: 'Autenticado y creado correctamente' }
                   }
                 },
                 data: USER_RESPONSE_SCHEMA
               }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']['code']).to eq(200)
          expect(data['data']).to have_key('email')
        end
      end

      response(422, 'Error de validación') do
        let(:user) { { user: { email: 'invalid-email', password: 'p' } } }
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 422 },
                     message: { type: :string, example: 'El usuario no pudo ser creado.' }
                   }
                 }
               }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']['code']).to eq(422)
          expect(data['status']['message']).to include('no pudo ser creado')
        end
      end

      response(429, 'Demasiadas peticiones') do
        let(:user) { { user: { email: 'test@example.com', password: 'password123', password_confirmation: 'password123' } } }
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Demasiadas peticiones' }
               }
        run_test!
      end
    end
  end

  path '/users/sign_in' do
    post('Iniciar sesión de usuario') do
      tags 'Authentication'
      description 'Autenticación de usuario con email y password. Retorna un token JWT en el header Authorization.'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: LOGIN_SCHEMA

      response(200, 'Login exitoso') do
        let(:test_user) { User.create!(email: 'test@example.com', password: 'password123', type: 'Customer') }
        let(:user) { { user: { email: test_user.email, password: 'password123' } } }

        header 'Authorization', type: :string, description: 'Bearer token JWT para autenticación en futuras peticiones.'

        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 200 },
                     message: { type: :string, example: 'Logueado exitosamente' }
                   }
                 },
                 data: USER_RESPONSE_SCHEMA
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']['code']).to eq(200)
          expect(data['status']['message']).to eq('Logueado exitosamente')
          expect(data['data']).to have_key('email')
          expect(response.headers['Authorization']).to be_present
        end
      end

      response(401, 'Credenciales inválidas') do
        let(:user) { { user: { email: 'wrong@test.com', password: 'wrong' } } }
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Invalid Email or password.' }
               }
        run_test!
      end

      response(429, 'Demasiadas peticiones') do
        let(:user) { { user: { email: 'test@example.com', password: 'password123' } } }
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Demasiadas peticiones' }
               }
        run_test!
      end
    end
  end

  path '/users/sign_out' do
    delete('Cerrar sesión de usuario') do
      tags 'Authentication'
      description 'Cierra la sesión del usuario actual. Requiere token JWT válido.'
      produces 'application/json'
      security [ Bearer: [] ]

      response(200, 'Logout exitoso') do
        # Simular usuario autenticado
        let(:Authorization) { 'Bearer valid_jwt_token' }

        schema type: :object,
               properties: {
                 status: { type: :integer, example: 200 },
                 message: { type: :string, example: 'Deslogueado exitosamente' }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(200)
          expect(data['message']).to eq('Deslogueado exitosamente')
        end
      end

      response(401, 'No autorizado') do
        let(:Authorization) { 'Bearer invalid_token' }

        schema type: :object,
               properties: {
                 status: { type: :integer, example: 401 },
                 message: { type: :string, example: 'No se pudo encontrar una sesión activa.' }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(401)
        end
      end
    end
  end
end
