namespace :bot do
  desc 'Start up the reminder bot'
  task :start => :environment do
    Bot.start
  end
end