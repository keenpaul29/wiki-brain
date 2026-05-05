---
title: Create a tunnel (dashboard)
type: source
created: 2026-05-02
source: https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/get-started/create-remote-tunnel/
tags:
  - source
  - cloudflare
  - networking
  - zero-trust
---

# Create a tunnel (dashboard)

## Summary

This source documents how to create a remotely managed Cloudflare Tunnel using the Cloudflare One dashboard. A tunnel connects local services or private network ranges to Cloudflare through the `cloudflared` connector, avoiding direct inbound exposure through port forwarding or public IPs.

## Key Ideas

- Tunnels are created from Zero Trust > Networks > Connectors > Cloudflare Tunnels, then completed by installing and running `cloudflared`.
- Published applications map a hostname and service type to an origin URL such as `localhost:8000`.
- Private networks are connected by adding an IP address or CIDR range under the CIDR tab.
- Public hostname exposure can be paired with a Cloudflare Access application to allow or block specific users.
- Tunnel status should be checked after setup; `Healthy` indicates the connector is active, while `Inactive`, `Down`, or `Degraded` require troubleshooting.

## Links

- Connects to [[concepts/infrastructure-primitives|Infrastructure Primitives]] (tunnels as networking/connectivity primitives)
- Connects to [[concepts/reliability-and-operations|Reliability and Operations]] (Zero Trust access control and connector health)
