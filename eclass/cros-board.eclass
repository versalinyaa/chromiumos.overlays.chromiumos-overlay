# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for handling building of ChromiumOS packages
#
#
#  This class sets the BOARD environment variable.  It is intended to
#  be used by ebuild packages that need to have the board information
#  for various reasons -- for example, to differentiate various
#  hardware attributes at build time; see 'adhd' for an example of
#  this.
#
#  When set, the BOARD environment variable should conform to the
#  syntax used by the CROS utilities.
#
#  If an unknown board is encountered, this class deliberately fails
#  the build; this provides an easy method of identifying a change to
#  the build which might affect inheriting packages.
#
#  For example, the ADHD (Google A/V daemon) package relies on the
#  BOARD variable to determine which hardware should be monitored at
#  runtime.  If the BOARD variable is not set, the daemon will not
#  monitor any specific hardware; thus, when a new board is added, the
#  ADHD project must be updated.
#
[[ ${EAPI} != "4" ]] && die "Only EAPI=4 is supported"

BOARD_USE_PREFIX="board_use_"

# Obsolete boards' names are commented-out but retained in this list so
# they won't be accidentally recycled in the future.
ALL_BOARDS=(
	amd64-corei7
	#amd64-drm
	amd64-generic
	amd64-generic_embedded
	amd64-host
	anglar
	#app-shell-panther
	aries
	arm-generic
	arm64-generic
	bayleybay
	beaglebone
	beaglebone_servo
	beltino
	blackwall
	bobcat
	bolt
	butterfly
	bwtm2
	cardhu
	#chronos
	clapper
	cranky
	daisy
	#daisy-drm
	daisy_embedded
	daisy_snow
	daisy_skate
	daisy_spring
	daisy_winter
	dalmore
	duck
	#emeraldlake2
	enguarde
	expresso
	falco
	falco_gles
	falco_li
	fb1
	fox
	fox_baskingridge
	fox_wtm1
	fox_wtm2
	gizmo
	glimmer
	gnawty
	hsb
	ironhide
	#kiev
	kip
	klang
	laser
	lemmings
	lemmings_external
	leon
	link
	link_freon
	lumpy
	mappy
	marble
	mccloud
	minnowboard
	mipseb-o32-generic
	mipseb-n32-generic
	mipseb-n64-generic
	mipsel-o32-generic
	mipsel-n32-generic
	mipsel-n64-generic
	monroe
	moose
	nyan
	nyan_big
	nyan_blaze
	nyan_freon
	optimus
	panda
	panther
	panther_embedded
	parrot
	parrot_ivb
	parrot32
	parrot64
	peach
	peach_kirby
	peach_pi
	peach_pit
	peppy
	ppcbe-32-generic
	ppcbe-64-generic
	ppcle-32-generic
	ppcle-64-generic
	puppy
	quawks
	rambi
	raspberrypi
	#ricochet
	rizer
	rush
	rush_ryu
	samus
	slippy
	sonic
	squawks
	storm
	stout
	#stout32
	strago
	stumpy
	stumpy_moblab
	stumpy_pico
	swanky
	tails
	#tegra2
	#tegra2_aebl
	#tegra2_arthur
	#tegra2_asymptote
	#tegra2_dev-board
	#tegra2_dev-board-opengl
	#tegra2_kaen
	#tegra2_seaboard
	#tegra2_wario
	tegra3-generic
	tricky
	urara
	veyron
	#waluigi
	winky
	wolf
	wsb
	x32-generic
	x86-agz
	x86-alex
	x86-alex_he
	x86-alex_hubble
	x86-alex32
	x86-alex32_he
	x86-dogfood
	#x86-drm
	#x86-fruitloop
	x86-generic
	x86-generic_embedded
	x86-mario
	x86-mario64
	#x86-pineview
	#x86-wayland
	x86-zgb
	x86-zgb_he
	x86-zgb32
	x86-zgb32_he
	zako
)

# Add BOARD_USE_PREFIX to each board in ALL_BOARDS to create IUSE.
# Also add cros_host so that we can inherit this eclass in ebuilds
# that get emerged both in the cros-sdk and for target boards.
# See REQUIRED_USE below.
IUSE="${ALL_BOARDS[@]/#/${BOARD_USE_PREFIX}} cros_host"

# Require one, and only one, of the board_use flags to be set if this eclass
# is used.  This effectively makes any ebuild that inherits this eclass require
# a known valid board to be set.
REQUIRED_USE="^^ ( ${IUSE} )"

# Echo the current board, with variant.
get_current_board_with_variant()
{
	local b

	for b in "${ALL_BOARDS[@]}"; do
		if use ${BOARD_USE_PREFIX}${b}; then
			echo ${b}
			return
		fi
	done

	die "Unable to determine current board (with variant)."
}

# Echo the current board, without variant.
get_current_board_no_variant()
{
	get_current_board_with_variant | cut -d '_' -f 1
}
