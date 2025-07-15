# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Carpeta raíz donde se generan los archivos de OpenAPI (Swagger).
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define los documentos de OpenAPI y sus metadatos globales.
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.1.0',
      info: {
        title: 'Puntospoint API E-Commerce',
        version: 'v1',
        description: 'Documentación de la API para el sistema E-Commerce de Puntospoint. 🛒'
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
      # Aquí se definen los componentes reutilizables como schemas y seguridad.
      components: {
        schemas: {
          user_response: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              email: { type: :string, example: 'user@example.com' },
              type: { type: :string, example: 'Customer', description: 'Puede ser Customer o Admin' },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id email type]
          }
        },
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'Token de autorización JWT. Incluir "Bearer " antes del token. Ejemplo: "Bearer eyJhbGciOiJIUzI1NiJ9..."'
          }
        }
      }
    }
  }

  # Especifica el formato del archivo de salida.
  config.openapi_format = :yaml
end
