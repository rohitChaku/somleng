class InitiateOutboundCall < ApplicationWorkflow
  class Error < StandardError; end

  attr_reader :phone_call, :call_service_client

  def initialize(phone_call, options = {})
    @phone_call = phone_call
    @call_service_client = options.fetch(:call_service_client) { CallService::Client.new }
  end

  def call
    return unless phone_call.status.in?(%w[queued initiating])
    return phone_call.cancel! if phone_call.sip_trunk.blank?
    return reschedule unless initiate!

    response = create_remote_call

    mark_as_initiated!(response.fetch(:id))
  end

  private

  def reschedule
    ScheduledJob.perform_later(
      OutboundCallJob.to_s,
      phone_call,
      wait_until: 10.seconds.from_now
    )
  end

  def initiate!
    return mark_as_initiating! if phone_call.sip_trunk.max_channels.blank?

    SIPTrunkChannelManager.allocate_sip_trunk_channel(sip_trunk) do
      mark_as_initiating! if channels_available?
    end

    phone_call.initiating?
  end

  def create_remote_call
    response = call_service_client.create_call(
      sid: decorated_phone_call.sid,
      account_sid: decorated_phone_call.account_sid,
      account_auth_token: decorated_phone_call.account.auth_token,
      direction: decorated_phone_call.direction,
      api_version: TwilioAPISerializer::API_VERSION,
      voice_url: decorated_phone_call.voice_url,
      voice_method: decorated_phone_call.voice_method,
      twiml: decorated_phone_call.twiml,
      to: decorated_phone_call.to,
      from: decorated_phone_call.caller_id,
      routing_parameters: RoutingParameters.new(
        sip_trunk: phone_call.sip_trunk,
        destination: phone_call.to
      ).to_h
    )

    raise Error, "Response body: #{response.body}" unless response.success?

    response
  end

  def channels_available?
    sip_trunk.max_channels > sip_trunk.phone_calls.in_progress_or_initiating.count
  end

  def sip_trunk
    phone_call.sip_trunk
  end

  def mark_as_initiating!
    phone_call.initiating_at = Time.current
    phone_call.mark_as_initiating!
  end

  def mark_as_initiated!(external_id)
    phone_call.external_id = external_id
    phone_call.initiated_at = Time.current
    phone_call.mark_as_initiated!
  end

  def decorated_phone_call
    @decorated_phone_call ||= PhoneCallDecorator.new(phone_call)
  end
end
