/* global Backbone */

var app = app || {};

(function(){

  /*
   * Todo Collection
   */
   var Todos = Backbone.Collection.extend({
    model : app.Todo,
    localStorage : new Backbone.LocalStorage('todos-backbone'),
   
    completed :  function(){
      return this.filter(function(todo){
        return todo.get('completed');
      });
    },

    remaining : function(){
      return this.without.apply(this, this.completed());
    },

    nextOrder : function(){
      if(!this.length) {
        return 1;
      }
      return parseInt(this.last().get('order'), 10) + 1;
    },

    comparator: function(todo) {
      return todo.get('order');
    }
   });

   // singleton
   app.Todos = new Todos();
})();
