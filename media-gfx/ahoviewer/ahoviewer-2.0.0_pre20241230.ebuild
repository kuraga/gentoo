# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson xdg

MY_COMMIT="821576a249ae0258a2b69332770ca84a5310b62b"

DESCRIPTION="A GTK image viewer, manga reader, and booru browser"
HOMEPAGE="https://github.com/ahodesuka/ahoviewer"
SRC_URI="https://github.com/ahodesuka/ahoviewer/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="keyring gnutls +gstreamer plugins +rar +ssl +zip"

COMMON_DEPEND="dev-cpp/atkmm:0
	dev-cpp/glibmm:2
	dev-cpp/gtkmm:3.0
	dev-cpp/pangomm:1.4
	dev-libs/glib:2
	dev-libs/libconfig:=[cxx]
	dev-libs/libsigc++:2
	dev-libs/libxml2:2
	>=media-libs/libnsgif-1.0.0:=
	media-plugins/gst-plugins-gtk
	net-misc/curl
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	keyring? ( app-crypt/libsecret )
	gstreamer? (
		media-libs/gst-plugins-bad:1.0
		media-libs/gstreamer:1.0
	)
	plugins? (
		dev-libs/gobject-introspection
		dev-libs/libpeas:0
	)
	rar? ( app-arch/unrar:= )
	ssl? (
		gnutls? (
			dev-libs/libgcrypt:=
			net-libs/gnutls:=
			net-misc/curl[curl_ssl_gnutls]
		)
		!gnutls? (
			dev-libs/openssl:=
			net-misc/curl[curl_ssl_openssl]
		)
	)
	zip? ( dev-libs/libzip:= )
"
DEPEND="${COMMON_DEPEND}
	x11-base/xorg-proto"
RDEPEND="${COMMON_DEPEND}
	gstreamer? (
		media-libs/gst-plugins-base:1.0[X]
		media-libs/gst-plugins-good:1.0
		|| (
			media-plugins/gst-plugins-vpx
			media-plugins/gst-plugins-libav
		)
	)"

# In future (-beta), pull https://github.com/ahodesuka/ahoviewer-plugins
# directly via SRC_URI="plugins? ( )", or add as a separate package. It
# depends on how the plugins are handled.
#PDEPEND="plugins? ( x11-misc/ahoviewer-plugins )"

S="${WORKDIR}/ahoviewer-${MY_COMMIT}"

src_configure() {
	local emesonargs=(
		$(meson_feature keyring libsecret)
		$(meson_feature gstreamer)
		$(meson_feature plugins libpeas)
		$(meson_feature rar libunrar)
		$(meson_feature zip libzip)
	)

	meson_src_configure
}
