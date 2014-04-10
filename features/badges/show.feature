Feature: The user can ask to see the details of its badges

  Background:
    Given I accept JSON
    And I am an authenticated user: "nickname"
    And existing badges for "nickname":
      | participation | 5 | 1 |

  Scenario: The badge exists
    When I send a GET request to "/v1/badges/me/participation/1"
    Then the response status should be "200"
    And the JSON response should have "$.identifier" with the text "participation"

  Scenario: The badge level doesn't exists
    When I send a GET request to "/v1/badges/me/participation/2"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "badge_not_found"

  Scenario: The badge identifier doesn't exists
    When I send a GET request to "/v1/badges/me/cool/1"
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "badge_not_found"

