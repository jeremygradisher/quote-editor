# Turbo Rails Tutorial
https://www.hotrails.dev/turbo-rails

Learn how to leverage the power of the turbo-rails library now included by default in Rails 7 to write reactive single-page applications without having to write a single line of custom JavaScript.

Wiki: https://github.com/jeremygradisher/quote-editor/wiki

## Chapter 0 - Turbo Rails tutorial introduction
Tutorial: https://www.hotrails.dev/turbo-rails/turbo-rails-tutorial-introduction

Wiki: https://github.com/jeremygradisher/quote-editor/wiki/Chapter-0

Turbo Rails tutorial introduction - 
In this chapter, we will explain what we are going to learn, have a look at the finished product and kickstart our brand new Rails 7 application!

## Chapter 1 - A simple CRUD controller with Rails
Tutorial: https://www.hotrails.dev/turbo-rails/crud-controller-ruby-on-rails

Wiki: https://github.com/jeremygradisher/quote-editor/wiki/Chapter-1

A simple CRUD controller with Rails
In this first chapter, we will start our application by creating our quote model and its associated controller following the Ruby on Rails conventions.

## Chapter 2 - Organizing CSS files in Ruby on Rails
Tutorial: https://www.hotrails.dev/turbo-rails/css-ruby-on-rails

Wiki: https://github.com/jeremygradisher/quote-editor/wiki/Chapter-2

Organizing CSS files in Ruby on Rails
In this chapter, we will write some CSS using the BEM methodology to create a nice design system for our application.

## Chapter 3 - Turbo Drive
Tutorial: https://www.hotrails.dev/turbo-rails/turbo-drive<br>
In this chapter, we will explain what Turbo Drive is and how it speeds up our Ruby on Rails applications by converting all link clicks and form submissions into AJAX requests.

Wiki: https://github.com/jeremygradisher/quote-editor/wiki/Chapter-3

## Chapter 4 - Turbo Frames and Turbo Stream templates
https://www.hotrails.dev/turbo-rails/turbo-frames-and-turbo-streams<br>
In this chapter, we will learn how to slice our page into independent parts thanks to Turbo Frames and the Turbo Stream format. After reading this chapter, all the CRUD actions on quotes will happen on the quotes index page.

Wiki: https://github.com/jeremygradisher/quote-editor/wiki/Chapter-4

## Chapter 5
Real-time updates with Turbo Streams<br>
Tutorial: https://www.hotrails.dev/turbo-rails/turbo-streams
In this chapter, we will learn how to broadcast Turbo Stream templates with Action Cable to make real-time updates on a web page.

Wiki: https://github.com/jeremygradisher/quote-editor/wiki/Chapter-5

## Chapter 6
Turbo Streams and security<br>
Tutorial: https://www.hotrails.dev/turbo-rails/turbo-streams-security
In this chapter, we will learn how to use Turbo Streams securely and avoid sending broadcastings to the wrong users.

Wiki: https://github.com/jeremygradisher/quote-editor/wiki/Chapter-6

I need to pick this up before pushing to production:
---

Note: When logging in with users, you might encounter a redirection bug when submitting an invalid form. This is because the **Devise gem does not support Turbo yet (version 4.8.1).** The easiest way to prevent this bug is to **disable Turbo on Devise forms by setting the data-turbo attribute to false on Devise forms**, as we learned in the [Turbo Drive chapter](https://www.hotrails.dev/turbo-rails/turbo-drive).

We won't do it in our Tutorial, but if we pushed our app to production, we would have to do it before real users try our app.

---

## Chapter 7
Flash messages with Hotwire<br>
Tutorial: https://www.hotrails.dev/turbo-rails/flash-messages-hotwire
In this chapter, we will learn how to add flash messages with Turbo and how to make a nice animation with Stimulus.

Wiki: https://github.com/jeremygradisher/quote-editor/wiki/Chapter-7

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