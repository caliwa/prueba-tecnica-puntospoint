# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

# Define one or more Swagger documents and provide global metadata for each one
# When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
# be generated at the provided relative path under openapi_root
# By default, the operations defined in spec files are added to the first
# document below. You can override this behavior by adding a openapi_spec tag to the
# the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        }
      ],
      # --- INICIO DE LA SECCIÓN IMPORTANTE ---
      components: {
        schemas: {
          # Schema para la respuesta de un usuario (ya lo tenías referenciado)
          user_response: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string },
              type: { type: :string },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id email type]
          },
          # Schema para el payload de signup
          user_signup_payload: {
            type: :object,
            properties: {
              user: {
                type: :object,
                properties: {
                  email: { type: :string, example: 'user@example.com' },
                  password: { type: :string, example: 'password123' },
                  password_confirmation: { type: :string, example: 'password123' },
                  type: { type: :string, example: 'Customer', description: 'Puede ser Customer o Admin' }
                },
                required: %w[email password password_confirmation]
              }
            },
            required: [ 'user' ]
          },
          # Schema para el payload de login
          user_login_payload: {
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
          }
        },
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'Ingresa el token JWT con el prefijo Bearer. Ejemplo: "Bearer {tu_token}"'
          }
        }
      }
      # --- FIN DE LA SECCIÓN IMPORTANTE ---
    }
  }


  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
