module ApiHelpers
  def json
    JSON.parse(response.body)
  end

  def auth_headers_for(user)
    headers = { 'Accept' => 'application/json' }
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    headers['Authorization'] = "Bearer #{token}"
    headers
  end
end
