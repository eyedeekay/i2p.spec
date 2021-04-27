---
title: "Common Structures"
date: 2021-04-27T14:39:34-04:00
draft: false
---

Common structures Specification
===============================

Category: Design Last updated: 2021-04 Accurate for: 0.9.49

This document describes some data types common to all I2P protocols,
like \[I2NP\], \[I2CP\], \[SSU\], etc.

Common type specification
-------------------------

### Integer {#type-Integer}

#### Description

Represents a non-negative integer.

#### Contents

1 to 8 bytes in network byte order (big endian) representing an unsigned
integer.

### Date {#type-Date}

#### Description

The number of milliseconds since midnight on January 1, 1970 in the GMT
timezone. If the number is 0, the date is undefined or null.

#### Contents

8 byte [Integer](#integer)

### String {#type-String}

#### Description

Represents a UTF-8 encoded string.

#### Contents

1 or more bytes where the first byte is the number of bytes (not
characters!) in the string and the remaining 0-255 bytes are the
non-null terminated UTF-8 encoded character array. Length limit is 255
bytes (not characters). Length may be 0.

### PublicKey {#type-PublicKey}

#### Description

This structure is used in ElGamal or other asymmetric encryption,
representing only the exponent, not the primes, which are constant and
defined in the cryptography specification \[ELGAMAL\]. Other encryption
schemes are in the process of being defined, see the table below.

#### Contents

Key type and length are inferred from context or are specified in the
Key Certificate of a Destination or RouterInfo, or the fields in a
[LeaseSet2](#leaseset2) or other data structure. The default type is
ElGamal. As of release 0.9.38, other types may be supported, depending
on context. Keys are big-endian unless otherwise noted.

X25519 keys are supported in Destinations and LeaseSet2 as of release
0.9.44. X25519 keys are supported in RouterIdentities as of release
0.9.48.

+---------+----------------+--------+-----------------------+
| Type    | Length (bytes) | Since  | Usage                 |
+=========+================+========+=======================+
| ElGamal | > 256          |        | All Router Identities |
|         |                |        | and Destinations      |
+---------+----------------+--------+-----------------------+
| P256    | > 64           | > TBD  | Reserved, see         |
|         |                |        | proposal 145          |
+---------+----------------+--------+-----------------------+
| P384    | > 96           | > TBD  | Reserved, see         |
|         |                |        | proposal 145          |
+---------+----------------+--------+-----------------------+
| P521    | > 132          | > TBD  | Reserved, see         |
|         |                |        | proposal 145          |
+---------+----------------+--------+-----------------------+
| X25519  | > 32           | 0.9.38 | Little-endian. See    |
|         |                |        | \[ECIES\] and         |
|         |                |        | \[ECIES-ROUTERS\]     |
+---------+----------------+--------+-----------------------+

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/PublicKey.html>

### PrivateKey {#type-PrivateKey}

#### Description

This structure is used in ElGamal or other asymmetric decryption,
representing only the exponent, not the primes which are constant and
defined in the cryptography specification \[ELGAMAL\]. Other encryption
schemes are in the process of being defined, see the table below.

#### Contents

Key type and length are inferred from context or are stored separately
in a data structure or a private key file. The default type is ElGamal.
As of release 0.9.38, other types may be supported, depending on
context. Keys are big-endian unless otherwise noted.

+---------+----------------+--------+-----------------------+
| Type    | Length (bytes) | Since  | Usage                 |
+=========+================+========+=======================+
| ElGamal | > 256          |        | All Router Identities |
|         |                |        | and Destinations      |
+---------+----------------+--------+-----------------------+
| P256    | > 32           | > TBD  | Reserved, see         |
|         |                |        | proposal 145          |
+---------+----------------+--------+-----------------------+
| P384    | > 48           | > TBD  | Reserved, see         |
|         |                |        | proposal 145          |
+---------+----------------+--------+-----------------------+
| P521    | > 66           | > TBD  | Reserved, see         |
|         |                |        | proposal 145          |
+---------+----------------+--------+-----------------------+
| X25519  | > 32           | 0.9.38 | Little-endian. See    |
|         |                |        | \[ECIES\] and         |
|         |                |        | \[ECIES-ROUTERS\]     |
+---------+----------------+--------+-----------------------+

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/PrivateKey.html>

### SessionKey {#type-SessionKey}

#### Description

This structure is used for symmetric AES256 encryption and decryption.

#### Contents

32 bytes

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/SessionKey.html>

### SigningPublicKey {#type-SigningPublicKey}

#### Description

This structure is used for verifying signatures.

#### Contents

Key type and length are inferred from context or are specified in the
Key Certificate of a Destination. The default type is DSA\_SHA1. As of
release 0.9.12, other types may be supported, depending on context.

+------------------+----------------+--------+------------------+
| Type             | Length (bytes) | Since  | Usage            |
+==================+================+========+==================+
| DSA\_SHA1        | > 128          |        | Legacy Router    |
|                  |                |        | Identities and   |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| ECD              | > 64           | 0.9.12 | Recent           |
| SA\_SHA256\_P256 |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| ECD              | > 96           | 0.9.12 | Rarely used for  |
| SA\_SHA384\_P384 |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| ECD              | > 132          | 0.9.12 | Rarely used for  |
| SA\_SHA512\_P521 |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| R                | > 256          | 0.9.12 | Offline signing, |
| SA\_SHA256\_2048 |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| R                | > 384          | 0.9.12 | Offline signing, |
| SA\_SHA384\_3072 |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| R                | > 512          | 0.9.12 | Offline signing, |
| SA\_SHA512\_4096 |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| EdDSA\           | > 32           | 0.9.15 | Recent Router    |
| _SHA512\_Ed25519 |                |        | Identities and   |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| EdDSA\_S         | > 32           | 0.9.25 | Offline signing, |
| HA512\_Ed25519ph |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| RedDSA\          | > 32           | 0.9.39 | For Destinations |
| _SHA512\_Ed25519 |                |        | and encrypted    |
|                  |                |        | leasesets only,  |
|                  |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities       |
+------------------+----------------+--------+------------------+

#### Notes

-   When a key is composed of two elements (for example points X,Y), it
    is serialized by padding each element to length/2 with leading zeros
    if necessary.
-   All types are Big Endian, except for EdDSA and RedDSA, which are
    stored and transmitted in a Little Endian format.

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/SigningPublicKey.html>

### SigningPrivateKey {#type-SigningPrivateKey}

#### Description

This structure is used for creating signatures.

#### Contents

Key type and length are specified when created. The default type is
DSA\_SHA1. As of release 0.9.12, other types may be supported, depending
on context.

+------------------+----------------+--------+------------------+
| Type             | Length (bytes) | Since  | Usage            |
+==================+================+========+==================+
| DSA\_SHA1        | > 20           |        | Legacy Router    |
|                  |                |        | Identities and   |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| ECD              | > 32           | 0.9.12 | Recent           |
| SA\_SHA256\_P256 |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| ECD              | > 48           | 0.9.12 | Rarely used for  |
| SA\_SHA384\_P384 |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| ECD              | > 66           | 0.9.12 | Rarely used for  |
| SA\_SHA512\_P521 |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| R                | > 512          | 0.9.12 | Offline signing, |
| SA\_SHA256\_2048 |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| R                | > 768          | 0.9.12 | Offline signing, |
| SA\_SHA384\_3072 |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| R                | > 1024         | 0.9.12 | Offline signing, |
| SA\_SHA512\_4096 |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| EdDSA\           | > 32           | 0.9.15 | Recent Router    |
| _SHA512\_Ed25519 |                |        | Identities and   |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| EdDSA\_S         | > 32           | 0.9.25 | Offline signing, |
| HA512\_Ed25519ph |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| RedDSA\          | > 32           | 0.9.39 | For Destinations |
| _SHA512\_Ed25519 |                |        | and encrypted    |
|                  |                |        | leasesets only,  |
|                  |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities       |
+------------------+----------------+--------+------------------+

#### Notes

-   When a key is composed of two elements (for example points X,Y), it
    is serialized by padding each element to length/2 with leading zeros
    if necessary.
-   All types are Big Endian, except for EdDSA and RedDSA, which are
    stored and transmitted in a Little Endian format.

JavaDoc:
<http://echelon.i2p/javadoc/net/i2p/data/SigningPrivateKey.html>

### Signature {#type-Signature}

#### Description

This structure represents the signature of some data.

#### Contents

Signature type and length are inferred from the type of key used. The
default type is DSA\_SHA1. As of release 0.9.12, other types may be
supported, depending on context.

+------------------+----------------+--------+------------------+
| Type             | Length (bytes) | Since  | Usage            |
+==================+================+========+==================+
| DSA\_SHA1        | > 40           |        | Legacy Router    |
|                  |                |        | Identities and   |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| ECD              | > 64           | 0.9.12 | Recent           |
| SA\_SHA256\_P256 |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| ECD              | > 96           | 0.9.12 | Rarely used for  |
| SA\_SHA384\_P384 |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| ECD              | > 132          | 0.9.12 | Rarely used for  |
| SA\_SHA512\_P521 |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| R                | > 256          | 0.9.12 | Offline signing, |
| SA\_SHA256\_2048 |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| R                | > 384          | 0.9.12 | Offline signing, |
| SA\_SHA384\_3072 |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| R                | > 512          | 0.9.12 | Offline signing, |
| SA\_SHA512\_4096 |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| EdDSA\           | > 64           | 0.9.15 | Recent Router    |
| _SHA512\_Ed25519 |                |        | Identities and   |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| EdDSA\_S         | > 64           | 0.9.25 | Offline signing, |
| HA512\_Ed25519ph |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities or    |
|                  |                |        | Destinations     |
+------------------+----------------+--------+------------------+
| RedDSA\          | > 64           | 0.9.39 | For Destinations |
| _SHA512\_Ed25519 |                |        | and encrypted    |
|                  |                |        | leasesets only,  |
|                  |                |        | never used for   |
|                  |                |        | Router           |
|                  |                |        | Identities       |
+------------------+----------------+--------+------------------+

#### Notes

-   When a signature is composed of two elements (for example values
    R,S), it is serialized by padding each element to length/2 with
    leading zeros if necessary.
-   All types are Big Endian, except for EdDSA and RedDSA, which are
    stored and transmitted in a Little Endian format.

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/Signature.html>

### Hash {#type-Hash}

#### Description

Represents the SHA256 of some data.

#### Contents

32 bytes

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/Hash.html>

### Session Tag {#type-SessionTag}

Note: Session Tags for ECIES-X25519 destinations (ratchet) and
ECIES-X25519 routers are 8 bytes. See \[ECIES\] and \[ECIES-ROUTERS\].

#### Description

A random number

#### Contents

32 bytes

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/SessionTag.html>

### TunnelId {#type-TunnelId}

#### Description

Defines an identifier that is unique to each router in a tunnel. A
Tunnel ID is generally greater than zero; do not use a value of zero
except in special cases.

#### Contents

4 byte [Integer](#integer)

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/TunnelId.html>

### Certificate {#type-Certificate}

#### Description

A certificate is a container for various receipts or proof of works used
throughout the I2P network.

#### Contents

1 byte [Integer](#integer) specifying certificate type, followed by a 2
byte [Integer](#integer) specifying the size of the certificate payload,
then that many bytes.

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+-// length \| payload
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+-//
>
> type :: \[Integer\]
>
> :   length -\> 1 byte
>
>     case 0 -\> NULL case 1 -\> HASHCASH case 2 -\> HIDDEN case 3 -\>
>     SIGNED case 4 -\> MULTIPLE case 5 -\> KEY
>
> length :: \[Integer\]
>
> :   length -\> 2 bytes
>
> payload :: data
>
> :   length -\> \$length bytes

\[Integer\]: /spec/common-structures\#type-integer

#### Notes

-   For [Router Identities](#struct_RouterIdentity), the Certificate is
    always NULL through version 0.9.15. As of 0.9.16, a Key Certificate
    may be used to specify the signing public key type. See below.
-   For [Garlic Cloves](/en/docs/spec/i2np#struct_GarlicClove), the
    Certificate is always NULL, no others are currently implemented.
-   For [Garlic Messages](/en/docs/spec/i2np#msg_Garlic), the
    Certificate is always NULL, no others are currently implemented.
-   For [Destinations](#struct_Destination), the Certificate may be
    non-NULL. As of 0.9.12, a Key Certificate may be used to specify the
    signing public key type. See below.
-   Implementers are cautioned to prohibit excess data in Certificates.
    The appropriate length for each certificate type should be enforced.

#### Certificate Types

The following certificate types are defined:

+----------+-----------+--------------+--------------+--------------+
| Type     | Type Code | Payload      | Total Length | Notes        |
|          |           | Length       |              |              |
+==========+===========+==============+==============+==============+
| Null     | > 0       | > 0          | > 3          |              |
+----------+-----------+--------------+--------------+--------------+
| HashCash | > 1       | > varies     | > varies     | E            |
|          |           |              |              | xperimental, |
|          |           |              |              | unused.      |
|          |           |              |              | Payload      |
|          |           |              |              | contains an  |
|          |           |              |              | ASCII        |
|          |           |              |              | col          |
|          |           |              |              | on-separated |
|          |           |              |              | hashcash     |
|          |           |              |              | string.      |
+----------+-----------+--------------+--------------+--------------+
| Hidden   | > 2       | > 0          | > 3          | E            |
|          |           |              |              | xperimental, |
|          |           |              |              | unused.      |
|          |           |              |              | Hidden       |
|          |           |              |              | routers      |
|          |           |              |              | generally do |
|          |           |              |              | not announce |
|          |           |              |              | that they    |
|          |           |              |              | are hidden.  |
+----------+-----------+--------------+--------------+--------------+
| Signed   | > 3       | > 40 or 72   | > 43 or 75   | E            |
|          |           |              |              | xperimental, |
|          |           |              |              | unused.      |
|          |           |              |              | Payload      |
|          |           |              |              | contains a   |
|          |           |              |              | 40-byte DSA  |
|          |           |              |              | signature,   |
|          |           |              |              | optionally   |
|          |           |              |              | followed by  |
|          |           |              |              | the 32-byte  |
|          |           |              |              | Hash of the  |
|          |           |              |              | signing      |
|          |           |              |              | Destination. |
+----------+-----------+--------------+--------------+--------------+
| Multiple | > 4       | > varies     | > varies     | E            |
|          |           |              |              | xperimental, |
|          |           |              |              | unused.      |
|          |           |              |              | Payload      |
|          |           |              |              | contains     |
|          |           |              |              | multiple     |
|          |           |              |              | c            |
|          |           |              |              | ertificates. |
+----------+-----------+--------------+--------------+--------------+
| Key      | > 5       | > 4+         | > 7+         | Since        |
|          |           |              |              | 0.9.12. See  |
|          |           |              |              | below for    |
|          |           |              |              | details.     |
+----------+-----------+--------------+--------------+--------------+

#### Key Certificates

Key certificates were introduced in release 0.9.12. Prior to that
release, all PublicKeys were 256-byte ElGamal keys, and all
SigningPublicKeys were 128-byte DSA-SHA1 keys. A key certificate
provides a mechanism to indicate the type of the PublicKey and
SigningPublicKey in the Destination or RouterIdentity, and to package
any key data in excess of the standard lengths.

By maintaining exactly 384 bytes before the certificate, and putting any
excess key data inside the certificate, we maintain compatibility for
any software that parses Destinations and Router Identities.

The key certificate payload contains:

+-----------------------------------------------+--------+
| Data                                          | Length |
+===============================================+========+
| Signing Public Key Type ([Integer](#integer)) | > 2    |
+-----------------------------------------------+--------+
| Crypto Public Key Type ([Integer](#integer))  | > 2    |
+-----------------------------------------------+--------+
| Excess Signing Public Key Data                | > 0+   |
+-----------------------------------------------+--------+
| Excess Crypto Public Key Data                 | > 0+   |
+-----------------------------------------------+--------+

The defined Signing Public Key types are:

+--------------+-------------+--------------+--------+--------------+
| Type         | Type Code   | Total Public | Since  | Usage        |
|              |             | Key Length   |        |              |
+==============+=============+==============+========+==============+
| DSA\_SHA1    | > 0         | > 128        | 0.9.12 | Legacy       |
|              |             |              |        | Router       |
|              |             |              |        | Identities   |
|              |             |              |        | and          |
|              |             |              |        | D            |
|              |             |              |        | estinations, |
|              |             |              |        | never        |
|              |             |              |        | explicitly   |
|              |             |              |        | set          |
+--------------+-------------+--------------+--------+--------------+
| ECDSA\_      | > 1         | > 64         | 0.9.12 | Older        |
| SHA256\_P256 |             |              |        | Destinations |
+--------------+-------------+--------------+--------+--------------+
| ECDSA\_      | > 2         | > 96         | 0.9.12 | Rarely if    |
| SHA384\_P384 |             |              |        | ever used    |
|              |             |              |        | for          |
|              |             |              |        | Destinations |
+--------------+-------------+--------------+--------+--------------+
| ECDSA\_      | > 3         | > 132        | 0.9.12 | Rarely if    |
| SHA512\_P521 |             |              |        | ever used    |
|              |             |              |        | for          |
|              |             |              |        | Destinations |
+--------------+-------------+--------------+--------+--------------+
| RSA\_        | > 4         | > 256        | 0.9.12 | Offline      |
| SHA256\_2048 |             |              |        | only; never  |
|              |             |              |        | used in Key  |
|              |             |              |        | Certificates |
|              |             |              |        | for Router   |
|              |             |              |        | Identities   |
|              |             |              |        | or           |
|              |             |              |        | Destinations |
+--------------+-------------+--------------+--------+--------------+
| RSA\_        | > 5         | > 384        | 0.9.12 | Offline      |
| SHA384\_3072 |             |              |        | only; never  |
|              |             |              |        | used in Key  |
|              |             |              |        | Certificates |
|              |             |              |        | for Router   |
|              |             |              |        | Identities   |
|              |             |              |        | or           |
|              |             |              |        | Destinations |
+--------------+-------------+--------------+--------+--------------+
| RSA\_        | > 6         | > 512        | 0.9.12 | Offline      |
| SHA512\_4096 |             |              |        | only; never  |
|              |             |              |        | used in Key  |
|              |             |              |        | Certificates |
|              |             |              |        | for Router   |
|              |             |              |        | Identities   |
|              |             |              |        | or           |
|              |             |              |        | Destinations |
+--------------+-------------+--------------+--------+--------------+
| EdDSA\_SHA   | > 7         | > 32         | 0.9.15 | Recent       |
| 512\_Ed25519 |             |              |        | Router       |
|              |             |              |        | Identities   |
|              |             |              |        | and          |
|              |             |              |        | Destinations |
+--------------+-------------+--------------+--------+--------------+
| EdDSA\_SHA51 | > 8 9 10    | > 32 64 128  | 0.9.25 | Offline      |
| 2\_Ed25519ph |             |              |        | only; never  |
| reserved     |             |              |        | used in Key  |
| (GOST)       |             |              |        | Certificates |
| reserved     |             |              |        | for Router   |
| (GOST)       |             |              |        | Identities   |
|              |             |              |        | or           |
|              |             |              |        | Destinations |
|              |             |              |        | Reserved,    |
|              |             |              |        | see proposal |
|              |             |              |        | 134          |
|              |             |              |        | Reserved,    |
|              |             |              |        | see proposal |
|              |             |              |        | 134          |
+--------------+-------------+--------------+--------+--------------+
| RedDSA\_SHA  | > 11        | > 32         | 0.9.39 | For          |
| 512\_Ed25519 |             |              |        | Destinations |
| reserved     | 65280-65534 |              |        | and          |
| reserved     |             |              |        | encrypted    |
|              | :   65535   |              |        | leasesets    |
|              |             |              |        | only; never  |
|              |             |              |        | used for     |
|              |             |              |        | Router       |
|              |             |              |        | Identities   |
|              |             |              |        | Reserved for |
|              |             |              |        | experimental |
|              |             |              |        | use Reserved |
|              |             |              |        | for future   |
|              |             |              |        | expansion    |
+--------------+-------------+--------------+--------+--------------+

The defined Crypto Public Key types are:

+-----------------+-------------+-----------------+-----------------+
| Type            | Type Code   | Total Public    | Usage           |
|                 |             | Key Length      |                 |
+=================+=============+=================+=================+
| ElGamal         | > 0         | > 256           | All Router      |
|                 |             |                 | Identities and  |
|                 |             |                 | Destinations    |
+-----------------+-------------+-----------------+-----------------+
| P256            | > 1         | > 64            | Reserved, see   |
|                 |             |                 | proposal 145    |
+-----------------+-------------+-----------------+-----------------+
| P384            | > 2         | > 96            | Reserved, see   |
|                 |             |                 | proposal 145    |
+-----------------+-------------+-----------------+-----------------+
| P521            | > 3         | > 132           | Reserved, see   |
|                 |             |                 | proposal 145    |
+-----------------+-------------+-----------------+-----------------+
| X25519 reserved | > 4         | > 32            | See \[ECIES\]   |
| reserved        |             |                 | and proposal    |
|                 | 65280-65534 |                 | 156 Reserved    |
|                 |             |                 | for             |
|                 | :   65535   |                 | experimental    |
|                 |             |                 | use Reserved    |
|                 |             |                 | for future      |
|                 |             |                 | expansion       |
+-----------------+-------------+-----------------+-----------------+

When a Key Certificate is not present, the preceeding 384 bytes in the
Destination or RouterIdentity are defined as the 256-byte ElGamal
PublicKey followed by the 128-byte DSA-SHA1 SigningPublicKey. When a Key
Certificate is present, the preceeding 384 bytes are redefined as
follows:

-   Complete or first portion of Crypto Public Key
-   Random padding if the total lengths of the two keys are less than
    384 bytes
-   Complete or first portion of Signing Public Key

The Crypto Public Key is aligned at the start and the Signing Public Key
is aligned at the end. The padding (if any) is in the middle. The
lengths and boundaries of the initial key data, the padding, and the
excess key data portions in the certificates are not explicitly
specified, but are derived from the lengths of the specified key types.
If the total lengths of the Crypto and Signing Public Keys exceed 384
bytes, the remainder will be contained in the Key Certificate. If the
Crypto Public Key length is not 256 bytes, the method for determining
the boundary between the two keys is to be specified in a future
revision of this document.

Example layouts using an ElGamal Crypto Public Key and the Signing
Public Key type indicated:

+--------------------------+----------------+---------------------------------+
| Signing Key Type         | Padding Length | Excess Signing Key Data in Cert |
+==========================+================+=================================+
| DSA\_SHA1                | > 0            | > 0                             |
+--------------------------+----------------+---------------------------------+
| ECDSA\_SHA256\_P256      | > 64           | > 0                             |
+--------------------------+----------------+---------------------------------+
| ECDSA\_SHA384\_P384      | > 32           | > 0                             |
+--------------------------+----------------+---------------------------------+
| ECDSA\_SHA512\_P521      | > 0            | > 4                             |
+--------------------------+----------------+---------------------------------+
| RSA\_SHA256\_2048        | > 0            | > 128                           |
+--------------------------+----------------+---------------------------------+
| RSA\_SHA384\_3072        | > 0            | > 256                           |
+--------------------------+----------------+---------------------------------+
| RSA\_SHA512\_4096        | > 0            | > 384                           |
+--------------------------+----------------+---------------------------------+
| EdDSA\_SHA512\_Ed25519   | > 96           | > 0                             |
+--------------------------+----------------+---------------------------------+
| EdDSA\_SHA512\_Ed25519ph | > 96           | > 0                             |
+--------------------------+----------------+---------------------------------+

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/Certificate.html>

#### Notes

-   Implementers are cautioned to prohibit excess data in Key
    Certificates. The appropriate length for each certificate type
    should be enforced.

### Mapping {#type-Mapping}

#### Description

A set of key/value mappings or properties

#### Contents

A 2-byte size Integer followed by a series of String=String; pairs

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> size \| key\_string (len + data)\| = \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> val\_string (len + data) \| ; \| \...
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ size ::
> \[Integer\] length -\> 2 bytes Total number of bytes that follow
>
> key\_string :: \[String\]
>
> :   A string (one byte length followed by UTF-8 encoded characters)
>
> = :: A single byte containing \'=\'
>
> val\_string :: \[String\]
>
> :   A string (one byte length followed by UTF-8 encoded characters)
>
> ; :: A single byte containing \';\'

\[Integer\]: /spec/common-structures\#type-integer \[String\]:
/spec/common-structures\#type-string

#### Notes

-   The encoding isn\'t optimal - we either need the \'=\' and \';\'
    characters, or the string lengths, but not both
-   Some documentation says that the strings may not include \'=\' or
    \';\' but this encoding supports them
-   Strings are defined to be UTF-8 but in the current implementation,
    I2CP uses UTF-8 but I2NP does not. For example, UTF-8 strings in a
    RouterInfo options mapping in a I2NP Database Store Message will be
    corrupted.
-   The encoding allows duplicate keys, however in any usage where the
    mapping is signed, duplicates may cause a signature failure.
-   Mappings contained in I2NP messages (i.e. in a RouterAddress or
    RouterInfo) must be sorted by key so that the signature will be
    invariant. Duplicate keys are not allowed.
-   Mappings contained in an [I2CP
    SessionConfig](/en/docs/spec/i2cp#struct_SessionConfig) must be
    sorted by key so that the signature will be invariant. Duplicate
    keys are not allowed.
-   The sort method is defined as in Java String.compareTo(), using the
    Unicode value of the characters.
-   While it is application-dependent, keys and values are generally
    case-sensitive.
-   Key and value string length limits are 255 bytes (not characters)
    each, plus the length byte. Length byte may be 0.
-   Total length limit is 65535 bytes, plus the 2 byte size field, or
    65537 total.

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/DataHelper.html>

Common structure specification
------------------------------

### KeysAndCert {#struct-KeysAndCert}

#### Description

An encryption public key, a signing public key, and a certificate, used
as either a RouterIdentity or a Destination.

#### Contents

A [PublicKey](#publickey) followed by a
[SigningPublicKey](#signingpublickey) and then a
[Certificate](#certificate).

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> public\_key \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> padding (optional) \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> signing\_key \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> certificate \| +\-\-\--+\-\-\--+\-\-\--+-//
>
> public\_key :: \[PublicKey\] (partial or full)
>
> :   length -\> 256 bytes or as specified in key certificate
>
> padding :: random data
>
> :   length -\> 0 bytes or as specified in key certificate padding
>     length + signing\_key length == 128 bytes
>
> signing\_\_key :: \[SigningPublicKey\] (partial or full)
>
> :   length -\> 128 bytes or as specified in key certificate padding
>     length + signing\_key length == 128 bytes
>
> certificate :: \[Certificate\]
>
> :   length -\> \>= 3 bytes
>
> total length: 387+ bytes

\[PublicKey\]: /spec/common-structures\#type-publickey
\[SigningPublicKey\]: /spec/common-structures\#type-signingpublickey
\[Certificate\]: /spec/common-structures\#type-certificate

#### Notes

-   Do not assume that these are always 387 bytes! They are 387 bytes
    plus the certificate length specified at bytes 385-386, which may be
    non-zero.
-   As of release 0.9.12, if the certificate is a Key Certificate, the
    boundaries of the key fields may vary. See the Key Certificate
    section above for details.
-   The Crypto Public Key is aligned at the start and the Signing Public
    Key is aligned at the end. The padding (if any) is in the middle.

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/KeysAndCert.html>

### RouterIdentity {#struct-RouterIdentity}

#### Description

Defines the way to uniquely identify a particular router

#### Contents

Identical to KeysAndCert.

#### Notes

-   The certificate for a RouterIdentity was always NULL until release
    0.9.12.
-   Do not assume that these are always 387 bytes! They are 387 bytes
    plus the certificate length specified at bytes 385-386, which may be
    non-zero.
-   As of release 0.9.12, if the certificate is a Key Certificate, the
    boundaries of the key fields may vary. See the Key Certificate
    section above for details.
-   The Crypto Public Key is aligned at the start and the Signing Public
    Key is aligned at the end. The padding (if any) is in the middle.
-   RouterIdentities with a key certificate and a ECIES\_X25519 public
    key are supported as of release 0.9.48. Prior to that, all
    RouterIdentities were ElGamal.

JavaDoc:
<http://echelon.i2p/javadoc/net/i2p/data/router/RouterIdentity.html>

### Destination {#struct-Destination}

#### Description

A Destination defines a particular endpoint to which messages can be
directed for secure delivery.

#### Contents

Identical to [KeysAndCert](#keysandcert).

#### Notes

-   The public key of the destination was used for the old i2cp-to-i2cp
    encryption which was disabled in version 0.6, it is currently unused
    except for the IV for LeaseSet encryption, which is deprecated. The
    public key in the LeaseSet is used instead.
-   Do not assume that these are always 387 bytes! They are 387 bytes
    plus the certificate length specified at bytes 385-386, which may be
    non-zero.
-   As of release 0.9.12, if the certificate is a Key Certificate, the
    boundaries of the key fields may vary. See the Key Certificate
    section above for details.
-   The Crypto Public Key is aligned at the start and the Signing Public
    Key is aligned at the end. The padding (if any) is in the middle.

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/Destination.html>

### Lease {#struct-Lease}

#### Description

Defines the authorization for a particular tunnel to receive messages
targeting a [Destination](#destination).

#### Contents

SHA256 [Hash](#hash) of the [RouterIdentity](#routeridentity) of the
gateway router, then the [TunnelId](#tunnelid), and finally an end
[Date](#date).

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> tunnel\_gw \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> tunnel\_id \| end\_date
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> tunnel\_gw :: Hash of the \[RouterIdentity\] of the tunnel gateway
>
> :   length -\> 32 bytes
>
> tunnel\_id :: \[TunnelId\]
>
> :   length -\> 4 bytes
>
> end\_date :: \[Date\]
>
> :   length -\> 8 bytes

\[Date\]: /spec/common-structures\#type-date \[TunnelId\]:
/spec/common-structures\#type-tunnelid \[RouterIdentity\]:
/spec/common-structures\#struct-routeridentity

#### Notes

-   Total size: 44 bytes

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/Lease.html>

### LeaseSet {#struct-LeaseSet}

#### Description

Contains all of the currently authorized [Leases](#struct-lease) for a
particular [Destination](#destination), the [PublicKey](#publickey) to
which garlic messages can be encrypted, and then the
[SigningPublicKey](#signingpublickey) that can be used to revoke this
particular version of the structure. The LeaseSet is one of the two
structures stored in the network database (the other being
[RouterInfo](#routerinfo)), and is keyed under the SHA256 of the
contained [Destination](#destination).

#### Contents

[Destination](#destination), followed by a [PublicKey](#publickey) for
encryption, then a [SigningPublicKey](#signingpublickey) which can be
used to revoke this version of the LeaseSet, then a 1 byte
[Integer](#integer) specifying how many [Lease](#lease) structures are
in the set, followed by the actual [Lease](#lease) structures and
finally a [Signature](#signature) of the previous bytes signed by the
[Destination](#destination)\'s [SigningPrivateKey](#signingprivatekey).

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> destination \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> encryption\_key \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> signing\_key \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> num\| Lease 0 \| +\-\-\--+ + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Lease 1 \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Lease (\$num-1) \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> signature \| + + \| \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> destination :: \[Destination\]
>
> :   length -\> \>= 387+ bytes
>
> encryption\_key :: \[PublicKey\]
>
> :   length -\> 256 bytes
>
> signing\_key :: \[SigningPublicKey\]
>
> :   
>
>     length -\> 128 bytes or as specified in destination\'s key
>
>     :   certificate
>
> num :: \[Integer\]
>
> :   length -\> 1 byte Number of leases to follow value: 0 \<= num \<=
>     16
>
> leases :: \[\[Lease\]\]
>
> :   length -\> \$num\*44 bytes
>
> signature :: \[Signature\]
>
> :   
>
>     length -\> 40 bytes or as specified in destination\'s key
>
>     :   certificate

\[Destination\]: /spec/common-structures\#struct-destination
\[PublicKey\]: /spec/common-structures\#type-publickey \[Signature\]:
/spec/common-structures\#type-signature \[Integer\]:
/spec/common-structures\#type-integer \[SigningPublicKey\]:
/spec/common-structures\#type-signingpublickey \[Lease\]:
/spec/common-structures\#struct-lease

#### Notes

-   The public key of the destination was used for the old I2CP-to-I2CP
    encryption which was disabled in version 0.6, it is currently
    unused.
-   The encryption key is used for end-to-end ElGamal/AES+SessionTag
    encryption \[ELGAMAL-AES\]. It is currently generated anew at every
    router startup, it is not persistent.
-   The signature may be verified using the signing public key of the
    destination.
-   A LeaseSet with zero Leases is allowed but is unused. It was
    intended for LeaseSet revocation, which is unimplemented. All
    LeaseSet2 variants require at least one Lease.
-   The signing\_key is currently unused. It was intended for LeaseSet
    revocation, which is unimplemented. It is currently generated anew
    at every router startup, it is not persistent. The signing key type
    is always the same as the destination\'s signing key type.
-   The earliest expiration of all the Leases is treated as the
    timestamp or version of the LeaseSet. Routers will generally not
    accept a store of a LeaseSet unless it is \"newer\" than the current
    one. Take care when publishing a new LeaseSet where the oldest Lease
    is the same as the oldest Lease in the previous LeaseSet. The
    publishing router should generally increment the expiration of the
    oldest Lease by at least 1 ms in that case.
-   Prior to release 0.9.7, when included in a DatabaseStore Message
    sent by the originating router, the router set all the published
    leases\' expirations to the same value, that of the earliest lease.
    As of release 0.9.7, the router publishes the actual lease
    expiration for each lease. This is an implementation detail and not
    part of the structures specification.

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/LeaseSet.html>

### Lease2 {#struct-Lease2}

#### Description

Defines the authorization for a particular tunnel to receive messages
targeting a [Destination](#destination). Same as [Lease](#lease) but
with a 4-byte end\_date. Used by [LeaseSet2](#leaseset2). Supported as
of 0.9.38; see proposal 123 for more information.

#### Contents

SHA256 [Hash](#hash) of the [RouterIdentity](#routeridentity) of the
gateway router, then the [TunnelId](#tunnelid), and finally a 4 byte end
date.

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> tunnel\_gw \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> tunnel\_id \| end\_date \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> tunnel\_gw :: Hash of the \[RouterIdentity\] of the tunnel gateway
>
> :   length -\> 32 bytes
>
> tunnel\_id :: \[TunnelId\]
>
> :   length -\> 4 bytes
>
> end\_date :: 4 byte date
>
> :   length -\> 4 bytes Seconds since the epoch, rolls over in 2106.

\[TunnelId\]: /spec/common-structures\#type-tunnelid \[RouterIdentity\]:
/spec/common-structures\#struct-routeridentity

#### Notes

-   Total size: 40 bytes

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/Lease2.html>

### OfflineSignature {#struct-OfflineSignature}

#### Description

This is an optional part of the [LeaseSet2Header](#leaseset2header).
Also used in streaming and I2CP. Supported as of 0.9.38; see proposal
123 for more information.

#### Contents

Contains an expiration, a sigtype and transient
[SigningPublicKey](#signingpublickey), and a [Signature](#signature).

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> expires \| sigtype \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ + \|
> transient\_public\_key \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> signature \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> expires :: 4 byte date
>
> :   length -\> 4 bytes Seconds since the epoch, rolls over in 2106.
>
> sigtype :: 2 byte type of the transient\_public\_key
>
> :   length -\> 2 bytes
>
> transient\_public\_key :: \[SigningPublicKey\]
>
> :   length -\> As inferred from the sigtype
>
> signature :: \[Signature\]
>
> :   
>
>     length -\> As inferred from the sigtype of the signing public key
>
>     :   in the \[Destination\] that preceded this offline signature.
>
>     Signature of expires timestamp, transient sig type, and public
>     key, by the destination public key.

\[Destination\]: /spec/common-structures\#struct-destination
\[SigningPublicKey\]: /spec/common-structures\#type-signingpublickey
\[Signature\]: /spec/common-structures\#type-signature

#### Notes

-   This section can, and should, be generated offline.

### LeaseSet2Header {#struct-LeaseSet2Header}

#### Description

This is the common part of the [LeaseSet2](#leaseset2) and
[MetaLeaseSet](#metaleaseset). Supported as of 0.9.38; see proposal 123
for more information.

#### Contents

Contains the [Destination](#destination), two timestamps, and an
optional [OfflineSignature](#offlinesignature).

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> destination \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> published \| expires \| flags \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> offline\_signature (optional) \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> destination :: \[Destination\]
>
> :   length -\> \>= 387+ bytes
>
> published :: 4 byte date
>
> :   length -\> 4 bytes Seconds since the epoch, rolls over in 2106.
>
> expires :: 2 byte time
>
> :   length -\> 2 bytes Offset from published timestamp in seconds,
>     18.2 hours max
>
> flags :: 2 bytes
>
> :   Bit order: 15 14 \... 3 2 1 0 Bit 0: If 0, no offline keys; if 1,
>     offline keys Bit 1: If 0, a standard published leaseset. If 1, an
>     unpublished leaseset. Should not be flooded, published, or sent in
>     response to a query. If this leaseset expires, do not query the
>     netdb for a new one, unless bit 2 is set. Bit 2: If 0, a standard
>     published leaseset. If 1, this unencrypted leaseset will be
>     blinded and encrypted when published. If this leaseset expires,
>     query the blinded location in the netdb for a new one. If this bit
>     is set to 1, set bit 1 to 1 also. As of release 0.9.42. Bits 15-3:
>     set to 0 for compatibility with future uses
>
> offline\_signature :: \[OfflineSignature\]
>
> :   length -\> varies Optional, only present if bit 0 is set in the
>     flags.

\[OfflineSignature\]: /spec/common-structures\#struct-offlinesignature
\[Destination\]: /spec/common-structures\#struct-destination

#### Notes

-   Total size: 395 bytes minimum
-   Maximum actual expires time is about 660 (11 minutes) for
    [LeaseSet2](#leaseset2) and 65535 (the full 18.2 hours) for
    [MetaLeaseSet](#metaleaseset).

### LeaseSet2 {#struct-LeaseSet2}

#### Description

Contained in a I2NP DatabaseStore message of type 3. Supported as of
0.9.38; see proposal 123 for more information.

Contains all of the currently authorized [Lease2](#lease2) for a
particular [Destination](#destination), and the [PublicKey](#publickey)
to which garlic messages can be encrypted. A LeaseSet is one of the two
structures stored in the network database (the other being
[RouterInfo](#routerinfo)), and is keyed under the SHA256 of the
contained [Destination](#destination).

#### Contents

[LeaseSet2Header](#leaseset2header), followed by a options, then one or
more [PublicKey](#publickey) for encryption, [Integer](#integer)
specifying how many [Lease2](#lease2) structures are in the set,
followed by the actual [Lease2](#lease2) structures and finally a
[Signature](#signature) of the previous bytes signed by the
[Destination](#destination)\'s [SigningPrivateKey](#signingprivatekey)
or the transient key.

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> ls2\_header \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> options \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
> keytype0\| keylen0 \| \| +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ +
> \| encryption\_key\_0 \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> keytypen\| keylenn \| \| +\-\-\--+\-\-\--+\-\-\--+\-\-\--+ + \|
> encryption\_key\_n \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> num\| Lease2 0 \| +\-\-\--+ + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> Lease2(\$num-1) \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> signature \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> ls2header :: \[LeaseSet2Header\]
>
> :   length -\> varies
>
> options :: \[Mapping\]
>
> :   length -\> varies, 2 bytes minimum
>
> numk :: \[Integer\]
>
> :   length -\> 1 byte Number of key types, key lengths, and
>     \[PublicKey\]s to follow value: 1 \<= numk \<= max TBD
>
> keytype :: The encryption type of the \[PublicKey\] to follow.
>
> :   length -\> 2 bytes
>
> keylen :: The length of the \[PublicKey\] to follow.
>
> :   Must match the specified length of the encryption type. length -\>
>     2 bytes
>
> encryption\_key :: \[PublicKey\]
>
> :   length -\> 256 bytes
>
> num :: \[Integer\]
>
> :   length -\> 1 byte Number of \[Lease2\]s to follow value: 0 \<= num
>     \<= 16
>
> leases :: \[\[Lease2\]\]
>
> :   length -\> \$num\*40 bytes
>
> signature :: \[Signature\]
>
> :   
>
>     length -\> 40 bytes or as specified in destination\'s key
>
>     :   certificate, or by the sigtype of the transient public key, if
>         present in the header

\[Mapping\]: /spec/common-structures\#type-mapping \[PublicKey\]:
/spec/common-structures\#type-publickey \[Signature\]:
/spec/common-structures\#type-signature \[Integer\]:
/spec/common-structures\#type-integer \[Lease2\]:
/spec/common-structures\#struct-lease2 \[LeaseSet2Header\]:
/spec/common-structures\#struct-leaseset2header

#### Notes

-   The public key of the destination was used for the old I2CP-to-I2CP
    encryption which was disabled in version 0.6, it is currently
    unused.
-   The encryption keys are used for end-to-end ElGamal/AES+SessionTag
    encryption \[ELGAMAL-AES\] (type 0) or other end-to-end encryption
    schemes. See \[ECIES\] and proposals 145 and 156. They may be
    generated anew at every router startup or they may be persistent.
    X25519 (type 4, see \[ECIES\] ) is supported as of release 0.9.44.
-   The signature is over the data above, PREPENDED with the single byte
    containing the DatabaseStore type (3).
-   The signature may be verified using the signing public key of the
    destination, or the transient signing public key, if an offline
    signature is included in the leaseset2 header.
-   The key length is provided for each key, so that floodfills and
    clients may parse the structure even if not all encryption types are
    known or supported.

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/LeaseSet2.html>

### MetaLease {#struct-MetaLease}

#### Description

Defines the authorization for a particular tunnel to receive messages
targeting a [Destination](#destination). Same as [Lease2](#lease2) but
with flags and cost instead of a tunnel id. Used by
[MetaLeaseSet](#metaleaseset). Contained in a I2NP DatabaseStore message
of type 7. Supported as of 0.9.38; see proposal 123 for more
information.

#### Contents

SHA256 [Hash](#hash) of the [RouterIdentity](#routeridentity) of the
gateway router, then flags and cost, and finally a 4 byte end date.

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> tunnel\_gw \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> flags end\_date \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> tunnel\_gw :: Hash of the \[RouterIdentity\] of the tunnel gateway,
>
> :   or the hash of another \[MetaLeaseSet\]. length -\> 32 bytes
>
> flags :: 3 bytes of flags
>
> :   Bit order: 23 22 \... 3 2 1 0 Bits 3-0: Type of the entry. If 0,
>     unknown. If 1, a \[LeaseSet\]. If 3, a \[LeaseSet2\]. If 5, a
>     \[MetaLeaseSet\]. Bits 23-4: set to 0 for compatibility with
>     future uses length -\> 3 bytes
>
> cost :: 1 byte, 0-255. Lower value is higher priority.
>
> :   length -\> 1 byte
>
> end\_date :: 4 byte date
>
> :   length -\> 4 bytes Seconds since the epoch, rolls over in 2106.

\[MetaLeaseSet\]: /spec/common-structures\#struct-metaleaseset
\[LeaseSet\]: /spec/common-structures\#struct-leaseset \[LeaseSet2\]:
/spec/common-structures\#struct-leaseset2 \[RouterIdentity\]:
/spec/common-structures\#struct-routeridentity

#### Notes

-   Total size: 40 bytes

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/MetaLease.html>

### MetaLeaseSet {#struct-MetaLeaseSet}

#### Description

Contained in a I2NP DatabaseStore message of type 7. Defined as of
0.9.38; scheduled to be working as of 0.9.40; see proposal 123 for more
information.

Contains all of the currently authorized [MetaLease](#metalease) for a
particular [Destination](#destination), and the [PublicKey](#publickey)
to which garlic messages can be encrypted. A LeaseSet is one of the two
structures stored in the network database (the other being
[RouterInfo](#routerinfo)), and is keyed under the SHA256 of the
contained [Destination](#destination).

#### Contents

[LeaseSet2Header](#leaseset2header), followed by a options,
[Integer](#integer) specifying how many [Lease2](#lease2) structures are
in the set, followed by the actual [Lease2](#lease2) structures and
finally a [Signature](#signature) of the previous bytes signed by the
[Destination](#destination)\'s [SigningPrivateKey](#signingprivatekey)
or the transient key.

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> ls2\_header \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> options \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> num\| MetaLease 0 \| +\-\-\--+ + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> MetaLease(\$num-1) \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> +\-\-\--+ + \| revocation\_0 \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> revocation\_n \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> signature \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> ls2header :: \[LeaseSet2Header\]
>
> :   length -\> varies
>
> options :: \[Mapping\]
>
> :   length -\> varies, 2 bytes minimum
>
> num :: \[Integer\]
>
> :   length -\> 1 byte Number of \[MetaLease\]s to follow value: 1 \<=
>     num \<= max TBD
>
> leases :: \[MetaLease\]s
>
> :   length -\> \$numr\*40 bytes
>
> numr :: \[Integer\]
>
> :   length -\> 1 byte Number of \[Hash\]es to follow value: 0 \<= numr
>     \<= max TBD
>
> revocations :: \[\[Hash\]\]
>
> :   length -\> \$numr\*32 bytes
>
> signature :: \[Signature\]
>
> :   
>
>     length -\> 40 bytes or as specified in destination\'s key
>
>     :   certificate, or by the sigtype of the transient public key, if
>         present in the header

\[Hash\]: /spec/common-structures\#type-hash \[MetaLease\]:
/spec/common-structures\#struct-metalease \[Mapping\]:
/spec/common-structures\#type-mapping \[Signature\]:
/spec/common-structures\#type-signature \[Integer\]:
/spec/common-structures\#type-integer \[LeaseSet2Header\]:
/spec/common-structures\#struct-leaseset2header

#### Notes

-   The public key of the destination was used for the old I2CP-to-I2CP
    encryption which was disabled in version 0.6, it is currently
    unused.
-   The signature is over the data above, PREPENDED with the single byte
    containing the DatabaseStore type (7).
-   The signature may be verified using the signing public key of the
    destination, or the transient signing public key, if an offline
    signature is included in the leaseset2 header.

JavaDoc: <http://echelon.i2p/javadoc/net/i2p/data/MetaLeaseSet.html>

### EncryptedLeaseSet {#struct-EncryptedLeaseSet}

#### Description

Contained in a I2NP DatabaseStore message of type 5. Defined as of
0.9.38; working as of 0.9.39; see proposal 123 for more information.

Only the blinded key and expiration are visible in cleartext. The actual
lease set is encrypted.

#### Contents

A two byte signature type, the blinded
[SigningPrivateKey](#signingprivatekey), published time, expiration, and
flags. Then, a two byte length followed by encrypted data. Finally, a
[Signature](#signature) of the previous bytes signed by the blinded
[SigningPrivateKey](#signingprivatekey) or the transient key.

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> sigtype \| \| +\-\-\--+\-\-\--+ + \| blinded\_public\_key \| \~ \~ \~
> \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> published \| expires \| flags \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> offline\_signature (optional) \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> len \| \| +\-\-\--+\-\-\--+ + \| encrypted\_data \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> signature \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> sigtype :: A two byte signature type of the public key to follow
>
> :   length -\> 2 bytes
>
> blinded\_public\_key :: \[SigningPublicKey\]
>
> :   length -\> As inferred from the sigtype
>
> published :: 4 byte date
>
> :   length -\> 4 bytes Seconds since the epoch, rolls over in 2106.
>
> expires :: 2 byte time
>
> :   length -\> 2 bytes Offset from published timestamp in seconds,
>     18.2 hours max
>
> flags :: 2 bytes
>
> :   Bit order: 15 14 \... 3 2 1 0 Bit 0: If 0, no offline keys; if 1,
>     offline keys Bit 1: If 0, a standard published leaseset. If 1, an
>     unpublished leaseset. Should not be flooded, published, or sent in
>     response to a query. If this leaseset expires, do not query the
>     netdb for a new one. Bits 15-2: set to 0 for compatibility with
>     future uses
>
> offline\_signature :: \[OfflineSignature\]
>
> :   length -\> varies Optional, only present if bit 0 is set in the
>     flags.
>
> len :: \[Integer\]
>
> :   length -\> 2 bytes length of encrypted\_data to follow value: 1
>     \<= num \<= max TBD
>
> encrypted\_data :: Data encrypted
>
> :   length -\> len bytes
>
> signature :: \[Signature\]
>
> :   
>
>     length -\> As specified by the sigtype of the blinded pubic key,
>
>     :   or by the sigtype of the transient public key, if present in
>         the header

\[OfflineSignature\]: /spec/common-structures\#struct-offlinesignature
\[SigningPublicKey\]: /spec/common-structures\#type-signingpublickey
\[Signature\]: /spec/common-structures\#type-signature \[Integer\]:
/spec/common-structures\#type-integer

#### Notes

-   The public key of the destination was used for the old I2CP-to-I2CP
    encryption which was disabled in version 0.6, it is currently
    unused.
-   The signature is over the data above, PREPENDED with the single byte
    containing the DatabaseStore type (5).
-   The signature may be verified using the signing public key of the
    destination, or the transient signing public key, if an offline
    signature is included in the leaseset2 header.
-   Blinding and encryption are specified in
    [EncryptedLeaseSet](/en/docs/spec/encryptedleaseset)
-   This structure does not use the [LeaseSet2Header](#leaseset2header).
-   Maximum actual expires time is about 660 (11 minutes), unless it is
    an encrypted [MetaLeaseSet](#metaleaseset).
-   See proposal 123 for notes on using offline signatures with
    encrypted leasesets.

JavaDoc:
<http://echelon.i2p/javadoc/net/i2p/data/EncryptedLeaseSet.html>

### RouterAddress {#struct-RouterAddress}

#### Description

This structure defines the means to contact a router through a transport
protocol.

#### Contents

1 byte [Integer](#integer) defining the relative cost of using the
address, where 0 is free and 255 is expensive, followed by the
expiration [Date](#date) after which the address should not be used, or
if null, the address never expires. After that comes a [String](#string)
defining the transport protocol this router address uses. Finally there
is a [Mapping](#mapping) containing all of the transport specific
options necessary to establish the connection, such as IP address, port
number, email address, URL, etc.

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
> expiration
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> transport\_style \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+-//-+\-\-\--+\-\-\--+\-\-\--+ \| \| +
> + \| options \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> cost :: \[Integer\]
>
> :   length -\> 1 byte
>
>     case 0 -\> free case 255 -\> expensive
>
> expiration :: \[Date\] (must be all zeros, see notes below)
>
> :   length -\> 8 bytes
>
>     case null -\> never expires
>
> transport\_style :: \[String\]
>
> :   length -\> 1-256 bytes
>
> options :: \[Mapping\]

\[Date\]: /spec/common-structures\#type-date \[Integer\]:
/spec/common-structures\#type-integer \[String\]:
/spec/common-structures\#type-string \[Mapping\]:
/spec/common-structures\#type-mapping

#### Notes

-   Cost is typically 5 or 6 for SSU, and 10 or 11 for NTCP.
-   Expiration is currently unused, always null (all zeroes). As of
    release 0.9.3, the expiration is assumed zero and not stored, so any
    non-zero expiration will fail in the RouterInfo signature
    verification. Implementing expiration (or another use for these
    bytes) will be a backwards-incompatible change. Routers MUST set
    this field to all zeros. As of release 0.9.12, a non-zero expiration
    field is again recognized, however we must wait several releases to
    use this field, until the vast majority of the network recognizes
    it.
-   The following options, while not required, are standard and expected
    to be present in most router addresses: \"host\" (an IPv4 or IPv6
    address or host name) and \"port\".

JavaDoc:
<http://echelon.i2p/javadoc/net/i2p/data/router/RouterAddress.html>

### RouterInfo {#struct-RouterInfo}

#### Description

Defines all of the data that a router wants to publish for the network
to see. The [RouterInfo](#routerinfo) is one of two structures stored in
the network database (the other being [LeaseSet](#leaseset)), and is
keyed under the SHA256 of the contained
[RouterIdentity](#routeridentity).

#### Contents

[RouterIdentity](#routeridentity) followed by the [Date](#date), when
the entry was published

> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> router\_ident \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> published \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
> RouterAddress 0 \| +\-\-\--+ + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> RouterAddress 1 \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+ \|
> RouterAddress (\$size-1) \| + + \| \| \~ \~ \~ \~ \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+-//-+\-\-\--+\-\-\--+\-\-\--+ options
> \| +\-\-\--+\-\-\--+\-\-\--+\-\-\--+-//-+\-\-\--+\-\-\--+\-\-\--+ \|
> signature \| + + \| \| + + \| \| + + \| \| + + \| \|
> +\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+\-\-\--+
>
> router\_ident :: \[RouterIdentity\]
>
> :   length -\> \>= 387+ bytes
>
> published :: \[Date\]
>
> :   length -\> 8 bytes
>
> size :: \[Integer\]
>
> :   length -\> 1 byte The number of \[RouterAddress\]es to follow,
>     0-255
>
> addresses :: \[\[RouterAddress\]\]
>
> :   length -\> varies
>
> peer\_size :: \[Integer\]
>
> :   length -\> 1 byte The number of peer \[Hash\]es to follow, 0-255,
>     unused, always zero value -\> 0
>
> options :: \[Mapping\]
>
> signature :: \[Signature\]
>
> :   
>
>     length -\> 40 bytes or as specified in router\_ident\'s key
>
>     :   certificate

\[Hash\]: /spec/common-structures\#type-hash \[Mapping\]:
/spec/common-structures\#type-mapping \[RouterAddress\]:
/spec/common-structures\#struct-routeraddress \[Signature\]:
/spec/common-structures\#type-signature \[Date\]:
/spec/common-structures\#type-date \[Integer\]:
/spec/common-structures\#type-integer \[RouterIdentity\]:
/spec/common-structures\#struct-routeridentity

#### Notes

-   The peer\_size [Integer](#integer) may be followed by a list of that
    many router hashes. This is currently unused. It was intended for a
    form of restricted routes, which is unimplemented. Certain
    implementations may require the list to be sorted so the signature
    is invariant. To be researched before enabling this feature.
-   The signature may be verified using the signing public key of the
    router\_ident.
-   See the network database page \[NETDB-ROUTERINFO\] for standard
    options that are expected to be present in all router infos.
-   Very old routers required the addresses to be sorted by the SHA256
    of their data so the signature is invariant. This is no longer
    required, and not worth implementing for backward compatibility.

JavaDoc:
<http://echelon.i2p/javadoc/net/i2p/data/router/RouterInfo.html>

### Delivery Instructions {#struct-DeliveryInstructions}

Tunnel Message Delivery Instructions are defined in the Tunnel Message
Specification \[TUNNEL-DELIVERY\].

Garlic Message Delivery Instructions are defined in the I2NP Message
Specification \[GARLIC-DELIVERY\].

References
----------

\[ECIES\]

:   <https://geti2p.net/spec/ecies>

\[ECIES-ROUTERS\]

:   <https://geti2p.net/spec/ecies-routers>

\[ELGAMAL\]

:   <https://geti2p.net/en/docs/how/cryptography#elgamal>

\[ELGAMAL-AES\]

:   <https://geti2p.net/en/docs/how/elgamal-aes>

\[GARLIC-DELIVERY\]

:   <https://geti2p.net/spec/i2np#struct-garlicclovedeliveryinstructions>

\[I2CP\]

:   <https://geti2p.net/en/docs/protocol/i2cp>

\[I2NP\]

:   <https://geti2p.net/en/docs/protocol/i2np>

\[NETDB-ROUTERINFO\]

:   <https://geti2p.net/en/docs/how/network-database#routerInfo>

\[SSU\]

:   <https://geti2p.net/en/docs/transport/ssu>

\[TUNNEL-DELIVERY\]

:   <https://geti2p.net/spec/tunnel-message#struct-tunnelmessagedeliveryinstructions>
