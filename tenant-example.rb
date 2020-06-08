require 'fusionauth/fusionauth_client'

@client = FusionAuth::FusionAuthClient.new(
      ENV['API_KEY'],
      'http://localhost:9011'
    )
