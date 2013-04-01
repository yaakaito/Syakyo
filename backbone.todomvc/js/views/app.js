/* global Backbone */

var app = app || {};

$(function($){
  'use strict';

  app.AppView = Backbone.View.extend({
    el : '#todoapp',
    events : {
      'keypress #new-todo' : 'createOnEnter',
      'click #toggle-all'  : 'toggleAllComplete'
    },

    initialize : function() {
      this.allCheckbox = this.$('#toggle-all')[0];
      this.$input = this.$('#new-todo');
      this.$main  = this.$('#main');

      this.listenTo(app.Todos, 'add', this.addOne);

    },


    addOne: function(todo){
      var view = new app.TodoView({ model : todo });
      $('#todo-list').append(view.render().el);
    },

    createOnEnter : function(e) {
      if (e.which !== ENTER_KEY || !this.$input.val().trim()) {
        return;
      }

      app.Todos.create({
        title : this.$input.val().trim(),
        order : app.Todos.nextOrder(),
        completed : false
      });
      this.$input.val('');
    },

    toggleAllComplete : function() {
      var completed = this.allCheckbox.checked;
      app.Todos.each(function(todo){
        todo.save({ 'completed' : completed });
      });
    }
  });

});