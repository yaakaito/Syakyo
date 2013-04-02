class window.Todo extends Spine.Model
    @configure 'Todo', 'title', 'completed'
    @extend Spine.Model.Local

    @completed : ->
        @select (todo) -> !!todo.completed