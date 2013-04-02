class window.Todos extends Spine.Controller
    TPL = Handlebars.compile $('#todo-template').html()

    constructor : ->
        super
        @todo.bind 'update', @render

    render : =>
        @replace $.trim( TPL( @todo ) )
        @