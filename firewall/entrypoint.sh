
#!/bin/sh
set -eu

echo "Inicializando Firewall Linux..."

# Limpar regras anteriores
iptables -F
iptables -t nat -F

# Politica padrao: bloquear encaminhamentos
iptables -P FORWARD DROP

# Descobrir interfaces pelas redes configuradas
LAN_IF=$(ip -o -4 addr show | awk '$4 ~ /^172\.28\.10\./ {print $2; exit}')
DMZ_IF=$(ip -o -4 addr show | awk '$4 ~ /^172\.28\.20\./ {print $2; exit}')

if [ -z "$LAN_IF" ] || [ -z "$DMZ_IF" ]; then
    echo "ERRO: Interfaces LAN ou DMZ nao encontradas."
    exit 1
fi

# Permitir respostas de conexoes estabelecidas
iptables -A FORWARD -m conntrack \
    --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permitir acesso HTTP do cliente ao servidor Web
iptables -A FORWARD \
    -i "$LAN_IF" -o "$DMZ_IF" \
    -s 172.28.10.0/24 \
    -d 172.28.20.10 \
    -p tcp --dport 80 \
    -m conntrack --ctstate NEW \
    -j ACCEPT

# Bloquear explicitamente acesso ao servico restrito
iptables -A FORWARD \
    -i "$LAN_IF" -o "$DMZ_IF" \
    -s 172.28.10.0/24 \
    -d 172.28.20.20 \
    -p tcp --dport 5432 \
    -j DROP

# Aplicar NAT para o retorno das conexoes
iptables -t nat -A POSTROUTING \
    -s 172.28.10.0/24 \
    -d 172.28.20.0/24 \
    -o "$DMZ_IF" \
    -j MASQUERADE

echo "Firewall configurado com sucesso!"
iptables -L FORWARD -n -v

# Manter o container funcionando
exec sleep infinity
