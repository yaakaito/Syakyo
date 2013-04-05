Events =
    bind: (ev, callback) ->
        evs     = ev.split(' ')
        calls   = @hasOwnProperty('_callbacks') and @_callbacks or= {}
        for name in evs
            calls[name] or = []
            calls[name].push(callback)
        return this

    ###
    # 一回だけ登録
    # 呼ばれたらunbindするfunctionでラップしている
    ###
    one: (ev, callback) ->
        @bind ev, ->
            @unbind(ev, arguments.callee)
            callback.apply(this, arguments)
