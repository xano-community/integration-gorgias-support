function "gorgias_create_ticket_message" {
  description = "Add a message or internal note to an existing Gorgias ticket"
  input {
    text domain { description = "Gorgias account subdomain (e.g. mycompany)" }
    int ticket_id { description = "Ticket ID to add message to" }
    text body_html { description = "Message body in HTML" }
    text channel?="email" { description = "Channel: email, internal-note, chat, etc." }
    bool from_agent?=true { description = "True if sent by agent, false if from customer" }
    text via?="api" { description = "Routing method: api, email, etc." }
  }
  stack {
    var $params {
      value = {
        channel: $input.channel,
        from_agent: $input.from_agent,
        via: $input.via,
        body_html: $input.body_html
      }
    }

    var $auth_string { value = ($env.GORGIAS_EMAIL ~ ":" ~ $env.GORGIAS_API_TOKEN)|base64_encode }

    api.request {
      url = "https://" ~ $input.domain ~ ".gorgias.com/api/tickets/" ~ $input.ticket_id ~ "/messages"
      method = "POST"
      headers = ["Authorization: Basic " ~ $auth_string, "Content-Type: application/json"]
      params = $params
      mock = {
        "creates message successfully": { response: { status: 201, result: { id: 99001, body_html: "<p>We are looking into this</p>", sent_datetime: "2026-03-17T10:05:00Z" } } }
      }
    } as $api_result

    precondition ($api_result.response.status == 201) {
      error_type = "standard"
      error = "Gorgias API error: " ~ $api_result.response.result
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "creates message successfully" {
    input = { domain: "mycompany", ticket_id: 12345, body_html: "<p>We are looking into this</p>" }
    expect.to_equal ($response.id) { value = 99001 }
  }
}