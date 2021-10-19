/// Miscelleanous defines.
///
/// Copyright: Valve Corporation, all rights reserved
module steam_gns.misc;

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
