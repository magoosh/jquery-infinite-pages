jQuery Infinite Pages
=====================

A custom jQuery plugin for adding infinite scrolling to paginated HTML views, designed
for integration with the Kaminari Rails plugin.

When the user scrolls to the point where the `rel="next"` link is within a set number 
of pixels of the bottom of the screen, an async request to the next page is triggered.
The response should then update the displayed data and the pagination link.

Installation
------------

Just copy the `jquery.infinite-pages.js.coffee` file in your `app/assets/javascripts`
folder.

(It would be awesome to make this a gem, so consider that a feature request :smile:)

Plugin Usage
------------

```
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
   $(this).text("Trouble! Please drink some coconut water and try again")

# Force load of the next page
$('.infinite-table').infinitePages('next')

# Pause firing of events on scroll
$('.infinite-table').infinitePages('pause')

# Resume...
$('.infinite-table').infinitePages('resume')
```

Rails/Kaminari Example
----------------------

Example `lessons_controller.rb`:

```ruby
class LessonsController
  def index
    @lessons = current_user.subscribed_lessons.page(params[:page])
  end
end
```

Example `index.html.erb`:

```erb
<div class="infinite-table">
 <table>
   <thead>
     <tr>
       <th>Lesson</th>
       <th>Length</th>
     </tr>
   </thead>
   <tbody>
     <%= render :partial => 'lessons', :object => @lessons %>
   </tbody>
 </table>
 <p class="pagination">
   <%= link_to_next_page(@lessons, 'Next Page'))%>
 </p>
</div>
```

Example `_lessons.html.erb`:

```erb
<% @lessons.each do |lesson| %>
  <tr>
    <td><%= lesson.name %></td>
    <td><%= lesson.length.format %></td>
  </tr>
<% end %>
```

Example `index.js.erb`:

```javascript
// Append new data
$("<%=j render(:partial => 'lessons', :object => @lessons) %>").appendTo($(".infinite-table tbody"));

// Update pagination link
<% if answers.last_page? %>
  $('.pagination').remove();
<% else %>
  $('.pagination').html("<%=j link_to_next_page(@lessons, 'Next Page'))%>");
<% end %>
```
