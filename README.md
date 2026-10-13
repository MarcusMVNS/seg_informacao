# Firewall Linux com Docker Compose

Projeto desenvolvido para a disciplina de Segurança da Informação do Bacharelado em Sistemas de Informação do Instituto Federal Goiano — Campus Ceres.

## Objetivo

Simular a infraestrutura de rede de uma pequena empresa, utilizando Docker Compose para implementar segmentação de redes LAN e DMZ, com um firewall Linux baseado em Netfilter/iptables.

## Arquitetura

O ambiente possui quatro containers:

| Container | Endereço IP | Função |
|---|---|---|
| seginf-cliente | 172.28.10.10 | Estação de trabalho |
| seginf-firewall | 172.28.10.254 / 172.28.20.254 | Gateway e firewall |
| seginf-web | 172.28.20.10 | Servidor Nginx |
| seginf-restrito | 172.28.20.20 | Serviço de acesso restrito |

As redes são:

- LAN: 172.28.10.0/24
- DMZ: 172.28.20.0/24

## Tecnologias

- Docker e Docker Compose
- Alpine Linux
- Netfilter/iptables
- Nginx
- Nmap e curl

## Execução

Pré-requisitos: Docker Desktop ou Docker Engine com Docker Compose, executando containers Linux.

Na pasta raiz do projeto, execute:

```bash
docker compose up -d --build
```

Verifique os containers:

```bash
docker compose ps
```

## Testes

**1. Verificar o roteamento pelo firewall**

```bash
docker exec seginf-cliente ip route get 172.28.20.10
```

**2. Testar acesso HTTP autorizado**

```bash
docker exec seginf-cliente curl http://172.28.20.10
```

Resultado esperado: página HTML do servidor Nginx.

**3. Testar bloqueio do serviço restrito**

```bash
docker exec seginf-cliente nmap -Pn -p 5432 172.28.20.20
```

Resultado esperado: porta `filtered`.

**4. Testar portas não autorizadas**

```bash
docker exec seginf-cliente nmap -Pn -p 80,81,443 172.28.20.10
```

Resultado esperado: porta 80 aberta; portas 81 e 443 filtradas.

**5. Consultar regras do firewall**

```bash
docker exec seginf-firewall iptables -L FORWARD -n -v
```

## Encerramento

Para remover os containers e as redes criadas pelo Compose:

```bash
docker compose down
```

## Segurança

A política padrão da cadeia FORWARD é DROP. O tráfego HTTP do cliente para o Nginx é autorizado explicitamente, enquanto o serviço restrito e as demais conexões não permitidas são bloqueados.

O projeto é uma simulação acadêmica. A validação apresentada demonstra a filtragem dos fluxos testados, sem representar uma auditoria completa do isolamento do host Docker.
