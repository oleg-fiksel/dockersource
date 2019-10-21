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
./dockersource.pl Version: 2.0.0
Usage: ./dockersource.pl (--whitelist 'regex'|--blacklist 'regex') [--debug] [--help] /path/to/Dockerfile /path/to_another/Dockerfile

--whitelist         specify a Perl RegEx to whitelist Docker images used in FROM clause
--blacklist         specify a Perl RegEx to blacklist Docker images used in FROM clause

Return codes:
      0 - No violations found
    >=1 - Number of violations found

Examples:
    ./dockersource.pl --whitelist '^my-private-registry.org/.*' /path/to/Dockerfile /path/to/another/Dockerfile
    ./dockersource.pl --whitelist '^openjdk' --whitelist 'openjdk' /path/to/Dockerfile
    ./dockersource.pl --whitelist '^openjdk:.*-alpine' /path/to/Dockerfile
    ./dockersource.pl --blacklist '^wildhacker/.*' /path/to/Dockerfile
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
      find . -type f -name Dockerfile | perl /opt/dockersource/dockersource.pl \
        --whitelist '^openjdk:\d+[\w\d-]*$' \
        --blacklist ':latest' \
        --blacklist '.'
```
