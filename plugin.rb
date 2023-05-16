# frozen_string_literal: true
# name: discord bot
# about: Integrate Discord Bots with Discourse
# version: 0.3
# authors: Robert Barrow
# url: https://github.com/merefield/discourse-discord-bot

require 'discordrb'
require 'discordrb/webhooks'

enabled_site_setting :discord_bot_enabled

after_initialize do

  %w[
    ../lib/engine.rb
    ../lib/bot.rb
    ../lib/bot_commands.rb
    ../lib/discourse_events_handlers.rb
    ../lib/discord_events_handlers.rb
  ].each do |path|
    load File.expand_path(path, __FILE__)
  end

  bot_thread = Thread.new do
    begin
      ::DiscordBot::Bot.run_bot
    rescue Exception => ex
      Rails.logger.error("Discord Bot: There was a problem: #{ex}")
    end
  end

  STDERR.puts '---------------------------------------------------'
  STDERR.puts 'Bot should now be spawned, say "Ping!" on Discord!'
  STDERR.puts '---------------------------------------------------'
  STDERR.puts '(-------      If not check logs          ---------)'
end
