---
title: "Tunnel Creation Ecies"
date: 2021-04-27T14:39:35-04:00
draft: true
---

ECIES-X25519 Tunnel Creation
============================

Category: Protocols Last updated: 2021-03 Accurate for: 0.9.49

Overview
--------

This document specifies Tunnel Build message encryption using crypto
primitives introduced by \[ECIES-X25519\]. It is a portion of the
overall proposal \[Prop156\] for converting routers from ElGamal to
ECIES-X25519 keys. This specification is implemented as of release
0.9.48.

For the purposes of transitioning the network from ElGamal + AES256 to
ECIES + ChaCha20, tunnels with mixed ElGamal and ECIES routers are
necessary. Specifications for handling mixed tunnel hops are provided.
No changes will be made to the format, processing, or encryption of
ElGamal hops.

ElGamal tunnel creators will generate ephemeral X25519 keypairs per-hop,
and follow this spec for creating tunnels containing ECIES hops.

This document specifies ECIES-X25519 Tunnel Building. For an overview of
all changes required for ECIES routers, see proposal 156 \[Prop156\].
For additional background on the development of this specification, see
proposal 152 \[Prop152\].

This format maintains the same size for tunnel build records, as
required for compatibility. Smaller build records and messages will be
implemented later - see \[Prop157\].

### Cryptographic Primitives

The primitives required to implement this specification are:

-   AES-256-CBC as in \[Cryptography\]
-   STREAM ChaCha20/Poly1305 functions: ENCRYPT(k, n, plaintext, ad) and
    DECRYPT(k, n, ciphertext, ad) - as in \[NTCP2\] \[ECIES-X25519\] and
    \[RFC-7539\]
-   X25519 DH functions - as in \[NTCP2\] and \[ECIES-X25519\]
-   HKDF(salt, ikm, info, n) - as in \[NTCP2\] and \[ECIES-X25519\]

Other Noise functions defined elsewhere:

-   MixHash(d) - as in \[NTCP2\] and \[ECIES-X25519\]
-   MixKey(d) - as in \[NTCP2\] and \[ECIES-X25519\]

Design
------

### Noise Protocol Framework

This specification provides the requirements based on the Noise Protocol
Framework \[NOISE\] (Revision 34, 2018-07-11). In Noise parlance, Alice
is the initiator, and Bob is the responder.

It is based on the Noise protocol Noise\_N\_25519\_ChaChaPoly\_SHA256.
This Noise protocol uses the following primitives:

-   One-Way Handshake Pattern: N Alice does not transmit her static key
    to Bob (N)
-   DH Function: X25519 X25519 DH with a key length of 32 bytes as
    specified in \[RFC-7748\].
-   Cipher Function: ChaChaPoly AEAD\_CHACHA20\_POLY1305 as specified in
    \[RFC-7539\] section 2.8. 12 byte nonce, with the first 4 bytes set
    to zero. Identical to that in \[NTCP2\].
-   Hash Function: SHA256 Standard 32-byte hash, already used
    extensively in I2P.

### Handshake Patterns

Handshakes use \[Noise\] handshake patterns.

The following letter mapping is used:

-   e = one-time ephemeral key
-   s = static key
-   p = message payload

The build request is identical to the Noise N pattern. This is also
identical to the first (Session Request) message in the XK pattern used
in \[NTCP2\].

> \<- s \... e es p -\>

### Request encryption

Build request records are created by the tunnel creator and
asymmetrically encrypted to the individual hop. This asymmetric
encryption of request records is currently ElGamal as defined in
\[Cryptography\] and contains a SHA-256 checksum. This design is not
forward-secret.

The ECIES design uses the one-way Noise pattern \"N\" with ECIES-X25519
ephemeral-static DH, with an HKDF, and ChaCha20/Poly1305 AEAD for
forward secrecy, integrity, and authentication. Alice is the tunnel
build requestor. Each hop in the tunnel is a Bob.

### Reply encryption

Build reply records are created by the hops creator and symmetrically
encrypted to the creator. This symmetric encryption of ElGamal reply
records is AES with a prepended SHA-256 checksum. and contains a SHA-256
checksum. This design is not forward-secret.

ECIES replies use ChaCha20/Poly1305 AEAD for integrity, and
authentication.

Specification
-------------

### Build Request Records

Encrypted BuildRequestRecords are 528 bytes for both ElGamal and ECIES,
for compatibility.

#### Request Record Unencrypted

This is the specification of the tunnel BuildRequestRecord for
ECIES-X25519 routers. Summary of changes:

-   Remove unused 32-byte router hash
-   Change request time from hours to minutes
-   Add expiration field for future variable tunnel time
-   Add more space for flags
-   Add Mapping for additional build options
-   AES-256 reply key and IV are not used for the hop\'s own reply
    record
-   Unencrypted record is longer because there is less encryption
    overhead

The request record does not contain any ChaCha reply keys. Those keys
are derived from a KDF. See below.

All fields are big-endian.

Unencrypted size: 464 bytes

> bytes 0-3: tunnel ID to receive messages as, nonzero bytes 4-7: next
> tunnel ID, nonzero bytes 8-39: next router identity hash bytes 40-71:
> AES-256 tunnel layer key bytes 72-103: AES-256 tunnel IV key bytes
> 104-135: AES-256 reply key bytes 136-151: AES-256 reply IV byte 152:
> flags bytes 153-155: more flags, unused, set to 0 for compatibility
> bytes 156-159: request time (in minutes since the epoch, rounded down)
> bytes 160-163: request expiration (in seconds since creation) bytes
> 164-167: next message ID bytes 168-x: tunnel build options (Mapping)
> bytes x-x: other data as implied by flags or options bytes x-463:
> random padding

The flags field is the same as defined in \[Tunnel-Creation\] and
contains the following:

    Bit order: 76543210 (bit 7 is MSB)
    bit 7: if set, allow messages from anyone
    bit 6: if set, allow messages to anyone, and send the reply to the
           specified next hop in a Tunnel Build Reply Message
    bits 5-0: Undefined, must set to 0 for compatibility with future options

Bit 7 indicates that the hop will be an inbound gateway (IBGW). Bit 6
indicates that the hop will be an outbound endpoint (OBEP). If neither
bit is set, the hop will be an intermediate participant. Both cannot be
set at once.

The request exipration is for future variable tunnel duration. For now,
the only supported value is 600 (10 minutes).

The tunnel build options is a Mapping structure as defined in
\[Common\]. This is for future use. No options are currently defined. If
the Mapping structure is empty, this is two bytes 0x00 0x00. The maximum
size of the Mapping (including the length field) is 296 bytes, and the
maximum value of the Mapping length field is 294.

#### Request Record Encrypted

All fields are big-endian except for the ephemeral public key which is
little-endian.

Encrypted size: 528 bytes

> bytes 0-15: Hop\'s truncated identity hash bytes 16-47: Sender\'s
> ephemeral X25519 public key bytes 48-511: ChaCha20 encrypted
> BuildRequestRecord bytes 512-527: Poly1305 MAC

### Build Reply Records

Encrypted BuildReplyRecords are 528 bytes for both ElGamal and ECIES,
for compatibility.

#### Reply Record Unencrypted

This is the specification of the tunnel BuildReplyRecord for
ECIES-X25519 routers. Summary of changes:

-   Add Mapping for build reply options
-   Unencrypted record is longer because there is less encryption
    overhead

ECIES replies are encrypted with ChaCha20/Poly1305.

All fields are big-endian.

Unencrypted size: 512 bytes

> bytes 0-x: Tunnel Build Reply Options (Mapping) bytes x-x: other data
> as implied by options bytes x-510: Random padding byte 511: Reply byte

The tunnel build reply options is a Mapping structure as defined in
\[Common\]. This is for future use. No options are currently defined. If
the Mapping structure is empty, this is two bytes 0x00 0x00. The maximum
size of the Mapping (including the length field) is 511 bytes, and the
maximum value of the Mapping length field is 509.

The reply byte is one of the following values as defined in
\[Tunnel-Creation\] to avoid fingerprinting:

-   0x00 (accept)
-   30 (TUNNEL\_REJECT\_BANDWIDTH)

#### Reply Record Encrypted

Encrypted size: 528 bytes

> bytes 0-511: ChaCha20 encrypted BuildReplyRecord bytes 512-527:
> Poly1305 MAC

After full transition to ECIES records, ranged padding rules are the
same as for request records.

### Symmetric Encryption of Records

Mixed tunnels are allowed, and necessary, for the transition from
ElGamal to ECIES. During the transitionary period, an increasing number
of routers will be keyed under ECIES keys.

Symmetric cryptography preprocessing will run in the same way:

-   \"encryption\":
    -   cipher run in decryption mode
    -   request records preemptively decrypted in preprocessing
        (concealing encrypted request records)
-   \"decryption\":
    -   cipher run in encryption mode
    -   request records encrypted (revealing next plaintext request
        record) by participant hops
-   ChaCha20 does not have \"modes\", so it is simply run three times:
    -   once in preprocessing
    -   once by the hop
    -   once on final reply processing

When mixed tunnels are used, tunnel creators will need to base the
symmetric encryption of BuildRequestRecord on the current and previous
hop\'s encryption type.

Each hop will use its own encryption type for encrypting
BuildReplyRecords, and the other records in the
VariableTunnelBuildMessage (VTBM).

On the reply path, the endpoint (sender) will need to undo the
\[Multiple-Encryption\], using each hop\'s reply key.

As a clarifying example, let\'s look at an outbound tunnel w/ ECIES
surrounded by ElGamal:

-   Sender (OBGW) -\> ElGamal (H1) -\> ECIES (H2) -\> ElGamal (H3)

All BuildRequestRecords are in their encrypted state (using ElGamal or
ECIES).

AES256/CBC cipher, when used, is still used for each record, without
chaining across multiple records.

Likewise, ChaCha20 will be used to encrypt each record, not streaming
across the entire VTBM.

The request records are preprocessed by the Sender (OBGW):

-   H3\'s record is \"encrypted\" using:
    -   H2\'s reply key (ChaCha20)
    -   H1\'s reply key (AES256/CBC)
-   H2\'s record is \"encrypted\" using:
    -   H1\'s reply key (AES256/CBC)
-   H1\'s record goes out without symmetric encryption

Only H2 checks the reply encryption flag, and sees its followed by
AES256/CBC.

After being processed by each hop, the records are in a \"decrypted\"
state:

-   H3\'s record is \"decrypted\" using:
    -   H3\'s reply key (AES256/CBC)
-   H2\'s record is \"decrypted\" using:
    -   H3\'s reply key (AES256/CBC)
    -   H2\'s reply key (ChaCha20-Poly1305)
-   H1\'s record is \"decrypted\" using:
    -   H3\'s reply key (AES256/CBC)
    -   H2\'s reply key (ChaCha20)
    -   H1\'s reply key (AES256/CBC)

The tunnel creator, a.k.a. Inbound Endpoint (IBEP), postprocesses the
reply:

-   H3\'s record is \"encrypted\" using:
    -   H3\'s reply key (AES256/CBC)
-   H2\'s record is \"encrypted\" using:
    -   H3\'s reply key (AES256/CBC)
    -   H2\'s reply key (ChaCha20-Poly1305)
-   H1\'s record is \"encrypted\" using:
    -   H3\'s reply key (AES256/CBC)
    -   H2\'s reply key (ChaCha20)
    -   H1\'s reply key (AES256/CBC)

### Request Record Keys

These keys are explicitly included in ElGamal BuildRequestRecords. For
ECIES BuildRequestRecords, the tunnel keys and AES reply keys are
included, but the ChaCha reply keys are derived from the DH exchange.
See \[Prop156\] for details of the router static ECIES keys.

Below is a description of how to derive the keys previously transmitted
in request records.

#### KDF for Initial ck and h

This is standard \[NOISE\] for pattern \"N\" with a standard protocol
name.

> This is the \"e\" message pattern:
>
> // Define protocol\_name. Set protocol\_name =
> \"Noise\_N\_25519\_ChaChaPoly\_SHA256\" (31 bytes, US-ASCII encoded,
> no NULL termination).
>
> // Define Hash h = 32 bytes // Pad to 32 bytes. Do NOT hash it,
> because it is not more than 32 bytes. h = protocol\_name \|\| 0
>
> Define ck = 32 byte chaining key. Copy the h data to ck. Set chainKey
> = h
>
> // MixHash(null prologue) h = SHA256(h);
>
> // up until here, can all be precalculated by all routers.

#### KDF for Request Record

ElGamal tunnel creators generate an ephemeral X25519 keypair for each
ECIES hop in the tunnel, and use scheme above for encrypting their
BuildRequestRecord. ElGamal tunnel creators will use the scheme prior to
this spec for encrypting to ElGamal hops.

ECIES tunnel creators will need to encrypt to each of the ElGamal hop\'s
public key using the scheme defined in \[Tunnel-Creation\]. ECIES tunnel
creators will use the above scheme for encrypting to ECIES hops.

This means that tunnel hops will only see encrypted records from their
same encryption type.

For ElGamal and ECIES tunnel creators, they will generate unique
ephemeral X25519 keypairs per-hop for encrypting to ECIES hops.

**IMPORTANT**: Ephemeral keys must be unique per ECIES hop, and per
build record. Failing to use unique keys opens an attack vector for
colluding hops to confirm they are in the same tunnel.

> // Each hop\'s X25519 static keypair (hesk, hepk) from the Router
> Identity hesk = GENERATE\_PRIVATE() hepk = DERIVE\_PUBLIC(hesk)
>
> // MixHash(hepk) // \|\| below means append h = SHA256(h \|\| hepk);
>
> // up until here, can all be precalculated by each router // for all
> incoming build requests
>
> // Sender generates an X25519 ephemeral keypair per ECIES hop in the
> VTBM (sesk, sepk) sesk = GENERATE\_PRIVATE() sepk =
> DERIVE\_PUBLIC(sesk)
>
> // MixHash(sepk) h = SHA256(h \|\| sepk);
>
> End of \"e\" message pattern.
>
> This is the \"es\" message pattern:
>
> // Noise es // Sender performs an X25519 DH with Hop\'s static public
> key. // Each Hop, finds the record w/ their truncated identity hash,
> // and extracts the Sender\'s ephemeral key preceding the encrypted
> record. sharedSecret = DH(sesk, hepk) = DH(hesk, sepk)
>
> // MixKey(DH()) //\[chainKey, k\] = MixKey(sharedSecret) // ChaChaPoly
> parameters to encrypt/decrypt keydata = HKDF(chainKey, sharedSecret,
> \"\", 64) // Save for Reply Record KDF chainKey = keydata\[0:31\]
>
> // AEAD parameters k = keydata\[32:64\] n = 0 plaintext = 464 byte
> build request record ad = h ciphertext = ENCRYPT(k, n, plaintext, ad)
>
> End of \"es\" message pattern.
>
> // MixHash(ciphertext) // Save for Reply Record KDF h = SHA256(h \|\|
> ciphertext)

`replyKey`, `layerKey` and `layerIV` must still be included inside
ElGamal records, and can be generated randomly.

### Reply Record Encryption

The reply record is ChaCha20/Poly1305 encrypted.

> // AEAD parameters k = chainkey from build request n = 0 plaintext =
> 512 byte build reply record ad = h from build request
>
> ciphertext = ENCRYPT(k, n, plaintext, ad)

Implementation Notes
--------------------

-   Older routers do not check the encryption type of the hop and will
    send ElGamal-encrypted records. Some recent routers are buggy and
    will send various types of malformed records. Implementers should
    detect and reject these records prior to the DH operation if
    possible, to reduce CPU usage.

References
----------

\[Common\]

:   <https://geti2p.net/spec/common-structures>

\[Cryptography\]

:   <https://geti2p.net/spec/cryptography>

\[ECIES-X25519\]

:   <https://geti2p.net/spec/ecies>

\[I2NP\]

:   <https://geti2p.net/spec/i2np>

\[NOISE\]

:   <https://noiseprotocol.org/noise.html>

\[NTCP2\]

:   <https://geti2p.net/spec/ntcp2>

\[Prop119\]

:   <https://geti2p.net/spec/proposals/119-bidirectional-tunnels>

\[Prop143\]

:   <https://geti2p.net/spec/proposals/143-build-message-options>

\[Prop152\]

:   <https://geti2p.net/spec/proposals/152-ecies-tunnels>

\[Prop153\]

:   <https://geti2p.net/spec/proposals/153-chacha20-layer-encryption>

\[Prop156\]

:   <https://geti2p.net/spec/proposals/156-ecies-routers>

\[Prop157\]

:   <https://geti2p.net/spec/proposals/157-new-tbm>

\[Tunnel-Creation\]

:   <https://geti2p.net/spec/tunnel-creation>

\[Multiple-Encryption\]

:   <https://en.wikipedia.org/wiki/Multiple_encryption>

\[RFC-7539\]

:   <https://tools.ietf.org/html/rfc7539>

\[RFC-7748\]

:   <https://tools.ietf.org/html/rfc7748>
