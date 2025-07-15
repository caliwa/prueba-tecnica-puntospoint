# spec/requests/api/v1/user_spec.rb
require 'swagger_helper'

RSpec.describe 'API V1 User', type: :request do
  path '/api/v1/user/current_user' do
    get('Obtener datos del usuario autenticado') do
      tags 'User'
      summary 'Devuelve la información del usuario que realiza la petición.'
      produces 'application/json'
      security [ Bearer: [] ]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 email: { type: :string, example: 'user@example.com' },
                 type: { type: :string, example: 'Customer' },
                 created_at: { type: :string, format: 'date-time' },
                 updated_at: { type: :string, format: 'date-time' }
               },
               required: %w[id email type]
        run_test!
      end

      response(401, 'unauthorized') do
        run_test!
      end
    end
  end
end
