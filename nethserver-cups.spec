Summary: NethServer CUPS module
Name: nethserver-cups
Version:        1.1.1
Release:        1
License: GPL
Group: Networking/Daemons
Source0: %{name}-%{version}.tar.gz
Packager: Giacomo Sanchietti <giacomo@nethesis.it>

#Requires: cups-pdf
BuildArch: noarch

Requires: foomatic, ghostscript, hpijs
Requires: nethserver-base >= 1.1.0

BuildRequires: nethserver-devtools
AutoReq: no

%description
CUPS module for NethServer.

Based on a work of Robert van den Aker <robert2@dds.nl>

%prep
%setup -q

%build
perl createlinks
mkdir -p root/usr/lib/cups/backend && ln -s /usr/bin/smbspool root/usr/lib/cups/backend/smb

%install
rm -rf $RPM_BUILD_ROOT
(cd root ; find . -depth -print | cpio -dump $RPM_BUILD_ROOT)
rm -f %{name}-%{version}-%{release}-filelist
/sbin/e-smith/genfilelist $RPM_BUILD_ROOT \
    --file /home/e-smith/db/cups "config(noreplace) %attr(0640,root,admin)" \
    > %{name}-%{version}-%{release}-filelist
echo "%doc COPYING" >> %{name}-%{version}-%{release}-filelist


%post

%preun

%clean
rm -rf $RPM_BUILD_ROOT

%files -f %{name}-%{version}-%{release}-filelist
%defattr(-,root,root)

%changelog
* Wed Aug 20 2014 Davide Principi <davide.principi@nethesis.it> - 1.1.1-1.ns6
- Missing Italian translation - Bug #2706 [NethServer]

* Wed Feb 05 2014 Davide Principi <davide.principi@nethesis.it> - 1.1.0-1.ns6
- Printer list status - Feature #1625 [NethServer]
- Lib: synchronize service status prop and chkconfig - Feature #2067 [NethServer]

* Tue May 07 2013 Giacomo Sanchietti <giacomo.sanchietti@nethesis.it> - 1.0.2-1.ns6
• Rebuild for automatic package handling. #1870

* Mon Mar 18 2013 Giacomo Sanchietti <giacomo.sanchietti@gmail.com> 1.0.1-1
- Remove web ui module
- Add backup configuration  #1684
- Add migration code #1683
- Use system ssl certificate

* Wed Jan 16 2013 Giacomo Sanchietti <giacomo.sanchietti@gmail.com> 1.0.0-1
- First release
