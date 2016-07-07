# this is the client module of the client-server chat app
# build the executable and run it with optional arguments for port, server, and user
# eg ./bin/client --port=7687 server="localhost" user="test"

import os, threadpool, asyncdispatch, asyncnet, protocol, parseopt, strutils

var 
  serverAddress = "localhost" # default server
  username = "anonymous"
  port = 7687 # default port

for kind, key, val in getOpt(): # get commandline args
  case kind:
  of cmdLongOption, cmdShortOption: # the only ones we care about have values
    case key
    of "port": port = parseInt val.string # val is actually a TaintedString
    of "server": serverAddress = val.string
    of "user": username = val.string
    else: echo("Got unknown flag --", key, " with value: ", val)
  else: discard

echo "Chat application started"

let socket = newAsyncSocket() # new socket we'll use to communicate with the server

proc connect(socket: AsyncSocket, serverAddress: string) {.async.} = # async function to connect to server
  echo "Connecting to ", serverAddress
  await socket.connect(serverAddress, port.Port) # wait till we get a connection to the server
  echo "Connected!"

  while true:
    let line = await socket.recvLine() # everytime we get a message
    let message = parseMessage line # create a message object
    echo message.username, " said: '", message.message, "'" # echo the message to the current client

asyncCheck socket.connect(serverAddress) # run the connect function asyncronously, don't care what's returned

var messageFlowVar = spawn stdin.readLine() # read a line from the user, returns an async FlowVar
while true:
  if messageFlowVar.isReady(): # will return true when the user enters a message
    let message = createMessage(username, ^messageFlowVar) # creates a message object to be sent to other clients
    asyncCheck socket.send(message) # send the message asyncronously, don't care what's returned
    messageFlowVar = spawn stdin.readLine() # get a new message from the current user

  asyncdispatch.poll() # poll the dispatcher for events so that we'll always know when the user has typed a message
