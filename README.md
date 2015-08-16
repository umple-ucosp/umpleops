capbash-deploykeys
==============

Scripts for deploying a consistent set of machine public/private keys for access to third party systems

# How to Install #

Install capbash first, more details at:
https://github.com/capbash/capbash

```
curl -s https://raw.githubusercontent.com/capbash/capbash/master/capbash-installer | bash
capbash new YOUR_REPO_ROOT
cd YOUR_REPO_ROOT
```

Now you can install deploykeys into your project

```
capbash install deploykeys
```

# Configurations #

The available configurations include:

```
LAUNCHER_OWNER=${DEPLOYKEYS_NAME-root}
DEPLOYKEYS_KEYNAME=${DEPLOYKEYS_KEYNAME-id_dsa}
DEPLOYKEYS_KNOWN_HOSTS=${DEPLOYKEYS_NAME-known_hosts}
```

# Deploy to Remote Server #

To push the deploykeys script to your server, all you need if the IP or hostname of your server (e.g. 192.167.0.48) and your root password.

```
capbash deploy <IP> deploykeys
```

For example,

```
capbash deploy 127.0.0.1 deploykeys
```
