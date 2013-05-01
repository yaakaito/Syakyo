Controller = require 'controllers/base/controller'

module.exports = class HeadersController extends Controller
    initialize: ->
        super
        @view = new HeaderView collection: mediator.todos