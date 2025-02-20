

client = Auth0Client.new(
  client_id: ENV['AUTH0_CLIENT_ID'],
  client_secret: ENV['AUTH0_CLIENT_SECRET'],
  domain: ENV['AUTH0_DOMAIN'],
  token: ENV['AUTH0_MGMT_API_TOKEN'],
)
BEARER_TOKEN = client.instance_variable_get(:@token)
API_BASE_URL = "https://#{ENV['AUTH0_DOMAIN']}"

def make_request(verb, url:, body: nil)
  url = URI([API_BASE_URL, url].join)
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = case verb
  when :get
    Net::HTTP::Get.new(url)
  when :post
    Net::HTTP::Post.new(url)
  else
    raise "Unexpected verb: #{verb}"
  end

  request["Content-Type"] = "application/json"
  request["Accept"] = "application/json"
  request['Authorization'] = "Bearer #{BEARER_TOKEN}" 
  
  if body
    request.body = JSON.dump(body)
  end
  
  puts "Request: #{verb} #{url}"
  JSON.parse(https.request(request).read_body)
  # TODO: raise error if not success
end


def create_organisation(name, display_name)
  body = {
    "name": name,
    "display_name": display_name
    # "branding": {
    #   "logo_url": "string",
    #   "colors": {
    #     "primary": "string",
    #     "page_background": "string"
    #   }
    # },
    # "metadata": {},
    # "enabled_connections": [
    #   {
    #     "connection_id": "string",
    #     "assign_membership_on_login": true,
    #     "show_as_button": true,
    #     "is_signup_enabled": true
    #   }
    # ]
  }
  make_request(:post, url: "/api/v2/organizations", body: body)
end


def create_sso_ticket(self_service_profile_id, organization_id)
  # https://auth0.com/docs/api/management/v2/self-service-profiles/post-sso-ticket

  body = {
    # "connection_id": "string",
    "connection_config": {
      "name": "this-is-the-conn-name",
      "display_name": "this is the conn display name",
      # "is_domain_connection": true, # "promotes to a domain-level connection so that third-party applications can use it"
      "show_as_button": true,
      "metadata": {
        "some": "metadata",
        "maybe": "our merchant ID"
      },
      # "options": {
      #   "icon_url": "string",
      #   "domain_aliases": [
      #     "string"
      #   ]
      # }
    },
    # "clients" are apps, eg merchant-dashboard
    # "enabled_clients": [
    #   "string"
    # ],
    "enabled_organizations": [
      {
        "organization_id": organization_id
        # "assign_membership_on_login": true,
        # "show_as_button": true
      }
    ],
    "ttl_sec": 0
  }
  make_request(:post, url: "/api/v2/self-service-profiles/#{self_service_profile_id}/sso-ticket", body: body)
end


# # List orgs
# organisations_list = make_request(:get, url: "/api/v2/organizations")
# puts organisations_list


# # * Create an Auth0 Organisation via Mgmt API - simulates the merchant enabling SSO
# timestamp = Time.now.to_i # make the name unique
# merchant_org = create_organisation("machine_friendly_name_#{timestamp}", "Human name #{timestamp}")

# puts merchant_org.fetch("id")
# organization_id = merchant_org.fetch("id")
organization_id = "org_rx532f12PN7E3rAQ" # "My Company Ltd"


# Create the "Self service profile"
# Currently only one profile can be created per tenant.
# A profile is your configuration for what your customers can choose, what their experience is like

# I've manually created the profile in the dashboard as I don't think we'd use the API to create it
self_service_profiles = make_request(:get, url: '/api/v2/self-service-profiles')
self_service_profile_id = self_service_profiles[0].fetch("id")


# Create a Self service "ticket" (URL)
# This gives us a URL to send the merchant to so they can setup/manage their SSO
# They can have multiple connections - we'd either provide a connection_id (edit), or connection_config (new)
# 
# The link requires no auth, it just works - eg incognito window
# I didn't see anything to stop us embedding in an iframe, ie no X-FRAME-OPTIONS header
# 
# By default, access ticket URLs remain valid for five days after generation.
# After accessing the ticket URL, the customer admin has five hours to complete their setup.
# An access ticket URL can be accessed a maximum of 10 times; once this limit is reached, a new access ticket must be requested.
# 
# 
ticket = create_sso_ticket(self_service_profile_id, organization_id)
puts ticket


# We 