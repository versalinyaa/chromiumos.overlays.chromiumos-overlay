# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/touch_noise_filter"
CROS_WORKON_USE_VCSID=1

inherit toolchain-funcs multilib cros-debug cros-workon

DESCRIPTION="Touch noise filter"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~*"
IUSE=""

LIBCHROME_VERS="271506"

RDEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]"
DEPEND="${RDEPEND}"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	export BASE_VER=${LIBCHROME_VERS}
	export LIBDIR="/usr/$(get_libdir)"

	emake clean  # TODO(adlr): remove when a better solution exists
	emake
}
