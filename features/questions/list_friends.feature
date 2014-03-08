Feature: Display lists of opened questions answered by friends

  Scenario: The user doesn't give a valid auth token
    When I send a GET request to "/v1/questions/fr/friends/open"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: There is no open question answered by a friend to display
    Given I am an authenticated user
    And existing questions:
      | 1 | Qui va gagner ?  |
      | 2 | Qui va marquer ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing components for the question "2":
      | 2 | choices | Chosir le bon joueur | Zidane,Zlatan |
    And the user "nickname" has answered the question "1" with:
      | id | value |
      | 1  | 0     |
    When I send a GET request to "/v1/questions/fr/friends/open"
    Then the response status should be "200"
    And the JSON response should have 0 "$.[*].*"

  Scenario: There is some open question answered by a friend to display
    Given I am an authenticated user
    And an user "friend_1" is already registered
    And the user "nickname" have the following "facebook" friends:
      | friend_1 |
    And existing questions:
      | 1 | Qui va gagner ?  |
      | 2 | Qui va marquer ? |
    And existing components for the question "1":
      | 1 | choices | Chosir la bonne équipe | France,Belgique |
    And existing components for the question "2":
      | 2 | choices | Chosir le bon joueur | Zidane,Zlatan |
    And the user "friend_1" has answered the question "2" with:
      | id | value |
      | 2  | 0     |
    When I send a GET request to "/v1/questions/fr/friends/open"
    Then the response status should be "200"
    And the JSON response should have 1 "$.[*].*"
    And the JSON response should have "$.[0].expires_at"
    And the JSON response should have "$.[0].label" with the text "Qui va marquer ?"
