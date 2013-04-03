class window.Todos extends Spine.Controller
    ENTER_KEY = 13
    TPL = Handlebars.compile $('#todo-template').html()

    elements : 
        '.edit' : 'editElem'

    events : 
        'click   .destroy' : 'remove'
        'click   .toggle' :  'toggleStatus'
        'dbclick label' :    'edit'
        'keyup   .edit' :    'finishEditOnEnter'
        'blur    .edit' :    'finishEdit'

    constructor : ->
        super
        @todo.bind 'update', @render
        @todo.bind 'destroy', @release

    render : =>
        @replace $.trim( TPL( @todo ) )
        @

    remove : ->
        @todo.destroy()

    toggleStatus : ->
        @todo.updateAttribute 'completed', !@todo.completed

    edit : ->
        @el.addClass 'editing'
        @editElem.focus()

    finishEdit : ->
        @el.removeClass 'edting'
        val = $.trim @editElem.val()
        if val then @todo.updateAttribute('title', val) else @remove()

    finishEditOnEnter : (e)->
        @finishEdit() if e.witch is ENTER_KEY