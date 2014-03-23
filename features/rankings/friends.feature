Feature: Display the friends ranking

  Scenario: The user doesn't give a valid auth token
    When I send a GET request to "/v1/ladders/friends"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: I have no friends
    Given I am an authenticated user
    When I send a GET request to "/v1/ladders/friends"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"
    And the JSON response should have "$.[0].nickname" with the text "nickname"

  Scenario: There is some other people but no friends
    Given I am an authenticated user: "nickname"
    And an user "player_1" is already registered
    And an user "player_2" is already registered
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And there is the following participations for the question "1":
      | nickname | 10 | 1:0 |
      | player_1 | 10 | 1:0 |
      | player_2 | 10 | 1:1 |
    When the solution to the question "1" is:
    """
    {
      "1": 0.0
    }
    """
    When I send a GET request to "/v1/ladders/friends"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"
    And the JSON response should have "$.[0].nickname" with the text "nickname"

  Scenario: There is some friends
    Given I am an authenticated user: "nickname"
    And an user "player" is already registered
    And an user "friend" is already registered
    And the user "nickname" have the following "facebook" friends:
      | friend |
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And there is the following participations for the question "1":
      | nickname | 10 | 1:0 |
      | friend   | 10 | 1:0 |
      | player   | 10 | 1:1 |
    When the solution to the question "1" is:
    """
    {
      "1": 0.0
    }
    """
    When I send a GET request to "/v1/ladders/friends"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*].*"
    And the JSON response should have "$.[0].nickname" with the text "nickname"
    And the JSON response should have "$.[1].nickname" with the text "friend"

  Scenario: The global rank is given
    Given I am an authenticated user: "nickname"
    And an user "player" is already registered
    And an user "friend" is already registered
    And the user "nickname" have the following "facebook" friends:
      | friend |
    And existing questions:
      | 1 | Qui va gagner ?  |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And there is the following participations for the question "1":
      | nickname | 10 | 1:0 |
      | friend   | 10 | 1:0 |
      | player   | 10 | 1:1 |
    When the solution to the question "1" is:
    """
    {
      "1": 0.0
    }
    """
    When I send a GET request to "/v1/ladders/friends"
    Then the response status should be "200"
    And the JSON response should have 2 "$.[*].*"
    And the JSON response should have "$.[0].nickname" with the text "nickname"
    And the JSON response should have "$.[1].nickname" with the text "friend"
    And the JSON response should have "$.[0].rank" with the text "1"
    And the JSON response should have "$.[1].rank" with the text "2"
