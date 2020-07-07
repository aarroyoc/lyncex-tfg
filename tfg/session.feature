Feature: Sessions in Lyncex - Forms 2

Scenario: Login form
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test5.ttl' data
    When I visit '/login'
    And I get a '<form method="POST"><input type="text" name="user"><input type="password" name="password"><input type="submit" value="Login"></form>' response
    And I get a 'text/html' response type
    And I get a 200 status code

Scenario: Do a login
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test5.ttl' data
    When I login at '/login'
    Then I get a '<p>¡Sesión iniciada!</p>' response
    And I get a 'text/html' response type
    And I get a 200 status code

Scenario: Deny access
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test5.ttl' data
    When I visit '/private'
    Then I get a 403 status code
    And I get a 'text/html' response type

Scenario: Grant access
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test5.ttl' data
    And I login at '/login'
    When I visit with cookies '/private'
    Then I get a 'Monty Python' response
    And I get a 'text/plain' response type
    And I get a 200 status code

