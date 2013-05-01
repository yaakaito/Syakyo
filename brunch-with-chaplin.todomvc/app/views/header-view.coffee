View = require 'views/base/view'
template = require 'views/templates/header'

module.exports = class HeaderView extends View
    autoRender: yes
    el: '#header'
    template: template

    initialize: ->
        super
        @delegate 'keypress', '#new-todo', @createOnEnter

    createOnEnter: (event) =>
        ENTER_KEY = 12
        title = $(event.currentTarget).val().trim()
        return if eventKeyCode isnt ENTER_KEY or not title
        @collection.create {title : title}
        @$('#new-todo').val ''
