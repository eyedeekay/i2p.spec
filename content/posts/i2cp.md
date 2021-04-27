---
title: "I2cp"
date: 2021-04-27T14:39:35-04:00
draft: true
---

I2CP Specification
==================

Category: Protocols Last updated: 2020-11 Accurate for: 0.9.48

Overview
--------

This page specified the I2P Control Protocol (I2CP), which is the
interface between clients and the router. Java clients will use the I2CP
client API, which implements this protocol. Non-Java clients will most
likely use a higher-layer protocol such as SAM or BOB.

The protocol is only serialized if the client and router are not in the
same JVM; otherwise, I2CP message objects are passed via an internal JVM
interface.

More information is on the I2CP Overview page \[I2CP\].

Sessions
--------

The protocol was designed to handle multiple \"sessions\", each with a
2-byte session ID, over a single TCP connection, however, Multiple
sessions were not implemented until version 0.9.21. See the
[multisession section below](_multisession). Do not attempt to use
multiple sessions on a single I2CP connection with routers older than
version 0.9.21.

It also appears that there are some provisions for a single client to
talk to multiple routers over separate connections. This is also
untested, and probably not useful.

It does not appear that there is currently a way for a session to be
maintained after a disconnect, or to be recovered on a different I2CP
connection.

Example Message Sequences
-------------------------

Note: The examples below do not show the Protocol Byte (0x2a) that must
be sent from the client to the router when first connecting. More
information about connection initialization is on the I2CP Overview page
\[I2CP\].

### Standard Session Establish

> Client Router
>
> > \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--\> Get Date Message Set
> > Date Message
> > \<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--\>
> > Create Session Message
>
> Session Status Message
> \<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--Request LeaseSet Message
> \<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--
> \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--\> Create LeaseSet Message

### Get Bandwidth Limits (Simple Session)

> Client Router
>
> > \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--\> Get Bandwidth Limits
> > Message
>
> Bandwidth Limits Message \<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

### Destination Lookup (Simple Session)

> Client Router
>
> > \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--\> Dest Lookup Message Dest
> > Reply Message \<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

### Outgoing Message

Existing session, with i2cp.messageReliability=none

> Client Router
>
> > \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--\> Send Message Message

Existing session, with i2cp.messageReliability=none and nonzero nonce

> Client Router
>
> > \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--\> Send Message Message
>
> Message Status Message
> \<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--(succeeded)

Existing session, with i2cp.messageReliability=BestEffort

> Client Router
>
> > \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--\> Send Message Message
>
> Message Status Message
> \<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--(accepted) Message Status
> Message \<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--(succeeded)

### Incoming Message

Existing session, with i2cp.fastReceive=true (as of 0.9.4)

> Client Router
>
> Message Payload Message \<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--

Existing session, with i2cp.fastReceive=false

> Client Router
>
> Message Status Message \<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--(available)
>
> :   \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--\> Receive Message Begin
>     Message
>
> Message Payload Message \<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--
> \-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\--\> Receive Message End
> Message

### Multisession Notes {#multisession}

Multiple sessions on a single I2CP connection are supported as of router
version 0.9.21. The first session that is created is the \"primary
session\". Additional sessions are \"subsessions\". Subsessions are used
to support multiple destinations sharing a common set of tunnels. The
initial application is for the primary session to use ECDSA signing
keys, while the subsession uses DSA signing keys for communication with
old eepsites.

Subsessions share the same inbound and outbound tunnel pools as the
primary session. Subsessions must use the same encryption keys as the
primary session. This applies both to the LeaseSet encryption keys and
the (unused) Destination encryption keys. Subsessions must use different
signing keys in the destination, so the destination hash is different
from the primary session. As subsessions use the same encryption keys
and tunnels as the primary session, it is apparent to all that the
Destinations are running on the same router, so the usual
anti-correlation anonymity guarantees do not apply.

Subsessions are created by sending a CreateSession message and receiving
a SessionStatus message in reply, as usual. Subsessions must be created
after the primary session is created. The SessionStatus response will,
on success, contain a unique Session ID, distinct from the ID for the
primary session. While CreateSession messages should be processed
in-order, there is no sure way to correlate a CreateSession message with
the response, so a client should not have multiple CreateSession
messages outstanding simultaneously. SessionConfig options for the
subsession may not be honored where they are different from the primary
session. In particular, since subsessions use the same tunnel pool as
the primary session, tunnel options may be ignored.

The router will send separate RequestVariableLeaseSet messages for each
Destination to the client, and the client must reply with a
CreateLeaseSet message for each. The leases for the two Destinations
will not necessarily be identical, even though they are selected from
the same tunnel pool.

A subsession may be destroyed with the DestroySession message as usual.
This will not destroy the primary session or stop the I2CP connection.
Destroying the primary session will, however, destroy all subsessions
and stop the I2CP connection. A Disconnect message destroys all
sessions.

Note that most, but not all, I2CP messages contain a Session ID. For the
ones that do not, clients may need additional logic to properly handle
router responses. DestLookup and DestReply do not contain Session IDs;
use the newer HostLookup and HostReply instead. GetBandwidthLimts and
BandwidthLimits do not contain session IDs, however the response is not
session-specific.

Support for multiple sessions is preliminary and subject to change.
Support may not be complete in other parts of the API and user
interface, particularly streaming and i2ptunnel. Current support is
primarily for clients (i.e. Destinations that do not publish their
leaseset or accept incoming connections), and is incomplete and untested
for servers. Future releases may provide additional features and
options.

### Version Notes {#notes}

The initial protocol version byte (0x2a) sent by the client is not
expected to change. Prior to release 0.8.7, the router\'s version
information was not available to the client, thus preventing new clients
from working with old routers. As of release 0.8.7, the two parties\'
protocol version strings are exchanged in the Get/Set Date Messages.
Going forward, clients may use this information to communicate correctly
with old routers. Clients and routers should not send messages that are
unsupported by the other side, as they generally disconnect the session
upon reception of an unsupported message.

The exchanged version information is the \"core\" version or I2CP
protocol version, and is not necessarily the router version.

A basic summary of the I2CP protocol versions is as follows. For
details, see below.

+----------------+----------------------------------------------------+
| Version        | Required I2CP Features                             |
+================+====================================================+
| > 0.9.43       | BlindingInfo message supported                     |
|                |                                                    |
|                | Additional HostReply message failure codes         |
+----------------+----------------------------------------------------+
| > 0.9.41       | EncryptedLeaseSet options                          |
|                |                                                    |
|                | MessageStatus message Meta LS error code           |
+----------------+----------------------------------------------------+
| > 0.9.39       | CreateLeaseSet2 message and options supported      |
|                |                                                    |
|                | Dest/LS key certs w/ RedDSA Ed25519 sig type       |
|                | supported                                          |
+----------------+----------------------------------------------------+
| > 0.9.38       | Preliminary CreateLeaseSet2 message supported      |
|                | (abandoned)                                        |
+----------------+----------------------------------------------------+
| > 0.9.21       | Multiple sessions on a single I2CP connection      |
|                | supported                                          |
+----------------+----------------------------------------------------+
| > 0.9.20       | Additional SetDate messages may be sent to the     |
|                | client at any time                                 |
+----------------+----------------------------------------------------+
| > 0.9.16       | Authentication, if enabled, is required via        |
|                | GetDate before all other messages                  |
+----------------+----------------------------------------------------+
| > 0.9.15       | Dest/LS key certs w/ EdDSA Ed25519 sig type        |
|                | supported                                          |
+----------------+----------------------------------------------------+
| > 0.9.14       | Per-message override of messageReliability=none    |
|                | with nonzero nonce                                 |
+----------------+----------------------------------------------------+
| > 0.9.12       | Dest/LS key certs w/ ECDSA P-256, P-384, and P-521 |
|                | sig types supported                                |
|                |                                                    |
|                | Note: RSA sig types also supported as of this      |
|                | version, but currently unused                      |
+----------------+----------------------------------------------------+
| > 0.9.11       | Host Lookup and Host Reply messages supported      |
|                |                                                    |
|                | Authentication mapping in Get Date message         |
|                | supported                                          |
+----------------+----------------------------------------------------+
| > 0.9.7        | Request Variable Lease Set message supported       |
+----------------+----------------------------------------------------+
| > 0.9.5        | Additional Message Status codes defined            |
+----------------+----------------------------------------------------+
| > 0.9.4        | Send Message nonce=0 allowed                       |
|                |                                                    |
|                | Fast receive mode is the default                   |
+----------------+----------------------------------------------------+
| > 0.9.2        | Send Message Expires flag tag bits supported       |
+----------------+----------------------------------------------------+
| > 0.9          | Supports up to 16 leases in a lease set (6         |
|                | previously)                                        |
+----------------+----------------------------------------------------+
| > 0.8.7        | Get Date and Set Date version strings included.    |
|                |                                                    |
|                | If not present, the client or router is version    |
|                | 0.8.6 or older.                                    |
+----------------+----------------------------------------------------+
| > 0.8.4        | Send Message Expires flag bits supported           |
+----------------+----------------------------------------------------+
| > 0.8.3        | Dest Lookup and Get Bandwidth messages supported   |
|                | in standard session                                |
|                |                                                    |
|                | Concurrent Dest Lookup messages supported          |
+----------------+----------------------------------------------------+
| > 0.8.1        | i2cp.messageReliability=none supported             |
+----------------+----------------------------------------------------+
| > 0.7.2        | Get Bandwidth Limits and Bandwidth Limits messages |
|                | supported                                          |
+----------------+----------------------------------------------------+
| > 0.7.1        | Send Message Expires message supported             |
|                |                                                    |
|                | Reconfigure Session message supported              |
+----------------+----------------------------------------------------+
| > 0.7          | Dest Lookup and Dest Reply messages supported      |
+----------------+----------------------------------------------------+
| 0.6.5 or lower | All messages and features not listed above         |
+----------------+----------------------------------------------------+

Common structures {#structures}
-----------------

### I2CP message header {#struct-I2CPMessageHeader}

#### Description

Common header to all I2CP messages, containing the message length and
message type.

#### Contents

1.  4 byte \[Integer\] specifying the length of the message body
2.  1 byte \[Integer\] specifying the message type.
3.  The I2CP message body, 0 or more bytes

#### Notes

Actual message length limit is about 64 KB.

### Message ID {#struct-MessageId}

#### Description

Uniquely identifies a message waiting on a particular router at a point
in time. This is always generated by the router and is NOT the same as
the nonce generated by the client.

#### Contents

1.  4 byte \[Integer\]

#### Notes

Message IDs are unique within a session only; they are not globally
unique.

### Payload {#struct-Payload}

#### Description

This structure is the content of a message being delivered from one
Destination to another.

#### Contents

1.  4 byte \[Integer\] length
2.  That many bytes

#### Notes

The payload is in a gzip format as specified on the I2CP Overview page
\[I2CP-FORMAT\].

### Session Config {#struct-SessionConfig}

#### Description

Defines the configuration options for a particular client session.

#### Contents

1.  \[Destination\]
2.  \[Mapping\] of options
3.  Creation \[Date\]
4.  \[Signature\] of the previous 3 fields, signed by the
    \[SigningPrivateKey\]

#### Notes

-   The options are specified on the I2CP Overview page
    \[I2CP-OPTIONS\].
-   The \[Mapping\] must be sorted by key so that the signature will be
    validated correctly in the router.
-   The creation date must be within +/- 30 seconds of the current time
    when processed by the router, or the config will be rejected.

#### Offline Signatures

-   If the \[Destination\] is offline signed, the \[Mapping\] must
    contain the three options i2cp.leaseSetOfflineExpiration,
    i2cp.leaseSetTransientPublicKey, and i2cp.leaseSetOfflineSignature.
    The \[Signature\] is then by the transient \[SigningPrivateKey\] and
    is verified with the \[SigningPublicKey\] specified in
    i2cp.leaseSetTransientPublicKey. See \[I2CP-OPTIONS\] for details.

### Session ID {#struct-SessionId}

#### Description

Uniquely identifies a session on a particular router at a point in time.

#### Contents

1.  2 byte \[Integer\]

#### Notes

Messages
--------

See also the I2CP Javadocs \[I2CP-JAVADOCS\].

### Message Types {#types}

+------------------+------------------+----------------+--------+
| Message          | Direction        | Type           | Since  |
+==================+==================+================+========+
| [                | > R -\> C        | > 23           | 0.7.2  |
| BandwidthLimitsM |                  |                |        |
| essage](#bandwid |                  |                |        |
| thlimitsmessage) |                  |                |        |
+------------------+------------------+----------------+--------+
| [BlindingIn      | > C -\> R C -\>  | > 42           | 0.9.43 |
| foMessage](#blin | > R              | >              |        |
| dinginfomessage) |                  | > :   4        |        |
| [CreateLeaseSet  |                  |                |        |
| Message](#create |                  |                |        |
| leasesetmessage) |                  |                |        |
+------------------+------------------+----------------+--------+
| [                | > C -\> R C -\>  | > 41           | 0.9.39 |
| CreateLeaseSet2M | > R              | >              |        |
| essage](#createl |                  | > :   1        |        |
| easeset2message) |                  |                |        |
| [CreateSessio    |                  |                |        |
| nMessage](#creat |                  |                |        |
| esessionmessage) |                  |                |        |
+------------------+------------------+----------------+--------+
| [DestLo          | > C -\> R        | > 34           | 0.7    |
| okupMessage](#de |                  |                |        |
| stlookupmessage) |                  |                |        |
+------------------+------------------+----------------+--------+
| [Dest            | > R -\> C C -\>  | > 35           | 0.7    |
| ReplyMessage](#d | > R bidir.       | >              |        |
| estreplymessage) |                  | > :   3        |        |
| [DestroySession  |                  | >              |        |
| Message](#destro |                  | > 30           |        |
| ysessionmessage) |                  |                |        |
| [Discon          |                  |                |        |
| nectMessage](#di |                  |                |        |
| sconnectmessage) |                  |                |        |
+------------------+------------------+----------------+--------+
| [GetBan          | > C -\> R C -\>  | > 8 32         | 0.7.2  |
| dwidthLimitsMess | > R              |                |        |
| age](#getbandwid |                  |                |        |
| thlimitsmessage) |                  |                |        |
| [                |                  |                |        |
| GetDateMessage]( |                  |                |        |
| #getdatemessage) |                  |                |        |
+------------------+------------------+----------------+--------+
| [HostLo          | > C -\> R        | > 38           | 0.9.11 |
| okupMessage](#ho |                  |                |        |
| stlookupmessage) |                  |                |        |
+------------------+------------------+----------------+--------+
| [Host            | > R -\> C R -\>  | > 39 31 22 6 7 | 0.9.11 |
| ReplyMessage](#h | > C R -\> C C    |                |        |
| ostreplymessage) | > -\> R C -\> R  |                |        |
| [MessagePayload  |                  |                |        |
| Message](#messag |                  |                |        |
| epayloadmessage) |                  |                |        |
| [MessageStatu    |                  |                |        |
| sMessage](#messa |                  |                |        |
| gestatusmessage) |                  |                |        |
| [ReceiveM        |                  |                |        |
| essageBeginMessa |                  |                |        |
| ge](#receivemess |                  |                |        |
| agebeginmessage) |                  |                |        |
| [Rece            |                  |                |        |
| iveMessageEndMes |                  |                |        |
| sage](#receiveme |                  |                |        |
| ssageendmessage) |                  |                |        |
+------------------+------------------+----------------+--------+
| [Reconf          | > C -\> R bidir. | > 2 29 21      | 0.7.1  |
| igureSessionMess | > R -\> C        |                |        |
| age](#reconfigur |                  |                |        |
| esessionmessage) |                  |                |        |
| [ReportAb        |                  |                |        |
| useMessage](#rep |                  |                |        |
| ortabusemessage) |                  |                |        |
| [                |                  |                |        |
| RequestLeaseSetM |                  |                |        |
| essage](#request |                  |                |        |
| leasesetmessage) |                  |                |        |
+------------------+------------------+----------------+--------+
| [                | > R -\> C C -\>  | > 37           | 0.9.7  |
| RequestVariableL | > R              | >              |        |
| easeSetMessage]( |                  | > :   5        |        |
| #requestvariable |                  |                |        |
| leasesetmessage) |                  |                |        |
| [SendMess        |                  |                |        |
| ageMessage](#sen |                  |                |        |
| dmessagemessage) |                  |                |        |
+------------------+------------------+----------------+--------+
| [SendMe          | > C -\> R R -\>  | > 36 20 33     | 0.7.1  |
| ssageExpiresMess | > C R -\> C      |                |        |
| age](#sendmessag |                  |                |        |
| eexpiresmessage) |                  |                |        |
| [SessionStatu    |                  |                |        |
| sMessage](#sessi |                  |                |        |
| onstatusmessage) |                  |                |        |
| [                |                  |                |        |
| SetDateMessage]( |                  |                |        |
| #SetDateMessage) |                  |                |        |
+------------------+------------------+----------------+--------+

### BandwidthLimitsMessage {#msg-BandwidthLimits}

#### Description

Tell the client what the bandwidth limits are.

Sent from Router to Client in response to a
[GetBandwidthLimitsMessage](#getbandwidthlimitsmessage).

#### Contents

1.  4 byte \[Integer\] Client inbound limit (KBps)
2.  4 byte \[Integer\] Client outbound limit (KBps)
3.  4 byte \[Integer\] Router inbound limit (KBps)
4.  4 byte \[Integer\] Router inbound burst limit (KBps)
5.  4 byte \[Integer\] Router outbound limit (KBps)
6.  4 byte \[Integer\] Router outbound burst limit (KBps)
7.  4 byte \[Integer\] Router burst time (seconds)
8.  Nine 4-byte \[Integer\] (undefined)

#### Notes

Currently, the client limits are the only values set, and are actually
the router limits. All the values labeled as router limits are always 0.
As of release 0.7.2.

### BlindingInfoMessage {#msg-BlindingInfo}

#### Description

Advise the router that a Destination is blinded, with optional lookup
password and optional private key for decryption. See proposals 123 and
149 for details.

The router needs to know if a destination is blinded. If it is blinded
and uses a secret or per-client authentication, it needs to have that
information as well.

A Host Lookup of a new-format b32 address (\"b33\") tells the router
that the address is blinded, but there\'s no mechanism to pass the
secret or private key to the router in the Host Lookup message. While we
could extend the Host Lookup message to add that information, it\'s
cleaner to define a new message.

This message provides a programmatic way for the client to tell the
router. Otherwise, the user would have to manually configure each
destination.

#### Usage

Before a client sends a message to a blinded destination, it must either
lookup the \"b33\" in a Host Lookup message, or send a Blinding Info
message. If the blinded destination requires a secret or per-client
authentication, the client must send a Blinding Info message.

The router does not send a reply to this message. Sent from Client to
Router.

#### Contents

1.  [Session ID](#session-id)
2.  1 byte \[Integer\] Flags

> -   Bit order: 76543210
> -   Bit 0: 0 for everybody, 1 for per-client
> -   Bits 3-1: Authentication scheme, if bit 0 is set to 1 for
>     per-client, otherwise 000
>     -   000: DH client authentication (or no per-client
>         authentication)
>     -   001: PSK client authentication
> -   Bit 4: 1 if secret required, 0 if no secret required
> -   Bits 7-5: Unused, set to 0 for future compatibility

3.  1 byte \[Integer\] Endpoint type

> -   Type 0 is a \[Hash\]
> -   Type 1 is a hostname \[String\]
> -   Type 2 is a \[Destination\]
> -   Type 3 is a Sig Type and \[SigningPublicKey\]

4.  2 byte \[Integer\] Blinded Signature Type
5.  4 byte \[Integer\] Expiration Seconds since epoch
6.  Endpoint: Data as specified, one of

> -   Type 0: 32 byte \[Hash\]
>
> -   Type 1: host name \[String\]
>
> -   Type 2: binary \[Destination\]
>
> -   
>
>     Type 3: 2 byte \[Integer\] signature type, followed by
>
>     :   \[SigningPublicKey\] (length as implied by sig type)

7.  \[PrivateKey\] Decryption key Only present if flag bit 0 is set to
    1. A 32-byte ECIES\_X25519 private key, little-endian
8.  \[String\] Lookup Password Only present if flag bit 4 is set to 1.

#### Notes

-   As of release 0.9.43.
-   The Hash endpoint type is probably not useful unless the router can
    do a reverse lookup in the address book to get the Destination.
-   The hostname endpoint type is probably not useful unless the router
    can do a lookup in the address book to get the Destination.

### CreateLeaseSetMessage {#msg-CreateLeaseSet}

#### Description

This message is sent in response to a
[RequestLeaseSetMessage](#requestleasesetmessage) or
[RequestVariableLeaseSetMessage](#requestvariableleasesetmessage) and
contains all of the \[Lease\] structures that should be published to the
I2NP Network Database.

Sent from Client to Router.

#### Contents

1.  [Session ID](#session-id)
2.  DSA \[SigningPrivateKey\] or 20 bytes ignored
3.  \[PrivateKey\]
4.  \[LeaseSet\]

#### Notes

The SigningPrivateKey matches the \[SigningPublicKey\] from within the
LeaseSet, only if the signing key type is DSA. This is for LeaseSet
revocation, which is unimplemented and is unlikely to ever be
implemented. If the signing key type is not DSA, this field contains 20
bytes of random data. The length of this field is always 20 bytes, it
does not ever equal the length of a non-DSA signing private key.

The PrivateKey matches the \[PublicKey\] from the LeaseSet. The
PrivateKey is necessary for decrypting garlic routed messages.

Revocation is unimplemented. Connection to multiple routers is
unimplemented in any client library.

### CreateLeaseSet2Message {#msg-CreateLeaseSet2}

#### Description

This message is sent in response to a
[RequestLeaseSetMessage](#requestleasesetmessage) or
[RequestVariableLeaseSetMessage](#requestvariableleasesetmessage) and
contains all of the \[Lease\] structures that should be published to the
I2NP Network Database.

Sent from Client to Router. Since release 0.9.39. Per-client
authentication for EncryptedLeaseSet supported as of 0.9.41.
MetaLeaseSet is not yet supported via I2CP. See proposal 123 for more
information.

#### Contents

1.  [Session ID](#session-id)
2.  One byte type of lease set to follow.

> -   Type 1 is a \[LeaseSet\]
> -   Type 3 is a \[LeaseSet2\]
> -   Type 5 is a \[EncryptedLeaseSet\]
> -   Type 7 is a \[MetaLeaseSet\]

3.  \[LeaseSet\] or \[LeaseSet2\] or \[EncryptedLeaseSet\] or
    \[MetaLeaseSet\]
4.  One byte number of private keys to follow.
5.  \[PrivateKey\] list. One for each public key in the lease set, in
    the same order. (Not present for Meta LS2)

> -   Encryption type (2 byte \[Integer\] )
> -   Encryption key length (2 byte \[Integer\] )
> -   Encryption \[PrivateKey\] (number of bytes specified)

#### Notes

The PrivateKeys match each of the \[PublicKey\] from the LeaseSet. The
PrivateKeys are necessary for decrypting garlic routed messages.

The contents and format for EncryptedLeaseSet are preliminary and
subject to change. See proposal 123 for more information.

The contents and format for MetaLeaseSet are preliminary and subject to
change. There is no protocol specified for administration of multiple
routers. See proposal 123 for more information.

The signing private key, previously defined for revocation and unused,
is not present in LS2.

Preliminary version with message type 40 was in 0.9.38 but the format
was changed. Type 40 is abandoned and is unsupported. Type 41 not valid
until 0.9.39.

### CreateSessionMessage {#msg-CreateSession}

#### Description

This message is sent from a client to initiate a session, where a
session is defined as a single Destination\'s connection to the network,
to which all messages for that Destination will be delivered and from
which all messages that Destination sends to any other Destination will
be sent through.

Sent from Client to Router. The router responds with a
[SessionStatusMessage](#sessionstatusmessage).

#### Contents

1.  [Session Config](#session-config)

#### Notes

-   This is the second message sent by the client. Previously the client
    sent a [GetDateMessage](#getdatemessage) and received a
    [SetDateMessage](#SetDateMessage) response.
-   If the Date in the Session Config is too far (more than +/- 30
    seconds) from the router\'s current time, the session will be
    rejected.
-   If there is already a session on the router for this Destination,
    the session will be rejected.
-   The \[Mapping\] in the Session Config must be sorted by key so that
    the signature will be validated correctly in the router.

### DestLookupMessage {#msg-DestLookup}

#### Description

Sent from Client to Router. The router responds with a
[DestReplyMessage](#destreplymessage).

#### Contents

1.  SHA-256 \[Hash\]

#### Notes

As of release 0.7.

As of release 0.8.3, multiple outstanding lookups are supported, and
lookups are supported in both I2PSimpleSession and in standard sessions.

[HostLookupMessage](#hostlookupmessage) is preferred as of release
0.9.11.

### DestReplyMessage {#msg-DestReply}

#### Description

Sent from Router to Client in response to a
[DestLookupMessage](#destlookupmessage).

#### Contents

1.  \[Destination\] on success, or \[Hash\] on failure

#### Notes

As of release 0.7.

As of release 0.8.3, the requested Hash is returned if the lookup
failed, so that the client may have multiple lookups outstanding and
correlate the replies to the lookups. To correlate a Destination
response with a request, take the Hash of the Destination. Prior to
release 0.8.3, the response was empty on failure.

### DestroySessionMessage {#msg-DestroySession}

#### Description

This message is sent from a client to destroy a session.

Sent from Client to Router. The router responds with a
[SessionStatusMessage](#sessionstatusmessage).

#### Contents

1.  [Session ID](#session-id)

#### Notes

The router at this point should release all resources related to the
session.

### DisconnectMessage {#msg-Disconnect}

#### Description

Tell the other party that there are problems and the current connection
is about to be destroyed. This does not necessarily end a session. Sent
either from router to client or from client to router.

#### Contents

1.  Reason \[String\]

#### Notes

Only implemented in the router-to-client direction. Disconnecting
probably does end a session, in practice.

### GetBandwidthLimitsMessage {#msg-GetBandwidthLimits}

#### Description

Request that the router state what its current bandwidth limits are.

Sent from Client to Router. The router responds with a
[BandwidthLimitsMessage](#bandwidthlimitsmessage).

#### Contents

*None*

#### Notes

As of release 0.7.2.

As of release 0.8.3, supported in both I2PSimpleSession and in standard
sessions.

### GetDateMessage {#msg-GetDate}

#### Description

Sent from Client to Router. The router responds with a
[SetDateMessage](#SetDateMessage).

#### Contents

1.  I2CP Version \[String\]
2.  Authentication \[Mapping\] (optional, as of release 0.9.11)

#### Notes

-   Generally the first message sent by the client after sending the
    protocol version byte.
-   The version string is included as of release 0.8.7. This is only
    useful if the client and router are not in the same JVM. If it is
    not present, the client is version 0.8.6 or earlier.
-   As of release 0.9.11, the authentication \[Mapping\] may be
    included, with the keys i2cp.username and i2cp.password. The Mapping
    need not be sorted as this message is not signed. Prior to and
    including 0.9.10, authentication is included in the [Session
    Config](#session-config) Mapping, and no authentication is enforced
    for [GetDateMessage](#getdatemessage),
    [GetBandwidthLimitsMessage](#getbandwidthlimitsmessage), or
    [DestLookupMessage](#destlookupmessage). When enabled,
    authentication via [GetDateMessage](#getdatemessage) is required
    before any other messages as of release 0.9.16. This is only useful
    outside router context. This is an incompatible change, but will
    only affect sessions outside router context with authentication,
    which should be rare.

### HostLookupMessage {#msg-HostLookup}

#### Description

Sent from Client to Router. The router responds with a
[HostReplyMessage](#hostreplymessage).

This replaces the [DestLookupMessage](#destlookupmessage) and adds a
request ID, a timeout, and host name lookup support. As it also supports
Hash lookups, it may be used for all lookups if the router supports it.
For host name lookups, the router will query its context\'s naming
service. This is only useful if the client is outside the router\'s
context. Inside router context, the client should query the naming
service itself, which is much more efficient.

#### Contents

1.  [Session ID](#session-id)
2.  4 byte \[Integer\] request ID
3.  4 byte \[Integer\] timeout (ms)
4.  1 byte \[Integer\] request type
5.  SHA-256 \[Hash\] or host name \[String\]

#### Notes

-   As of release 0.9.11. Use [DestLookupMessage](#destlookupmessage)
    for older routers.
-   The session ID and request ID will be returned in the
    [HostReplyMessage](#hostreplymessage). Use 0xFFFF for the session ID
    if there is no session.
-   Timeout is useful for Hash lookups. Recommended minimum 10,000 (10
    sec.). In the future it may also be useful for remote naming service
    lookups. The value may be not be honored for local host name
    lookups, which should be fast.
-   The request type is 0 for Hash and 1 for host name.
-   Base 32 host name lookup is supported but it is preferred to convert
    it to a Hash first.

### HostReplyMessage {#msg-HostReply}

#### Description

Sent from Router to Client in response to a
[HostLookupMessage](#hostlookupmessage).

#### Contents

1.  [Session ID](#session-id)
2.  4 byte \[Integer\] request ID
3.  1 byte \[Integer\] result code

> -   0: Success
> -   1: Failure
> -   2: Lookup password required (as of 0.9.43)
> -   3: Private key required (as of 0.9.43)
> -   4: Lookup password and private key required (as of 0.9.43)
> -   5: Leaseset decryption failure (as of 0.9.43)

4.  \[Destination\], only present if result code is zero.

#### Notes

-   As of release 0.9.11. See [HostLookupMessage](#hostlookupmessage)
    notes.
-   The session ID and request ID are those from the
    [HostLookupMessage](#hostlookupmessage).
-   The result code is 0 for success, 1-255 for failure. 1 indicates a
    generic failure. As of 0.9.43, the additional failure codes 2-5 were
    defined to support extended errors for \"b33\" lookups. See
    proposals 123 and 149 for additional information.

### MessagePayloadMessage {#msg-MessagePayload}

#### Description

Deliver the payload of a message to the client.

Sent from Router to Client. If i2cp.fastReceive=true, which is not the
default, the client responds with a
[ReceiveMessageEndMessage](#receivemessageendmessage).

#### Contents

1.  [Session ID](#session-id)
2.  [Message ID](#message-id)
3.  [Payload](#payload)

#### Notes

### MessageStatusMessage {#msg-MessageStatus}

#### Description

Notify the client of the delivery status of an incoming or outgoing
message. Sent from Router to Client. If this message indicates that an
incoming message is available, the client responds with a
[ReceiveMessageBeginMessage](#receivemessagebeginmessage). For an
outgoing message, this is a response to a
[SendMessageMessage](#sendmessagemessage) or
[SendMessageExpiresMessage](#sendmessageexpiresmessage).

#### Contents

1.  [Session ID](#session-id)
2.  [Message ID](#message-id) generated by the router
3.  1 byte \[Integer\] status
4.  4 byte \[Integer\] size
5.  4 byte \[Integer\] nonce previously generated by the client

#### Notes

Through version 0.9.4, the known status values are 0 for message is
available, 1 for accepted, 2 for best effort succeeded, 3 for best
effort failed, 4 for guaranteed succeeded, 5 for guaranteed failed. The
size Integer specifies the size of the available message and is only
relevant for status = 0. Even though guaranteed is unimplemented, (best
effort is the only service), the current router implementation uses the
guaranteed status codes, not the best effort codes.

As of router version 0.9.5, additional status codes are defined, however
they are not necessarily implemented. See \[MSM-JAVADOCS\] for details.
All status codes:

+-------------+---------------+------------------+------------------+
| Status Code | As Of Release | Name             | Description      |
+=============+===============+==================+==================+
| > 0         |               | Available        | For incoming     |
| >           |               |                  | messages only.   |
| > 1         |               | Accepted         | All other status |
| >           |               |                  | codes below are  |
| > 2         |               | Best Effort      | for outgoing     |
| >           |               | Success          | messages.        |
| > 3         |               |                  |                  |
| >           |               | Best Effort      | The included     |
| > 4         |               | Failure          | size is the size |
| >           |               |                  | in bytes of the  |
| > 5         |               | Guaranteed       | available        |
|             |               | Success          | message.         |
|             |               |                  |                  |
|             |               | Guaranteed       | This is unused   |
|             |               | Failure          | in \"fast        |
|             |               |                  | receive\" mode,  |
|             |               |                  | which is the     |
|             |               |                  | default as of    |
|             |               |                  | release 0.9.4.   |
|             |               |                  |                  |
|             |               |                  | Outgoing message |
|             |               |                  | accepted by the  |
|             |               |                  | local router for |
|             |               |                  | delivery. The    |
|             |               |                  | included nonce   |
|             |               |                  | matches the      |
|             |               |                  | nonce in the     |
|             |               |                  | [SendMessa       |
|             |               |                  | geMessage](#send |
|             |               |                  | messagemessage), |
|             |               |                  | and the included |
|             |               |                  | Message ID will  |
|             |               |                  | be used for      |
|             |               |                  | subsequent       |
|             |               |                  | success or       |
|             |               |                  | failure          |
|             |               |                  | notification.    |
|             |               |                  |                  |
|             |               |                  | Probable success |
|             |               |                  | (unused)         |
|             |               |                  |                  |
|             |               |                  | Probable failure |
|             |               |                  |                  |
|             |               |                  | Probable success |
|             |               |                  |                  |
|             |               |                  | Generic failure, |
|             |               |                  | specific cause   |
|             |               |                  | unknown. May not |
|             |               |                  | really be a      |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 6         | > 0.9.5       | Local Success    | Local delivery   |
|             |               |                  | successful. The  |
|             |               |                  | destination was  |
|             |               |                  | another client   |
|             |               |                  | on the same      |
|             |               |                  | router.          |
+-------------+---------------+------------------+------------------+
| > 7         | > 0.9.5       | Local Failure    | Local delivery   |
|             |               |                  | failure. The     |
|             |               |                  | destination was  |
|             |               |                  | another client   |
|             |               |                  | on the same      |
|             |               |                  | router.          |
+-------------+---------------+------------------+------------------+
| > 8         | > 0.9.5       | Router Failure   | The local router |
|             |               |                  | is not ready,    |
|             |               |                  | has shut down,   |
|             |               |                  | or has major     |
|             |               |                  | problems.        |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 9         | > 0.9.5       | Network Failure  | The local        |
|             |               |                  | computer         |
|             |               |                  | apparently has   |
|             |               |                  | no network       |
|             |               |                  | connectivity at  |
|             |               |                  | all.             |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 10        | > 0.9.5       | Bad Session      | The I2CP session |
|             |               |                  | is invalid or    |
|             |               |                  | closed.          |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 11        | > 0.9.5       | Bad Message      | The message      |
|             |               |                  | payload is       |
|             |               |                  | invalid or       |
|             |               |                  | zero-length or   |
|             |               |                  | too big.         |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 12        | > 0.9.5       | Bad Options      | Something is     |
|             |               |                  | invalid in the   |
|             |               |                  | message options, |
|             |               |                  | or the           |
|             |               |                  | expiration is in |
|             |               |                  | the past or too  |
|             |               |                  | far in the       |
|             |               |                  | future.          |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 13        | > 0.9.5       | Overflow Failure | Some queue or    |
|             |               |                  | buffer in the    |
|             |               |                  | router is full   |
|             |               |                  | and the message  |
|             |               |                  | was dropped.     |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 14        | > 0.9.5       | Message Expired  | The message      |
|             |               |                  | expired before   |
|             |               |                  | it could be      |
|             |               |                  | sent.            |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 15        | > 0.9.5       | Bad Local        | The client has   |
|             |               | Leaseset         | not yet signed a |
|             |               |                  | \[LeaseSet\], or |
|             |               |                  | the local keys   |
|             |               |                  | are invalid, or  |
|             |               |                  | it has expired,  |
|             |               |                  | or it does not   |
|             |               |                  | have any tunnels |
|             |               |                  | in it.           |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 16        | > 0.9.5       | No Local Tunnels | Local problems.  |
|             |               |                  | No outbound      |
|             |               |                  | tunnel to send   |
|             |               |                  | through, or no   |
|             |               |                  | inbound tunnel   |
|             |               |                  | if a reply is    |
|             |               |                  | required.        |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 17        | > 0.9.5       | Unsupported      | The certs or     |
|             |               | Encryption       | options in the   |
|             |               |                  | \[Destination\]  |
|             |               |                  | or its           |
|             |               |                  | \[LeaseSet\]     |
|             |               |                  | indicate that it |
|             |               |                  | uses an          |
|             |               |                  | encryption       |
|             |               |                  | format that we   |
|             |               |                  | don\'t support,  |
|             |               |                  | so we can\'t     |
|             |               |                  | talk to it.      |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 18        | > 0.9.5       | Bad Destination  | Something is     |
|             |               |                  | wrong with the   |
|             |               |                  | far-end          |
|             |               |                  | \[Destination\]. |
|             |               |                  | Bad format,      |
|             |               |                  | unsupported      |
|             |               |                  | options,         |
|             |               |                  | certificates,    |
|             |               |                  | etc.             |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 19        | > 0.9.5       | Bad Leaseset     | We got the       |
|             |               |                  | far-end          |
|             |               |                  | \[LeaseSet\] but |
|             |               |                  | something        |
|             |               |                  | strange is wrong |
|             |               |                  | with it.         |
|             |               |                  | Unsupported      |
|             |               |                  | options or       |
|             |               |                  | certificates, no |
|             |               |                  | tunnels, etc.    |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 20        | > 0.9.5       | Expired Leaseset | We got the       |
|             |               |                  | far-end          |
|             |               |                  | \[LeaseSet\] but |
|             |               |                  | it\'s expired    |
|             |               |                  | and we can\'t    |
|             |               |                  | get a new one.   |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 21        | > 0.9.5       | No Leaseset      | Could not find   |
|             |               |                  | the far-end      |
|             |               |                  | \[LeaseSet\].    |
|             |               |                  | This is a common |
|             |               |                  | failure,         |
|             |               |                  | equivalent to a  |
|             |               |                  | DNS lookup       |
|             |               |                  | failure.         |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+
| > 22        | > 0.9.41      | Meta Leaseset    | The far-end      |
|             |               |                  | destination\'s   |
|             |               |                  | lease set was a  |
|             |               |                  | meta lease set,  |
|             |               |                  | and cannot be    |
|             |               |                  | sent to. The     |
|             |               |                  | client should    |
|             |               |                  | request the meta |
|             |               |                  | lease set\'s     |
|             |               |                  | contents with a  |
|             |               |                  | Ho               |
|             |               |                  | stLookupMessage, |
|             |               |                  | and select one   |
|             |               |                  | of the hashes    |
|             |               |                  | contained within |
|             |               |                  | to look up and   |
|             |               |                  | send to.         |
|             |               |                  |                  |
|             |               |                  | This is a        |
|             |               |                  | guaranteed       |
|             |               |                  | failure.         |
+-------------+---------------+------------------+------------------+

When status = 1 (accepted), the nonce matches the nonce in the
[SendMessageMessage](#sendmessagemessage), and the included Message ID
will be used for subsequent success or failure notification. Otherwise,
the nonce may be ignored.

### ReceiveMessageBeginMessage {#msg-ReceiveMessageBegin}

#### Description

Request the router to deliver a message that it was previously notified
of. Sent from Client to Router. The router responds with a
[MessagePayloadMessage](#messagepayloadmessage).

#### Contents

1.  [Session ID](#session-id)
2.  [Message ID]{.title-ref}

#### Notes

The [ReceiveMessageBeginMessage](#receivemessagebeginmessage) is sent as
a response to a [MessageStatusMessage](#messagestatusmessage) stating
that a new message is available for pickup. If the message id specified
in the [ReceiveMessageBeginMessage](#receivemessagebeginmessage) is
invalid or incorrect, the router may simply not reply, or it may send
back a [DisconnectMessage](#disconnectmessage).

This is unused in \"fast receive\" mode, which is the default as of
release 0.9.4.

### ReceiveMessageEndMessage {#msg-ReceiveMessageEnd}

#### Description

Tell the router that delivery of a message was completed successfully
and that the router can discard the message.

Sent from Client to Router.

#### Contents

1.  [Session ID](#session-id)
2.  [Message ID]{.title-ref}

#### Notes

The [ReceiveMessageEndMessage](#receivemessageendmessage) is sent after
a [MessagePayloadMessage](#messagepayloadmessage) fully delivers a
message\'s payload.

This is unused in \"fast receive\" mode, which is the default as of
release 0.9.4.

### ReconfigureSessionMessage {#msg-ReconfigureSession}

#### Description

Sent from Client to Router to update the session configuration. The
router responds with a [SessionStatusMessage](#sessionstatusmessage).

#### Contents

1.  [Session ID](#session-id)
2.  [Session Config](#session-config)

#### Notes

-   As of release 0.7.1.
-   If the Date in the Session Config is too far (more than +/- 30
    seconds) from the router\'s current time, the session will be
    rejected.
-   The \[Mapping\] in the Session Config must be sorted by key so that
    the signature will be validated correctly in the router.
-   Some configuration options may only be set in the
    [CreateSessionMessage](#createsessionmessage), and changes here will
    not be recognized by the router. Changes to tunnel options
    inbound.\* and outbound.\* are always recognized.

### ReportAbuseMessage {#msg-ReportAbuse}

#### Description

Tell the other party (client or router) that they are under attack,
potentially with reference to a particular MessageId. If the router is
under attack, the client may decide to migrate to another router, and if
a client is under attack, the router may rebuild its routers or banlist
some of the peers that sent it messages delivering the attack.

Sent either from router to client or from client to router.

#### Contents

1.  [Session ID](#session-id)
2.  1 byte \[Integer\] abuse severity (0 is minimally abusive, 255 being
    extremely abusive)
3.  Reason \[String\]
4.  [Message ID](#message-id)

#### Notes

Unused. Not fully implemented. Both router and client can generate a
[ReportAbuseMessage](#reportabusemessage), but neither has a handler for
the message when received.

### RequestLeaseSetMessage {#msg-RequestLeaseSet}

#### Description

Request that a client authorize the inclusion of a particular set of
inbound tunnels. Sent from Router to Client. The client responds with a
[CreateLeaseSetMessage](#createleasesetmessage).

#### Contents

1.  [Session ID](#session-id)
2.  1 byte \[Integer\] number of tunnels
3.  That many pairs of:
    1.  \[Hash\]
    2.  \[TunnelId\]
4.  End \[Date\]

#### Notes

This requests a \[LeaseSet\] with all \[Leases\] set to expire at the
same time. For client versions 0.9.7 or higher,
[RequestVariableLeaseSetMessage](#requestvariableleasesetmessage) is
preferred.

### RequestVariableLeaseSetMessage {#msg-RequestVariableLeaseSet}

#### Description

Request that a client authorize the inclusion of a particular set of
inbound tunnels.

Sent from Router to Client. The client responds with a
[CreateLeaseSetMessage](#createleasesetmessage).

#### Contents

1.  [Session ID](#session-id)
2.  1 byte \[Integer\] number of tunnels
3.  That many \[Leases\]

#### Notes

This requests a \[LeaseSet\] with an individual expiration time for each
\[Lease\].

As of release 0.9.7. For clients before that release, use
[RequestLeaseSetMessage](#requestleasesetmessage).

### SendMessageMessage {#msg-SendMessage}

#### Description

This is how a client sends a message (the payload) to the
\[Destination\]. The router will use a default expiration.

Sent from Client to Router. The router responds with a
[MessageStatusMessage](#messagestatusmessage).

#### Contents

1.  [Session ID](#session-id)
2.  \[Destination\]
3.  [Payload](#payload)
4.  4 byte \[Integer\] nonce

#### Notes

As soon as the [SendMessageMessage](#sendmessagemessage) arrives fully
intact, the router should return a
[MessageStatusMessage](#messagestatusmessage) stating that it has been
accepted for delivery. That message will contain the same nonce sent
here. Later on, based on the delivery guarantees of the session
configuration, the router may additionally send back another
[MessageStatusMessage](#messagestatusmessage) updating the status.

As of release 0.8.1, the router does not send either
[MessageStatusMessage](#messagestatusmessage) if
i2cp.messageReliability=none.

Prior to release 0.9.4, a nonce value of 0 was not allowed. As of
release 0.9.4, a nonce value of 0 is allowed, and tells to the router
that it should not send either
[MessageStatusMessage](#messagestatusmessage), i.e. it acts as if
i2cp.messageReliability=none for this message only.

Prior to release 0.9.14, a session with i2cp.messageReliability=none
could not be overridden on a per-message basis. As of release 0.9.14, in
a session with i2cp.messageReliability=none, the client may request
delivery of a [MessageStatusMessage](#messagestatusmessage) with the
delivery success or failure by setting the nonce to a nonzero value. The
router will not send the \"accepted\"
[MessageStatusMessage](#messagestatusmessage) but it will later send the
client a [MessageStatusMessage](#messagestatusmessage) with the same
nonce, and a success or failure value.

### SendMessageExpiresMessage {#msg-SendMessageExpires}

#### Description

Sent from Client to Router. Same as
[SendMessageMessage](#sendmessagemessage), except includes an expiration
and options.

#### Contents

1.  [Session ID](#session-id)
2.  \[Destination\]
3.  [Payload](#payload)
4.  4 byte \[Integer\] nonce
5.  2 bytes of flags (options)
6.  Expiration \[Date\] truncated from 8 bytes to 6 bytes

#### Notes

As of release 0.7.1.

In \"best effort\" mode, as soon as the SendMessageExpiresMessage
arrives fully intact, the router should return a MessageStatusMessage
stating that it has been accepted for delivery. That message will
contain the same nonce sent here. Later on, based on the delivery
guarantees of the session configuration, the router may additionally
send back another MessageStatusMessage updating the status.

As of release 0.8.1, the router does not send either Message Status
Message if i2cp.messageReliability=none.

Prior to release 0.9.4, a nonce value of 0 was not allowed. As of
release 0.9.4, a nonce value of 0 is allowed, and tells the router that
it should not send either Message Status Message, i.e. it acts as if
i2cp.messageReliability=none for this message only.

Prior to release 0.9.14, a session with i2cp.messageReliability=none
could not be overridden on a per-message basis. As of release 0.9.14, in
a session with i2cp.messageReliability=none, the client may request
delivery of a Message Status Message with the delivery success or
failure by setting the nonce to a nonzero value. The router will not
send the \"accepted\" Message Status Message but it will later send the
client a Message Status Message with the same nonce, and a success or
failure value.

#### Flags Field

As of release 0.8.4, the upper two bytes of the Date are redefined to
contain flags. The flags must default to all zeros for backward
compatibility. The Date will not encroach on the flags field until the
year 10889. The flags may be used by the application to provide hints to
the router as to whether a LeaseSet and/or ElGamal/AES Session Tags
should be delivered with the message. The settings will significantly
affect the amount of protocol overhead and the reliability of message
delivery. The individual flag bits are defined as follows, as of release
0.9.2. Definitions are subject to change. Use the SendMessageOptions
class to construct the flags.

Bit order: 15\...0

Bits 15-11

:   Unused, must be zero

Bits 10-9

:   Message Reliability Override (Unimplemented, to be removed).

+-------------+-------------------------------------------------------+
| Field value | Description                                           |
+=============+=======================================================+
| > 00        | Use session setting i2cp.messageReliability (default) |
+-------------+-------------------------------------------------------+
| > 01        | Use \"best effort\" message reliability for this      |
|             | message, overriding the session setting. The router   |
|             | will send one or more MessageStatusMessages in        |
|             | response.                                             |
|             |                                                       |
|             | Unused. Use a nonzero nonce value to override a       |
|             | session setting of \"none\".                          |
+-------------+-------------------------------------------------------+
| > 10        | Use \"guaranteed\" message reliability for this       |
|             | message, overriding the session setting. The router   |
|             | will send one or more MessageStatusMessages in        |
|             | response.                                             |
|             |                                                       |
|             | Unused. Use a nonzero nonce value to override a       |
|             | session setting of \"none\".                          |
+-------------+-------------------------------------------------------+
| > 11        | Unused. Use a nonce value of 0 to force \"none\" and  |
|             | override a session setting of \"best effort\" or      |
|             | \"guaranteed\".                                       |
+-------------+-------------------------------------------------------+

Bit 8

:   If 1, don\'t bundle a lease set in the garlic with this message. If
    0, the router may bundle a lease set at its discretion.

Bits 7-4

:   Low tag threshold. If there are less than this many tags available,
    send more. This is advisory and does not force tags to be delivered.

+-------------+----------------------------------+
| Field value | Tag threshold                    |
+=============+==================================+
| > 0000      | Use session key manager settings |
+-------------+----------------------------------+
| > 0001      | > 2                              |
+-------------+----------------------------------+
| > 0010      | > 3                              |
+-------------+----------------------------------+
| > 0011      | > 6                              |
+-------------+----------------------------------+
| > 0100      | > 9                              |
+-------------+----------------------------------+
| > 0101      | > 14                             |
+-------------+----------------------------------+
| > 0110      | > 20                             |
+-------------+----------------------------------+
| > 0111      | > 27                             |
+-------------+----------------------------------+
| > 1000      | > 35                             |
+-------------+----------------------------------+
| > 1001      | > 45                             |
+-------------+----------------------------------+
| > 1010      | > 57                             |
+-------------+----------------------------------+
| > 1011      | > 72                             |
+-------------+----------------------------------+
| > 1100      | > 92                             |
+-------------+----------------------------------+
| > 1101      | > 117                            |
+-------------+----------------------------------+
| > 1110      | > 147                            |
+-------------+----------------------------------+
| > 1111      | > 192                            |
+-------------+----------------------------------+

Bits 3-0

:   Number of tags to send if required. This is advisory and does not
    force tags to be delivered.

+-------------+----------------------------------+
| Field value | Tags to send                     |
+=============+==================================+
| > 0000      | Use session key manager settings |
+-------------+----------------------------------+
| > 0001      | > 2                              |
+-------------+----------------------------------+
| > 0010      | > 4                              |
+-------------+----------------------------------+
| > 0011      | > 6                              |
+-------------+----------------------------------+
| > 0100      | > 8                              |
+-------------+----------------------------------+
| > 0101      | > 12                             |
+-------------+----------------------------------+
| > 0110      | > 16                             |
+-------------+----------------------------------+
| > 0111      | > 24                             |
+-------------+----------------------------------+
| > 1000      | > 32                             |
+-------------+----------------------------------+
| > 1001      | > 40                             |
+-------------+----------------------------------+
| > 1010      | > 51                             |
+-------------+----------------------------------+
| > 1011      | > 64                             |
+-------------+----------------------------------+
| > 1100      | > 80                             |
+-------------+----------------------------------+
| > 1101      | > 100                            |
+-------------+----------------------------------+
| > 1110      | > 125                            |
+-------------+----------------------------------+
| > 1111      | > 160                            |
+-------------+----------------------------------+

### SessionStatusMessage {#msg-SessionStatus}

#### Description

Instruct the client as to the status of its session.

Sent from Router to Client, possibly in response to a
[CreateSessionMessage](#createsessionmessage),
[ReconfigureSessionMessage](#reconfiguresessionmessage), or
[DestroySessionMessage](#destroysessionmessage).

#### Contents

1.  [Session ID](#session-id)
2.  1 byte \[Integer\] status

+--------+--------+-----------+-------------------------------------+
| Status | Since  | Name      | Definition                          |
+========+========+===========+=====================================+
| > 0    |        | Destroyed | The session with the given ID is    |
| >      |        |           | terminated. May be a response to a  |
| > 1    |        | Created   | [DestroySessi                       |
| >      |        |           | onMessage](#destroysessionmessage). |
| > 2    |        | Updated   |                                     |
| >      |        |           | In response to a                    |
| > 3    |        | Invalid   | [CreateSess                         |
|        |        |           | ionMessage](#createsessionmessage), |
|        |        |           | a new session with the given ID is  |
|        |        |           | now active.                         |
|        |        |           |                                     |
|        |        |           | In response to a                    |
|        |        |           | [ReconfigureSessionMe               |
|        |        |           | ssage](#reconfiguresessionmessage), |
|        |        |           | an existing session with the given  |
|        |        |           | ID has been reconfigured.           |
|        |        |           |                                     |
|        |        |           | In response to a                    |
|        |        |           | [CreateSess                         |
|        |        |           | ionMessage](#createsessionmessage), |
|        |        |           | the configuration is invalid. The   |
|        |        |           | included session ID should be       |
|        |        |           | ignored.                            |
|        |        |           |                                     |
|        |        |           | In response to a                    |
|        |        |           | [ReconfigureSessionMe               |
|        |        |           | ssage](#reconfiguresessionmessage), |
|        |        |           | the new configuration is invalid    |
|        |        |           | for the session with the given ID.  |
+--------+--------+-----------+-------------------------------------+
| > 4    | 0.9.12 | Refused   | In response to a                    |
|        |        |           | [CreateSess                         |
|        |        |           | ionMessage](#createsessionmessage), |
|        |        |           | the router was unable to create the |
|        |        |           | session, perhaps due to limits      |
|        |        |           | being exceeded. The included        |
|        |        |           | session ID should be ignored.       |
+--------+--------+-----------+-------------------------------------+

#### Notes

Status values are defined above. If the status is Created, the Session
ID is the identifier to be used for the rest of the session.

### Set Date[]{#msg-SetDate} {#SetDateMessage}

#### Description

The current date and time. Sent from Router to Client as a part of the
initial handshake. As of release 0.9.20, may also be sent at any time
after the handshake to notify the client of a clock shift.

#### Contents

1.  \[Date\]
2.  I2CP Version \[String\]

#### Notes

This is generally the first message sent by the router. The version
string is included as of release 0.8.7. This is only useful if the
client and router are not in the same JVM. If it is not present, the
router is version 0.8.6 or earlier.

Additional SetDate messages will not be sent to clients in the same JVM.

References
----------

\[Date\]

:   <https://geti2p.net/spec/common-structures#type-date>

\[Destination\]

:   <https://geti2p.net/spec/common-structures#struct-destination>

\[EncryptedLeaseSet\]

:   <https://geti2p.net/spec/common-structures#struct-encryptedleaseset>

\[Hash\]

:   <https://geti2p.net/spec/common-structures#type-hash>

\[I2CP\]

:   <https://geti2p.net/en/docs/protocol/i2cp>

\[I2CP-FORMAT\]

:   <https://geti2p.net/en/docs/protocol/i2cp#format>

\[I2CP-OPTIONS\]

:   <https://geti2p.net/en/docs/protocol/i2cp#options>

\[I2CP-JAVADOCS\]

:   <http://echelon.i2p/javadoc/net/i2p/data/i2cp/package-summary.html>

\[Integer\]

:   <https://geti2p.net/spec/common-structures#type-integer>

\[Leases\] \[Lease\]
<https://geti2p.net/spec/common-structures#struct-lease>

\[LeaseSet\]

:   <https://geti2p.net/spec/common-structures#struct-leaseset>

\[LeaseSet2\]

:   <https://geti2p.net/spec/common-structures#struct-leaseset2>

\[Mapping\]

:   <https://geti2p.net/spec/common-structures#type-mapping>

\[MetaLeaseSet\]

:   <https://geti2p.net/spec/common-structures#struct-metaleaseset>

\[MSM-JAVADOCS\]

:   <http://echelon.i2p/javadoc/net/i2p/data/i2cp/MessageStatusMessage.html>

\[PrivateKey\]

:   <https://geti2p.net/spec/common-structures#type-privatekey>

\[PublicKey\]

:   <https://geti2p.net/spec/common-structures#type-publickey>

\[RouterIdentity\]

:   <https://geti2p.net/spec/common-structures#struct-routeridentity>

\[Signature\]

:   <https://geti2p.net/spec/common-structures#type-signature>

\[SigningPrivateKey\]

:   <https://geti2p.net/spec/common-structures#type-signingprivatekey>

\[SigningPublicKey\]

:   <https://geti2p.net/spec/common-structures#type-signingpublickey>

\[String\]

:   <https://geti2p.net/spec/common-structures#type-string>

\[TunnelId\]

:   <https://geti2p.net/spec/common-structures#type-tunnelid>
