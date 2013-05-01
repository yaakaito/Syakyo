CollectionView = require 'views/base/collection-view'
Todos = require 'views/todos-view'

module.exports = class TodosView extends CollectionView
    itemView: TodoView
    listSelector: '#todo-list'
    template: template

    initialize: ->
        super
        @subscribeEvent 'todos:clear', @clear
        @modelBind 'all', @renderCheckbox
        @delegate 'click', '#toggle-all', @toggleCompleted

    render: =>
        super
        @renderCheckbox()

    renderCheckbox: =>
        @$('#toggle-all').prop 'checked', @collection.AllAreCompleted
        @$el.toggle(@collection.length isnt 0)

    toggleComplated: (event) =>
        isChecked = event.currentTarget.checked
        @collection.each (todo) -> todo.save completed: isChecked

    clear: ->
        @collection.getCompleted().forEach (medel) ->
            model.destroy()