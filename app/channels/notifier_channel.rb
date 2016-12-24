# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class NotifierChannel < ApplicationCable::Channel
	def subscribed
    # stream_from "notifier_channel_#{params[:data][:channel]}"
	end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
