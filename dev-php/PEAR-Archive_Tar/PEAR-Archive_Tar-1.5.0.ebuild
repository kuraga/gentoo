# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN/PEAR-/}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Tar file management class"
HOMEPAGE="https://pear.php.net/package/Archive_Tar"
SRC_URI="https://pear.php.net/get/${MY_P}.tgz"
S="${WORKDIR}/${MY_P}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 arm ~hppa ppc64 ~s390 sparc x86"

# bzip2 and zlib are needed for compressed tarballs, and there's one
# call to preg_match to test paths against a pattern of files and
# directories that will be ignored.
RDEPEND="dev-lang/php:*[bzip2,pcre(+),zlib]"
PDEPEND="dev-php/PEAR-PEAR"

src_install() {
	insinto /usr/share/php
	doins -r Archive

	dodoc docs/*

	insinto /usr/share/php/.packagexml
	newins "${WORKDIR}/package.xml" "${MY_P}.xml"
}

pkg_postinst() {
	# It is not critical to complete so only warn on failure
	if [[ -f "${EROOT}/usr/share/php/.packagexml/${MY_P}.xml" && \
		-x "${EROOT}/usr/bin/peardev" ]] ; then
		"${EROOT}/usr/bin/peardev" install -nrO --force \
			"${EROOT}/usr/share/php/.packagexml/${MY_P}.xml" 2> /dev/null \
			|| ewarn "Failed to insert package into local PEAR database"
	fi
}

pkg_postrm() {
	if [[ -x "${EROOT}/usr/bin/peardev" ]]; then
		"${EROOT}/usr/bin/peardev" uninstall -nrO "pear.php.net/${MY_PN}"
	fi
}
