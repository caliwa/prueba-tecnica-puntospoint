class OneTimeTokenValidator
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    accept_header = env['HTTP_ACCEPT'] || ''

    if request.path.start_with?('/api-docs') && accept_header.include?('text/html')
      token = request.params['access_token']
      
      begin
        Rails.application.message_verifier('one_time_token').verify(token)
        @app.call(env)
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        [302, { 'Location' => '/', 'Content-Type' => 'text/html' }, ['Acceso no autorizado o expirado.']]
      end
    else
      @app.call(env)
    end
  end
end