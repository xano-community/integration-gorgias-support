function "gorgias_create_customer" {
  description = "Create a new customer record in Gorgias"
  input {
    text domain { description = "Gorgias account subdomain (e.g. mycompany)" }
    text email { description = "Customer email address" }
    text name? { description = "Customer full name" }
    text external_id? { description = "External system ID for the customer" }
    text language? { description = "Preferred language code (e.g. en)" }
    text timezone? { description = "Customer timezone (e.g. America/New_York)" }
    text note? { description = "Internal note about the customer" }
  }
  stack {
    var $params {
      value = {
        email: $input.email
      }
    }
    var.update $params { value = $params|set_ifnotnull:"name":$input.name }
    var.update $params { value = $params|set_ifnotnull:"external_id":$input.external_id }
    var.update $params { value = $params|set_ifnotnull:"language":$input.language }
    var.update $params { value = $params|set_ifnotnull:"timezone":$input.timezone }
    var.update $params { value = $params|set_ifnotnull:"note":$input.note }

    var $auth_string { value = ($env.GORGIAS_EMAIL ~ ":" ~ $env.GORGIAS_API_TOKEN)|base64_encode }

    api.request {
      url = "https://" ~ $input.domain ~ ".gorgias.com/api/customers"
      method = "POST"
      headers = ["Authorization: Basic " ~ $auth_string, "Content-Type: application/json"]
      params = $params
      mock = {
        "creates customer successfully": { response: { status: 201, result: { id: 500, name: "Jane Doe", email: "jane@example.com", created_datetime: "2026-03-17T10:00:00Z" } } }
      }
    } as $api_result

    precondition ($api_result.response.status == 201) {
      error_type = "standard"
      error = "Gorgias API error: " ~ $api_result.response.result
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "creates customer successfully" {
    input = { domain: "mycompany", email: "jane@example.com", name: "Jane Doe" }
    expect.to_equal ($response.id) { value = 500 }
    expect.to_equal ($response.email) { value = "jane@example.com" }
  }
}