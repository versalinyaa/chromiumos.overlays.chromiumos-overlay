# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("9375916b89bbb2f946ad91939431bae08f456a76" "d6c9c81e5f9b089809ddb5d2fe5745ce8e0b70bc" "7c70cdfacc870168954aa708ec4e50f7eb2da653" "a2321b9ad36d6a8e4078012945205732a9a45300" "af697fc95e11a23646b951d1279f5928f936687c" "4d65f72009eef80201067b118b57866d8971bdb7" "431f36af850df147cc42d562a564aefb2dc467a8" "660ec86095c5388937f2e259df26e3c4d5badbca" "d2378eacf09ecf010b9453ffafe2dbf1c1552e11" "a964e790d0a2f9bfd66ca55fc0bb5e75b432bfcd" "3f0454697d9ef18cf6f73288b2baca893eb031e6" "d2294781f1df9189e1819b951986f97dbb5742be")
CROS_WORKON_TREE=("028e16acaa2cec914da57db93155813e06ead1d8" "fdbc773799eaeaca2799bddecbba60f0dd77ceb4" "1f570ce7d8733d273e97b9c746842f946087ad58" "b72f1ef14dfc7383dfe1e5ccfbbec7d523814811" "1dc1d380533d7b5f451ed786d7f8e3f4c0aa42c4" "bc068fe24b478b4ea23f059b375d7accebe1aa0d" "1c3a87fe5c167072ce4a126fc91dbfa7975aef48" "dcc8f82f4dcdbaa53c42c56ca665be3a20a924b5" "5e6d22ebf7dd5b0ae946ff417cf4034bd0da23b1" "bf765873e4e7a938473faa08c0fb193af1629157" "928d016458904c7ff3363df966cd9cd71db27717" "f67277e260443be0b7152e06ec09b33d6c3e4c01")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1

CROS_WORKON_LOCALNAME=(
	"common-mk"
	"chaps"
	"cromo"
	"cros-disks"
	"debugd"
	"libchromeos"
	"metrics"
	"mist"
	"shill"
	"system_api"
	"vpn-manager"
	"wimax_manager"
)
CROS_WORKON_PROJECT=("${CROS_WORKON_LOCALNAME[@]/#/chromiumos/platform/}")
CROS_WORKON_DESTDIR=("${CROS_WORKON_LOCALNAME[@]/#/${S}/}")

inherit cros-board cros-debug cros-workon eutils multilib udev

DESCRIPTION="Platform2 for Chromium OS: a GYP-based incremental build system"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="+cellular cros_host gdmwimax platform2 test +tpm +vpn"

LIBCHROME_VERS=( 180609 )

LIBCHROME_DEPEND=$(
	printf \
		'chromeos-base/libchrome:%s[cros-debug=] ' \
		${LIBCHROME_VERS[@]}
)

RDEPEND_chaps="app-crypt/trousers"

RDEPEND_cros_disks="
	app-arch/unrar
	sys-apps/eject
	sys-apps/util-linux
	sys-block/parted
	sys-fs/avfs
	sys-fs/exfat-utils
	sys-fs/fuse-exfat
	sys-fs/ntfs3g
	sys-fs/udev
"

RDEPEND_debugd="
	dev-libs/libpcre
	net-libs/libpcap
	sys-apps/memtester
	sys-apps/smartmontools
"

RDEPEND_cromo="cellular? ( dev-cpp/glog )"

RDEPEND_shill="
	chromeos-base/bootstat
	chromeos-base/chromeos-minijail
	!<chromeos-base/flimflam-0.0.1-r530
	cellular? ( >=chromeos-base/mobile-providers-0.0.1-r12 )
	dev-libs/libnl:3
	dev-libs/nss
	cellular? ( net-dialup/ppp )
	vpn? ( net-dialup/ppp )
	net-dns/c-ares
	net-libs/libmnl
	net-libs/libnetfilter_queue
	net-libs/libnfnetlink
	net-misc/dhcpcd
	vpn? ( net-misc/openvpn )
	net-wireless/wpa_supplicant[dbus]
"

RDEPEND_vpn_manager="
	net-dialup/xl2tpd
	net-misc/strongswan
"

DEPEND_chaps="dev-db/leveldb"

DEPEND_wimax_manager="gdmwimax? ( virtual/gdmwimax )"

RDEPEND="
	platform2? (
		!cros_host? ( $(for v in ${!RDEPEND_*}; do echo "${!v}"; done) )

		${LIBCHROME_DEPEND}
		chromeos-base/chromeos-minijail
		dev-cpp/gflags
		dev-libs/dbus-c++
		dev-libs/dbus-glib
		>=dev-libs/glib-2.30
		dev-libs/openssl
		dev-libs/protobuf
		sys-apps/dbus
		sys-apps/rootdev
	)
"

DEPEND="${RDEPEND}
	platform2? (
		!cros_host? (
			$(for v in ${!DEPEND_*}; do echo "${!v}"; done)
			virtual/modemmanager
		)

		chromeos-base/protofiles
		test? (
			app-shells/dash
			dev-cpp/gmock
			dev-cpp/gtest
		)
	)
"

#
# Platform2 common helper functions
#

platform2() {
	local platform2_py="${S}/common-mk/platform2.py"

	local action="$1"

	"${platform2_py}" \
		$(platform2_get_target_args) \
		--libdir="/usr/$(get_libdir)" \
		--use_flags="${USE}" \
		--action="${action}" \
		|| die
}

platform2_get_target_args() {
	if use cros_host; then
		echo "--host"
	else
		echo "--board=$(get_current_board_with_variant)"
	fi
}

platform2_test() {
	local platform2_test_py="${S}/common-mk/platform2_test.py"

	local action="$1"
	local bin="$2"
	local run_as_root="$3"
	local gtest_filter="$4"

	local run_as_root_flag=""
	if [[ "${run_as_root}" == "1" ]]; then
		run_as_root_flag="--run_as_root"
	fi

	"${platform2_test_py}" \
		--action="${action}" \
		--bin="${bin}" \
		$(platform2_get_target_args) \
		--gtest_filter="${gtest_filter}" \
		--use_flags="${USE}" \
		${run_as_root_flag} \
		|| die

}

platform2_multiplex() {
	# Runs a step (ie platform2_{test,install}) for a given subdir.
	# Sets up two variables to be used by the step:
	#   OUT = the build output directory, contains binaries/libs
	#   SRC = the path to subdir we're running the step for

	local phase=$1
	local OUT="$(cros-workon_get_build_dir)/out/Default"
	local pkg
	for pkg in "${CROS_WORKON_LOCALNAME[@]}"; do
		local SRC="${S}/${pkg}"
		pushd "${SRC}" >/dev/null

		# Subshell so that funcs that change the env (like `into` and
		# `insinto`) don't affect the next pkg.
		( platform2_${phase}_${pkg} ) || die

		popd >/dev/null
	done
}

#
# These are all the repo-specific install functions.
# Keep them sorted by name!
#

platform2_install_chaps() {
	use cros_host && return 0

	dosbin "${OUT}"/chapsd
	dobin "${OUT}"/chaps_client
	dobin "${OUT}"/p11_replay
	dolib.so "${OUT}"/lib/libchaps.so

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.Chaps.conf

	# Install D-Bus service file.
	insinto /usr/share/dbus-1/services
	doins org.chromium.Chaps.service

	# Install upstart config file.
	insinto /etc/init
	doins chapsd.conf

	# Install headers for use by clients.
	insinto /usr/include/chaps
	doins token_manager_client.h
	doins token_manager_interface.h
	doins isolate.h
	doins chaps_proxy_mock.h
	doins chaps_interface.h
	doins chaps.h
	doins attributes.h

	insinto /usr/include/chaps/pkcs11
	doins pkcs11/*.h
}

platform2_install_common-mk() {
	return 0
}

platform2_install_cromo() {
	use cros_host && return 0
	use cellular || return 0

	dosbin "${OUT}"/cromo
	dolib.so "${OUT}"/obj/cromo/libcromo.a

	dobin mm-cromo-command

	insinto /etc/dbus-1/system.d
	doins org.chromium.ModemManager.conf

	insinto /usr/include/cromo
	doins modem_handler.h cromo_server.h plugin.h \
		hooktable.h carrier.h utilities.h modem.h \
		sms_message.h sms_cache.h

	dodir /usr/$(get_libdir)/cromo/plugins
}

platform2_install_cros-disks() {
	use cros_host && return 0

	exeinto /opt/google/cros-disks
	doexe "${OUT}"/disks

	# Install USB device IDs file.
	insinto /opt/google/cros-disks
	doins usb-device-info

	# Install seccomp policy file.
	newins avfsd-seccomp-${ARCH}.policy avfsd-seccomp.policy

	# Install upstart config file.
	insinto /etc/init
	doins cros-disks.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.CrosDisks.conf
}

platform2_install_debugd() {
	use cros_host && return 0

	into /
	dosbin "${OUT}"/debugd
	dodir /debugd

	exeinto /usr/libexec/debugd/helpers
	doexe "${OUT}"/{capture_packets,icmp,netif,modem_status,network_status}

	doexe src/helpers/{minijail-setuid-hack,send_at_command,systrace,capture_utility}.sh

	insinto /etc/dbus-1/system.d
	doins share/org.chromium.debugd.conf

	insinto /etc/init
	doins share/{debugd,trace_marker-test}.conf

	insinto /etc/perf_commands
	doins share/perf_commands/{arm,core,unknown}.txt
}

platform2_install_libchromeos() {
	./platform2_preinstall.sh "${OUT}" "${LIBCHROME_VERS}"

	local v
	insinto /usr/$(get_libdir)/pkgconfig
	for v in "${LIBCHROME_VERS[@]}"; do
		dolib.so "${OUT}"/lib/lib{chromeos,policy}*-${v}.so
		doins "${OUT}"/lib/libchromeos-${v}.pc
	done

	local dir dirs=( . dbus glib )
	for dir in "${dirs[@]}"; do
		insinto /usr/include/chromeos/${dir}
		doins chromeos/${dir}/*.h
	done

	insinto /usr/include/policy
	doins chromeos/policy/*.h
}

platform2_install_metrics() {
	dobin "${OUT}"/metrics_{client,daemon} syslog_parser.sh

	dolib.so "${OUT}/lib/libmetrics.so"

	insinto /usr/include/metrics
	doins c_metrics_library.h \
		metrics_library{,_mock}.h \
		timer{,_mock}.h
}

platform2_install_mist() {
	use cros_host && return 0
	use cellular || return 0;

	dobin "${OUT}"/mist

	insinto /usr/share/mist
	doins default.conf

	udev_dorules 51-mist.rules
}

platform2_install_shill() {
	use cros_host && return 0

	dobin "bin/ff_debug"

	if use cellular; then
		dobin "bin/mm_debug"
		dobin "bin/set_apn"
		dobin "bin/set_cellular_ppp"
	fi

	dobin "bin/set_arpgw"
	dobin "bin/shill_login_user"
	dobin "bin/shill_logout_user"
	dobin "bin/wpa_debug"
	dobin "${OUT}/shill"

	# Netfilter queue helper is run directly from init, so install in sbin.
	dosbin "${OUT}/netfilter-queue-helper"

	# Install Netfilter queue helper syscall filter policy file.
	insinto /usr/share/policy
	newins "shims/nfqueue-seccomp-${ARCH}.policy" nfqueue-seccomp.policy

	local shims_dir="/usr/$(get_libdir)/shill/shims"
	exeinto "${shims_dir}"
	doexe "${OUT}/net-diags-upload"
	doexe "${OUT}/nss-get-cert"
	doexe "${OUT}/crypto-util"

	if use vpn; then
		doexe "${OUT}/openvpn-script"
		newexe "${OUT}/lib/libshill-pppd-plugin.so" "shill-pppd-plugin.so"
	fi

	use cellular && doexe "${OUT}/set-apn-helper"

	sed s,@libdir@,"/usr/$(get_libdir)", "shims/wpa_supplicant.conf.in" \
		> "${D}/${shims_dir}/wpa_supplicant.conf"
	insinto /etc
	doins shims/nsswitch.conf
	dosym /var/run/shill/resolv.conf /etc/resolv.conf
	insinto /etc/dbus-1/system.d
	doins shims/org.chromium.flimflam.conf
	insinto /usr/share/shill
	use cellular && doins data/cellular_operator_info

	# Install introspection XML
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.flimflam.*.xml
}

platform2_install_system_api() {
	local dir dirs=( dbus switches )
	for dir in "${dirs[@]}"; do
		insinto /usr/include/chromeos/${dir}
		doins -r ${dir}/*
	done
}

platform2_install_vpn-manager() {
	use cros_host && return 0
	use vpn || return 0

	insinto /usr/include/chromeos/vpn-manager
	doins service_error.h
	dosbin "${OUT}"/l2tpipsec_vpn
	exeinto /usr/libexec/l2tpipsec_vpn
	doexe "bin/pluto_updown"
}

platform2_install_wimax_manager() {
	use cros_host && return 0

	# Install D-Bus introspection XML files.
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.WiMaxManager*.xml

	# Skip the rest of the files unless USE=gdmwimax is specified.
	use gdmwimax || return 0

	# Install daemon executable.
	dosbin "${OUT}"/wimax-manager

	# Install WiMAX Manager default config file.
	insinto /usr/share/wimax-manager
	doins default.conf

	# Install upstart config file.
	insinto /etc/init
	doins wimax_manager.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins dbus_bindings/org.chromium.WiMaxManager.conf
}

#
# These are all the repo-specific test functions.
# Keep them sorted by name!
#

platform2_test_chaps() {
	use cros_host && return 0

	local tests=(
		chaps_test
		chaps_service_test
		slot_manager_test
		session_test
		object_test
		object_policy_test
		object_pool_test
		object_store_test
		opencryptoki_importer_test
		isolate_login_client_test
	)

	local gtest_filter_qemu=""
	gtest_filter_qemu+="-*DeathTest*"
	gtest_filter_qemu+=":*ImportSample*"
	gtest_filter_qemu+=":TestSession.RSA*"
	gtest_filter_qemu+=":TestSession.KeyTypeMismatch"
	gtest_filter_qemu+=":TestSession.KeyFunctionPermission"
	gtest_filter_qemu+=":TestSession.BadKeySize"
	gtest_filter_qemu+=":TestSession.BadSignature.*"

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform2_test "run" "${OUT}/${test_bin}" "" "${gtest_filter_qemu}"
	done
}

platform2_test_common-mk() {
	return 0
}

platform2_test_cromo() {
	use cros_host && return 0
	use cellular || return 0

	local tests=(
		sms_message_unittest
		sms_cache_unittest
		utilities_unittest
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform2_test "run" "${OUT}/${test_bin}"
	done
}

platform2_test_cros-disks() {
	use cros_host && return 0

	local gtest_filter_qemu_common=""
	gtest_filter_qemu_common+="DiskManagerTest.*"
	gtest_filter_qemu_common+=":ExternalMounterTest.*"
	gtest_filter_qemu_common+=":UdevDeviceTest.*"
	gtest_filter_qemu_common+=":MountInfoTest.RetrieveFromCurrentProcess"
	gtest_filter_qemu_common+=":GlibProcessTest.*"

	local gtest_filter_user_tests="-*.RunAsRoot*:"
	use arm && gtest_filter_user_tests+="${gtest_filter_qemu_common}"

	local gtest_filter_root_tests="*.RunAsRoot*-"
	use arm && gtest_filter_root_tests+="${gtest_filter_qemu_common}"

	platform2_test "run" "${OUT}/disks_testrunner" "1" \
		"${gtest_filter_root_tests}"
	platform2_test "run" "${OUT}/disks_testrunner" "0" \
		"${gtest_filter_user_tests}"
}

platform2_test_debugd() {
	use cros_host && return 0
	! use x86 && ! use amd64 && return 0

	pushd "${SRC}/src" >/dev/null
	platform2_test "run" "${OUT}/debugd_testrunner"
	./helpers/capture_utility_test.sh || die
	popd >/dev/null
}

platform2_test_libchromeos() {
	! use x86 && ! use amd64 && return 0

	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		platform2_test "run" "${OUT}/libchromeos-${v}_unittests"
		platform2_test "run" "${OUT}/libpolicy-${v}_unittests"
	done
}

platform2_test_metrics() {
	local tests=(
		metrics_library_test
		metrics_daemon_test
		counter_test
		timer_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform2_test "run" "${OUT}/${test_bin}"
	done
}

platform2_test_mist() {
	use cros_host && return 0
	use cellular || return 0;

	platform2_test "run" "${OUT}/mist_testrunner"
}

platform2_test_shill() {
	use cros_host && return 0
	! use x86 && ! use amd64 && return 0

	platform2_test "run" "${OUT}/shill_unittest"
}

platform2_test_system_api() {
	return 0
}

platform2_test_vpn-manager() {
	use cros_host && return 0
	use vpn || return 0
	! use x86 && ! use amd64 && return 0

	local tests=(
		daemon_test
		ipsec_manager_test
		l2tp_manager_test
		service_manager_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform2_test "run" "${OUT}/${test_bin}"
	done
}

platform2_test_wimax_manager() {
	use cros_host && return 0
	use gdmwimax || return 0

	platform2_test "run" "${OUT}/wimax_manager_testrunner"
}

#
# These are the ebuild <-> Platform2 glue functions.
#

src_unpack() {
	# If we don't create the source directory when Platform2 is disabled
	# prepare complains. Once Platform2 is default, this isn't needed.
	mkdir -p "${S}"

	use platform2 && cros-workon_src_unpack
}

src_configure() {
	use platform2 && platform2 "configure"
}

src_compile() {
	use platform2 && platform2 "compile"
}

src_test() {
	use platform2 || return 0

	platform2_test "pre_test"
	platform2_multiplex test
	platform2_test "post_test"
}

src_install() {
	use platform2 && platform2_multiplex install
}