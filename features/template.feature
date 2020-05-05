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

Scenario: Code templates
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test3.ttl' data
    When I visit '/person2'
    Then I get a 200 status code
    And I get a '<b>Name: </b>Adrián Arroyo<br><b>Nombre 2: </b>Mario Arroyo' response
    And I get a 'text/html' response type

Scenario: Parameters (GET, valid)
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test3.ttl' data
    When I visit '/person3?id=42'
    Then I get a 200 status code
    And I get a '<b>ID: </b>42' response
    And I get a 'text/html' response type

Scenario: Parameters (GET, invalid)
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test3.ttl' data
    When I visit '/person3?id=jojo'
    Then I get a 500 status code

Scenario: Parameters (GET, no validation)
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test3.ttl' data
    When I visit '/person4?id=pepo'
    Then I get a 200 status code
    And I get a '<b>ID: </b>pepo' response
    And I get a 'text/html' response type

Scenario: Parameters (POST, valid)
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test3.ttl' data
    When I submit form '/person5' with data 'name=Adrián'
    Then I get a 200 status code
    And I get a '<b>ID: </b>Adrián' response
    And I get a 'text/html' response type

Scenario: Register db prefix
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test3.ttl' data
    When I visit '/person6'
    Then I get a 200 status code
    And I get a '<b>Name: </b>Adrián Arroyo<br><b>Nombre 2: </b>Mario Arroyo' response
    And I get a 'text/html' response type

Scenario: Validate parameter with Prolog (valid)
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test3.ttl' data
    When I visit '/person7?age=14'
    Then I get a 200 status code
    And I get a '<b>ID: </b>14' response
    And I get a 'text/html' response type

Scenario: Validate parameter with Prolog (invalid)
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test3.ttl' data
    When I visit '/person7?age=Pepe'
    Then I get a 500 status code

Scenario: Query with template
    Given I have an empty Lyncex instance
    And I do a POST request with 'features/test3.ttl' data
    When I visit '/person8?person=Mario'
    Then I get a 200 status code
    And I get a '<b>Name: </b>Adrián Arroyo<br><b>Age: </b>21<br>Other person is: Mario Arroyo</p>' response
    And I get a 'text/html' response type