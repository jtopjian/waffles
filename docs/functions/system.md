# System Functions

`lib/system.sh` contains functions that are considered core to Waffles.

[TOC]

## stdlib.array_contains

Reports true if element exists in an array.

```shell
x=(foo bar baz)
if stdlib.array_contains "x" "foo" ; then
  echo "Exists"
fi
```

## stdlib.array_join

Joins an array into a string.

```shell
x=(foo bar baz)
stdlib.array_join x ,
=> foo,bar,baz
```

## stdlib.array_length

Returns the length of an array.

```shell
x=(a b c)
stdlib.array_length x
=> 3
```

## stdlib.array_pop

Removes and the last element from array $1 and optionally stores it in $2

```shell
x=(a b c)
stdlib.array_pop x y
echo $y
=> c
```

## stdlib.array_push

Adds an element to the end of an array.

```shell
x=()
stdlib.array_push x foo
```

## stdlib.array_shift

Removes and returns the first element from array $1 and optionally stores it in $2

```shell
x=(a b c)
stdlib.array_shift x y
echo $y
=> a
```

## stdlib.array_unshift

Adds an element to the beginning of the array.

```shell
x=(b c)
stdlib.array_unshift x a

```

## stdlib.capture_error

Takes a command as input, prints the command, and detects if anything was written to `stderr`. If there was, the error is printed to `stderr` again, and if `WAFFLES_EXIT_ON_ERROR` is set, Waffles halts.

```shell
stdlib.capture_error apt-get update
```

## stdlib.command_exists

A simple wrapper around `which`.

```shell
if [[ stdlib.command_exists apt-get ]]; then
  stdlib.info "We're on a Debian-based system."
fi
```

## stdlib.data

The same as `stdlib.profiles` but the shell scripts can be placed differently:

```shell
stdlib.data common => data/common.sh
stdlib.data common => data/common/init.sh
stdlib.data common/users => data/common/users.sh
stdlib.data memcached => data/memcached.sh
stdlib.data memcached => data/memcached/init.sh
```

## stdlib.debug

Prints a log message at `debug` level.

```shell
stdlib.debug "Foobar"
```

## stdlib.debug?

Determines if Waffles is being run in `debug` mode.

```shell
if stdlib.debug? ; then
  stdlib.debug "We're in debug mode."
fi
```

## stdlib.debug_mute

Like `stdlib.mute` but messages only appear in `debug` mode.

```shell
stdlib.debug_mute apt-get update
```

## stdlib.dir

A simple function that returns the current directory of the script currently being run.

## stdlib.error

Prints an error message to `stderr`.

```shell
stdlib.error "Foobar"
```

## stdlib.exec

A simple function that takes a command as input, prints the command, and then executes it.

```shell
stdlib.exec apt-get update
```

## stdlib.git_profile

stdlib.git_profile will check a profile out from a git repository. It will be ignored if running in REMOTE mode, so repositories are only created when Waffles is run locally.

stdlib.git_profile repositories must be named:

```shell
waffles-profile-$profile_name
```

stdlib.git_profiles must follow the following syntax:

```
stdlib.git_profile https://github.com/jtopjian/waffles-profile-openstack
stdlib.git_profile https://github.com/jtopjian/waffles-profile-openstack branch dev
stdlib.git_profile https://github.com/jtopjian/waffles-profile-openstack tag 0.5.1
stdlib.git_profile https://github.com/jtopjian/waffles-profile-openstack commit 023a83
```

## stdlib.git_profile_push

Works the same way as stdlib.git_profile, but the git repository is downloaded on the Waffles "server" and pushed to the node. This is useful in cases when the nodes do not have direct access to the git repository.

## stdlib.hash_keys

Returns the keys of a hash / associative array.

```shell
declare -A foo=(
  [a]=1
  [b]=2
  [c]=3
)

stdlib.hash_keys "foo"
=> a b c

x=($(stdlib.hash_keys "foo"))
echo "${x[1]}"
=> b
```

## stdlib.include

A more intelligent `source`. It checks if the file being sourced / included exists, and if not, prints a warning and moves on.

## stdlib.info

Prints a log message at `info` level.

```shell
stdlib.info "Foobar"
```

## stdlib.mute

Prints the command being run, but suppresses the command output.

```shell
stdlib.mute apt-get update
```

## stdlib.noop?

Determines if Waffles is being run in `noop` mode.

```shell
if stdlib.noop? ; then
  stdlib.info "We're in noop mode."
fi
```

## stdlib.profile

Takes a profile as input and determines the shell script attached to the profile.

If Waffles is being run locally, then `stdlib.include` is run on the script. If Waffles is being run in push-based mode, then the profile is marked to be copied to the remote node.

```shell
stdlib.profiles common/users => profiles/common/scripts/users.sh
stdlib.profiles common/packages => profiles/common/scripts/packages.sh
stdlib.profiles memcached => profiles/memcached/scripts/init.sh
stdlib.profiles memcached/utils => profiles/memcached/scripts/utils.sh
```

## stdlib.split

Splits a string into an array. Stores the result in `__split`. The delimiter can be multi-character.

```shell
stdlib.split "foo/bar", "/"
stdlib.info $__split[1] # bar
```

## stdlib.subtitle

Sets a subtitle context. This is usually used internally by resources. An internal counter to determine if the resource was changed:

```shell
$ cat profiles/common/scripts/package.sh
stdlib.title "profiles/common/packages"
stdlib.apt --package sl

if [[ $stdlib_resource_change == true ]]; then
  stdlib.info "The state of package sl changed"
fi

stdlib.apt --package cowsay

if [[ $stdlib_resource_change == true ]]; then
  stdlib.info "The state of package cowsay changed"
fi
```

## stdlib.sudo_exec

Runs a command as another user via sudo:

```shell
stdlib.sudo_exec username tar xzvf foobar.tar.gz
```

## stdlib.title

Sets a title context. A title is a major section of Waffles being run; for example, a profile. You usually being profiles by setting a title:

```shell
$ cat profiles/common/scripts/package.sh
stdlib.title "profiles/common/packages"
stdlib.apt --package sl
```

Internal counters are reset whenever `stdlib.title` is used. This is useful for determining if any changes were made to a resource or the profile as a whole:

```shell
$ cat profiles/common/scripts/package.sh
stdlib.title "profiles/common/packages"
stdlib.apt --package sl
stdlib.apt --package cowsay

if [[ $stdlib_state_change == true ]]; then
  stdlib.info "One of the above packages were updated."
fi
```

## stdlib.trim

Trims the whitespace on both sides of a string.

```shell
trimmed=$(stdlib.trim "   foobar   "
```

## stdlib.warn

Prints a warning message.

```shell
stdlib.warn "Foobar"
```
