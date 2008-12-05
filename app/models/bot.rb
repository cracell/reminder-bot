class Bot
  require 'xmpp4r/client'
  require 'chronic'
  include Jabber
  
  
  attr_accessor :messenger
  cattr_accessor :main
  def self.start
    @@main = Bot.new(APP_CONFIG[:gmail], APP_CONFIG[:gmail_password])
    @@main.monitor
  end
  
  def initialize(jid, password, status = nil, status_message = "Available")
    @messenger = Client::new(JID::new(jid))
    @messenger.connect
    @messenger.auth(password)
    @messenger.send(Presence.new.set_type(:available))
    set_callbacks
  end
  
  def message(user, message)
    to = user
    subject = "Reminder Bot Message"
    body = message
    m = Message::new(to, body).set_type(:normal).set_id('1').set_subject(subject)
    @messenger.send m
  end
  
  def monitor
    int = 0
    while true
      int += 1
      remind
      sleep 60
      if int > 120
        message('cracell@gmail', 'Just checking in bossman')
        int = 0
      end
    end
  end

  def remind
    Reminder.reminds(Time.now.utc + 60.seconds).each do |reminder|
      message(reminder.user, reminder.reminder) 
      reminder.destroy
    end
  end

private
  def set_callbacks
    @messenger.add_message_callback do |m|
      recieve(m)
    end
  end
  
  def recieve(message)
      user = message.from.to_s.split('/')[0]
      puts user
      puts message.body
      if create_reminder(message.body, user)
        message(user, "Standbye for Reminder Commander")
      else
        message(user, "I couldn't remind you. I failed sir.")
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