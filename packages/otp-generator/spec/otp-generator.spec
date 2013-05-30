
Name:           otp-generator
Version:        1.0.0
Release:        2%{?dist}
Summary:        Generate One-Time-Passwords
Group:          System Environment/Base
License:        GPLv2
URL:            https://github.com/vlisivka/linux-tools
Source:         %{name}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)-%{JOB_NAME}
BuildArch:      noarch

# For shell script
Requires:       perl
Requires:       perl-Digest-SHA1

%description

Generate One-Time-Passwords using SHA1 on master key, user name, host,
role, resource, and date/time.

%prep
%setup -q -n %{name}

%build

# Nothing to do

%install
rm -rf "$RPM_BUILD_ROOT"
mkdir -p "$RPM_BUILD_ROOT"

cp -a src/* "$RPM_BUILD_ROOT/"

# Generate man page(s)
mkdir -p "$RPM_BUILD_ROOT/usr/share/man/man1/"
for I in src/usr/bin/*.pl
do
  pod2man "$I" >"$RPM_BUILD_ROOT/usr/share/man/man1/`basename \"$I\"`.1"
done

%clean
rm -rf "$RPM_BUILD_ROOT"

%files
%defattr(0644,root,root,755)

%dir %attr(0700,root,root) %{_sysconfdir}/otp-generator/
%attr(0600,root,root) %{_sysconfdir}/otp-generator/*

%attr(0755,root,root) %{_bindir}/*.pl
%attr(0644,root,root) /usr/share/man/man1/*

%changelog
