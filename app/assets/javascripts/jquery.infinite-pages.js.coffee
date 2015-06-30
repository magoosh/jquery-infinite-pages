###
jQuery Infinite Pages v0.2.0
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
    # Internal id to tracking the elements used for multiple instances
    @_ID: 0

    # Internal helper to return a unique id for a new instance for the page
    @_nextId: ->
      @_ID += 1
      @_ID

    # Default settings
    defaults:
      debug: false  # set to true to log messages to the console
      navSelector: 'a[rel=next]'
      buffer: 1000  # 1000px buffer by default
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
      @$table = $(container).find('table')
      @$context = $(@options.context)
      @instanceId = @constructor._nextId()
      @invalidateAt = +new Date # timestamp before which we ignore responses
      @requestAts = [] # list of timestamps for pending requests
      @init()

    # Setup and bind to related events
    init: ->

      # Debounce scroll event to improve performance
      scrollDelay = 250
      scrollTimeout = null
      lastCheckAt = null
      scrollHandler = (=>
        lastCheckAt = +new Date
        @check()
      )

      # Have we waited enough time since the last check?
      shouldCheck = -> +new Date > lastCheckAt + scrollDelay

      @$context.scroll ->
        scrollHandler() if shouldCheck # Call the check once every scrollDelay ms
        if scrollTimeout
          clearTimeout(scrollTimeout)
          scrollTimeout = null
        scrollTimeout = setTimeout(scrollHandler, scrollDelay)

      # Set a data attribute so we can find again after a turbolink page is loaded
      @$container.attr('data-jquery-infinite-pages-container', @instanceId)

      # Setup callbacks to handle turbolinks page loads
      $(window.document)
        .on("page:before-unload", => @_invalidateActiveRequests())
        .on("page:change", => @_recache())

    # Internal helper for logging messages
    _log: (msg) ->
      console?.log(msg) if @options.debug

    # Check the distance of the nav selector from the bottom of the window and fire
    # load event if close enough
    check: ->
      nav = @$container.find(@options.navSelector)
      if nav.size() == 0
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

        @requestAts.push +new Date # note when this request started
        $.getScript(@$container.find(@options.navSelector).attr('href'))
          .done(=> @_success())
          .fail(=> @_error())

    _loading: ->
      @options.state.loading = true
      @_log "Loading next page..."
      if typeof @options.loading is 'function'
        @$container.find(@options.navSelector).each(@options.loading)

    _success: ->
      # ignore any requests that started before we last invalidated
      return if @_isInvalidatedRequest(@requestAts.shift())
      @_recache()
      @options.state.loading = false
      @_log "New page loaded!"
      if typeof @options.success is 'function'
        @$container.find(@options.navSelector).each(@options.success)

    _error: ->
      # ignore any requests that started before we last invalidated
      return if @_isInvalidatedRequest(@requestAts.shift())
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

    _recache: ->
      # Recache the element references we use (needed when using turbolinks)
      @$container = $("[data-jquery-infinite-pages-container=#{@instanceId}]")
      @$table = @$container.find('table')
      @$context = $(@options.context)

    _invalidateActiveRequests: ->
      # Invalidate any active requests (needed when using turbolinks)
      @invalidateAt = +new Date

    _isInvalidatedRequest: (requestAt) ->
      # Check to see if a request was invalidated
      requestAt < @invalidateAt

  # Define the plugin
  $.fn.extend infinitePages: (option, args...) ->
    @each ->
      $this = $(this)
      data = $this.data('infinitepages')

      if !data
        $this.data 'infinitepages', (data = new InfinitePages(this, option))
      if typeof option == 'string'
        data[option].apply(data, args)

) window.jQuery, window
