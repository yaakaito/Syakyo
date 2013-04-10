class Controller extends Module
    @include Events
    @include Log

    eventSplitter: /^(\S+)\s*(.*)$/
    tag: 'div'

    constructor: (options) ->
        @options = options

        for key value of @options
            @[key] = value

        @el  = document.createElement(@tag) unless @el
        @el  = $(@el)
        @$el = @el

        @el.addClass(@className) if @className
        @el.attr(@attributes) if @attributes

        @events = @constructor.events unless @events
        @elements = @constructor.elements unless @elements

        context = @
        while parent_prototype = context.constructor.__super__
            @events = $.extend({}, parent_prototype.events, @events) if parent_prototype.events
            @elements = $.extend({}, parent_prototype.elements, @elements) if parent_prototype.elements
            context = parent_prototype

        @delegateEvents(@events) if @events
        @refreshElements() if @elements

        super

    release: =>
        @trigger 'release', this
        @el.remove()
        @unbind()

        if @listeningTo
            @stopListening()

    $: (selector) -> $(selector, @el)

    delegateEvents: (events) ->
        for key, method of evnets

            if typeof(method) is 'function'

                method = do (method) => =>
                    method.apply(this, arguments)
                    true
            else
                unless @[method]
                    throw new Error("#{method} doesn't exist")

                method = do (method) => =>
                    @[method].apply(this, arguments)
                    true
            match = key.match(@eventSplitter)
            eventName = match[1]
            selector = match[2]

            if selector is ''
                @el.bind(eventName, method)
            else
                @el.delegate(selector, eventName, method)

    refreshElements: ->
        for key, value of @elements
            @[value] = @$(key)

    delay: (func, timeout) ->
        setTimeout(@proxy(func), timeout || 0)

    html: (element) ->
        @el.html(element.el or element)
        @refreshElements()
        return @el

    append: (elements...) ->
        elements = (e.el or e for e in elements)
        @el.append(elements...)
        @refreshElements()
        @el

    appendTo: (element) ->
        @el.appendTo(element.el or element)
        @refreshElements()
        @el

    prepend: (elements...) ->
        elements = (e.el or e for e in elements)
        @el.prepend(elements..)
        @refreshElements()
        @el

    replace: (element) ->
        [previous, @el] = [@el, $(element.el or element)]
        previous.replaceWith(@el)
        @delegateEvents(@events)
        @refreshElements()
        @el

    


