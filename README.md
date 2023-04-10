# Turbo Rails Tutorial
https://www.hotrails.dev/turbo-rails

Learn how to leverage the power of the turbo-rails library now included by default in Rails 7 to write reactive single-page applications without having to write a single line of custom JavaScript.

## Chapter 0
https://www.hotrails.dev/turbo-rails/turbo-rails-tutorial-introduction

Turbo Rails tutorial introduction - 
In this chapter, we will explain what we are going to learn, have a look at the finished product and kickstart our brand new Rails 7 application!

1. Let's create our brand new Rails application. We will use Sass as a CSS pre-processor to create our design system, esbuild to bundle our single line of JavaScript, and a Postgresql database to be able to deploy our app on Heroku at the end of the tutorial.

```
$ rails new quote-editor --css=sass --javascript=esbuild --database=postgresql
```

2. As this tutorial was written at the time of Rails 7.0.0 let's make sure we use the version of turbo-rails that was used at the time to avoid unexpected issues. Let's update our Gemfile by locking the turbo-rails version:

```
# Gemfile
gem "turbo-rails", "~> 1.0"
```

3. We can now run bundle install to install the correct version of the gem.
```
$ bundle install
```

4. Now that our application is ready, let's type the bin/setup command to install the dependencies 
and create the database:
```
$ bin/setup
```

5. We can now run the rails server, and the scripts that precompile the CSS and the JavaScript code with the bin/dev command:
```
$ bin/dev
```

6. We can now go to http://localhost:3000, and we should see the Rails boot screen.

## Chapter 1
https://www.hotrails.dev/turbo-rails/crud-controller-ruby-on-rails
A simple CRUD controller with Rails
In this first chapter, we will start our application by creating our quote model and its associated controller following the Ruby on Rails conventions.

7. Let's first run the generator to create the test file for us:
```
bin/rails g system_test quotes
```

8. With the help of the sketches above, let's describe what happens in plain English and write some tests at the same time:
```
# test/system/quotes_test.rb

require "application_system_test_case"

class QuotesTest < ApplicationSystemTestCase
  test "Creating a new quote" do
    # When we visit the Quotes#index page
    # we expect to see a title with the text "Quotes"
    visit quotes_path
    assert_selector "h1", text: "Quotes"

    # When we click on the link with the text "New quote"
    # we expect to land on a page with the title "New quote"
    click_on "New quote"
    assert_selector "h1", text: "New quote"

    # When we fill in the name input with "Capybara quote"
    # and we click on "Create Quote"
    fill_in "Name", with: "Capybara quote"
    click_on "Create quote"

    # We expect to be back on the page with the title "Quotes"
    # and to see our "Capybara quote" added to the list
    assert_selector "h1", text: "Quotes"
    assert_text "Capybara quote"
  end
end
```

9. Let's first create the fixture file for our quotes:
```
touch test/fixtures/quotes.yml
```

10. Let's create a few quotes in this file:
```
# test/fixtures/quotes.yml

first:
  name: First quote

second:
  name: Second quote

third:
  name: Third quote
```

11. We are now ready to add two more tests to our test suite:
```
# test/system/quotes_test.rb

require "application_system_test_case"

class QuotesTest < ApplicationSystemTestCase
  setup do
    @quote = quotes(:first) # Reference to the first fixture quote
  end

  # ...
  # The test we just wrote
  # ...

  test "Showing a quote" do
    visit quotes_path
    click_link @quote.name

    assert_selector "h1", text: @quote.name
  end

  test "Updating a quote" do
    visit quotes_path
    assert_selector "h1", text: "Quotes"

    click_on "Edit", match: :first
    assert_selector "h1", text: "Edit quote"

    fill_in "Name", with: "Updated quote"
    click_on "Update quote"

    assert_selector "h1", text: "Quotes"
    assert_text "Updated quote"
  end

  test "Destroying a quote" do
    visit quotes_path
    assert_text @quote.name

    click_on "Delete", match: :first
    assert_no_text @quote.name
  end
end
```

Now that our tests are ready, we can run them with bin/rails test:system. As we can notice, all of them are failing because we are missing routes, a Quote model, and a QuotesController. Now that our requirements are precise, it's time to start working on the meat of our application.

Run the tests:
```
bin/rails test:system
```

## Chapter 2
Organizing CSS files in Ruby on Rails
In this chapter, we will write some CSS using the BEM methodology to create a nice design system for our application.

## Chapter 3
Turbo Drive
In this chapter, we will explain what Turbo Drive is and how it speeds up our Ruby on Rails applications by converting all link clicks and form submissions into AJAX requests.

## Chapter 4
Turbo Frames and Turbo Stream templates
In this chapter, we will learn how to slice our page into independent parts thanks to Turbo Frames and the Turbo Stream format. After reading this chapter, all the CRUD actions on quotes will happen on the quotes index page.

## Chapter 5
Real-time updates with Turbo Streams
In this chapter, we will learn how to broadcast Turbo Stream templates with Action Cable to make real-time updates on a web page.

## Chapter 6
Turbo Streams and security
In this chapter, we will learn how to use Turbo Streams securely and avoid sending broadcastings to the wrong users.

## Chapter 7
Flash messages with Hotwire
In this chapter, we will learn how to add flash messages with Turbo and how to make a nice animation with Stimulus.

## Chapter 8
Two ways to handle empty states with Hotwire
In this chapter, we will learn two ways to handle empty states with Turbo. The first one uses Turbo Frames and Turbo Streams, and the second uses the only-child CSS pseudo-class.

## Chapter 9
Another CRUD controller with Turbo Rails
In this chapter, we will build the CRUD controller for the dates in our quotes. It is the perfect opportunity to practice what we have learned since the beginning of the tutorial!

## Chapter 10
Nested Turbo Frames
In this chapter, we will build our last CRUD controller for line items. As line items are nested in line item dates, we will have some interesting challenges to solve with Turbo Frames!

## Chapter 11
Adding a quote total with Turbo Frames
In this chapter, we will add a sticky bar containing the total of the quote. This total will be updated every time we create, update, or delete a line item.