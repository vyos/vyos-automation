[Interface]
PrivateKey = ${wg_client_PrivKey}
Address = ${wg_client_IP}/24
DNS = ${wg_server_Private_IP}

[Peer]
PublicKey = ${wg_server_PublicKey}
PresharedKey = ${wg_client_PresharedKey}
Endpoint = ${wg_server_Public_IP}:${wg_server_port}
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 15
