/// Miscelleanous defines.
///
/// Copyright: Valve Corporation, all rights reserved
module steam_gns.misc;

import steam_gns.types;

@nogc nothrow extern (C++) align(4):

alias SteamInstanceID_t = ushort;
alias SteamLocalUserID_t = ulong;

struct TSteamSplitLocalUserID {

    uint    Low32bits;
    uint    High32bits;

}


struct TSteamGlobalUserID {

    SteamInstanceID_t m_SteamInstanceID;

    union SteamLocalUserID_union {
        SteamLocalUserID_t      As64bits;
        TSteamSplitLocalUserID  Split;

    }

    SteamLocalUserID_union m_SteamLocalUserID;

}

enum k_iSteamNetworkingSocketsCallbacks = 1220;
enum k_iSteamNetworkingMessagesCallbacks = 1250;
enum k_iSteamNetworkingUtilsCallbacks = 1280;

extern (C) {

    bool GameNetworkingSockets_Init(const SteamNetworkingIdentity* pIdentity, ref SteamNetworkingErrMsg errMsg);

    // Close all connections and listen sockets and free all resources
    void GameNetworkingSockets_Kill();

}
