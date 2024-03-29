# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Install the update_engine policy for chromeos"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"

KEYWORDS="*"

RDEPEND="
	!<chromeos-base/update_engine-0.0.2
"
S=${WORKDIR}

src_install() {
	insinto /etc
	doins "${FILESDIR}"/update_manager.conf
}
