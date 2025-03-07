# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake eapi9-ver xdg

MY_P="tea-qt-${PV}"

DESCRIPTION="Small, lightweight Qt text editor"
HOMEPAGE="https://tea.ourproject.org/"
SRC_URI="https://github.com/psemiletov/tea-qt/archive/${PV}.tar.gz -> ${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64 ~riscv x86"
IUSE="aspell djvu pdf"

RESTRICT="test" # no tests

DEPEND="
	app-text/hunspell:=
	dev-qt/qt5compat:6
	dev-qt/qtbase:6[gui,widgets]
	sys-libs/zlib
	aspell? ( app-text/aspell )
	djvu? ( app-text/djvu )
	pdf? ( app-text/poppler:=[qt6(+)] )
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

DOCS=( AUTHORS ChangeLog NEWS NEWS-RU TODO )

PATCHES=( "${FILESDIR}/tea-62.1.1-fix-desktop.patch" )

src_prepare() {
	cmake_src_prepare

	# Replace AUR link with p.g.o link
	sed -i \
		-e 's,AUR: aur.archlinux.org/packages/tea-qt-git,Gentoo: https://packages.gentoo.org/packages/app-editors/tea,' \
		tea.cpp translations/{de,es,fr,pl,ru}.ts || die

	# Rename tea to tea-qt to avoid file conflict with dev-util/tea
	# bug #917587
	# https://github.com/psemiletov/tea-qt/issues/50
	sed -i -e '/set_target_properties(tea PROPERTIES$/ a\
		OUTPUT_NAME \"tea-qt\"' \
		CMakeLists.txt || die
	sed -i -e '/Exec/ { s/tea/tea-qt/ }' desktop/tea.desktop || die
}

src_configure() {
	local mycmakeargs=(
		-DUSE_ASPELL=$(usex aspell)
		-DUSE_PDF=$(usex pdf)
		-DUSE_DJVU=$(usex djvu)
		-DUSE_PRINTER=OFF # appears to be setup wrong
	)

	cmake_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst

	if ver_replacing -eq 47.0.0; then
		elog "Executable 'tea' has been renamed to 'tea-qt'"
	fi
}
