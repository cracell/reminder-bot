require 'xmpp4r-simple'

class OldBot
  attr_accessor :messenger
  cattr_accessor :main
  def self.start
    @@main = Bot.new
    @@main.monitor
  end
  
  def initialize
    @messenger = Jabber::Simple.new(APP_CONFIG[:gmail], APP_CONFIG[:gmail_password])
  end
  
  def message(user, message)
    messenger.deliver(user, message)
  end
  
  def monitor
    while true
      remind
      recieve
      sleep 2  
    end
  end
  
  def recieve
    messenger.received_messages do |msg|  
      user = msg.from.to_s.split('/')[0]
      puts user
      puts msg.body
      if create_reminder(msg.body, user)
        messenger.deliver(user, "Standbye for Reminder Commander")
      else
        messenger.deliver(user, "I couldn't remind you. I failed sir.")
      end
    end
  end
  
  def remind
    Reminder.reminds(Time.now.utc + 30.seconds).each do |reminder|
      message(reminder.user, reminder.reminder) 
      reminder.destroy
    end
  end
  
  def create_reminder(message, user)
      if match_data = /(.*)(Time:)(.*)/i.match(message) and remind_at = Chronic.parse(match_data[3]).to_s and not remind_at.blank?
        puts remind_at
        Reminder.create(:reminder => match_data[1], :user => user, :remind_at => remind_at)
      else
        false
      end
  end
end