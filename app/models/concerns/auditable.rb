require 'active_support/concern'

module Auditable
  extend ActiveSupport::Concern

  def after_create(record)
    log_event(record, "created", nil, record.attributes)
  end

  def after_update(record)
    old_values = record.previous_changes.transform_values(&:first)
    new_values = record.previous_changes.transform_values(&:second)
    log_event(record, "updated", old_values, new_values)
  end

  def before_destroy(record)
    log_event(record, "deleted", record.attributes, nil)
  end

  private

  def log_event(record, event_type, old_data, new_data)
    return if old_data.blank? && new_data.blank?

    AuditEvent.create!(
      auditable: record,
      event_type: event_type,
      old_values: old_data,
      new_values: new_data,
      user: Current.user,
      metadata: {
        url: Current.request&.fullpath,
        ip_address: Current.request&.remote_ip
      }
    )
  end
end
