NIMFLAGS="c"

# build the client executable
client:
	nim $(NIMFLAGS) src/client.nim

# build the server executable
server:
	nim $(NIMFLAGS) src/server.nim

# build both
all: client server

# clean the output dirs
clean:
	rm bin/* src/nimcache/*