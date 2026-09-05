
{} (:about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --full` first. Manual edits must follow format and schema conventions, then run `calcit edit format`.") (:package |app)
  :entries $ {}
    :default $ {} (:description |) (:init-fn 'app.client/main!) (:mode :js) (:reload-fn 'app.client/reload!)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |lilac/ |recollect/ |memof/ |respo-ui.calcit/ |ws-edn.calcit/ |cumulo-util.calcit/ |respo-message.calcit/ |cumulo-reel.calcit/ |alerts.calcit/
      :type-slots $ {}
    :server $ {} (:description |) (:init-fn 'app.server/main!) (:mode :native) (:reload-fn 'app.server/reload!)
      :feature-policy $ {}
      :modules $ [] |lilac/ |recollect/ |memof/ |cumulo-util.calcit/ |cumulo-reel.calcit/ |calcit.std/ |calcit-wss/
      :type-slots $ {}
  :files $ {}
    'app.client $ %{} 'FileEntry
      :defs $ {}
        '*states $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defatom *states $ {}
              :states $ {}
                :cursor $ []
          :examples $ []
          :schema $ :: 'Dynamic
        '*store $ %{} 'CodeEntry (:doc |)
          :code $ quote (defatom *store nil)
          :examples $ []
          :schema $ :: 'Dynamic
        'connect! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn connect! () $ let
                url-obj $ url-parse js/location.href true
                host $ either (-> url-obj .-query .-host) js/location.hostname
                port $ either (-> url-obj .-query .-port) (:port config/site)
              ws-connect! (str |ws:// host |: port)
                {}
                  :on-open $ fn (event) (simulate-login!)
                  :on-close $ fn (event) (reset! *store nil) (js/console.error "|Lost connection!")
                  :on-data on-server-data
          :examples $ []
          :schema $ :: 'Dynamic
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn dispatch! (op op-data)
              when
                and config/dev? $ not= op :states
                println |Dispatch op op-data
              case-default op
                ws-send! $ {} (:kind :op) (:op op) (:data op-data)
                :states $ reset! *states (update-states @*states op-data)
                :effect/connect $ connect!
          :examples $ []
          :schema $ :: 'Dynamic
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn main! () (load-console-formatter!)
              println "|Running mode:" $ if config/dev? |dev |release
              render-app!
              connect!
              add-watch *store :changes $ fn (store prev) (render-app!)
              add-watch *states :changes $ fn (states prev) (render-app!)
              on-page-touch $ fn ()
                if (nil? @*store) (connect!)
              println "|App started!"
          :examples $ []
          :schema $ :: 'Dynamic
        'mount-target $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def mount-target $ .querySelector js/document |.app
          :examples $ []
          :schema $ :: 'Dynamic
        'on-server-data $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn on-server-data (data)
              case-default (:kind data) (println "|unknown server data kind:" data)
                :patch $ let
                    changes $ :data data
                  when config/dev? $ js/console.log |Changes (to-js-data changes)
                  reset! *store $ patch-twig @*store changes
          :examples $ []
          :schema $ :: 'Dynamic
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn reload! () $ if
              or $ some? client-errors
              tip! |error client-errors
              do (tip! |ok~ nil) (remove-watch *store :changes) (remove-watch *states :changes) (clear-cache!) (render-app!)
                add-watch *store :changes $ fn (store prev) (render-app!)
                add-watch *states :changes $ fn (states prev) (render-app!)
                println "|Code updated."
          :examples $ []
          :schema $ :: 'Dynamic
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn render-app! () $ render! mount-target
              comp-container (:states @*states) @*store
              , dispatch!
          :examples $ []
          :schema $ :: 'Dynamic
        'simulate-login! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn simulate-login! () $ let
                raw $ .!getItem js/localStorage (:storage-key config/site)
              if (some? raw)
                do (println "|Found storage.")
                  dispatch! :user/log-in $ parse-cirru-edn raw
                do $ println "|Found no storage."
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.client $ :require
            respo.core :refer $ render! clear-cache! realize-ssr!
            respo.cursor :refer $ update-states
            app.comp.container :refer $ comp-container
            app.schema :as schema
            app.config :as config
            ws-edn.client :refer $ ws-connect! ws-send!
            recollect.patch :refer $ patch-twig
            cumulo-util.core :refer $ on-page-touch
            |url-parse :default url-parse
            |bottom-tip :default tip!
            |./calcit.build-errors :default client-errors
    'app.comp.container $ %{} 'FileEntry
      :defs $ {}
        'comp-card-header $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-card-header (name idx)
              div
                {} $ :style
                  merge ui/row-parted $ {}
                    :border-bottom $ str "|1px solid " (hsl 0 0 90)
                    :padding "|0 8px"
                span $ {}
                <> $ str name
                span $ {} (:inner-text "|✕")
                  :style $ {}
                    :color $ hsl 0 80 70
                    :cursor :pointer
                  :on-click $ fn (e d!) (d! :stack/close idx)
          :examples $ []
          :schema $ :: 'Dynamic
        'comp-container $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-container (states store)
              let
                  state $ either (:data states)
                    {} $ :demo |
                  session $ :session
                    either store $ {}
                  router $ either
                    :router $ either store ({})
                    {}
                  router-data $ :data router
                if (nil? store) (comp-offline)
                  div
                    {} $ :style (merge ui/global ui/fullscreen ui/row)
                    if (:logged-in? store)
                      case-default (:name router) (<> router)
                        :home $ comp-stack (>> states :stack) (:stack store)
                        :profile $ comp-profile (:user store) (:data router)
                      comp-login $ >> states :login
                    =- :v
                    comp-navigation (:logged-in? store) (:count store)
                    comp-status-color $ :color store
                    when dev? $ comp-inspect |Store store
                      {} (:bottom 80) (:left 0) (:max-width |100%)
                    comp-messages
                      get-in store $ [] :session :messages
                      {}
                      fn (info d!) (d! :session/remove-message info)
                    when dev? $ comp-reel (:reel-length store) ({})
          :examples $ []
          :schema $ :: 'Dynamic
        'comp-offline $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-offline () $ div
              {} $ :style
                merge ui/global ui/fullscreen ui/column-dispersive $ {}
                  :background-color $ :theme config/site
              div $ {}
                :style $ {} (:height 0)
              div $ {}
                :style $ {}
                  :background-image $ str "|url(" (:icon config/site) "|)"
                  :width 128
                  :height 128
                  :background-size :contain
              div
                {}
                  :style $ {} (:cursor :pointer) (:line-height |32px)
                  :on-click $ fn (e d!) (d! :effect/connect nil)
                <> "|No connection..." $ {} (:font-family ui/font-fancy) (:font-size 24)
          :examples $ []
          :schema $ :: 'Dynamic
        'comp-stack $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-stack (states stack)
              list->
                {} $ :style (merge ui/expand ui/row)
                -> stack
                  map-indexed $ fn (idx router)
                    [] idx $ div
                      {} $ :style
                        merge ui/column $ {} (:width 400) (:height |100%)
                          :border-right $ str "|1px solid " (hsl 0 0 90)
                      comp-card-header (:name router) idx
                      case-default (:name router) (comp-unknown-card router)
                        :topics $ comp-topics (>> states :chat) (:data router)
                        :topic $ comp-topic
                          >> states $ str :topic
                            get-in router $ [] :data :id
                          :data router
                  concat $ []
                    [] 999 $ comp-start
          :examples $ []
          :schema $ :: 'Dynamic
        'comp-start $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-start () $ div
              {} $ :style
                {} $ :padding "|16px 40px"
              div ({}) (<> |Start...)
              =< nil 16
              div ({})
                button $ {} (:style ui/button) (:inner-text "|Open Chat")
                  :on-click $ fn (e d!)
                    d! :stack/add $ {} (:name :topics)
              div ({})
                button $ {} (:style ui/button) (:inner-text "|Open Threads")
                  :on-click $ fn (e d!) (println |TODO)
              div ({})
                button $ {} (:style ui/button) (:inner-text "|Open Wiki")
                  :on-click $ fn (e d!) (println |TODO)
              div ({})
                button $ {} (:style ui/button) (:inner-text "|Open Tags")
                  :on-click $ fn (e d!) (println |TODO)
              div ({})
                button $ {} (:style ui/button) (:inner-text "|Open Votes")
                  :on-click $ fn (e d!) (println |TODO)
          :examples $ []
          :schema $ :: 'Dynamic
        'comp-status-color $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-status-color (color)
              div $ {}
                :style $ let
                    size 24
                  {} (:width size) (:height size) (:position :absolute) (:bottom 60) (:left 8) (:background-color color) (:border-radius |50%) (:opacity 0.6) (:pointer-events :none)
          :examples $ []
          :schema $ :: 'Dynamic
        'comp-topic $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-topic (states topic)
              let
                  cursor $ :cursor states
                  state $ or (:data states)
                    {} $ :draft |
                div
                  {} $ :style
                    merge ui/expand ui/column $ {}
                      :border-top $ str "|1px solid " (hsl 0 0 88)
                  div
                    {} $ :style
                      {} $ :padding 8
                    span $ {}
                      :inner-text $ or (:content topic) |-
                  div
                    {} $ :style
                      {} (:padding 8)
                        :border-bottom $ str "|1px solid " (hsl 0 0 90)
                    <>
                      str |@ $ get-in topic ([] :author :nickname)
                      {} $ :color (hsl 0 0 50)
                    =< 8 nil
                    <>
                      -> (:time topic) (dayjs) (.!format |HH:mm)
                      {}
                        :color $ hsl 0 0 70
                        :font-weight 300
                        :font-family ui/font-fancy
                  div
                    {} $ :style
                      merge ui/expand $ {}
                    list-> ({})
                      ->
                        option:unwrap-or (get topic :replies) ({})
                        .to-list
                        .sort-by $ fn (x)
                          :time $ nth x 1
                        map $ fn (pair)
                          &let
                            reply $ nth pair 1
                            [] (nth pair 0)
                              div
                                {} $ :style
                                  {} (:padding |8px)
                                    :border-bottom $ str "|1px solid " (hsl 0 0 90)
                                div ({})
                                  <> $ str |@
                                    get-in reply $ [] :author :nickname
                                  =< 8 nil
                                  <> $ -> (:time reply) (dayjs) (.!format |HH:mm)
                                div ({})
                                  <> $ :content (wo-log reply)
                    =< nil 80
                  div
                    {} $ :style
                      merge ui/row $ {}
                        :border-top $ str "|1px solid " (hsl 0 0 90)
                    textarea $ {}
                      :style $ merge ui/expand ui/textarea
                      :value $ :draft state
                      :placeholder |Reply...
                      :on-change $ fn (e d!)
                        d! cursor $ assoc state :draft (:value e)
                    =< 8 nil
                    div ({})
                      button $ {} (:inner-text |Send) (:style ui/button)
                        :on-click $ fn (e d!)
                          let
                              content $ .trim
                                option:unwrap-or (get state :draft) |
                            when
                              not $ .blank? content
                              d! :topic/reply $ {}
                                :topic-id $ :id topic
                                :text content
                              d! cursor $ assoc state :draft |
          :examples $ []
          :schema $ :: 'Dynamic
        'comp-topic-item $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-topic-item (topic)
              div
                {} $ :style
                  {} (:padding 8)
                    :border-top $ str "|1px solid " (hsl 0 0 88)
                div ({})
                  span $ {}
                    :inner-text $ or (:content topic) |-
                    :on-click $ fn (e d!)
                      d! :stack/add $ {} (:name :topic)
                        :data $ :id topic
                div ({})
                  <>
                    str |@ $ get-in topic ([] :author :nickname)
                    {} $ :color (hsl 0 0 50)
                  =< 8 nil
                  <>
                    -> (:time topic) (dayjs) (.format |HH:mm)
                    {}
                      :color $ hsl 0 0 70
                      :font-weight 300
                      :font-family ui/font-fancy
          :examples $ []
          :schema $ :: 'Dynamic
        'comp-topics $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-topics (states data)
              let
                  cursor $ :cursor states
                  state $ or (:data states) ({})
                  create-plugin $ use-prompt (>> states :new)
                    {} $ :title "|Create Topic"
                div
                  {} $ :style
                    merge ui/expand ui/column $ {}
                  div
                    {} $ :style
                      merge ui/row-middle $ {}
                        ; :border-bottom $ str "|1px solid " (hsl 0 0 90)
                        :padding "|4px 8px"
                    <> |Topics
                    =< 16 nil
                    a $ {} (:style ui/link) (:inner-text |New)
                      :on-click $ fn (e d!)
                        .show create-plugin d! $ fn (text) (d! :topic/add text)
                  div
                    {} $ :style ui/expand
                    list->
                      {} $ :style
                        {} $ :border-bottom
                          str "|1px solid " $ hsl 0 0 80
                      -> data
                        or $ {}
                        .to-list
                        .sort-by $ fn (pair)
                          negate $ :time (last pair)
                        .map $ fn (pair)
                          [] (first pair)
                            comp-topic-item $ last pair
                    =< nil 100
                  .render create-plugin
          :examples $ []
          :schema $ :: 'Dynamic
        'comp-unknown-card $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-unknown-card (router)
              div
                {} $ :style
                  merge ui/column $ {} (:width 400) (:height |100%)
                    :border-right $ str "|1px solid " (hsl 0 0 90)
                div ({}) (<> "|Unknown card")
                pre ({})
                  code $ {}
                    :inner-text $ format-cirru-edn router
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.comp.container $ :require
            respo.util.format :refer $ hsl
            respo-ui.core :as ui
            respo.core :refer $ defcomp <> >> div span button input textarea pre list-> a code
            respo.comp.inspect :refer $ comp-inspect
            respo.comp.space :refer $ =<
            app.comp.navigation :refer $ comp-navigation
            app.comp.profile :refer $ comp-profile
            app.comp.login :refer $ comp-login
            respo-message.comp.messages :refer $ comp-messages
            cumulo-reel.comp.reel :refer $ comp-reel
            app.config :refer $ dev?
            app.schema :as schema
            app.config :as config
            |dayjs :default dayjs
            respo-alerts.core :refer $ use-prompt
            app.comp.widget :refer $ =-
    'app.comp.login $ %{} 'FileEntry
      :defs $ {}
        'comp-login $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-login (states)
              let
                  cursor $ :cursor states
                  state $ or (:data states) initial-state
                div
                  {} $ :style (merge ui/flex ui/center)
                  div ({})
                    div
                      {} $ :style ({})
                      div ({})
                        input $ {} (:placeholder |Username)
                          :value $ :username state
                          :style ui/input
                          :on-input $ fn (e d!)
                            d! cursor $ assoc state :username (:value e)
                      =< nil 8
                      div ({})
                        input $ {} (:placeholder |Password)
                          :value $ :password state
                          :style ui/input
                          :on-input $ fn (e d!)
                            d! cursor $ assoc state :password (:value e)
                    =< nil 8
                    div
                      {} $ :style
                        {} $ :text-align :right
                      span $ {} (:inner-text "|Sign up")
                        :style $ merge ui/link
                        :on-click $ on-submit (:username state) (:password state) true
                      =< 8 nil
                      span $ {} (:inner-text "|Log in")
                        :style $ merge ui/link
                        :on-click $ on-submit (:username state) (:password state) false
          :examples $ []
          :schema $ :: 'Dynamic
        'initial-state $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def initial-state $ {} (:username |) (:password |)
          :examples $ []
          :schema $ :: 'Dynamic
        'on-submit $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn on-submit (username password signup?)
              fn (e dispatch!)
                dispatch! (if signup? :user/sign-up :user/log-in) ([] username password)
                .setItem js/localStorage (:storage-key config/site)
                  format-cirru-edn $ [] username password
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.comp.login $ :require
            respo.core :refer $ defcomp <> div input button span
            respo.comp.space :refer $ =<
            respo.comp.inspect :refer $ comp-inspect
            respo-ui.core :as ui
            app.schema :as schema
            app.config :as config
    'app.comp.navigation $ %{} 'FileEntry
      :defs $ {}
        'comp-navigation $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-navigation (logged-in? count-members)
              div
                {} $ :style
                  merge ui/column-parted $ {} (:width 64) (:justify-content :space-between) (:padding "|0 16px") (:font-size 16) (:font-family ui/font-fancy)
                div
                  {} $ :style ui/column
                  div
                    {}
                      :on-click $ fn (e d!)
                        d! :router/change $ {} (:name :home)
                      :style $ {} (:cursor :pointer)
                    <> |Ploy nil
                div
                  {}
                    :style $ merge ui/row
                      {} $ :cursor |pointer
                    :on-click $ fn (e d!)
                      d! :router/change $ {} (:name :profile)
                  <> $ if logged-in? |Me |Guest
                  =< 4 nil
                  <> count-members
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.comp.navigation $ :require
            respo.util.format :refer $ hsl
            respo-ui.core :as ui
            respo.comp.space :refer $ =<
            respo.core :refer $ defcomp <> span div
            app.config :as config
    'app.comp.profile $ %{} 'FileEntry
      :defs $ {}
        'comp-profile $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defcomp comp-profile (user members)
              div
                {} $ :style
                  merge ui/flex $ {} (:padding 16)
                div
                  {} $ :style
                    {} (:font-family ui/font-fancy) (:font-size 32) (:font-weight 100)
                  <> $ str "|Hello! " (:name user)
                =< nil 16
                div
                  {} $ :style ui/row
                  <> |Members:
                  =< 8 nil
                  list->
                    {} $ :style ui/row
                    -> members (.to-list)
                      map $ fn (pair)
                        let[] (k username) pair $ [] k
                          div
                            {} $ :style
                              {} (:padding "|0 8px")
                                :border $ str "|1px solid " (hsl 0 0 80)
                                :border-radius |16px
                                :margin "|0 4px"
                            <> username
                =< nil 48
                div ({})
                  button
                    {}
                      :style $ merge ui/button
                      :on-click $ fn (e d!)
                        js/location.replace $ str js/location.origin |?time= (.now js/Date)
                    <> |Refresh
                  =< 8 nil
                  button
                    {}
                      :style $ merge ui/button
                        {} (:color :red) (:border-color :red)
                      :on-click $ fn (e dispatch!) (dispatch! :user/log-out nil)
                        .removeItem js/localStorage $ :storage-key config/site
                    <> "|Log out"
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.comp.profile $ :require
            respo.util.format :refer $ hsl
            app.schema :as schema
            respo-ui.core :as ui
            respo.core :refer $ defcomp list-> <> span div button
            respo.comp.space :refer $ =<
            app.config :as config
    'app.comp.widget $ %{} 'FileEntry
      :defs $ {}
        '=- $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn =- (direction ? style)
              div $ {}
                :style $ merge
                  {} $ :background-color (hsl 0 0 88)
                  if (= direction :v)
                    {} (:width 1) (:height |100%)
                    {} (:height 1) (:width |100%)
                  , style
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.comp.widget $ :require
            respo-ui.core :refer $ hsl
            respo.core :refer $ defcomp <> >> div span button input textarea
    'app.config $ %{} 'FileEntry
      :defs $ {}
        'dev? $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def dev? $ = |dev (get-env |mode)
          :examples $ []
          :schema $ :: 'Dynamic
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def site $ {} (:port 11026) (:title |Polygonum) (:icon |http://cdn.tiye.me/logo/cumulo.png) (:theme |#eeeeff) (:storage-key |polygonum) (:storage-file |storage.cirru)
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote (ns app.config)
    'app.schema $ %{} 'FileEntry
      :defs $ {}
        'database $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def database $ {}
              :sessions $ do session ({})
              :users $ do user ({})
              :topics $ do topic ({})
          :examples $ []
          :schema $ :: 'Dynamic
        'reply $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def reply $ {} (:id nil) (:content |) (:author-id |) (:time nil)
          :examples $ []
          :schema $ :: 'Dynamic
        'router $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def router $ {} (:name nil) (:title nil)
              :data $ {}
              :router nil
          :examples $ []
          :schema $ :: 'Dynamic
        'session $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def session $ {} (:user-id nil) (:id nil) (:nickname nil)
              :router $ do router
                {} (:name :home) (:data nil) (:router nil)
              :messages $ {}
              :stack $ do stack ([])
          :examples $ []
          :schema $ :: 'Dynamic
        'stack $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def stack $ {} (:name nil) (:data nil)
          :examples $ []
          :schema $ :: 'Dynamic
        'topic $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def topic $ {} (:id nil) (:content |) (:time nil)
              :replies $ do reply ({})
              :author-id nil
          :examples $ []
          :schema $ :: 'Dynamic
        'user $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def user $ {} (:name nil) (:id nil) (:nickname nil) (:avatar nil) (:password nil)
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote (ns app.schema)
    'app.server $ %{} 'FileEntry
      :defs $ {}
        '*client-caches $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defatom *client-caches $ {}
          :examples $ []
          :schema $ :: 'Dynamic
        '*initial-db $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defatom *initial-db $ if
              path-exists? $ w-log storage-file
              do (println "|Found local EDN data")
                merge schema/database $ parse-cirru-edn (read-file storage-file)
              do (println "|Found no data") schema/database
          :examples $ []
          :schema $ :: 'Dynamic
        '*proxied-dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote (defatom *proxied-dispatch! dispatch!)
          :examples $ []
          :schema $ :: 'Dynamic
        '*reader-reel $ %{} 'CodeEntry (:doc |)
          :code $ quote (defatom *reader-reel @*reel)
          :examples $ []
          :schema $ :: 'Dynamic
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defatom *reel $ merge reel-schema
              {} (:base @*initial-db) (:db @*initial-db)
          :examples $ []
          :schema $ :: 'Dynamic
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn dispatch! (op op-data sid)
              let
                  op-id $ generate-id!
                  op-time $ str (get-time!)
                if config/dev? $ println |Dispatch! (str op) op-data sid
                if (= op :effect/persist) (persist-db!)
                  reset! *reel $ reel-reducer @*reel updater op op-data sid op-id op-time config/dev?
          :examples $ []
          :schema $ :: 'Dynamic
        'get-backup-path! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn get-backup-path! () $ let
                now $ extract-time (get-time!)
              join-path calcit-dirname |backups
                str $ :month now
                str (:day now) |-snapshot.cirru
          :examples $ []
          :schema $ :: 'Dynamic
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn main! ()
              println "|Running mode:" $ if config/dev? |dev |release
              let
                  p? $ get-env |port
                  port $ if (some? p?) (js/parseInt p?) (:port config/site)
                run-server! port
                println $ str "|Server started on port:" port
              do (; "|init it before doing multi-threading") (identity @*reader-reel)
              set-interval 200 $ fn () (render-loop!)
              set-interval 600000 $ fn () (persist-db!)
              on-control-c on-exit!
          :examples $ []
          :schema $ :: 'Dynamic
        'on-exit! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn on-exit! () (persist-db!) (; println "|exit code is...") (quit! 0)
          :examples $ []
          :schema $ :: 'Dynamic
        'persist-db! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn persist-db! () $ let
                file-content $ format-cirru-edn
                  assoc (:db @*reel) :sessions $ {}
                storage-path storage-file
                backup-path $ get-backup-path!
              check-write-file! storage-path file-content
              check-write-file! backup-path file-content
          :examples $ []
          :schema $ :: 'Dynamic
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn reload! () (println "|Code updated..")
              if (not config/dev?) (raise "|reloading only happens in dev mode")
              clear-twig-caches!
              reset! *reel $ refresh-reel @*reel @*initial-db updater
              sync-clients! @*reader-reel
          :examples $ []
          :schema $ :: 'Dynamic
        'render-loop! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn render-loop! () $ when
              not $ identical? @*reader-reel @*reel
              reset! *reader-reel @*reel
              sync-clients! @*reader-reel
          :examples $ []
          :schema $ :: 'Dynamic
        'run-server! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn run-server! (port)
              wss-serve! (&{} :port port)
                fn (data)
                  match data
                    (:connect sid)
                      do (dispatch! :session/connect nil sid) (println "|New client.")
                    (:message sid msg)
                      let
                          action $ parse-cirru-edn msg
                        case-default (&map:get action :kind) (println "|unknown action:" action)
                          :op $ dispatch! (&map:get action :op) (&map:get action :data) sid
                    (:disconnect sid)
                      do (println "|Client closed!") (dispatch! :session/disconnect nil sid)
                    _ $ println "|unknown data:" data
          :examples $ []
          :schema $ :: 'Dynamic
        'storage-file $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def storage-file $ if (empty? calcit-dirname)
              str calcit-dirname $ :storage-file config/site
              str calcit-dirname |/ $ :storage-file config/site
          :examples $ []
          :schema $ :: 'Dynamic
        'sync-clients! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn sync-clients! (reel)
              wss-each! $ fn (sid)
                let
                    db $ :db reel
                    records $ :records reel
                    session $ get-in db ([] :sessions sid)
                    old-store $ or (get @*client-caches sid) nil
                    new-store $ twig-container db session records
                    changes $ diff-twig old-store new-store
                      {} $ :key :id
                  ; when config/dev? $ println "|Changes for" sid |: changes (count records)
                  if
                    not= changes $ []
                    do
                      wss-send! sid $ format-cirru-edn
                        {} (:kind :patch) (:data changes)
                      swap! *client-caches assoc sid new-store
              new-twig-loop!
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.server $ :require (app.schema :as schema)
            app.updater :refer $ updater
            cumulo-reel.core :refer $ reel-reducer refresh-reel reel-schema
            app.config :as config
            app.twig.container :refer $ twig-container
            recollect.diff :refer $ diff-twig
            recollect.twig :refer $ new-twig-loop! clear-twig-caches!
            wss.core :refer $ wss-serve! wss-send! wss-each!
            app.$meta :refer $ calcit-dirname
            calcit.std.fs :refer $ path-exists? check-write-file!
            calcit.std.time :refer $ set-interval
            calcit.std.date :refer $ get-time! extract-time
            calcit.std.path :refer $ join-path
    'app.twig.container $ %{} 'FileEntry
      :defs $ {}
        'twig-container $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn twig-container (db session records)
              let
                  logged-in? $ some? (:user-id session)
                  router $ :router session
                  base-data $ {} (:logged-in? logged-in?) (:session session)
                    :reel-length $ count records
                merge base-data $ if logged-in?
                  {}
                    :user $ twig-user
                      get-in db $ [] :users (:user-id session)
                    :router $ assoc router :data
                      case (:name router)
                        :home $ -> (:messages db) (.to-map)
                          map-kv $ fn (k v)
                            [] k $ assoc v :author
                              twig-user $ get-in db
                                [] :users $ :author-id v
                        :profile $ twig-members (:sessions db) (:users db)
                        (:name router) ({})
                    :stack $ if
                      = :home $ get router :name
                      -> (:stack session)
                        or $ []
                        map $ fn (router)
                          assoc router :data $ case-default (:name router)
                            {} $ :original-data router
                            :topic $ let
                                topic $ get-in db
                                  [] :topics $ :data router
                              if (some? topic)
                                -> topic
                                  assoc :author $ twig-user
                                    get-in db $ [] :users (:author-id topic)
                                  update :replies $ fn (replies)
                                    -> replies (.to-map)
                                      map-kv $ fn (k v)
                                        [] k $ assoc v :author
                                          twig-user $ get-in db
                                            [] :users $ :author-id v
                                , nil
                            :topics $ -> (:topics db) (.to-map)
                              map-kv $ fn (k v)
                                [] k $ assoc v :author
                                  twig-user $ get-in db
                                    [] :users $ :author-id v
                      []
                    :count $ count (:sessions db)
                    :color $ rand-hex-color!
                  {}
          :examples $ []
          :schema $ :: 'Dynamic
        'twig-members $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn twig-members (sessions users)
              -> sessions (.to-list)
                map $ fn (pair)
                  let[] (k session) pair $ [] k
                    get-in users $ [] (:user-id session) :name
                pairs-map
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.twig.container $ :require
            app.twig.user :refer $ twig-user
            calcit.std.rand :refer $ rand-hex-color!
    'app.twig.user $ %{} 'FileEntry
      :defs $ {}
        'twig-user $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn twig-user (user) (dissoc user :password)
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.twig.user $ :require
    'app.updater $ %{} 'FileEntry
      :defs $ {}
        'updater $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn updater (db op op-data sid op-id op-time)
              let
                  session $ get-in db ([] :sessions sid)
                  user $ if (some? session)
                    get-in db $ [] :users (:user-id session)
                  f $ case-default op
                    fn (& args) (println "|Unknown op:" op) db
                    :session/connect session/connect
                    :session/disconnect session/disconnect
                    :session/remove-message session/remove-message
                    :user/log-in user/log-in
                    :user/sign-up user/sign-up
                    :user/log-out user/log-out
                    :router/change router/change
                    :stack/add router/add-stack
                    :stack/close router/close-stack
                    :topic/add topic/add-topic
                    :topic/reply topic/add-reply
                f db op-data sid op-id op-time
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.updater $ :require (app.updater.session :as session) (app.updater.user :as user) (app.updater.router :as router) (app.updater.topic :as topic) (app.schema :as schema)
            respo-message.updater :refer $ update-messages
    'app.updater.router $ %{} 'FileEntry
      :defs $ {}
        'add-stack $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn add-stack (db op-data sid op-id op-time)
              update-in db ([] :sessions sid :stack)
                fn (s) (conj s op-data)
          :examples $ []
          :schema $ :: 'Dynamic
        'change $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn change (db op-data sid op-id op-time)
              assoc-in db ([] :sessions sid :router) op-data
          :examples $ []
          :schema $ :: 'Dynamic
        'close-stack $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn close-stack (db op-data sid op-id op-time)
              update-in db ([] :sessions sid :stack)
                fn (s) (dissoc s op-data)
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote (ns app.updater.router)
    'app.updater.session $ %{} 'FileEntry
      :defs $ {}
        'connect $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn connect (db op-data sid op-id op-time)
              assoc-in db ([] :sessions sid)
                merge schema/session $ {} (:id sid)
          :examples $ []
          :schema $ :: 'Dynamic
        'disconnect $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn disconnect (db op-data sid op-id op-time)
              update db :sessions $ fn (session) (dissoc session sid)
          :examples $ []
          :schema $ :: 'Dynamic
        'remove-message $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn remove-message (db op-data sid op-id op-time)
              update-in db ([] :sessions sid :messages)
                fn (messages)
                  dissoc messages $ :id op-data
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.updater.session $ :require (app.schema :as schema)
    'app.updater.topic $ %{} 'FileEntry
      :defs $ {}
        'add-reply $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn add-reply (db op-data sid op-id op-time)
              let
                  user-id $ get-in db ([] :sessions sid :user-id)
                assoc-in db
                  [] :topics (:topic-id op-data) :replies op-id
                  merge schema/reply $ {} (:id op-id) (:time op-time)
                    :content $ :text op-data
                    :author-id user-id
          :examples $ []
          :schema $ :: 'Dynamic
        'add-topic $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn add-topic (db op-data sid op-id op-time)
              let
                  user-id $ get-in db ([] :sessions sid :user-id)
                assoc-in db ([] :topics op-id)
                  merge schema/topic $ {} (:id op-id) (:time op-time) (:content op-data) (:author-id user-id)
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.updater.topic $ :require (app.schema :as schema)
    'app.updater.user $ %{} 'FileEntry
      :defs $ {}
        'log-in $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn log-in (db op-data sid op-id op-time)
              let-sugar
                    [] username password
                    , op-data
                  maybe-user $ -> (:users db) (vals) (.to-list)
                    find $ fn (user)
                      and $ = username (:name user)
                update-in db ([] :sessions sid)
                  fn (session)
                    if (some? maybe-user)
                      if
                        = (md5 password) (:password maybe-user)
                        assoc session :user-id $ :id maybe-user
                        update session :messages $ fn (messages)
                          assoc messages op-id $ {} (:id op-id)
                            :text $ str "|Wrong password for " username
                      update session :messages $ fn (messages)
                        assoc messages op-id $ {} (:id op-id)
                          :text $ str "|No user named: " username
          :examples $ []
          :schema $ :: 'Dynamic
        'log-out $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn log-out (db op-data sid op-id op-time)
              assoc-in db ([] :sessions sid :user-id) nil
          :examples $ []
          :schema $ :: 'Dynamic
        'sign-up $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn sign-up (db op-data sid op-id op-time)
              let-sugar
                    [] username password
                    , op-data
                  maybe-user $ find
                    vals $ :users db
                    fn (user)
                      = username $ :name user
                if (some? maybe-user)
                  update-in db ([] :sessions sid :messages)
                    fn (messages)
                      assoc messages op-id $ {} (:id op-id)
                        :text $ str "|Name is taken: " username
                  -> db
                    assoc-in ([] :sessions sid :user-id) op-id
                    assoc-in ([] :users op-id)
                      {} (:id op-id) (:name username) (:nickname username)
                        :password $ md5 password
                        :avatar nil
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns app.updater.user $ :require
            cumulo-util.core :refer $ find-first
            calcit.std.hash :refer $ md5
