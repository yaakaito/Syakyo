/* global Backbone */

var app = app || {};

$(function($){
  'use strict';

  app.AppView = Backbone.View.extend({
    el : '#todoapp',
  });
});