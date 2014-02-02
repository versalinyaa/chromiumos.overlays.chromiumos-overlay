# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=2
CROS_WORKON_COMMIT="fb2addad49c6e5ab5b0287e36c17a269f2933be6"
CROS_WORKON_TREE="842c6a782f6562b75fcf15a97568805e0484a8f5"
CROS_WORKON_PROJECT="chromiumos/platform/gobi-cromo-plugin"
CROS_WORKON_USE_VCSID="1"

inherit cros-debug cros-workon toolchain-funcs multilib

DESCRIPTION="Cromo plugin to control Qualcomm Gobi modems"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="install_tests internal"

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	dev-cpp/glog
	dev-libs/dbus-c++
	chromeos-base/platform2
	chromeos-base/gobi3k-sdk
	|| (
		!internal? ( chromeos-base/gobi3k-lib-bin )
		chromeos-base/gobi3k-lib
	)
	install_tests? ( dev-cpp/gmock dev-cpp/gtest )
"
DEPEND="${RDEPEND}
	dev-cpp/gmock
	dev-cpp/gtest
	virtual/modemmanager
"

cr_make() {
	emake \
		LIBDIR=/usr/$(get_libdir) \
		BASE_VER=${LIBCHROME_VERS} \
		$(use install_tests && echo INSTALL_TESTS=1) \
		"$@" || die
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CXX LD CC
	cros-debug-add-NDEBUG
	cr_make
}

mkqcqmirules() {
	rule="ACTION==\"add|change\", SUBSYSTEM==\"QCQMI\", KERNEL==\"qcqmi[0-9]*\""
	rule="$rule, OWNER=\"cromo\""
	rule="$rule, GROUP=\"cromo\""
	echo "$rule"
}

src_install() {
	cr_make DESTDIR="${D}" install
	# The qualcomm makefile for gobi-cromo-plugin seems to stick its own
	# rules into this directory, which I don't think is right - I believe
	# /lib/udev/rules.d belongs to udev and /etc/udev/rules.d is for distro
	# stuff. Ah well.
	mkqcqmirules > "${D}/lib/udev/rules.d/76-cromo-gobi-permissions.rules"
}