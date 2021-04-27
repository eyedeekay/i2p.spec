---
title: "I2np"
date: 2021-04-27T14:39:35-04:00
draft: true
---

I2NP Specification
==================

Category: Protocols Last updated: 2021-01 Accurate for: 0.9.49

Overview
--------

The I2P Network Protocol (I2NP), which is sandwiched between I2CP and
the various I2P transport protocols, manages the routing and mixing of
messages between routers, as well as the selection of what transports to
use when communicating with a peer for which there are multiple common
transports supported.

Protocol Versions {#versions}
-----------------

All routers must publish their I2NP protocol version in the
\"router.version\" field in the RouterInfo properties. This version
field indicates their level of support for various I2NP protocol
features, and is not necessarily the actual router version.

If alternative (non-Java) routers wish to publish any version
information about the actual router implementation, they must do so in
another property. Versions other than those listed below are allowed.
Support will be determined through a numeric comparison; for example,
0.9.13 implies support for 0.9.12 features. Note that the
\"coreVersion\" property is not used for determination of the I2NP
protocol version.

A basic summary of the I2NP protocol versions is as follows. For
details, see below.

+----------------+----------------------------------------------------+
| Version        | Required I2NP Features                             |
+================+====================================================+
| > 0.9.49       | Garlic messages to ECIES-X25519 routers            |
+----------------+----------------------------------------------------+
| > 0.9.48       | ECIES-X25519 Routers                               |
|                |                                                    |
|                | ECIES-X25519 Build Request/Response records        |
+----------------+----------------------------------------------------+
| > 0.9.46       | DatabaseLookup flag bit 4 for AEAD reply           |
+----------------+----------------------------------------------------+
| > 0.9.44       | ECIES-X25519 keys in LeaseSet2                     |
+----------------+----------------------------------------------------+
| > 0.9.40       | MetaLeaseSet may be sent in a DSM                  |
+----------------+----------------------------------------------------+
| > 0.9.39       | EncryptedLeaseSet may be sent in a DSM             |
|                |                                                    |
|                | RedDSA\_SHA512\_Ed25519 signature type supported   |
|                | for destinations and leasesets                     |
+----------------+----------------------------------------------------+
| > 0.9.38       | DSM type bits 3-0 now contain the type; LeaseSet2  |
|                | may be sent in a DSM                               |
+----------------+----------------------------------------------------+
| > 0.9.36       | NTCP2 transport support (if advertised in router   |
|                | address)                                           |
|                |                                                    |
|                | Minimum peers will build tunnels through, as of    |
|                | 0.9.46                                             |
+----------------+----------------------------------------------------+
| > 0.9.28       | RSA sig types disallowed                           |
|                |                                                    |
|                | Minimum floodfill peers will send DSM to, as of    |
|                | 0.9.34                                             |
+----------------+----------------------------------------------------+
| > 0.9.18       | DSM type bits 7-1 ignored                          |
+----------------+----------------------------------------------------+
| > 0.9.16       | RI key certs / ECDSA and EdDSA sig types           |
|                |                                                    |
|                | Note: RSA sig types also supported as of this      |
|                | version, but currently unused                      |
|                |                                                    |
|                | DLM lookup types (DLM flag bits 3-2)               |
|                |                                                    |
|                | Minimum version compatible with vast majority of   |
|                | current network, since routers are now using the   |
|                | EdDSA sig type.                                    |
+----------------+----------------------------------------------------+
| > 0.9.15       | Dest/LS key certs w/ EdDSA Ed25519 sig type (if    |
|                | floodfill)                                         |
+----------------+----------------------------------------------------+
| > 0.9.12       | Dest/LS key certs w/ ECDSA P-256, P-384, and P-521 |
|                | sig types (if floodfill)                           |
|                |                                                    |
|                | Note: RSA sig types also supported as of this      |
|                | version, but currently unused                      |
|                |                                                    |
|                | Nonzero expiration allowed in RouterAddress        |
+----------------+----------------------------------------------------+
| > 0.9.7        | Encrypted DSM/DSRM replies supported (DLM flag bit |
|                | 1) (if floodfill)                                  |
+----------------+----------------------------------------------------+
| > 0.9.6        | Nonzero DLM flag bits 7-1 allowed                  |
+----------------+----------------------------------------------------+
| > 0.9.3        | Requires zero expiration in RouterAddress          |
+----------------+----------------------------------------------------+
| > 0.9          | Supports up to 16 leases in a DSM LS store (6      |
|                | previously)                                        |
+----------------+----------------------------------------------------+
| > 0.7.12       | VTBM and VTBRM message support                     |
+----------------+----------------------------------------------------+
| > 0.7.10       | Floodfill supports encrypted DSM stores            |
+----------------+----------------------------------------------------+
| 0.7.9 or lower | All messages and features not listed above         |
+----------------+----------------------------------------------------+
| > 0.6.1.10     | TBM and TBRM messages introduced                   |
|                |                                                    |
|                | Minimum version compatible with current network    |
+----------------+----------------------------------------------------+

Note that there are also transport-related features and compatibility
issues; see the NTCP and SSU transport documentation for details.

Common structures {#structures}
-----------------

The following structures are elements of multiple I2NP messages. They
are not complete messages.

### I2NP message header {#struct-I2NPMessageHeader}

#### Description

Common header to all I2NP messages, which contains important information
like a checksum, expiration date, etc.

#### Contents

1 byte \[Integer\] specifying the type of this message, followed by a 4
byte \[Integer\] specifying the message-id. After that there is an
expiration \[Date\], followed by a 2 byte \[Integer\] specifying the
length of the message payload, followed by a \[Hash\], which is
truncated to the first byte. After that the actual message data follows.

> Standard (16 bytes):
>
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
> msg\_id \| expiration
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> size +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> Short (SSU, 5 bytes):
>
>   ------ ------ -------- ------- ----
>   type   shor   t\_exp   irati   on
>
>   ------ ------ -------- ------- ----
>
> Short (NTCP2, 9 bytes):
>
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
> msg\_id \|
> short\_expira-+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
> tion\| +\-\-\--+
>
> type :: \[Integer\]
>
> :   length -\> 1 byte purpose -\> identifies the message type (see
>     table below)
>
> msg\_id :: \[Integer\]
>
> :   length -\> 4 bytes purpose -\> uniquely identifies this message
>     (for some time at least) This is usually a locally-generated
>     random number, but for outgoing tunnel build messages it may be
>     derived from the incoming message. See below.
>
> expiration :: \[Date\]
>
> :   8 bytes date this message will expire
>
> short\_expiration :: \[Integer\]
>
> :   4 bytes date this message will expire (seconds since the epoch)
>
> size :: \[Integer\]
>
> :   length -\> 2 bytes purpose -\> length of the payload
>
> chks :: \[Integer\]
>
> :   length -\> 1 byte purpose -\> checksum of the payload SHA256 hash
>     truncated to the first byte
>
> data ::
>
> :   length -\> \$size bytes purpose -\> actual message contents

\[Date\]: /spec/common-structures\#type-date \[Integer\]:
/spec/common-structures\#type-integer

#### Notes

-   When transmitted over \[SSU\], the 16-byte standard header is not
    used. Only a 1-byte type and a 4-byte expiration in seconds are
    included. The message id and size are incorporated in the SSU data
    packet format. The checksum is not required since errors are caught
    in decryption.
-   When transmitted over \[NTCP2\], the 16-byte standard header is not
    used. Only a 1-byte type, 4-byte message id, and a 4-byte expiration
    in seconds are included. The size is incorporated in the NTCP2 data
    packet format. The checksum is not required since errors are caught
    in decryption.
-   The standard header is also required for I2NP messages contained in
    other messages and structures (Data, TunnelData, TunnelGateway, and
    GarlicClove). As of release 0.8.12, to reduce overhead, checksum
    verification is disabled at some places in the protocol stack.
    However, for compatibility with older versions, checksum generation
    is still required. It is a topic for future research to determine
    points in the protocol stack where the far-end router\'s version is
    known and checksum generation can be disabled.
-   The short expiration is unsigned and will wrap around on Feb.
    7, 2106. As of that date, an offset must be added to get the correct
    time.

### BuildRequestRecord {#struct-BuildRequestRecord}

#### Description

One Record in a set of multiple records to request the creation of one
hop in the tunnel. For more details see the tunnel overview
\[TUNNEL-IMPL\] and the ElGamal tunnel creation specification
\[TUNNEL-CREATION\].

For ECIES-X25519 BuildRequestRecords, see \[TUNNEL-CREATION-ECIES\].

#### Contents (ElGamal)

\[TunnelId\] to receive messages on, followed by the \[Hash\] of our
\[RouterIdentity\]. After that the \[TunnelId\] and the \[Hash\] of the
next router\'s \[RouterIdentity\] follow.

ElGamal and AES encrypted:

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> encrypted data\... \| \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> encrypted\_data :: ElGamal and AES encrypted data
>
> :   length -\> 528
>
> total length: 528

ElGamal encrypted:

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> toPeer \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> encrypted data\... \| \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> toPeer :: First 16 bytes of the SHA-256 Hash of the peer\'s \[RouterIdentity\]
>
> :   length -\> 16 bytes
>
> encrypted\_data :: ElGamal-2048 encrypted data (see notes)
>
> :   length -\> 512
>
> total length: 528

\[RouterIdentity\]: /spec/common-structures\#struct-routeridentity

Cleartext:

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> receive\_tunnel \| our\_ident \| +\-\-\--+\-\-\--+\-\-\--+\-\-\--+ +
> \| \| + + \| \| + + \| \| + +\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \| \|
> next\_tunnel \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> next\_ident \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> layer\_key \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> iv\_key \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> reply\_key \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> reply\_iv \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
> request\_time \| send\_msg\_id
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> \| +\-\-\--+ + \| 29 bytes padding \| + + \| \| + +\-\-\--+\-\-\--+ \|
> \| +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> receive\_tunnel :: \[TunnelId\]
>
> :   length -\> 4 bytes nonzero
>
> our\_ident :: \[Hash\]
>
> :   length -\> 32 bytes
>
> next\_tunnel :: \[TunnelId\]
>
> :   length -\> 4 bytes nonzero
>
> next\_ident :: \[Hash\]
>
> :   length -\> 32 bytes
>
> layer\_key :: \[SessionKey\]
>
> :   length -\> 32 bytes
>
> iv\_key :: \[SessionKey\]
>
> :   length -\> 32 bytes
>
> reply\_key :: \[SessionKey\]
>
> :   length -\> 32 bytes
>
> reply\_iv :: data
>
> :   length -\> 16 bytes
>
> flag :: \[Integer\]
>
> :   length -\> 1 byte
>
> request\_time :: \[Integer\]
>
> :   length -\> 4 bytes Hours since the epoch, i.e. current time / 3600
>
> send\_message\_id :: \[Integer\]
>
> :   length -\> 4 bytes
>
> padding :: Data
>
> :   length -\> 29 bytes source -\> random
>
> total length: 222

\[Integer\]: /spec/common-structures\#type-integer \[SessionKey\]:
/spec/common-structures\#type-sessionkey \[Hash\]:
/spec/common-structures\#type-hash \[TunnelId\]:
/spec/common-structures\#type-tunnelid

#### Notes

-   In the 512-byte encrypted record, the ElGamal data contains bytes
    1-256 and 258-513 of the 514-byte ElGamal encrypted block
    \[CRYPTO-ELG\]. The two padding bytes from the block (the zero bytes
    at locations 0 and 257) are removed.
-   See the tunnel creation specification \[TUNNEL-CREATION\] for
    details on field contents.

### BuildResponseRecord {#struct-BuildResponseRecord}

#### Description

One Record in a set of multiple records with responses to a build
request. For more details see the tunnel overview \[TUNNEL-IMPL\] and
the ElGamal tunnel creation specification \[TUNNEL-CREATION\].

For ECIES-X25519 BuildResponseRecords, see \[TUNNEL-CREATION-ECIES\].

#### Contents (ElGamal)

> Encrypted:
>
> bytes 0-527 :: AES-encrypted record (note: same size as
> \[BuildRequestRecord\])
>
> Unencrypted:
>
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> \| + + \| \| + SHA-256 Hash of following bytes + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> random data\... \| \~ \~ \| \| + +\-\-\--+ \| \| ret\|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> bytes 0-31 :: SHA-256 Hash of bytes 32-527 bytes 32-526 :: random data
> byte 527 :: reply
>
> total length: 528

\[BuildRequestRecord\]: /spec/i2np\#struct-buildrequestrecord

#### Notes

-   The random data field could, in the future, be used to return
    congestion or peer connectivity information back to the requestor.
-   See the tunnel creation specification \[TUNNEL-CREATION\] for
    details on the reply field.

### GarlicClove[]{#struct-GarlicClove} {#Garlic Cloves}

> Unencrypted:
>
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Delivery Instructions \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> I2NP Message \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Clove ID \| Expiration
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Certificate \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> Delivery Instructions :: as defined below
>
> :   Length varies but is typically 1, 33, or 37 bytes
>
> I2NP Message :: Any I2NP Message
>
> Clove ID :: 4 byte \[Integer\]
>
> Expiration :: \[Date\] (8 bytes)
>
> Certificate :: Always NULL in the current implementation (3 bytes
> total, all zeroes)

\[Date\]: /spec/common-structures\#type-date \[Integer\]:
/spec/common-structures\#type-integer

#### Notes

-   Cloves are never fragmented. When used in a Garlic Clove, the first
    bit of the Delivery Instructions flag byte specifies encryption. If
    this bit is 0, the clove is not encrypted. If 1, the clove is
    encrypted, and a 32 byte Session Key immediately follows the flag
    byte. Clove encryption is not fully implemented.
-   See also the garlic routing specification \[GARLICSPEC\].
-   Maximum length is a function of the total length of all the cloves
    and the maximum length of the GarlicMessage.
-   In the future, the certificate could possibly be used for a HashCash
    to \"pay\" for the routing.
-   The message can be any I2NP message (including a GarlicMessage,
    although that is not used in practice). The messages used in
    practice are DataMessage, DeliveryStatusMessage, and
    DatabaseStoreMessage.
-   The Clove ID is generally set to a random number on transmit and is
    checked for duplicates on receive (same message ID space as
    top-level Message IDs)

### Garlic Clove Delivery Instructions {#struct-GarlicCloveDeliveryInstructions}

This specification is for Delivery Instructions inside Garlic Cloves
only. Note that \"Delivery Instructions\" are also used inside Tunnel
Messages, where the format is significantly different. See the Tunnel
Message documentation \[TMDI\] for details. Do NOT use the following
specification for Tunnel Message Delivery Instructions!

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> +\-\-\--+ + \| \| + Session Key (optional) + \| \| + + \| \| +
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\-\-\-\-\-\-\-\-\-\-\--+ \| \| \|
> +\-\-\--+ + \| \| + To Hash (optional) + \| \| + + \| \| +
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\-\-\-\-\-\-\-\-\-\-\--+ \| \|
> Tunnel ID (opt) \| Delay (opt)
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> +\-\-\--+
>
> flag ::
>
> :   1 byte Bit order: 76543210 bit 7: encrypted? Unimplemented, always
>     0 If 1, a 32-byte encryption session key is included bits 6-5:
>     delivery type 0x0 = LOCAL, 0x01 = DESTINATION, 0x02 = ROUTER, 0x03
>     = TUNNEL bit 4: delay included? Not fully implemented, always 0 If
>     1, four delay bytes are included bits 3-0: reserved, set to 0 for
>     compatibility with future uses
>
> Session Key ::
>
> :   32 bytes Optional, present if encrypt flag bit is set.
>     Unimplemented, never set, never present.
>
> To Hash ::
>
> :   32 bytes Optional, present if delivery type is DESTINATION,
>     ROUTER, or TUNNEL If DESTINATION, the SHA256 Hash of the
>     destination If ROUTER, the SHA256 Hash of the router If TUNNEL,
>     the SHA256 Hash of the gateway router
>
> Tunnel ID :: \[TunnelId\]
>
> :   4 bytes Optional, present if delivery type is TUNNEL The
>     destination tunnel ID, nonzero
>
> Delay :: \[Integer\]
>
> :   4 bytes Optional, present if delay included flag is set Not fully
>     implemented. Specifies the delay in seconds.
>
> Total length: Typical length is:
>
> :   1 byte for LOCAL delivery; 33 bytes for ROUTER / DESTINATION
>     delivery; 37 bytes for TUNNEL delivery

\[Integer\]: /spec/common-structures\#type-integer \[TunnelId\]:
/spec/common-structures\#type-tunnelid

Messages
--------

+-------------------------------------------------------+---------+
| Message                                               | Type    |
+=======================================================+=========+
| [DatabaseStore](#databasestore)                       | > 1     |
+-------------------------------------------------------+---------+
| [DatabaseLookup](#databaselookup)                     | > 2     |
+-------------------------------------------------------+---------+
| [DatabaseSearchReply](#databasesearchreply)           | > 3     |
+-------------------------------------------------------+---------+
| [DeliveryStatus](#deliverystatus)                     | > 10    |
+-------------------------------------------------------+---------+
| [Garlic](#garlic)                                     | > 11    |
+-------------------------------------------------------+---------+
| [TunnelData](#tunneldata)                             | > 18    |
+-------------------------------------------------------+---------+
| [TunnelGateway](#tunnelgateway)                       | > 19    |
+-------------------------------------------------------+---------+
| [Data](#data)                                         | > 20    |
+-------------------------------------------------------+---------+
| [TunnelBuild](#tunnelbuild)                           | > 21    |
+-------------------------------------------------------+---------+
| [TunnelBuildReply](#tunnelbuildreply)                 | > 22    |
+-------------------------------------------------------+---------+
| [VariableTunnelBuild](#variabletunnelbuild)           | > 23    |
+-------------------------------------------------------+---------+
| [VariableTunnelBuildReply](#variabletunnelbuildreply) | > 24    |
+-------------------------------------------------------+---------+
| Reserved \[Prop157\]                                  | > 25    |
+-------------------------------------------------------+---------+
| Reserved \[Prop157\]                                  | > 26    |
+-------------------------------------------------------+---------+
| Reserved \[Prop157\]                                  | > 27    |
+-------------------------------------------------------+---------+
| Reserved                                              | > 0     |
+-------------------------------------------------------+---------+
| Reserved for experimental messages                    | 224-254 |
+-------------------------------------------------------+---------+
| Reserved for future expansion                         | > 255   |
+-------------------------------------------------------+---------+

### DatabaseStore {#msg-DatabaseStore}

#### Description

An unsolicited database store, or the response to a successful
[DatabaseLookup](#databaselookup) Message

#### Contents

An uncompressed LeaseSet, LeaseSet2, MetaLeaseSet, or EncryptedLeaseset,
or a compressed RouterInfo

> with reply token:
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> SHA256 Hash as key \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
> reply token \| reply\_tunnelId
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> SHA256 of the gateway RouterInfo \| +\-\-\--+ + \| \| + + \| \| + + \|
> \| + +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \| \|
> data \... +\-\-\--+-//
>
> with reply token == 0:
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> SHA256 Hash as key \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ 0 \|
> data \... +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+-//
>
> key ::
>
> :   32 bytes SHA256 hash
>
> type ::
>
> :   1 byte type identifier bit 0: 0 \[RouterInfo\] 1 \[LeaseSet\] or
>     variants listed below bits 3-1: Through release 0.9.17, must be 0
>     As of release 0.9.18, ignored, reserved for future options, set to
>     0 for compatibility As of release 0.9.38, the remainder of the
>     type identifier: 0: \[RouterInfo\] or \[LeaseSet\] (types 0 or 1)
>     1: \[LeaseSet2\] (type 3) 2: \[EncryptedLeaseSet\] (type 5) 3:
>     \[MetaLeaseSet\] (type 7) 4-7: Unsupported, invalid bits 7-4:
>     Through release 0.9.17, must be 0 As of release 0.9.18, ignored,
>     reserved for future options, set to 0 for compatibility
>
> reply token ::
>
> :   4 bytes If greater than zero, a \[DeliveryStatus\] is requested
>     with the Message ID set to the value of the Reply Token. A
>     floodfill router is also expected to flood the data to the closest
>     floodfill peers if the token is greater than zero.
>
> reply\_tunnelId ::
>
> :   4 byte \[TunnelId\] Only included if reply token \> 0 This is the
>     \[TunnelId\] of the inbound gateway of the tunnel the response
>     should be sent to If \$reply\_tunnelId is zero, the reply is sent
>     directy to the reply gateway router.
>
> reply gateway ::
>
> :   32 bytes Hash of the \[RouterInfo\] entry to reach the gateway
>     Only included if reply token \> 0 If \$reply\_tunnelId is nonzero,
>     this is the router hash of the inbound gateway of the tunnel the
>     response should be sent to. If \$reply\_tunnelId is zero, this is
>     the router hash the response should be sent to.
>
> data ::
>
> :   
>
>     If type == 0, data is a 2-byte \[Integer\] specifying the number of bytes that follow,
>
>     :   followed by a gzip-compressed \[RouterInfo\]. See note below.
>
>     If type == 1, data is an uncompressed \[LeaseSet\]. If type == 3,
>     data is an uncompressed \[LeaseSet2\]. If type == 5, data is an
>     uncompressed \[EncryptedLeaseSet\]. If type == 7, data is an
>     uncompressed \[MetaLeaseSet\].

\[TunnelId\]: /spec/common-structures\#type-tunnelid \[LeaseSet\]:
/spec/common-structures\#struct-leaseset \[DeliveryStatus\]:
/spec/i2np\#msg-deliverystatus \[EncryptedLeaseSet\]:
/spec/common-structures\#struct-encryptedleaseset \[RouterInfo\]:
/spec/common-structures\#struct-routerinfo \[Integer\]:
/spec/common-structures\#type-integer \[MetaLeaseSet\]:
/spec/common-structures\#struct-metaleaseset \[LeaseSet2\]:
/spec/common-structures\#struct-leaseset2

#### Notes

-   For security, the reply fields are ignored if the message is
    received down a tunnel.
-   The key is the \"real\" hash of the RouterIdentity or Destination,
    NOT the routing key.
-   Types 3, 5, and 7 are as of release 0.9.38. See proposal 123 for
    more information. These types should only be sent to routers with
    release 0.9.38 or higher.
-   As an optimization to reduce connections, if the type is a LeaseSet,
    the reply token is included, the reply tunnel ID is nonzero, and the
    reply gateway/tunnelID pair is found in the LeaseSet as a lease, the
    recipient may reroute the reply to any other lease in the LeaseSet.
-   To hide the router OS and implementation, match the Java router
    implementation of gzip by setting the modification time to 0 and the
    OS byte to 0xFF, and set XFL to 0x02 (max compression, slowest
    algorithm). See RFC 1952. First 10 bytes of the compressed router
    info will be (hex): 1F 8B 08 00 00 00 00 00 02 FF

### DatabaseLookup {#msg-DatabaseLookup}

#### Description

A request to look up an item in the network database. The response is
either a [DatabaseStore](#databasestore) or a
[DatabaseSearchReply](#databasesearchreply).

#### Contents

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> SHA256 hash as the key to look up \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> SHA256 hash of the routerInfo \| + who is asking or the gateway to +
> \| send the reply to \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
> reply\_tunnelId \| size \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ + \| SHA256
> of key1 to exclude \| + + \| \| + + \| \| + +\-\-\--+ \| \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ + \| SHA256
> of key2 to exclude \| + + \~ \~ + +\-\-\--+ \| \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ + \| \| + +
> \| Session key if reply encryption \| + was requested + \| \| +
> +\-\-\--+ \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> \| + + \| Session tags if reply encryption \| + was requested + \| \|
> + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> key ::
>
> :   32 bytes SHA256 hash of the object to lookup
>
> from ::
>
> :   32 bytes if deliveryFlag == 0, the SHA256 hash of the routerInfo
>     entry this request came from (to which the reply should be sent)
>     if deliveryFlag == 1, the SHA256 hash of the reply tunnel gateway
>     (to which the reply should be sent)
>
> flags ::
>
> :   1 byte bit order: 76543210 bit 0: deliveryFlag 0 =\> send reply
>     directly 1 =\> send reply to some tunnel bit 1: encryptionFlag
>     through release 0.9.5, must be set to 0 as of release 0.9.6,
>     ignored as of release 0.9.7: 0 =\> send unencrypted reply 1 =\>
>     send AES encrypted reply using enclosed key and tag bits 3-2:
>     lookup type flags through release 0.9.5, must be set to 00 as of
>     release 0.9.6, ignored as of release 0.9.16: 00 =\> normal lookup,
>     return \[RouterInfo\] or \[LeaseSet\] or \[DatabaseSearchReply\]
>     Not recommended when sending to routers with version 0.9.16 or
>     higher. 01 =\> LS lookup, return \[LeaseSet\] or
>     \[DatabaseSearchReply\] As of release 0.9.38, may also return a
>     \[LeaseSet2\], \[MetaLeaseSet\], or \[EncryptedLeaseSet\]. 10 =\>
>     RI lookup, return \[RouterInfo\] or \[DatabaseSearchReply\] 11 =\>
>     exploration lookup, return \[DatabaseSearchReply\] containing
>     non-floodfill routers only (replaces an excludedPeer of all
>     zeroes) bit 4: ECIESFlag before release 0.9.46 ignored as of
>     release 0.9.46: 0 =\> send unencrypted or ElGamal reply 1 =\> send
>     ChaCha/Poly encrypted reply using enclosed key (whether tag is
>     enclosed depends on bit 1) bits 7-5: through release 0.9.5, must
>     be set to 0 as of release 0.9.6, ignored, set to 0 for
>     compatibility with future uses and with older routers
>
> reply\_tunnelId ::
>
> :   4 byte TunnelID only included if deliveryFlag == 1 tunnelId of the
>     tunnel to send the reply to, nonzero
>
> size ::
>
> :   2 byte \[Integer\] valid range: 0-512 number of peers to exclude
>     from the \[DatabaseSearchReply\]
>
> excludedPeers ::
>
> :   \$size SHA256 hashes of 32 bytes each (total \$size\*32 bytes) if
>     the lookup fails, these peers are requested to be excluded from
>     the list in the \[DatabaseSearchReply\]. if excludedPeers includes
>     a hash of all zeroes, the request is exploratory, and the
>     \[DatabaseSearchReply\] is requested to list non-floodfill routers
>     only.
>
> reply\_key ::
>
> :   32 byte key see below
>
> tags ::
>
> :   1 byte \[Integer\] valid range: 1-32 (typically 1) the number of
>     reply tags that follow see below
>
> reply\_tags ::
>
> :   one or more 8 or 32 byte session tags (typically one) see below

\[LeaseSet\]: /spec/common-structures\#struct-leaseset
\[EncryptedLeaseSet\]: /spec/common-structures\#struct-encryptedleaseset
\[RouterInfo\]: /spec/common-structures\#struct-routerinfo \[Integer\]:
/spec/common-structures\#type-integer \[MetaLeaseSet\]:
/spec/common-structures\#struct-metaleaseset \[DatabaseSearchReply\]:
/spec/i2np\#msg-databasesearchreply \[LeaseSet2\]:
/spec/common-structures\#struct-leaseset2

#### Reply Encryption

Flag bit 4 is used in combination with bit 1 to determine the reply
encryption mode. Flag bit 4 must only be set when sending to routers
with version 0.9.46 or higher. See proposals 154 and 156 for details.

In the table below, \"DH n/a\" means that the reply is not encrypted.
\"DH no\" means that the reply keys are included in the request. \"DH
yes\" means that the reply keys are derived from the DH operation.

  Flag bits 4,1   From    To Router   Reply    DH?   notes
  --------------- ------- ----------- -------- ----- ---------------
  0 0             Any     Any         no enc   n/a   no encryption
  0 1             ElG     ElG         AES      no    As of 0.9.7
  1 0             ECIES   ElG         AEAD     no    As of 0.9.46
  1 0             ECIES   ECIES       AEAD     no    As of 0.9.49
  1 1             ElG     ECIES       AES      yes   TBD
  1 1             ECIES   ECIES       AEAD     yes   TBD

#### No Encryption

reply\_key, tags, and reply\_tags are not present.

#### ElG to ElG

Supported as of 0.9.7. ElG destination sends a lookup to a ElG router.

Requester key generation:

> reply\_key :: CSRNG(32) 32 bytes random data reply\_tags :: Each is
> CSRNG(32) 32 bytes random data

Message format:

> reply\_key ::
>
> :   32 byte \[SessionKey\] big-endian only included if encryptionFlag
>     == 1 AND ECIESFlag == 0, only as of release 0.9.7
>
> tags ::
>
> :   1 byte \[Integer\] valid range: 1-32 (typically 1) the number of
>     reply tags that follow only included if encryptionFlag == 1 AND
>     ECIESFlag == 0, only as of release 0.9.7
>
> reply\_tags ::
>
> :   one or more 32 byte \[SessionTag\]s (typically one) only included
>     if encryptionFlag == 1 AND ECIESFlag == 0, only as of release
>     0.9.7

\[Integer\]: /spec/common-structures\#type-integer \[SessionKey\]:
/spec/common-structures\#type-sessionkey \[SessionTag\]:
/spec/common-structures\#type-sessiontag

#### ECIES to ElG

Supported as of 0.9.46. ECIES destination sends a lookup to a ElG
router. The reply\_key and reply\_tags fields are redefined for an
ECIES-encrypted reply.

Requester key generation:

> reply\_key :: CSRNG(32) 32 bytes random data reply\_tags :: Each is
> CSRNG(8) 8 bytes random data

Message format: Redefine reply\_key and reply\_tags fields as follows:

> reply\_key ::
>
> :   32 byte ECIES \[SessionKey\] big-endian only included if
>     encryptionFlag == 0 AND ECIESFlag == 1, only as of release 0.9.46
>
> tags ::
>
> :   1 byte \[Integer\] required value: 1 the number of reply tags that
>     follow only included if encryptionFlag == 0 AND ECIESFlag == 1,
>     only as of release 0.9.46
>
> reply\_tags ::
>
> :   an 8 byte ECIES \[SessionTag\] only included if encryptionFlag ==
>     0 AND ECIESFlag == 1, only as of release 0.9.46

\[Integer\]: /spec/common-structures\#type-integer \[SessionKey\]:
/spec/common-structures\#type-sessionkey \[SessionTag\]:
/spec/common-structures\#type-sessiontag

The reply is an ECIES Existing Session message, as defined in \[ECIES\].

#### Reply format

This is the existing session message, same as in \[ECIES\], copied below
for reference.

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Session Tag \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> \| + Payload Section + \| ChaCha20 encrypted data \| \~ \~ \| \| + +
> \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Poly1305 Message Authentication Code \| + (MAC) + \| 16 bytes \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> Session Tag :: 8 bytes, cleartext
>
> Payload data :: remaining data minus 16 bytes
>
> MAC :: Poly1305 message authentication code, 16 bytes

AEAD parameters:

> tag :: 8 byte reply\_tag
>
> k :: 32 byte session key
>
> :   The reply\_key.
>
> n :: 0
>
> ad :: The 8 byte reply\_tag
>
> payload :: Plaintext data, the DSM or DSRM.
>
> ciphertext = ENCRYPT(k, n, payload, ad)

### ECIES to ECIES (0.9.49)

ECIES destination or router sends a lookup to a ECIES router. Supported
as of 0.9.49.

ECIES routers were introduced in 0.9.48, see \[Prop156\]. ECIES
destinations and routers may use the same format as in the \"ECIES to
ElG\" section above, with reply keys included in the request. The lookup
message encryption is specified in \[ECIES-ROUTERS\]. The requester is
anonymous.

### ECIES to ECIES (future)

This option is not yet fully defined. See \[Prop156\].

#### Notes

-   Prior to 0.9.16, the key may be for a RouterInfo or LeaseSet, as
    they are in the same key space, and there was no flag to request
    only a particular type of data.
-   Encryption flag, reply key, and reply tags as of release 0.9.7.
-   Encrypted replies are only useful when the response is through a
    tunnel.
-   The number of included tags could be greater than one if alternative
    DHT lookup strategies (for example, recursive lookups) are
    implemented.
-   The lookup key and exclude keys are the \"real\" hashes, NOT routing
    keys.
-   Types 3, 5, and 7 may be returned as of release 0.9.38. See proposal
    123 for more information.

### DatabaseSearchReply {#msg-DatabaseSearchReply}

#### Description

The response to a failed [DatabaseLookup](#databaselookup) Message

#### Contents

A list of router hashes closest to the requested key

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> SHA256 hash as query key \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> num\| peer\_hashes \| +\-\-\--+ + \| \| + + \| \| + + \| \| +
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \| \| from
> \| +\-\-\--+ + \| \| + + \| \| + + \| \| +
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \| \|
> +\-\-\--+
>
> key ::
>
> :   32 bytes SHA256 of the object being searched
>
> num ::
>
> :   1 byte \[Integer\] number of peer hashes that follow, 0-255
>
> peer\_hashes ::
>
> :   \$num SHA256 hashes of 32 bytes each (total \$num\*32 bytes)
>     SHA256 of the \[RouterIdentity\] that the other router thinks is
>     close to the key
>
> from ::
>
> :   32 bytes SHA256 of the \[RouterInfo\] of the router this reply was
>     sent from

\[Integer\]: /spec/common-structures\#type-integer \[RouterInfo\]:
/spec/common-structures\#struct-routerinfo \[RouterIdentity\]:
/spec/common-structures\#struct-routeridentity

#### Notes

-   The \'from\' hash is unauthenticated and cannot be trusted.
-   The returned peer hashes are not necessarily closer to the key than
    the router being queried.
-   Typical number of hashes returned: 3
-   The lookup key, peer hashes, and from hash are \"real\" hashes, NOT
    routing keys.

### DeliveryStatus {#msg-DeliveryStatus}

#### Description

A simple message acknowledgment. Generally created by the message
originator, and wrapped in a Garlic Message with the message itself, to
be returned by the destination.

#### Contents

The ID of the delivered message, and the creation or arrival time.

>   --------- ---- ---- ---- ---- ---- ------ -------- ---- ---- ---- ----
>   [msg]()   id                       time   \_stam   p              
>
>   --------- ---- ---- ---- ---- ---- ------ -------- ---- ---- ---- ----
>
> msg\_id :: \[Integer\]
>
> :   4 bytes unique ID of the message we deliver the DeliveryStatus for
>     (see \[I2NPMessageHeader\] for details)
>
> time\_stamp :: \[Date\]
>
> :   8 bytes time the message was successfully created or delivered

\[Date\]: /spec/common-structures\#type-date \[Integer\]:
/spec/common-structures\#type-integer \[I2NPMessageHeader\]:
/spec/i2np\#struct-i2npmessageheader

#### Notes

-   It appears that the time stamp is always set by the creator to the
    current time. However there are several uses of this in the code,
    and more may be added in the future.
-   This message is also used as a session established confirmation in
    SSU \[SSU-ED\]. In this case, the message ID is set to a random
    number, and the \"arrival time\" is set to the current network-wide
    ID, which is 2 (i.e. 0x0000000000000002).

### Garlic {#msg-Garlic}

#### Description

Used to wrap multiple encrypted I2NP Messages

#### Contents

When decrypted, a series of [Garlic Cloves](#Garlic Cloves) and
additional data, also known as a Clove Set.

Encrypted:

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> length \| data \| +\-\-\--+\-\-\--+\-\-\--+\-\-\--+ + \| \| \~ \~ \~
> \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> length ::
>
> :   4 byte \[Integer\] number of bytes that follow 0 - 64 KB
>
> data ::
>
> :   \$length bytes ElGamal encrypted data

\[Integer\]: /spec/common-structures\#type-integer

Decrypted data, also known as a Clove Set:

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> num\| clove 1 \| +\-\-\--+ + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> clove 2 \... \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Certificate \| Message\_ID \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
> Expiration \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> num ::
>
> :   1 byte \[Integer\] number of \[GarlicClove\]s to follow
>
> clove :: a \[GarlicClove\]
>
> Certificate :: always NULL in the current implementation (3 bytes
> total, all zeroes)
>
> Message\_ID :: 4 byte \[Integer\]
>
> Expiration :: \[Date\] (8 bytes)

\[Date\]: /spec/common-structures\#type-date \[Integer\]:
/spec/common-structures\#type-integer \[GarlicClove\]:
/spec/i2np\#struct-garlicclove

#### Notes

-   When unencrypted, data contains one or more [Garlic
    Cloves](#Garlic Cloves).
-   The AES encrypted block is padded to a minimum of 128 bytes; with
    the 32-byte Session Tag the minimum size of the encrypted message is
    160 bytes; with the 4 length bytes the minimum size of the Garlic
    Message is 164 bytes.
-   Actual max length is less than 64 KB; see \[I2NP\].
-   See also the ElGamal/AES specification \[ELG-AES\].
-   See also the garlic routing specification \[GARLIC\].
-   The 128 byte minimum size of the AES encrypted block is not
    currently configurable, however the minimum size of a DataMessage in
    a GarlicClove in a GarlicMessage, with overhead, is 128 bytes
    anyway. A configurable option to increase the minimum size may be
    added in the future.
-   The message ID is generally set to a random number on transmit and
    appears to be ignored on receive.
-   In the future, the certificate could possibly be used for a HashCash
    to \"pay\" for the routing.

### TunnelData {#msg-TunnelData}

#### Description

A message sent from a tunnel\'s gateway or participant to the next
participant or endpoint. The data is of fixed length, containing I2NP
messages that are fragmented, batched, padded, and encrypted.

#### Contents

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> tunnnelID \| data \| +\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \| \| \| \~ \~
> \~ \~ \| \| + +\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> tunnelId ::
>
> :   4 byte \[TunnelId\] identifies the tunnel this message is directed
>     at nonzero
>
> data ::
>
> :   1024 bytes payload data.. fixed to 1024 bytes

\[TunnelId\]: /spec/common-structures\#type-tunnelid

#### Notes

-   The I2NP message ID for this message is set to a new random number
    at each hop.
-   See also the Tunnel Message Specification \[TUNNEL-MSG\]

### TunnelGateway {#msg-TunnelGateway}

#### Description

Wraps another I2NP message to be sent into a tunnel at the tunnel\'s
inbound gateway.

#### Contents

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+-// \|
> tunnelId \| length \| data\...
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+-//
>
> tunnelId ::
>
> :   4 byte \[TunnelId\] identifies the tunnel this message is directed
>     at nonzero
>
> length ::
>
> :   2 byte \[Integer\] length of the payload
>
> data ::
>
> :   \$length bytes actual payload of this message

\[Integer\]: /spec/common-structures\#type-integer \[TunnelId\]:
/spec/common-structures\#type-tunnelid

#### Notes

-   The payload is an I2NP message with a standard 16-byte header.

### Data {#msg-Data}

#### Description

Used by Garlic Messages and Garlic Cloves to wrap arbitrary data.

#### Contents

A length Integer, followed by opaque data.

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+-//-+ \| length \| data\...
> \| +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+-//-+
>
> length ::
>
> :   4 bytes length of the payload
>
> data ::
>
> :   \$length bytes actual payload of this message

#### Notes

-   This message contains no routing information and will never be sent
    \"unwrapped\". It is only used inside [Garlic]{.title-ref} messages.

### TunnelBuild {#msg-TunnelBuild}

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Record 0 \... \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Record 1 \... \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Record 7 \... \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> Just 8 \[BuildRequestRecord\]s attached together record size: 528
> bytes total size: 8\*528 = 4224 bytes

\[BuildRequestRecord\]: /spec/i2np\#struct-buildrequestrecord

#### Notes

-   As of 0.9.48, may also contain ECIES-X25519 BuildRequestRecords, see
    \[TUNNEL-CREATION-ECIES\].
-   See also the tunnel creation specification \[TUNNEL-CREATION\].
-   The I2NP message ID for this message must be set according to the
    tunnel creation specification.
-   While this message is rarely seen in today\'s network, having been
    replaced by the [VariableTunnelBuild]{.title-ref} message, it may
    still be used for very long tunnels, and has not been deprecated.
    Routers must implement.

### TunnelBuildReply {#msg-TunnelBuildReply}

> Same format as \[TunnelBuild\], with \[BuildResponseRecord\]s

\[BuildResponseRecord\]: /spec/i2np\#struct-buildresponserecord
\[TunnelBuild\]: /spec/i2np\#msg-tunnelbuild

#### Notes

-   As of 0.9.48, may also contain ECIES-X25519 BuildResponseRecords,
    see \[TUNNEL-CREATION-ECIES\].
-   See also the tunnel creation specification \[TUNNEL-CREATION\].
-   The I2NP message ID for this message must be set according to the
    tunnel creation specification.
-   While this message is rarely seen in today\'s network, having been
    replaced by the [VariableTunnelBuildReply]{.title-ref} message, it
    may still be used for very long tunnels, and has not been
    deprecated. Routers must implement.

### VariableTunnelBuild {#msg-VariableTunnelBuild}

>   ----- ------ ------- ------- ------- ------ ---- ----
>   num   Buil   dRequ   estRe   cords   \...        
>
>   ----- ------ ------- ------- ------- ------ ---- ----
>
> Same format as \[TunnelBuild\], except for the addition of a \$num
> field in front and \$num number of \[BuildRequestRecord\]s instead of
> 8
>
> num ::
>
> :   1 byte \[Integer\] Valid values: 1-8
>
> record size: 528 bytes total size: 1+\$num\*528

\[Integer\]: /spec/common-structures\#type-integer
\[BuildRequestRecord\]: /spec/i2np\#struct-buildrequestrecord
\[TunnelBuild\]: /spec/i2np\#msg-tunnelbuild

#### Notes

-   As of 0.9.48, may also contain ECIES-X25519 BuildRequestRecords, see
    \[TUNNEL-CREATION-ECIES\].
-   This message was introduced in router version 0.7.12, and may not be
    sent to tunnel participants earlier than that version.
-   See also the tunnel creation specification \[TUNNEL-CREATION\].
-   The I2NP message ID for this message must be set according to the
    tunnel creation specification.
-   Typical number of records in today\'s network is 4, for a total size
    of 2113.

### VariableTunnelBuildReply {#msg-VariableTunnelBuildReply}

>   ----- ------ ------- ------- ------- ------- ---- ----
>   num   Buil   dResp   onseR   ecord   s\...        
>
>   ----- ------ ------- ------- ------- ------- ---- ----
>
> Same format as \[VariableTunnelBuild\], with \[BuildResponseRecord\]s.

\[BuildResponseRecord\]: /spec/i2np\#struct-buildresponserecord
\[VariableTunnelBuild\]: /spec/i2np\#msg-variabletunnelbuild

#### Notes

-   As of 0.9.48, may also contain ECIES-X25519 BuildResponseRecords,
    see \[TUNNEL-CREATION-ECIES\].
-   This message was introduced in router version 0.7.12, and may not be
    sent to tunnel participants earlier than that version.
-   See also the tunnel creation specification \[TUNNEL-CREATION\].
-   The I2NP message ID for this message must be set according to the
    tunnel creation specification.
-   Typical number of records in today\'s network is 4, for a total size
    of 2113.

References
----------

\[CRYPTO-ELG\]

:   <https://geti2p.net/en/docs/how/cryptography#elgamal>

\[Date\]

:   <https://geti2p.net/spec/common-structures#type-date>

\[ECIES\]

:   <https://geti2p.net/spec/ecies>

\[ECIES-ROUTERS\]

:   <https://geti2p.net/spec/ecies-routers>

\[ElG-AES\]

:   <https://geti2p.net/en/docs/how/elgamal-aes>

\[GARLICSPEC\]

:   <https://geti2p.net/en/docs/how/garlic-routing>

\[Hash\]

:   <https://geti2p.net/spec/common-structures#type-hash>

\[I2NP\]

:   <https://geti2p.net/en/docs/protocol/i2np>

\[Integer\]

:   <https://geti2p.net/spec/common-structures#type-integer>

\[NTCP2\]

:   <https://geti2p.net/spec/ntcp2>

\[Prop156\]

:   <https://geti2p.net/spec/proposals/156-ecies-routers>

\[Prop157\]

:   <https://geti2p.net/spec/proposals/157-new-tbm>

\[RouterIdentity\]

:   <https://geti2p.net/spec/common-structures#struct-routeridentity>

\[SSU\]

:   <https://geti2p.net/en/docs/transport/ssu>

\[SSU-ED\]

:   <https://geti2p.net/en/docs/transport/ssu#establishDirect>

\[TMDI\]

:   <https://geti2p.net/spec/tunnel-message#struct-tunnelmessagedeliveryinstructions>

\[TUNNEL-CREATION\]

:   <https://geti2p.net/spec/tunnel-creation>

\[TUNNEL-CREATION-ECIES\]

:   <https://geti2p.net/spec/tunnel-creation-ecies>

\[TUNNEL-MSG\]

:   <https://geti2p.net/spec/tunnel-message>

\[TUNNEL-IMPL\]

:   <https://geti2p.net/en/docs/tunnels/implementation>

\[TunnelId\]

:   <https://geti2p.net/spec/common-structures#type-tunnelid>
