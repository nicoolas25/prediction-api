Feature: Display the detailed infos about an user

  Scenario: The user doesn't give a valid auth token
    When I send a GET request to "/v1/users/me"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: There is some an user to display info
    Given I accept JSON
    And I am an authenticated user: "nickname"
    When I send a GET request to "/v1/users/me"
    Then the response status should be "200"
    And the JSON response should have 1 "$.statistics"
    And the JSON response should have "$.statistics.current_ranking" with the text "1"
    And the JSON response should have "$.nickname" with the text "nickname"
