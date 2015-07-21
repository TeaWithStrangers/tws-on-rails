class EmailReminder < ActiveRecord::Base
  belongs_to :remindable, polymorphic: true
end
