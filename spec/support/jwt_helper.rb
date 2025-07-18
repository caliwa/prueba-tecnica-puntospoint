module JwtHelper
  # Incluye los helpers de rutas de Devise para poder usar `user_session_path`, etc. si fuera necesario.
  include Devise::Controllers::UrlHelpers

  # Genera un token JWT para un usuario específico.
  # @param user [User] El objeto de usuario para el cual se generará el token.
  # @return [String] El token JWT.
  def generate_jwt_token_for(user)
    # --- CORRECCIÓN ---
    # Obtenemos la clave secreta para firmar el token directamente desde la configuración
    # de Rails, tal como se define en tu `config/initializers/devise.rb`.
    # Esto asegura que el token de prueba se firme con la misma clave que usa la aplicación.
    secret = Rails.application.secret_key_base

    # Salvaguarda para asegurar que la clave secreta no esté vacía.
    if secret.blank?
      raise "La clave secreta para JWT no está configurada. Por favor, define 'secret_key_base' en tu entorno."
    end

    # Obtenemos la estrategia de revocación. `Null` es la estrategia por defecto
    # si no se ha configurado una diferente (como JTIMatcher) en el modelo User.
    warden_scope = Devise.mappings[:user].to_s
    strategy = Devise::JWT::JTIMatchers::Null.new

    # Creamos el payload del token.
    # 'jti' (JWT ID) y 'aud' (Audience) son generados por la estrategia.
    payload = {
      sub: user.id.to_s, # 'sub' (subject) es el ID del usuario.
      scp: warden_scope, # 'scp' (scope) es el scope de Devise.
      aud: strategy.aud,
      iat: Time.now.to_i, # 'iat' (issued at) es el momento de creación.
      # --- CORRECCIÓN ---
      # El tiempo de expiración se ajusta a 30 minutos para coincidir
      # con `config.jwt.expiration_time` en tu archivo devise.rb.
      exp: (Time.now + 30.minutes).to_i
    }
    jti = strategy.call(payload)
    payload.merge!(jti)

    # Codificamos el token usando el algoritmo HS256 (el default de devise-jwt).
    JWT.encode(payload, secret, 'HS256')
  end
end
