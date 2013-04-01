/* global Backbone */

var app = app || {};

$(function($){
  'use strict';

  app.AppView = Backbone.View.extend({
    el : '#todoapp',
    statsTemplate : _.template($('#stats-template').html()),
    events : {
      'keypress #new-todo' : 'createOnEnter',
      'click #toggle-all'  : 'toggleAllComplete'
    },

    initialize : function() {
      this.allCheckbox = this.$('#toggle-all')[0];
      this.$input = this.$('#new-todo');
      this.$main  = this.$('#main');
      this.$footer = this.$('#footer');

      this.listenTo(app.Todos, 'add', this.addOne);
      this.listenTo(app.Todos, 'filter', this.filterAll);
      this.listenTo(app.Todos, 'change:completed', this.filterOne);

      app.Todos.fetch();

      this.render(); // 気に入らないので足した
    },

    render : function(){
      this.$footer.show();
      this.$footer.html(this.statsTemplate({
        completed : app.Todos.completed().length,
        remaining : app.Todos.remaining().length
      }));

      // Highlight selected filter link
      this.$('#filters li a')
        .removeClass('selected')
        .filter('[href="#/' + (app.TodoFilter || '') + '"]')
        .addClass('selected');
    },


    addOne: function(todo){
      var view = new app.TodoView({ model : todo });
      $('#todo-list').append(view.render().el);
    },

    filterOne : function(todo){
      todo.trigger('visible');
      this.render();// 気に入らないので足した
    },

    filterAll : function(){
      app.Todos.each(this.filterOne, this);
      this.render(); // 気に入らないので足した
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