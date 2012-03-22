%define git_url git://github.com/flaboy/metronome.git
%define rev %(date +%%Y%%m%%d%%H%%M)
%define __prelink_undo_cmd %{nil}

Name:           metronome
Version:        %{rev}
Release:        shopex
Summary:        metronome

Group:          Development/Languages
License:        ERPL
URL:            http://www.shopex.cn
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  m4
BuildRequires:  erlang >= R14
BuildRequires:  git

%description
ecae

%prep
export LC_ALL=en_US.UTF-8
rm -rf metronome
git clone %{git_url} metronome

%build
cd metronome
./configure --prefix=/usr/local \
         --exec-prefix=%{_prefix} \
         --bindir=%{_bindir} \
         --libdir=%{_libdir}

GIT_SSL_NO_VERIFY=true DESTDIR=$RPM_BUILD_ROOT make clean release

%install
rm -rf $RPM_BUILD_ROOT
cd metronome
make DESTDIR=$RPM_BUILD_ROOT install
mkdir -p $RPM_BUILD_ROOT/etc/init.d
mkdir -p $RPM_BUILD_ROOT/usr/bin
cp support/metronome-init.script $RPM_BUILD_ROOT/etc/init.d/metronome
chmod 0555 $RPM_BUILD_ROOT/etc/init.d/metronome
find $RPM_BUILD_ROOT -type d -name ".git" -exec rm -rf {} \; 2>&1 >/dev/null || echo "rm .git"

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
/usr/local/metronome
/etc/init.d/metronome
/usr/bin
