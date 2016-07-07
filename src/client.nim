import os, threadpool, asyncdispatch, asyncnet, protocol

proc connect(socket: AsyncSocket, serverAddr: string) {.async.} =
  echo "Connecting to ", serverAddr
  await socket.connect(serverAddr, 7687.Port)
  echo "Connected!"

  while true:
    let line = await socket.recvLine()
    let message = parseMessage line
    echo message.username, " said: '", message.message, "'"

echo "Chat application started"
if paramCount() == 0: quit "Please specify the server address, e.g. ./client localhost"

let serverAddr = paramStr(1)
var username: string
when paramCount() > 1:
  username = paramStr(2)
echo "Connecting to ", serverAddr

let socket = newAsyncSocket()
asyncCheck connect(socket, serverAddr)

var messageFlowVar = spawn stdin.readLine()
while true:
  if messageFlowVar.isReady():
    let message = createMessage(username, ^messageFlowVar)
    asyncCheck socket.send(message)
    messageFlowVar = spawn stdin.readLine()

  asyncdispatch.poll()
