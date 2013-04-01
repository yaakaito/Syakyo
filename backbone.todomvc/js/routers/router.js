/* global Backbone */

var app = app || {};

(function(){
  'use strict';

  var Workspace = Backbone.Router.extend({
    routes : {
      '*filter' : 'setFilter'
    },

    setFilter : function(param) {
      app.TodoFilter = param || '';
      app.Todos.trigger('filter'); // 気に入らない
    }
  });

  app.TodoRouter = new Workspace();
  Backbone.history.start();
})();