###
動作メモ

共通
  既にキューに格納されている動画はキューに入れようとしても無視される

タブ
  ニコニコ動画の動画再生ページが2タブ開かれている場合
    新たに動画ページが開かれた場合、そのURLをキューに格納してタブを閉じる
      既にタブで開かれている動画をキューに入れようとした場合はキャンセル
  ニコニコ動画の動画再生ページが0〜1タブの場合
    キューに格納されている動画が開かれた場合、キューから該当するURLを削除

ブラウザアクション
  ニコニコ動画の動画再生ページが0〜1タブの場合
    キューに動画が入っていれば、新規タブでその動画を開く

コンテキストメニュー(リンク先をNicoQueueに格納)
  リンク先のURLをキューに格納
    既にタブで開かれている動画をキューに入れようとした場合はキャンセル

コンテキストメニュー(NicoQueueに格納)
  該当するタブをキューに格納して閉じる



内部的な事に関するメモ

chrome.tabs -> current_tabs -> queue -> update_badge
chrome.browserAction -> queue -> update_badge
chrome.contextMenus -> queue -> update_badge

URLはchrome.*部で整形する
###

do ->
  fix_url = (url) ->
    url.replace(/[?#].*$/, "")

  update_badge = (queue_length) ->
    text = if queue_length is 0 then "" else queue_length.toString(10)
    chrome.browserAction.setBadgeText(text: text)
    return

  notice = (title, text) ->
    title = title or document.title
    return if webkitNotifications.checkPermission() isnt 0
    notification = webkitNotifications.createNotification("", title, text)
    notification.show()
    setTimeout((-> notification.cancel()), 3000)
    return

  queue =
    push: (url) ->
      data = JSON.parse(localStorage["queue"] or "[]")

      unless url in data
        data.push(url)
        localStorage["queue"] = JSON.stringify(data)
        update_badge(data.length)
        notice(null, url + "をキューに追加しました")

      length: data.length
    pop: ->
      data = JSON.parse(localStorage["queue"] or "[]")
      if data.length > 0
        res =
          url: data.shift()
          length: data.length
        localStorage["queue"] = JSON.stringify(data)
        update_badge(res.length)
        res
      else
        url: null
        length: 0
    remove: (url) ->
      data = JSON.parse(localStorage["queue"] or "[]")
      if url in data
        data.splice(data.indexOf(url), 1)
        localStorage["queue"] = JSON.stringify(data)
        update_badge(this.length)
      return
  queue.__defineGetter__ "length", ->
    JSON.parse(localStorage["queue"] or "[]").length

  is_target = (url) ->
    target_pref = "http://www.nicovideo.jp/watch/"
    url.slice(0, target_pref.length) is target_pref

  current_tabs = null
  do ->
    tabs = {}
    tabs_length = 0

    current_tabs =
      add: (tab_id, tab_url) ->
        if is_target(tab_url) and not tabs[tab_id]
          tabs[tab_id] = tab_url
          tabs_length++

          if tabs_length >= 3
            queue.push(tab_url)
            chrome.tabs.remove(tab_id)
          else
            queue.remove(tab_url)
        return
      update: (tab_id, tab_url) ->
        if tabs[tab_id] and not is_target(tab_url)
          @remove(tab_id)
        else
          @add(tab_id, tab_url)
        return
      remove: (tab_id) ->
        if tabs[tab_id]
          delete tabs[tab_id]
          tabs_length--
        return
      contains: (url) ->
        for tab_url of tabs
          return true if tab_url is url
        false
    current_tabs.__defineGetter__ "length", ->
      tabs_length
    return

  if not /\/test\.html$/.test(location.href)
    update_badge(queue.length)

    chrome.windows.getAll {populate: true}, (array_of_window) ->
      for win in array_of_window
        for tab in win
          current_tabs.add(tab.id, fix_url(tab.url))

      chrome.tabs.onCreated.addListener (tab) ->
        current_tabs.add(tab.id, fix_url(tab.url))
        return

      chrome.tabs.onRemoved.addListener (tab_id) ->
        current_tabs.remove(tab_id)
        return

      chrome.tabs.onUpdated.addListener (tab_id, info) ->
        if info.url?
          current_tabs.update(tab_id, fix_url(info.url))
        return

    chrome.contextMenus.create
      title: "NicoQueueに格納"
      documentUrlPatterns: [
        "http://www.nicovideo.jp/watch/*"
      ]
      onclick: (info, tab) ->
        queue.push(fix_url(tab.url))
        chrome.tabs.remove(tab.id)
        return

    chrome.contextMenus.create
      title: "リンク先をNicoQueueに格納"
      contexts: ["link"]
      targetUrlPatterns: [
        "http://www.nicovideo.jp/watch/*"
      ]
      onclick: (info, tab) ->
        url = fix_url(info.linkUrl)
        return if current_tabs.contains(url)
        queue.push(url)
        return

    chrome.browserAction.onClicked.addListener (tab) ->
      if current_tabs.length < 2 and (url = queue.pop().url)
        chrome.tabs.getSelected null, (tab) ->
          chrome.tabs.create(url: url, index: tab.index + 1)
          return
      return
  else
    window.app = {fix_url, queue}
  return
