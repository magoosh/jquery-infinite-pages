jQuery Infinite Pages
=====================

[![Gem Version](https://badge.fury.io/rb/jquery-infinite-pages.svg)](http://badge.fury.io/rb/jquery-infinite-pages)

A light-weight jQuery plugin for adding infinite scrolling to paginated HTML views
that tastes great with [Rails](https://github.com/rails/rails) and
[Kaminari](https://github.com/amatsuda/kaminari).

This project was originally designed for Rails, but the core plugin is flexible
enough to use anywhere.

Installation
------------

Add this line to your application's `Gemfile`:
```ruby
gem 'jquery-infinite-pages'
```

And then execute:
```
bundle install
```

Add to your `application.js` file:
```javascript
//= require jquery.infinite-pages
```

### Non-Rails

Just copy the `jquery.infinite-pages.js.coffee` file from `app/assets/javascripts` to
wherever you want it.

Usage
-----
jQuery Infinite Pages binds to an element containing a `rel="next"` pagination link and
watches for scroll events.

When the link is close to the bottom of the screen, an async request to the next page
is triggered. The server's response should then append the new page and update the
pagination link.

```coffeescript
# Setup plugin and define optional event callbacks
$('.infinite-table').infinitePages
 debug: true
 buffer: 200 # load new page when within 200px of nav link
 context: '.pane' # define the scrolling container (defaults to window)
 loading: ->
   # jQuery callback on the nav element
   $(this).text("Loading...")
 success: ->
   # called after successful ajax call
 error: ->
   # called after failed ajax call
   $(this).text("Trouble! Please drink some coconut water and click again")
```

You can also manually control the firing of load events:

```coffeescript
# Force load of the next page
$('.infinite-table').infinitePages('next')

# Pause firing of events on scroll
$('.infinite-table').infinitePages('pause')

# Resume...
$('.infinite-table').infinitePages('resume')
```

Rails/Kaminari Example
----------------------

The following is an example of how to integrate this plugin into your Rails app
using Kaminari.

Set up pagination in `lessons_controller.rb`:

```ruby
class LessonsController
  def index
    @lessons = Lesson.order('lessons.name ASC').page(params[:page])
  end
end
```

Write the template for your list of lessons in `app/views/lessons/index.html.erb`:

```erb
<div class="infinite-table">
  <table>
    <tr>
      <th>Lesson</th>
      <th></th>
    </tr>
    <%= render :partial => 'lessons', :object => @lessons %>
  </table>
  <p class="pagination">
    <%= link_to_next_page(@lessons, 'Next Page', :remote => true) %>
  </p>
</div>
```

...and `app/views/lessons/_lessons.html.erb`:

```erb
<% @lessons.each do |lesson| %>
  <tr>
    <td><%= lesson.name %> (<%= lesson.length.format %>)</td>
    <td><%= link_to "watch", lesson_path(lesson) %></td>
  </tr>
<% end %>
```

Append new data to the table in `app/views/lessons/index.js.erb`:

```javascript
// Append new data
$("<%=j render(:partial => 'lessons', :object => @lessons) %>")
  .appendTo($(".infinite-table table"));

// Update pagination link
<% if @lessons.last_page? %>
  $('.pagination').html("That's all, folks!");
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@lessons, 'Next Page', :remote => true) %>");
<% end %>
```

At this point, the pagination link at the bottom of your table should allow you
to load the next page without refreshing. Finally, we trigger the next page load
with the `infinitePages` plugin in `app/assets/javascripts/lessons.js.coffee`:

```coffee
$ ->
  # Configure infinite table
  $('.infinite-table').infinitePages
    # debug: true
    loading: ->
      $(this).text('Loading next page...')
    error: ->
      $(this).button('There was an error, please try again')
```

Voila! You should now have an infinitely long list of lessons.
