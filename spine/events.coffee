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
        return @bind ev, ->
            # 呼ばれたらunbindするラッパー
            @unbind(ev, arguments.callee)
            callback.apply(this, arguments)

    ###
    # 発火
    ###
    trigger: (args...) ->
        # 一つ目にイベント名が入っている
        ev = args.shift()

        # _callbacksからcallbackのリストを取ってくる、無かったら何もしない
        list = @hasOwnProperty('_callbacks') and @_callbacks?[ev]
        return unless list

        for callback in list
            # 失敗したらやめる
            if callback.apply(this, args) is false
                break

        return true

    ###
    # あるオブジェクトのイベントを監視する other.on のエイリアスでもある
    # 実際には other(s) への参照を保存していて、こっち側からもイベントを消すことができる
    ### 
    listenTo: (obj, ev, callback) ->
        obj.bind(ev, callback)
        # this.listeningToに対象をもっておく、なければ作る
        # stopされるために使われる
        @listeningTo or= []
        @listeningTo.push(obj)
        return this

    ###
    # listenToの1回版
    # 仕様がちょっと微妙(だった)、というのも、１回も使われていない状態でstopListeningされても消えない
    # 修正済み
    ###
    listenToOnce: (obj, ev, callback) ->
        # こっちは単なるエイリアス
        # これだと、stopListeing() で全部消せなくね？と思うが、そういう仕様なのか？ -> ちがった、なおした
        obj.one(ev, callback)
        return this

    ###
    # 監視を破棄
    # このメソッド、listenする前に呼ばれると死にますね -> なおした！！！！！！！！
    ### 
    stopListening: (obj, ev, callback) ->
        # 対象のオブジェクトのものだけ消す or 全部消す
        # これオブジェクトに意図せずnullがはいったときに、全部消されるね？
        # オーバーロード罰・・・ -> なおした
        if obj
            # objがある場合はそのオブジェクトのイベントを外す
            obj.unbind(ev, callback)
            # @listeningToからもはずす
            idx = @listeningTo.indexOf(obj)
            @listeningTo.splice(idx, 1) unless idx is -1
        else
            # objが指定されていない場合は@listeningToのを全部消す
            for obj in @listeningTo
                obj.unbind()
            # undefined いれてリセット []の方がよくね
            @listeningTo = undefined

    ###
    # イベントの登録を解除、2段階オーバーロードしているのでちょっと複雑
    # オーバーロードがあんまりよくなかったのでわしがなおした Looks good は頂いたが取り込まれるかは不明
    ###
    unbind: (ev, callback) ->
        unless ev # ちなみにこのオーバーロードは死にます
            # オーバーロード
            # 何も指定されずに呼ばれたら、全部リセット
            @_callbacks = {}
            return this
        # 複数登録への対応
        evs = ev.split(' ')
        for name in evs
            list = @_callbacks?[name]
            # 対応するcallbackがなければcontinue
            continue unless list

            # オーバーロード
            # callbackが指定されていない場合は、全部削除(プロパティごと落とす)
            unless callback
                delete @_callbacks[name]
                continue

            # 対象のコールバックを探す
            for cb, i in list when (cd is callback)
                # 見つかったので、削除してbreak
                list = list.slice()
                list.splice(i, 1)
                @_callbacks[name] = list
                break;
        this


