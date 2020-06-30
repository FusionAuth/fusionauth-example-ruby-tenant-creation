require 'fusionauth/fusionauth_client'
require 'pp'

FA_URL = "http://localhost:9011"
TENANT_ID = "YOUR_TENANT_ID"

tenant_client = FusionAuth::FusionAuthClient.new(ENV['API_KEY'], FA_URL)
tenant_client.set_tenant_id(TENANT_ID)
PP.pp tenant_client.retrieve_user_by_email('jared@piedpiper.com')
