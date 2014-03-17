# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Virtual package installing the boot-complete boot marker that
represents the system being operationnal and ready to use.
Boards should override it to define their own boot-complete."
HOMEPAGE="http://src.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_embedded"

RDEPEND="
	|| (
		!cros_embedded? ( chromeos-base/bootcomplete-login )
		chromeos-base/bootcomplete-embedded
	)
"

DEPEND="${RDEPEND}"
