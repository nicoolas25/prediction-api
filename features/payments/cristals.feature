Feature: Buy cristals from the application

  Scenario: The player doesn't give a valid auth token
    When I send a POST request to "/v1/payments/apple"
    Then the response status should be "401"
    And the JSON response should have "$.code" with the text "unauthorized"

  Scenario: The player send a valid request
    Given I send and accept JSON
    And I am an authenticated user: "nickname"
    And the "apple" payment api respond with trasanction "123" and product "cristals_100"
    When I send a POST request to "/v1/payments/apple" with the following:
    """
    {
      "payload": {
        "receipt": "dont-care"
      }
    }
    """
    Then the response status should be "201"
    And the player "nickname" should have "120" cristals

  Scenario: The player claims an unknown product
    Given I send and accept JSON
    And I am an authenticated user: "nickname"
    And the "apple" payment api respond with trasanction "123" and product "cristals_99"
    When I send a POST request to "/v1/payments/apple" with the following:
    """
    {
      "payload": {
        "receipt": "dont-care"
      }
    }
    """
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "unknown_product_id"

  Scenario: The player claims a trasaction that is not found on the provider server
    Given I send and accept JSON
    And I am an authenticated user: "nickname"
    And the "apple" payment api respond with trasanction "nil" and product "cristals_100"
    When I send a POST request to "/v1/payments/apple" with the following:
    """
    {
      "payload": {
        "receipt": "dont-care"
      }
    }
    """
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "transaction_not_found"


  Scenario: The player claims an transaction that have already been processed
    Given I send and accept JSON
    And I am an authenticated user: "nickname"
    And the "apple" payment api respond with trasanction "123" and product "cristals_100"
    When I send a POST request to "/v1/payments/apple" with the following:
    """
    {
      "payload": {
        "receipt": "dont-care"
      }
    }
    """
    When I send a POST request to "/v1/payments/apple" with the following:
    """
    {
      "payload": {
        "receipt": "dont-care"
      }
    }
    """
    Then the response status should be "403"
    And the JSON response should have "$.code" with the text "existing_transaction"


  # Scenario: The player send a valid request (real case)
  #   Given I send and accept JSON
  #   And I am an authenticated user: "nickname"
  #   When I send a POST request to "/v1/payments/google" with the following:
  #   """
  #   {
  #     "payload": {
  #       "token": "dlnejjgcbhamaloaomlfbkgj.AO-J1Oy4cHCbdmRWmBlR6h17FK7WdLwHI_kUWhZlwDWJQ0qnWcbl2Msf46W2q3R16XLtvnslJ7ztFpAcT9CSZ9XgJfBEU9_2QEfm0_bVq-Ukjs0XRsVt6ZQ",
  #       "product_id": "pack_10"
  #     }
  #   }
  #   """
  #   Then the response status should be "403"
  #   And the JSON response should have "$.code" with the text "unknown_product_id"

  # Scenario: The player send a valid request (real case)
  #   Given I send and accept JSON
  #   And I am an authenticated user: "nickname"
  #   When I send a POST request to "/v1/payments/apple" with the following:
  #   """
  #   {
  #     "payload": {
  #       "receipt": ""
  #     }
  #   }
  #   """
  #   Then the response status should be "201"
  #   And the player "nickname" should have "2020" cristals
