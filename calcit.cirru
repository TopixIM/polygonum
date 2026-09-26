
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
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
          :code $ quote $ defatom *states
            {} $ :states $ {}
              :cursor $ []
          :examples $ []
          :schema $ :: 'Ref 'Dynamic
        '*store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *store nil
          :examples $ []
          :schema $ :: 'Ref 'Dynamic
        'ParsedUrlHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait ParsedUrlHost (:query 'app.client/QueryHost)
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
          :schema $ :: 'Trait
        'QueryHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait QueryHost
            :host $ :: 'JsNullish 'String
            :port $ :: 'JsNullish 'String
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
          :schema $ :: 'Trait
        'connect! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn connect! ()
            let
                location $ unsafe-coerce js/location 'js-ffi.browser/LocationHost
                url-obj $ unsafe-coerce
                  url-parse (.-href location) true
                  , 'app.client/ParsedUrlHost
                query $ unsafe-coerce (.-query url-obj) 'app.client/QueryHost
                raw-host $ .-host query
                raw-port $ .-port query
                host $ if (js-present? raw-host) (unsafe-coerce raw-host String) (.-hostname location)
                port $ if (js-present? raw-port) (unsafe-coerce raw-port String)
                  .unwrap-or (get config/site :port) 11026
              ws-connect! (str |ws:// host |: port)
                {}
                  :on-open $ fn (event) (simulate-login!)
                  :on-close $ fn (event) (reset! *store nil) (js/console.error "|Lost connection!")
                  :on-data on-server-data
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'ws-edn.client/WsClient)
            :args $ []
            :features $ #{} :js-ffi
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op op-data)
            when
              and config/dev? $ not= op :states
              println |Dispatch op op-data
            case-default op
              ws-send! $ {} (:kind :op) (:op op) (:data op-data)
              :states $ let[] (cursor s) op-data $ reset! *states (update-states @*states cursor s)
              :effect/connect $ connect!
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'Tag 'Dynamic
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () (load-console-formatter!)
            println "|Running mode:" $ if config/dev? |dev |release
            render-app!
            connect!
            add-watch *store :changes $ fn (store prev) (render-app!)
            add-watch *states :changes $ fn (states prev) (render-app!)
            on-page-touch $ unsafe-coerce
              fn () $ if (nil? @*store) (connect!)
              :: 'Fn $ {} (:return 'Unit)
                :args $ []
            println "|App started!"
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'mount-target $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn mount-target () (.querySelector js/document |.app)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ []
            :features $ #{} :js-ffi
            :return $ :: 'JsNullish 'JsObject
        'on-server-data $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn on-server-data (data)
            case-default (&map:get data :kind) (println "|unknown server data kind:" data)
              :patch $ let
                  changes $ unsafe-coerce (&map:get data :data) (:: 'List 'recollect.schema/change-op)
                when config/dev? $ js/console.log |Changes $ to-js-data changes
                reset! *store $ patch-twig @*store changes
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] $ :: 'Map 'Tag 'Dynamic
            :features $ #{} :js-ffi
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! ()
            if
              or $ some? client-errors
              tip! |error client-errors
              do (tip! |ok~ nil) (remove-watch *store :changes) (remove-watch *states :changes) (clear-cache!) (render-app!)
                add-watch *store :changes $ fn (store prev) (render-app!)
                add-watch *states :changes $ fn (states prev) (render-app!)
                println "|Code updated."
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! ()
            render! (mount-target)
              comp-container (&map:get @*states :states) @*store
              unsafe-coerce dispatch! $ :: 'Fn $ {} (:return 'Unit)
                :args $ [] 'Dynamic
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'simulate-login! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn simulate-login! ()
            let
                raw $ js/localStorage.getItem $ .unwrap-or (get config/site :storage-key) |
              if (js-present? raw)
                do (println "|Found storage.")
                  dispatch! :user/log-in $ parse-cirru-edn $ unsafe-coerce raw String
                do $ println "|Found no storage."
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.client
          :require
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
          :code $ quote $ defcomp comp-card-header (name idx)
            div
              {} $ :style $ merge ui/row-parted
                {}
                  :border-bottom $ str "|1px solid " $ hsl 0 0 90
                  :padding "|0 8px"
              span $ {}
              <> $ str name
              span $ {} (:inner-text "|✕")
                :style $ {}
                  :color $ hsl 0 80 70
                  :cursor :pointer
                :on-click $ fn (e d!) (d! :stack/close idx)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
        'comp-container $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (states store)
            let
                states-map $ unsafe-coerce states $ :: 'Map 'Tag 'Dynamic
                store-map $ unsafe-coerce
                  or store $ {}
                  :: 'Map 'Tag 'Dynamic
                state $ .unwrap-or (get states-map :data)
                  {} $ :demo |
                session $ unsafe-coerce
                  .unwrap-or (get store-map :session) ({})
                  :: 'Map 'Tag 'Dynamic
                router $ unsafe-coerce
                  .unwrap-or (get session :router) ({})
                  :: 'Map 'Tag 'Dynamic
                router-data $ .unwrap-or (get router :data) ({})
              if (nil? store) (comp-offline)
                div
                  {} $ :style $ merge ui/global ui/fullscreen ui/row
                  if
                    .unwrap-or (get store-map :logged-in?) false
                    case-default
                      .unwrap-or (get router :name) :unknown
                      <> $ format-cirru-edn router
                      :home $ comp-stack (>> states :stack)
                        .unwrap-or (get store-map :stack) ([])
                      :profile $ comp-profile
                        .unwrap-or (get store-map :user) ({})
                        , router-data
                    comp-login $ >> states :login
                  =- :v
                  comp-navigation
                    .unwrap-or (get store-map :logged-in?) false
                    .unwrap-or (get store-map :count) 0
                  comp-status-color $ .unwrap-or (get store-map :color) |transparent
                  when dev? $ comp-inspect |Store store $ {} (:bottom 80) (:left 0) (:max-width |100%)
                  comp-messages
                    .unwrap-or
                      get-in store-map $ [] :session :messages
                      {}
                    {}
                    fn (info d!) (d! :session/remove-message info)
                  when dev? $ comp-reel
                    .unwrap-or (get store-map :reel-length) 0
                    {}
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
        'comp-offline $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-offline ()
            div
              {} $ :style $ merge ui/global ui/fullscreen ui/column-dispersive
                {} $ :background-color $ &map:get config/site :theme
              div $ {} $ :style
                {} $ :height 0
              div $ {} $ :style
                {}
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
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ []
            :features $ #{} :js-ffi
        'comp-stack $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-stack (states stack)
            list->
              {} $ :style $ merge ui/expand ui/row
              -> stack
                map-indexed $ fn (idx router)
                  let
                      router-map $ unsafe-coerce router $ :: 'Map 'Tag 'Dynamic
                      router-data $ .unwrap-or (get router-map :data) ({})
                    [] idx $ div
                      {} $ :style $ merge ui/column
                        {} (:width 400) (:height |100%)
                          :border-right $ str "|1px solid " $ hsl 0 0 90
                      comp-card-header
                        .unwrap-or (get router-map :name) :unknown
                        , idx
                      case-default
                        .unwrap-or (get router-map :name) :unknown
                        comp-unknown-card router
                        :topics $ comp-topics (>> states :chat) router-data
                        :topic $ comp-topic
                          >> states $ str :topic $ .unwrap-or
                            get-in router-map $ [] :data :id
                            , |
                          , router-data
                concat $ [] $ [] 999 (comp-start)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'Dynamic $ :: 'List 'Dynamic
            :features $ #{} :js-ffi
        'comp-start $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-start ()
            div
              {} $ :style $ {} (:padding "|16px 40px")
              div ({}) (<> |Start...)
              =< nil 16
              div ({})
                button $ {} (:style ui/button) (:inner-text "|Open Chat")
                  :on-click $ fn (e d!)
                    d! :stack/add $ {} $ :name :topics
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
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ []
            :features $ #{} :js-ffi
        'comp-status-color $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-status-color (color)
            div $ {} $ :style
              let
                  size 24
                {} (:width size) (:height size) (:position :absolute) (:bottom 60) (:left 8) (:background-color color) (:border-radius |50%) (:opacity 0.6) (:pointer-events :none)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
        'comp-topic $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-topic (states topic)
            let
                states-map $ unsafe-coerce states $ :: 'Map 'Tag 'Dynamic
                topic-map $ unsafe-coerce topic $ :: 'Map 'Tag 'Dynamic
                cursor $ .unwrap-or (get states-map :cursor) ([])
                state $ .unwrap-or (get states-map :data)
                  {} $ :draft |
                state-map $ unsafe-coerce state $ :: 'Map 'Tag 'Dynamic
              div
                {} $ :style $ merge ui/expand ui/column
                  {} $ :border-top $ str "|1px solid " (hsl 0 0 88)
                div
                  {} $ :style $ {} (:padding 8)
                  span $ {} $ :inner-text
                    .unwrap-or (get topic-map :content) |-
                div
                  {} $ :style $ {} (:padding 8)
                    :border-bottom $ str "|1px solid " $ hsl 0 0 90
                  <>
                    str |@ $ .unwrap-or
                      get-in topic-map $ [] :author :nickname
                      , |
                    {} $ :color $ hsl 0 0 50
                  =< 8 nil
                  <>
                    unsafe-coerce
                      ->
                        .unwrap-or (get topic-map :time) 0
                        dayjs
                        .!format |HH:mm
                      , String
                    {}
                      :color $ hsl 0 0 70
                      :font-weight 300
                      :font-family ui/font-fancy
                div
                  {} $ :style $ merge ui/expand ({})
                  list-> ({})
                    unsafe-coerce
                      ->
                        unsafe-coerce
                          .unwrap-or (get topic-map :replies) ({})
                          :: 'Map 'Tag 'Dynamic
                        &map:to-list
                        &list:sort-by $ fn (pair)
                          let[] (_ reply) pair $ .unwrap-or
                            get
                              unsafe-coerce reply $ :: 'Map 'Tag 'Dynamic
                              , :time
                            , 0
                        map $ fn (pair)
                          let[] (k reply) pair $ let
                              reply-map $ unsafe-coerce reply $ :: 'Map 'Tag 'Dynamic
                            [] k
                            div
                              {} $ :style $ {} (:padding |8px)
                                :border-bottom $ str "|1px solid " $ hsl 0 0 90
                              div ({})
                                <> $ str |@ $ .unwrap-or
                                  get-in reply-map $ [] :author :nickname
                                  , |
                                =< 8 nil
                                <> $ unsafe-coerce
                                  ->
                                    .unwrap-or (get reply-map :time) 0
                                    dayjs
                                    .!format |HH:mm
                                  , String
                              div ({})
                                <> $ .unwrap-or (get reply-map :content) |
                      :: 'List $ :: 'List 'Dynamic
                  =< nil 80
                div
                  {} $ :style $ merge ui/row
                    {} $ :border-top $ str "|1px solid " (hsl 0 0 90)
                  textarea $ {}
                    :style $ merge ui/expand ui/textarea
                    :value $ .unwrap-or (get state-map :draft) |
                    :placeholder |Reply...
                    :on-change $ fn (e d!)
                      d! cursor $ assoc state :draft $ .unwrap-or (get e :value) |
                  =< 8 nil
                  div ({})
                    button $ {} (:inner-text |Send) (:style ui/button)
                      :on-click $ fn (e d!)
                        let
                            content $ trim $ .unwrap-or (get state :draft) |
                          when
                            not $ blank? content
                            d! :topic/reply $ {}
                              :topic-id $ .unwrap-or (get topic-map :id) |
                              :text content
                            d! cursor $ assoc state :draft |
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
        'comp-topic-item $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-topic-item (topic)
            let
                topic-map $ unsafe-coerce topic $ :: 'Map 'Tag 'Dynamic
              div
                {} $ :style $ {} (:padding 8)
                  :border-top $ str "|1px solid " $ hsl 0 0 88
                div ({})
                  span $ {}
                    :inner-text $ .unwrap-or (get topic-map :content) |-
                    :on-click $ fn (e d!)
                      d! :stack/add $ {} (:name :topic)
                        :data $ .unwrap-or (get topic-map :id) |
                div ({})
                  <>
                    str |@ $ .unwrap-or
                      get-in topic-map $ [] :author :nickname
                      , |
                    {} $ :color $ hsl 0 0 50
                  =< 8 nil
                  <>
                    unsafe-coerce
                      ->
                        .unwrap-or (get topic-map :time) 0
                        dayjs
                        .!format |HH:mm
                      , String
                    {}
                      :color $ hsl 0 0 70
                      :font-weight 300
                      :font-family ui/font-fancy
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
        'comp-topics $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-topics (states data)
            let
                states-map $ unsafe-coerce states $ :: 'Map 'Tag 'Dynamic
                cursor $ .unwrap-or (get states-map :cursor) ([])
                state $ .unwrap-or (get states-map :data) ({})
                create-plugin $ use-prompt (>> states :new)
                  {} $ :title "|Create Topic"
              div
                {} $ :style $ merge ui/expand ui/column ({})
                div
                  {} $ :style $ merge
                    unsafe-coerce ui/row-middle $ :: 'Map 'Tag 'Dynamic
                    unsafe-coerce
                      {} $ :padding "|4px 8px"
                      :: 'Map 'Tag 'Dynamic
                  <> |Topics
                  =< 16 nil
                  a $ {} (:style ui/link) (:inner-text |New)
                    :on-click $ fn (e d!)
                      .show create-plugin d! $ fn (text) (d! :topic/add text)
                div
                  {} $ :style ui/expand
                  list->
                    {} $ :style $ {}
                      :border-bottom $ str "|1px solid " $ hsl 0 0 80
                    unsafe-coerce
                      ->
                        unsafe-coerce
                          or data $ {}
                          :: 'Map 'Tag 'Dynamic
                        &map:to-list
                        &list:sort-by $ fn (pair)
                          let[] (_ topic) pair $ negate $ .unwrap-or
                            get
                              unsafe-coerce topic $ :: 'Map 'Tag 'Dynamic
                              , :time
                            , 0
                        map $ fn (pair)
                          let[] (k topic) pair $ [] k $ comp-topic-item topic
                      :: 'List $ :: 'List 'Dynamic
                  =< nil 100
                .render create-plugin
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
        'comp-unknown-card $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-unknown-card (router)
            div
              {} $ :style $ merge ui/column
                {} (:width 400) (:height |100%)
                  :border-right $ str "|1px solid " $ hsl 0 0 90
              div ({}) (<> "|Unknown card")
              pre ({})
                code $ {} $ :inner-text (format-cirru-edn router)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require
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
          :code $ quote $ defcomp comp-login (states)
            let
                states-map $ unsafe-coerce states $ :: 'Map 'Tag 'Dynamic
                cursor $ .unwrap-or (get states-map :cursor) ([])
                state $ .unwrap-or (get states-map :data) initial-state
                state-map $ unsafe-coerce state $ :: 'Map 'Tag 'Dynamic
              div
                {} $ :style $ merge
                  unsafe-coerce ui/flex $ :: 'Map 'Tag 'Dynamic
                  unsafe-coerce ui/center $ :: 'Map 'Tag 'Dynamic
                div ({})
                  div
                    {} $ :style $ {}
                    div ({})
                      input $ {} (:placeholder |Username)
                        :value $ .unwrap-or (get state-map :username) |
                        :style ui/input
                        :on-input $ fn (e d!)
                          d! cursor $ assoc state :username $ .unwrap-or (get e :value) |
                    =< nil 8
                    div ({})
                      input $ {} (:placeholder |Password)
                        :value $ .unwrap-or (get state-map :password) |
                        :style ui/input
                        :on-input $ fn (e d!)
                          d! cursor $ assoc state :password $ .unwrap-or (get e :value) |
                  =< nil 8
                  div
                    {} $ :style $ {} (:text-align :right)
                    span $ {} (:inner-text "|Sign up")
                      :style $ merge ui/link
                      :on-click $ on-submit
                        .unwrap-or (get state-map :username) |
                        .unwrap-or (get state-map :password) |
                        , true
                    =< 8 nil
                    span $ {} (:inner-text "|Log in")
                      :style $ merge ui/link
                      :on-click $ on-submit
                        .unwrap-or (get state-map :username) |
                        .unwrap-or (get state-map :password) |
                        , false
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
        'initial-state $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def initial-state
            {} (:username |) (:password |)
          :examples $ []
          :schema $ :: 'Dynamic
        'on-submit $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn on-submit (username password signup?)
            fn (e dispatch!)
              dispatch! (if signup? :user/sign-up :user/log-in) ([] username password)
              .setItem js/localStorage
                .unwrap-or (get config/site :storage-key) |
                format-cirru-edn $ [] username password
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'String 'String 'Bool
            :features $ #{} :js-ffi
            :return $ :: 'Fn $ {} (:return 'Unit)
              :args $ [] 'Dynamic 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.login
          :require
            respo.core :refer $ defcomp <> div input button span
            respo.comp.space :refer $ =<
            respo.comp.inspect :refer $ comp-inspect
            respo-ui.core :as ui
            app.schema :as schema
            app.config :as config
    'app.comp.navigation $ %{} 'FileEntry
      :defs $ {} $ 'comp-navigation
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-navigation (logged-in? count-members)
            div
              {} $ :style $ merge ui/column-parted
                {} (:width 64) (:justify-content :space-between) (:padding "|0 16px") (:font-size 16) (:font-family ui/font-fancy)
              div
                {} $ :style ui/column
                div
                  {}
                    :on-click $ fn (e d!)
                      d! :router/change $ {} $ :name :home
                    :style $ {} $ :cursor :pointer
                  <> |Ploy nil
              div
                {}
                  :style $ merge ui/row $ {} (:cursor |pointer)
                  :on-click $ fn (e d!)
                    d! :router/change $ {} $ :name :profile
                <> $ if logged-in? |Me |Guest
                =< 4 nil
                <> count-members
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.navigation
          :require
            respo.util.format :refer $ hsl
            respo-ui.core :as ui
            respo.comp.space :refer $ =<
            respo.core :refer $ defcomp <> span div
            app.config :as config
    'app.comp.profile $ %{} 'FileEntry
      :defs $ {} $ 'comp-profile
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-profile (user members)
            let
                user-map $ unsafe-coerce user $ :: 'Map 'Tag 'Dynamic
              div $ {} $ :style
                merge ui/flex $ {} $ :padding 16
              div
                {} $ :style $ {} (:font-family ui/font-fancy) (:font-size 32) (:font-weight 100)
                <> $ str "|Hello! " $ .unwrap-or (get user-map :name) |
              =< nil 16
              div
                {} $ :style ui/row
                <> |Members:
                =< 8 nil
                list->
                  {} $ :style ui/row
                  ->
                    unsafe-coerce members $ :: 'Map 'Tag 'Dynamic
                    &map:to-list
                    map $ fn (pair)
                      let[] (k username) pair $ [] k $ div
                        {} $ :style $ {} (:padding "|0 8px")
                          :border $ str "|1px solid " $ hsl 0 0 80
                          :border-radius |16px
                          :margin "|0 4px"
                        <> username
              =< nil 48
              div ({})
                button
                  {}
                    :style $ merge ui/button
                    :on-click $ fn (e d!)
                      js/location.replace $ str js/location.origin |?time= $ .now js/Date
                  <> |Refresh
                =< 8 nil
                button
                  {}
                    :style $ merge ui/button $ {} (:color :red) (:border-color :red)
                    :on-click $ fn (e dispatch!) (dispatch! :user/log-out nil)
                      .removeItem js/localStorage $ &map:get config/site :storage-key
                  <> "|Log out"
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.profile
          :require
            respo.util.format :refer $ hsl
            app.schema :as schema
            respo-ui.core :as ui
            respo.core :refer $ defcomp list-> <> span div button
            respo.comp.space :refer $ =<
            app.config :as config
    'app.comp.widget $ %{} 'FileEntry
      :defs $ {} $ '=-
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn =- (direction style)
            div $ {} $ :style
              merge
                {} $ :background-color $ hsl 0 0 88
                if (= direction :v)
                  {} (:width 1) (:height |100%)
                  {} (:height 1) (:width |100%)
                .unwrap-or style $ {}
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Element)
            :args $ [] 'Tag $ :: 'Option (:: 'Map 'Tag 'Dynamic)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.widget
          :require
            respo-ui.core :refer $ hsl
            respo.core :refer $ defcomp <> >> div span button input textarea
    'app.config $ %{} 'FileEntry
      :defs $ {}
        'dev? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $ option:unwrap-or (get-env |mode) |
          :examples $ []
          :schema $ :: 'Dynamic
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site
            {} (:port 11026) (:title |Polygonum) (:icon |http://cdn.tiye.me/logo/cumulo.png) (:theme |#eeeeff) (:storage-key |polygonum) (:storage-file |storage.cirru)
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
    'app.schema $ %{} 'FileEntry
      :defs $ {}
        'database $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def database
            {}
              :sessions $ do session $ {}
              :users $ do user $ {}
              :topics $ do topic $ {}
          :examples $ []
          :schema $ :: 'Dynamic
        'reply $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def reply
            {} (:id nil) (:content |) (:author-id |) (:time nil)
          :examples $ []
          :schema $ :: 'Dynamic
        'router $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def router
            {} (:name nil) (:title nil)
              :data $ {}
              :router nil
          :examples $ []
          :schema $ :: 'Dynamic
        'session $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def session
            {} (:user-id nil) (:id nil) (:nickname nil)
              :router $ do router $ {} (:name :home) (:data nil) (:router nil)
              :messages $ {}
              :stack $ do stack $ []
          :examples $ []
          :schema $ :: 'Dynamic
        'stack $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def stack
            {} (:name nil) (:data nil)
          :examples $ []
          :schema $ :: 'Dynamic
        'topic $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def topic
            {} (:id nil) (:content |) (:time nil)
              :replies $ do reply $ {}
              :author-id nil
          :examples $ []
          :schema $ :: 'Dynamic
        'user $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def user
            {} (:name nil) (:id nil) (:nickname nil) (:avatar nil) (:password nil)
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.schema
    'app.server $ %{} 'FileEntry
      :defs $ {}
        '*client-caches $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *client-caches ({})
          :examples $ []
          :schema $ :: 'Ref 'Dynamic
        '*initial-db $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *initial-db
            if
              path-exists? $ w-log storage-file
              do (println "|Found local EDN data")
                merge-loaded-db schema/database $ load-db storage-file
              do (println "|Found no data") schema/database
          :examples $ []
          :schema $ :: 'Ref $ :: 'Map 'Tag 'Dynamic
        '*proxied-dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *proxied-dispatch! dispatch!
          :examples $ []
          :schema $ :: 'Ref $ :: 'Fn
            {} (:return 'Unit)
              :args $ [] 'Tag 'Dynamic 'Number
        '*reader-reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *reader-reel @*reel
          :examples $ []
          :schema $ :: 'Ref 'cumulo-reel.core/ReelState
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defatom *reel
            struct-with reel-schema (:base @*initial-db) (:db @*initial-db)
          :examples $ []
          :schema $ :: 'Ref 'cumulo-reel.core/ReelState
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op op-data sid)
            let
                op-id $ generate-id!
                op-time $ calcit.std.date/get-timestamp $ get-time!
              if config/dev? $ println |Dispatch! (str op) op-data sid
              if (= op :effect/persist) (persist-db!)
                reset! *reel $ reel-reducer @*reel updater (:: op op-data) sid op-id op-time config/dev?
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'Tag 'Dynamic 'Number
        'get-backup-path! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn get-backup-path! ()
            let
                now $ extract-time $ get-time!
              join-path calcit-dirname |backups
                str $ &map:get now :month
                str (&map:get now :day) |-snapshot.cirru
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'String)
            :args $ []
            :features $ #{} :js-ffi
        'load-db $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn load-db (path)
            unsafe-coerce
              parse-cirru-edn $ read-file path
              :: 'Map 'Tag 'Dynamic
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'String
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            println "|Running mode:" $ if config/dev? |dev |release
            let
                p? $ get-env |port
                fallback $ unsafe-coerce
                  .unwrap-or (get config/site :port) 11026
                  , Number
                port $ if (.some? p?)
                  .unwrap-or
                    parse-float $ .unwrap p?
                    , fallback
                  , fallback
              run-server! port
              println $ str "|Server started on port:" port
            do (; "|init it before doing multi-threading") (identity @*reader-reel)
            set-interval 200 $ fn () $ render-loop!
            set-interval 600000 $ fn () $ persist-db!
            on-control-c on-exit!
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'FfiTask)
            :args $ []
            :features $ #{} :js-ffi
        'merge-loaded-db $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn merge-loaded-db (base loaded)
            merge
              unsafe-coerce base $ :: 'Map 'Tag 'Dynamic
              , loaded
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic $ :: 'Map 'Tag 'Dynamic
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'on-exit! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn on-exit! () (persist-db!) (; println "|exit code is...") (quit! 0)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
        'persist-db! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn persist-db! ()
            let
                file-content $ format-cirru-edn $ assoc (:db @*reel) :sessions ({})
                storage-path storage-file
                backup-path $ get-backup-path!
              check-write-file! storage-path file-content
              check-write-file! backup-path file-content
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! () (println "|Code updated..")
            if (not config/dev?) (raise "|reloading only happens in dev mode")
            clear-twig-caches!
            reset! *reel $ refresh-reel @*reel @*initial-db updater
            sync-clients! @*reader-reel
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
        'render-loop! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-loop! ()
            when
              not $ identical? @*reader-reel @*reel
              reset! *reader-reel @*reel
              sync-clients! @*reader-reel
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
        'run-server! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn run-server! (port)
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
          :schema $ :: 'Fn $ {} (:return 'FfiTask)
            :args $ [] 'Number
            :features $ #{} :js-ffi
        'storage-file $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def storage-file
            if (empty? calcit-dirname)
              str calcit-dirname $ :storage-file config/site
              str calcit-dirname |/ $ :storage-file config/site
          :examples $ []
          :schema $ :: 'String
        'sync-clients! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn sync-clients! (reel) (begin-twig-frame!)
            wss-each! $ fn (sid)
              let
                  reel-state $ unsafe-coerce reel 'cumulo-reel.core/ReelState
                  db $ :db reel-state
                  records $ :records reel-state
                  session $ get-in db $ [] :sessions sid
                  old-store $ or (get @*client-caches sid) nil
                  new-store $ twig-container db session records
                  changes $ diff-twig old-store new-store $ {} (:key :id)
                ; when config/dev? $ println "|Changes for" sid |: changes $ count records
                if
                  not $ empty? changes
                  do
                    wss-send! sid $ format-cirru-edn $ {} (:kind :patch) (:data changes)
                    swap! *client-caches assoc sid new-store
            finish-twig-frame!
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.server
          :require (app.schema :as schema)
            app.updater :refer $ updater
            cumulo-reel.core :refer $ reel-reducer refresh-reel reel-schema
            app.config :as config
            app.twig.container :refer $ twig-container
            recollect.diff :refer $ diff-twig
            recollect.twig :refer $ clear-twig-caches!
            recollect.memo :refer $ begin-twig-frame! finish-twig-frame!
            wss.core :refer $ wss-serve! wss-send! wss-each!
            app.$meta :refer $ calcit-dirname
            calcit.std.fs :refer $ path-exists? check-write-file!
            calcit.std.time :refer $ set-interval
            calcit.std.date :refer $ get-time! extract-time
            calcit.std.path :refer $ join-path
    'app.twig.container $ %{} 'FileEntry
      :defs $ {}
        'merge-dynamic-maps $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn merge-dynamic-maps (a b)
            merge
              unsafe-coerce a $ :: 'Map 'Tag 'Dynamic
              unsafe-coerce b $ :: 'Map 'Tag 'Dynamic
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'twig-container $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn twig-container (db session records)
            let
                db-map $ unsafe-coerce db $ :: 'Map 'Tag 'Dynamic
                session-map $ unsafe-coerce
                  .unwrap-or session $ {}
                  :: 'Map 'Tag 'Dynamic
                user-id $ get session-map :user-id
                logged-in? $ .some? user-id
                router $ unsafe-coerce
                  .unwrap-or (get session-map :router) ({})
                  :: 'Map 'Tag 'Dynamic
                base-data $ {} (:logged-in? logged-in?) (:session session-map)
                  :reel-length $ count records
              merge-dynamic-maps base-data $ if logged-in?
                let
                    user $ unsafe-coerce
                      .unwrap-or
                        get-in db-map $ [] :users user-id
                        {}
                      :: 'Map 'Tag 'Dynamic
                  {}
                    :user $ twig-user user
                    :router $ assoc router :data $ case-default (get router :name) ({})
                      :home $ ->
                        .unwrap-or (get db-map :messages) ({})
                        unsafe-coerce $ :: 'Map 'Tag 'Dynamic
                        filter-map-kv $ fn (k v)
                          hint-fn $ {}
                            :args $ [] 'Tag 'Dynamic
                            :return $ :: 'MapEntryDecision 'Tag 'Dynamic
                          let
                              value-map $ unsafe-coerce v $ :: 'Map 'Tag 'Dynamic
                            %:: MapEntryDecision :keep k $ assoc value-map :author $ twig-user
                              .unwrap-or
                                get-in db-map $ [] :users $ get value-map :author-id
                                {}
                      :profile $ twig-members
                        unsafe-coerce
                          .unwrap-or (get db-map :sessions) ({})
                          :: 'Map 'Tag 'Dynamic
                        unsafe-coerce
                          .unwrap-or (get db-map :users) ({})
                          :: 'Map 'Tag 'Dynamic
                    :stack $ if
                      = :home $ unsafe-coerce
                        .unwrap-or (get router :name) :unknown
                        , Tag
                      ->
                        .unwrap-or (get session-map :stack) ([])
                        map $ fn (stack-router)
                          let
                              router-map $ unsafe-coerce stack-router $ :: 'Map 'Tag 'Dynamic
                            assoc router-map :data $ case-default (get router-map :name)
                              {} $ :original-data router-map
                              :topic $ if-let
                                topic $ get-in db-map $ [] :topics (get router-map :data)
                                let
                                    topic-map $ unsafe-coerce topic $ :: 'Map 'Tag 'Dynamic
                                  -> topic-map
                                    assoc :author $ twig-user $ .unwrap-or
                                      get-in db-map $ [] :users $ get topic-map :author-id
                                      {}
                                    update :replies $ fn (replies)
                                      ->
                                        unsafe-coerce replies $ :: 'Map 'Tag 'Dynamic
                                        unsafe-coerce $ :: 'Map 'Tag 'Dynamic
                                        filter-map-kv $ fn (k v)
                                          hint-fn $ {}
                                            :args $ [] 'Tag 'Dynamic
                                            :return $ :: 'MapEntryDecision 'Tag 'Dynamic
                                          let
                                              value-map $ unsafe-coerce v $ :: 'Map 'Tag 'Dynamic
                                            %:: MapEntryDecision :keep k $ assoc value-map :author $ twig-user
                                              .unwrap-or
                                                get-in db-map $ [] :users $ get value-map :author-id
                                                {}
                                unsafe-coerce nil $ :: 'Map 'Tag 'Dynamic
                              :topics $ ->
                                .unwrap-or (get db-map :topics) ({})
                                unsafe-coerce $ :: 'Map 'Tag 'Dynamic
                                filter-map-kv $ fn (k v)
                                  hint-fn $ {}
                                    :args $ [] 'Tag 'Dynamic
                                    :return $ :: 'MapEntryDecision 'Tag 'Dynamic
                                  let
                                      value-map $ unsafe-coerce v $ :: 'Map 'Tag 'Dynamic
                                    %:: MapEntryDecision :keep k $ assoc value-map :author $ twig-user
                                      .unwrap-or
                                        get-in db-map $ [] :users $ get value-map :author-id
                                        {}
                      []
                    :count $ count $ get db-map :sessions
                    :color $ rand-hex-color!
                {}
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) (:: 'Option 'Dynamic) 'Dynamic
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'twig-members $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn twig-members (sessions users)
            ->
              unsafe-coerce sessions $ :: 'Map 'Tag 'Dynamic
              &map:to-list
              map $ fn (pair)
                let[] (k session) pair $ [] k $ .unwrap-or
                  get-in users $ []
                    &map:get
                      unsafe-coerce session $ :: 'Map 'Tag 'Dynamic
                      , :user-id
                    , :name
                  , nil
              pairs-map
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) (:: 'Map 'Tag 'Dynamic)
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.twig.container
          :require
            app.twig.user :refer $ twig-user
            calcit.std.rand :refer $ rand-hex-color!
    'app.twig.user $ %{} 'FileEntry
      :defs $ {} $ 'twig-user
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn twig-user (user) (dissoc user :password)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.twig.user (:require)
    'app.updater $ %{} 'FileEntry
      :defs $ {} $ 'updater
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (db op sid op-id op-time)
            match op
              (:session/connect op-data) (session/connect db op-data sid op-id op-time)
              (:session/disconnect op-data) (session/disconnect db op-data sid op-id op-time)
              (:session/remove-message op-data) (session/remove-message db op-data sid op-id op-time)
              (:user/log-in op-data) (user/log-in db op-data sid op-id op-time)
              (:user/sign-up op-data) (user/sign-up db op-data sid op-id op-time)
              (:user/log-out op-data) (user/log-out db op-data sid op-id op-time)
              (:router/change op-data) (router/change db op-data sid op-id op-time)
              (:stack/add op-data) (router/add-stack db op-data sid op-id op-time)
              (:stack/close op-data) (router/close-stack db op-data sid op-id op-time)
              (:topic/add op-data) (topic/add-topic db op-data sid op-id op-time)
              (:topic/reply op-data) (topic/add-reply db op-data sid op-id op-time)
              _ $ do (println "|Unknown op:" op) db
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :return $ :: 'Map 'Tag 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require (app.updater.session :as session) (app.updater.user :as user) (app.updater.router :as router) (app.updater.topic :as topic) (app.schema :as schema)
            respo-message.updater :refer $ update-messages
    'app.updater.router $ %{} 'FileEntry
      :defs $ {}
        'add-stack $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn add-stack (db op-data sid op-id op-time)
            update-in db ([] :sessions sid :stack)
              fn (s)
                hint-fn $ {}
                  :args $ [] $ :: 'Option (:: 'List 'Dynamic)
                  :return $ :: 'List 'Dynamic
                conj
                  .unwrap-or s $ []
                  , op-data
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'change $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn change (db op-data sid op-id op-time)
            assoc-in db ([] :sessions sid :router) op-data
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'close-stack $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn close-stack (db op-data sid op-id op-time)
            update-in db ([] :sessions sid :stack)
              fn (s)
                dissoc
                  option:unwrap-or s $ []
                  , op-data
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater.router
    'app.updater.session $ %{} 'FileEntry
      :defs $ {}
        'connect $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn connect (db op-data sid op-id op-time)
            assoc-in db ([] :sessions sid)
              merge schema/session $ {} $ :id sid
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'disconnect $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn disconnect (db op-data sid op-id op-time)
            update db :sessions $ fn (session) (dissoc session sid)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'remove-message $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn remove-message (db op-data sid op-id op-time)
            update-in db ([] :sessions sid :messages)
              fn (messages)
                hint-fn $ {}
                  :args $ [] $ :: 'Option (:: 'Map 'Tag 'Dynamic)
                  :return $ :: 'Map 'Tag 'Dynamic
                dissoc
                  .unwrap-or messages $ {}
                  &map:get
                    unsafe-coerce op-data $ :: 'Map 'Tag 'Dynamic
                    , :id
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater.session
          :require $ app.schema :as schema
    'app.updater.topic $ %{} 'FileEntry
      :defs $ {}
        'add-reply $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn add-reply (db op-data sid op-id op-time)
            let
                user-id $ get-in db $ [] :sessions sid :user-id
                op-map $ unsafe-coerce op-data 'Map
              assoc-in db
                [] :topics (&map:get op-map :topic-id) :replies op-id
                merge schema/reply $ {} (:id op-id) (:time op-time)
                  :content $ &map:get op-map :text
                  :author-id user-id
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'add-topic $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn add-topic (db op-data sid op-id op-time)
            let
                user-id $ get-in db $ [] :sessions sid :user-id
              assoc-in db ([] :topics op-id)
                merge schema/topic $ {} (:id op-id) (:time op-time) (:content op-data) (:author-id user-id)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater.topic
          :require $ app.schema :as schema
    'app.updater.user $ %{} 'FileEntry
      :defs $ {}
        'log-in $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn log-in (db op-data sid op-id op-time)
            let-sugar
                  [] username password
                  , op-data
                maybe-user $ ->
                  unsafe-coerce (&map:get db :users) (:: 'Map 'Tag 'Dynamic)
                  vals
                  &set:to-list
                  unsafe-coerce $ :: 'List $ :: 'Map 'Tag 'Dynamic
                  find $ fn (user)
                    hint-fn $ {}
                      :args $ [] $ :: 'Map 'Tag 'Dynamic
                      :return 'Bool
                    = username $ &map:get user :name
              update-in db ([] :sessions sid)
                fn (session)
                  hint-fn $ {}
                    :args $ [] $ :: 'Option (:: 'Map 'Tag 'Dynamic)
                    :return $ :: 'Map 'Tag 'Dynamic
                  if (option:some? maybe-user)
                    if
                      = (md5 password)
                        &map:get (option:unwrap maybe-user) :password
                      assoc
                        .unwrap-or session $ {}
                        , :user-id $ &map:get (option:unwrap maybe-user) :id
                      update
                        .unwrap-or session $ {}
                        , :messages $ fn (messages)
                          hint-fn $ {}
                            :args $ [] 'Dynamic
                            :return 'Dynamic
                          assoc
                            or messages $ {}
                            , op-id $ {} (:id op-id)
                              :text $ str "|Wrong password for " username
                    update
                      .unwrap-or session $ {}
                      , :messages $ fn (messages)
                        hint-fn $ {}
                          :args $ [] 'Dynamic
                          :return 'Dynamic
                        assoc
                          or messages $ {}
                          , op-id $ {} (:id op-id)
                            :text $ str "|No user named: " username
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'log-out $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn log-out (db op-data sid op-id op-time)
            assoc-in db ([] :sessions sid :user-id) nil
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
        'sign-up $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn sign-up (db op-data sid op-id op-time)
            let-sugar
                  [] username password
                  , op-data
                maybe-user $ find
                  unsafe-coerce
                    ->
                      unsafe-coerce (&map:get db :users) (:: 'Map 'Tag 'Dynamic)
                      , vals &set:to-list
                    :: 'List $ :: 'Map 'Tag 'Dynamic
                  fn (user)
                    hint-fn $ {}
                      :args $ [] $ :: 'Map 'Tag 'Dynamic
                      :return 'Bool
                    = username $ &map:get user :name
              if (option:some? maybe-user)
                update-in db ([] :sessions sid :messages)
                  fn (messages)
                    hint-fn $ {}
                      :args $ [] $ :: 'Option (:: 'Map 'String 'Dynamic)
                      :return $ :: 'Map 'String 'Dynamic
                    assoc
                      .unwrap-or messages $ {}
                      , op-id $ {} (:id op-id)
                        :text $ str "|Name is taken: " username
                -> db
                  assoc-in ([] :sessions sid :user-id) op-id
                  assoc-in ([] :users op-id)
                    {} (:id op-id) (:name username) (:nickname username)
                      :password $ md5 password
                      :avatar nil
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Dynamic 'Number 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Tag 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater.user
          :require
            cumulo-util.core :refer $ find-first
            calcit.std.hash :refer $ md5
