# name: discourse-azure-ad
# about: Microsoft Azure Active Directory OAuth support for Discourse
# version: 0.1
# authors: Neil Lalonde
# url: https://github.com/discourse/discourse-azure-ad

require_dependency 'auth/oauth2_authenticator'

gem 'omniauth-azure-oauth2', '0.0.8'

class AzureOAuth2Authenticator < ::Auth::OAuth2Authenticator
  def register_middleware(omniauth)
    omniauth.provider :azure_oauth2,
                      :name => 'azure_oauth2',
                      :tenant_id => GlobalSetting.try(:azure_tenant_id) || "common",
                      :client_id => GlobalSetting.azure_client_id,
                      :client_secret => GlobalSetting.azure_client_secret
  end

  def after_authenticate(auth)
    result = Auth::Result.new

    if info = auth['info'].present?
      email = auth['info']['email']
      if email.present?
        result.email = email
        result.email_valid = true
      end
      result.name = auth['info']['name']
    end

    current_info = ::PluginStore.get("azure_oauth2", "azure_oauth2_user_#{auth['uid']}")
    if current_info
      result.user = User.where(id: current_info[:user_id]).first
    elsif result.email_valid && (user = User.find_by_email(result.email))
      result.user = user
      plugin_store_azure_user auth['uid'], user.id
    end
    result.extra_data = { azure_user_id: auth['uid'] }
    result
  end

  def after_create_account(user, auth)
    plugin_store_azure_user auth[:extra_data][:azure_user_id], user.id
  end

  def plugin_store_azure_user(azure_user_id, discourse_user_id)
    ::PluginStore.set("azure_oauth2", "azure_oauth2_user_#{azure_user_id}", {user_id: discourse_user_id })
  end

end

title = GlobalSetting.try(:azure_title) || "Azure AD"
button_title = GlobalSetting.try(:azure_title) || "with Azure AD"

auth_provider :title => button_title,
              :authenticator => AzureOAuth2Authenticator.new('azure_oauth2'),
              :message => "Authorizing with #{title} (make sure pop up blockers are not enabled)",
              :frame_width => 725,
              :frame_height => 500,
              :background_color => '#71B1D1'
