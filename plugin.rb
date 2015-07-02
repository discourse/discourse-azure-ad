# name: discourse-azure-ad
# about: Microsoft Azure Active Directory OAuth support for Discourse
# version: 0.1
# authors: Neil Lalonde
# url: https://github.com/discourse/discourse-azure-ad

require_dependency 'auth/oauth2_authenticator'

gem 'omniauth-azure-oauth2', '0.0.5'

class AzureOAuth2Authenticator < ::Auth::OAuth2Authenticator
  def register_middleware(omniauth)
    omniauth.provider :azure_oauth2,
                      :name => 'azure_oauth2',
                      :client_id => "9777d5c7-a0a7-430f-abab-63db039af307", #GlobalSetting.azure_oauth2_client_id,
                      :client_secret => "nGNdi1ECKT2GISkt2B3BedzbR1QZpHGyftMbqG6Dd7g=" #GlobalSetting.azure_oauth2_client_secret
  end

  def after_authenticate(auth)
    result = Auth::Result.new

    Rails.logger.error "=========================================================================="
    Rails.logger.error auth.inspect
    Rails.logger.error "=========================================================================="

    # result.username = auth['username'] # TODO: do we get one?
    if info = auth['info'].present?
      email = auth['info']['email']
      if email.present?
        result.email = email
        result.email_valid = true
      end
    end

    current_info = ::PluginStore.get("azure_oauth2", "meteor_user_#{auth['uid']}")
    if current_info
      result.user = User.where(id: current_info[:user_id]).first
    end
    result.extra_data = { azure_user_id: auth['uid'] }
    result
  end

  def after_create_account(user, auth)
    ::PluginStore.set("azure_oauth2", "azure_oauth2_user_#{auth['uid']}", {user_id: user.id })
  end

end

title = GlobalSetting.try(:azure_oauth2_title) || "Azure AD"
button_title = GlobalSetting.try(:azure_oauth2_title) || "with Azure AD"

auth_provider :title => button_title,
              :authenticator => AzureOAuth2Authenticator.new('azure_oauth2'),
              :message => "Authorizing with #{title} (make sure pop up blockers are not enabled)",
              :frame_width => 600,
              :frame_height => 380,
              :background_color => '#71B1D1'
