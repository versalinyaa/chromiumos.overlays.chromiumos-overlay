# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT=("dd204133d024db01edf476239a1089f7ba195f1d" "8f7b7055a134d003920b4a67a951d23ad7b1f939")
CROS_WORKON_TREE=("46485bdf55708f9d798456c1d28558e76b74f534" "1770be64acbc16222625a5e435012144b5ebeb29")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/depthcharge"
	"chromiumos/platform/vboot_reference"
)

DESCRIPTION="coreboot's depthcharge payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="mocktpm fwconsole unified_depthcharge"

RDEPEND="
	sys-apps/coreboot-utils
	sys-boot/libpayload
	chromeos-base/vboot_reference
	"
DEPEND=${RDEPEND}

CROS_WORKON_LOCALNAME=("../platform/depthcharge" "../platform/vboot_reference")
VBOOT_REFERENCE_DESTDIR="${S}/vboot_reference"
CROS_WORKON_DESTDIR=("${S}" "${VBOOT_REFERENCE_DESTDIR}")

inherit cros-workon cros-board toolchain-funcs

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	local board=$(get_current_board_with_variant)
	if [[ ! -d "board/${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi

	tc-getCC

	# Firmware related binaries are compiled with a 32-bit toolchain
	# on 64-bit platforms
	if use amd64 ; then
		export CROSS_COMPILE="i686-pc-linux-gnu-"
		export CC="${CROSS_COMPILE}gcc"
	else
		export CROSS_COMPILE=${CHOST}-
	fi

	if use mocktpm ; then
		echo "CONFIG_MOCK_TPM=y" >> "board/${board}/defconfig"
	fi
	if use fwconsole ; then
		echo "CONFIG_CLI=y" >> "board/${board}/defconfig"
		echo "CONFIG_SYS_PROMPT=\"${board}: \"" >>  \
		  "board/${board}/defconfig"
	fi

	emake distclean
	emake defconfig \
		LIBPAYLOAD_DIR="${ROOT}/firmware/libpayload/" \
		BOARD="${board}" \
		|| die "depthcharge make defconfig failed"
	emake \
		LIBPAYLOAD_DIR="${ROOT}/firmware/libpayload/" \
		VB_SOURCE="${VBOOT_REFERENCE_DESTDIR}" \
		|| die "depthcharge build failed"
}

src_install() {
	local build_root="build"
	local destdir="/firmware/depthcharge"
	local dtsdir="/firmware/dts"
	local board=$(get_current_board_with_variant)
	if [[ ! -d "board/${board}" ]]; then
		board=$(get_current_board_no_variant)
	fi
	local files_to_copy=(netboot.{bin,elf{,.map}})
	if use unified_depthcharge ; then
		files_to_copy+=(depthcharge.elf{,.map})
	else
		files_to_copy+=(depthcharge.{ro,rw}.{bin,elf{,.map}})
	fi

	insinto "${dtsdir}"
	doins "board/${board}/fmap.dts"

	cd "${build_root}"
	insinto "${destdir}"
	doins "${files_to_copy[@]}"

	# Install the depthcharge.payload file into the firmware
	# directory for downstream use if it is produced.
	if [[ -r depthcharge.payload ]]; then
		doins {depthcharge,netboot}.payload
	fi
}