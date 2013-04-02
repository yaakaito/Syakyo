class TodoApp extends Spine.Controller
    ENTER_KEY = 13

    elements:
        '#new-todo' :   'newTodoInput'
        '#todo-list' :  'todos'

    events:
        'keyup #new-todo' :     'new'

    constructor : ->
        super
        Todo.bind 'create', @addNew

    new : (e) ->
        val = $.trim @newTodoInput.val()
        if e.which is ENTER_KEY and val
            Todo.create title : val
            @newTodoInput.val ''

    addNew : (todo) =>
        view = new Todos todo : todo
        @todos.append view.render().el

$ ->
    new TodoApp el : $('#todoapp')
    Spine.Route.setup()

    