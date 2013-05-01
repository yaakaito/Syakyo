Controller = require 'controllers/base/controller'
TodosView = require 'view/todos-view'

module.exports = class TodosController extends Controller
    initialize: ->
        super
        @view = new TodosView collection: mediator.todos