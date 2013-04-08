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

    @refresh: (values, options = {}) ->
        if options.clear
            @records  = {}
            @crecords = {}

        records = @fromJSON(values)
        records = [records] unless isArray(records)

        for record in records
            record.id            or= record.cid
            @records[record.id]    = record
            @crecords[records.cid] = record

        @trigger 'refresh', @cloneArray(records)
        return this

    @select: (callback) ->
        result = (record for id, record of @records when callback(record))
        @cloneArray(result)

    @findByAttribute: (name, value) ->
        for id, record of @records
            if record[name] is value
                return record.clone()
        return null

    @findAllbyAttribute: (name, value) ->
        @select (item) ->
            item[name] is value

 makeArray = (arg) ->
    Array::slice.call(arg, 0)