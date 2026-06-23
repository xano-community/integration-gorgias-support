# Gorgias Integration for Xano

Create and manage support tickets, add messages, and sync customer records with the Gorgias integration for Xano.

## Functions

| Function | Description |
| --- | --- |
| `gorgias_create_ticket` | Create a new support ticket with an initial customer message. |
| `gorgias_list_tickets` | Retrieve a paginated list of support tickets. |
| `gorgias_create_ticket_message` | Add a reply or internal note to an existing ticket. |
| `gorgias_create_customer` | Create a new customer record in Gorgias. |
| `gorgias_list_customers` | Retrieve a paginated list of customers. |

## Install

### Option A — Ask Claude Code

With the [Xano MCP](https://github.com/xano-labs/mcp-server) enabled in Claude Code, paste this into Claude:

> Install the integration at https://github.com/xano-community/integration-gorgias-support into my Xano workspace.

Claude will clone the repo and push the functions to your workspace.

### Option B — Use the Xano CLI

1. Install and authenticate the [Xano CLI](https://docs.xano.com/cli):
   ```sh
   npm install -g @xano/cli
   xano auth
   ```

2. Clone and push this integration:
   ```sh
   git clone https://github.com/xano-community/integration-gorgias-support.git
   cd integration-gorgias-support
   xano workspace push -w <your-workspace-id>
   ```

   Replace `<your-workspace-id>` with the ID from `xano workspace list`.

## Configure Credentials

1. Log in to your Gorgias account at yourcompany.gorgias.com.
2. Go to Settings > REST API and create a new API token.
3. Note your account subdomain (the part before .gorgias.com) — you will pass this as the `domain` input on every function call.
4. In Xano, set the following environment variables:
   - `GORGIAS_EMAIL` — your Gorgias account email
   - `GORGIAS_API_TOKEN` — the API token you created

Environment variables used by this integration:

- `GORGIAS_API_TOKEN`
- `GORGIAS_EMAIL`

**Runtime input — `domain`:** All five functions require a `domain` input parameter. Pass your Gorgias account subdomain (the part before `.gorgias.com`) on each call. This is not an environment variable — it is supplied by the caller at runtime so one Xano workspace can serve multiple Gorgias accounts.

See `.env.example` for a template.

## Usage

Call any function from another function, task, or API endpoint using `function.run`:

```xs
function.run "gorgias_create_ticket" {
  input = {
    domain: "mycompany",
    // See function signature for required parameters
  }
} as $result
```

## Function Reference

### `gorgias_create_ticket`

Creates a new ticket in Gorgias with a customer email, message body, and channel. You can set the subject, priority, and communication channel (email, chat, phone, SMS). Use this when customers submit support requests through your app.

### `gorgias_list_tickets`

Lists tickets from your Gorgias helpdesk with cursor-based pagination. Returns ticket data including subject, status, priority, and customer info. Use this to build ticket dashboards or sync ticket data into your Xano database.

### `gorgias_create_ticket_message`

Adds a new message to a Gorgias ticket. Supports agent replies, customer messages, and internal notes by setting the channel and from_agent flag. Messages are sent asynchronously and Gorgias automatically records the sent timestamp.

### `gorgias_create_customer`

Creates a customer in Gorgias with email, name, and optional fields like external ID, language, timezone, and internal notes. Use this to sync your app's user records with Gorgias for seamless support workflows.

### `gorgias_list_customers`

Lists customers from your Gorgias account with cursor-based pagination. Returns customer names, emails, and metadata. Use this to sync customer records or look up existing customers before creating tickets.

## License

MIT — see [LICENSE](./LICENSE).
