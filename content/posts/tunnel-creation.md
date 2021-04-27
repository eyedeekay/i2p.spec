---
title: "Tunnel Creation"
date: 2021-04-27T14:39:34-04:00
draft: true
---

Tunnel Creation Specification
=============================

Category: Design Last updated: July 2019 Accurate for: 0.9.41

Overview {#tunnelCreate.overview}
--------

This document specifies the details of the encrypted tunnel build
messages used to create tunnels using a \"non-interactive telescoping\"
method. See the tunnel build document \[TUNNEL-IMPL\] for an overview of
the process, including peer selection and ordering methods.

The tunnel creation is accomplished by a single message passed along the
path of peers in the tunnel, rewritten in place, and transmitted back to
the tunnel creator. This single tunnel message is made up of a variable
number of records (up to 8) - one for each potential peer in the tunnel.
Individual records are asymmetrically (ElGamal \[CRYPTO-ELG\] )
encrypted to be read only by a specific peer along the path, while an
additional symmetric layer of encryption (AES \[CRYPTO-AES\] ) is added
at each hop so as to expose the asymmetrically encrypted record only at
the appropriate time.

### Number of Records {#number}

Not all records must contain valid data. The build message for a 3-hop
tunnel, for example, may contain more records to hide the actual length
of the tunnel from the participants. There are two build message types.
The original Tunnel Build Message (\[TBM\] ) contains 8 records, which
is more than enough for any practical tunnel length. The newer Variable
Tunnel Build Message (\[VTBM\] ) contains 1 to 8 records. The originator
may trade off the size of the message with the desired amount of tunnel
length obfuscation.

In the current network, most tunnels are 2 or 3 hops long. The current
implementation uses a 5-record VTBM to build tunnels of 4 hops or less,
and the 8-record TBM for longer tunnels. The 5-record VTBM (which, when
fragmented, fits in three 1KB tunnel messaages) reduces network traffic
and increases build sucess rate, because smaller messages are less
likely to be dropped.

The reply message must be the same type and length as the build message.

### Request Record Specification {#tunnelCreate.requestRecord}

Also specified in the I2NP Specification \[BRR\].

Cleartext of the record, visible only to the hop being asked:

    bytes     0-3: tunnel ID to receive messages as, nonzero
    bytes    4-35: local router identity hash
    bytes   36-39: next tunnel ID, nonzero
    bytes   40-71: next router identity hash
    bytes  72-103: AES-256 tunnel layer key
    bytes 104-135: AES-256 tunnel IV key
    bytes 136-167: AES-256 reply key
    bytes 168-183: AES-256 reply IV
    byte      184: flags
    bytes 185-188: request time (in hours since the epoch, rounded down)
    bytes 189-192: next message ID
    bytes 193-221: uninterpreted / random padding

The next tunnel ID and next router identity hash fields are used to
specify the next hop in the tunnel, though for an outbound tunnel
endpoint, they specify where the rewritten tunnel creation reply message
should be sent. In addition, the next message ID specifies the message
ID that the message (or reply) should use.

The tunnel layer key, tunnel IV key, reply key, and reply IV are each
random 32-byte values generated by the creator, for use in this build
request record only.

The flags field contains the following:

    Bit order: 76543210 (bit 7 is MSB)
    bit 7: if set, allow messages from anyone
    bit 6: if set, allow messages to anyone, and send the reply to the
           specified next hop in a Tunnel Build Reply Message
    bits 5-0: Undefined, must set to 0 for compatibility with future options

Bit 7 indicates that the hop will be an inbound gateway (IBGW). Bit 6
indicates that the hop will be an outbound endpoint (OBEP). If neither
bit is set, the hop will be an intermediate participant. Both cannot be
set at once.

#### Request Record Creation

Every hop gets a random Tunnel ID, nonzero. The current and next-hop
Tunnel IDs are filled in. Every record gets a random tunnel IV key,
reply IV, layer key, and reply key.

#### Request Record Encryption {#encryption}

That cleartext record is ElGamal 2048 encrypted \[CRYPTO-ELG\] with the
hop\'s public encryption key and formatted into a 528 byte record:

    bytes   0-15: First 16 bytes of the SHA-256 of the current hop's router identity
    bytes 16-527: ElGamal-2048 encrypted request record

In the 512-byte encrypted record, the ElGamal data contains bytes 1-256
and 258-513 of the 514-byte ElGamal encrypted block \[CRYPTO-ELG\]. The
two padding bytes from the block (the zero bytes at locations 0 and 257)
are removed.

Since the cleartext uses the full field, there is no need for additional
padding beyond `SHA256(cleartext) + cleartext`.

Each 528-byte record is then iteratively encrypted (using AES
decryption, with the reply key and reply IV for each hop) so that the
router identity will only be in cleartext for the hop in question.

### Hop Processing and Encryption {#tunnelCreate.hopProcessing}

When a hop receives a TunnelBuildMessage, it looks through the records
contained within it for one starting with their own identity hash
(trimmed to 16 bytes). It then decrypts the ElGamal block from that
record and retrieves the protected cleartext. At that point, they make
sure the tunnel request is not a duplicate by feeding the AES-256 reply
key into a Bloom filter. Duplicates or invalid requests are dropped.
Records that are not stamped with the current hour, or the previous hour
if shortly after the top of the hour, must be dropped. For example, take
the hour in the timestamp, convert to a full time, then if it\'s more
than 65 minutes behind or 5 minutes ahead of the current time, it is
invalid. The Bloom filter must have a duration of at least one hour
(plus a few minutes, to allow for clock skew), so that duplicate records
in the current hour that are not rejected by checking the hour timestamp
in the record, will be rejected by the filter.

After deciding whether they will agree to participate in the tunnel or
not, they replace the record that had contained the request with an
encrypted reply block. All other records are AES-256 encrypted
\[CRYPTO-AES\] with the included reply key and IV. Each is AES/CBC
encrypted separately with the same reply key and reply IV. The CBC mode
is not continued (chained) across records.

Each hop knows only its own response. If it agrees, it will maintain the
tunnel until expiration, even if it will not be used, as it cannot know
whether all other hops agreed.

#### Reply Record Specification {#tunnelCreate.replyRecord}

After the current hop reads their record, they replace it with a reply
record stating whether or not they agree to participate in the tunnel,
and if they do not, they classify their reason for rejection. This is
simply a 1 byte value, with 0x0 meaning they agree to participate in the
tunnel, and higher values meaning higher levels of rejection.

The following rejection codes are defined:

-   TUNNEL\_REJECT\_PROBABALISTIC\_REJECT = 10
-   TUNNEL\_REJECT\_TRANSIENT\_OVERLOAD = 20
-   TUNNEL\_REJECT\_BANDWIDTH = 30
-   TUNNEL\_REJECT\_CRIT = 50

To hide other causes, such as router shutdown, from peers, the current
implementation uses TUNNEL\_REJECT\_BANDWIDTH for almost all rejections.

The reply is encrypted with the AES session key delivered to it in the
encrypted block, padded with 495 bytes of random data to reach the full
record size. The padding is placed before the status byte:

    AES-256-CBC(SHA-256(padding+status) + padding + status, key, IV)

    bytes   0-31 : SHA-256 of bytes 32-527
    bytes 32-526 : Random padding
    byte 527     : Reply value

This is also described in the I2NP spec \[BRR\].

### Tunnel Build Message Preparation {#tunnelCreate.requestPreparation}

When building a new Tunnel Build Message, all of the Build Request
Records must first be built and asymmetrically encrypted using ElGamal
\[CRYPTO-ELG\]. Each record is then premptively decrypted with the reply
keys and IVs of the hops earlier in the path, using AES \[CRYPTO-AES\].
That decryption should be run in reverse order so that the
asymmetrically encrypted data will show up in the clear at the right hop
after their predecessor encrypts it.

The excess records not needed for individual requests are simply filled
with random data by the creator.

### Tunnel Build Message Delivery {#tunnelCreate.requestDelivery}

For outbound tunnels, the delivery is done directly from the tunnel
creator to the first hop, packaging up the TunnelBuildMessage as if the
creator was just another hop in the tunnel. For inbound tunnels, the
delivery is done through an existing outbound tunnel. The outbound
tunnel is generally from the same pool as the new tunnel being built. If
no outbound tunnel is available in that pool, an outbound exploratory
tunnel is used. At startup, when no outbound exploratory tunnel exists
yet, a fake 0-hop outbound tunnel is used.

### Tunnel Build Message Endpoint Handling {#tunnelCreate.endpointHandling}

For creation of an outbound tunnel, when the request reaches an outbound
endpoint (as determined by the \'allow messages to anyone\' flag), the
hop is processed as usual, encrypting a reply in place of the record and
encrypting all of the other records, but since there is no \'next hop\'
to forward the TunnelBuildMessage on to, it instead places the encrypted
reply records into a TunnelBuildReplyMessage (\[TBRM\] ) or
VariableTunnelBuildReplyMessage (\[VTBRM\] ) (the type of message and
number of records must match that of the request) and delivers it to the
reply tunnel specified within the request record. That reply tunnel
forwards the Tunnel Build Reply Message back to the tunnel creator, just
as for any other message \[TUNNEL-OP\]. The tunnel creator then
processes it, as described below.

The reply tunnel was selected by the creator as follows: Generally it is
an inbound tunnel from the same pool as the new outbound tunnel being
built. If no inbound tunnel is available in that pool, an inbound
exploratory tunnel is used. At startup, when no inbound exploratory
tunnel exists yet, a fake 0-hop inbound tunnel is used.

For creation of an inbound tunnel, when the request reaches the inbound
endpoint (also known as the tunnel creator), there is no need to
generate an explicit Tunnel Build Reply Message, and the router
processes each of the replies, as below.

### Tunnel Build Reply Message Processing {#tunnelCreate.replyProcessing}

To process the reply records, the creator simply has to AES decrypt each
record individually, using the reply key and IV of each hop in the
tunnel after the peer (in reverse order). This then exposes the reply
specifying whether they agree to participate in the tunnel or why they
refuse. If they all agree, the tunnel is considered created and may be
used immediately, but if anyone refuses, the tunnel is discarded.

The agreements and rejections are noted in each peer\'s profile
\[PEER-SELECTION\], to be used in future assessments of peer tunnel
capacity.

History and Notes {#tunnelCreate.notes}
-----------------

This strategy came about during a discussion on the I2P mailing list
between Michael Rogers, Matthew Toseland (toad), and jrandom regarding
the predecessor attack. See \[TUNBUILD-SUMMARY\],
\[TUNBUILD-REASONING\]. It was introduced in release 0.6.1.10 on
2006-02-16, which was the last time a non-backward-compatible change was
made in I2P.

Notes:

-   This design does not prevent two hostile peers within a tunnel from
    tagging one or more request or reply records to detect that they are
    within the same tunnel, but doing so can be detected by the tunnel
    creator when reading the reply, causing the tunnel to be marked as
    invalid.
-   This design does not include a proof of work on the asymmetrically
    encrypted section, though the 16 byte identity hash could be cut in
    half with the latter replaced by a hashcash function of up to 2\^64
    cost.
-   This design alone does not prevent two hostile peers within a tunnel
    from using timing information to determine whether they are in the
    same tunnel. The use of batched and synchronized request delivery
    could help (batching up requests and sending them off on the
    (ntp-synchronized) minute). However, doing so lets peers \'tag\' the
    requests by delaying them and detecting the delay later in the
    tunnel, though perhaps dropping requests not delivered in a small
    window would work (though doing that would require a high degree of
    clock synchronization). Alternately, perhaps individual hops could
    inject a random delay before forwarding on the request?
-   Are there any nonfatal methods of tagging the request?
-   The timestamp with a one-hour resolution is used for replay
    prevention. The constraint was not enforced until release 0.9.16.

Future Work {#future}
-----------

-   In the current implementation, the originator leaves one record
    empty for itself. Thus a message of n records can only build a
    tunnel of n-1 hops. This appears to be necessary for inbound tunnels
    (where the next-to-last hop can see the hash prefix for the next
    hop), but not for outbound tunnels. This is to be researched and
    verified. If it is possible to use the remaining record without
    compromising anonymity, we should do so.
-   Further analysis of possible tagging and timing attacks described in
    the above notes.
-   Use only VTBM; do not select old peers that don\'t support it.
-   The Build Request Record does not specify a tunnel lifetime or
    expiration; each hop expires the tunnel after 10 minutes, which is a
    network-wide hardcoded constant. We could use a bit in the flag
    field and take 4 (or 8) bytes out of the padding to specify a
    lifetime or expiration. The requestor would only specify this option
    if all participants supported it.

References {#ref}
----------

\[BRR\]

:   <https://geti2p.net/spec/i2np#struct-buildrequestrecord>

\[CRYPTO-AES\]

:   <https://geti2p.net/en/docs/how/cryptography#AES>

\[CRYPTO-ELG\]

:   <https://geti2p.net/en/docs/how/cryptography#elgamal>

\[HASHING-IT-OUT\]

:   <http://www-users.cs.umn.edu/~hopper/hashing_it_out.pdf>

\[PEER-SELECTION\]

:   <https://geti2p.net/en/docs/how/peer-selection>

\[PREDECESSOR\]

:   <http://forensics.umass.edu/pubs/wright-tissec.pdf>

\[PREDECESSOR-2008\]

:   <http://forensics.umass.edu/pubs/wright.tissec.2008.pdf>

\[TBM\]

:   <https://geti2p.net/spec/i2np#msg-tunnelbuild>

\[TBRM\]

:   <https://geti2p.net/spec/i2np#msg-tunnelbuildreply>

\[TUNBUILD-REASONING\]

:   <http://zzz.i2p/archive/2005-10/msg00129.html>

\[TUNBUILD-SUMMARY\]

:   <http://zzz.i2p/archive/2005-10/msg00138.html>

\[TUNNEL-IMPL\]

:   <https://geti2p.net/en/docs/tunnels/implementation>

\[TUNNEL-OP\]

:   <https://geti2p.net/en/docs/tunnels/implementation#tunnel.operation>

\[VTBM\]

:   <https://geti2p.net/spec/i2np#msg-variabletunnelbuild>

\[VTBRM\]

:   <https://geti2p.net/spec/i2np#msg-variabletunnelbuildreply>