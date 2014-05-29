Feature: Display the list of the tags

  Scenario: There is some tags to list
    Given I am an authenticated user
    And existing tags:
      | 0 | tag1 |
      | 0 | tag2 |
    When I send a GET request to "/v1/tags"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*]"
    And the JSON response should have "$.[0].keyword" with the text "tag1"
    And the JSON response should have "$.[0].questions_count" with the text "0"
