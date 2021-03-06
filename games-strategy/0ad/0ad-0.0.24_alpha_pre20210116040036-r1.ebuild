# Copyright 2014-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

WX_GTK_VER="3.0-gtk3"
inherit desktop toolchain-funcs wxwidgets xdg

if [[ ${PV} == 9999 ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/0ad/0ad"
	ZEROAD_GIT_REVISION=""
elif [[ ${PV} == *_pre* ]]; then
	ZEROAD_GIT_REVISION="c7d07d3979f969b969211a5e5748fa775f6768a7"
else
	MY_P="0ad-${PV/_/-}"
fi

DESCRIPTION="A free, real-time strategy game"
HOMEPAGE="https://play0ad.com/"
if [[ ${PV} == 9999 ]]; then
	SRC_URI=""
elif [[ ${PV} == *_pre* ]]; then
	SRC_URI="https://github.com/0ad/0ad/archive/${ZEROAD_GIT_REVISION}.tar.gz -> ${P}.tar.gz"
else
	SRC_URI="http://releases.wildfiregames.com/${MY_P}-unix-build.tar.xz"
fi

LICENSE="CC-BY-SA-3.0 GPL-2 LGPL-2.1 MIT ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="editor +lobby nvtt pch test"
RESTRICT="test"

BDEPEND="virtual/pkgconfig
	test? ( dev-lang/perl )"
DEPEND="
	dev-libs/boost:=
	dev-libs/icu:=
	dev-libs/libfmt:0=
	dev-libs/libsodium
	dev-libs/libxml2
	media-libs/libpng:0
	media-libs/libsdl2[X,opengl,video]
	media-libs/libvorbis
	media-libs/openal
	net-libs/enet:1.3
	net-libs/miniupnpc:=
	net-misc/curl
	sys-libs/zlib
	virtual/opengl
	x11-libs/libX11
	editor? ( x11-libs/wxGTK:${WX_GTK_VER}[X,opengl] )
	lobby? ( >=net-libs/gloox-1.0.20 )
	nvtt? ( >=media-gfx/nvidia-texture-tools-2.1.0 )"

RDEPEND="${DEPEND}"
PDEPEND="~games-strategy/0ad-data-${PV}"

if [[ ${PV} == 9999 ]]; then
	S="${WORKDIR}/${P}"
elif [[ ${PV} == *_pre* ]]; then
	S="${WORKDIR}/${PN}-${ZEROAD_GIT_REVISION}"
else
	S="${WORKDIR}/${MY_P}"
fi

PATCHES=(
	"${FILESDIR}/${PN}-0.0.24_alpha_pre20210116040036-build.patch"
)

pkg_setup() {
	use editor && setup-wxwidgets
}

src_prepare() {
	default

	sed -i -e "/--build/d" libraries/source/spidermonkey/build.sh || die
}

src_configure() {
	local myconf=(
		--minimal-flags
		$(usex nvtt "" "--without-nvtt")
		$(usex pch "" "--without-pch")
		$(usex test "" "--without-tests")
		$(usex editor "--atlas" "")
		$(usex lobby "" "--without-lobby")
		--bindir="/usr/bin"
		--libdir="/usr/$(get_libdir)"/${PN}
		--datadir="/usr/share/${PN}"
	)

	tc-export CC CXX

	# stock premake5 does not work, use the shipped one
	emake -C "${S}"/build/premake/premake5/build/gmake2.unix

	# regenerate scripts.c so our patch applies
	cd "${S}"/build/premake/premake5 || die
	"${S}"/build/premake/premake5/bin/release/premake5 embed || die

	# rebuild premake again... this is the most stupid build system
	emake -C "${S}"/build/premake/premake5/build/gmake2.unix clean
	emake -C "${S}"/build/premake/premake5/build/gmake2.unix

	# run premake to create build scripts
	cd "${S}"/build/premake || die
	"${S}"/build/premake/premake5/bin/release/premake5 \
		--file="premake5.lua" \
		--outpath="../workspaces/gcc/" \
		--os=linux \
		"${myconf[@]}" \
		gmake2 || die "Premake failed"
}

src_compile() {
	tc-export AR

	# build 3rd party fcollada
	einfo "Building bundled fcollada"
	emake -C libraries/source/fcollada/src

	# build bundled nvtt
	# nvtt is abandoned upstream and 0ad have forked it
	# and added fixes. Use their copy.
	# bug #768930
	if use nvtt ; then
		cd libraries/source/nvtt || die
		elog "Building bundled nvtt (bug #768930)"
		./build.sh || die "Failed to build bundled nvtt"
		cd "${S}" || die
	fi

	# build bundled spidermonkey
	# We genuinely can't use the system SpiderMonkey right now.
	# Breakages occur even on minor bumps in upstream SM,
	# e.g. bug #768840.
	cd libraries/source/spidermonkey || die
	elog "Building bundled SpiderMonkey (bug #768840)"
	XARGS="${EPREFIX}/usr/bin/xargs" ./build.sh || die "Failed to build bundled SpiderMonkey"
	cd "${S}" || die

	# build 0ad
	elog "Building 0ad"
	emake -C build/workspaces/gcc verbose=1
}

src_test() {
	cd binaries/system || die
	./test -libdir "${S}/binaries/system" || die "test phase failed"
}

src_install() {
	newbin binaries/system/pyrogenesis 0ad
	use editor && newbin binaries/system/ActorEditor 0ad-ActorEditor

	insinto /usr/share/${PN}
	doins -r binaries/data/l10n

	exeinto /usr/$(get_libdir)/${PN}
	doexe binaries/system/libCollada.so
	use editor && doexe binaries/system/libAtlasUI.so

	dodoc binaries/system/readme.txt
	doicon -s 128 build/resources/${PN}.png
	make_desktop_entry ${PN}
}
