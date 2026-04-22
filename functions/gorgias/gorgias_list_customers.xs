function "gorgias_list_customers" {
  description = "List customers from Gorgias with pagination"
  input {
    text domain { description = "Gorgias account subdomain (e.g. mycompany)" }
    int limit?=30 { description = "Max customers per page" }
    text cursor? { description = "Pagination cursor for next page" }
  }
  stack {
    var $auth_string { value = ($env.GORGIAS_EMAIL ~ ":" ~ $env.GORGIAS_API_TOKEN)|base64_encode }

    var $query_string { value = "?limit=" ~ $input.limit }
    conditional {
      if ($input.cursor != null) {
        var.update $query_string { value = $query_string ~ "&cursor=" ~ $input.cursor }
      }
    }

    api.request {
      url = "https://" ~ $input.domain ~ ".gorgias.com/api/customers" ~ $query_string
      method = "GET"
      headers = ["Authorization: Basic " ~ $auth_string]
      mock = {
        "lists customers successfully": { response: { status: 200, result: { data: [{ id: 500, name: "Jane Doe", email: "jane@example.com" }, { id: 501, name: "John Smith", email: "john@example.com" }], meta: { next_cursor: "xyz789", prev_cursor: null } } } }
      }
    } as $api_result

    precondition ($api_result.response.status == 200) {
      error_type = "standard"
      error = "Gorgias API error: " ~ $api_result.response.result
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "lists customers successfully" {
    input = { domain: "mycompany" }
    expect.to_not_be_null ($response.data)
    expect.to_not_be_null ($response.meta)
  }
}