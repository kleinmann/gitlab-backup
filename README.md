# GitLab Backup

A command line tool for backing up GitLab repositories.


## Prerequisites

* [Git](http://git-scm.com/)
* [Ruby](https://www.ruby-lang.org/) (>= 2.1.0)

To backup your repositories you **must** have the git on your `PATH`.


## Installation

    $ gem install gitlab-backup


## Usage

    $ gitlab-backup [options] ~/backup

See the help prompt for more info:

    $ gitlab-backup --help


## Config files

You can provide a config file in the YAML format
to `gitlab-backup` via the `--config` or `-c` option.
Settings specified on the command line have precedence
over settings in the config file.

The `host` and `token` settings will be
read from the config file.

For example to backup every repository the user with the token `example` has access to
put the following in a config file and pass it to `gitlab-backup`:

    host: https://gitlab.com
    token: example


## License

[ISC](LICENSE)

## Thanks

This project is based on the [previous work](https://bitbucket.org/seth/bitbucket-backup) of Seth Jackson for bitbucket-backup.
