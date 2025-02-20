jcobbett+auth0-user@gocardless.com


# PoC scope

GET /authorise?client_id|app=MERCHANT_DASHBOARD&connection=PaysvcOrg1Connection

We will use the "Enterprise Connections"

## Questions we want to answer:

### 1. Do we need to generate a semi-specific auth0 URL to send the user to, or can we just send them to our Auth0 login URL?

If we do:
* We think MD can know the Client ID, it is just a string identifier for the app within our Auth0, eg `merchant-dashboard`
* Mike thinks we need to supply a Connection ID, eg `PaysvcOrg1Connection`
    * Could that be a human readable name that the user can enter?

If we don't:
* Can we just redirect straight to Auth0, and have it use Home Realm Discovery (based on email) to figure out which Connection to use

### 2. Can we use the mgmt API to setup SSO with a third party


I'll need two IdP instances:
* One simulating the GC tenant, must be Auth0
* Another simulating the Merchant IdP, could be Auth0, or Keycloak


## Target output

Demo (eg a script) showing we can:
* [DONE] Create an Auth0 Organisation via Mgmt API - simulates the merchant enabling SSO
* [DONE] Use the Self-Service SSO Config Auth0 feature to set up merchant IdP in Auth0
* [DONE] Configure the Merchant IdP within the GC Auth0 tenant
* [DONE] Authenticate with the Auth0 test app joining everything together
* [DONE] Result is an ID Token issued by the GC Auth0 tenant
* [DONE] Get logged in with an email not entering "company name"


TODO:

[] Record a video (Loom?) of the flow, including script

# things wot I have learned:

I think we'll need to change the login flow:

1. Users enter just email (I think this is called "identifier first")
2. We can inspect the email domain and decide if they belong to a merchant with SSO enabled or not
    - what happens if a merchant has users on a domain not on their list?
3. If they are not SSO, we then ask for password, MFA etc.
4. If they are SSO, we can get the Auth0 organization_id for their merchant
5. We redirect them to Auth0 with the organization_id param (first to /auth/auth0?organization=xxxxx on our domain, which then redirects to Auth0 domain -- auth0-react might be different)
6. Auth0 redirects them to their IdP
7. They login, come back to us, everybody's golden 🎉


I think we'll need to store:
* for a merchant:
    * whether SSO is enabled
    * a list of email domains
    * the Auth0 organization_id, once created
    * the Auth0 connection_id, once they have setup their SSO

* fixed config (env var): our `self_service_profile_id` - or we could look it up via API every time :shrug:




Self-Service SSO currently supports the following identity providers:

* Okta Workforce Identity Cloud (using OIDC)
* Entra ID
* Google Workspace (using OIDC)
* Keycloak
* Microsoft Active Directory Federation Services (ADFS)
* PingFederate
* Generic OIDC
* Generic SAML


https://auth0.com/docs/authenticate/protocols/saml/saml-configuration/configure-auth0-as-service-and-identity-provider

# Glossary




## IdP
## Claim
##Token

## Auth0 Tenant

Most organisations have a single tenant to handle their use case, but you might have multiple. It contains everything else.

## Auth0 Organisation
##Auth0 Tenant


## "ID Token" aka SSO token

eg: Bearer tokens (OAuth, OIDC)
eg: SAML assertions
eg: Kerberos tickets

To facilitate SSO, Identity Providers and Service Providers use ID Tokens as intermediaries. ID Tokens are issued by Identity Providers, acting as proof that a user has been authenticated. Clients use ID Tokens as credentials, exchanging them for Access Tokens with Service Providers.