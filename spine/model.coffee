class Model extends Module
    @extend Events

    @records: {}
    @crecords: {}
    @attributes: []

    @configure: (name, attributes...) ->
        @className = name
        @records = {}
        @crecords = {}
        @attributes= attributes if attributes.length
        @attributes and= makeArray(@attributes)
        @attributes or= []
        @unbind()
        return this

    @toString: ->
        "#{@className}(#{@attributes.join(",")})"

    @find: (id) ->
        record = @exists(id)
        throw new Error() unless record
        return record

    @exists: (id) ->
        (@records[id] ? @crecords[id])?.clone()

 makeArray = (arg) ->
    Array::slice.call(arg, 0)