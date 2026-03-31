#!/bin/sh

. "$IPKG_INSTROOT/etc/nikki/scripts/include.sh"

apply() {
	cleanup

	nft add table inet dns_gateway
	nft add chain inet dns_gateway prerouting '{ type nat hook prerouting priority -110; policy accept; }'
	nft add chain inet dns_gateway output '{ type nat hook output priority -110; policy accept; }'

	nft add rule inet dns_gateway prerouting 'meta nfproto ipv4 udp dport 53 counter redirect to :5533 comment "DNS Gateway"'
	nft add rule inet dns_gateway prerouting 'meta nfproto ipv4 tcp dport 53 counter redirect to :5533 comment "DNS Gateway"'
	nft add rule inet dns_gateway prerouting 'meta nfproto ipv6 udp dport 53 counter redirect to :5533 comment "DNS Gateway"'
	nft add rule inet dns_gateway prerouting 'meta nfproto ipv6 tcp dport 53 counter redirect to :5533 comment "DNS Gateway"'

	nft add rule inet dns_gateway output 'socket cgroupv2 level 2 "services/mosdns" udp dport 53 counter return comment "DNS Gateway Bypass"'
	nft add rule inet dns_gateway output 'socket cgroupv2 level 2 "services/mosdns" tcp dport 53 counter return comment "DNS Gateway Bypass"'
	nft add rule inet dns_gateway output 'meta nfproto ipv4 udp dport 53 counter redirect to :5533 comment "DNS Gateway"'
	nft add rule inet dns_gateway output 'meta nfproto ipv4 tcp dport 53 counter redirect to :5533 comment "DNS Gateway"'
	nft add rule inet dns_gateway output 'meta nfproto ipv6 udp dport 53 counter redirect to :5533 comment "DNS Gateway"'
	nft add rule inet dns_gateway output 'meta nfproto ipv6 tcp dport 53 counter redirect to :5533 comment "DNS Gateway"'
}

cleanup() {
	nft delete table inet dns_gateway > /dev/null 2>&1
}

case "${1:-}" in
	apply)
		apply
		;;
	cleanup)
		cleanup
		;;
	*)
		echo "Usage: $0 {apply|cleanup}" >&2
		exit 1
		;;
esac

exit 0
