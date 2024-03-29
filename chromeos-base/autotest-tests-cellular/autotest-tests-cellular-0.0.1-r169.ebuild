# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="f11c971f67f255d8093e5cee05e5da0e6446d900"
CROS_WORKON_TREE="6e49517855c6f222b12957dbca46c2284ff226fa"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest

DESCRIPTION="Cellular autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.2
	chromeos-base/autotest-deps-cellular
	chromeos-base/shill-test-scripts
	dev-python/pygobject
	dev-python/pyusb
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_cellular_CdmaConfig
	+tests_cellular_DeferredRegistration
	+tests_cellular_Dummy
	+tests_cellular_ModemControl
	+tests_cellular_OutOfCreditsSubscriptionState
	+tests_cellular_ServiceName
	+tests_cellular_Signal
	+tests_cellular_Smoke
	+tests_cellular_ThroughputController
	+tests_cellular_Throughput
	+tests_cellular_ZeroSignal
	+tests_network_3GActivate
	+tests_network_3GAssociation
	+tests_network_3GDisableWhileConnecting
	+tests_network_3GDisableGobiWhileConnecting
	+tests_network_3GDisconnectFailure
	+tests_network_3GDormancyDance
	+tests_network_3GFailedConnect
	+tests_network_3GGobiPorts
	+tests_network_3GIdentifiers
	+tests_network_3GModemControl
	+tests_network_3GModemPresent
	+tests_network_3GNoGobi
	+tests_network_3GRecoverFromGobiDesync
	+tests_network_3GSafetyDance
	+tests_network_3GScanningProperty
	+tests_network_3GSmokeTest
	+tests_network_3GStressEnable
	+tests_network_BasicProfileProperties
	+tests_network_CDMAActivate
	+tests_network_ConnmanCromoCrash
	+tests_network_GobiUncleanDisconnect
	+tests_network_LockedSIM
	+tests_network_LTEActivate
	+tests_network_ModemManagerSMS
	+tests_network_ModemManagerSMSSignal
	+tests_network_SIMLocking
	+tests_network_SwitchCarrier
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_configure() {
	cros-workon_src_configure
}
