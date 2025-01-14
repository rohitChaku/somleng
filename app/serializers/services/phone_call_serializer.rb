module Services
  class PhoneCallSerializer < ResourceSerializer
    def attributes
      super.merge(
        "voice_url" => nil,
        "voice_method" => nil,
        "status_callback_url" => nil,
        "status_callback_method" => nil,
        "twiml" => nil,
        "to" => nil,
        "from" => nil,
        "sid" => nil,
        "account_sid" => nil,
        "account_auth_token" => nil,
        "direction" => nil,
        "api_version" => nil
      )
    end

    def api_version
      TwilioAPISerializer::API_VERSION
    end

    def account_auth_token
      object.account.auth_token
    end
  end
end
