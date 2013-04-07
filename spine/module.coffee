
# ベースクラス的な

moduleKeywords = ['include', 'extended']

class Module
    # プロトタイプへ追加
    @include: (obj) ->
        throw new Error('include (obj) requires obj') unless obj
        for key, value of obj when key not in moduleKeywords
            @::[key] = value
        obj.extended?.apply(this)
        return this

    # 自身へ追加
    @extend: (obj) ->
        throw new Error('extend (obj) requires obj') unless obj
        for key, value of obj when key not in moduleKeywords
            @[key] = value
        obj.extended?.apply(this)
        return this

    @proxy: (func) ->
        => func.apply(this, arguments)

    proxy: (func) ->
        => func.apply(this, arguments)

    constructor: ->
        @init?(arguments)
