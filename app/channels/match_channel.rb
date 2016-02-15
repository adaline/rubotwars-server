class MatchChannel < ApplicationCable::Channel
  def subscribed
    current_user.appear
    stream_for current_user
  end

  def unsubscribed
    current_user.disappear
  end

  def perform_move(data)
    current_user.move_ready data
  end
end
