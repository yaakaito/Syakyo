###
# モデルとコレクションがハイブリッドになってると思えば良い
# クラスプロパティ/メソッドはこのモデルのコレクション
# それ以外のものはインスタンス
# で、recordという概念があって、ここにインスタンスが入っている
###
class Model extends Module
    # 個々のインスタンスはEventsは継承していなくて、最終的にこのEventsに集約されている
    @extend Events

    # ここには実際のモデルのインスタンスが入っている
    @records: {}
    # 作ったときのレコード？
    @crecords: {}


    @attributes: []

    # モデルの設定
    # @configure 'Hoge', 'x', 'y' とするとHogeという名前でxとyというプロパティを持ったモデルになるイメージ
    @configure: (name, attributes...) ->
        @className = name
        # リセットとか
        @records = {}
        @crecords = {}

        # arrributesの登録
        # 一旦バインドしてから配列に変換するのかー
        # これに関しては素直に if とかが分かりやすい気がするなぁ
        @attributes= attributes if attributes.length
        @attributes and= makeArray(@attributes)
        @attributes or= []

        # イベントを全部削除
        @unbind()
        return this

    @toString: ->
        "#{@className}(#{@attributes.join(",")})"

    # idから対象のモデルを取得
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

    # 条件をもとに、モデルの配列のクローンを生成する
    @select: (callback) ->
        result = (record for id, record of @records when callback(record))
        @cloneArray(result)

    # attributesにあるvalueがセットされているかでセレクトする。
    # 最初にマッチしたものだけ返る
    # allから返ってきた物の[0]でよい気がするが、パフォーマンスなのかな
    @findByAttribute: (name, value) ->
        for id, record of @records
            if record[name] is value
                return record.clone()
        return null

    # attributesにあるvalueがセットされているものをすべてセレクトする
    @findAllbyAttribute: (name, value) ->
        @select (item) ->
            item[name] is value

    # each
    @each: (callback) ->
        for key, value of @records
            callback(value.clone())

    # すべてのモデルのクローンを取得
    @all: ->
        @cloneArray(@recordsValues())

    # セレクト系のメソッド、クローンされたものが返ってくる
    @first: ->
        record = @recordsValues()[0]
        record?.clone()

    @last: ->
        values = @recordsValues();
        record = values[values.length - 1]
        record?.clone()

    # 今のモデルの個数
    @count: ->
        @recordsValues().length

    # モデルのインスタンスを作成する
    @create: (atts, options) ->
        record = new @(atts)
        # saveに成功すると対象のオブジェクトが返される
        # 失敗した場合は false が返される
        return record.save(options)

    # 対象のidに対するattributeのアップデート
    @update: (id, atts, options) ->
        @find(id).updateAttributes(atts, options)

    # とにかくすべて破棄する、イベントが呼ばれない
    # = {} でも良い気がするが
    @deleteAll: ->
        for key, value of @records
            delete @records[key]

    # destory経由ですべて破棄する、イベントが飛ぶ
    @destroyAll: (options) ->
        for key, value of @records
            @records[key].destroy(options)

    # 対象idのモデルを破棄する
    @destroy: (id, options) ->
        @find(id).destroy(options)

    # callbackならコレクションに対するchangeイベントを登録
    # パラメーターならイベントを発火する
    # この変数名の付け方いいね！
    @change: (callbackOrParams) ->
        if typeof callbackOrParams is 'function'
            @bind('change', callbackOrParams)
        else
            @trigger('change', callbackOrParams)

    # callbackならコレクションに対するfetchイベントを登録
    # パラメーターならイベントを発火する
    @fetch: (callbackOrParams) ->
        if typeof callbackOrParams is 'function'
            @bind('fetch', callbackOrParams)
        else
            @trigger('fetch', callbackOrParams)

    # モデルをJSONに変換
    @toJSON: ->
        @recordsValues()

    # マップ形式になっているものをモデルの配列へ変換する
    @recordsValues: ->
        result = []
        for key, value of @recordsValues
            result.push(value)
        return result

    # 配列のクローン
    @cloneArray: (array) ->
        (value.clone() for value in array)

    # ユニークなidの発行
    @uid: (prefix = '') ->
        uid = prefix + @idCounter++
        uid = @uid(prefix) if @exists(uid) # 被った場合は再帰的に作る
        return uid 

    # Instance

    constructor: (atts) ->
        super
        @load atts if atts
        @cid = @constructor.uid('c-')

    # attsからプロパティを設定する
    load: (atts) ->
        # idが指定されている場合はidを利用する
        if atts.id then @id = atts.id
        for key, value of atts
            if atts.hasOwnProperty(key) and typeof @[key] is 'function'
                # すでに存在するfunctionなら実行するのかー
                @[key](value)
            else
                @[key] = value
        return this

    # new == セーブ(create)されてない状態
    isNew: ->
        not @exists()

    isValid: ->
        not @validate()

    validate: ->
        # テンプレートメソッド

    # attributeの取り出し
    # テンプレートとか、toJSONとか、クローン作るときにはここからattributeだけコピーされる感じ
    attributes: ->
        result = {}
        # attributesに定義されている値を取り出す
        for key in @constructor.attributes when key of this
            if typeof @[key] is 'function'
                # functionなら実行した結果を
                result[key] = @[key]()
            else
                result[key] = @[key]
        result.id = @id if @id
        return result

    # アアアアアア？？？？
    eql: (rec) ->
        !!(rec and rec.constructor is @constructor and
            (rec.cid is @cid) or (rec.id and rec.id is @id))

    save: (options = {}) ->
        # validateが通っていないものなら先にvalidateを通す
        unless options.validate is false
            error = @validate()
            if error
                @trigger('error', error)
                return false

        @trigger('beforeSave', options)
        # まだsaveされてないものだったらcreate
        # すでにあったらupdateする
        record = if @isNew() then @create(options) else @update(options)
        @stripCloneAttrs()
        @trigger('save', options)
        return record

    # attributesに登録されているもの以外を削除する
    stripCloneAttrs: ->
        return if @hasOwnProperty 'cid'
        for own key, value of @
            delete @[key] if @constructor.attributes.indexOf(key) > -1
        return this

    # 単体アップデート用のラッパー、複数アップデートへ変換
    # ちゃんと分けてるの偉いと思う
    updateAttribute: (name, value, options) ->
        atts = {}
        atts[name] = value
        @updateAttributes(atts, options)

    # attrbiuteのアップデート、load -> save
    updateAttributes: (atts, options) ->
        @load(atts)
        @save(options)

    # idを上書きする 保存して消すだけ
    changeID: (id) ->
        records = @constructor.records
        records[id] = records[@id]
        delete records[@id]
        @id = id 
        save()

    # 自身を破棄する、結構きわどい
    detroy: (options = {}) ->

        # destroy前のフック用イベントかな？
        @trigger('beforeDestroy', options)

        # @records あたりから削除する
        # これはキモい
        delete @constructor.records[@id]
        delete @constructor.crecords[@cid]

        # destroyされたステータスに
        @destroyed = true

        # destroyを通知
        @trigger('destroy', options)

        # changeをdestroyとして通知
        @trigger('change', 'destroy', options)

        # イベントリスナーはずす
        if @listeningTo
            @stopListening()
        @unbind()
        return this

    dup: (newRecord) ->
        result = new @constructor(@attributes())
        if newRecord is false
            result.cid = @cid
        else 
            delete result.id
        return result

    clone: ->
        createObject(this)

    reload: ->
        return this if @isNew()
        original = @constructor.find(@id)
        @load(original.attributes())
        # えっ・・・・
        return original

    toJSON: ->
        @attributes()

    toString: ->
        "<#{@constructor.className} {#{JSON.stringify(this)}}>"

    # レコードに対してアップデートをかける
    update: (options) ->
        @trigger('beforeUpdate', options)

        # 実データに対してアップデート
        records = @construcor.records
        records[@id].load @attributes()

        # 操作するのはクローン
        clone = records[@id].clone()
        clone.trigger('update', options)
        clone.trigger('change', 'update', options)
        return clone

    create:(options) ->
        @trigger('beforeCreate', options)
        @id = @cid unless @id

        # 登録用にクローンを作る
        record =  @dup(false)
        # 登録する
        @constructor.records[@id] = record
        # 作ったときのレコード情報
        @constructor.crecords[@cid] = record

        clone = record.clone()
        clone.trigger('create', options)
        clone.trigger('change', 'create', options)
        return clone

 makeArray = (arg) ->
    Array::slice.call(arg, 0)

createObject = Object.create or (o) ->
    Func = ->
    Func.prototype = 0
    new Func()