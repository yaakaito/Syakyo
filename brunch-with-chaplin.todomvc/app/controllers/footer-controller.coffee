Controller = require 'controllers/base/controller'
FooterView = require 'view/footer-view'

module.exports = class FootersController extends Controller
    initialize: ->
        super
        @view = new FooterView collection: mediator.todos