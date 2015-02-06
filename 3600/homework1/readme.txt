Project: valueGuesser & valueServer
Author: Jackson Dawkins
Due: 1.30.2015

jacksod@g.clemson.edu

--------------------------------- Analysis -------------------------------------

This project is divided into two parts: client and server.

The client (vgClient.c) has the role of guessing the random number chosen by
the server (vgServer.c). The random number chosen is on the range of [0,10^9].
The most effective way for the client to guess the server's number is to use a
binary search algorithm, by choosing 5 * 10^8 as the starting point, since that
is the middle of the range of random numbers. The client uses a datagram/UDP
socket to communicate with the server and to send a guess for the random number.
The response to the client from the server is what the client uses to direct the
binary search.

The server has a couple roles: to choose a random number, and to handle clients
which try to guess the value of the random number. If the user chooses, he can
provide a starting value for the server. Otherwise, the choosing relies on the
c library's rand() and srand() methods, while using time to seed the methods.
Once a number is guessed, the server waits for a message from a client containing
the client's guess. Once received, the server evaluates the value and responds
with one of a few responses: "1" if the value is too high, "2" if the value is
too low, or "0" if the value is correct. The server responds to the client with
a message containing the response. If the client guessed the number correctly,
the server automatically chooses another random number.


---------------------------------- Usage ---------------------------------------

A makefile is provided to build all assets for the client and server sides.
To compile, run "make"

The makefile also provides for cleaning execuatables and object files after
finished by running "make clean"

Once compiled, the client and server can be run in the following ways:

The SERVER should be started first for maximum efficiency. The user provides both
the port and (optionally) the initial number for the server to use as a value to
be guessed. Assuming the user is providing the initial value, the CLI input is:
                    valueServer <port> <initialValue>
If the user chooses not to provide an initial server value, the input is like:
                    valueServer <port>

To use the CLIENT, the user must know the IP address and receiving port of the
server. To start the client, the user provides the following input to the CLI:
                    valueGuesser <Server_IP> <Server_Port>
