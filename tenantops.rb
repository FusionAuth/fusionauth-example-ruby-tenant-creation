require 'fusionauth/fusionauth_client'
require 'pp'

def create_new_tenant(generic_tenant_client, name)
  # create a new tenant
  tenants_response = generic_tenant_client.retrieve_tenants
  #PP.pp tenants.success_response.tenants.select { |t| t.name == 'Default' }[0].id
  if tenants_response.status != 200
    puts "Unable to retrieve tenants."
    return
  end
  
  default_tenant_id = tenants_response.success_response.tenants.select { |t| t.name == 'Default' }[0].id
  default_tenant_theme_id = tenants_response.success_response.tenants.select { |t| t.name == 'Default' }[0].themeId
  
  new_tenant_request = { "sourceTenantId": default_tenant_id, tenant: {"name": "New client - "+name }}
  new_tenant_response = generic_tenant_client.create_tenant(nil, new_tenant_request)

  if new_tenant_response.status != 200
    puts "Unable to create tenant."
    puts new_tenant_response.error_response
    return false
  end
  new_tenant = new_tenant_response.success_response.tenant
  [default_tenant_theme_id, new_tenant]
end

def create_application(new_tenant_id, name)
  # used for making requests scoped to this tenant
  new_tenant_client = FusionAuth::FusionAuthClient.new(ENV['API_KEY'], FA_HOST)
  new_tenant_client.set_tenant_id(new_tenant_id)
  
  # create an application in that tenant
  new_application_request = { application: {"name": "New client app - "+name }}
  new_application_response = new_tenant_client.create_application(nil, new_application_request)
  
  if new_application_response.status != 200
    puts "Unable to create application."
    puts new_application_response.error_response
    return false
  end
  true
end

def create_new_theme(generic_tenant_client, name, default_tenant_theme_id)
  # create new theme
  new_theme_request = { "sourceThemeId": default_tenant_theme_id, theme: {"name": "New theme - "+name }}
  new_theme_response = generic_tenant_client.create_theme(nil, new_theme_request)
  if new_theme_response.status != 200
    puts "Unable to create new theme."
    puts new_theme_response.error_response
    return false
  end
  new_theme_response.success_response.theme
end

def update_theme(generic_tenant_client, theme)
  templates = theme.templates
  # modify the title tag
  templates.helpers = IO.read(File.new("helpers"))

  # convert template object to hash
  keys = templates.to_h.keys
  t_body = {}
  keys.each { |k| t_body[k.to_s] = templates.to_h[k] }
  patch_theme_request = { theme: {templates: t_body}}
  patch_theme_response = generic_tenant_client.patch_theme(theme.id, patch_theme_request)

  if patch_theme_response.status != 200
    #PP.pp update_theme_response
    puts "Unable to patch theme."
    puts patch_theme_response.error_response
    return false
  end

  true
end

def update_tenant_with_new_theme(generic_tenant_client, new_tenant_id, theme_id)

  # update tenant with new theme

  patch_tenant_theme_request = { tenant: {themeId: theme_id} }
  patch_tenant_theme_response = generic_tenant_client.patch_tenant(new_tenant_id, patch_tenant_theme_request)
  
  if patch_tenant_theme_response.status != 200
    puts "Unable to update tenant to new theme."
    puts patch_tenant_theme_response.error_response
    return false
  end
  true
end

