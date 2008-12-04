class Reminder < ActiveRecord::Base
    named_scope :reminds, lambda {|time| {
    :conditions => ['remind_at <= ?', time.to_s(:db)]}}
end