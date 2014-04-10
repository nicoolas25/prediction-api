Feature: Display the user's cristals

  Scenario: The user have 33 cristals
    Given I accept JSON
    And I am an authenticated user: "nickname" with "33" cristals
    When I send a GET request to "/v1/users/me/cristals"
    Then the response status should be "200"
    And the JSON response should have "$.cristals" with the text "33"
