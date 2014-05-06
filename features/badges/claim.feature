Feature: The user can choose the type of earnings he wants from a badge

  Background:
    Given I accept JSON
    And I am an authenticated user: "nickname"
    And existing badges for "nickname":
      | participation | 10 | 2 |

  Scenario: The badge can be converted to cristals
    When I send a POST request to "/v1/badges/me/participation/2" with the following:
      | convert_to | cristals |
    Then the response status should be "201"
    And the JSON response should have "$.identifier" with the text "participation"
    And the JSON response should have "$.converted_to" with the text "cristals"
    And the player "nickname" should have "45" cristals

  Scenario: The badge can be converted to bonus
    When I send a POST request to "/v1/badges/me/participation/2" with the following:
      | convert_to | bonus |
    Then the response status should be "201"
    And the JSON response should have "$.identifier" with the text "participation"
    And the JSON response should have "$.converted_to" with the text "bonus"
    And the player "nickname" should have "2" available bonus

  Scenario: The badge is already converted to something
    Given the "participation" badge level "2" of "nickname" is already converted
    When I send a POST request to "/v1/badges/me/participation/2" with the following:
      | convert_to | cristals |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "badge_already_claimed"

  Scenario: The badge convertion doesn't exists
    When I send a POST request to "/v1/badges/me/participation/2" with the following:
      | convert_to | gold |
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "target_not_found"

  Scenario: The badge level doesn't exists
    When I send a POST request to "/v1/badges/me/participation/3" with the following:
      | convert_to | cristals |
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "badge_not_found"

  Scenario: The badge level is invalid
    When I send a POST request to "/v1/badges/me/participation/0" with the following:
      | convert_to | cristals |
    Then the response status should be "400"

  Scenario: The badge identifier doesn't exists
    When I send a POST request to "/v1/badges/me/cool/1" with the following:
      | convert_to | cristals |
    Then the response status should be "404"
    And the JSON response should have "$.code" with the text "badge_not_found"

