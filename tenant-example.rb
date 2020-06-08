require './tenantops'

NAME = "Organization2"
FA_URL = "http://localhost:9011"

generic_tenant_client = FusionAuth::FusionAuthClient.new(ENV['API_KEY'], FA_URL)

result = create_new_tenant(generic_tenant_client, NAME)

unless result
  return
end

default_tenant_theme_id, new_tenant = result

result = create_application(new_tenant.id, NAME)

unless result
  return
end

result = create_new_theme(generic_tenant_client, NAME, default_tenant_theme_id)
unless result
  return
end

theme = result

result = update_theme(generic_tenant_client, theme)
unless result
  return
end

result = update_tenant_with_new_theme(generic_tenant_client, new_tenant.id, theme.id)

unless result
  return
end

puts "Success. Enjoy your new tenant."

