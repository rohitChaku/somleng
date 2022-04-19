require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::String,
    email: Field::String,
    name: Field::String,
    carrier_role: Field::String,
    carrier: Field::BelongsTo,
    sign_in_count: Field::String,
    last_sign_in_at: Field::DateTime,
    confirmation_sent_at: Field::DateTime,
    confirmed_at: Field::DateTime,
    invitation_sent_at: Field::DateTime,
    invitation_accepted_at: Field::DateTime,
    invited_by: Field::BelongsTo,
    account_memberships: Field::HasMany
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    name
    email
    carrier
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    email
    carrier
    carrier_role
    sign_in_count
    last_sign_in_at
    confirmation_sent_at
    confirmed_at
    invitation_sent_at
    invitation_accepted_at
    invited_by
    account_memberships
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(user)
    user.name
  end
end