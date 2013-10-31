# Copyright 2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/profiles/base/profile.bashrc,v 1.3 2009/07/21 00:08:05 zmedico Exp $

# Set LANG=C globally because it speeds up build times, and we don't need
# localized messages inside of our builds.
export LANG=C

# Since unittests on the buildbots don't automatically get access to an
# X server, don't let local dev stations get access either.  If a test
# really needs an X server, they should launch their own with Xvfb.
unset DISPLAY

if ! declare -F elog >/dev/null ; then
	elog() {
		einfo "$@"
	}
fi

# Dumping ground for build-time helpers to utilize since SYSROOT/tmp/
# can be nuked at any time.
CROS_BUILD_BOARD_TREE="${SYSROOT}/build"
CROS_BUILD_BOARD_BIN="${CROS_BUILD_BOARD_TREE}/bin"

CROS_ADDONS_TREE="/usr/local/portage/chromiumos/chromeos"

# Are we merging for the board sysroot, or for the cros sdk, or for
# the target hardware?  Returns a string:
#  - cros_host (the sdk)
#  - board_sysroot
#  - target_image
# We can't rely on "use cros_host" as USE gets filtred based on IUSE,
# and not all packages have IUSE=cros_host.
cros_target() {
	if [[ ${CROS_SDK_HOST} == "cros-sdk-host" ]] ; then
		echo "cros_host"
	elif [[ ${ROOT%/} == ${SYSROOT%/} ]] ; then
		echo "board_sysroot"
	else
		echo "target_image"
	fi
}

# Load all additional bashrc files we have for this package.
cros_stack_bashrc() {
	local cfg cfgd

	# Old location.
	cfgd="${CROS_ADDONS_TREE}/config/env"
	for cfg in ${PN} ${PN}-${PV} ${PN}-${PV}-${PR} ; do
		cfg="${cfgd}/${CATEGORY}/${cfg}"
		[[ -f ${cfg} ]] && . "${cfg}"
	done

	# New location.
	cfgd="/mnt/host/source/src/third_party/chromiumos-overlay/${CATEGORY}/${PN}"
	export BASHRC_FILESDIR="${cfgd}/files"
	for cfg in ${PN} ${P} ${PF} ; do
		cfg="${cfgd}/${cfg}.bashrc"
		[[ -f ${cfg} ]] && . "${cfg}"
	done
}
cros_stack_bashrc

# The standard bashrc hooks do not stack.  So take care of that ourselves.
# Now people can declare:
#   cros_pre_pkg_preinst_foo() { ... }
# And we'll automatically execute that in the pre_pkg_preinst func.
#
# Note: profile.bashrc's should avoid hooking phases that differ across
# EAPI's (src_{prepare,configure,compile} for example).  These are fine
# in the per-package bashrc tree (since the specific EAPI is known).
cros_lookup_funcs() {
	declare -f | egrep "^$1 +\(\) +$" | awk '{print $1}'
}
cros_stack_hooks() {
	local phase=$1 func
	local header=true

	for func in $(cros_lookup_funcs "cros_${phase}_[-_[:alnum:]]+") ; do
		if ${header} ; then
			einfo "Running stacked hooks for ${phase}"
			header=false
		fi
		ebegin "   ${func#cros_${phase}_}"
		${func}
		eend $?
	done
}
cros_setup_hooks() {
	# Avoid executing multiple times in a single build.
	[[ ${cros_setup_hooks_run+set} == "set" ]] && return

	local phase
	for phase in {pre,post}_{src_{unpack,prepare,configure,compile,test,install},pkg_{{pre,post}{inst,rm},setup}} ; do
		eval "${phase}() { cros_stack_hooks ${phase} ; }"
	done
	export cros_setup_hooks_run="booya"
}
cros_setup_hooks

# Packages that use python will run a small python script to find the
# pythondir. Unfortunately, they query the host python to find out the
# paths for things, which means they inevitably guess wrong.  Export
# the cached values ourselves and since we know these are going through
# autoconf, we can leverage ${libdir} that econf sets up automatically.
cros_pre_src_unpack_python_multilib_setup() {
	# Avoid executing multiple times in a single build.
	[[ ${am_cv_python_version:+set} == "set" ]] && return

	local py=${PYTHON:-python}
	local py_ver=$(${py} -c 'import sys;sys.stdout.write(sys.version[:3])')

	export am_cv_python_version=${py_ver}
	export am_cv_python_pythondir="\${libdir}/python${py_ver}/site-packages"
	export am_cv_python_pyexecdir=${am_cv_python_pythondir}
}

# Since we're storing the wrappers in a board sysroot, make sure that
# is actually in our PATH.
cros_pre_pkg_setup_sysroot_build_bin_dir() {
	PATH+=":${CROS_BUILD_BOARD_BIN}"
}
