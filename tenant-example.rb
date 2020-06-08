require 'fusionauth/fusionauth_client'
require 'pp'

time = Time.now.getutc.to_s

generic_tenant_client = FusionAuth::FusionAuthClient.new(
      ENV['API_KEY'],
      'http://localhost:9011'
    )

# create a new tenant
tenants_response = generic_tenant_client.retrieve_tenants
#PP.pp tenants.success_response.tenants.select { |t| t.name == 'Default' }[0].id
if tenants_response.status != 200
  puts "Unable to retrieve tenants."
  return
end

default_tenant_id = tenants_response.success_response.tenants.select { |t| t.name == 'Default' }[0].id
default_tenant_theme_id = tenants_response.success_response.tenants.select { |t| t.name == 'Default' }[0].themeId

new_tenant_request = { "sourceTenantId": default_tenant_id, tenant: {"name": "New client "+time }}
new_tenant_response = generic_tenant_client.create_tenant(nil, new_tenant_request)

if new_tenant_response.status != 200
  puts "Unable to create tenant."
  return
end

new_tenant = new_tenant_response.success_response.tenant

# used for making requests scoped to this tenant
new_tenant_client = FusionAuth::FusionAuthClient.new(
      ENV['API_KEY'],
      'http://localhost:9011'
    )
new_tenant_client.set_tenant_id(new_tenant.id)

# create an application in that tenant
new_application_request = { application: {"name": "New client app "+time }}
new_application_response = new_tenant_client.create_application(nil, new_application_request)

if new_application_response.status != 200
  puts "Unable to create application."
  return
end

# create new theme
new_theme_request = { "sourceThemeId": default_tenant_theme_id, theme: {"name": "New theme "+time }}
new_theme_response = generic_tenant_client.create_theme(nil, new_theme_request)
if new_theme_response.status != 200
  puts "Unable to create new theme."
  return
end

# update new theme to helpers from this repo
theme = new_theme_response.success_response.theme
# msgs = theme.defaultMessages
#puts msgs

#keys = msgs.to_h.keys
#m_body = {}
#keys.each { |k| m_body[k.to_s] = msgs.to_h[k] }


templates = theme.templates
#puts templates.to_h.keys.length
#puts templates.helpers

# modify the title tag
templates.helpers = IO.read(File.new("helpers"))

keys = templates.to_h.keys
t_body = {}
keys.each { |k| t_body[k.to_s] = templates.to_h[k] }
patch_theme_request = { theme: {templates: t_body}}
#puts update_theme_request.to_json
#puts theme.id
#puts patch_theme_request 
patch_theme_response = generic_tenant_client.patch_theme(theme.id, patch_theme_request)

if patch_theme_response.status != 200
  #PP.pp update_theme_response
  puts "Unable to update theme."
  puts patch_theme_response.error_response
  return
end

# update tenant with new theme

patch_tenant_theme_request = { tenant: {themeId: theme.id} }
patch_tenant_theme_response = generic_tenant_client.patch_tenant(new_tenant.id, patch_tenant_theme_request)

if patch_tenant_theme_response.status != 200
  puts "Unable to update tenant to new theme."
  puts patch_tenant_theme_response.error_response
  return
end

puts "Success. Enjoy your new tenant."

#puts theme_response.success_response.theme.templates.to_h.keys

# change something
# push the theme
# set the theme for the new tenant
# TODO put into methods
