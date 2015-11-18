# GitLab Backup

A command line tool for backing up GitLab repositories.


## Prerequisites

* [Git](http://git-scm.com/)
* [Ruby](http://www.ruby-lang.org/) (>= 1.9.3)

To backup your repositories you **must** have the SCM tools
your repositories use on your `PATH`.


## Installation

    $ gem install gitlab-backup


## Usage

    $ gitlab-backup [options] /path/to/backupdir

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
