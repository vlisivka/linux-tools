#!/usr/bin/perl
use warnings;
use strict;
use Digest::SHA1  qw(sha1_base64);
use Getopt::Long;
use Pod::Usage;

# Path to master key file. Only first line will be used, without
# trailing spaces and new line character.
my $masterKeyFile="/etc/otp-generator/master-key";

my $user='';
my $host='';
my $role='';
my $resource='';
my $custom='';
my $datePattern='YMDhm';

my $verbose=0;

# Prepend zero to number, which is less than 10.
sub pz($) {
  my ($n) = @_;
  if($n<10) {
    return '0'.$n;
  } else {
    return ''.$n;
  }
}

# Generate numerical date using pattern.
# Jan is '1'.
# Zero is prepended to month, day, hour, minute.
# Supported fields: Y (year), M (month), D (day), h(hour), m (minute).
# Use blank pattern or 'x' character for nothing.
sub generateDate($) {
  my ($datePattern)=@_;
  my ($sec, $min, $hour, $day, $month, $year, $wday, $yday, $isdst) = gmtime(time);

  my $date='';

  my @chars=split(//, $datePattern);
  for my $char (@chars) {
    if($char eq 'x') {
      # Do nothing
      return '';
    } elsif($char eq 'Y') {
      $date .= (1900+$year);
    } elsif ($char eq 'M') {
      $date .= pz(1+$month);
    } elsif ($char eq 'D') {
      $date .= pz($day);
    } elsif ($char eq 'h') {
      $date .= pz($hour);
    } elsif ($char eq 'm') {
      $date .= pz($min);
    } else {
      die "[otp-generator.pl] ERROR: Wrong date field: \"$char\", date pattern: \"$datePattern\".";
    }
  }

  return $date;
}

sub main() {

  my $date=generateDate($datePattern);

  # Read master key from configuration file
  open(FILE, $masterKeyFile) || die "[otp-generator.pl] ERROR: Cannot open master key file: $!";
  my $masterKey= <FILE>; # Read first line only

  # Drop trailing spaces and newline
  $masterKey =~ s/\s*$//s;


  my $data="$user|$host|$role|$resource|$date|$custom";

  print "[otp-generator.pl] INFO: Data before hashing with SHA1 (without master key): \"MASTER_KEY|$data\".\n" if($verbose);

  my $digest = sha1_base64("$masterKey|$data");

  print $digest, "\n";
}

my $help=0;
my $man=0;

Getopt::Long::Configure( qw( posix_default no_ignore_case_always) );
GetOptions(
  'help|?' => \$help,
  'man' => \$man,
  'verbose|v' => \$verbose,

  'master-key=s' => \$masterKeyFile,

  'user|u=s' => \$user,
  'host|h=s' => \$host,
  'role|r=s' => \$role,
  'resource|R=s' => \$resource,
  'custom|c=s' => \$custom,
  'date-pattern|d=s' => \$datePattern,
) || die "[otp-generator.pl] ERROR: Incorrect option.";

if($help) {
  pod2usage(   -verbose => 1, -noperldoc => 1  );
} elsif($man) {
  pod2usage(   -verbose => 2, -noperldoc => 1  );
}

main();

__END__

=pod

=head1 NAME

rds-backup-util.pl - generate one-time-passwords using SHA1, master key, and user data

=head1 SYNOPSIS

otp-generator.pl [OPTIONS]

=head1 OPTIONS

=over 4

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Show manual page.

=item B<--help> | B<-?>

Show this help page and exit.

=item B<--man>

Show full documentation.

=item B<--verbose> | B<-v>

Print generated data string before hashing (without master key).

=item B<--master-key> PATH_TO_FILE

Path to file with master key. Please, keep your master password in safe
place, because it can be used to generate all passwords at any time.

=item B<--user> | B<-u> USER_NAME

User name.

=item B<--host> | B<-h> HOST_NAME

Host name.

=item B<--role> | B<-r> ROLE_NAME

Role name.

=item B<--resource> | B<-R> RESOURCE_NAME

Resource name.

=item B<--custom> | B<-c> CUSTOM_DATA

Custom text.

=item B<--date-pattern> | B<-d> DATE_PATTERN

Date pattern. Default value is 'YMDhm', where Y is year, M is month, D
is day of month, h is hour, and m is minute.

Examples:

  -d Y
  # Change passwords once a year

  -d YMD
  # Change passwords once a day

  -d ''
  # disable date generation, so passwords will be independed
  # from date, i.e. permanent.

=back

=head1 ARGUMENTS

Arguments are not allowed.

=head1 DESCRIPTION

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

=head1 AUTHOUR

Volodymyr M. Lisivka <vlisivka@gmail.com>

=cut
