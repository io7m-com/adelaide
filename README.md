adelaide
===

[![Maven Central](https://img.shields.io/maven-central/v/com.io7m.adelaide/com.io7m.adelaide.svg?style=flat-square)](http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22com.io7m.adelaide%22)
[![Maven Central (snapshot)](https://img.shields.io/nexus/s/com.io7m.adelaide/com.io7m.adelaide?server=https%3A%2F%2Fs01.oss.sonatype.org&style=flat-square)](https://s01.oss.sonatype.org/content/repositories/snapshots/com/io7m/adelaide/)
[![Codecov](https://img.shields.io/codecov/c/github/io7m-com/adelaide.svg?style=flat-square)](https://codecov.io/gh/io7m-com/adelaide)
![Java Version](https://img.shields.io/badge/23-java?label=java&color=a1e65c)

![com.io7m.adelaide](./src/site/resources/adelaide.jpg?raw=true)

| JVM | Platform | Status |
|-----|----------|--------|
| OpenJDK (Temurin) Current | Linux | [![Build (OpenJDK (Temurin) Current, Linux)](https://img.shields.io/github/actions/workflow/status/io7m-com/adelaide/main.linux.temurin.current.yml)](https://www.github.com/io7m-com/adelaide/actions?query=workflow%3Amain.linux.temurin.current)|
| OpenJDK (Temurin) LTS | Linux | [![Build (OpenJDK (Temurin) LTS, Linux)](https://img.shields.io/github/actions/workflow/status/io7m-com/adelaide/main.linux.temurin.lts.yml)](https://www.github.com/io7m-com/adelaide/actions?query=workflow%3Amain.linux.temurin.lts)|
| OpenJDK (Temurin) Current | Windows | [![Build (OpenJDK (Temurin) Current, Windows)](https://img.shields.io/github/actions/workflow/status/io7m-com/adelaide/main.windows.temurin.current.yml)](https://www.github.com/io7m-com/adelaide/actions?query=workflow%3Amain.windows.temurin.current)|
| OpenJDK (Temurin) LTS | Windows | [![Build (OpenJDK (Temurin) LTS, Windows)](https://img.shields.io/github/actions/workflow/status/io7m-com/adelaide/main.windows.temurin.lts.yml)](https://www.github.com/io7m-com/adelaide/actions?query=workflow%3Amain.windows.temurin.lts)|

## adelaide

Better [ActiveMQ Artemis](https://activemq.apache.org/components/artemis/) OCI
images.

## Motivation

The existing Artemis OCI images have a number of problems that are addressed
by the `adelaide` images.

* The images expect users to generate configuration files and then use them
  in the broker instances. This makes the container the "owner" of the
  configuration files instead of the files being a read-only input to the
  container, and makes it difficult to keep them in version control.
  Additionally, the images seem to be designed under the assumption that a user
  might want to run more than one broker in a container instance. Nobody
  sensible wants to do this. The `adelaide` images expose a single `/data`
  volume for the single broker instance supported by the container, and expose
  a single `/data/etc` volume to allow for configuration files to be read-only
  mounted in the container, and managed externally.

* The images expect to be run under Docker, and therefore do the usual
  idiotic "run as a separate UID inside the container" dance. This is a
  fundamental design flaw of Docker and is one of many reasons to exclusively
  use `podman` instead. The `adelaide` images do not do any manipulation of
  UIDs or GIDs; if you run the `adelaide` image as UID 0 on the host, Artemis
  will run as UID 0 inside the container. Simply run `podman` as a non-root
  user on the host, and everything inside the container is guaranteed to run
  without privileges of any kind. The `adelaide` images do not support Docker;
  this is a feature and not a bug.

* The `adelaide` images are free of any platform-specific complexity. Noone
  sensible is hosting message broker containers on any platform other than
  Linux.

* The `adelaide` images are designed to be run with an entirely read-only
  filesystem (aside from the read/write mounted broker instance directory).
  This is intended to allow for greater reliability and security.

## Features

* Runs rootless with a read-only root directory!
* Version control your broker configuration files!
* ISC license.

## Usage

Run `podman` as an unprivileged user, with an invocation similar to:

```
podman run \
  --read-only \
  --volume '/path/to/host/tls:/tls:ro,z' \
  --volume '/path/to/broker/data:/data:Z,rw' \
  --volume '/path/to/broker/etc:/data/etc:Z,ro' \
  --publish '...:61616:61616/tcp' \
  quay.io/io7mcom/adelaide:${VERSION}
```

Naturally, the exact directories you mount, and the exact TCP ports you
publish is dependent on your broker configuration.

Use the following volume mounts:

|Mount|Description|
|-----|-----------|
|`/data`|Persistent broker data (the "broker instance")|
|`/data/etc`|Broker configuration files (such as `broker.xml`)|
|`/tls`|A directory containing keystores.|

The `/data` mount contains the persistent state of the one-and-only broker
instance used by the container.

The `/data/etc` mount should be mounted read-only and should contain your
version-controlled broker configuration files (such as `broker.xml`).

The `/tls` mount should contain keystores and truststores.

For extra security, run `podman run` with the `--read-only` option; the images
are designed such that no part of the filesystem except for `/data` is required
to be writable.


