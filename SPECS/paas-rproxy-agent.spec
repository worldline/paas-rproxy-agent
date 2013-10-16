%define _topdir /usr/src/rpmbuild
%define prefix /usr/local
%define prefix2 /usr/libexec/mcollective
%define sources /usr/local/paas-rproxy-agent/paas
%define sources2 /usr/local/paas-rproxy-agent/mcollective
Name:           paas-rproxy-agent
Version:        0.2
Release:        1
%define buildroot %{_topdir}/%{name}-%{version}
Summary:        Mcollective Agent to update reverses proxies conf

Group:          Applications/Paas
BuildArch:			noarch
License:        Apache 2.0
URL:            http://worldline.com
BuildRoot:      %{buildroot}
Source0:		/usr/local/paas-rproxy-agent
Prefix:		%{prefix}

#BuildRequires:  
Requires:				ruby193 >= 1
Requires:				ruby193-rubygems >= 1.8.10
Requires:				mcollective >= 2.2.3
Requires:				ruby193-mcollective-common >= 2.2.3
Requires:				ruby193-rubygem-sqlite3 >= 1.3.3

%description
Paas: Mcollective Agent to update reverses proxies conf

%prep
rm -rf %{name}
mkdir %{name}
%__cp -Rp %{sources} %{sources2} %{name}

%install
mkdir -p ${RPM_BUILD_ROOT}/%{prefix}
mkdir -p ${RPM_BUILD_ROOT}/%{prefix2}
%__cp -Rp %{name}/paas ${RPM_BUILD_ROOT}/%{prefix}
%__cp -Rp %{name}/mcollective ${RPM_BUILD_ROOT}/%{prefix2}

%clean
# rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/usr/local/paas/bin/rproxy
/usr/local/paas/bin/isIpHere
/usr/libexec/mcollective/mcollective/agent/rproxy.ddl
/usr/libexec/mcollective/mcollective/agent/rproxy.tmpl
/usr/libexec/mcollective/mcollective/agent/rproxy.rb

%config

%post
if ! [ -f /opt/rh/ruby193/root/usr/libexec/mcollective/mcollective/agent/rproxy.ddl ]; then ln -s /usr/libexec/mcollective/mcollective/agent/rproxy.ddl /opt/rh/ruby193/root/usr/libexec/mcollective/mcollective/agent/rproxy.ddl; fi
if ! [ -f /opt/rh/ruby193/root/usr/libexec/mcollective/mcollective/agent/rproxy.rb ]; then ln -s /usr/libexec/mcollective/mcollective/agent/rproxy.rb /opt/rh/ruby193/root/usr/libexec/mcollective/mcollective/agent/rproxy.rb; fi
if ! [ -f /opt/rh/ruby193/root/usr/libexec/mcollective/mcollective/agent/rproxy.tmpl ]; then ln -s /usr/libexec/mcollective/mcollective/agent/rproxy.tmpl /opt/rh/ruby193/root/usr/libexec/mcollective/mcollective/agent/rproxy.tmpl; fi

%postun

%changelog
* Mon Oct 10 2013 - 0.2 - a186643
- Cleaned version to push to github
* Mon Jul 10 2013 - 0.1 - a186643
- Version initiale

