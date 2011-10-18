console.log app

module("fix_url")

test "URLからクエリとハッシュを削除する", 4, ->
  url = "http://www.nicovideo.jp/watch/sm1"
  strictEqual(app.fix_url(url), url)
  strictEqual(app.fix_url(url + "#test"), url)
  strictEqual(app.fix_url(url + "?test"), url)
  strictEqual(app.fix_url(url + "?test#test"), url)

module "queue"
  setup: ->
    if localStorage.queue?
      this._queue = localStorage.queue
      delete localStorage.queue
  teardown: ->
    if this._queue?
      localStorage.queue = this._queue
    else
      delete localStorage.queue

test "任意のURLをキューに追加出来る", 13, ->
  url1 = "http://www.nicovideo.jp/watc9/sm1"
  url2 = "http://example.com/"

  app.queue.push(url1)
  strictEqual(app.queue.length, 1)
  strictEqual(localStorage.queue, """["#{url1}"]""")

  app.queue.push(url2)
  strictEqual(app.queue.length, 2)
  strictEqual(localStorage.queue, """["#{url1}","#{url2}"]""")

  deepEqual(app.queue.pop(), {url: url1, length: 1})
  strictEqual(app.queue.length, 1)
  strictEqual(localStorage.queue, """["#{url2}"]""")

  deepEqual(app.queue.pop(), {url: url2, length: 0})
  strictEqual(app.queue.length, 0)
  strictEqual(localStorage.queue, """[]""")

  deepEqual(app.queue.pop(), {url: null, length: 0})
  strictEqual(app.queue.length, 0)
  strictEqual(localStorage.queue, """[]""")

test "キューが空の場合にqueue.popした場合は、urlがnullになる", 2, ->
  deepEqual(app.queue.pop(), {url: null, length: 0})
  strictEqual(app.queue.length, 0)
