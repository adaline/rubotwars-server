App.masterChannel = App.cable.subscriptions.create "MasterChannel",
  # Called when the subscription is ready for use on the server
  connected: ->
    # Calls `AppearanceChannel#appear(data)` on the server
    @perform("test", direction: 1234)

  # Called when the WebSocket connection is closed
  disconnected: ->

  # Called when the subscription is rejected by the server
  rejected: ->

  received: (data) ->
    canvas = document.getElementById("game_canvas")
    switch data.status
      when 'start'
        event = new CustomEvent "start", { detail: { bots: data.bots, map: data.map }, bubbles: true, cancelable: true }
        canvas.dispatchEvent(event)
      when 'update'
        event = new CustomEvent "update", { detail: { bots: data.bots, map: data.map }, bubbles: true, cancelable: true }
        canvas.dispatchEvent(event)
      when 'game_over'
        event = new CustomEvent "game_over", { detail: { winner: data.winner}, bubbles: true, cancelable: true }
        canvas.dispatchEvent(event)
      when 'scan'
        event = new CustomEvent "scan", { detail: { bot: data.bot }, bubbles: true, cancelable: true }
        canvas.dispatchEvent(event)
      when 'fire'
        event = new CustomEvent "fire", { detail: { bot: data.bot }, bubbles: true, cancelable: true }
        canvas.dispatchEvent(event)
      when 'turn'
        event = new CustomEvent "turn", { detail: { bot: data.bot, direction: data.direction }, bubbles: true, cancelable: true }
        canvas.dispatchEvent(event)
