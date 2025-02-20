Rails.application.config.auth0 = Rails.application.config_for(:auth0)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    Rails.application.config.auth0['auth0_client_id'],
    Rails.application.config.auth0['auth0_client_secret'],
    Rails.application.config.auth0['auth0_domain'],
    callback_path: '/auth/auth0/callback',
    authorize_params: {
      scope: 'openid profile email'
      # Alternative way of passing params to Auth0  
      # organization: "org_rx532f12PN7E3rAQ"
    }
  )
end
