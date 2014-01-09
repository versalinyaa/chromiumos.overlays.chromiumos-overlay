# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="175a1aac77e00370dcb77406d5ac3ab70b269ba6"
CROS_WORKON_TREE="445dbb3fc76c9468ccea0d2989c9a3267a29d609"
CROS_WORKON_PROJECT="chromiumos/platform/suggest"
CROS_WORKON_USE_VCSID=1
CROS_WORKON_OUTOFTREE_BUILD=1

inherit multilib cros-debug cros-workon

DESCRIPTION="virtual keyboard suggestions library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE=""

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	cros-workon_src_install
	emake DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" install
}