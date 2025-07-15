class ProductObserver < ActiveRecord::Observer
  def after_create(product)
    log_event(product, "created", nil, product.attributes)
  end

  def after_update(product)
    old_values = product.previous_changes.transform_values(&:first)
    new_values = product.previous_changes.transform_values(&:second)

    log_event(product, "updated", old_values, new_values)
  end

  def before_destroy(product)
    log_event(product, "deleted", product.attributes, nil)
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
