class window.Todos extends Spine.Controller
    TPL = Handlebars.compile $('#todo-template').html()

    constructor : ->
        super
        
    render : =>
        @replace $.trim( TPL( @todo ) )
        @