function "gorgias_list_tickets" {
  description = "List support tickets from Gorgias with pagination"
  input {
    text domain { description = "Gorgias account subdomain (e.g. mycompany)" }
    int limit?=30 { description = "Max tickets per page" }
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
      url = "https://" ~ $input.domain ~ ".gorgias.com/api/tickets" ~ $query_string
      method = "GET"
      headers = ["Authorization: Basic " ~ $auth_string]
      mock = {
        "lists tickets successfully": { response: { status: 200, result: { data: [{ id: 12345, subject: "Order issue", status: "open", priority: "normal" }, { id: 12346, subject: "Refund request", status: "open", priority: "high" }], meta: { next_cursor: "abc123", prev_cursor: null } } } }
      }
    } as $api_result

    precondition ($api_result.response.status == 200) {
      error_type = "standard"
      error = "Gorgias API error: " ~ $api_result.response.result
    }

    var $result { value = $api_result.response.result }
  }
  response = $result

  test "lists tickets successfully" {
    input = { domain: "mycompany" }
    expect.to_not_be_null ($response.data)
    expect.to_not_be_null ($response.meta)
  }
}