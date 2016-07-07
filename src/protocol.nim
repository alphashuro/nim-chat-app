import json

type
  Message* = object
    username*: string
    message*: string

proc parseMessage*(data: string): Message = 
  let dataJson = parseJson data
  result.username = dataJson["username"].getStr()
  result.message = dataJson["message"].getStr()

proc createMessage*(username = "Anon", message: string): string = 
  $ %{
    "username": %username,
    "message": %message
  } & "\c\l"

proc createMessage*(message: Message): string = 
  createMessage message.username, message.message

when isMainModule:
  block:
    let data = """{"username": "John", "message": "Hi!"}"""
    let parsed = parseMessage data
    doAssert parsed.username == "John"
    doAssert parsed.message == "Hi!"
  block:
    let data = """foobar"""
    try:
      discard parseMessage data
      doAssert false
    except JsonParsingError:
      doAssert true
    except:
      doAssert false
  block:
    let actual = createMessage("dom", "hello")
    let expected = """{"username":"dom","message":"hello"}""" & "\c\l"
    doAssert actual == expected
  echo("All tests passed!")