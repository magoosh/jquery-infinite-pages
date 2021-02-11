###
jQuery Infinite Pages v0.2.3
https://github.com/magoosh/jquery-infinite-pages

Released under the MIT License
###

#
# Built with a class-based template for jQuery plugins in Coffeescript:
# https://gist.github.com/rjz/3610858
#

(($, window) ->
  # Define the plugin class
  class InfinitePages

    # Default settings
    defaults:
      debug: false  # set to true to log messages to the console
      navSelector: 'a[rel=next]'
      buffer: 1000  # 1000px buffer by default
      debounce: 250 # 250ms debounce by default
      loading: null # optional callback when next-page request begins
      success: null # optional callback when next-page request finishes
      error:   null # optional callback when next-page request fails
      context: window # context to define the scrolling container
      state:
        paused:  false
        loading: false

    # Constructs the new InfinitePages object
    #
    # container - the element containing the infinite table and pagination links
    constructor: (container, options) ->
      @options = $.extend({}, @defaults, options)
      @$container = $(container)
      @$context = $(@options.context)
      @init()

    # Setup and bind to related events
    init: ->

      # Debounce scroll event to improve performance
      scrollTimeout = null
      scrollHandler = (=> @check())
      debounce = @options.debounce

      # Use namespace to let us unbind event handler
      @$context.on 'scroll.infinitePages', ->
        if scrollTimeout && self.active
          clearTimeout(scrollTimeout)
          scrollTimeout = null
        scrollTimeout = setTimeout(scrollHandler, debounce)

    # Internal helper for logging messages
    _log: (msg) ->
      console?.log(msg) if @options.debug

    # Check the distance of the nav selector from the bottom of the window and fire
    # load event if close enough
    check: ->
      nav = @$container.find(@options.navSelector)
      if nav.length == 0
        @_log "No more pages to load"
      else
        windowBottom = @$context.scrollTop() + @$context.height()
        distance = nav.offset().top - windowBottom

        if @options.state.paused
          @_log "Paused"
        else if @options.state.loading
          @_log "Waiting..."
        else if (distance > @options.buffer)
          @_log "#{distance - @options.buffer}px remaining..."
        else
          @next() # load the next page

    # Load the next page
    next: ->
      if @options.state.done
        @_log "Loaded all pages"
      else
        @_loading()

        @jqXHR = $.getScript(@$container.find(@options.navSelector).attr('href'))
          .done(=> @_success())
          .fail(=> @_error())

    _loading: ->
      @options.state.loading = true
      @_log "Loading next page..."
      if typeof @options.loading is 'function'
        @$container.find(@options.navSelector).each(@options.loading)

    _success: ->
      @options.state.loading = false
      @jqXHR = null
      @_log "New page loaded!"
      if typeof @options.success is 'function'
        @$container.find(@options.navSelector).each(@options.success)

    _error: ->
      @options.state.loading = false
      @_log "Error loading new page :("
      if typeof @options.error is 'function'
        @$container.find(@options.navSelector).each(@options.error)

    # Pause firing of events on scroll
    pause: ->
      @options.state.paused = true
      @_log "Scroll checks paused"

    # Resume firing of events on scroll
    resume: ->
      @options.state.paused = false
      @_log "Scroll checks resumed"
      @check()
      
    stop: ->
      @$context.off 'scroll.infinitePages'
      @_log "Scroll checks stopped"  
      
    # Abort loading of the page
    abort: ->
      if @jqXHR
        @jqXHR.abort()
        @jqXHR = null
        @_log "Page load aborted!"
      else
        @_log "There was no request to abort"  

  # Define the plugin
  $.fn.extend infinitePages: (option, args...) ->
    @each ->
      $this = $(this)
      data = $this.data('infinitepages')

      if !data
        $this.data 'infinitepages', (data = new InfinitePages(this, option))
      if typeof option == 'string'
        if option == 'destroy'
           data.stop args
         else if option == 'reinit'
           data.init args
         else
          data[option].apply(data, args)

) window.jQuery, window
