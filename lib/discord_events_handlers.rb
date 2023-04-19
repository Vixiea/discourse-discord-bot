# frozen_string_literal: true
module ::DiscordBot::DiscordEventsHandlers
  # Copy message to Discourse
  module TransmitAnnouncement
    extend Discordrb::EventContainer
    message do |event|

      return if !SiteSetting.discord_bot_auto_channel_sync && SiteSetting.discord_bot_discourse_announcement_topic_id.blank? && (event.message.channel.id != SiteSetting.discord_bot_announcement_channel_id)
      return if event.message.author.bot

      system_user = User.find_by(id: -1)

      associated_user = UserCustomField.find_by(value: event.message.auther.name)

      unless associated_user.nil?
        message_user = User.find_by(id: associated_user.user_id)
      else
        message_user = system_user
        raw = event.message.nick.to_s + ": "
      end

      discordmessage = event.message.to_s
      raw += discordmessage
      if !discordmessage.blank?
        if SiteSetting.discord_bot_auto_channel_sync
          matching_channel = Chat::Channel.find_by(name: event.message.channel.name)
          unless matching_channel.nil?
            Chat::MessageCreator.create(chat_channel: matching_channel, user: message_user, content: raw).chat_message
            @@DiscordPost = 1
            return
          end
        end
        if !SiteSetting.discord_bot_chat_listening_categories.blank?
          chat_listening_categories = SiteSetting.discord_bot_chat_listening_categories.split('|')
          matching_channel = Chat::Channel.find_by(name: event.message.channel.name)
          if chat_listening_categories.include?(matching_channel.to_s) then
            Chat::MessageCreator.create(chat_channel: matching_channel, user: message_user, content: raw).chat_message
            @@DiscordPost = 1
          end
        end
      end
    end
  end
end
