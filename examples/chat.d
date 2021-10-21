/// Simplified D translation of example_chat.cpp from the original repo.
///
/// Copyright: Valve Corporation, all rights reserved
module chat;

import steam_gns;

import std.uni;
import std.stdio;
import std.range;
import std.format;
import std.string;
import std.algorithm;
import std.exception;
import std.concurrency;

import core.time;
import core.atomic;
import core.thread;

enum ushort defaultServerPort = 27020;

shared {

    bool quit = false;
    auto outbox = new shared MessageQueue;

}

/// A simple input message queue to work across threads. Handles local user input.
synchronized class MessageQueue {

    private string[] messages;

    bool empty() const {

        return messages.length == 0;

    }

    string front() const {

        return messages[0];

    }

    void popFront() {

        messages = messages[1..$];

    }

    void put(string message) {

        messages ~= message;

    }

}

// Non-blocking console user input. Sort of.
// Why is this so hard?
//
// Done from a separate thread.
void userInputEntrypoint() {

    // Repeat
    while (!quit.atomicLoad) {

        write("msg: ");

        // Read a line and send to the parent thread
        auto line = readln().strip;

        // Quit
        if (line is null) {

            quit.atomicStore = true;

        }

        // Or send the message to the owner thread
        else outbox.put(line);

    }
}

/// Our chat server
class ChatServer {

    struct Client {

        string nick;

    }

    private static ChatServer instance;

    ISteamNetworkingSockets inter;
    HSteamListenSocket socket;
    HSteamNetPollGroup pollGroup;

    Client[HSteamNetConnection] clients;

    static void SteamNetConnectionStatusChangedCallback(SteamNetConnectionStatusChangedCallback_t* info) {

        instance.OnSteamNetConnectionStatusChanged(info);

    }

    void Run(ushort port) {

        // Select instance to use. For now we'll always use the default.
        inter = SteamNetworkingSockets();

        // Set IP for the connection
        SteamNetworkingIPAddr serverLocalAddr;
        serverLocalAddr.Clear();
        serverLocalAddr.m_port = port;

        // Set callback for connection status change
        SteamNetworkingConfigValue_t opt;
        opt.SetPtr(
            ESteamNetworkingConfigValue.Callback_ConnectionStatusChanged,
            &SteamNetConnectionStatusChangedCallback
        );

        // Start listening
        socket = inter.CreateListenSocketIP(serverLocalAddr, 1, &opt);
        enforce(socket != k_HSteamListenSocket_Invalid, port.format!"Failed to listen on port %s");

        // Clean the socket up
        scope (exit) {
            inter.CloseListenSocket(socket);
            socket = k_HSteamListenSocket_Invalid;
        }

        // Create a poll group
        pollGroup = inter.CreatePollGroup();
        enforce(pollGroup != k_HSteamNetPollGroup_Invalid, port.format!"Failed to listen on port %s");

        // Clean the poll group up
        scope (exit) {
            inter.DestroyPollGroup(pollGroup);
            pollGroup = k_HSteamNetPollGroup_Invalid;
        }

        // Output listening status
        writefln!"Server listening on port %s"(port);

        // Close connections
        scope (exit) {

            foreach (connection; clients.byKey) {

                // Send them one more goodbye message.  Note that we also have the
                // connection close reason as a place to send final data.  However,
                // that's usually best left for more diagnostic/debug text not actual
                // protocol strings.
                SendStringToClient(connection, "Server is shutting down. Goodbye.");

                // Close the connection.  We use "linger mode" to ask SteamNetworkingSockets
                // to flush this out and close gracefully.
                inter.CloseConnection(connection, 0, "Server shutdown", true);

            }

            clients.clear();

        }

        // Listen to connections
        while (!quit.atomicLoad) {

            PollIncomingMessages();
            PollConnectionStateChanges();
            PollLocalUserInput();

            Thread.sleep(10.msecs);

        }

        // Close all the connections
        writefln!"Closing connections... Press <Enter> to continue.";

    }

    void SendStringToClient(HSteamNetConnection conn, string str) {

        inter.SendMessageToConnection(conn, str.ptr, cast(uint) str.length, k_nSteamNetworkingSend_Reliable,
            null);

    }

    void SendStringToAllClients(string str, HSteamNetConnection except = k_HSteamNetConnection_Invalid) {

        foreach (connection; clients.byKey) {

            if (connection == except) continue;
            SendStringToClient(connection, str);

        }

    }

    void PollIncomingMessages() {

        while (!quit.atomicLoad) {

            SteamNetworkingMessage_t* incomingMsg;

            int numMsgs = inter.ReceiveMessagesOnPollGroup(pollGroup, &incomingMsg, 1);

            // Stop when out of messages
            if (numMsgs == 0) break;

            enforce(numMsgs > 0, "Error checking for messages");
            enforce(incomingMsg);

            // Clean the message up
            scope (exit) incomingMsg.Release();

            auto connection = incomingMsg.m_conn;
            auto client = clients[connection];

            // '\0'-terminate it to make it easier to parse
            auto cmd = cast(string) incomingMsg.m_pData[0 .. incomingMsg.m_cbSize];

            // Check for known commands.  None of this example code is secure or robust.
            // Don't write a real server like this, please.
            if (cmd.startsWith("/nick")) {

                string nick = cmd[5..$];

                // Skip space
                while (nick.front.isWhite) nick.popFront;

                // Let everybody else know they changed their name
                SendStringToAllClients(
                    format!"%s shall henceforth be known as %s"(client.nick, nick),
                    connection
                );

                // Respond to client
                SendStringToClient(
                    connection,
                    format!"Ye shall henceforth be known as %s"(nick)
                );

                // Actually change their name
                SetClientNick(connection, nick.dup);

                continue;

            }

            // Assume it's just a ordinary chat message, dispatch to everybody else
            SendStringToAllClients(format!"%s: %s"(client.nick, cmd), connection);

        }

    }

    void PollLocalUserInput() {

        while (!quit.atomicLoad && !outbox.empty) {

            auto cmd = outbox.front;
            outbox.popFront;

            if (cmd.startsWith("/quit")) {

                quit.atomicStore = true;
                writefln!"Shutting down the server";
                break;

            }

            // That's the only command we support
            writefln!"The server only knows one command: '/quit'";

        }

    }

    void SetClientNick(HSteamNetConnection hConn, string nick) {

        // Remember their nick
        clients[hConn].nick = nick;

        // Set the connection name, too, which is useful for debugging
        inter.SetConnectionName(hConn, nick.toStringz);

    }

    void OnSteamNetConnectionStatusChanged(SteamNetConnectionStatusChangedCallback_t* info) {

        // What's the state of the connection?
        switch (info.m_info.m_eState) {

            case ESteamNetworkingConnectionState.None:

                // NOTE: We will get callbacks here when we destroy connections. You can ignore these.
                break;

            case ESteamNetworkingConnectionState.ClosedByPeer:
            case ESteamNetworkingConnectionState.ProblemDetectedLocally:

                scope (exit) {

                    // Clean up the connection.  This is important!
                    // The connection is "closed" in the network sense, but it has not been destroyed.  We must close it
                    // on our end, too to finish up. The reason information does not matter in this case, and we cannot
                    // linger because it's already closed on the other end, so we just pass 0's.
                    inter.CloseConnection(info.m_hConn, 0, null, false);

                }

                // Ignore if they were not previously connected.  (If they disconnected before we accepted the
                // connection)
                if (info.m_eOldState == ESteamNetworkingConnectionState.Connected) {

                    // Locate the client. Note that it should have been found, because this is the only codepath where
                    // we remove clients (except on shutdown), and connection change callbacks are dispatched in queue
                    // order.
                    auto connection = info.m_hConn;
                    auto client = clients[connection];

                    // Select appropriate log messages
                    string logMessage;

                    if (info.m_info.m_eState == ESteamNetworkingConnectionState.ProblemDetectedLocally) {

                        logMessage = "problem detected locally";

                        // Send a message so everybody else knows what happened
                        SendStringToAllClients(
                            format!"Alas, %s hath fallen into shadow. (%s)"(client.nick, info.m_info.m_szEndDebug)
                        );

                    }

                    else {

                        // Note that here we could check the reason code to see if
                        // it was a "usual" connection or an "unusual" one.
                        logMessage = "closed by peer";

                        SendStringToAllClients(
                            format!"%s hath departed"(client.nick)
                        );

                    }

                    // Spew something to our own log. Note that because we put their nick as the connection description,
                    // it will show up, along with their transport-specific data (e.g. their IP address)
                    writefln!"Connection %s %s, reason %s: %s\n"(
                        info.m_info.m_szConnectionDescription,
                        logMessage,
                        info.m_info.m_eEndReason,
                        info.m_info.m_szEndDebug
                    );

                    clients.remove(connection);

                }

                else assert(info.m_eOldState == ESteamNetworkingConnectionState.Connecting);

                break;

            case ESteamNetworkingConnectionState.Connecting:

                // This must be a new connection
                assert(info.m_hConn !in clients);

                writefln!"Connection request from %s"(info.m_info.m_szConnectionDescription);

                // A client is attempting to connect
                // Try to accept the connection.
                if (inter.AcceptConnection(info.m_hConn) != EResult.OK) {

                    // This could fail. If the remote host tried to connect, but then disconnected, the connection may
                    // already be half closed. Just destroy whatever we have on our side.
                    inter.CloseConnection(info.m_hConn, 0, null, false);

                    writefln!"Can't accept connection. (It was already closed?)";
                    break;

                }

                // Assign the poll group
                if (!inter.SetConnectionPollGroup(info.m_hConn, pollGroup)) {

                    inter.CloseConnection(info.m_hConn, 0, null, false);

                    writefln!"Failed to set poll group?";
                    break;
                }

                import std.random;

                // Generate a random nick. A random temporary nick is really dumb and not how you would write a real
                // chat server.  You would want them to have some sort of signon message, and you would keep their
                // client in a state of limbo (connected, but not logged on) until them.  I'm trying to keep this
                // example code really simple.
                auto nick = format!"BraveWarrior%s"(10_000 + uniform(0, 100_000));

                // Send them a welcome message
                SendStringToClient(info.m_hConn,
                    format!("Welcome, stranger.  Thou art known to us for now as '%s'; upon thine command '/nick' we "
                        ~ "shall know thee otherwise.")(nick)
                );

                // Also send them a list of everybody who is already connected
                if (clients.empty) {
                    SendStringToClient(info.m_hConn, "Thou art utterly alone.");
                }

                else {

                    SendStringToClient(info.m_hConn, format!"%s companions greet you:"(clients.length));

                    foreach (client; clients) {

                        SendStringToClient(info.m_hConn, client.nick);

                    }

                }

                // Let everybody else know who they are for now
                SendStringToAllClients(
                    format!"Hark!  A stranger hath joined this merry host.  For now we shall call them '%s'"(nick),
                    info.m_hConn
                );

                // Add them to the client list, using std::map wacky syntax
                clients[info.m_hConn] = Client(nick);
                break;

            case ESteamNetworkingConnectionState.Connected:

                // We will get a callback immediately after accepting the connection.
                // Since we are the server, we can ignore this, it's not news to us.
                break;

            default: break;

        }

    }

    void PollConnectionStateChanges() {

        instance = this;
        inter.RunCallbacks();

    }

}

/// Our chat client
class ChatClient {

    static ChatClient instance;

    HSteamNetConnection connection;
    ISteamNetworkingSockets inter;

    static void SteamNetConnectionStatusChangedCallback(SteamNetConnectionStatusChangedCallback_t* info) {

        instance.OnSteamNetConnectionStatusChanged(info);

    }

    void Run(const ref SteamNetworkingIPAddr serverAddr) {

        // Select instance to use.  For now we'll always use the default.
        inter = SteamNetworkingSockets();

        // Start connecting
        char[SteamNetworkingIPAddr.k_cchMaxString] szAddr;
        serverAddr.ToString(szAddr.ptr, szAddr.length, true);

        writefln!"Connecting to chat server at %s"(szAddr);
        SteamNetworkingConfigValue_t opt;

        opt.SetPtr(
            ESteamNetworkingConfigValue.Callback_ConnectionStatusChanged,
            &SteamNetConnectionStatusChangedCallback
        );

        connection = inter.ConnectByIPAddress(serverAddr, 1, &opt);

        enforce(connection != k_HSteamNetConnection_Invalid, "Failed to create connection");

        while (!quit.atomicLoad) {

            PollIncomingMessages();
            PollConnectionStateChanges();
            PollLocalUserInput();

            Thread.sleep(10.msecs);

        }
    }

    void PollIncomingMessages() {

        while (!quit.atomicLoad) {

            SteamNetworkingMessage_t* incomingMsg;

            int numMsgs = inter.ReceiveMessagesOnConnection(connection, &incomingMsg, 1);

            if (numMsgs == 0) break;

            assert(numMsgs > 0, "Error checking for messages");

            // Clean up
            scope (exit) incomingMsg.Release();

            // Just echo anything we get from the server
            writeln(cast(string) incomingMsg.m_pData[0..incomingMsg.m_cbSize]);

        }
    }

    void PollLocalUserInput() {

        while (!quit.atomicLoad && !outbox.empty) {

            auto cmd = outbox.front;
            outbox.popFront;

            // Check for known commands
            if (cmd.startsWith("/quit")) {

                quit.atomicStore = true;
                writefln!"Disconnecting from chat server. Press <Enter> to continue.";

                // Close the connection gracefully.
                // We use linger mode to ask for any remaining reliable data to be flushed out. But remember this is an
                // application protocol on UDP. See ShutdownSteamDatagramConnectionSockets
                inter.CloseConnection(connection, 0, "Goodbye", true);

                break;

            }

            // Anything else, just send it to the server and let them parse it
            inter.SendMessageToConnection(connection, cmd.ptr, cast(uint) cmd.length, k_nSteamNetworkingSend_Reliable,
                null);

        }

    }

    void OnSteamNetConnectionStatusChanged(SteamNetConnectionStatusChangedCallback_t* info) {

        assert(info.m_hConn == connection || connection == k_HSteamNetConnection_Invalid);

        // What's the state of the connection?
        switch (info.m_info.m_eState) {

            case ESteamNetworkingConnectionState.None:
                // NOTE: We will get callbacks here when we destroy connections.  You can ignore these.
                break;

            case ESteamNetworkingConnectionState.ClosedByPeer:
            case ESteamNetworkingConnectionState.ProblemDetectedLocally:

                quit.atomicStore = true;

                scope (exit) {

                    // Clean up the connection.  This is important!
                    // The connection is "closed" in the network sense, but it has not been destroyed. We must close it on
                    // our end, too to finish up. The reason information do not matter in this case, and we cannot linger
                    // because it's already closed on the other end, so we just pass 0's.
                    inter.CloseConnection(info.m_hConn, 0, null, false);
                    connection = k_HSteamNetConnection_Invalid;

                }

                // Print an appropriate message
                if (info.m_eOldState == ESteamNetworkingConnectionState.Connecting) {

                    // Note: we could distinguish between a timeout, a rejected connection,
                    // or some other transport problem.
                    writefln!"We sought the remote host, yet our efforts were met with defeat. (%s)"(
                        info.m_info.m_szEndDebug);

                }

                else if (info.m_info.m_eState == ESteamNetworkingConnectionState.ProblemDetectedLocally) {

                    writefln!"Alas, troubles beset us; we have lost contact with the host. (%s)"(
                        info.m_info.m_szEndDebug);

                }

                // NOTE: We could check the reason code for a normal disconnection
                else writefln!"The host hath bidden us farewell. (%s)"(info.m_info.m_szEndDebug);

                break;

            case ESteamNetworkingConnectionState.Connecting:
                // We will get this callback when we start connecting.
                // We can ignore this.
                break;

            case ESteamNetworkingConnectionState.Connected:
                writefln!"Connected to server OK";
                break;

            default: break;

        }

    }

    void PollConnectionStateChanges() {

        instance = this;
        inter.RunCallbacks();

    }

}

void main(string[] args) {

    import std.getopt;

    auto server = false;
    auto port = defaultServerPort;

    SteamNetworkingIPAddr addrServer;
    addrServer.Clear();

    auto help = args.getopt(
        "port|p", "Port to use, if running as a server", &port,
        "server|s", "Run as a server", &server,
    );

    // User requested help
    if (help.helpWanted) {

        help:

        defaultGetoptPrinter("An example chat program", help.options);
        return;

    }

    // Unknown argument
    if (args.length > 1) {

        // Must be the server address to connect to!
        if (!server && addrServer.IsIPv6AllZeros) {

            enforce(addrServer.ParseString(args[1].toStringz));

            // No port set
            if (addrServer.m_port == 0) {

                addrServer.m_port = defaultServerPort;

            }

        }

        // Nope.
        else goto help;

    }

    // No address set as client.
    if (!server && addrServer.IsIPv6AllZeros()) goto help;

    // Create client and server sockets
    //InitSteamDatagramConnectionSockets();

    SteamNetworkingErrMsg errMsg;
    enforce(GameNetworkingSockets_Init(null, errMsg), errMsg.format!"GameNetworkingSockets_Init failed. %s");
    scope (exit) GameNetworkingSockets_Kill();

    // Start input
    auto inputTid = spawn(&userInputEntrypoint);

    if (!server) {

        auto prog = new ChatClient;
        prog.Run(addrServer);

    }

    else {

        auto prog = new ChatServer;
        prog.Run(cast(ushort) port);

    }

    //ShutdownSteamDatagramConnectionSockets();

}
