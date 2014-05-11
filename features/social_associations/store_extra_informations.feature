Feature: Store any user related information in the database

  Scenario: The social association is created at social association creation
    Given I accept JSON
    And an user "nickname" is already registered
    And the player informations given by "facebook" are:
      | phone  | 0123456789 |
      | gender | Male       |
    When a social account for "facebook" with "fake-id" id is linked to "nickname"
    Then the social association for "facebook" for "nickname" should include those informations:
      | phone  | 0123456789 |
      | gender | Male       |

  Scenario: The social association is updated at session openning
    Given I accept JSON
    And an user "nickname" is already registered
    And the player informations given by "facebook" are:
      | gender | Female |
    And a social account for "facebook" with "fake-id" id is linked to "nickname"
    And a valid OAuth2 token for the "facebook" provider which returns the id "fake-id"
    And the social association for "facebook" for "nickname" should include those informations:
      | gender | Female |
    And the player informations given by "facebook" are:
      | phone  | 0123456789 |
      | gender | Male       |
    When I send a POST request to "/v1/sessions" with the following:
      | oauth2Provider | facebook   |
      | oauth2Token    | test-token |
    Then the social association for "facebook" for "nickname" should include those informations:
      | gender | Male |

