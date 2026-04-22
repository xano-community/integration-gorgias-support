function "gorgias_create_ticket" {
  description = "Create a new support ticket in Gorgias with an initial message"
  input {
    text domain { description = "Gorgias account subdomain (e.g. mycompany)" }
    text customer_email { description = "Customer email address" }
    text message_body { description = "Initial message body (HTML supported)" }
    text subject? { description = "Ticket subject line" }
    text via?="email" { description = "Channel: email, api, chat, phone, sms" }
    text priority?="normal" { description = "Priority: critical, high, normal, low" }
  }
  stack {
    var $params {
      value = {
        customer: {
          email: $input.customer_email
        },
        messages: [
          {
            channel: $input.via,
            from_agent: false,
            via: $input.via,
            body_html: $input.message_body
          }
        ],
        via: $input.via,
        priority: $input.priority
      }
    }
    var.update $params { value = $params|set_ifnotnull:"subject":$input.subject }

    var $auth_string { value = ($env.GORGIAS_EMAIL ~ ":" ~ $env.GORGIAS_API_TOKEN)|base64_encode }

    api.request {
      url = "https://" ~ $input.domain ~ ".gorgias.com/api/tickets"
      method = "POST"
      headers = ["Authorization: Basic " ~ $auth_string, "Content-Type: application/json"]
      params = $params
      mock = {
        "creates ticket successfully": { response: { status: 201, result: { id: 12345, subject: "Order issue", status: "open", priority: "normal", customer: { id: 100, email: "customer@example.com" }, created_datetime: "2026-03-17T10:00:00Z" } } }
      }
    } as $api_result

    precondition ($api_result.response.status == 201) {
      error_type = "standard"
      error = "Gorgias API error: " ~ $api_result.response.result
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "creates ticket successfully" {
    input = { domain: "mycompany", customer_email: "customer@example.com", message_body: "<p>I need help with my order</p>", subject: "Order issue" }
    expect.to_equal ($response.id) { value = 12345 }
    expect.to_equal ($response.status) { value = "open" }
  }
}