class TodoApp extends Spine.Controller
    ENTER_KEY = 13

    elements:
        '#new-todo' :   'newTodoInput'
        '#toggle-all' : 'toggleAllElem'
        '#todo-list' :  'todos'
        '#main' :       'main'

    events:
        'keyup #new-todo' :     'new'
        'click #toggle-all' :   'toggleAll'

    constructor : ->
        super
        Todo.bind 'create', @addNew
        Todo.bind 'refresh change', @toggleElems
        Todo.fetch()

    new : (e) ->
        val = $.trim @newTodoInput.val()
        if e.which is ENTER_KEY and val
            Todo.create title : val
            @newTodoInput.val ''

    addNew : (todo) =>
        view = new Todos todo : todo
        @todos.append view.render().el

    toggleAll : (e) ->
        Todo.each (todo) ->
            todo.updateAttribute 'completed', e.target.checked
            todo.trigger 'update', todo

    toggleElems : =>
        isTodos = !!Todo.count()
        @main.toggle isTodos
        @toggleAllElem.removeAttr 'checked' if !Todo.completed().length
        
$ ->
    new TodoApp el : $('#todoapp')
    Spine.Route.setup()

    