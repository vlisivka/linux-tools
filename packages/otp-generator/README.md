otp-generator
===========


NAME
===========

otp-generator.pl - generate one-time-passwords using SHA1, master key, and user data

SYNOPSIS
========

otp-generator.pl [OPTIONS]

OPTIONS
=======

    --help
        Print a brief help message and exit.

    --man
        Show manual page.

    --help | -?
        Show this help page and exit.

    --man
        Show full documentation.

    --verbose | -v
        Print generated data string before hashing (without master key).

    --master-key PATH_TO_FILE
        Path to file with master key. Please, keep your master password in
        safe place, because it can be used to generate all passwords at any
        time.

    --user | -u USER_NAME
        User name.

    --host | -h HOST_NAME
        Host name.

    --role | -r ROLE_NAME
        Role name.

    --resource | -R RESOURCE_NAME
        Resource name.

    --custom | -c CUSTOM_DATA
        Custom text.

    --date-pattern | -d DATE_PATTERN
        Date pattern. Default value is 'YMDhm', where Y is year, M is month,
        D is day of month, h is hour, and m is minute.

        Examples:

          -d Y
          # Change passwords once a year

          -d YMD
          # Change passwords once a day

          -d ''
          # disable date generation, so passwords will be independed
          # from date, i.e. permanent.

ARGUMENTS
=========

Arguments are not allowed.

DESCRIPTION
===========

Purpose of this script is to generate one time passwords, or permanent
passwords, using secret master key and other information: user name,
host name, role, resource, date, time, etc.

Script does that by generating of SHA1 hash in base64 encoding using
master key, date/time, and user provided data.

It is NOT safe to set UID or GID on this script to allow unprivileged
users to generate passwords. Use sudo and wrapper script for that
purpose to limit set of allowed options, i.e. if you need to allow
unprivileged user to generate OT passwords using master key without risk
of disclose master key or risk of generating of passwords for other
services, use following wrapper script as example:

      #!/usr/bin/perl -wT
      $ENV{ 'PATH' } = '/bin:/usr/bin:/usr/local/bin';
      delete @ENV{ 'IFS', 'CDPATH', 'ENV', 'BASH_ENV' };
      exec '/usr/bin/otp-generator.pl', '-h','prod-backup', '-u','backup', '-r','mysql', '-d','YM';

AUTHOUR
=======

Volodymyr M. Lisivka <vlisivka@gmail.com>
