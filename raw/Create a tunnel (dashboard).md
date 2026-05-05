---
title: "Create a tunnel (dashboard)"
source: "https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/get-started/create-remote-tunnel/"
author:
published: 2026-04-17
created: 2026-05-02
description: "Create a tunnel (dashboard) in Zero Trust networking."
tags:
  - "clippings"
---
Follow this step-by-step guide to create your first [remotely-managed tunnel](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/get-started/tunnel-useful-terms/#remotely-managed-tunnel) using Cloudflare One.

## 1\. Create a tunnel

<iframe src="https://customer-1mwganm1ma0xgnmj.cloudflarestream.com/4b75ad2aa58700602e94b148827687a2/iframe?preload=true&amp;letterboxColor=transparent&amp;poster=https%3A%2F%2Fpub-d9bf66e086fb4b639107aa52105b49dd.r2.dev%2Ftunnel%25204_%2520set%2520up%2520tunnel.png" allow="accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture;" allowfullscreen="true" title="How to set up Cloudflare Tunnel"></iframe>
1. Log in to the [Cloudflare dashboard ↗](https://dash.cloudflare.com/) and go to **Zero Trust** > **Networks** > **Connectors** > **Cloudflare Tunnels**.
2. Select **Create a tunnel**.
3. Choose **Cloudflared** for the connector type and select **Next**.
4. Enter a name for your tunnel. We suggest choosing a name that reflects the type of resources you want to connect through this tunnel (for example, `enterprise-VPC-01`).
5. Select **Save tunnel**.
6. Next, you will need to install `cloudflared` and run it. To do so, check that the environment under **Choose an environment** reflects the operating system on your machine, then copy the command in the box below and paste it into a terminal window. Run the command.
7. Once the command has finished running, your connector will appear in Cloudflare One.
	![Connector appearing in the UI after cloudflared has run](https://developers.cloudflare.com/_astro/connector.BnVS4T_M_ZxLFu6.webp)
8. Select **Next**.

The next steps depend on whether you want to [publish an application to the Internet](#2a-publish-an-application) or [connect a private network](#2b-connect-a-network).

## 2a. Publish an application

Follow these steps to publish an application to the Internet. If you are looking to connect a private resource, skip to the [Connect a network](#2b-connect-a-network) section.

To add a published application when creating a new tunnel:

1. Go to the **Published applications** tab.
2. Enter a subdomain and select a **Domain** from the drop-down menu. Specify any subdomain or path information.
3. Under **Service**, choose a [service type](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/routing-to-tunnel/protocols/) and specify its URL. For example,
	- **Type**: *HTTP*
		- **URL**: `localhost:8000`
4. Under **Additional application settings**, specify any [parameters](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/origin-parameters/) you would like to add to your tunnel configuration.
	![Example of a published application route in the Cloudflare One dashboard](https://developers.cloudflare.com/_astro/published-app.CZQbD1Bb_ZFOOUB.webp)
5. Select **Save**.

Anyone on the Internet can now access the application at the specified hostname. To allow or block specific users, [create an Access application](https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/self-hosted-public-app/).

## 2b. Connect a network

To connect a private network through your tunnel:

1. Go to the **CIDR** tab.
2. In **CIDR**, enter the private IP address or CIDR range of your service (for example, `10.0.0.1` or `10.0.0.0/24`).
3. Select **Complete setup**.

`cloudflared` can now route traffic to these destination IPs. To configure Zero Trust policies and connect as a user, refer to [Connect an IP/CIDR](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/private-net/cloudflared/).

## 3\. View your tunnel

After saving the tunnel, you will be redirected to the **Networks** > **Connectors** page. Your tunnel should be listed with a `Healthy` status. If your tunnel status is `Inactive`, `Down`, or `Degraded`, refer to the [troubleshooting documentation](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/troubleshoot-tunnels/common-errors/#tunnel-status) for recommended next steps.