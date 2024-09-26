#cloud-config
vyos_config_commands:
    - set system host-name 'VyOS-01'
    - set system login banner pre-login 'Welcome to the VyOS on Azure'
    - set interfaces ethernet eth0 description 'OUTSIDE'
    - set interfaces ethernet eth1 description 'INSIDE'
    - set system name-server '${dns_1}'
    - set system name-server '${dns_2}'
    - set service dns forwarding name-server '${dns_1}'
    - set service dns forwarding listen-address '${vyos_01_priv_nic_ip}'
    - set service dns forwarding allow-from '${vnet_01_priv_subnet_prefix}'
    - set service dns forwarding no-serve-rfc1918
    - set nat source rule 10 outbound-interface name 'eth0'
    - set nat source rule 10 source address '${vnet_01_priv_subnet_prefix}'
    - set nat source rule 10 translation address 'masquerade'
    - set vpn ipsec interface 'eth0'
    - set vpn ipsec esp-group AZURE lifetime '3600'
    - set vpn ipsec esp-group AZURE mode 'tunnel'
    - set vpn ipsec esp-group AZURE pfs 'dh-group2'
    - set vpn ipsec esp-group AZURE proposal 1 encryption 'aes256'
    - set vpn ipsec esp-group AZURE proposal 1 hash 'sha1'
    - set vpn ipsec ike-group AZURE dead-peer-detection action 'restart'
    - set vpn ipsec ike-group AZURE dead-peer-detection interval '15'
    - set vpn ipsec ike-group AZURE dead-peer-detection timeout '30'
    - set vpn ipsec ike-group AZURE ikev2-reauth
    - set vpn ipsec ike-group AZURE key-exchange 'ikev2'
    - set vpn ipsec ike-group AZURE lifetime '28800'
    - set vpn ipsec ike-group AZURE proposal 1 dh-group '2'
    - set vpn ipsec ike-group AZURE proposal 1 encryption 'aes256'
    - set vpn ipsec ike-group AZURE proposal 1 hash 'sha1'
    - set vpn ipsec ike-group AZURE close-action start
    - set vpn ipsec option disable-route-autoinstall
    - set interfaces vti vti1 address '10.1.100.11/32'
    - set interfaces vti vti1 description 'Tunnel VyOS 02'
    - set interfaces vti vti1 ip adjust-mss '1350'
    - set protocols static route 10.2.100.11/32 interface vti1
    - set vpn ipsec authentication psk VyOS id '${public_ip_address_01}'
    - set vpn ipsec authentication psk VyOS id '${on_prem_public_ip_address}'
    - set vpn ipsec authentication psk VyOS secret 'ch00s3-4-s3cur3-psk'
    - set vpn ipsec site-to-site peer VyOS-02 authentication local-id '${public_ip_address_01}'
    - set vpn ipsec site-to-site peer VyOS-02 authentication mode 'pre-shared-secret'
    - set vpn ipsec site-to-site peer VyOS-02 authentication remote-id '${on_prem_public_ip_address}'
    - set vpn ipsec site-to-site peer VyOS-02 connection-type 'none'
    - set vpn ipsec site-to-site peer VyOS-02 description 'AZURE TUNNEL to VyOS on NET 02'
    - set vpn ipsec site-to-site peer VyOS-02 ike-group 'AZURE'
    - set vpn ipsec site-to-site peer VyOS-02 ikev2-reauth 'inherit'
    - set vpn ipsec site-to-site peer VyOS-02 local-address '${vyos_01_pub_nic_ip}'
    - set vpn ipsec site-to-site peer VyOS-02 remote-address '${on_prem_public_ip_address}'
    - set vpn ipsec site-to-site peer VyOS-02 vti bind 'vti1'
    - set vpn ipsec site-to-site peer VyOS-02 vti esp-group 'AZURE'
    - set protocols bgp system-as '${vnet_01_bgp_as_number}'
    - set protocols bgp address-family ipv4-unicast network ${vnet_01_priv_subnet_prefix}
    - set protocols bgp neighbor 10.2.100.11 remote-as '${on_prem_bgp_as_number}'
    - set protocols bgp neighbor 10.2.100.11 address-family ipv4-unicast soft-reconfiguration inbound
    - set protocols bgp neighbor 10.2.100.11 timers holdtime '30'
    - set protocols bgp neighbor 10.2.100.11 timers keepalive '10'
    - set protocols bgp neighbor 10.2.100.11 disable-connected-check
    - set firewall group network-group Local network '${vnet_01_priv_subnet_prefix}'
    - set firewall group port-group dns_ports port '53'
    - set firewall group port-group mail_ports port '110'
    - set firewall group port-group mail_ports port '25'
    - set firewall group port-group web_ports port '443'
    - set firewall group port-group web_ports port '8080'
    - set firewall group port-group web_ports port '80'
    - set firewall ipv4 forward filter default-action 'drop'
    - set firewall ipv4 forward filter rule 10 action 'accept'
    - set firewall ipv4 forward filter rule 10 state 'established'
    - set firewall ipv4 forward filter rule 10 state 'related'
    - set firewall ipv4 forward filter rule 11 action 'drop'
    - set firewall ipv4 forward filter rule 11 state 'invalid'
    - set firewall ipv4 forward filter rule 20 action 'accept'
    - set firewall ipv4 forward filter rule 20 description 'Allow ICMP'
    - set firewall ipv4 forward filter rule 20 icmp type-name 'echo-request'
    - set firewall ipv4 forward filter rule 20 inbound-interface name 'eth0'
    - set firewall ipv4 forward filter rule 20 protocol 'icmp'
    - set firewall ipv4 forward filter rule 20 state 'new'
    - set firewall ipv4 forward filter rule 30 action 'drop'
    - set firewall ipv4 forward filter rule 30 description 'Mitigate SSH brute-forcing'
    - set firewall ipv4 forward filter rule 30 destination port '22'
    - set firewall ipv4 forward filter rule 30 inbound-interface name 'eth0'
    - set firewall ipv4 forward filter rule 30 protocol 'tcp'
    - set firewall ipv4 forward filter rule 30 recent count '4'
    - set firewall ipv4 forward filter rule 30 recent time 'minute'
    - set firewall ipv4 forward filter rule 30 state 'new'
    - set firewall ipv4 forward filter rule 31 action 'accept'
    - set firewall ipv4 forward filter rule 31 description 'Allow SSH'
    - set firewall ipv4 forward filter rule 31 destination port '22'
    - set firewall ipv4 forward filter rule 31 inbound-interface name 'eth0'
    - set firewall ipv4 forward filter rule 31 protocol 'tcp'
    - set firewall ipv4 forward filter rule 31 state 'new'
    - set firewall ipv4 forward filter rule 120 action 'accept'
    - set firewall ipv4 forward filter rule 120 description 'LAN clients web requests to Web SRVs'
    - set firewall ipv4 forward filter rule 120 destination group port-group 'web_ports'
    - set firewall ipv4 forward filter rule 120 inbound-interface name 'eth1'
    - set firewall ipv4 forward filter rule 120 protocol 'tcp'
    - set firewall ipv4 forward filter rule 130 action 'accept'
    - set firewall ipv4 forward filter rule 130 description 'LAN clients ICMP'
    - set firewall ipv4 forward filter rule 130 icmp type-name 'echo-request'
    - set firewall ipv4 forward filter rule 130 inbound-interface name 'eth1'
    - set firewall ipv4 forward filter rule 130 state 'new'
    - set firewall ipv4 forward filter rule 140 action 'drop'
    - set firewall ipv4 forward filter rule 140 description 'Mitigate clients SSH brute-forcing'
    - set firewall ipv4 forward filter rule 140 destination port '22'
    - set firewall ipv4 forward filter rule 140 inbound-interface name 'eth1'
    - set firewall ipv4 forward filter rule 140 protocol 'tcp'
    - set firewall ipv4 forward filter rule 140 recent count '4'
    - set firewall ipv4 forward filter rule 140 recent time 'minute'
    - set firewall ipv4 forward filter rule 140 state 'new'
    - set firewall ipv4 forward filter rule 141 action 'accept'
    - set firewall ipv4 forward filter rule 141 description 'Allow clients SSH'
    - set firewall ipv4 forward filter rule 141 destination port '22'
    - set firewall ipv4 forward filter rule 141 inbound-interface name 'eth1'
    - set firewall ipv4 forward filter rule 141 protocol 'tcp'
    - set firewall ipv4 forward filter rule 141 state 'new'
    - set firewall ipv4 input filter default-action 'drop'
    - set firewall ipv4 input filter rule 10 action 'accept'
    - set firewall ipv4 input filter rule 10 description 'Allow established/related'
    - set firewall ipv4 input filter rule 10 state 'established'
    - set firewall ipv4 input filter rule 10 state 'related'
    - set firewall ipv4 input filter rule 11 action 'drop'
    - set firewall ipv4 input filter rule 11 state 'invalid'
    - set firewall ipv4 input filter rule 20 action 'accept'
    - set firewall ipv4 input filter rule 20 description 'WireGuard_IN'
    - set firewall ipv4 input filter rule 20 destination port '2224'
    - set firewall ipv4 input filter rule 20 inbound-interface name 'eth0'
    - set firewall ipv4 input filter rule 20 log
    - set firewall ipv4 input filter rule 20 protocol 'udp'
    - set firewall ipv4 input filter rule 30 action 'accept'
    - set firewall ipv4 input filter rule 30 description 'OpenVPN_IN'
    - set firewall ipv4 input filter rule 30 destination port '1194'
    - set firewall ipv4 input filter rule 30 inbound-interface name 'eth0'
    - set firewall ipv4 input filter rule 30 log
    - set firewall ipv4 input filter rule 30 protocol 'udp'
    - set firewall ipv4 input filter rule 40 action 'accept'
    - set firewall ipv4 input filter rule 40 description 'Allow ESP'
    - set firewall ipv4 input filter rule 40 inbound-interface name 'eth0'
    - set firewall ipv4 input filter rule 40 protocol 'esp'
    - set firewall ipv4 input filter rule 50 action 'accept'
    - set firewall ipv4 input filter rule 50 description 'Allow ISAKMP'
    - set firewall ipv4 input filter rule 50 destination port '500'
    - set firewall ipv4 input filter rule 50 inbound-interface name 'eth0'
    - set firewall ipv4 input filter rule 50 protocol 'udp'
    - set firewall ipv4 input filter rule 60 action 'accept'
    - set firewall ipv4 input filter rule 60 description 'IPSec NAT Traversal'
    - set firewall ipv4 input filter rule 60 destination port '4500'
    - set firewall ipv4 input filter rule 60 inbound-interface name 'eth0'
    - set firewall ipv4 input filter rule 60 protocol 'udp'
    - set firewall ipv4 input filter rule 70 action 'accept'
    - set firewall ipv4 input filter rule 70 description 'Allow L2TP'
    - set firewall ipv4 input filter rule 70 destination port '1701'
    - set firewall ipv4 input filter rule 70 inbound-interface name 'eth0'
    - set firewall ipv4 input filter rule 70 ipsec match-ipsec
    - set firewall ipv4 input filter rule 70 protocol 'udp'
    - set firewall ipv4 input filter rule 80 action 'accept'
    - set firewall ipv4 input filter rule 80 description 'Allow ICMP'
    - set firewall ipv4 input filter rule 80 icmp type-name 'echo-request'
    - set firewall ipv4 input filter rule 80 inbound-interface name 'eth0'
    - set firewall ipv4 input filter rule 80 protocol 'icmp'
    - set firewall ipv4 input filter rule 80 state 'new'
    - set firewall ipv4 input filter rule 90 action 'drop'
    - set firewall ipv4 input filter rule 90 description 'Mitigate SSH brute-forcing'
    - set firewall ipv4 input filter rule 90 destination port '22'
    - set firewall ipv4 input filter rule 90 inbound-interface name 'eth0'
    - set firewall ipv4 input filter rule 90 protocol 'tcp'
    - set firewall ipv4 input filter rule 90 recent count '4'
    - set firewall ipv4 input filter rule 90 recent time 'minute'
    - set firewall ipv4 input filter rule 90 state 'new'
    - set firewall ipv4 input filter rule 91 action 'accept'
    - set firewall ipv4 input filter rule 91 description 'Allow SSH'
    - set firewall ipv4 input filter rule 91 destination port '22'
    - set firewall ipv4 input filter rule 91 inbound-interface name 'eth0'
    - set firewall ipv4 input filter rule 91 protocol 'tcp'
    - set firewall ipv4 input filter rule 91 state 'new'
    - set firewall ipv4 input filter rule 140 action 'accept'
    - set firewall ipv4 input filter rule 140 description 'Allow ESP'
    - set firewall ipv4 input filter rule 140 inbound-interface name 'vti1'
    - set firewall ipv4 input filter rule 140 protocol 'esp'
    - set firewall ipv4 input filter rule 150 action 'accept'
    - set firewall ipv4 input filter rule 150 description 'Allow ISAKMP'
    - set firewall ipv4 input filter rule 150 destination port '500'
    - set firewall ipv4 input filter rule 150 inbound-interface name 'vti1'
    - set firewall ipv4 input filter rule 150 protocol 'udp'
    - set firewall ipv4 input filter rule 160 action 'accept'
    - set firewall ipv4 input filter rule 160 description 'IPSec NAT Traversal'
    - set firewall ipv4 input filter rule 160 destination port '4500'
    - set firewall ipv4 input filter rule 160 inbound-interface name 'vti1'
    - set firewall ipv4 input filter rule 160 protocol 'udp'
    - set firewall ipv4 input filter rule 170 action 'accept'
    - set firewall ipv4 input filter rule 170 description 'Allow L2TP'
    - set firewall ipv4 input filter rule 170 destination port '1701'
    - set firewall ipv4 input filter rule 170 inbound-interface name 'vti1'
    - set firewall ipv4 input filter rule 170 ipsec match-ipsec
    - set firewall ipv4 input filter rule 170 protocol 'udp'
    - set firewall ipv4 input filter rule 180 action 'accept'
    - set firewall ipv4 input filter rule 180 description 'Allow ICMP'
    - set firewall ipv4 input filter rule 180 icmp type-name 'echo-request'
    - set firewall ipv4 input filter rule 180 inbound-interface name 'vti1'
    - set firewall ipv4 input filter rule 180 protocol 'icmp'
    - set firewall ipv4 input filter rule 180 state 'new'
    - set firewall ipv4 input filter rule 190 action 'accept'
    - set firewall ipv4 input filter rule 190 description 'Allow BGP'
    - set firewall ipv4 input filter rule 190 destination port '179'
    - set firewall ipv4 input filter rule 190 inbound-interface name 'vti1'
    - set firewall ipv4 input filter rule 190 protocol 'tcp'
