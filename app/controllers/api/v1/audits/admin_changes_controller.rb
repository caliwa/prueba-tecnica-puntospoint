class Api::V1::Audits::AdminChangesController < ApplicationController
  rate_limit to: 10, within: 30.seconds, with: -> { render json: { error: "Demasiadas peticiones" }, status: 429 }, store: cache_store
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    admin_events = AuditEvent
                     .includes(:user)
                     .where(users: { type: "Admin" })
                     .order(created_at: :desc)

    events_by_admin = admin_events.group_by(&:user)

    response_data = events_by_admin.map do |admin, events|
      {
        admin_user: {
          id: admin.id,
          email: admin.email
        },
        changes: events.map do |event|
          {
            event_id: event.id,
            event_type: event.event_type,
            resource_type: event.auditable_type,
            resource_id: event.auditable_id,
            old_values: event.old_values,
            new_values: event.new_values,
            changed_at: event.created_at
          }
        end
      }
    end

    render json: response_data, status: :ok
  end
end
