atlassian-confluence
====================

The atlassian-confluence container can be used to spin up an instance of
[Atlassian Confluence®](https://www.atlassian.com/software/confluence).


Quick Start
-----------

To quickly spin up an instance of Atlassian Confluence®, simply specify a port
forwarding rule and run the container:

    $ docker run \
        -p 8090:8090 \
        jleight/atlassian-confluence

Usage
-----

If you want to change the context root of the application (by default the
application listens on `/`) you can follow the instructions in the
[context root](#context-root) section of this document.

If you are not planning on running Atlassian Confluence® behind a reverse proxy,
you can follow the instructions in the [simple](#simple) section. If you plan to
use a reverse proxy, further instructions can be found in the
[reverse proxy](#reverse-proxy) section of this document.

If you are planning to use a different authentication mode, follow the
instructions in the [authentication](#authentication) section of this document.

### Simple

Atlassian Confluence® stores instance-specific data inside a folder it defines
as the `confluence.home` directory. This container defines the `confluence.home`
directory as `/var/opt/atlassian` and exposes it as a volume. As such, it is
recommended to either map this volume to a host directory, or to create a data
container for the volume.

A data container can be created by running the following command:

    $ docker create \
        --name confluence-data \
        jleight/atlassian-confluence

The application container can then be started by running:

    $ docker run \
        --name confluence \
        --volumes-from confluence-data \
        -p 8090:8090 \
        jleight/atlassian-confluence

### Context Root

If you want to run Atlassian Confluence® under a context root other than `/`,
you can specify an extra environment variable when running the container:

- *TC_ROOTPATH*: the new context root for Atlassian Confluence®.

It can be specified in the `docker run` command like this:

    $ docker run \
        --name confluence \
        --volumes-from confluence-data \
        -p 8090:8090 \
        -e TC_ROOTPATH=/confluence \
        jleight/atlassian-confluence

Atlassian Confluence® can then be accessed at http://${HOST_IP}:8090/confluence.

### Reverse Proxy

If you are using a reverse proxy to proxy connections to Atlassian Confluence®,
you will need to specify two extra environment variables when starting this
container.

The variables are as follows:

- *TC_PROXYNAME*: the domain name at which Atlassian Confluence® will be
  accessible.
- *TC_PROXYPORT*: the port on which Atlassian Confluence® will be accessible.

For example, if you are planning on running Atlassian Confluence® at
https://example.com/confluence, you would use the following command:

    $ docker run \
        --name confluence \
        --volumes-from confluence-data \
        -p 8090:8090 \
        -e TC_PROXYNAME=example.com \
        -e TC_PROXYPORT=443 \
        -e TC_ROOTPATH=/confluence \
        jleight/atlassian-confluence

Once your proxy server is configured, Atlassian Confluence® should be accessible
at https://example.com/confluence.

### Authentication

By default, Atlassian Confluence® is configured to use `ConfluenceAuthenticator`
for authentication. This allows for authentication and authorization to be
performed against an internal directory of users.

If you want to switch to one of the other authentication providers, you can
specify the *CONFLUENCE_AUTH* environment variable with one of the following
values:

- `ConfluenceAuthenticator` (default)
- `ConfluenceCrowdSSOAuthenticator`
- `ConfluenceGroupJoiningAuthenticator`

If you are using the `ConfluenceCrowdSSOAuthenticator` authenticator, you can
also supply the application's name, password, and Atlassian Crowd's® base URL as
environment variables:

- *CROWD_APP_NAME* the application name configured in Atlassian Crowd®.
- *CROWD_APP_PASS* the password configured in Atlassian Crowd®.
- *CROWD_BASE_URL* the base URL of Atlassian Crowd®, including "/crowd".

Building on the previous reverse proxy example, here's how you can switch to
Atlassian Crowd® single sign-on authentication running behind the same proxy:

    $ docker run \
        --name confluence \
        --volumes-from confluence-data \
        -p 8090:8090 \
        -e TC_PROXYNAME=example.com \
        -e TC_PROXYPORT=443 \
        -e TC_ROOTPATH=/confluence \
        -e CONFLUENCE_AUTH=ConfluenceCrowdSSOAuthenticator \
        -e CROWD_APP_NAME=confluence \
        -e CROWD_APP_PASS=somesecretpassword \
        -e CROWD_BASE_URL=https://example.com/crowd \
        jleight/atlassian-confluence
