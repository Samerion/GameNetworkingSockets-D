/// Transcription of steamuniverse.h to D.
///
/// Copyright: Valve Corporation, all rights reserved
module steam_gns.universe;

@nogc nothrow extern (C++) align(4):

/// Steam universes.  Each universe is a self-contained Steam instance.
enum EUniverse {

    k_EUniverseInvalid = 0,
    k_EUniversePublic = 1,
    k_EUniverseBeta = 2,
    k_EUniverseInternal = 3,
    k_EUniverseDev = 4,
    // k_EUniverseRC = 5,               // no such universe anymore
    k_EUniverseMax

}
