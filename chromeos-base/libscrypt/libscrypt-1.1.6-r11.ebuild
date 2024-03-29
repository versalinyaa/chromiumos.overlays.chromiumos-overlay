# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b45c53f9418a6eff2c8ed98703a55f96029304b1"
CROS_WORKON_TREE="9ab3db8e143709362b25e0b8d9285a1dcdfe34a8"
CROS_WORKON_PROJECT="chromiumos/third_party/libscrypt"

inherit cros-workon autotools

DESCRIPTION="Scrypt key derivation library"
HOMEPAGE="http://www.tarsnap.com/scrypt.html"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang static-libs"
REQUIRED_USE="asan? ( clang )"

RDEPEND="dev-libs/openssl"
DEPEND="${RDEPEND}"

CROS_WORKON_LOCALNAME="../third_party/libscrypt"

src_prepare() {
	epatch function_visibility.patch
	epatch "${FILESDIR}"/function_visibility2.patch
	eautoreconf
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure \
		$(use_enable static-libs static)
}

src_install() {
	emake install DESTDIR="${D}"

	insinto /usr/include/scrypt
	doins src/lib/scryptenc/scryptenc.h
	doins src/lib/crypto/crypto_scrypt.h
}
