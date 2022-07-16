/// Transcription of steamclientpublic.h to D.
///
/// Translated by hand, based on v1.3.0 6be41e3
///
/// Copyright: Valve Corporation, all rights reserved
module steam_gns.client_public;

import steam_gns.misc;
import steam_gns.stypes;
import steam_gns.universe;

@nogc nothrow extern (C++) align(4):

// General result codes
enum EResult {

    None = 0,                          // no result
    OK = 1,                            // success
    Fail = 2,                          // generic failure
    NoConnection = 3,                  // no/failed network connection
//  NoConnectionRetry = 4,             // OBSOLETE - removed
    InvalidPassword = 5,               // password/ticket is invalid
    LoggedInElsewhere = 6,             // same user logged in elsewhere
    InvalidProtocolVer = 7,            // protocol version is incorrect
    InvalidParam = 8,                  // a parameter is incorrect
    FileNotFound = 9,                  // file was not found
    Busy = 10,                         // called method busy - action not taken
    InvalidState = 11,                 // called object was in an invalid state
    InvalidName = 12,                  // name is invalid
    InvalidEmail = 13,                 // email is invalid
    DuplicateName = 14,                // name is not unique
    AccessDenied = 15,                 // access is denied
    Timeout = 16,                      // operation timed out
    Banned = 17,                       // VAC2 banned
    AccountNotFound = 18,              // account not found
    InvalidSteamID = 19,               // steamID is invalid
    ServiceUnavailable = 20,           // The requested service is currently unavailable
    NotLoggedOn = 21,                  // The user is not logged on
    Pending = 22,                      // Request is pending (may be in process, or waiting on third party)
    EncryptionFailure = 23,            // Encryption or Decryption failed
    InsufficientPrivilege = 24,        // Insufficient privilege
    LimitExceeded = 25,                // Too much of a good thing
    Revoked = 26,                      // Access has been revoked (used for revoked guest passes)
    Expired = 27,                      // License/Guest pass the user is trying to access is expired
    AlreadyRedeemed = 28,              // Guest pass has already been redeemed by account, cannot be acked again
    DuplicateRequest = 29,             // The request is a duplicate and the action has already occurred in the past, ignored this time
    AlreadyOwned = 30,                 // All the games in this guest pass redemption request are already owned by the user
    IPNotFound = 31,                   // IP address not found
    PersistFailed = 32,                // failed to write change to the data store
    LockingFailed = 33,                // failed to acquire access lock for this operation
    LogonSessionReplaced = 34,
    ConnectFailed = 35,
    HandshakeFailed = 36,
    IOFailure = 37,
    RemoteDisconnect = 38,
    ShoppingCartNotFound = 39,         // failed to find the shopping cart requested
    Blocked = 40,                      // a user didn't allow it
    Ignored = 41,                      // target is ignoring sender
    NoMatch = 42,                      // nothing matching the request found
    AccountDisabled = 43,
    ServiceReadOnly = 44,              // this service is not accepting content changes right now
    AccountNotFeatured = 45,           // account doesn't have value, so this feature isn't available
    AdministratorOK = 46,              // allowed to take this action, but only because requester is admin
    ContentVersion = 47,               // A Version mismatch in content transmitted within the Steam protocol.
    TryAnotherCM = 48,                 // The current CM can't service the user making a request, user should try another.
    PasswordRequiredToKickSession = 49,// You are already logged in elsewhere, this cached credential login has failed.
    AlreadyLoggedInElsewhere = 50,     // You are already logged in elsewhere, you must wait
    Suspended = 51,                    // Long running operation (content download) suspended/paused
    Cancelled = 52,                    // Operation canceled (typically by user: content download)
    DataCorruption = 53,               // Operation canceled because data is ill formed or unrecoverable
    DiskFull = 54,                     // Operation canceled - not enough disk space.
    RemoteCallFailed = 55,             // an remote call or IPC call failed
    PasswordUnset = 56,                // Password could not be verified as it's unset server side
    ExternalAccountUnlinked = 57,      // External account (PSN, Facebook...) is not linked to a Steam account
    PSNTicketInvalid = 58,             // PSN ticket was invalid
    ExternalAccountAlreadyLinked = 59, // External account (PSN, Facebook...) is already linked to some other account, must explicitly request to replace/delete the link first
    RemoteFileConflict = 60,           // The sync cannot resume due to a conflict between the local and remote files
    IllegalPassword = 61,              // The requested new password is not legal
    SameAsPreviousValue = 62,          // new value is the same as the old one ( secret question and answer )
    AccountLogonDenied = 63,           // account login denied due to 2nd factor authentication failure
    CannotUseOldPassword = 64,         // The requested new password is not legal
    InvalidLoginAuthCode = 65,         // account login denied due to auth code invalid
    AccountLogonDeniedNoMail = 66,     // account login denied due to 2nd factor auth failure - and no mail has been sent
    HardwareNotCapableOfIPT = 67,      //
    IPTInitError = 68,                 //
    ParentalControlRestricted = 69,    // operation failed due to parental control restrictions for current user
    FacebookQueryError = 70,           // Facebook query returned an error
    ExpiredLoginAuthCode = 71,         // account login denied due to auth code expired
    IPLoginRestrictionFailed = 72,
    AccountLockedDown = 73,
    AccountLogonDeniedVerifiedEmailRequired = 74,
    NoMatchingURL = 75,
    BadResponse = 76,                  // parse failure, missing field, etc.
    RequirePasswordReEntry = 77,       // The user cannot complete the action until they re-enter their password
    ValueOutOfRange = 78,              // the value entered is outside the acceptable range
    UnexpectedError = 79,              // something happened that we didn't expect to ever happen
    Disabled = 80,                     // The requested service has been configured to be unavailable
    InvalidCEGSubmission = 81,         // The set of files submitted to the CEG server are not valid !
    RestrictedDevice = 82,             // The device being used is not allowed to perform this action
    RegionLocked = 83,                 // The action could not be complete because it is region restricted
    RateLimitExceeded = 84,            // Temporary rate limit exceeded, try again later, different from k_EResultLimitExceeded which may be permanent
    AccountLoginDeniedNeedTwoFactor = 85,  // Need two-factor code to login
    ItemDeleted = 86,                  // The thing we're trying to access has been deleted
    AccountLoginDeniedThrottle = 87,   // login attempt failed, try to throttle response to possible attacker
    TwoFactorCodeMismatch = 88,        // two factor code mismatch
    TwoFactorActivationCodeMismatch = 89,  // activation code for two-factor didn't match
    AccountAssociatedToMultiplePartners = 90,  // account has been associated with multiple partners
    NotModified = 91,                  // data not modified
    NoMobileDevice = 92,               // the account does not have a mobile device associated with it
    TimeNotSynced = 93,                // the time presented is out of range or tolerance
    SmsCodeFailed = 94,                // SMS code failure (no match, none pending, etc.)
    AccountLimitExceeded = 95,         // Too many accounts access this resource
    AccountActivityLimitExceeded = 96, // Too many changes to this account
    PhoneActivityLimitExceeded = 97,   // Too many changes to this phone
    RefundToWallet = 98,               // Cannot refund to payment method, must use wallet
    EmailSendFailure = 99,             // Cannot send an email
    NotSettled = 100,                  // Can't perform operation till payment has settled
    NeedCaptcha = 101,                 // Needs to provide a valid captcha
    GSLTDenied = 102,                  // a game server login token owned by this token's owner has been banned
    GSOwnerDenied = 103,               // game server owner is denied for other reason (account lock, community ban, vac ban, missing phone)
    InvalidItemType = 104,             // the type of thing we were requested to act on is invalid
    IPBanned = 105,                    // the ip address has been banned from taking this action
    GSLTExpired = 106,                 // this token has expired from disuse; can be reset for use
    InsufficientFunds = 107,           // user doesn't have enough wallet funds to complete the action
    TooManyPending = 108,              // There are too many of this thing pending already
    NoSiteLicensesFound = 109,         // No site licenses found
    WGNetworkSendExceeded = 110,       // the WG couldn't send a response because we exceeded max network send size
    AccountNotFriends = 111,           // the user is not mutually friends
    LimitedUserAccount = 112,          // the user is limited
    CantRemoveItem = 113,              // item can't be removed
    AccountDeleted = 114,              // account has been deleted
    ExistingUserCancelledLicense = 115,    // A license for this already exists, but cancelled
    CommunityCooldown = 116,           // access is denied because of a community cooldown (probably from support profile data resets)
    NoLauncherSpecified = 117,         // No launcher was specified, but a launcher was needed to choose correct realm for operation.
    MustAgreeToSSA = 118,              // User must agree to china SSA or global SSA before login
    LauncherMigrated = 119,            // The specified launcher type is no longer supported; the user should be directed elsewhere
    SteamRealmMismatch = 120,          // The user's realm does not match the realm of the requested resource
    InvalidSignature = 121,            // signature check did not match
    ParseFailure = 122,                // Failed to parse input
    NoVerifiedPhone = 123,             // account does not have a verified phone number

}

// Error codes for use with the voice functions
enum EVoiceResult {

    OK = 0,
    NotInitialized = 1,
    NotRecording = 2,
    NoData = 3,
    BufferTooSmall = 4,
    DataCorrupted = 5,
    Restricted = 6,
    UnsupportedCodec = 7,
    ReceiverOutOfDate = 8,
    ReceiverDidNotAnswer = 9,

}

// Result codes to GSHandleClientDeny/Kick
enum EDenyReason {

    Invalid = 0,
    InvalidVersion = 1,
    Generic = 2,
    NotLoggedOn = 3,
    NoLicense = 4,
    Cheater = 5,
    LoggedInElseWhere = 6,
    UnknownText = 7,
    IncompatibleAnticheat = 8,
    MemoryCorruption = 9,
    IncompatibleSoftware = 10,
    SteamConnectionLost = 11,
    SteamConnectionError = 12,
    SteamResponseTimedOut = 13,
    SteamValidationStalled = 14,
    SteamOwnerLeftGuestUser = 15,

}

// return type of GetAuthSessionTicket
alias HAuthTicket = uint;
enum HAuthTicket k_HAuthTicketInvalid = 0;

// results from BeginAuthSession
enum EBeginAuthSessionResult {

    OK = 0,                        // Ticket is valid for this game and this steamID.
    InvalidTicket = 1,             // Ticket is not valid.
    DuplicateRequest = 2,          // A ticket has already been submitted for this steamID
    InvalidVersion = 3,            // Ticket is from an incompatible interface version
    GameMismatch = 4,              // Ticket is not for this game
    ExpiredTicket = 5,             // Ticket has expired

}

// Callback values for callback ValidateAuthTicketResponse_t which is a response to BeginAuthSession
enum EAuthSessionResponse {

    OK = 0,                           // Steam has verified the user is online, the ticket is valid and ticket has not been reused.
    UserNotConnectedToSteam = 1,      // The user in question is not connected to steam
    NoLicenseOrExpired = 2,           // The license has expired.
    VACBanned = 3,                    // The user is VAC banned for this game.
    LoggedInElseWhere = 4,            // The user account has logged in elsewhere and the session containing the game instance has been disconnected.
    VACCheckTimedOut = 5,             // VAC has been unable to perform anti-cheat checks on this user
    AuthTicketCanceled = 6,           // The ticket has been canceled by the issuer
    AuthTicketInvalidAlreadyUsed = 7, // This ticket has already been used, it is not valid.
    AuthTicketInvalid = 8,            // This ticket is not from a user instance currently connected to steam.
    PublisherIssuedBan = 9,           // The user is banned for this game. The ban came via the web api and not VAC

}

// results from UserHasLicenseForApp
enum EUserHasLicenseForAppResult {

    HasLicense = 0,                  // User has a license for specified app
    DoesNotHaveLicense = 1,          // User does not have a license for the specified app
    NoAuth = 2,                      // User has not been authenticated

}


// Steam account types
enum EAccountType {

    Invalid = 0,
    Individual = 1,       // single user account
    Multiseat = 2,        // multiseat (e.g. cybercafe) account
    GameServer = 3,       // game server account
    AnonGameServer = 4,   // anonymous game server account
    Pending = 5,          // pending
    ContentServer = 6,    // content server
    Clan = 7,
    Chat = 8,
    ConsoleUser = 9,      // Fake SteamID for local PSN account on PS3 or Live account on 360, etc.
    AnonUser = 10,

    // Max of 16 items in this field
    TypeMax

}



//-----------------------------------------------------------------------------
// Purpose: Chat Entry Types (previously was only friend-to-friend message types)
//-----------------------------------------------------------------------------
enum EChatEntryType {

    Invalid = 0,
    ChatMsg = 1,        // Normal text message from another user
    Typing = 2,         // Another user is typing (not used in multi-user chat)
    InviteGame = 3,     // Invite from other user into that users current game
    Emote = 4,          // text emote message (deprecated, should be treated as ChatMsg)
    //k_EChatEntryTypeLobbyGameStart = 5,   // lobby game is starting (dead - listen for LobbyGameCreated_t callback instead)
    LeftConversation = 6, // user has left the conversation ( closed chat window )
    // Above are previous FriendMsgType entries, now merged into more generic chat entry types
    Entered = 7,        // user has entered the conversation (used in multi-user chat and group chat)
    WasKicked = 8,      // user was kicked (data: 64-bit steamid of actor performing the kick)
    WasBanned = 9,      // user was banned (data: 64-bit steamid of actor performing the ban)
    Disconnected = 10,  // user disconnected
    HistoricalChat = 11,    // a chat message from user's chat history or offilne message
    //k_EChatEntryTypeReserved1 = 12, // No longer used
    //k_EChatEntryTypeReserved2 = 13, // No longer used
    LinkBlocked = 14, // a link was removed by the chat filter.

}


//-----------------------------------------------------------------------------
// Purpose: Chat Room Enter Responses
//-----------------------------------------------------------------------------
enum EChatRoomEnterResponse {

    Success = 1,        // Success
    DoesntExist = 2,    // Chat doesn't exist (probably closed)
    NotAllowed = 3,     // General Denied - You don't have the permissions needed to join the chat
    Full = 4,           // Chat room has reached its maximum size
    Error = 5,          // Unexpected Error
    Banned = 6,         // You are banned from this chat room and may not join
    Limited = 7,        // Joining this chat is not allowed because you are a limited user (no value on account)
    ClanDisabled = 8,   // Attempt to join a clan chat when the clan is locked or disabled
    CommunityBan = 9,   // Attempt to join a chat when the user has a community lock on their account
    MemberBlockedYou = 10, // Join failed - some member in the chat has blocked you from joining
    YouBlockedMember = 11, // Join failed - you have blocked some member already in the chat
    // k_EChatRoomEnterResponseNoRankingDataLobby = 12,  // No longer used
    // k_EChatRoomEnterResponseNoRankingDataUser = 13,  //  No longer used
    // k_EChatRoomEnterResponseRankOutOfRange = 14, //  No longer used
    RatelimitExceeded = 15, // Join failed - to many join attempts in a very short period of time

}


enum uint k_unSteamAccountIDMask = 0xFFFFFFFF;
enum uint k_unSteamAccountInstanceMask = 0x000FFFFF;
enum uint k_unSteamUserDefaultInstance = 1; // fixed instance for all individual users

// Special flags for Chat accounts - they go in the top 8 bits
// of the steam ID's "instance", leaving 12 for the actual instances
enum EChatSteamIDInstanceFlags {

    EChatAccountInstanceMask = 0x00000FFF, // top 8 bits are flags

    EChatInstanceFlagClan = ( k_unSteamAccountInstanceMask + 1 ) >> 1,    // top bit
    EChatInstanceFlagLobby = ( k_unSteamAccountInstanceMask + 1 ) >> 2,   // next one down, etc
    EChatInstanceFlagMMSLobby = ( k_unSteamAccountInstanceMask + 1 ) >> 3,    // next one down, etc

    // Max of 8 flags
}


//-----------------------------------------------------------------------------
// Purpose: Possible positions to tell the overlay to show notifications in
//-----------------------------------------------------------------------------
enum ENotificationPosition {

    TopLeft = 0,
    TopRight = 1,
    BottomLeft = 2,
    BottomRight = 3,

}


//-----------------------------------------------------------------------------
// Purpose: Broadcast upload result details
//-----------------------------------------------------------------------------
enum EBroadcastUploadResult {

    None = 0,   // broadcast state unknown
    OK = 1,     // broadcast was good, no problems
    InitFailed = 2, // broadcast init failed
    FrameFailed = 3,    // broadcast frame upload failed
    Timeout = 4,    // broadcast upload timed out
    BandwidthExceeded = 5,  // broadcast send too much data
    LowFPS = 6, // broadcast FPS too low
    MissingKeyFrames = 7,   // broadcast sending not enough key frames
    NoConnection = 8,   // broadcast client failed to connect to relay
    RelayFailed = 9,    // relay dropped the upload
    SettingsChanged = 10,   // the client changed broadcast settings
    MissingAudio = 11,  // client failed to send audio data
    TooFarBehind = 12,  // clients was too slow uploading
    TranscodeBehind = 13,   // server failed to keep up with transcode
    NotAllowedToPlay = 14, // Broadcast does not have permissions to play game
    Busy = 15, // RTMP host to busy to take new broadcast stream, choose another
    Banned = 16, // Account banned from community broadcast
    AlreadyActive = 17, // We already already have an stream running.
    ForcedOff = 18, // We explicitly shutting down a broadcast
    AudioBehind = 19, // Audio stream was too far behind video
    Shutdown = 20,  // Broadcast Server was shut down
    Disconnect = 21,    // broadcast uploader TCP disconnected
    VideoInitFailed = 22,   // invalid video settings
    AudioInitFailed = 23,   // invalid audio settings

}


//-----------------------------------------------------------------------------
// Purpose: Reasons a user may not use the Community Market.
//          Used in MarketEligibilityResponse_t.
//-----------------------------------------------------------------------------
enum EMarketNotAllowedReasonFlags {

    None = 0,

    // A back-end call failed or something that might work again on retry
    TemporaryFailure = (1 << 0),

    // Disabled account
    AccountDisabled = (1 << 1),

    // Locked account
    AccountLockedDown = (1 << 2),

    // Limited account (no purchases)
    AccountLimited = (1 << 3),

    // The account is banned from trading items
    TradeBanned = (1 << 4),

    // Wallet funds aren't tradable because the user has had no purchase
    // activity in the last year or has had no purchases prior to last month
    AccountNotTrusted = (1 << 5),

    // The user doesn't have Steam Guard enabled
    SteamGuardNotEnabled = (1 << 6),

    // The user has Steam Guard, but it hasn't been enabled for the required
    // number of days
    SteamGuardOnlyRecentlyEnabled = (1 << 7),

    // The user has recently forgotten their password and reset it
    RecentPasswordReset = (1 << 8),

    // The user has recently funded his or her wallet with a new payment method
    NewPaymentMethod = (1 << 9),

    // An invalid cookie was sent by the user
    InvalidCookie = (1 << 10),

    // The user has Steam Guard, but is using a new computer or web browser
    UsingNewDevice = (1 << 11),

    // The user has recently refunded a store purchase by his or herself
    RecentSelfRefund = (1 << 12),

    // The user has recently funded his or her wallet with a new payment method that cannot be verified
    NewPaymentMethodCannotBeVerified = (1 << 13),

    // Not only is the account not trusted, but they have no recent purchases at all
    NoRecentPurchases = (1 << 14),

    // User accepted a wallet gift that was recently purchased
    AcceptedWalletGift = (1 << 15),

}


//
// describes XP / progress restrictions to apply for games with duration control /
// anti-indulgence enabled for minor Steam China users.
//
// WARNING: DO NOT RENUMBER
enum EDurationControlProgress {

    Full = 0,    // Full progress
    Half = 1,    // deprecated - XP or persistent rewards should be halved
    None = 2,    // deprecated - XP or persistent rewards should be stopped

    ExitSoon_3h = 3,     // allowed 3h time since 5h gap/break has elapsed, game should exit - steam will terminate the game soon
    ExitSoon_5h = 4,     // allowed 5h time in calendar day has elapsed, game should exit - steam will terminate the game soon
    ExitSoon_Night = 5,  // game running after day period, game should exit - steam will terminate the game soon

}


//
// describes which notification timer has expired, for steam china duration control feature
//
// WARNING: DO NOT RENUMBER
enum EDurationControlNotification {

    None = 0,        // just informing you about progress, no notification to show
    _1Hour = 1,       // "you've been playing for N hours"

    _3Hours = 2,      // deprecated - "you've been playing for 3 hours; take a break"
    HalfProgress = 3,// deprecated - "your XP / progress is half normal"
    NoProgress = 4,  // deprecated - "your XP / progress is zero"

    ExitSoon_3h = 5, // allowed 3h time since 5h gap/break has elapsed, game should exit - steam will terminate the game soon
    ExitSoon_5h = 6, // allowed 5h time in calendar day has elapsed, game should exit - steam will terminate the game soon
    ExitSoon_Night = 7,// game running after day period, game should exit - steam will terminate the game soon

}


//
// Specifies a game's online state in relation to duration control
//
enum EDurationControlOnlineState {

    Invalid = 0,              // nil value
    Offline = 1,              // currently in offline play - single-player, offline co-op, etc.
    Online = 2,               // currently in online play
    OnlineHighPri = 3,        // currently in online play and requests not to be interrupted

}


// Steam ID structure (64 bits total)
struct CSteamID {

    ulong m_steamid;

}

/+
inline bool CSteamID::IsValid() const
{
    if ( m_steamid.m_comp.m_EAccountType <= k_EAccountTypeInvalid || m_steamid.m_comp.m_EAccountType >= k_EAccountTypeMax )
        return false;

    if ( m_steamid.m_comp.m_EUniverse <= k_EUniverseInvalid || m_steamid.m_comp.m_EUniverse >= k_EUniverseMax )
        return false;

    if ( m_steamid.m_comp.m_EAccountType == k_EAccountTypeIndividual )
    {
        if ( m_steamid.m_comp.m_unAccountID == 0 || m_steamid.m_comp.m_unAccountInstance != k_unSteamUserDefaultInstance )
            return false;
    }

    if ( m_steamid.m_comp.m_EAccountType == k_EAccountTypeClan )
    {
        if ( m_steamid.m_comp.m_unAccountID == 0 || m_steamid.m_comp.m_unAccountInstance != 0 )
            return false;
    }

    if ( m_steamid.m_comp.m_EAccountType == k_EAccountTypeGameServer )
    {
        if ( m_steamid.m_comp.m_unAccountID == 0 )
            return false;
        // Any limit on instances?  We use them for local users and bots
    }
    return true;
}

// generic invalid CSteamID
#define k_steamIDNil CSteamID()

// This steamID comes from a user game connection to an out of date GS that hasnt implemented the protocol
// to provide its steamID
#define k_steamIDOutofDateGS CSteamID( 0, 0, k_EUniverseInvalid, k_EAccountTypeInvalid )
// This steamID comes from a user game connection to an sv_lan GS
#define k_steamIDLanModeGS CSteamID( 0, 0, k_EUniversePublic, k_EAccountTypeInvalid )
// This steamID can come from a user game connection to a GS that has just booted but hasnt yet even initialized
// its steam3 component and started logging on.
#define k_steamIDNotInitYetGS CSteamID( 1, 0, k_EUniverseInvalid, k_EAccountTypeInvalid )
// This steamID can come from a user game connection to a GS that isn't using the steam authentication system but still
// wants to support the "Join Game" option in the friends list
#define k_steamIDNonSteamGS CSteamID( 2, 0, k_EUniverseInvalid, k_EAccountTypeInvalid )

+/

/+


#ifdef STEAM
// Returns the matching chat steamID, with the default instance of 0
// If the steamID passed in is already of type k_EAccountTypeChat it will be returned with the same instance
CSteamID ChatIDFromSteamID( const CSteamID &steamID );
// Returns the matching clan steamID, with the default instance of 0
// If the steamID passed in is already of type k_EAccountTypeClan it will be returned with the same instance
CSteamID ClanIDFromSteamID( const CSteamID &steamID );
// Asserts steamID type before conversion
CSteamID ChatIDFromClanID( const CSteamID &steamIDClan );
// Asserts steamID type before conversion
CSteamID ClanIDFromChatID( const CSteamID &steamIDChat );

#endif // _STEAM

+/


/+

//-----------------------------------------------------------------------------
// Purpose: encapsulates an appID/modID pair
//-----------------------------------------------------------------------------
class CGameID
{
public:

    CGameID()
    {
        m_gameID.m_nType = k_EGameIDTypeApp;
        m_gameID.m_nAppID = k_uAppIdInvalid;
        m_gameID.m_nModID = 0;
    }

    explicit CGameID( uint64 ulGameID )
    {
        m_ulGameID = ulGameID;
    }
#ifdef INT64_DIFFERENT_FROM_INT64_T
    CGameID( uint64_t ulGameID )
    {
        m_ulGameID = (uint64)ulGameID;
    }
#endif

    explicit CGameID( int32 nAppID )
    {
        m_ulGameID = 0;
        m_gameID.m_nAppID = nAppID;
    }

    explicit CGameID( uint32 nAppID )
    {
        m_ulGameID = 0;
        m_gameID.m_nAppID = nAppID;
    }

    CGameID( uint32 nAppID, uint32 nModID )
    {
        m_ulGameID = 0;
        m_gameID.m_nAppID = nAppID;
        m_gameID.m_nModID = nModID;
        m_gameID.m_nType = k_EGameIDTypeGameMod;
    }

    CGameID( const CGameID &that )
    {
        m_ulGameID = that.m_ulGameID;
    }

    CGameID& operator=( const CGameID & that )
    {
        m_ulGameID = that.m_ulGameID;
        return *this;
    }

    // Hidden functions used only by Steam
    explicit CGameID( const char *pchGameID );
    const char *Render() const;                 // render this Game ID to string
    static const char *Render( uint64 ulGameID );       // static method to render a uint64 representation of a Game ID to a string

    uint64 ToUint64() const
    {
        return m_ulGameID;
    }

    uint64 *GetUint64Ptr()
    {
        return &m_ulGameID;
    }

    void Set( uint64 ulGameID )
    {
        m_ulGameID = ulGameID;
    }

    bool IsMod() const
    {
        return ( m_gameID.m_nType == k_EGameIDTypeGameMod );
    }

    bool IsShortcut() const
    {
        return ( m_gameID.m_nType == k_EGameIDTypeShortcut );
    }

    bool IsP2PFile() const
    {
        return ( m_gameID.m_nType == k_EGameIDTypeP2P );
    }

    bool IsSteamApp() const
    {
        return ( m_gameID.m_nType == k_EGameIDTypeApp );
    }

    uint32 ModID() const
    {
        return m_gameID.m_nModID;
    }

    uint32 AppID() const
    {
        return m_gameID.m_nAppID;
    }

    bool operator == ( const CGameID &rhs ) const
    {
        return m_ulGameID == rhs.m_ulGameID;
    }

    bool operator != ( const CGameID &rhs ) const
    {
        return !(*this == rhs);
    }

    bool operator < ( const CGameID &rhs ) const
    {
        return ( m_ulGameID < rhs.m_ulGameID );
    }

    bool IsValid() const
    {
        // each type has it's own invalid fixed point:
        switch( m_gameID.m_nType )
        {
        case k_EGameIDTypeApp:
            return m_gameID.m_nAppID != k_uAppIdInvalid;

        case k_EGameIDTypeGameMod:
            return m_gameID.m_nAppID != k_uAppIdInvalid && m_gameID.m_nModID & 0x80000000;

        case k_EGameIDTypeShortcut:
            return (m_gameID.m_nModID & 0x80000000) != 0;

        case k_EGameIDTypeP2P:
            return m_gameID.m_nAppID == k_uAppIdInvalid && m_gameID.m_nModID & 0x80000000;

        default:
            return false;
        }

    }

    void Reset()
    {
        m_ulGameID = 0;
    }

//
// Internal stuff.  Use the accessors above if possible
//

    enum EGameIDType
    {
        k_EGameIDTypeApp        = 0,
        k_EGameIDTypeGameMod    = 1,
        k_EGameIDTypeShortcut   = 2,
        k_EGameIDTypeP2P        = 3,
    };

    struct GameID_t
    {
#ifdef VALVE_BIG_ENDIAN
        unsigned int m_nModID : 32;
        unsigned int m_nType : 8;
        unsigned int m_nAppID : 24;
#else
        unsigned int m_nAppID : 24;
        unsigned int m_nType : 8;
        unsigned int m_nModID : 32;
#endif
    };

    union
    {
        uint64 m_ulGameID;
        GameID_t m_gameID;
    };
};

#pragma pack( pop )

const int k_cchGameExtraInfoMax = 64;


//-----------------------------------------------------------------------------
// Purpose: Passed as argument to SteamAPI_UseBreakpadCrashHandler to enable optional callback
//  just before minidump file is captured after a crash has occurred.  (Allows app to append additional comment data to the dump, etc.)
//-----------------------------------------------------------------------------
typedef void (*PFNPreMinidumpCallback)(void *context);

enum EGameSearchErrorCode_t
{
    k_EGameSearchErrorCode_OK = 1,
    k_EGameSearchErrorCode_Failed_Search_Already_In_Progress = 2,
    k_EGameSearchErrorCode_Failed_No_Search_In_Progress = 3,
    k_EGameSearchErrorCode_Failed_Not_Lobby_Leader = 4, // if not the lobby leader can not call SearchForGameWithLobby
    k_EGameSearchErrorCode_Failed_No_Host_Available = 5, // no host is available that matches those search params
    k_EGameSearchErrorCode_Failed_Search_Params_Invalid = 6, // search params are invalid
    k_EGameSearchErrorCode_Failed_Offline = 7, // offline, could not communicate with server
    k_EGameSearchErrorCode_Failed_NotAuthorized = 8, // either the user or the application does not have priveledges to do this
    k_EGameSearchErrorCode_Failed_Unknown_Error = 9, // unknown error
};

enum EPlayerResult_t
{
    k_EPlayerResultFailedToConnect = 1, // failed to connect after confirming
    k_EPlayerResultAbandoned = 2,       // quit game without completing it
    k_EPlayerResultKicked = 3,          // kicked by other players/moderator/server rules
    k_EPlayerResultIncomplete = 4,      // player stayed to end but game did not conclude successfully ( nofault to player )
    k_EPlayerResultCompleted = 5,       // player completed game
};


enum ESteamIPv6ConnectivityProtocol
{
    k_ESteamIPv6ConnectivityProtocol_Invalid = 0,
    k_ESteamIPv6ConnectivityProtocol_HTTP = 1,      // because a proxy may make this different than other protocols
    k_ESteamIPv6ConnectivityProtocol_UDP = 2,       // test UDP connectivity. Uses a port that is commonly needed for other Steam stuff. If UDP works, TCP probably works.
};

// For the above transport protocol, what do we think the local machine's connectivity to the internet over ipv6 is like
enum ESteamIPv6ConnectivityState
{
    k_ESteamIPv6ConnectivityState_Unknown = 0,  // We haven't run a test yet
    k_ESteamIPv6ConnectivityState_Good = 1,     // We have recently been able to make a request on ipv6 for the given protocol
    k_ESteamIPv6ConnectivityState_Bad = 2,      // We failed to make a request, either because this machine has no ipv6 address assigned, or it has no upstream connectivity
};


// Define compile time assert macros to let us validate the structure sizes.
#define VALVE_COMPILE_TIME_ASSERT( pred ) typedef char compile_time_assert_type[(pred) ? 1 : -1];

#if defined(__linux__) || defined(__APPLE__) || defined(__FreeBSD__)
// The 32-bit version of gcc has the alignment requirement for uint64 and double set to
// 4 meaning that even with #pragma pack(8) these types will only be four-byte aligned.
// The 64-bit version of gcc has the alignment requirement for these types set to
// 8 meaning that unless we use #pragma pack(4) our structures will get bigger.
// The 64-bit structure packing has to match the 32-bit structure packing for each platform.
#define VALVE_CALLBACK_PACK_SMALL
#else
#define VALVE_CALLBACK_PACK_LARGE
#endif

#if defined( VALVE_CALLBACK_PACK_SMALL )
#pragma pack( push, 4 )
#elif defined( VALVE_CALLBACK_PACK_LARGE )
#pragma pack( push, 8 )
#else
#error ???
#endif

typedef struct ValvePackingSentinel_t
{
    uint32 m_u32;
    uint64 m_u64;
    uint16 m_u16;
    double m_d;
} ValvePackingSentinel_t;

#pragma pack( pop )


#if defined(VALVE_CALLBACK_PACK_SMALL)
VALVE_COMPILE_TIME_ASSERT( sizeof(ValvePackingSentinel_t) == 24 )
#elif defined(VALVE_CALLBACK_PACK_LARGE)
VALVE_COMPILE_TIME_ASSERT( sizeof(ValvePackingSentinel_t) == 32 )
#else
#error ???
#endif

#endif // STEAMCLIENTPUBLIC_H

+/
