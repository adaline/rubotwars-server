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
        console.log 'Starting'
        event = new CustomEvent "start", { detail: { bots: data.bots, map: data.map }, bubbles: true, cancelable: true }
        canvas.dispatchEvent(event)
      when 'update'
        console.log 'Updating'
        event = new CustomEvent "update", { detail: { bots: data.bots, map: data.map }, bubbles: true, cancelable: true }
        canvas.dispatchEvent(event)
      when 'game_over'
        console.log 'Game Over'
        event = new CustomEvent "game_over"
        canvas.dispatchEvent(event)
