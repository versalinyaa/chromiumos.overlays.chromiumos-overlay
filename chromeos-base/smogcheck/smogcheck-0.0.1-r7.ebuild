# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="a3633b1f3ba298fc09e64baa64037b62c2918c31"
CROS_WORKON_TREE="fccc9cb7f14f908b962606c357c1f2e96062ca8d"
CROS_WORKON_PROJECT="chromiumos/platform/smogcheck"
inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="TPM SmogCheck library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"
KEYWORDS="amd64 arm x86"

RDEPEND=""
DEPEND="${RDEPEND}
	sys-kernel/linux-headers"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	tc-export CC
	cros-debug-add-NDEBUG

	emake clean
	emake
}

src_install() {
	emake DESTDIR="${D}" install
}