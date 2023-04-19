# frozen_string_literal: true
module ::DiscordBot::DiscordEventsHandlers
  # Copy message to Discourse
  module TransmitAnnouncement
    extend Discordrb::EventContainer
    message do |event|

      return if !SiteSetting.discord_bot_auto_channel_sync && SiteSetting.discord_bot_discourse_announcement_topic_id.blank? && (event.message.channel.id != SiteSetting.discord_bot_announcement_channel_id)
      return if event.message.from_bot?

      system_user = User.find_by(id: -1)
      raw = ""
      
      associated_user = UserCustomField.find_by(value: event.message.author.username + "#" + event.message.author.discriminator)
      STDERR.puts associated_user.value
      unless associated_user.nil? || associated_user.blank?
        message_user = User.find_by(id: associated_user.user_id)
        raw = event.message.content
        STDERR.puts 'Found User'
      else
        message_user = system_user
        raw = event.message.author.username + ": " + event.message.content
        STDERR.puts 'No User'
      end

      STDERR.puts 'Raw: ' + raw
      discordmessage = event.message.content
      
      if !discordmessage.blank?
        if SiteSetting.discord_bot_auto_channel_sync
          matching_channel = Chat::Channel.find_by(slug: event.message.channel.name.to_s)
          STDERR.puts 'First case channel: ' + matching_channel
          unless matching_channel.nil?
            Chat::MessageCreator.create(chat_channel: matching_channel, user: message_user, content: raw).chat_message
            $DiscordPost = 1
            return
          end
        end
        if !SiteSetting.discord_bot_chat_listening_categories.blank?
          chat_listening_categories = SiteSetting.discord_bot_chat_listening_categories.split('|')
          matching_channel = Chat::Channel.find_by(slug: event.message.channel.name.to_s)
          STDERR.puts 'Second case channel: ' + matching_channel
          if chat_listening_categories.include?(matching_channel.to_s) then
            Chat::MessageCreator.create(chat_channel: matching_channel, user: message_user, content: raw).chat_message
            $DiscordPost = 1
          end
        end
      end
        STDERR.puts $DiscordPost
    end
  end
end
