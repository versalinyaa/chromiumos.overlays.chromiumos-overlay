# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1cce6aa8854e58ecc2695e1c361008c61fa267fd"
CROS_WORKON_TREE="c446436e41d06cbc3aa6f3cdf84d1d105d3404bd"
CROS_WORKON_PROJECT="chromiumos/platform/p2p"

inherit autotools cros-debug cros-workon

DESCRIPTION="Chrome OS P2P"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/metrics
	dev-libs/glib
	net-dns/avahi"

DEPEND="test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
	${RDEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure $(use_enable test tests)
}

src_test() {
	# Needed for `cros_run_unit_tests`.
	cros-workon_src_test
}