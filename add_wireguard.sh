#!/bin/bash

set -e

SRC="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# display_alert
source "${SRC}"/lib/general.sh
# grab_version
source "${SRC}"/lib/compilation.sh

WIREGUARD="yes"

add_wireguard()
{
	# WireGuard - fast, modern, secure VPN tunnel
	# WireGuard VPN for Linux 3.10 - 5.5
	if linux-version compare $version ge 3.10 && linux-version compare $version le 5.5 && [ "${WIREGUARD}" == yes ]; then

		# attach to specifics tag or branch
		local wirever="branch:master"

		display_alert "Adding" "WireGuard VPN for Linux 3.10 - 5.5 ${wirever} " "info"
		fetch_from_repo "https://git.zx2c4.com/wireguard-linux-compat" "wireguard" "${wirever}" "yes"

		cd ${kerneldir}
		rm -rf ${kerneldir}/net/wireguard
		cp -R ${SRC}/cache/sources/wireguard/${wirever#*:}/src/ ${kerneldir}/net/wireguard
		sed -i "/^obj-\\\$(CONFIG_NETFILTER).*+=/a obj-\$(CONFIG_WIREGUARD) += wireguard/" \
		${kerneldir}/net/Makefile
		sed -i "/^if INET\$/a source \"net/wireguard/Kconfig\"" \
		${kerneldir}/net/Kconfig
		# remove duplicates
		[[ $(cat ${kerneldir}/net/Makefile | grep wireguard | wc -l) -gt 1 ]] && \
		sed -i '0,/wireguard/{/wireguard/d;}' ${kerneldir}/net/Makefile
		[[ $(cat ${kerneldir}/net/Kconfig | grep wireguard | wc -l) -gt 1 ]] && \
		sed -i '0,/wireguard/{/wireguard/d;}' ${kerneldir}/net/Kconfig
		# headers workaround
		display_alert "Patching WireGuard" "Applying workaround for headers compilation" "info"
		sed -i '/mkdir -p "$destdir"/a mkdir -p "$destdir"/net/wireguard; \
		touch "$destdir"/net/wireguard/{Kconfig,Makefile} # workaround for Wireguard' \
		${kerneldir}/scripts/package/builddeb

	fi
}

kerneldir=$1
[[ -z $kerneldir ]] && exit_with_error "Usage: add_wireguard.sh path_to_kernel_sources"

main()
{
	cd "$kerneldir"

	if ! grep -qoE '^-rc[[:digit:]]+' <(grep "^EXTRAVERSION" Makefile | head -1 | awk '{print $(NF)}'); then
		sed -i 's/EXTRAVERSION = .*/EXTRAVERSION = /' Makefile
	fi

	local version=$(grab_version "$kerneldir")

	echo "Trying to patch kernel version=$version ..."

	add_wireguard
}

main