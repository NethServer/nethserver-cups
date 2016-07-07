Summary: NethServer CUPS module
Name: nethserver-cups
Version: 1.2.0
Release: 1%{?dist}
License: GPL
Source0: %{name}-%{version}.tar.gz
URL: %{url_prefix}/%{name}
BuildArch: noarch

Requires: foomatic, ghostscript, hpijs, hplip
Requires: nethserver-base

BuildRequires: nethserver-devtools

%description
CUPS module for NethServer.
Based on a work of Robert van den Aker <robert2@dds.nl>

%prep
%setup -q

%build
perl createlinks
mkdir -p root/usr/lib/cups/backend && ln -s /usr/bin/smbspool root/usr/lib/cups/backend/smb

%install
rm -rf %{buildroot}
(cd root ; find . -depth -print | cpio -dump %{buildroot})
%{genfilelist} %{buildroot} > %{name}-%{version}-%{release}-filelist

%files -f %{name}-%{version}-%{release}-filelist
%defattr(-,root,root)
%doc COPYING
%dir %{_nseventsdir}/%{name}-update

%changelog
* Thu Jul 07 2016 Stefano Fancello <stefano.fancello@nethesis.it> - 1.2.0-1
- First NS7 release

* Tue Sep 29 2015 Davide Principi <davide.principi@nethesis.it> - 1.1.3-1
- Make Italian language pack optional - Enhancement #3265 [NethServer]

* Wed Jul 15 2015 Giacomo Sanchietti <giacomo.sanchietti@nethesis.it> - 1.1.2-1
- Event trusted-networks-modify - Enhancement #3195 [NethServer]

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
