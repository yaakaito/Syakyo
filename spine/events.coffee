Events =
    ###
    # イベント登録
    # 自身に対して this._callbacks : func[] を作って、そこに追加していく
    ###
    bind: (ev, callback) ->
        # 複数登録のパターンなら分割して一個ずつ ex: 'a b c'
        evs     = ev.split(' ')
        # なかったら作ってから取得
        calls   = @hasOwnProperty('_callbacks') and @_callbacks or= {}
        for name in evs
            # 対応するものがなければ作る
            calls[name] or = []
            # 登録
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
