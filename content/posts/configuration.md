---
title: "Configuration"
date: 2021-04-27T14:39:35-04:00
draft: false
---

Configuration File Specification
================================

Last updated: March 2020 Accurate for: 0.9.45

Overview
--------

This page provides a general specification of I2P configuration files,
used by the router and various applications. It also gives an overview
of the information contained in the various files, and links to detailed
documentation where available.

General Format
--------------

An I2P configuration file is formatted as specified in Java
\[Properties\] with the following exceptions:

-   Encoding must be UTF-8
-   Does not use or recognize any escapes, including \'\', so lines may
    not be continued
-   \'\#\' or \';\' starts a comment, but \'!\' does not
-   \'\#\' starts a comment in any position but \';\' must be in column
    1 to start a comment
-   Leading and trailing whitespace is not trimmed on keys
-   Leading and trailing whitespace is trimmed on values
-   \'=\' is the only key-termination character (not \':\' or
    whitespace)
-   Lines without \'=\' are ignored. As of release 0.9.10, keys with a
    value of \"\" are supported.
-   As there are no escapes, keys may not contain \'\#\', \'=\', or
    \'n\', or start with \';\'
-   As there are no escapes, values may not contain \'\#\' or \'n\', or
    start or end with \'r\' or whitespace

The file need not be sorted, but most applications do sort by key when
writing to the file, for ease of reading and manual editing.

Reads and writes are implemented in DataHelper loadProps() and
storeProps() \[DATAHELPER\]. Note that the file format is significantly
different than the serialized format for I2P protocols specified in
\[Mapping\].

Core library and router
-----------------------

### Clients (clients.config)

Configured via /configclients in the router console. As of release
0.9.42, the default clients.config file is split into individual
configuration files for each client in the clients.config.d directory.
After being split, the properties in the individual files are prefixed
with \"clientApp.0.\".

The format is as follows:

Lines are of the form clientApp.x.prop=val, where x is the app number.
App numbers MUST start with 0 and be consecutive.

Properties are as follows:

> main
>
> :   Full class name. Required.
>
>     The constructor or main() method in this class will be run,
>     depending on whether the client is managed or unmanaged. See below
>     for details.
>
> name
>
> :   Name to be displayed on console.
>
> args
>
> :   Arguments to the main class, separated by spaces or tabs.
>     Arguments containing spaces or tabs may be quoted with \' or \"
>
> delay
>
> :   Seconds before starting, default 120
>
> onBoot
>
> :   {true\|false},
>
>     Default false, forces a delay of 0, overrides delay setting
>
> startOnLoad:
>
> :   {true\|false}
>
>     Is the client to be run at all? Default true

The following additional properties are used only by plugins:

> stopargs
>
> :   Arguments to stop the client.
>
> uninstallargs
>
> :   Arguments to uninstall the client.
>
> classpath
>
> :   Additional classpath elements for the client, separated by commas.

The following substitutions are made in the args, stopargs,
uninstallargs, and classpath lines, for plugins only:

> \$I2P
>
> :   The base I2P install directory
>
> \$CONFIG
>
> :   The user\'s configuration directory (e.g. \~/.i2p)
>
> \$PLUGIN
>
> :   This plugin\'s directory (e.g. \~/.i2p/plugins/foo)

All properties except \"main\" are optional. Lines starting with \"\#\"
are comments.

If the delay is less than zero, the client will wait until the router
reaches RUNNING state and then start immediately in a new thread.

If the delay is equal to zero, the client is run immediately, in the
same thread, so that exceptions may be propagated to the console. In
this case, the client should either throw an exception, return quickly,
or spawn its own thread.

If the delay is greater than zero, it will be run in a new thread, and
exceptions will be logged but not propagated to the console.

Clients may be \"managed\" or \"unmanaged\".

### Logger (logger.config)

Configured via /configlogging in the router console.

Properties are as follows:

    # Default 20
    logger.consoleBufferSize=n
    # Default from locale; format as specified by Java SimpleDateFormat
    logger.dateFormat=HH:mm:ss.SSS
    # Default ERROR
    logger.defaultLevel=CRIT|ERROR|WARN|INFO|DEBUG
    # Default true
    logger.displayOnScreen=true|false
    # Default true
    logger.dropDuplicates=true|false
    # Default false
    logger.dropOnOverflow=true|false
    # As of 0.9.18. Default 29 (seconds)
    logger.flushInterval=nnn
    # d = date, c = class, t = thread name, p = priority, m = message
    logger.format={dctpm}*
    # Max to buffer before flushing. Default 1024
    logger.logBufferSize=n
    # Default logs/log-@.txt; @ replaced with number
    logger.logFileName=name
    logger.logFilenameOverride=name
    # Default 10M
    logger.logFileSize=nnn[K|M|G]
    # Highest file number. Default 2
    logger.logRotationLimit=n
    # Default CRIT
    logger.minimumOnScreenLevel=CRIT|ERROR|WARN|INFO|DEBUG
    logger.record.{class}=CRIT|ERROR|WARN|INFO|DEBUG

### Individual Plugin (plugins/\*/plugin.config)

See the plugin specification \[PLUGIN\]. Note that plugins may also
contain clients.config, i2ptunnel.config, and webapps.config files.

### Plugins (plugins.config)

Enable/disable for each installed plugin.

Properties are as follows:

    plugin.{name}.startOnLoad=true|false

### Webapps (webapps.config)

Enable/disable for each installed webapp.

Properties are as follows:

    webapps.{name}.classpath=[space- or comma-separated paths]
    webapps.{name}.startOnLoad=true|false

### Router (router.config)

Configured via /configadvanced in the router console.

Applications
------------

### Addressbook (addressbook/config.txt)

See documentation in SusiDNS.

### I2PSnark (i2psnark.config.d/i2psnark.config)

Configured via the application gui.

### Individual i2psnark (i2psnark.config.d/*/*.config)

The configuration for an individual torrent. Configured via the
application gui.

### I2PTunnel (i2ptunnel.config)

Configured via the /i2ptunnel application in the router console. As of
release 0.9.42, the default i2ptunnel.config file is split into
individual configuration files for each tunnel in the i2ptunnel.config.d
directory. After being split, the properties in the individual files are
NOT prefixed with \"tunnel.N.\".

Properties are as follows:

    # Display description for UI
    tunnel.N.description=

    # Router IP address or host name. Ignored if in router context.
    tunnel.N.i2cpHost=127.0.0.1

    # Router I2CP port. Ignored if in router context.
    tunnel.N.i2cpPort=nnnn

    # For clients only. Local listen IP address or host name.
    tunnel.N.interface=127.0.0.1

    # For clients only. Local listen port.
    tunnel.N.listenPort=nnnn

    # Display name for UI
    tunnel.N.name=

    # Servers only. Default false. Originate connections to local server with a
    # unique IP per-remote-destination.
    tunnel.N.option.enableUniqueLocal=true|false

    # Servers only. Persistent private leaseset key
    tunnel.N.option.i2cp.leaseSetPrivateKey=base64

    # Servers only. Persistent private leaseset key
    tunnel.N.option.i2cp.leaseSetSigningPrivateKey=sigtype:base64

    # Clients only. Create a new destination when reopening the socket manager
    tunnel.N.option.i2cp.newDestOnResume=true|false

    # Servers only. The maximum size of the thread pool, default 65. Ignored
    # for standard servers.
    tunnel.N.option.i2ptunnel.blockingHandlerCount=nnn

    # HTTP client only. Whether to use allow SSL connections to i2p addresses.
    # Default false.
    tunnel.N.option.i2ptunnel.httpclient.allowInternalSSL=true|false

    # HTTP client only. Whether to disable address helper links. Default false.
    tunnel.N.option.i2ptunnel.httpclient.disableAddressHelper=true|false

    # HTTP client only. Comma- or space-separated list of jump server URLs.
    tunnel.N.option.i2ptunnel.httpclient.jumpServers=http://example.i2p/jump

    # HTTP client only. Whether to pass Accept* headers through. Default false.
    tunnel.N.option.i2ptunnel.httpclient.sendAccept=true|false

    # HTTP client only. Whether to pass Referer headers through. Default false.
    tunnel.N.option.i2ptunnel.httpclient.sendReferer=true|false

    # HTTP client only. Whether to pass User-Agent headers through. Default
    # false.
    tunnel.N.option.i2ptunnel.httpclient.sendUserAgent=true|false

    # HTTP client only. Whether to pass Via headers through. Default false.
    tunnel.N.option.i2ptunnel.httpclient.sendVia=true|false

    # HTTP client only. Comma- or space-separated list of in-network SSL
    # outproxies.
    tunnel.N.option.i2ptunnel.httpclient.SSLOutproxies=example.i2p

    # SOCKS client only. Comma- or space-separated list of in-network
    # outproxies for any ports not specified.
    tunnel.N.option.i2ptunnel.socks.proxy.default=example.i2p

    # SOCKS client only. Comma- or space-separated list of in-network
    # outproxies for port NNNN.
    tunnel.N.option.i2ptunnel.socks.proxy.NNNN=example.i2p

    # HTTP client only. Whether to use a registered local outproxy plugin.
    # Default true.
    tunnel.N.option.i2ptunnel.useLocalOutproxy=true|false

    # Servers only. Whether to use a thread pool. Default true. Ignored for
    # standard servers, always false.
    tunnel.N.option.i2ptunnel.usePool=true|false

    # IRC Server only. Only used if fakeHostname contains a %c.  If unset,
    # cloak with a random value that is persistent for the life of this tunnel.
    # If set, cloak with the hash of this passphrase.  Use to have consistent
    # mangling across restarts, or for multiple IRC servers cloak consistently
    # to be able to track users even when they switch servers.  Note: don't
    # quote or put spaces in the passphrase, the i2ptunnel gui can't handle it.
    tunnel.N.option.ircserver.cloakKey=

    # IRC Server only. Set the fake hostname sent by I2PTunnel, %f is the full
    # B32 destination hash, %c is the cloaked hash.
    tunnel.N.option.ircserver.fakeHostname=%f.b32.i2p

    # IRC Server only. Default user.
    tunnel.N.option.ircserver.method=user|webirc

    # IRC Server only. The password to use for the webirc protocol.  Note:
    # don't quote or put spaces in the passphrase, the i2ptunnel gui can't
    # handle it.
    tunnel.N.option.ircserver.webircPassword=

    # IRC Server only.
    tunnel.N.option.ircserver.webircSpoofIP=

    # For clients only. Alias for the private key in the keystore for the SSL
    # socket. Will be autogenerated if a new key is created.
    tunnel.N.option.keyAlias=

    # For clients only. Password for the private key for the SSL socket. Will be
    # autogenerated if a new key is created.
    tunnel.N.option.keyPassword=

    # For clients only. Path to the keystore file containing the private key for
    # the SSL socket. Will be autogenerated if a new keystore is created.
    # Relative to $(I2P_CONFIG_DIR)/keystore/ if not absolute.
    tunnel.N.option.keystoreFile=i2ptunnel-(random string).ks

    # For clients only. Password for the keystore containing the private key for
    # the SSL socket. Default is "changeit".
    tunnel.N.option.keystorePassword=changeit

    # HTTP Server only. Max number of POSTs allowed for one destination per
    # postCheckTime. Default 0 (unlimited)
    tunnel.N.option.maxPosts=nnn

    # HTTP Server only. Max number of POSTs allowed for all destinations per
    # postCheckTime. Default 0 (unlimited)
    tunnel.N.option.maxTotalPosts=nnn

    # HTTP Clients only. Whether to send authorization to an outproxy. Default
    # false.
    tunnel.N.option.outproxyAuth=true|false

    # HTTP Clients only. The password for the outproxy authorization.
    tunnel.N.option.outproxyPassword=

    # HTTP Clients only. The username for the outproxy authorization.
    tunnel.N.option.outproxyUsername=

    # HTTP Clients only. Whether to send authorization to an outproxy. Default
    # false.
    tunnel.N.option.outproxyAuth=true|false

    # Clients only. Whether to store a destination in a private key file and
    # reuse it. Default false.
    tunnel.N.option.persistentClientKey=true|false

    # HTTP Server only. Time period for banning POSTs from a single destination
    # after maxPosts is exceeded, in seconds. Default 1800 seconds.
    tunnel.N.option.postBanTime=nnn

    # HTTP Server only. Time period for checking maxPosts and maxTotalPosts, in
    # seconds. Default 300 seconds.
    tunnel.N.option.postCheckTime=nnn

    # HTTP Server only. Time period for banning all POSTs after maxTotalPosts
    # is exceeded, in seconds. Default 600 seconds.
    tunnel.N.option.postTotalBanTime=nnn

    # HTTP Clients only. Whether to require local authorization for the proxy.
    # Default false. "true" is the same as "basic".
    tunnel.N.option.proxyAuth=true|false|basic|digest

    # HTTP Clients only. The MD5 of the password for local authorization for
    # user USER.
    tunnel.N.option.proxy.auth.USER.md5=

    # HTTP Servers only. Whether to reject incoming connections apparently via
    # an inproxy. Default false.
    tunnel.N.option.rejectInproxy=true|false

    # HTTP Servers only. Whether to reject incoming connections containing a
    # referer header. Default false. Since 0.9.25.
    tunnel.N.option.rejectReferer=true|false

    # HTTP Servers only. Whether to reject incoming connections containing
    # specific user-agent headers. Default false. Since 0.9.25. See
    # tunnel.N.option.userAgentRejectList
    tunnel.N.option.rejectUserAgents=true|false

    # Servers only. Overrides targetHost and targetPort for incoming port NNNN.
    tunnel.N.option.targetForPort.NNNN=hostnameOrIP:nnnn

    # HTTP Servers only. Comma-separated list of strings to match in the
    # user-agent header. Since 0.9.25. Example: "Mozilla,Opera". Case-sensitive.
    # As of 0.9.33, a string of "none" may be used to match an empty user-agent.
    # See tunnel.N.option.rejectUserAgents
    tunnel.N.option.userAgentRejectList=string1[,string2]*

    # Default false. For servers, use SSL for connections to local server. For
    # clients, SSL is required for connections from local clients.
    tunnel.N.option.useSSL=false

    # Each option is passed to I2CP and streaming with "tunnel.N.option."
    # stripped off. See those docs.
    tunnel.N.option.*=

    # For servers and clients with persistent keys only. Absolute path or
    # relative to config directory.
    tunnel.N.privKeyFile=filename

    # For proxies only. Comma- or space-separated host names.
    tunnel.N.proxyList=example.i2p[,example2.i2p]

    # For clients only. Default false.
    tunnel.N.sharedClient=true|false

    # For HTTP servers only. Host name to be passed to the local server in the
    # HTTP headers.  Default is the base 32 hostname.
    tunnel.N.spoofedHost=example.i2p

    # For HTTP servers only. Host name to be passed to the local server in the
    # HTTP headers.  Overrides above setting for incoming port NNNN, to allow
    # virtual hosts.
    tunnel.N.spoofedHost.NNNN=example.i2p

    # Default true
    tunnel.N.startOnLoad=true|false

    # For clients only. Comma- or space-separated host names or host:port.
    tunnel.N.targetDestination=example.i2p[:nnnn][,example2.i2p[:nnnn]]

    # For servers only. Local IP address or host name to connect to.
    tunnel.N.targetHost=

    # For servers only. Port on targetHost to connect to.
    tunnel.N.targetPort=nnnn

    # The type of i2ptunnel
    tunnel.N.type=client|connectclient|httpbidirserver|httpclient|httpserver|ircclient|ircserver|
              server|socksirctunnel|sockstunnel|streamrclient|streamrserver

Note: Each \'N\' is a tunnel number starting with 0. There may not be
any gaps in numbering.

### Router Console

The router console uses the router.config file.

### SusiMail (susimail.config)

See post on zzz.i2p.

References
----------

\[DATAHELPER\]

:   <http://echelon.i2p/javadoc/net/i2p/data/DataHelper.html>

\[Mapping\]

:   <https://geti2p.net/spec/common-structures#type-mapping>

\[PLUGIN\]

:   <https://geti2p.net/spec/plugin>

\[Properties\]

:   <http://docs.oracle.com/javase/1.5.0/docs/api/java/util/Properties.html#load%28java.io.InputStream%29>
