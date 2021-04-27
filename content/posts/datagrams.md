---
title: "Datagrams"
date: 2021-04-27T14:39:35-04:00
draft: true
---

Datagram Specification
======================

Category: Protocols Last updated: February 2019 Accurate for: 0.9.39

Overview
--------

See \[DATAGRAMS\] for an overview of the Datagrams API.

Non-Repliable Datagrams {#raw}
-----------------------

Non-repliable datagrams have no \'from\' address and are not
authenticated. They are also called \"raw\" datagrams. Strictly
speaking, they are not \"datagrams\" at all, they are just raw data.
They are not handled by the datagram API. However, SAM and the I2PTunnel
classes support \"raw datagrams\".

The standard I2CP protocol number for raw datagrams is
PROTO\_DATAGRAM\_RAW (18).

### Format

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--// \| payload\...
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--//
>
> length: 0 - unlimited (see notes)

### Notes

The practical length is limited by lower layers of protocols - the
tunnel message spec \[TUNMSG\] limits messages to about 61.2 KB and the
transports \[TRANSPORT\] currently limit messages to about 32 KB,
although this may be raised in the future.

Repliable Datagrams {#repliable}
-------------------

Repliable datagrams contain a \'from\' address and a signature. These
add at least 427 bytes of overhead.

The standard I2CP protocol number for repliable datagrams is
PROTO\_DATAGRAM (17).

### Format

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> from \| + + \| \| \~ \~ \~ \~ \| \| + + \| \| \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> signature \| + + \| \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> payload\... +\-\-\--+\-\-\--+\-\-\--+\-\-\--//
>
> from :: a \[Destination\]
>
> :   length: 387+ bytes The originator and signer of the datagram
>
> signature :: a \[Signature\]
>
> :   Signature type must match the signing public key type of \$from
>     length: 40+ bytes, as implied by the Signature type. For the
>     default DSA\_SHA1 key type: The DSA \[Signature\] of the SHA-256
>     hash of the payload. For other key types: The \[Signature\] of the
>     payload. The signature may be verified by the signing public key
>     of \$from
>
> payload :: The data
>
> :   Length: 0 to \~31.5 KB (see notes)
>
> Total length: Payload length + 427+

\[Destination\]: /spec/common-structures\#struct-destination
\[Signature\]: /spec/common-structures\#type-signature

### Notes

-   The practical length is limited by lower layers of protocols - the
    transports \[TRANSPORT\] currently limit messages to about 32 KB, so
    the data length here is limited to about 31.5 KB.
-   See important notes about the reliability of large datagrams
    \[DATAGRAMS\]. For best results, limit the payload to about 10 KB or
    less.
-   Signatures for types other than DSA\_SHA1 were redefined in release
    0.9.14.
-   The format does not support inclusion of an offline signature block
    for LS2 (proposal 123). A new protocol with flags must be defined
    for that.

References
----------

\[DATAGRAMS\]

:   <https://geti2p.net/en/docs/api/datagrams>

\[TRANSPORT\]

:   <https://geti2p.net/en/docs/transport>

\[TUNMSG\]

:   <https://geti2p.net/spec/tunnel-message#notes>
