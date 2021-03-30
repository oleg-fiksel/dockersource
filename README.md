# ⚠️ WARNING! This repo is moved to https://gitlab.com/olegfiksel/dockersource

# Dockersource

Check `FROM` derective of a `Dockerfile` for whitelisted or blacklisted image RegEx.

# Use-case

You want to make sure the sources for your Dockerfiles (`FROM ...`) are controlled by a whitelist or a backlist. This take cares of having such a Dockerfile in your project:
```
FROM wildhacker/openjdk:latest
COPY target/*.jar /work
```

# Build

It's a Perl 5 script so you can use any Perl (>= v5.6.0) environment to run this script or use the official Docker image: https://hub.docker.com/r/olegfiksel/dockersource

# Run

`docker run olegfiksel/dockersource perl /opt/dockersource/dockersource.pl --help`

```
dockersource.pl Version: 3.0.0
Usage: dockersource.pl (--whitelist 'regex'|--blacklist 'regex') [--summary] [--debug] [--help] /path/to/Dockerfile /path/to_another/Dockerfile

--whitelist         Specify a Perl RegEx to whitelist Docker images used in FROM clause
--blacklist         Specify a Perl RegEx to blacklist Docker images used in FROM clause
--summary           Print the whitelist and blacklist summary before the run
--debug             Enable debug output

Return codes:
      0 - No violations found
      0 - No parameters given
    >=1 - Number of violations found

Examples:
    dockersource.pl --whitelist '^my-private-registry.org/.*' /path/to/Dockerfile /path/to/another/Dockerfile
    dockersource.pl --whitelist '^openjdk' --whitelist 'openjdk' /path/to/Dockerfile
    dockersource.pl --whitelist '^openjdk:.*-alpine' /path/to/Dockerfile
    dockersource.pl --blacklist '^wildhacker/.*' /path/to/Dockerfile
```

## GitLab-CI

Sample job definition (`.gitlab-ci.yml:`):

```
stages:
  - compliance

compliance:dockerfile:
  stage: compliance
  image: olegfiksel/dockersource
  script:
    - |
      find . -type f -name Dockerfile | xargs perl /opt/dockersource/dockersource.pl \
        --whitelist '^openjdk:\d+[\w\d-]*$' \
        --blacklist ':latest' \
        --blacklist '.'
```
