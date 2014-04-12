jQuery Infinite Pages
=====================

A light-weight jQuery plugin for adding infinite scrolling to paginated HTML views.

This plugin's designed for Kaminari and Rails, but it should be flexible enough to use
almost anywhere.

Installation
------------

Just copy the `jquery.infinite-pages.js.coffee` file to your `app/assets/javascripts`
folder.

(It would be awesome to make this a gem, so consider that a feature request :smile:)

Plugin Usage
------------

When the user scrolls to the point where the `rel="next"` link is within `buffer` pixels
of the bottom of the screen, an async request to the next page is triggered. The response
should then update the displayed data and the pagination link.

```coffeescript
# Setup plugin and define optional event callbacks
$('.infinite-table').infinitePages
 debug: true
 buffer: 200 # load new page when within 200px of nav link
 loading: ->
   # jQuery callback on the nav element
   $(this).text("Loading...")
 success: ->
   # called after successful ajax call
 error: ->
   # called after failed ajax call
   $(this).text("Trouble! Please drink some coconut water and click again")

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

Write the template for your list of lessons in `index.html.erb`:

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
    <%= link_to_next_page(@lessons, 'Next Page', :remote => true))%>
  </p>
</div>
```

...and `_lessons.html.erb`:

```erb
<% @lessons.each do |lesson| %>
  <tr>
    <td><%= lesson.name %> (<%= lesson.length.format %>)</td>
    <td><%= link_to "watch", lesson_path(lesson) %></td>
  </tr>
<% end %>
```

Append new data to the table in `index.js.erb`:

```javascript
// Append new data
$("<%=j render(:partial => 'lessons', :object => @lessons) %>")
  .appendTo($(".infinite-table table"));

// Update pagination link
<% if answers.last_page? %>
  $('.pagination').html("That's all, folks!");
<% else %>
  $('.pagination')
    .html("<%=j link_to_next_page(@lessons, 'Next Page', :remote => true))%>");
<% end %>
```

At this point, the pagination link at the bottom of your table should allow you
to load the next page without refreshing. Finally, we trigger the next page load
with the `infinitePages` plugin in `lessons.js.coffee`:

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
