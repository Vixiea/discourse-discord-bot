# frozen_string_literal: true
module ::DiscordBot::DiscourseEventsHandlers
  def self.hook_events
    DiscourseEvent.on(:chat_message_created) do |chat_message|
      #if Chat::Channel.find_by(id: message.chat_channel_id).chatable_type != 'DirectMessage' && !::DiscordBot::Bot.discord_bot.nil? then
      if chat_message.chat_channel.chatable_type != 'DirectMessage' && !::DiscordBot::Bot.discord_bot.nil? then
          chat_listening_categories = SiteSetting.discord_bot_chat_listening_categories.split('|')
          #matching_channel = Chat::Channel.find_by(id: message.chat_channel_id)
          matching_channel = chat_message.chat_channel
          STDERR.puts matching_channel
          if SiteSetting.discord_bot_auto_channel_sync && $DiscordPost == 0 then
            channel_id = matching_channel.description.to_s
            #channel_id = matching_channel.slug
            #text = User.find_by(id: message.user_id).name + ": " + message.message.to_s
            text = User.find_by(id: chat_message.user_id).name + ": " + chat_message.message.to_s
            ::DiscordBot::Bot.discord_bot.send_message(channel_id, text)
        else
          if chat_listening_categories.include?(matching_channel.to_s) && $DiscordPost == 0 then
            channel_id = matching_channel.description.to_s
            #channel_id = matching_channel.slug
            #text = User.find_by(id: message.user_id).name + ": " + message.message.to_s 
            text = User.find_by(id: chat_message.user_id).name + ": " + chat_message.message.to_s
            ::DiscordBot::Bot.discord_bot.send_message(channel_id, message)
          end
          $DiscordPost = 0
        end
      end
    end
  end
end
