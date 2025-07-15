class CustomerObserver < ActiveRecord::Observer
  def after_create(customer)
    log_event(customer, "created", nil, customer.attributes)
  end

  def after_update(customer)
    old_values = customer.previous_changes.transform_values(&:first)
    new_values = customer.previous_changes.transform_values(&:second)
    log_event(customer, "updated", old_values, new_values)
  end

  def before_destroy(customer)
    log_event(customer, "deleted", customer.attributes, nil)
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
