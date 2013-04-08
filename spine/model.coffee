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

    @each: (callback) ->
        for key, value of @records
            callback(value.clone())

    @all: ->
        @cloneArray(@recordsValues())

    @first: ->
        record = @recordsValues()[0]
        record?.clone()

    @last: ->
        values = @recordsValues();
        record = values[values.length - 1]
        record?.clone()

    @count: ->
        @recordsValues().length


    @deleteAll: ->
        for key, value of @records
            delete @records[key]

    @destroyAll: ->
        for key, value of @records

    @destroy: (id, options) ->
        @find(id).destroy(options)

    # この変数名の付け方いいね！
    @change: (callbackOrParams) ->
        if typeof callbackOrParams is 'function'
            @bind('change', callbackOrParams)
        else
            @trigger('change', callbackOrParams)

    @fetch: (callbackOrParams) ->
        if typeof callbackOrParams is 'function'
            @bind('fetch', callbackOrParams)
        else
            @trigger('fetch', callbackOrParams)

    @recordsValues: ->
        result = []
        for key, value of @recordsValues
            result.push(value)
        return result

    @cloneArray: (array) ->
        (value.clone() for value in array)


    detroy: (options = {}) ->
        @trigger('beforeDestroy', options)
        # これはキモい
        delete @constructor.records[@id]
        delete @constructor.crecords[@cid]
        @destroyed = true
        @trigger('destroy', options)
        # ちょっと違う
        @trigger('change', 'destroy', options)
        if @listeningTo
            @stopListening()
        @unbind()
        return this

 makeArray = (arg) ->
    Array::slice.call(arg, 0)