App.appearanceChannel = App.cable.subscriptions.create "MasterChannel",
  # Called when the subscription is ready for use on the server
  connected: ->
    # Calls `AppearanceChannel#appear(data)` on the server
    @perform("test", direction: 1234)

  # Called when the WebSocket connection is closed
  disconnected: ->

  # Called when the subscription is rejected by the server
  rejected: ->
