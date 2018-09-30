# name: discourse-azure-ad
# about: Microsoft Azure Active Directory OAuth support for Discourse
# version: 0.1
# authors: Neil Lalonde
# url: https://github.com/discourse/discourse-azure-ad

require_dependency 'auth/oauth2_authenticator'

gem 'omniauth-azure-oauth2', '0.0.8'

enabled_site_setting :azure_enabled

class AzureAuthenticator < ::Auth::OAuth2Authenticator
  def name
    'azure_oauth2'
  end
  
  def register_middleware(omniauth)
    if enabled?
      omniauth.provider :azure_oauth2,
                        :name => 'azure_oauth2',
                        :client_id => SiteSetting.azure_client_id,
                        :client_secret => SiteSetting.azure_client_secret
    end
  end

  def enabled?
    # SiteSetting.azure_enabled
    if SiteSetting.azure_enabled? && defined?(SiteSetting.azure_client_id) && defined?(SiteSetting.azure_client_secret)
      !SiteSetting.azure_client_id.blank? && !SiteSetting.azure_client_secret.blank?
    end
  end

  def can_revoke?
    true
  end

  def revoke(user, skip_remote: false)
    # info = GoogleUserInfo.find_by(user_id: user.id)
    info = ::PluginStore.get("azure_oauth2", "azure_oauth2_user_#{user['uid']}")
    raise Discourse::NotFound if info.nil?

    # We get a temporary token from google upon login but do not need it, and do not store it.
    # Therefore we do not have any way to revoke the token automatically on google's end

    info.destroy!
    true
  end

  def can_connect_existing_user?
    true
  end

  def after_authenticate(auth)
    result = Auth::Result.new

    if info = auth['info'].present?
      email = auth['info']['email']
      if email.present?
        result.email = email
        result.email_valid = true
      end
    end

    current_info = ::PluginStore.get("azure", "azure_user_#{auth['uid']}")
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
    ::PluginStore.set("azure", "azure_user_#{azure_user_id}", {user_id: discourse_user_id })
  end

end

# title = GlobalSetting.try(:azure_title) || "Azure AD"
# button_title = GlobalSetting.try(:azure_title) || "with Azure AD"

# title = SiteSetting.try(:azure_title) || "Azure AD"
# button_title = SiteSetting.try(:azure_button_title) || "with Azure AD"

auth_provider :title => "azure_button_title",
              :enabled_setting => "azure_enabled",
              :title_setting => "azure_button_title",
              :authenticator => AzureAuthenticator.new('azure_oauth2'),
              :message => "Authorizing with Azure AD (make sure pop up blockers are not enabled)",
              :frame_width => 725,
              :frame_height => 500,
              :background_color => '#71B1D1'

register_css <<CSS

.btn-social.azure {
  background: #71B1D1;
}
.btn-social.azure::before {
  content: $fa-var-windows;
}
CSS
