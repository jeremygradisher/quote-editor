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
https://www.hotrails.dev/turbo-rails/css-ruby-on-rails<br>
Organizing CSS files in Ruby on Rails
In this chapter, we will write some CSS using the BEM methodology to create a nice design system for our application.

32. Added a bunch of sass/css: <br>
The mixins folder - app/assets/stylesheets/mixins/_media.scss<br>
The configuration folder - app/assets/stylesheets/config/_variables.scss<br>
Global styles - app/assets/stylesheets/config/_reset.scss<br>
The components folder - app/assets/stylesheets/components/ - _btn and _quote<br>
.form component - app/assets/stylesheets/components/_form.scss<br>
.visually-hidden component - app/assets/stylesheets/components/_visually_hidden.scss<br>
Error messages: app/assets/stylesheets/components/_error_message.scss<br>
Layouts folder container - app/assets/stylesheets/layouts/_container.scss

Finally, we have to import all of those CSS files in our application.sass.scss

app/assets/stylesheets/application.sass.scss

Chapter 2 complete!

## Chapter 3
Turbo Drive - https://www.hotrails.dev/turbo-rails/turbo-drive<br>
In this chapter, we will explain what Turbo Drive is and how it speeds up our Ruby on Rails applications by converting all link clicks and form submissions into AJAX requests.

Understanding what Turbo Drive is
Turbo Drive is the first part of Turbo, which gets installed by default in Rails 7 applications, as we can see in our Gemfile and our JavaScript manifest file application.js:

By default, Turbo Drive speeds up our Ruby on Rails applications by converting all link clicks and form submissions into AJAX requests. That means that our CRUD application from the first chapter is already a single-page application, and we had no custom code to write.

With Turbo Drive, our Ruby on Rails applications will be fast by default because the HTML page we first visit won't be completely refreshed. When Turbo Drive intercepts a link click or a form submission, the response to the AJAX request will only serve to replace the <body> of the HTML page. In most cases, the <head> of the current HTML page won't change, resulting in a considerable performance improvement: the requests to download the fonts, CSS, and JavaScript files will only be made once when we first access the website.

Turbo Drive works by intercepting "click" events on links and "submit" events on forms.

## Disabling Turbo Drive
We may want to disable Turbo Drive for certain link clicks or form submissions in some cases. For example, this can be the case when working with gems that don't support Turbo Drive yet.

At the time writing this chapter, the Devise gem does not support Turbo Drive. A good workaround is to disable Turbo Drive on Devise forms such as the sign-in and sign-up forms. We will come back to this problem in a future chapter but for now, let's learn how to disable Turbo Drive on specific links and forms.

To disable Turbo Drive on a link or a form, we need to add the data-turbo="false" data attribute on it.

On the Quotes#index page, let's disable Turbo Drive on the "New quote" link:
```
<main class="container">
  <div class="header">
    <h1>Quotes</h1>
    <%= link_to "New quote",
                new_quote_path,
                class: "btn btn--primary",
                data: { turbo: false } %>
  </div>

  <%= render @quotes %>
</main>
```
You can see if turbo:false that the page refreshes when clicking "New Quote"

We demonstrated what Turbo Drive does for us in brand new Ruby on Rails 7 applications.

-It converts all link clicks and form submissions into AJAX requests to speed up our application<br>
-It prevents the browser from making too many requests to load CSS and JavaScript files<br>
The best part is that we didn't have to write any custom code. We get this benefit for free!

## Disable Turbo Drive
Note: It is also possible to disable Turbo Drive for the whole application, even though I don't recommend doing it as you will lose the speed benefits Turbo Drive provides.

To disable Turbo Drive on the whole application, we have to add two lines of config to our JavaScript code. You can, for example, do it directly in the manifest file:
```
// app/javascript/application.js

import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false
```
## Reloading the page with data-turbo-track="reload"
In most cases, Turbo Drive only replaces the \<body> of the HTML page and leaves the \<head> unchanged. I say in most cases because there are situations where we want Turbo Drive to notice changes on the \<head> of our web pages.

Let's take the example of a deployment where we change the CSS of our application. Thanks to the asset pipeline, the path to our CSS bundle will change from /assets/application-oldfingerprint.css to /assets/application-newfingerprint.css. However, if the \<head> never changed, users that were on the website before the deployment and who remained on the website after the deployment would still be using the old CSS bundle as no request to download the new bundle would be sent. This could harm the user experience as users would use outdated CSS. We have the same problem with our JavaScript bundle.

To solve this problem, on every new request, Turbo Drive compares the DOM elements with data-turbo-track="reload" in the \<head> of the current HTML page and the \<head> of the response. If there are differences, Turbo Drive will reload the whole page.

Let's now make a silly temporary change to our CSS manifest to simulate a change in our CSS bundle and a deployment by, for example, importing the code for the .btn component twice:
```
// app/assets/stylesheets/application.sass.scss

// Remove the double import after the experiment
@import "components/btn";
@import "components/btn";
```

Next time we click on a link, we should see a complete page reload. Let's test it and see that it works! Turbo Drive is a fantastic piece of software!

## Changing the style of the Turbo Drive progress bar
As Turbo Drive overrides the browser's default behavior for link clicks and form submissions, the browser's default progress bar/loaders won't work as expected anymore.

Turbo has our back and has a built-in replacement for the browser's default progress bar, and we can style it to meet our application's design system! Let's style the Turbo Drive progress bar before moving to the next chapter:

33. A good way to see we succeeded in adding styles to the Turbo progress bar is to temporarily add sleep 3 to our controller actions for the progress bar to appear for at least 3 seconds:
```
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  # Add this line to see the progress bar long enough
  # and remove it when it has the expected styles
  before_action -> { sleep 3 }
end
```

That's it, our progress bar is styled and matches our design system! We can now remove the sleep 3 piece of code.

Chapter 3 complete!

## Chapter 4
Turbo Frames and Turbo Stream templates<br>
https://www.hotrails.dev/turbo-rails/turbo-frames-and-turbo-streams<br>
In this chapter, we will learn how to slice our page into independent parts thanks to Turbo Frames and the Turbo Stream format. After reading this chapter, all the CRUD actions on quotes will happen on the quotes index page.

### Turbo Frames and Turbo Stream templates
In this chapter, we will learn how to slice our page into independent parts thanks to Turbo Frames and the Turbo Stream format. After reading this chapter, all the CRUD actions on quotes will happen on the quotes index page.

Currently tests are still passing:
```
bin/rails test:system
```

34. Let's now update our Capybara system tests to match the desired behavior of all CRUD actions happening on the quotes index page.
```
# test/system/quotes_test.rb

require "application_system_test_case"

class QuotesTest < ApplicationSystemTestCase
  setup do
    @quote = quotes(:first)
  end

  test "Showing a quote" do
    visit quotes_path
    click_link @quote.name

    assert_selector "h1", text: @quote.name
  end

  test "Creating a new quote" do
    visit quotes_path
    assert_selector "h1", text: "Quotes"

    click_on "New quote"
    fill_in "Name", with: "Capybara quote"

    assert_selector "h1", text: "Quotes"
    click_on "Create quote"

    assert_selector "h1", text: "Quotes"
    assert_text "Capybara quote"
  end

  test "Updating a quote" do
    visit quotes_path
    assert_selector "h1", text: "Quotes"

    click_on "Edit", match: :first
    fill_in "Name", with: "Updated quote"

    assert_selector "h1", text: "Quotes"
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

If we run the tests now, the two tests corresponding to the creation and the edition of quotes will fail. Our goal is to make them green again with Turbo Frames and Turbo Streams. Ready to learn how they work? Let's dive in!

### What are Turbo Frames?
Turbo Frames are independent pieces of a web page that can be appended, prepended, replaced, or removed without a complete page refresh and writing a single line of JavaScript!

35. Let's create our first Turbo Frame. To create Turbo Frames, we use the turbo_frame_tag helper. Let's wrap the header on the Quotes#index page in a Turbo Frame with an id of "first_turbo_frame":
```
<%# app/views/quotes/index.html.erb %>

<main class="container">
  <%= turbo_frame_tag "first_turbo_frame" do %>
    <div class="header">
      <h1>Quotes</h1>
      <%= link_to "New quote", new_quote_path, class: "btn btn--primary" %>
    </div>
  <% end %>

  <%= render @quotes %>
</main>
```

### Turbo Frames cheat sheet
In this section, we will explain the rules that apply to Turbo Frames.
<strong>Even if the examples are written with links, those rules apply for both links and forms!</strong>

<strong>Rule 1:</strong> When clicking on a link within a Turbo Frame, Turbo expects a frame of the same id on the target page. It will then replace the Frame's content on the source page with the Frame's content on the target page.

35. let's add the Turbo Frame with the same id on the Quotes#new page:
```
<%# app/views/quotes/new.html.erb %>

<main class="container">
  <%= link_to sanitize("&larr; Back to quotes"), quotes_path %>

  <div class="header">
    <h1>New quote</h1>
  </div>

  <%= turbo_frame_tag "first_turbo_frame" do %>
    <%= render "form", quote: @quote %>
  <% end %>
</main>
```

When clicking on a link within a Turbo Frame, if there is a frame with the same id on the target page, Turbo will replace the content of the Turbo Frame of the source page with the content of the Turbo Frame of the target page.

<strong>Rule 2:</strong> When clicking on a link within a Turbo Frame, if there is no Turbo Frame with the same id on the target page, the frame disappears, and the error Response has no matching \<turbo-frame id="name_of_the_frame"> element is logged in the console.

<strong>Rule 3:</strong> A link can target another frame than the one it is directly nested in thanks to the data-turbo-frame data attribute.

36. On the Quotes#index page, we need to add the second Turbo Frame and the data-turbo-frame data attribute with the same id as this second Turbo Frame:
```
<%# app/views/quotes/index.html.erb %>

<main class="container">
  <%= turbo_frame_tag "first_turbo_frame" do %>
    <div class="header">
      <h1>Quotes</h1>
      <%= link_to "New quote",
                  new_quote_path,
                  data: { turbo_frame: "second_frame" },
                  class: "btn btn--primary" %>
    </div>
  <% end %>

  <%= turbo_frame_tag "second_frame" do %>
    <%= render @quotes %>
  <% end %>
</main>

```

37. On the Quote#new page, let's wrap our form in a Turbo Frame of the same name as the second frame:
```
<%# app/views/quotes/new.html.erb %>

<main class="container">
  <%= link_to sanitize("&larr; Back to quotes"), quotes_path %>

  <div class="header">
    <h1>New quote</h1>
  </div>

  <%= turbo_frame_tag "second_frame" do %>
    <%= render "form", quote: @quote %>
  <% end %>
</main>
```

Now let's experiment again. Let's visit the Quotes#index page, refresh it, and click on the "New quote" button. We should see our quotes list replaced by the new quote form. This is because our link now targets the second frame thanks to the data-turbo-frame attribute.

A link can target a Turbo Frame it is not directly nested in, thanks to the data-turbo-frame data attribute. In that case, the Turbo Frame with the same id as the data-turbo-frame data attribute on the source page will be replaced by the Turbo Frame of the same id as the data-turbo-frame data attribute on the target page.

### Note:
There is a special frame called _top that represents the whole page. It's not really a Turbo Frame, but it behaves almost like one, so we will make this approximation for our mental model.

For example, if we wanted our "New quote" button to replace the whole page, we could use data-turbo-frame="_top". Of course, every page has the "_top" frame by default, so our Quotes#new page also has it.

38. To make our markup match our sketches on the Quotes#index page, let's tell our "New quote" link to target the "_top" frame:
```
<%# app/views/quotes/index.html.erb %>

<main class="container">
  <%= turbo_frame_tag "first_turbo_frame" do %>
    <div class="header">
      <h1>Quotes</h1>
      <%= link_to "New quote",
                  new_quote_path,
                  data: { turbo_frame: "_top" },
                  class: "btn btn--primary" %>
    </div>
  <% end %>

  <%= render @quotes %>
</main>
```
39. We can add whatever we want on the Quotes#new page. It does not matter as the browser will replace the whole page. For our example, we will simply go back to our initial state:
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
Now let's experiment again. Let's navigate to the Quotes#index page and click on the "New quote" button. We can see that the whole page is replaced by the content of the Quotes#new page.

<b>When using the "_top" keyword, the URL of the page changes to the URL of the target page, which is another difference from when using a regular Turbo Frame.</b>

As we can notice, Turbo Frames are a significant addition to our toolbox as Ruby on Rails developers. They enable us to slice up pages in independent contexts without writing any custom JavaScript.

40. Let's practice and make our system tests pass! But just before, let's reset our Quotes#index page markup to its initial state:
```
<%# app/views/quotes/index.html.erb %>

<main class="container">
  <div class="header">
    <h1>Quotes</h1>
    <%= link_to "New quote", new_quote_path, class: "btn btn--primary" %>
  </div>

  <%= render @quotes %>
</main>
```

## Editing quotes with Turbo Frames

41. With those sketches in mind and the rules of the previous section, let's implement this behavior. On the Quotes#index page, let's wrap each quote in a Turbo Frame with an id of "quote_#{quote_id}". As each quote card on the Quotes#index page is rendered from the _quote.html.erb partial, we simply need to wrap each quote within a Turbo Frame with this id:
```
<%# app/views/quotes/_quote.html.erb %>

<%= turbo_frame_tag "quote_#{quote.id}" do %>
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
<% end %>
```

42. We need a Turbo Frame of the same id around the form of the Quotes#edit page:
```
<%# app/views/quotes/edit.html.erb %>

<main class="container">
  <%= link_to sanitize("&larr; Back to quote"), quote_path(@quote) %>

  <div class="header">
    <h1>Edit quote</h1>
  </div>

  <%= turbo_frame_tag "quote_#{@quote.id}" do %>
    <%= render "form", quote: @quote %>
  <% end %>
</main>
```

Now with only those four lines of code added, let's try our code in the browser. Let's click on the "Edit" button for a quote. The form successfully replaces the quote card.

### Turbo Frames and the dom_id helper

There is one more thing to know about the turbo_frame_tag helper. You can pass it a string or any object that can be converted to a dom_id. The dom_id helper helps us convert an object into a unique id like this:
```
# If the quote is persisted and its id is 1:
dom_id(@quote) # => "quote_1"

# If the quote is a new record:
dom_id(Quote.new) # => "new_quote"

# Note that the dom_id can also take an optional prefix argument
# We will use this later in the tutorial
dom_id(Quote.new, "prefix") # "prefix_new_quote"
```

The turbo_frame_tag helper automatically passes the given object to dom_id. Therefore, we can refactor our two turbo_frame_tag calls in our Quotes#index and Quotes#edit views by passing an object instead of a string. The following blocks of code are equivalent:
```
<%= turbo_frame_tag "quote_#{@quote.id}" do %>
  ...
<% end %>

<%= turbo_frame_tag dom_id(@quote) do %>
  ...
<% end %>

<%= turbo_frame_tag @quote %>
  ...
<% end %>
```

43. Let's refactor the code we just wrote to use this syntactic sugar:
```
<%# app/views/quotes/_quote.html.erb %>

<%= turbo_frame_tag quote do %>
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
<% end %>
```
```
<%# app/views/quotes/edit.html.erb %>

<main class="container">
  <%= link_to sanitize("&larr; Back to quote"), quote_path(@quote) %>

  <div class="header">
    <h1>Edit quote</h1>
  </div>

  <%= turbo_frame_tag @quote do %>
    <%= render "form", quote: @quote %>
  <% end %>
</main>
```

44. Turbo expects a Turbo Frame of the same id on the Quotes#show page. To solve the problem, we will make the links to the Quote#show page target the "_top" frame to replace the whole page:
```
<%# app/views/quotes/_quote.html.erb %>

<%= turbo_frame_tag quote do %>
  <div class="quote">
    <%= link_to quote.name,
                quote_path(quote),
                data: { turbo_frame: "_top" } %>
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
<% end %>
```

Let's test it in the browser. Our first problem is solved. Our links to the Quotes#show page now work as expected!

We could solve the second problem with the same method by making the form to delete the quote target the "_top" frame:
```
<%# app/views/quotes/_quote.html.erb %>

<%= turbo_frame_tag quote do %>
  <div class="quote">
    <%= link_to quote.name,
                quote_path(quote),
                data: { turbo_frame: "_top" } %>
    <div class="quote__actions">
      <%= button_to "Delete",
                    quote_path(quote),
                    method: :delete,
                    form: { data: { turbo_frame: "_top" } },
                    class: "btn btn--light" %>
      <%= link_to "Edit",
                  edit_quote_path(quote),
                  class: "btn btn--light" %>
    </div>
  </div>
<% end %>
```
While this is a perfectly valid solution, it has an unintended side effect we might want to address. Imagine if we open the form for the second quote, and click on the "Delete" button for the third quote like in this example:

Go ahead and test it in the browser. The third quote is removed as expected, but the response also closes the form for the second quote. This is because, as the form to delete the third quote targets the "_top" frame, the whole page is replaced!

It would be nice if we could only remove the Turbo Frame containing the deleted quote and leave the rest of the page unchanged to preserve the state of the page. Well, Turbo and Rails once again have our back! Let's remove what we just did for the "Delete" button:

```
<%# app/views/quotes/_quote.html.erb %>

<%= turbo_frame_tag quote do %>
  <div class="quote">
    <%= link_to quote.name,
                quote_path(quote),
                data: { turbo_frame: "_top" } %>
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
<% end %>
```

45. In the controller, let's support both the HTML and the TURBO_STREAM formats thanks to the respond_to method:
```
# app/controllers/quotes_controller.rb

def destroy
  @quote.destroy

  respond_to do |format|
    format.html { redirect_to quotes_path, notice: "Quote was successfully destroyed." }
    format.turbo_stream
  end
end
```

46. As with any other format, let's create the corresponding view:
```
<%# app/views/quotes/destroy.turbo_stream.erb %>

<%= turbo_stream.remove "quote_#{@quote.id}" %>
```

Let's delete a quote and inspect the response body in the "Network" tab in the browser.

Where does this HTML come from? In the TURBO_STREAM view we just created, the turbo_stream helper received the remove method with the "quote_#{@quote.id}" as an argument. As we can see, this helper converts this into a <turbo-stream> custom element with the action "remove" and the target "quote_908005780".

When the browser receives this HTML, Turbo will know how to interpret it. It will perform the desired action on the Turbo Frame with the id specified by the target attribute. In our case, Turbo removes the Turbo Frame corresponding to the deleted quote leaving the rest of the page untouched. That's exactly what we wanted!

Note: As of writing this chapter, the turbo_stream helper responds to the following methods, so that it can perform the following actions:
```
# Remove a Turbo Frame
turbo_stream.remove

# Insert a Turbo Frame at the beginning/end of a list
turbo_stream.append
turbo_stream.prepend

# Insert a Turbo Frame before/after another Turbo Frame
turbo_stream.before
turbo_stream.after

# Replace or update the content of a Turbo Frame
turbo_stream.update
turbo_stream.replace
```

With the combination of Turbo Frames and the new TURBO_STREAM format, we will be able to perform precise operations on pieces of our web pages without having to write a single line of JavaScript, therefore preserving the state of our web pages.

One last thing before we move on to the next section, the turbo_stream helper can also be used with dom_id. We can refactor our view like this:
```
<%# app/views/quotes/destroy.turbo_stream.erb %>

<%= turbo_stream.remove @quote %>
```





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