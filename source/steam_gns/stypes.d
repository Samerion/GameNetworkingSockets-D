/// Transcription of steamtypes.h to D.
///
/// Copyright: Valve Corporation, all rights reserved
module steam_gns.stypes;

@nogc nothrow extern (C++) align(4):

// probably unnecessary, i confused this with steamnetworkingtypes.h

alias intp = ptrdiff_t;
alias uintp = size_t;

alias AppId_t = uint;
enum AppId_t k_uAppIdInvalid = 0x0;

// AppIds and DepotIDs also presently share the same namespace
alias DepotId_t = uint;
enum DepotId_t k_uDepotIdInvalid = 0x0;

// RTime32.  Seconds elapsed since Jan 1 1970, i.e. unix timestamp.
// It's the same as time_t, but it is always 32-bit and unsigned.
alias RTime32 = uint;

// handle to a Steam API call
alias SteamAPICall_t = ulong;
enum SteamAPICall_t k_uAPICallInvalid = 0x0;

alias AccountID_t = uint;

// Party Beacon ID
alias PartyBeaconID_t = ulong;
enum PartyBeaconID_t k_ulPartyBeaconIdInvalid = 0;

enum ESteamIPType {
    k_ESteamIPTypeIPv4 = 0,
    k_ESteamIPTypeIPv6 = 1,
}

struct SteamIPAddress_t {

    align(1):

    union {

        uint          m_unIPv4;       // Host order
        ubyte[16]     m_rgubIPv6;     // Network order! Same as inaddr_in6.  (0011:2233:4455:6677:8899:aabb:ccdd:eeff)

        // Internal use only
        ulong[2]         m_ipv6Qword; // big endian
    };

    ESteamIPType m_eType;

    bool IsSet() const {
        if (ESteamIPType.k_ESteamIPTypeIPv4 == m_eType) {
            return m_unIPv4 != 0;
        }
        else {
            return m_ipv6Qword[0] != 0 || m_ipv6Qword[1] != 0;
        }
    }

    static SteamIPAddress_t IPv4Any() {
        SteamIPAddress_t ipOut;
        ipOut.m_eType = ESteamIPType.k_ESteamIPTypeIPv4;
        ipOut.m_unIPv4 = 0;

        return ipOut;
    }

    static SteamIPAddress_t IPv6Any() {
        SteamIPAddress_t ipOut;
        ipOut.m_eType = ESteamIPType.k_ESteamIPTypeIPv6;
        ipOut.m_ipv6Qword[0] = 0;
        ipOut.m_ipv6Qword[1] = 0;

        return ipOut;
    }

    static SteamIPAddress_t IPv4Loopback() {
        SteamIPAddress_t ipOut;
        ipOut.m_eType = ESteamIPType.k_ESteamIPTypeIPv4;
        ipOut.m_unIPv4 = 0x7f000001;

        return ipOut;
    }

    static SteamIPAddress_t IPv6Loopback() {
        SteamIPAddress_t ipOut;
        ipOut.m_eType = ESteamIPType.k_ESteamIPTypeIPv6;
        ipOut.m_ipv6Qword[0] = 0;
        ipOut.m_ipv6Qword[1] = 0;
        ipOut.m_rgubIPv6[15] = 1;

        return ipOut;
    }
}
