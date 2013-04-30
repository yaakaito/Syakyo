Todos = require 'models/todos'
Todos = require 'models/todos'

describe 'Todos', ->
  beforeEach ->
    @model = new Todos()
    @collection = new Todos()

  afterEach ->
    @model.dispose()
    @collection.dispose()
