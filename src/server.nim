import asyncdispatch, asyncnet, parseopt, strutils

var 
  port = 7687

for kind, key, val in getOpt(): # get commandline args
  case kind:
  of cmdLongOption, cmdShortOption: # the only ones we care about have values
    case key
    of "port": port = parseInt val.string # val is actually a TaintedString
    else: echo("Got unknown flag --", key, " with value: ", val)
  else: discard

type
  Client = ref object
    socket: AsyncSocket # socket we will use to send messages to client
    ipAddress: string # client ip
    id: int
    connected: bool

  Server = ref object
    socket: AsyncSocket
    clients: seq[Client]

# define how to convert a Client object to a string
proc `$`(client: Client): string = $client.id & " : " & client.ipAddress

# used to asyncronously listen to messages from clients, and close their connections when they disconnect
proc processMessages(server: Server, client: Client) {.async.} =
  while true:
    let line = await client.socket.recvLine() # wait until the client sends a message
    if line.len == 0: # only happens when client disconnects
      echo client, " disconnected"
      client.connected = false
      client.socket.close() # close connection because we don't need it any more
      return

    echo client, " sent: ", line # log the client's message to the console
    for c in server.clients: # send the messages to all the other clients
      if c.id != client.id and c.connected: # only clients who aren't this client, and are connected
        await c.socket.send line & "\c\l" # also add a line feed to the end

# listen for connections from clients
proc listen(server: Server, port = port) {.async.} =
  server.socket.bindAddr port.Port
  server.socket.listen()

  while true:
    let (ipAddress, clientSocket) = await server.socket.acceptAddr() # wait to accept a connected client
    echo "Accepted connection from ", ipAddress
    let client = Client(
      socket: clientSocket,
      ipAddress: ipAddress,
      id: server.clients.len,
      connected: true
    )
    server.clients.add client
    asyncCheck server.processMessages(client)

proc newServer(): Server = Server(socket: newAsyncSocket(), clients: @[]) # "constructor" for new servers

var server = newServer()

waitFor server.listen()
