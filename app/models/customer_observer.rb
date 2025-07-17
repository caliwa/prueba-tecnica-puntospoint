class CustomerObserver < ActiveRecord::Observer
  include Auditable
end
