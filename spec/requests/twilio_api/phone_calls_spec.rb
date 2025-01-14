require "rails_helper"

RSpec.resource "Phone Calls", document: :twilio_api do
  header("Content-Type", "application/x-www-form-urlencoded")

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Calls" do
    example "List phone calls" do
      account = create(:account)
      phone_call = create(:phone_call, account:)
      _other_phone_call = create(:phone_call)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/call")
      expect(json_response.fetch("calls").pluck("sid")).to match_array([phone_call.id])
    end
  end

  post "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Calls" do
    parameter(
      "To",
      "The phone number to call.",
      required: true,
      example: "+299221234"
    )
    parameter(
      "From",
      "The phone number to use as the caller id",
      required: true,
      example: "1234"
    )
    parameter(
      "Url",
      "The absolute URL that returns the TwiML instructions for the call. We will call this URL using the `method` when the call connects.",
      required: false,
      example: "https://demo.twilio.com/docs/voice.xml"
    )
    parameter(
      "Method",
      "The HTTP method we should use when calling the url parameter's value. Can be: `GET` or `POST` and the default is `POST`.",
      required: false,
      example: "GET"
    )
    parameter(
      "Twiml",
      "TwiML instructions for the call Somleng will use without fetching Twiml from `Url` parameter. If both `Twiml` and `Url` are provided then `Twiml` parameter will be ignored.",
      required: false,
      example: "<Response><Say>Ahoy there!</Say></Response>"
    )
    parameter(
      "StatusCallback",
      "The URL we should call using the `status_callback_method` to send status information to your application. URLs must contain a valid hostname (underscores are not permitted).",
      required: false,
      example: "https://example.com/status_callback"
    )
    parameter(
      "StatusCallbackMethod",
      "The HTTP method we should use when calling the `status_callback` URL. Can be: `GET` or `POST` and the default is `POST`.",
      required: false,
      example: "POST"
    )

    # https://www.twilio.com/docs/voice/api/call-resource#create-a-call-resource
    example "Create a call" do
      account = create(:account)
      create(:sip_trunk, carrier: account.carrier)

      set_twilio_api_authorization_header(account)

      do_request(
        account_sid: account.id,
        "To" => "+299221234",
        "From" => "1234",
        "Url" => "https://demo.twilio.com/docs/voice.xml"
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/call")
    end

    example "Handles invalid requests", document: false do
      account = create(:account)

      set_twilio_api_authorization_header(account)
      do_request(
        account_sid: account.id,
        "To" => "+299221234",
        "From" => "1234",
        "Url" => "https://demo.twilio.com/docs/voice.xml"
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
      expect(json_response).to eq(
        "message" => "Calling this number is unsupported or the number is invalid",
        "status" => 422,
        "code" => 13_224,
        "more_info" => "https://www.twilio.com/docs/errors/13224"
      )
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Calls/:sid" do
    # https://www.twilio.com/docs/api/rest/call#instance-get

    example "Fetch a call" do
      account = create(:account)
      phone_call = create(:phone_call, account:)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, sid: phone_call.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/call")
    end
  end

  post "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Calls/:sid" do
    parameter(
      "Status",
      "The new status of the resource. Can be: `canceled` or `completed`. Specifying `canceled` will attempt to hang up calls that are `queued` or `ringing`; however, it will not affect calls already in progress. Specifying `completed` will attempt to hang up a call even if it's already in progress.",
      required: false,
      example: "completed"
    )

    # https://www.twilio.com/docs/voice/api/call-resource?code-sample=code-update-a-call-resource-to-end-the-call&code-language=curl&code-sdk-version=json#update-a-call-resource

    example "Update a call" do
      account = create(:account)
      phone_call = create(:phone_call, :answered, account:)

      set_twilio_api_authorization_header(account)
      do_request(
        account_sid: account.id,
        sid: phone_call.id,
        "Status" => "completed"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/call")
      expect(EndCallJob).to have_been_enqueued.with(phone_call)
    end

    example "Cancels a call", document: false do
      account = create(:account)
      phone_call = create(:phone_call, :queued, account:)

      set_twilio_api_authorization_header(account)
      do_request(
        account_sid: account.id,
        sid: phone_call.id,
        "Status" => "canceled"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/call")
      expect(json_response.fetch("status")).to eq("canceled")
    end

    example "Handles invalid requests", document: false do
      account = create(:account)
      phone_call = create(:phone_call, :answered, account:)

      set_twilio_api_authorization_header(account)
      do_request(
        account_sid: account.id,
        sid: phone_call.id,
        "Status" => "busy"
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
    end
  end
end
