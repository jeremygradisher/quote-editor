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
12. First, let's create the Quote model with a name attribute and its associated migration file by running the following command in the console. As we already generated the fixture file, type "n" for "no" when asked to override it:
```
rails generate model Quote name:string
```

13. All our quotes must have a name to be valid, so we'll add this as a validation in the model:
```
# app/models/quote.rb

class Quote < ApplicationRecord
  validates :name, presence: true
end
```

14. In the CreateQuotes migration, let's add null: false as a constraint to our name attribute to enforce the validation and ensure we will never store quotes with an empty name in the database even if we made a mistake in the console.
```
# db/migrate/XXXXXXXXXXXXXX_create_quotes.rb

class CreateQuotes < ActiveRecord::Migration[7.0]
  def change
    create_table :quotes do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
```

15. We are now ready to run the migration:
```
bin/rails db:migrate
```

16. Now that our model is ready, it's time to develop our CRUD controller. Let's create the file with the help of the rails generator:
```
bin/rails generate controller Quotes
```

Let's add the seven routes of the CRUD for our Quote resource:
```
# config/routes.rb

Rails.application.routes.draw do
  resources :quotes
end
```

17. Now that the routes are all set, we can write the corresponding controller actions:
```
# app/controllers/quotes_controller.rb

class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy]

  def index
    @quotes = Quote.all
  end

  def show
  end

  def new
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(quote_params)

    if @quote.save
      redirect_to quotes_path, notice: "Quote was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @quote.update(quote_params)
      redirect_to quotes_path, notice: "Quote was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @quote.destroy
    redirect_to quotes_path, notice: "Quote was successfully destroyed."
  end

  private

  def set_quote
    @quote = Quote.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:name)
  end
end
```

Great! The last thing we need to do to make our tests pass is to create the views.

18. Adding our quote views
The markup for the Quotes#index page
The first file we have to create is the Quotes#index page app/views/quotes/index.html.erb.
```
<%# app/views/quotes/index.html.erb %>

<main class="container">
  <div class="header">
    <h1>Quotes</h1>
    <%= link_to "New quote",
                new_quote_path,
                class: "btn btn--primary" %>
  </div>

  <%= render @quotes %>
</main>
```

19. We follow the Ruby on Rails conventions for the Quotes#index page by rendering each quote in the @quotes collection from the partial app/views/quotes/_quote.html.erb. This is why we need this second file:
```
<%# app/views/quotes/_quote.html.erb %>

<div class="quote">
  <%= link_to quote.name, quote_path(quote) %>
  <div class="quote__actions">
    <%= button_to "Delete",
                  quote_path(quote),
                  method: :delete,
                  class: "btn btn--light" %>
    <%= link_to "Edit",
                edit_quote_path(quote),
                class: "btn btn--light" %>
  </div>
</div>
```

20. The markup for the Quotes#new and Quotes#edit pages
The first files we have to create are app/views/quotes/new.html.erb and app/views/quotes/edit.html.erb. Note that the only difference between the two pages is the content of the <h1> tag.

```
<%# app/views/quotes/new.html.erb %>

<main class="container">
  <%= link_to sanitize("&larr; Back to quotes"), quotes_path %>

  <div class="header">
    <h1>New quote</h1>
  </div>

  <%= render "form", quote: @quote %>
</main>
```

Edit:
```
<%# app/views/quotes/edit.html.erb %>

<main class="container">
  <%= link_to sanitize("&larr; Back to quote"), quote_path(@quote) %>

  <div class="header">
    <h1>Edit quote</h1>
  </div>

  <%= render "form", quote: @quote %>
</main>
```
21. Once again, we will follow Ruby on Rails conventions by rendering the form from the app/views/quotes/_form.html.erb file. That way, we can use the same partial for both the Quotes#new and the Quotes#edit pages.
```
<%# app/views/quotes/_form.html.erb %>

<%= simple_form_for quote, html: { class: "quote form" } do |f| %>
  <% if quote.errors.any? %>
    <div class="error-message">
      <%= quote.errors.full_messages.to_sentence.capitalize %>
    </div>
  <% end %>

  <%= f.input :name, input_html: { autofocus: true } %>
  <%= f.submit class: "btn btn--secondary" %>
<% end %>
```
22. The autofocus option is here to focus the corresponding input field when the form appears on the screen, so we don't have to use the mouse and can type directly in it. Notice how the markup for the form is simple? It's because we are going to use the simple_form gem. To install it, let's add the gem to our Gemfile.
```
# Gemfile
gem "simple_form", "~> 5.1.0"
```
23. With our gem added, it's time to install it:
```
bundle install
bin/rails generate simple_form:install
```
24. The role of the simple_form gem is to make forms easy to work with. It also helps keep the form designs consistent across the application by making sure we always use the same CSS classes. Let's replace the content of the configuration file and break it down together:
```
# config/initializers/simple_form.rb

SimpleForm.setup do |config|
  # Wrappers configration
  config.wrappers :default, class: "form__group" do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: "visually-hidden"
    b.use :input, class: "form__input", error_class: "form__input--invalid"
  end

  # Default configuration
  config.generate_additional_classes_for = []
  config.default_wrapper                 = :default
  config.button_class                    = "btn"
  config.label_text                      = lambda { |label, _, _| label }
  config.error_notification_tag          = :div
  config.error_notification_class        = "error_notification"
  config.browser_validations             = false
  config.boolean_style                   = :nested
  config.boolean_label_class             = "form__checkbox-label"
end
```

25. Simple form also helps us define text for labels and placeholders in another configuration file:
```
# config/locales/simple_form.en.yml

en:
  simple_form:
    placeholders:
      quote:
        name: Name of your quote
    labels:
      quote:
        name: Name

  helpers:
    submit:
      quote:
        create: Create quote
        update: Update quote
```
25. The last view we need is the Quotes#show page. For now, it will be almost empty, containing only a title with the name of the quote and a link to go back to the Quotes#index page.
```
<%# app/views/quotes/show.html.erb %>

<main class="container">
  <%= link_to sanitize("&larr; Back to quotes"), quotes_path %>
  <div class="header">
    <h1>
      <%= @quote.name %>
    </h1>
  </div>
</main>
```

26. It seems like we just accomplished our mission. Let's make sure our test passes by running bin/rails test:system. They pass!
```
bin/rails test:system
```

27. Note: When launching the system tests, we will see the Google Chrome browser open and perform the tasks we created for our quote system test. We can use the headless_chrome driver instead to prevent the Google Chrome window from opening:
```
# test/application_system_test_case.rb

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Change :chrome with :headless_chrome
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
```

28. We can also launch our webserver with the bin/dev command in the terminal and make sure everything works just fine. Let's not forget to restart our server as we just installed a new gem and modified a configuration file.
```
bin/dev
```

29. Turbo Drive: Form responses must redirect to another location - The app works as expected unless we submit an empty form. Even if we have a presence validation on the name of the quote, the error message is not displayed as we could expect when the form submission fails. If we open the console in our dev tools, we will see the cryptic error message "Form responses must redirect to another location".

This is a "breaking change" since Rails 7 because of Turbo Drive. We will discuss this topic in-depth in Chapter 3 dedicated to Turbo Drive. If you ever encounter this issue, the way to fix it is to add status: :unprocessable_entity to the QuotesController#create and QuotesController#update actions when the form is submitted with errors:
```
# app/controllers/quotes_controller.rb

class QuotesController < ApplicationController
  # ...

  def create
    @quote = Quote.new(quote_params)

    if @quote.save
      redirect_to quotes_path, notice: "Quote was successfully created."
    else
      # Add `status: :unprocessable_entity` here
      render :new, status: :unprocessable_entity
    end
  end

  # ...

  def update
    if @quote.update(quote_params)
      redirect_to quotes_path, notice: "Quote was successfully updated."
    else
      # Add `status: :unprocessable_entity` here
      render :edit, status: :unprocessable_entity
    end
  end

  # ...
end
```

30. Seeding our application with development data
When we launched our server for the first time, we didn't have any quotes on our page. Without development data, every time we want to edit or delete a quote, we must create it first. 

While this is fine for a small application like this one, it becomes annoying for real-world applications. Imagine if we needed to create all the data manually every time we want to add a new feature. This is why most Rails applications have a script in db/seeds.rb to populate the development database with fake data to help set up realistic data for development.

In our tutorial, however, we already have fixtures for test data:

```
# test/fixtures/quotes.yml

first:
  name: First quote

second:
  name: Second quote

third:
  name: Third quote
```

31. We will reuse the data from the fixtures to create our development data. It will have two advantages:

We won't have to do the work twice in both db/seeds.rb and the fixtures files

We will keep test data and development data in sync

If you like using fixtures for your tests, you may know that instead of running bin/rails db:seed you can run bin/rails db:fixtures:load to create development data from your fixtures files. Let's tell Rails that the two commands are equivalent in the db/seeds.rb file:
```
# db/seeds.rb

puts "\n== Seeding the database with fixtures =="
system("bin/rails db:fixtures:load")
```
Running the bin/rails db:seed command is now equivalent to removing all the quotes and loading fixtures as development data. Every time we need to reset a clean development data, we can run the bin/rails db:seed command:
```
bin/rails db:seed
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