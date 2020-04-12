Feature: Show information with HTML-based templating

Scenario: No variable templates
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test3.ttl' data
    When I visit '/'
    Then I get a 200 status code
    And I get a '<h1>Welcome to Lyncex</h1>' response
    And I get a 'text/html' response type

Scenario: Mirror templates in Turtle
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test3.ttl' data
    When I visit '/person'
    Then I get a 200 status code
    And I get a '<b>Name: </b>Adrián Arroyo<br><b>Age: </b>21<br>Other person is: Mario Arroyo</p>' response
    And I get a 'text/html' response type