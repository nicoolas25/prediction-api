Feature: Buy bonus with cristals from the application

  Background:
    Given I accept JSON

  Scenario: The player doesn't give a valid auth token
    When I send a POST request to "/v1/conversions" with the following:
      | target | bonus_2 |
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: The player send a valid request
    Given I am an authenticated user: "nickname" with "100" cristals
    When I send a POST request to "/v1/conversions" with the following:
      | target | bonus_2 |
    Then the response status should be "201"
    And the player "nickname" should have "8" available bonus

  Scenario: The player claims an unknown target
    Given I am an authenticated user: "nickname"
    When I send a POST request to "/v1/conversions" with the following:
      | target | bonu_2 |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "unknown_target"

  Scenario: The player have not enough cristals
    Given I am an authenticated user: "nickname"
    When I send a POST request to "/v1/conversions" with the following:
      | target | bonus_4 |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "cristals_needed"
