/* global Backbone */

var app = app || {};

$(function() {
  'use strict';

  app.TodoView = Backbone.View.extend({
    tagName : 'li',
    template : _.template($('#item-template').html()),

    events : {
      'click .toggle' : 'toggleCompleted'
    },

    initialize : function(){
      this.listenTo(this.model, 'destroy', this.remove);
      this.listenTo(this.model, 'change', this.render);
      this.listenTo(this.model, 'visible', this.toggleVisible);
    },

    render : function(){
      this.$el.html(this.template(this.model.toJSON()));
      this.$el.toggleClass('completed', this.model.get('completed'));
      this.toggleVisible();
      this.$input = this.$('.edit');
      return this;
    },

    toggleVisible : function(){
      this.$el.toggleClass('hidden', this.isHidden());
    },

    isHidden : function(){
      var isCompleted = this.model.get('completed');
      return (
        (!isCompleted && app.TodoFilter === 'completed') ||
        (isCompleted && app.TodoFilter === 'active')
      );
    },

    toggleCompleted : function(){
      this.model.toggle();
    }
  });
});