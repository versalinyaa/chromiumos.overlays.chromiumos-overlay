# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="74ffd1cf0a031011801b3dab1a3f1c33fd9d46dd"
CROS_WORKON_TREE="f5ff78793a4842e48a04aee8c306f50eaae7095c"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"

inherit cros-workon cros-perf

KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
RDEPEND="!dev-util/perf"
DEPEND="${RDEPEND}
	${DEPEND}"

