NIMFLAGS="c"

# build both
all: client server

# build the client executable
client:
	nim $(NIMFLAGS) src/client.nim

# build the server executable
server:
	nim $(NIMFLAGS) src/server.nim

# clean the output dirs
clean:
	rm bin/* src/nimcache/*