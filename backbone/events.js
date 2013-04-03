var Backbone = {}

// メソッドチェインがサポートされるので全部 this 返してくるよ！

var Events = Backbone.Events = {
    /*
        nameはstringかobject(マップ型で渡されることもある)
     */
    on: function(name, callback, context) {
        // eventsApiに聞いてみて、オーバーロードされてる形ならあとはeventsApiに任せる
        if(!eventsApi(this, 'on', name, [callback, context]) || !callback) return this;

        // eventsApiか、きれいな形で呼び出されたとき (not 複数 and マップ)
        // イベントを登録する
        this._events || (this._events = {}); // _eventsなかったら作る

        // すでに同じ名前のイベントがあったらそのArray、なければその名前で新しいArrayを作ってアサイン 
        var events = this._events[name] || (this._events[name] = []);       
    
        // イベントを登録
        // ctxがよくわからん、なかった時用？？？
        events.push({callback: callbacl, context: context, ctx: context || this});

        return this;
    }

}

var eventSplitter = /\s+/;

// いろいんな形式で送られてくるので、それを変換する。ようするにオーバーロード用っぽい
// actionには呼び出し元のメソッド名が入ってくる
// たとえば Events.on から来たときに引数を解決して Events.on を呼び直す、みたいな動きをする
//
// これ以下は action = on だと仮定する
var eventsApi = function(obj, action, name, rest) {
    if (!name) return true; // 名前ないとか論外

    // マップ形式だったら
    if (typeof name === "object") {
        for (var key in name) {
            /*
            自身の on を呼び直す
            マップ形式
            {
                'name' : callback 
            }
            なので on(name , callback , context) となるようにして全部呼び直す 
            この場合はonのcallbackにはcontextが入っているはずなので(わたってくるのが[context, undefned])、
            結果として on(name , callback , context, undefined) が on(name , callback , context) になる。
            ちょっとトリッキー
            */
            obj[action].apply(obj, [key, name[key]].concat(rest));

            // マップ形式だったので失敗 == 呼び直した、と返す
            return false;
        }
    }

    // 複数名前が ("hoge fuga piyo") 含まれているときは
    if(eventSplitter.test(name)) {
        var names = name.split(eventSplitter);
        for(var i = 0, l = names.length; i < l; i++) {
            /*
            自身の on を呼び出す
            複数なのでsplitして１個づつ呼び直す
            この場合はcallbackはrestに含まれているので、nameだけ設定してconcatすると
            on(name, callback, context) となる
            */
            obj[action].apply(obj, [names[i]].concat(rest));
        }
    }

    // ここまできた場合は一番シンプルな形 on('hoge', callback, context) で呼び出されているときなので、
    // それぞれの処理をお願いするために成功させる
    return true;
}

// ---------- Copy from backbone -------------- //

$(document).ready(function() {

  module("Backbone.Events");

  test("on and trigger", 2, function() {
    var obj = { counter: 0 };
    _.extend(obj,Backbone.Events);
    obj.on('event', function() { obj.counter += 1; });
    obj.trigger('event');
    equal(obj.counter,1,'counter should be incremented.');
    obj.trigger('event');
    obj.trigger('event');
    obj.trigger('event');
    obj.trigger('event');
    equal(obj.counter, 5, 'counter should be incremented five times.');
  });

  test("binding and triggering multiple events", 4, function() {
    var obj = { counter: 0 };
    _.extend(obj, Backbone.Events);

    obj.on('a b c', function() { obj.counter += 1; });

    obj.trigger('a');
    equal(obj.counter, 1);

    obj.trigger('a b');
    equal(obj.counter, 3);

    obj.trigger('c');
    equal(obj.counter, 4);

    obj.off('a c');
    obj.trigger('a b c');
    equal(obj.counter, 5);
  });

  test("binding and triggering with event maps", function() {
    var obj = { counter: 0 };
    _.extend(obj, Backbone.Events);

    var increment = function() {
      this.counter += 1;
    };

    obj.on({
      a: increment,
      b: increment,
      c: increment
    }, obj);

    obj.trigger('a');
    equal(obj.counter, 1);

    obj.trigger('a b');
    equal(obj.counter, 3);

    obj.trigger('c');
    equal(obj.counter, 4);

    obj.off({
      a: increment,
      c: increment
    }, obj);
    obj.trigger('a b c');
    equal(obj.counter, 5);
  });

  test("listenTo and stopListening", 1, function() {
    var a = _.extend({}, Backbone.Events);
    var b = _.extend({}, Backbone.Events);
    a.listenTo(b, 'all', function(){ ok(true); });
    b.trigger('anything');
    a.listenTo(b, 'all', function(){ ok(false); });
    a.stopListening();
    b.trigger('anything');
  });

  test("listenTo and stopListening with event maps", 4, function() {
    var a = _.extend({}, Backbone.Events);
    var b = _.extend({}, Backbone.Events);
    var cb = function(){ ok(true); };
    a.listenTo(b, {event: cb});
    b.trigger('event');
    a.listenTo(b, {event2: cb});
    b.on('event2', cb);
    a.stopListening(b, {event2: cb});
    b.trigger('event event2');
    a.stopListening();
    b.trigger('event event2');
  });

  test("stopListening with omitted args", 2, function () {
    var a = _.extend({}, Backbone.Events);
    var b = _.extend({}, Backbone.Events);
    var cb = function () { ok(true); };
    a.listenTo(b, 'event', cb);
    b.on('event', cb);
    a.listenTo(b, 'event2', cb);
    a.stopListening(null, {event: cb});
    b.trigger('event event2');
    b.off();
    a.listenTo(b, 'event event2', cb);
    a.stopListening(null, 'event');
    a.stopListening();
    b.trigger('event2');
  });

  test("listenToOnce and stopListening", 1, function() {
    var a = _.extend({}, Backbone.Events);
    var b = _.extend({}, Backbone.Events);
    a.listenToOnce(b, 'all', function() { ok(true); });
    b.trigger('anything');
    b.trigger('anything');
    a.listenToOnce(b, 'all', function() { ok(false); });
    a.stopListening();
    b.trigger('anything');
  });

  test("listenTo, listenToOnce and stopListening", 1, function() {
    var a = _.extend({}, Backbone.Events);
    var b = _.extend({}, Backbone.Events);
    a.listenToOnce(b, 'all', function() { ok(true); });
    b.trigger('anything');
    b.trigger('anything');
    a.listenTo(b, 'all', function() { ok(false); });
    a.stopListening();
    b.trigger('anything');
  });

  test("listenTo and stopListening with event maps", 1, function() {
    var a = _.extend({}, Backbone.Events);
    var b = _.extend({}, Backbone.Events);
    a.listenTo(b, {change: function(){ ok(true); }});
    b.trigger('change');
    a.listenTo(b, {change: function(){ ok(false); }});
    a.stopListening();
    b.trigger('change');
  });

  test("listenTo yourself", 1, function(){
    var e = _.extend({}, Backbone.Events);
    e.listenTo(e, "foo", function(){ ok(true); });
    e.trigger("foo");
  });

  test("listenTo yourself cleans yourself up with stopListening", 1, function(){
    var e = _.extend({}, Backbone.Events);
    e.listenTo(e, "foo", function(){ ok(true); });
    e.trigger("foo");
    e.stopListening();
    e.trigger("foo");
  });

  test("listenTo with empty callback doesn't throw an error", 1, function(){
    var e = _.extend({}, Backbone.Events);
    e.listenTo(e, "foo", null);
    e.trigger("foo");
    ok(true);
  });

  test("trigger all for each event", 3, function() {
    var a, b, obj = { counter: 0 };
    _.extend(obj, Backbone.Events);
    obj.on('all', function(event) {
      obj.counter++;
      if (event == 'a') a = true;
      if (event == 'b') b = true;
    })
    .trigger('a b');
    ok(a);
    ok(b);
    equal(obj.counter, 2);
  });

  test("on, then unbind all functions", 1, function() {
    var obj = { counter: 0 };
    _.extend(obj,Backbone.Events);
    var callback = function() { obj.counter += 1; };
    obj.on('event', callback);
    obj.trigger('event');
    obj.off('event');
    obj.trigger('event');
    equal(obj.counter, 1, 'counter should have only been incremented once.');
  });

  test("bind two callbacks, unbind only one", 2, function() {
    var obj = { counterA: 0, counterB: 0 };
    _.extend(obj,Backbone.Events);
    var callback = function() { obj.counterA += 1; };
    obj.on('event', callback);
    obj.on('event', function() { obj.counterB += 1; });
    obj.trigger('event');
    obj.off('event', callback);
    obj.trigger('event');
    equal(obj.counterA, 1, 'counterA should have only been incremented once.');
    equal(obj.counterB, 2, 'counterB should have been incremented twice.');
  });

  test("unbind a callback in the midst of it firing", 1, function() {
    var obj = {counter: 0};
    _.extend(obj, Backbone.Events);
    var callback = function() {
      obj.counter += 1;
      obj.off('event', callback);
    };
    obj.on('event', callback);
    obj.trigger('event');
    obj.trigger('event');
    obj.trigger('event');
    equal(obj.counter, 1, 'the callback should have been unbound.');
  });

  test("two binds that unbind themeselves", 2, function() {
    var obj = { counterA: 0, counterB: 0 };
    _.extend(obj,Backbone.Events);
    var incrA = function(){ obj.counterA += 1; obj.off('event', incrA); };
    var incrB = function(){ obj.counterB += 1; obj.off('event', incrB); };
    obj.on('event', incrA);
    obj.on('event', incrB);
    obj.trigger('event');
    obj.trigger('event');
    obj.trigger('event');
    equal(obj.counterA, 1, 'counterA should have only been incremented once.');
    equal(obj.counterB, 1, 'counterB should have only been incremented once.');
  });

  test("bind a callback with a supplied context", 1, function () {
    var TestClass = function () {
      return this;
    };
    TestClass.prototype.assertTrue = function () {
      ok(true, '`this` was bound to the callback');
    };

    var obj = _.extend({},Backbone.Events);
    obj.on('event', function () { this.assertTrue(); }, (new TestClass));
    obj.trigger('event');
  });

  test("nested trigger with unbind", 1, function () {
    var obj = { counter: 0 };
    _.extend(obj, Backbone.Events);
    var incr1 = function(){ obj.counter += 1; obj.off('event', incr1); obj.trigger('event'); };
    var incr2 = function(){ obj.counter += 1; };
    obj.on('event', incr1);
    obj.on('event', incr2);
    obj.trigger('event');
    equal(obj.counter, 3, 'counter should have been incremented three times');
  });

  test("callback list is not altered during trigger", 2, function () {
    var counter = 0, obj = _.extend({}, Backbone.Events);
    var incr = function(){ counter++; };
    obj.on('event', function(){ obj.on('event', incr).on('all', incr); })
    .trigger('event');
    equal(counter, 0, 'bind does not alter callback list');
    obj.off()
    .on('event', function(){ obj.off('event', incr).off('all', incr); })
    .on('event', incr)
    .on('all', incr)
    .trigger('event');
    equal(counter, 2, 'unbind does not alter callback list');
  });

  test("#1282 - 'all' callback list is retrieved after each event.", 1, function() {
    var counter = 0;
    var obj = _.extend({}, Backbone.Events);
    var incr = function(){ counter++; };
    obj.on('x', function() {
      obj.on('y', incr).on('all', incr);
    })
    .trigger('x y');
    strictEqual(counter, 2);
  });

  test("if no callback is provided, `on` is a noop", 0, function() {
    _.extend({}, Backbone.Events).on('test').trigger('test');
  });

  test("if callback is truthy but not a function, `on` should throw an error just like jQuery", 1, function() {
    var view = _.extend({}, Backbone.Events).on('test', 'noop');
    throws(function() {
      view.trigger('test');
    });
  });

  test("remove all events for a specific context", 4, function() {
    var obj = _.extend({}, Backbone.Events);
    obj.on('x y all', function() { ok(true); });
    obj.on('x y all', function() { ok(false); }, obj);
    obj.off(null, null, obj);
    obj.trigger('x y');
  });

  test("remove all events for a specific callback", 4, function() {
    var obj = _.extend({}, Backbone.Events);
    var success = function() { ok(true); };
    var fail = function() { ok(false); };
    obj.on('x y all', success);
    obj.on('x y all', fail);
    obj.off(null, fail);
    obj.trigger('x y');
  });

  test("#1310 - off does not skip consecutive events", 0, function() {
    var obj = _.extend({}, Backbone.Events);
    obj.on('event', function() { ok(false); }, obj);
    obj.on('event', function() { ok(false); }, obj);
    obj.off(null, null, obj);
    obj.trigger('event');
  });

  test("once", 2, function() {
    // Same as the previous test, but we use once rather than having to explicitly unbind
    var obj = { counterA: 0, counterB: 0 };
    _.extend(obj, Backbone.Events);
    var incrA = function(){ obj.counterA += 1; obj.trigger('event'); };
    var incrB = function(){ obj.counterB += 1; };
    obj.once('event', incrA);
    obj.once('event', incrB);
    obj.trigger('event');
    equal(obj.counterA, 1, 'counterA should have only been incremented once.');
    equal(obj.counterB, 1, 'counterB should have only been incremented once.');
  });

  test("once variant one", 3, function() {
    var f = function(){ ok(true); };

    var a = _.extend({}, Backbone.Events).once('event', f);
    var b = _.extend({}, Backbone.Events).on('event', f);

    a.trigger('event');

    b.trigger('event');
    b.trigger('event');
  });

  test("once variant two", 3, function() {
    var f = function(){ ok(true); };
    var obj = _.extend({}, Backbone.Events);

    obj
      .once('event', f)
      .on('event', f)
      .trigger('event')
      .trigger('event');
  });

  test("once with off", 0, function() {
    var f = function(){ ok(true); };
    var obj = _.extend({}, Backbone.Events);

    obj.once('event', f);
    obj.off('event', f);
    obj.trigger('event');
  });

  test("once with event maps", function() {
    var obj = { counter: 0 };
    _.extend(obj, Backbone.Events);

    var increment = function() {
      this.counter += 1;
    };

    obj.once({
      a: increment,
      b: increment,
      c: increment
    }, obj);

    obj.trigger('a');
    equal(obj.counter, 1);

    obj.trigger('a b');
    equal(obj.counter, 2);

    obj.trigger('c');
    equal(obj.counter, 3);

    obj.trigger('a b c');
    equal(obj.counter, 3);
  });

  test("once with off only by context", 0, function() {
    var context = {};
    var obj = _.extend({}, Backbone.Events);
    obj.once('event', function(){ ok(false); }, context);
    obj.off(null, null, context);
    obj.trigger('event');
  });

  test("Backbone object inherits Events", function() {
    ok(Backbone.on === Backbone.Events.on);
  });

  asyncTest("once with asynchronous events", 1, function() {
    var func = _.debounce(function() { ok(true); start(); }, 50);
    var obj = _.extend({}, Backbone.Events).once('async', func);

    obj.trigger('async');
    obj.trigger('async');
  });

  test("once with multiple events.", 2, function() {
    var obj = _.extend({}, Backbone.Events);
    obj.once('x y', function() { ok(true); });
    obj.trigger('x y');
  });

  test("Off during iteration with once.", 2, function() {
    var obj = _.extend({}, Backbone.Events);
    var f = function(){ this.off('event', f); };
    obj.on('event', f);
    obj.once('event', function(){});
    obj.on('event', function(){ ok(true); });

    obj.trigger('event');
    obj.trigger('event');
  });

  test("`once` on `all` should work as expected", 1, function() {
    Backbone.once('all', function() {
      ok(true);
      Backbone.trigger('all');
    });
    Backbone.trigger('all');
  });

  test("once without a callback is a noop", 0, function() {
    _.extend({}, Backbone.Events).once('event').trigger('event');
  });

  test("event functions are chainable", function() {
    var obj = _.extend({}, Backbone.Events);
    var obj2 = _.extend({}, Backbone.Events);
    var fn = function() {};
    equal(obj, obj.trigger('noeventssetyet'));
    equal(obj, obj.off('noeventssetyet'));
    equal(obj, obj.stopListening('noeventssetyet'));
    equal(obj, obj.on('a', fn));
    equal(obj, obj.once('c', fn));
    equal(obj, obj.trigger('a'));
    equal(obj, obj.listenTo(obj2, 'a', fn));
    equal(obj, obj.listenToOnce(obj2, 'b', fn));
    equal(obj, obj.off('a c'));
    equal(obj, obj.stopListening(obj2, 'a'));
    equal(obj, obj.stopListening());
  });

});