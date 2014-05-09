Feature: Display the global ranking

  Background:
    Given I accept JSON
    And I am an authenticated user: "nickname"
    And "100" registered users with "player" as nickname prefix
    And the players with nickname prefix "player" have random scores

  Scenario: The player asks for the top ranking
    Given the player "nickname" has a ranking of "30"
    When I send a GET request to "/v1/ladders/global/top"
    Then the response status should be "200"
    And the JSON response should have 30 "$.[*].*"
    And the JSON response should have "$.[29].nickname" with the text "nickname"

  Scenario: The player asks for the ranking arround him
    Given the player "nickname" has a ranking of "49"
    When I send a GET request to "/v1/ladders/global/me"
    Then the response status should be "200"
    And the JSON response should have 30 "$.[*].*"
    And the JSON response should have "$.[15].nickname" with the text "nickname"

  Scenario: The player asks for the ranking following a given player
    Given the player "nickname" has a ranking of "80"
    When I send a GET request to "/v1/ladders/global/me/after"
    Then the response status should be "200"
    And the JSON response should have "$.[0].nickname" with the text "nickname"
    And the JSON response should have 22 "$.[*].*"

  Scenario: The player asks for the ranking preceding a given player
    Given the player "nickname" has a ranking of "20"
    When I send a GET request to "/v1/ladders/global/me/before"
    Then the response status should be "200"
    And the JSON response should have 20 "$.[*].*"
    And the JSON response should have "$.[19].nickname" with the text "nickname"