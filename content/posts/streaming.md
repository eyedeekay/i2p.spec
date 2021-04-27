---
title: "Streaming"
date: 2021-04-27T14:39:35-04:00
draft: false
---

Streaming Library Specification
===============================

Category: Protocols Last updated: May 2020 Accurate for: 0.9.46

Overview
--------

See \[STREAMING\] for an overview of the Streaming Library.

Protocol Versions {#versions}
-----------------

The streaming protocol does not include a version field. The versions
listed below are for Java I2P. Implementations and actual crypto support
may vary. There is no way to determine if the far-end supports any
particular version or feature. The table below is for general guidance
as to the release dates for various features.

The features listed below are for the protocol itself. Various options
for configuration are documented in \[STREAMING\] along with the Java
I2P version in which they were implemented.

+----------------+--------------------------------------------+
| Router Version | Streaming Features                         |
+================+============================================+
| > 0.9.39       | OFFLINE\_SIGNATURE option                  |
+----------------+--------------------------------------------+
| > 0.9.36       | I2CP protocol number enforced              |
+----------------+--------------------------------------------+
| > 0.9.20       | FROM\_INCLUDED no longer required in RESET |
+----------------+--------------------------------------------+
| > 0.9.18       | PINGs and PONGs may include a payload      |
+----------------+--------------------------------------------+
| > 0.9.15       | EdDSA Ed25519 sig type                     |
+----------------+--------------------------------------------+
| > 0.9.12       | ECDSA P-256, P-384, and P-521 sig types    |
+----------------+--------------------------------------------+
| > 0.9.11       | Variable-length signatures                 |
+----------------+--------------------------------------------+
| > 0.7.1        | Protocol numbers defined in I2CP           |
+----------------+--------------------------------------------+

Protocol Specification
----------------------

### Packet Format

The format of a single packet in the streaming protocol is shown below.
The minimum header size, without NACKs or option data, is 22 bytes.

There is no length field in the streaming protocol. Framing is provided
by the lower layers - I2CP and I2NP.

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> send Stream ID \| rcv Stream ID \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> sequence Num \| ack Through \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> nc \| nc\*4 bytes of NACKs (optional)
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> rd \| flags \| opt size\| opt data
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \...
> (optional, see below) \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> payload \... +\-\-\--+\-\-\--+\-\-\--+-//
>
> sendStreamId :: 4 byte \[Integer\]
>
> :   Random number selected by the packet recipient before sending the
>     first SYN reply packet and constant for the life of the
>     connection. 0 in the SYN message sent by the connection
>     originator, and in subsequent messages, until a SYN reply is
>     received, containing the peer\'s stream ID.
>
> receiveStreamId :: 4 byte \[Integer\]
>
> :   Random number selected by the packet originator before sending the
>     first SYN packet and constant for the life of the connection. May
>     be 0 if unknown, for example in a RESET packet.
>
> sequenceNum :: 4 byte \[Integer\]
>
> :   The sequence for this message, starting at 0 in the SYN message,
>     and incremented by 1 in each message except for plain ACKs and
>     retransmissions. If the sequenceNum is 0 and the SYN flag is not
>     set, this is a plain ACK packet that should not be ACKed.
>
> ackThrough :: 4 byte \[Integer\]
>
> :   The highest packet sequence number that was received on the
>     \$receiveStreamId. This field is ignored on the initial connection
>     packet (where \$receiveStreamId is the unknown id) or if the
>     NO\_ACK flag set. All packets up to and including this sequence
>     number are ACKed, EXCEPT for those listed in NACKs below.
>
> NACK count :: 1 byte \[Integer\]
>
> :   The number of 4-byte NACKs in the next field
>
> NACKs :: \$nc \* 4 byte \[Integer\]s
>
> :   Sequence numbers less than ackThrough that are not yet received.
>     Two NACKs of a packet is a request for a \'fast retransmit\' of
>     that packet.
>
> resendDelay :: 1 byte \[Integer\]
>
> :   How long is the creator of this packet going to wait before
>     resending this packet (if it hasn\'t yet been ACKed). The value is
>     seconds since the packet was created. Currently ignored on
>     receive.
>
> flags :: 2 byte value
>
> :   See below.
>
> option size :: 2 byte \[Integer\]
>
> :   The number of bytes in the next field
>
> option data :: 0 or more bytes
>
> :   As specified by the flags. See below.
>
> payload :: remaining packet size

\[Integer\]: /spec/common-structures\#type-integer

### Flags and Option Data Fields

The flags field above specifies some metadata about the packet, and in
turn may require certain additional data to be included. The flags are
as follows. Any data structures specified must be added to the options
area in the given order.

Bit order: 15\....0 (15 is MSB)

+-------+--------------+--------------+--------------+--------------+
| Bit   | Flag         | Option Order | Option Data  | Function     |
+=======+==============+==============+==============+==============+
| > 0   | SYNCHRONIZE  | > \--        | > \--        | Similar to   |
|       |              |              |              | TCP SYN. Set |
|       |              |              |              | in the       |
|       |              |              |              | initial      |
|       |              |              |              | packet and   |
|       |              |              |              | in the first |
|       |              |              |              | response.    |
|       |              |              |              | FR           |
|       |              |              |              | OM\_INCLUDED |
|       |              |              |              | and          |
|       |              |              |              | SIGNATU      |
|       |              |              |              | RE\_INCLUDED |
|       |              |              |              | must also be |
|       |              |              |              | set.         |
+-------+--------------+--------------+--------------+--------------+
| > 1   | CLOSE        | > \--        | > \--        | Similar to   |
|       |              |              |              | TCP FIN. If  |
|       |              |              |              | the response |
|       |              |              |              | to a         |
|       |              |              |              | SYNCHRONIZE  |
|       |              |              |              | fits in a    |
|       |              |              |              | single       |
|       |              |              |              | message, the |
|       |              |              |              | response     |
|       |              |              |              | will contain |
|       |              |              |              | both         |
|       |              |              |              | SYNCHRONIZE  |
|       |              |              |              | and CLOSE.   |
|       |              |              |              | SIGNATU      |
|       |              |              |              | RE\_INCLUDED |
|       |              |              |              | must also be |
|       |              |              |              | set.         |
+-------+--------------+--------------+--------------+--------------+
| > 2   | RESET        | > \--        | > \--        | Abnormal     |
|       |              |              |              | close.       |
|       |              |              |              | SIGNATU      |
|       |              |              |              | RE\_INCLUDED |
|       |              |              |              | must also be |
|       |              |              |              | set. Prior   |
|       |              |              |              | to release   |
|       |              |              |              | 0.9.20, due  |
|       |              |              |              | to a bug,    |
|       |              |              |              | FR           |
|       |              |              |              | OM\_INCLUDED |
|       |              |              |              | must also be |
|       |              |              |              | set.         |
+-------+--------------+--------------+--------------+--------------+
| > 3   | SIGNATU      | > 5          | variable     | Currently    |
|       | RE\_INCLUDED |              | length       | sent only    |
|       |              |              | \            | with         |
|       |              |              | [Signature\] | SYNCHRONIZE, |
|       |              |              |              | CLOSE, and   |
|       |              |              |              | RESET, where |
|       |              |              |              | it is        |
|       |              |              |              | required,    |
|       |              |              |              | and with     |
|       |              |              |              | ECHO, where  |
|       |              |              |              | it is        |
|       |              |              |              | required for |
|       |              |              |              | a ping. The  |
|       |              |              |              | signature    |
|       |              |              |              | uses the     |
|       |              |              |              | De           |
|       |              |              |              | stination\'s |
|       |              |              |              | \[Signing    |
|       |              |              |              | PrivateKey\] |
|       |              |              |              | to sign the  |
|       |              |              |              | entire       |
|       |              |              |              | header and   |
|       |              |              |              | payload with |
|       |              |              |              | the space in |
|       |              |              |              | the option   |
|       |              |              |              | data field   |
|       |              |              |              | for the      |
|       |              |              |              | signature    |
|       |              |              |              | being set to |
|       |              |              |              | all zeroes.  |
|       |              |              |              |              |
|       |              |              |              | Prior to     |
|       |              |              |              | release      |
|       |              |              |              | 0.9.11, the  |
|       |              |              |              | signature    |
|       |              |              |              | was always   |
|       |              |              |              | 40 bytes. As |
|       |              |              |              | of release   |
|       |              |              |              | 0.9.11, the  |
|       |              |              |              | signature    |
|       |              |              |              | may be       |
|       |              |              |              | vari         |
|       |              |              |              | able-length, |
|       |              |              |              | see below    |
|       |              |              |              | for details. |
+-------+--------------+--------------+--------------+--------------+
| > 4   | SIGNATUR     | > \--        | > \--        | Unused.      |
|       | E\_REQUESTED |              |              | Requests     |
|       |              |              |              | every packet |
|       |              |              |              | in the other |
|       |              |              |              | direction to |
|       |              |              |              | have         |
|       |              |              |              | SIGNATU      |
|       |              |              |              | RE\_INCLUDED |
+-------+--------------+--------------+--------------+--------------+
| > 5   | FR           | > 2          | 387+ byte    | Currently    |
|       | OM\_INCLUDED |              | \[D          | sent only    |
|       |              |              | estination\] | with         |
|       |              |              |              | SYNCHRONIZE, |
|       |              |              |              | where it is  |
|       |              |              |              | required,    |
|       |              |              |              | and with     |
|       |              |              |              | ECHO, where  |
|       |              |              |              | it is        |
|       |              |              |              | required for |
|       |              |              |              | a ping.      |
|       |              |              |              | Prior to     |
|       |              |              |              | release      |
|       |              |              |              | 0.9.20, due  |
|       |              |              |              | to a bug,    |
|       |              |              |              | must also be |
|       |              |              |              | sent with    |
|       |              |              |              | RESET.       |
+-------+--------------+--------------+--------------+--------------+
| > 6   | DELA         | > 1          | 2 byte       | Optional     |
|       | Y\_REQUESTED |              | \[Integer\]  | delay. How   |
|       |              |              |              | many         |
|       |              |              |              | milliseconds |
|       |              |              |              | the sender   |
|       |              |              |              | of this      |
|       |              |              |              | packet wants |
|       |              |              |              | the          |
|       |              |              |              | recipient to |
|       |              |              |              | wait before  |
|       |              |              |              | sending any  |
|       |              |              |              | more data. A |
|       |              |              |              | value        |
|       |              |              |              | greater than |
|       |              |              |              | 60000        |
|       |              |              |              | indicates    |
|       |              |              |              | choking.     |
+-------+--------------+--------------+--------------+--------------+
| > 7   | MAX          | > 3          | 2 byte       | The maximum  |
|       | \_PACKET\_SI |              | \[Integer\]  | length of    |
|       | ZE\_INCLUDED |              |              | the payload. |
|       |              |              |              | Send with    |
|       |              |              |              | SYNCHRONIZE. |
+-------+--------------+--------------+--------------+--------------+
| > 8   | PROFILE\     | > \--        | > \--        | Unused or    |
|       | _INTERACTIVE |              |              | ignored; the |
|       |              |              |              | interactive  |
|       |              |              |              | profile is   |
|       |              |              |              | un           |
|       |              |              |              | implemented. |
+-------+--------------+--------------+--------------+--------------+
| > 9   | ECHO         | > \--        | > \--        | Unused       |
|       |              |              |              | except by    |
|       |              |              |              | ping         |
|       |              |              |              | programs. If |
|       |              |              |              | set, most    |
|       |              |              |              | other        |
|       |              |              |              | options are  |
|       |              |              |              | ignored. See |
|       |              |              |              | the          |
|       |              |              |              | streaming    |
|       |              |              |              | docs         |
|       |              |              |              | \[           |
|       |              |              |              | STREAMING\]. |
+-------+--------------+--------------+--------------+--------------+
| > 10  | NO\_ACK      | > \--        | > \--        | This flag    |
|       |              |              |              | simply tells |
|       |              |              |              | the          |
|       |              |              |              | recipient to |
|       |              |              |              | ignore the   |
|       |              |              |              | ackThrough   |
|       |              |              |              | field in the |
|       |              |              |              | header.      |
|       |              |              |              | Currently    |
|       |              |              |              | set in the   |
|       |              |              |              | inital SYN   |
|       |              |              |              | packet,      |
|       |              |              |              | otherwise    |
|       |              |              |              | the          |
|       |              |              |              | ackThrough   |
|       |              |              |              | field is     |
|       |              |              |              | always       |
|       |              |              |              | valid. Note  |
|       |              |              |              | that this    |
|       |              |              |              | does not     |
|       |              |              |              | save any     |
|       |              |              |              | space, the   |
|       |              |              |              | ackThrough   |
|       |              |              |              | field is     |
|       |              |              |              | before the   |
|       |              |              |              | flags and is |
|       |              |              |              | always       |
|       |              |              |              | present.     |
+-------+--------------+--------------+--------------+--------------+
| > 11  | OFFLIN       | > 4          | variable     | Contains the |
|       | E\_SIGNATURE |              | length       | offline      |
| 12-15 |              |              | \[           | signature    |
|       | unused       |              | OfflineSig\] | section from |
|       |              |              |              | LS2. See     |
|       |              |              |              | proposal 123 |
|       |              |              |              | and the      |
|       |              |              |              | common       |
|       |              |              |              | structures   |
|       |              |              |              | sp           |
|       |              |              |              | ecification. |
|       |              |              |              | FR           |
|       |              |              |              | OM\_INCLUDED |
|       |              |              |              | must also be |
|       |              |              |              | set.         |
|       |              |              |              | Contains an  |
|       |              |              |              | \[           |
|       |              |              |              | OfflineSig\] |
|       |              |              |              | : 1) Expires |
|       |              |              |              | timestamp (4 |
|       |              |              |              | bytes,       |
|       |              |              |              | seconds      |
|       |              |              |              | since epoch, |
|       |              |              |              | rolls over   |
|       |              |              |              | in 2106) 2)  |
|       |              |              |              | Transient    |
|       |              |              |              | sig type (2  |
|       |              |              |              | bytes) 3)    |
|       |              |              |              | Transient    |
|       |              |              |              | \[Signin     |
|       |              |              |              | gPublicKey\] |
|       |              |              |              | (length as   |
|       |              |              |              | implied by   |
|       |              |              |              | sig type) 4) |
|       |              |              |              | \            |
|       |              |              |              | [Signature\] |
|       |              |              |              | of expires   |
|       |              |              |              | timestamp,   |
|       |              |              |              | transient    |
|       |              |              |              | sig type,    |
|       |              |              |              | and public   |
|       |              |              |              | key, by the  |
|       |              |              |              | destination  |
|       |              |              |              | public key.  |
|       |              |              |              | Length of    |
|       |              |              |              | sig as       |
|       |              |              |              | implied by   |
|       |              |              |              | by the       |
|       |              |              |              | destination  |
|       |              |              |              | public key   |
|       |              |              |              | sig type.    |
|       |              |              |              |              |
|       |              |              |              | Set to zero  |
|       |              |              |              | for          |
|       |              |              |              | c            |
|       |              |              |              | ompatibility |
|       |              |              |              | with future  |
|       |              |              |              | uses.        |
+-------+--------------+--------------+--------------+--------------+

#### Variable Length Signature Notes

Prior to release 0.9.11, the signature in the option field was always 40
bytes.

As of release 0.9.11, the signature is variable length. The Signature
type and length are inferred from the type of key used in the
FROM\_INCLUDED option and the \[Signature\] documentation.

As of release 0.9.39, the OFFLINE\_SIGNATURE option is supported. If
this option is present, the transient \[SigningPublicKey\] is used to
verify any signed packets, and the signature length and type are
inferred from the transient \[SigningPublicKey\] in the option.

-   When a packet contains both FROM\_INCLUDED and SIGNATURE\_INCLUDED
    (as in SYNCHRONIZE), the inference may be made directly.
-   When a packet does not contain FROM\_INCLUDED, the inference must be
    made from a previous SYNCHRONIZE packet.
-   When a packet does not contain FROM\_INCLUDED, and there was no
    previous SYNCHRONIZE packet (for example a stray CLOSE or RESET
    packet), the inference can be made from the length of the remaining
    options (since SIGNATURE\_INCLUDED is the last option), but the
    packet will probably be discarded anyway, since there is no FROM
    available to validate the signature. If more option fields are
    defined in the future, they must be accounted for.

References
----------

\[Destination\]

:   <https://geti2p.net/spec/common-structures#struct-destination>

\[Integer\]

:   <https://geti2p.net/spec/common-structures#type-integer>

\[OfflineSig\]

:   <https://geti2p.net/spec/common-structures#struct-offlinesignature>

\[Signature\]

:   <https://geti2p.net/spec/common-structures#type-signature>

\[SigningPrivateKey\]

:   <https://geti2p.net/spec/common-structures#type-signingprivatekey>

\[SigningPublicKey\]

:   <https://geti2p.net/spec/common-structures#type-signingpublickey>

\[STREAMING\]

:   <https://geti2p.net/en/docs/api/streaming>
