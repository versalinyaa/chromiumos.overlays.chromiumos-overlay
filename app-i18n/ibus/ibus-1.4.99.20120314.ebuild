# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# How to run the test manually:
#   (chroot)$ ./cros_run_unit_tests --packages ibus
# or
#   (chroot)$ env FEATURES="test" emerge-$BOARD -a ibus

EAPI="2"
inherit eutils flag-o-matic toolchain-funcs multilib python libtool

DESCRIPTION="Intelligent Input Bus for Linux / Unix OS"
HOMEPAGE="http://code.google.com/p/ibus/"

SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="doc nls python"
#RESTRICT="mirror"

RDEPEND="python? ( >=dev-lang/python-2.5 )
	>=dev-libs/glib-2.26
	python? ( >=dev-python/pygobject-2.14 )
	nls? ( virtual/libintl )
	>=x11-libs/gtk+-2
	x11-libs/libX11"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.9 )
	dev-util/pkgconfig
	nls? ( >=sys-devel/gettext-0.16.1 )"
RDEPEND="${RDEPEND}
	python? ( >=dev-python/dbus-python-0.83 )
	python? ( dev-python/pygtk )
	python? ( dev-python/pyxdg )"

pkg_setup() {
	# An arch specific config directory is used on multilib systems
	has_multilib_profile && GTK2_CONFDIR="/etc/gtk-2.0/${CHOST}"
	GTK2_CONFDIR=${GTK2_CONFDIR:=/etc/gtk-2.0/}
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-0003-Add-api-to-ibus-for-retreiving-unused-config-values.patch
	epatch "${FILESDIR}"/${P}-0004-Remove-bus_input_context_register_properties-props_e.patch

	# TODO(yusukes): Remove this when ibus is upgraded to >= 20120315.
	epatch "${FILESDIR}"/${P}-fix-engine-destroy-cb-69902696928e6acb953ab30b1f70e462b5994272.patch
	# TODO(nona): Remove the patch when we fix crosbug.com/25335#c1
	epatch "${FILESDIR}"/${P}-do-not-send-cursor-location-to-chrome.patch
	# TODO(penghuang): Remove the patch when we fix ibus issue 1438.
	epatch "${FILESDIR}"/${P}-disable-ibus-daemon-tests.patch

	elibtoolize
}

src_configure() {
	# TODO(yusukes): Add -Werror back when IBus issue 1437 is fixed.
	# append-cflags -Wall -Werror
	append-cflags -Wall

	# TODO(petkov): Ideally, configure should support --disable-isocodes but
	# it seems that the current version doesn't, so use the environment
	# variables instead to remove the dependence on iso-codes.
	econf \
		--enable-surrounding-text \
		--disable-gtk2 \
		--disable-gtk3 \
		--disable-dconf \
		--disable-gconf \
		--enable-memconf \
		--disable-xim \
		--disable-key-snooper \
		--disable-vala \
		--enable-introspection=no \
		$(use_enable doc gtk-doc) \
		$(use_enable nls) \
		$(use_enable python) \
		CPPFLAGS='-DOS_CHROMEOS=1' \
		ISOCODES_CFLAGS=' ' ISOCODES_LIBS=' '
}

test_fail() {
	kill $IBUS_DAEMON_PID
	rm -rf "${T}"/.ibus-test-socket-*
	die
}

src_test() {
	# Start ibus-daemon background.
	export IBUS_ADDRESS_FILE="`mktemp -d ${T}/.ibus-test-socket-XXXXXXXXXX`/ibus-socket-file"
	./bus/ibus-daemon --replace --panel=disable &
	IBUS_DAEMON_PID=$!

	# Wait for the daemon to start.
	if [ ! -f ${IBUS_ADDRESS_FILE} ] ; then
	   sleep .5
	fi

	# Run tests.
	./src/tests/ibus-bus || test_fail

	# TODO(yusukes): Fix 'ERROR:ibus-inputcontext.c:101:test_input_context'
	# and reenable the test.
	# ./src/tests/ibus-inputcontext || test_fail

	./src/tests/ibus-inputcontext-create || test_fail
	./src/tests/ibus-configservice || test_fail
	./src/tests/ibus-factory || test_fail
	./src/tests/ibus-keynames || test_fail
	./src/tests/ibus-serializable || test_fail

	# Cleanup.
	kill $IBUS_DAEMON_PID
	rm -rf "${T}"/.ibus-test-socket-*
}

src_install() {
	emake DESTDIR="${D}" install || die
	if [ -f "${D}/usr/share/ibus/component/gtkpanel.xml" ] ; then
		rm "${D}/usr/share/ibus/component/gtkpanel.xml" || die
	fi

	# Remove unnecessary files
	rm -rf "${D}/usr/share/icons" || die
	rm "${D}/usr/share/applications/ibus.desktop" || die
        rm -rf "${D}/usr/lib/gtk-2.0/2.10.0/immodules/" || die

	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	if use python; then
		python_mod_optimize /usr/share/${PN}
	fi
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup /usr/share/${PN}
	fi
}
