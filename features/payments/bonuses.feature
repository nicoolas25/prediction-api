Feature: Buy bonuses from the application

  Scenario: The player send a valid request
    Given I send and accept JSON
    And I am an authenticated user: "nickname"
    And the "apple" payment api respond with trasanction "123" and product "bonus_3"
    When I send a POST request to "/v1/payments/apple" with the following:
    """
    {
      "payload": {
        "receipt": "dont-care"
      }
    }
    """
    Then the response status should be "201"
    And the player "nickname" should have "9" available bonus
