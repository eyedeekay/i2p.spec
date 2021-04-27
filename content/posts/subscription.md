---
title: "Subscription"
date: 2021-04-27T14:39:35-04:00
draft: false
---

Addressbook Subscription Feed Commands
======================================

Last updated: 2021-01 Accurate for: 0.9.49

Overview
--------

This specification extends the address subscription feed with commands,
to enable name servers to broadcast entry updates from hostname holders.
Implemented in 0.9.26, originally proposed in proposal 112.

Motivation
----------

Previously, the hosts.txt subscription servers just sent data in a
hosts.txt format, which is as follows:

    example.i2p=b64destination

There are several problems with this:

-   Hostname holders cannot update the Destination associated with their
    hostnames (in order to e.g. upgrade the signing key to a stronger
    type).
-   Hostname holders cannot relinquish their hostnames arbitrarily; they
    must give the corresponding Destination private keys directly to the
    new holder.
-   There is no way to authenticate that a subdomain is controlled by
    the corresponding base hostname; this is currently only enforced
    individually by some name servers.

Design
------

This specification adds a number of command lines to the hosts.txt
format. With these commands, name servers can extend their services to
provide a number of additional features. Clients that implement this
specification will be able to listen for these features through the
regular subscription process.

All command lines must be signed by the corresponding Destination. This
ensures that changes are only made at the request of the hostname
holder.

Security implications
---------------------

This specification does not affect anonymity.

There is an increase in the risk associated with losing control of a
Destination key, as someone who obtains it can use these commands to
make changes to any associated hostnames. But this is no more of a
problem than the status quo, where someone who obtains a Destination can
impersonate a hostname and (partially) take over its traffic. The
increased risk is also balanced our by giving hostname holders the
ability to change the Destination associated with a hostname, in the
event that they believe the Destination has been compromised; this is
impossible with the current system.

Specification
-------------

### New line types

There are two new types of lines:

1.  Add and Change commands:

        example.i2p=b64destination#!key1=val1#key2=val2 ...

2.  Remove commands:

        #!key1=val1#key2=val2 ...

#### Ordering

A feed is not necessarily in-order or complete. For example, a change
command may be on a line before an add command, or without an add
command.

Keys may be in any order. Duplicate keys are not allowed. All keys and
values are case-sensitive.

### Common keys

Required in all commands:

sig

:   B64 signature, using signing key from the destination

References to a second hostname and/or destination:

oldname

:   A second hostname (new or changed)

olddest

:   A second b64 destination (new or changed)

oldsig

:   A second b64 signature, using signing key from nolddest

Other common keys:

action

:   A command

name

:   The hostname, only present if not preceded by example.i2p=b64dest

dest

:   The b64 destination, only present if not preceded by
    example.i2p=b64dest

date

:   In seconds since epoch

expires

:   In seconds since epoch

### Commands

All commands except the \"Add\" command must contain an
\"action=command\" key/value.

For compatibility with older clients, most commands are preceded by
example.i2p=b64dest, as noted below. For changes, these are always the
new values. Any old values are included in the key/value section.

Listed keys are required. All commands may contain additional key/value
items not defined here.

#### Add hostname

Preceded by example.i2p=b64dest

:   YES, this is the new host name and destination.

action

:   NOT included, it is implied.

sig

:   signature

Example:

    example.i2p=b64dest#!sig=b64sig

#### Change hostname

Preceded by example.i2p=b64dest

:   YES, this is the new host name and old destination.

action

:   changename

oldname

:   the old hostname, to be replaced

sig

:   signature

Example:

    example.i2p=b64dest#!action=changename#oldname=oldhostname#sig=b64sig

#### Change destination

Preceded by example.i2p=b64dest

:   YES, this is the old host name and new destination.

action

:   changedest

olddest

:   the old dest, to be replaced

oldsig

:   signature using olddest

sig

:   signature

Example:

    example.i2p=b64dest#!action=changedest#olddest=oldb64dest#oldsig=b64sig#sig=b64sig

#### Add hostname alias

Preceded by example.i2p=b64dest

:   YES, this is the new (alias) host name and old destination.

action

:   addname

oldname

:   the old hostname

sig

:   signature

Example:

    example.i2p=b64dest#!action=addname#oldname=oldhostname#sig=b64sig

#### Add destination alias

(Used for crypto upgrade)

Preceded by example.i2p=b64dest

:   YES, this is the old host name and new (alternate) destination.

action

:   adddest

olddest

:   the old dest

oldsig

:   signature using olddest

sig

:   signature using dest

Example:

    example.i2p=b64dest#!action=adddest#olddest=oldb64dest#oldsig=b64sig#sig=b64sig

#### Add subdomain

Preceded by subdomain.example.i2p=b64dest

:   YES, this is the new host subdomain name and destination.

action

:   addsubdomain

oldname

:   the higher-level hostname (example.i2p)

olddest

:   the higher-level destination (for example.i2p)

oldsig

:   signature using olddest

sig

:   signature using dest

Example:

    subdomain.example.i2p=b64dest#!action=addsubdomain#oldname=example.i2p#olddest=oldb64dest#oldsig=b64sig#sig=b64sig

#### Update metadata

Preceded by example.i2p=b64dest

:   YES, this is the old host name and destination.

action

:   update

sig

:   signature

(add any updated keys here)

Example:

    example.i2p=b64dest#!action=update#k1=v1#k2=v2#sig=b64sig

#### Remove hostname

Preceded by example.i2p=b64dest

:   NO, these are specified in the options

action

:   remove

name

:   the hostname

dest

:   the destination

sig

:   signature

Example:

    #!action=remove#name=example.i2p#dest=b64destsig=b64sig

#### Remove all with this destination

Preceded by example.i2p=b64dest

:   NO, these are specified in the options

action

:   removeall

name

:   the old hostname, advisory only

dest

:   the old dest, all with this dest are removed

sig

:   signature

Example:

    #!action=removeall#name=example.i2p#dest=b64destsig=b64sig

### Signatures

All commands must contain a signature key/value \"sig=b64signature\"
where the signature for the other data, using the destination signing
key.

For commands including an old and new destination, there must also be an
oldsig=b64signature, and either oldname, olddest, or both.

In an Add or Change command, the public key for verification is in the
Destination to be added or changed.

In some add or edit commands, there may be an additional destination
referenced, for example when adding an alias, or changing a destination
or host name. In that case, there must be a second signature included
and both should be verified. The second signature is the \"inner\"
signature and is signed and verified first (excluding the \"outer\"
signature). The client should take any additional action necessary to
verify and accept changes.

oldsig is always the \"inner\" signature. Sign and verify without the
\'oldsig\' or \'sig\' keys present. sig is always the \"outer\"
signature. Sign and verify with the \'oldsig\' key present but not the
\'sig\' key.

#### Input for signatures

To generate a byte stream to create or verify the signature, serialize
as follows:

-   Remove the \"sig\" key
-   If verifying with oldsig, also remove the \"oldsig\" key
-   For Add or Change commands only, output example.i2p=b64dest
-   If any keys remain, output \"\#!\"
-   Sort the options by UTF-8 key, fail if duplicate keys
-   For each key/value, output key=value, followed by (if not the last
    key/value) a \'\#\'

Notes

-   Do not output a newline
-   Output encoding is UTF-8
-   All destination and signature encoding is in Base 64 using the I2P
    alphabet
-   Keys and values are case-sensitive
-   Host names must be in lower-case

Compatibility
-------------

All new lines in the hosts.txt format are implemented using leading
comment characters, so all older I2P versions will interpret the new
commands as comments.

When I2P routers update to the new specification, they will not
re-interpret old comments, but will start listening to new commands in
subsequent fetches of their subscription feeds. Thus it is important for
name servers to persist command entries in some fashion, or enable etag
support so that routers can fetch all past commands.
