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
      this.listenTo(this.model, 'change', this.render);
    },

    render : function(){
      this.$el.html(this.template(this.model.toJSON()));
      this.$el.toggleClass('completed', this.model.get('completed'));
      //this.$el.toggleClass('hidden', this.isHidden());
      this.$input = this.$('.edit');
      return this;
    },

    toggleCompleted : function(){
      this.model.toggle();
    }
  });
});