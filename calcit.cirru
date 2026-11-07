
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {}
    :default $ {} (:description |) (:init-fn 'app.client/main!) (:mode :js) (:reload-fn 'app.client/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |recollect/ |respo-ui.calcit/ |ws-edn.calcit/ |cumulo-util.calcit/ |respo-message.calcit/ |cumulo-reel.calcit/ |alerts.calcit/ |js-ffi/
      :type-slots $ {} $ :dispatch-op 'app.schema/Op
    :server $ {} (:description |) (:init-fn 'app.server/main!) (:mode :native) (:reload-fn 'app.server/reload!) (:target :native)
      :feature-policy $ {}
      :modules $ [] |recollect/ |cumulo-util.calcit/ |cumulo-reel.calcit/ |calcit.std/ |calcit-wss/
      :type-slots $ {}
  :files $ {}
    'app.client $ %{} 'FileEntry
      :defs $ {}
        '*states $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *states
            {} $ :cursor $ []
          :examples $ []
          :schema $ quote $ Ref Dynamic
        '*store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *store (Option :none)
          :examples $ []
          :schema $ quote $ Ref (Option app.schema/Store)
        '*wire-store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *wire-store (Option :none)
          :examples $ []
          :schema $ quote $ Ref (Option Dynamic)
        'connect! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn connect! ()
            reset! *wire-store $ Option :none
            reset! *store $ Option :none
            ws-connect! (connection-url)
              {}
                :on-open $ fn (event) (simulate-login!)
                :on-close $ fn (event)
                  reset! *wire-store $ Option :none
                  reset! *store $ Option :none
                  host/console-error! |Lost-connection
                :on-data on-server-data
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit)
        'connection-url $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn connection-url ()
            let
                location $ browser/location-host
                query $ host/search-params-create $ .-search location
                server-host $ .unwrap-or (host/search-params-get query |host) (.-hostname location)
                server-port $ .unwrap-or (host/search-params-get query |port)
                  str $ :port config/site
              str |ws:// server-host |: server-port
          :examples $ []
          :schema $ quote $ Fn (-> String) (:features :js-ffi)
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (raw)
            let
                op $ protocol/decode-op raw
              match op
                (:states cursor state)
                  reset! *states $ update-state-tree @*states cursor state
                (:effect/connect) (connect!)
                _ $ ws-send! $ protocol/encode-op op
            , &unit
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> Unit)
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            println "|Running mode:" $ if config/dev? |dev |release
            render-app!
            connect!
            add-watch! *store :changes $ fn (store previous) (render-app!)
            add-watch! *states :changes $ fn (states previous) (render-app!)
            on-page-touch $ fn () $ match @*store
              (:none) (connect!)
              (:some store) &unit
            println "|App started!"
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit)
        'mount-target $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn mount-target ()
            .unwrap $ dom/query-selector |.app
          :examples $ []
          :schema $ quote $ Fn (-> respo.dom/DomElement)
        'on-server-data $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn on-server-data (data)
            try
              if (enum? data)
                match data
                  (:patch raw-changes)
                    let
                        changes $ decode-changes raw-changes
                        result $ try-patch-twig
                          match @*wire-store
                            (:none) nil
                            (:some previous) previous
                          , changes
                      match result
                        (:ok candidate)
                          let
                              decoded $ protocol/decode-store candidate
                            reset! *wire-store $ Option :some candidate
                            reset! *store $ Option :some decoded
                        (:err error)
                          raise $ patch-error-message error
                  _ $ raise |Unsupported-server-message
                raise |Expected-server-message-enum
              fn (error)
                host/console-error! $ str |Rejected-server-patch: error
                tip! |error error
            , &unit
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> Unit) (:features :js-ffi)
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! ()
            if (js-present? client-errors) (tip! |error client-errors)
              do (tip! |inactive nil) (remove-watch! *store :changes) (remove-watch! *states :changes) (clear-cache!) (render-app!)
                add-watch! *store :changes $ fn (store previous) (render-app!)
                add-watch! *states :changes $ fn (states previous) (render-app!)
                println |Code-updated
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! ()
            render-with! (mount-target)
              fn () $ comp-container
                decode-map-as @*states $ Map Dynamic Dynamic
                , @*store
              , dispatch!
          :examples $ []
          :schema $ quote $ Fn (-> Unit)
        'simulate-login! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn simulate-login! ()
            match
              browser/storage-get $ :storage-key config/site
              (:none) &unit
              (:some content)
                try
                  ws-send! $ protocol/encode-op $ schema/Op :user/log-in
                    protocol/decode-credentials $ parse-cirru-edn content
                  fn (error) (host/console-error! |Invalid-saved-login)
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.client
          :require
            respo.core :refer $ render-with! clear-cache!
            respo.ffi.browser :as dom
            respo.cursor :refer $ update-state-tree
            app.comp.container :refer $ comp-container
            app.schema :as schema
            app.protocol :as protocol
            app.config :as config
            ws-edn.client :refer $ ws-connect! ws-send!
            recollect.patch :refer $ try-patch-twig patch-error-message
            recollect.schema :refer $ decode-changes
            cumulo-util.core :refer $ on-page-touch
            js-ffi.browser :as browser
            js-ffi.shared :as host
            |bottom-tip :default tip!
            |./calcit.build-errors :default client-errors
    'app.comp.container $ %{} 'FileEntry
      :defs $ {}
        'author-label $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn author-label (author)
            match author
              (:none) |
              (:some user)
                .unwrap-or (:nickname user) |
          :examples $ []
          :schema $ quote $ Fn (Option app.schema/UserView) (-> String)
          :tests $ [] $ %{} 'TestEntry (:name |optional-author-and-nickname-display)
            :code $ quote $ let
                user $ schema/UserView :id |u :name |User :nickname (Option :none) :avatar $ Option :none
              assert= | $ author-label $ Option :none
              assert= | $ author-label $ Option :some user
              assert= "|昵称" $ author-label $ Option :some
                assoc user :nickname $ Option :some "|昵称"
            :tags $ #{} :migration :unit
        'card-name $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn card-name (card)
            match card
              (:topics _) :topics
              (:topic _) :topic
              (:unknown original) (:name original)
          :examples $ []
          :schema $ quote $ Fn app.schema/CardView (-> Tag)
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
                :on-click $ fn (e d!)
                  d! $ schema/Op :stack/close idx
          :examples $ []
          :schema $ quote $ Fn Tag Number (-> respo.schema/Component)
        'comp-container $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (states store)
            match store
              (:none) (comp-offline)
              (:some current)
                div
                  {} $ :style $ merge ui/global ui/fullscreen ui/row
                  match (:user current)
                    (:none)
                      comp-login $ >> states :login
                    (:some user)
                      match (:router current)
                        (:none) (<> "|No route")
                        (:some route)
                          match route
                            (:home)
                              comp-stack (>> states :stack) (:stack current)
                            (:profile members) (comp-profile user members)
                            (:unknown original)
                              <> $ format-cirru-edn original
                  =- :v
                  comp-navigation (:logged-in? current) (:count current)
                  comp-status-color $ :color current
                  if dev?
                    Option :some $ comp-inspect |Store current $ {} (:bottom 80) (:left 0) (:max-width |100%)
                    Option :none
                  comp-messages
                    filter-map-kv
                      :messages $ :session current
                      fn (id message)
                        MapEntryDecision :keep id $ {}
                          :id $ :id message
                          :text $ :text message
                    {}
                    fn (info d!)
                      hint-fn $ Fn (Map Tag Dynamic)
                        Fn app.schema/Op $ -> Unit
                        -> Unit
                      d! $ schema/Op :session/remove-message $ decode-map-as
                        .unwrap $ get info :id
                        , 'String
                  if dev?
                    Option :some $ comp-reel (:reel-length current) ({})
                    Option :none
          :examples $ []
          :schema $ quote $ Fn (Map Dynamic Dynamic) (Option app.schema/Store) (-> respo.schema/Component)
        'comp-offline $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-offline ()
            div
              {} $ :style $ merge ui/global ui/fullscreen ui/column-dispersive
                {} $ :background-color $ :theme config/site
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
                  :on-click $ fn (e d!)
                    d! $ schema/Op :effect/connect
                <> "|No connection..." $ {} (:font-family ui/font-fancy) (:font-size 24)
          :examples $ []
          :schema $ quote $ Fn (-> respo.schema/Component)
        'comp-reply $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-reply (reply)
            div
              {} $ :style $ {} (:padding |8px)
                :border-bottom $ str "|1px solid " $ hsl 0 0 90
              div ({})
                <> $ str |@ $ author-label (:author reply)
                space-x 8
                <> $ format-time $ :time reply
              div ({})
                <> $ :content reply
          :examples $ []
          :schema $ quote $ Fn app.schema/ReplyView (-> respo.schema/Component)
        'comp-stack $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-stack (states stack)
            list->
              {} $ :style $ merge ui/expand ui/row
              -> stack
                map-indexed $ fn (idx card)
                  [] idx $ div
                    {} $ :style $ merge ui/column
                      {} (:width 400) (:height |100%)
                        :border-right $ str "|1px solid " $ hsl 0 0 90
                    comp-card-header (card-name card) idx
                    match card
                      (:topics topics)
                        comp-topics (>> states :chat) topics
                      (:topic maybe-topic)
                        match maybe-topic
                          (:none)
                            div ({}) (<> "|Topic not found")
                          (:some topic)
                            comp-topic
                              >> states $ str :topic $ :id topic
                              , topic
                      (:unknown original) (comp-unknown-card original)
                concat $ [] $ [] 999 (comp-start)
          :examples $ []
          :schema $ quote $ Fn (Map Dynamic Dynamic) (List app.schema/CardView) (-> respo.schema/Component)
        'comp-start $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-start ()
            div
              {} $ :style $ {} (:padding "|16px 40px")
              div ({}) (<> |Start...)
              space-y 16
              div ({})
                button $ {} (:style ui/button) (:inner-text "|Open Chat")
                  :on-click $ fn (e d!)
                    d! $ schema/Op :stack/add $ schema/Stack :name :topics :data nil
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
          :schema $ quote $ Fn (-> respo.schema/Component)
        'comp-status-color $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-status-color (color)
            div $ {} $ :style
              let
                  size 24
                {} (:width size) (:height size) (:position :absolute) (:bottom 60) (:left 8) (:background-color color) (:border-radius |50%) (:opacity 0.6) (:pointer-events :none)
          :examples $ []
          :schema $ quote $ Fn String (-> respo.schema/Component)
        'comp-topic $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-topic (states topic)
            let
                cursor $ decode-map-as
                  .unwrap-or (get states :cursor) ([])
                  List Dynamic
                state $ decode-map-as
                  .unwrap-or (get states :data)
                    {} $ :draft |
                  Map Tag String
              div
                {} $ :style $ merge ui/expand ui/column
                  {} $ :border-top $ str "|1px solid " (hsl 0 0 88)
                div
                  {} $ :style $ {} (:padding 8)
                  span $ {} $ :inner-text (:content topic)
                div
                  {} $ :style $ {} (:padding 8)
                    :border-bottom $ str "|1px solid " $ hsl 0 0 90
                  <>
                    str |@ $ author-label $ :author topic
                    {} $ :color $ hsl 0 0 50
                  space-x 8
                  <>
                    format-time $ :time topic
                    {}
                      :color $ hsl 0 0 70
                      :font-weight 300
                      :font-family ui/font-fancy
                div
                  {} $ :style $ merge ui/expand ({})
                  list-> ({})
                    map
                      replies-in-order $ :replies topic
                      fn (reply)
                        [] (:id reply) (comp-reply reply)
                  space-y 80
                div
                  {} $ :style $ merge ui/row
                    {} $ :border-top $ str "|1px solid " (hsl 0 0 90)
                  textarea $ {}
                    :style $ merge ui/expand ui/textarea
                    :value $ .unwrap-or (get state :draft) |
                    :placeholder |Reply...
                    :on-change $ fn (e d!)
                      d! $ schema/Op :states cursor $ assoc state :draft (schema/event-value e)
                  space-x 8
                  div ({})
                    button $ {} (:inner-text |Send) (:style ui/button)
                      :on-click $ fn (e d!)
                        let
                            content $ trim $ .unwrap-or (get state :draft) |
                          when
                            not $ blank? content
                            d! $ schema/Op :topic/reply $ schema/ReplyPayload :topic-id (:id topic) :text content
                            d! $ schema/Op :states cursor $ assoc state :draft |
          :examples $ []
          :schema $ quote $ Fn (Map Dynamic Dynamic) app.schema/TopicView (-> respo.schema/Component)
        'comp-topic-item $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-topic-item (topic)
            div
              {} $ :style $ {} (:padding 8)
                :border-top $ str "|1px solid " $ hsl 0 0 88
              div ({})
                span $ {}
                  :inner-text $ :content topic
                  :on-click $ fn (e d!)
                    d! $ schema/Op :stack/add $ schema/Stack :name :topic :data (:id topic)
              div ({})
                <>
                  str |@ $ author-label $ :author topic
                  {} $ :color $ hsl 0 0 50
                space-x 8
                <>
                  format-time $ :time topic
                  {}
                    :color $ hsl 0 0 70
                    :font-weight 300
                    :font-family ui/font-fancy
          :examples $ []
          :schema $ quote $ Fn app.schema/TopicView (-> respo.schema/Component)
        'comp-topics $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-topics (states data)
            let
                create-plugin $ use-prompt (>> states :new)
                  {} $ :title "|Create Topic"
              div
                {} $ :style $ merge ui/expand ui/column ({})
                div
                  {} $ :style $ merge ui/row-middle
                    {} $ :padding "|4px 8px"
                  <> |Topics
                  space-x 16
                  a $ {} (:style ui/link) (:inner-text |New)
                    :on-click $ fn (e d!)
                      hint-fn $ Fn respo.schema/RespoEvent
                        Fn *dispatch-op $ -> Unit
                        -> Unit
                      .show create-plugin d! $ fn (text)
                        hint-fn $ Fn String $ -> Unit
                        d! $ schema/Op :topic/add text
                        , &unit
                div
                  {} $ :style ui/expand
                  list->
                    {} $ :style $ {}
                      :border-bottom $ str "|1px solid " $ hsl 0 0 80
                    map (topics-in-order data)
                      fn (topic)
                        [] (:id topic) (comp-topic-item topic)
                  space-y 100
                .render create-plugin
          :examples $ []
          :schema $ quote $ Fn (Map Dynamic Dynamic) (Map String app.schema/TopicView) (-> respo.schema/Component)
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
          :schema $ quote $ Fn app.schema/Stack (-> respo.schema/Component)
        'format-time $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn format-time (time)
            decode-map-as
              .!format (dayjs time) |HH:mm
              , 'String
          :examples $ []
          :schema $ quote $ Fn Number (-> String) (:features :js-ffi)
        'replies-in-order $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn replies-in-order (replies)
            .sort-by
              map-list-kv replies $ fn (id value) value
              fn (value) (:time value)
          :examples $ []
          :schema $ quote $ Fn (Map String app.schema/ReplyView)
            -> $ List app.schema/ReplyView
        'topics-in-order $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn topics-in-order (topics)
            .sort-by
              map-list-kv topics $ fn (id value) value
              fn (value)
                negate $ :time value
          :examples $ []
          :schema $ quote $ Fn (Map String app.schema/TopicView)
            -> $ List app.schema/TopicView
          :tests $ [] $ %{} 'TestEntry
            :name |topic-descending-reply-ascending-and-no-deduplication
            :code $ quote $ let
                older $ schema/TopicView :id |old :content "|旧话题" :time 10 :author (Option :none) :replies $ {}
                newer $ assoc (assoc older :id |new) :time 20
                reply $ schema/ReplyView :id |first :content "|先回复" :time 11 :author $ Option :none
                later $ assoc (assoc reply :id |later) :time 21
              assert= ([] |new |old)
                map
                  topics-in-order $ {} (|a older) (|b newer)
                  fn (topic) (:id topic)
              assert= ([] |first |later)
                map
                  replies-in-order $ {} (|a later) (|b reply)
                  fn (value) (:id value)
              assert= 2 $ count $ topics-in-order
                {} (|one older) (|two older)
              assert= ([])
                topics-in-order $ {}
              assert= ([])
                replies-in-order $ {}
            :tags $ #{} :migration :unit
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require
            respo-ui.core :refer $ hsl
            respo-ui.core :as ui
            respo.core :refer $ defcomp <> >> div span button input textarea pre list-> a code
            respo.comp.inspect :refer $ comp-inspect
            respo.comp.space :refer $ space-x space-y
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
                cursor $ decode-map-as
                  .unwrap-or (get states :cursor) ([])
                  List Dynamic
                state $ decode-map-as
                  .unwrap-or (get states :data) initial-state
                  Map Tag String
              div
                {} $ :style $ merge ui/flex ui/center
                div ({})
                  div
                    {} $ :style $ {}
                    div ({})
                      input $ {} (:placeholder |Username)
                        :value $ .unwrap-or (get state :username) |
                        :style ui/input
                        :on-input $ fn (e d!)
                          d! $ schema/Op :states cursor $ assoc state :username (schema/event-value e)
                    space-y 8
                    div ({})
                      input $ {} (:placeholder |Password)
                        :value $ .unwrap-or (get state :password) |
                        :style ui/input
                        :on-input $ fn (e d!)
                          d! $ schema/Op :states cursor $ assoc state :password (schema/event-value e)
                        :type |password
                  space-y 8
                  div
                    {} $ :style $ {} (:text-align :right)
                    span $ {} (:inner-text "|Sign up")
                      :style $ merge ui/link
                      :on-click $ on-submit
                        .unwrap-or (get state :username) |
                        .unwrap-or (get state :password) |
                        , true
                    space-x 8
                    span $ {} (:inner-text "|Log in")
                      :style $ merge ui/link
                      :on-click $ on-submit
                        .unwrap-or (get state :username) |
                        .unwrap-or (get state :password) |
                        , false
          :examples $ []
          :schema $ quote $ Fn (Map Dynamic Dynamic) (-> respo.schema/Component)
        'initial-state $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def initial-state
            {} (:username |) (:password |)
          :examples $ []
          :schema $ quote $ Map Tag String
        'on-submit $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn on-submit (username password signup?)
            fn (event dispatch!)
              hint-fn $ Fn (Map Tag Dynamic)
                Fn app.schema/Op $ -> Unit
                -> Unit
              dispatch! $ if signup?
                schema/Op :user/sign-up $ [] username password
                schema/Op :user/log-in $ [] username password
              browser/storage-set! (:storage-key config/site)
                format-cirru-edn $ [] username password
          :examples $ []
          :schema $ quote $ Fn String String Bool
            -> $ Fn (Map Tag Dynamic)
              Fn app.schema/Op $ -> Unit
              -> Unit
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.login
          :require
            respo.core :refer $ defcomp <> div input button span
            respo.comp.space :refer $ space-x space-y
            respo.comp.inspect :refer $ comp-inspect
            respo-ui.core :as ui
            app.schema :as schema
            app.config :as config
            js-ffi.browser :as browser
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
                      d! $ schema/Op :router/change $ assoc schema/router :name :home
                    :style $ {} $ :cursor :pointer
                  <> |Ploy
              div
                {}
                  :style $ merge ui/row $ {} (:cursor |pointer)
                  :on-click $ fn (e d!)
                    d! $ schema/Op :router/change $ assoc schema/router :name :profile
                <> $ if logged-in? |Me |Guest
                space-x 4
                <> $ str count-members
          :examples $ []
          :schema $ quote $ Fn Bool Number (-> respo.schema/Component)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.navigation
          :require
            respo-ui.core :refer $ hsl
            respo-ui.core :as ui
            respo.comp.space :refer $ space-x space-y
            respo.core :refer $ defcomp <> span div
            app.config :as config
            app.schema :as schema
    'app.comp.profile $ %{} 'FileEntry
      :defs $ {} $ 'comp-profile
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-profile (user members)
            div
              {} $ :style $ merge ui/flex
                {} $ :padding 16
              div
                {} $ :style $ {} (:font-family ui/font-fancy) (:font-size 32) (:font-weight 100)
                <> $ str "|Hello! " $ :name user
              space-y 16
              div
                {} $ :style ui/row
                <> |Members:
                space-x 8
                list->
                  {} $ :style ui/row
                  map-list-kv members $ fn (id username)
                    [] id $ div
                      {} $ :style $ {} (:padding "|0 8px")
                        :border $ str "|1px solid " $ hsl 0 0 80
                        :border-radius |16px
                        :margin "|0 4px"
                      <> $ .unwrap-or username |GUEST
              space-y 48
              div ({})
                button
                  {}
                    :style $ merge ui/button
                    :on-click $ fn (e d!)
                      browser/location-replace! $ str
                        .-origin $ browser/location-host
                        , |?time= $ host/now-ms
                  <> |Refresh
                space-x 8
                button
                  {}
                    :style $ merge ui/button $ {} (:color :red) (:border-color :red)
                    :on-click $ fn (e dispatch!)
                      dispatch! $ schema/Op :user/log-out
                      browser/storage-remove! $ :storage-key config/site
                  <> "|Log out"
          :examples $ []
          :schema $ quote $ Fn app.schema/UserView
            Map Number $ Option String
            -> respo.schema/Component
            :features :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.profile
          :require
            respo-ui.core :refer $ hsl
            app.schema :as schema
            respo-ui.core :as ui
            respo.core :refer $ defcomp list-> <> span div button
            respo.comp.space :refer $ space-x space-y
            app.config :as config
            js-ffi.browser :as browser
            js-ffi.shared :as host
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
          :schema $ quote $ Fn Tag
            Option $ Map Tag Dynamic
            -> respo.schema/Element
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
          :schema $ quote Bool
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site
            schema/Site :port 11026 :title |Polygonum :icon |https://cdn.tiye.me/logo/cumulo.png :theme |#eeeeff :storage-key |polygonum :storage-file |storage.cirru
          :examples $ []
          :schema $ quote app.schema/Site
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
          :require $ app.schema :as schema
    'app.protocol $ %{} 'FileEntry
      :defs $ {}
        'data-map $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn data-map (raw)
            if (struct? raw)
              decode-map-as (&struct:to-map raw) (Map Tag Dynamic)
              decode-map-as raw $ Map Tag Dynamic
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Map Tag Dynamic
        'decode-author-id $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-author-id (raw)
            if (enum? raw)
              match raw
                (:none) (Option :none)
                (:some payload) (decode-optional-string payload)
                _ $ raise "|Invalid legacy author ID"
              decode-optional-string raw
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Option String
        'decode-card-view $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-card-view (raw)
            if (enum? raw)
              match raw
                (:topics payload)
                  CardView :topics $ normalize-items payload decode-topic-view
                (:topic payload)
                  CardView :topic $ decode-option payload decode-topic-view
                (:unknown payload)
                  CardView :unknown $ decode-stack payload
                _ $ raise "|Invalid card view variant"
              raise "|Expected card view enum"
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> app.schema/CardView)
        'decode-credentials $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-credentials (raw)
            let
                credentials $ decode-map-as raw $ List String
              if
                = 2 $ count credentials
                , credentials $ raise "|Expected two credential strings"
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ List String
        'decode-database $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-database (raw)
            let
                data $ data-map raw
                normalized $ -> data
                  assoc :sessions $ filter-map-kv
                    decode-map-as
                      .unwrap-or (get data :sessions) ({})
                      Map Number Dynamic
                    fn (id session)
                      MapEntryDecision :keep id $ normalize-session session
                  assoc :users $ normalize-items
                    .unwrap-or (get data :users) ({})
                    , normalize-user
                  assoc :topics $ normalize-items
                    .unwrap-or (get data :topics) ({})
                    , normalize-topic
              decode-map-as normalized 'app.schema/Db
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> app.schema/Db)
          :tests $ [] $ %{} 'TestEntry
            :name |legacy-author-options-archive-roundtrip-and-rejection
            :code $ quote $ let
                raw $ {}
                  :sessions $ {} $ 7
                    {} (:id 7)
                      :user-id $ Option :some |u
                      :nickname nil
                      :router $ {} (:name :home) (:title nil) (:data nil) (:router nil)
                      :messages $ {} $ |note
                        {} (:id |note) (:text "|提示")
                      :stack $ [] $ {} (:name :topic) (:data |t)
                  :users $ {} $ |u
                    {} (:id |u) (:name "|用户") (:nickname nil) (:avatar nil) (:password |synthetic-hash)
                  :topics $ {} $ |t
                    {} (:id |t) (:content "|已有话题 🌸") (:time 11)
                      :author-id $ Option :some $ Option :some |u
                      :replies $ {} $ |r
                        {} (:id |r) (:content "|已有回复") (:time 12)
                          :author-id $ Option :some nil
                db $ decode-database raw
                topic $ .unwrap $ get (:topics db) |t
                reply $ .unwrap $ get (:replies topic) |r
                session $ .unwrap $ get (:sessions db) 7
              assert= "|已有话题 🌸" $ :content topic
              assert= 11 $ :time topic
              assert= (Option :some |u) (:author-id topic)
              assert= (Option :none) (:author-id reply)
              assert= 12 $ :time reply
              assert= (Option :some |u) (:user-id session)
              assert= 1 $ count $ :stack session
              assert= db $ decode-database $ parse-cirru-edn (format-cirru-edn db)
              assert= true $ empty? $ :topics
                decode-database $ {}
              assert= true $ try
                do
                  decode-database $ assoc raw :unexpected "|must reject"
                  , false
                fn (error) true
              assert= true $ try
                do
                  decode-database $ assoc raw :topics $ {}
                    |broken $ {} $ :replies ({})
                  , false
                fn (error) true
              assert= true $ try
                do (decode-author-id 123) false
                fn (error) true
            :tags $ #{} :migration :unit
        'decode-op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-op (raw)
            if (enum? raw)
              match raw
                (:session/connect) (Op :session/connect)
                (:session/disconnect) (Op :session/disconnect)
                (:session/remove-message payload)
                  Op :session/remove-message $ if (string? payload) payload $ decode-map-as
                    .unwrap $ get (data-map payload) :id
                    , 'String
                (:user/log-in payload)
                  Op :user/log-in $ decode-credentials payload
                (:user/sign-up payload)
                  Op :user/sign-up $ decode-credentials payload
                (:user/log-out) (Op :user/log-out)
                (:router/change payload)
                  Op :router/change $ decode-router payload
                (:states cursor state)
                  Op :states
                    decode-map-as cursor $ List Dynamic
                    , state
                (:effect/connect) (Op :effect/connect)
                (:reel/reset) (Op :reel/reset)
                (:reel/merge) (Op :reel/merge)
                (:effect/persist) (Op :effect/persist)
                (:stack/add payload)
                  Op :stack/add $ decode-stack payload
                (:stack/close payload)
                  Op :stack/close $ decode-map-as payload 'Number
                (:topic/add payload)
                  Op :topic/add $ decode-map-as payload 'String
                (:topic/reply payload)
                  Op :topic/reply $ decode-map-as (data-map payload) 'app.schema/ReplyPayload
                _ $ raise "|Unsupported operation"
              raise "|Expected operation enum"
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> app.schema/Op)
          :tests $ [] $ %{} 'TestEntry (:name |all-operation-wire-roundtrips-and-invalid-input)
            :code $ quote $ do
              foldl
                [] (Op :session/connect) (Op :session/disconnect) (Op :session/remove-message |note)
                  Op :user/log-in $ [] "|用户" "|密码"
                  Op :user/sign-up $ [] "|用户" "|密码"
                  Op :user/log-out
                  Op :router/change $ assoc router :name :profile
                  Op :stack/add $ Stack :name :topics :data nil
                  Op :stack/add $ Stack :name :topic :data |t
                  Op :stack/close 0
                  Op :topic/add "|中文 🌸"
                  Op :topic/reply $ ReplyPayload :topic-id |t :text "|回复"
                  Op :states ([] :topic)
                    {} $ :draft "|草稿"
                  Op :effect/connect
                  Op :reel/reset
                  Op :reel/merge
                  Op :effect/persist
                , &unit $ fn (acc op)
                  assert= op $ decode-op $ parse-cirru-edn
                    format-cirru-edn $ encode-op op
              assert= true $ try
                do
                  decode-op $ :: :unknown
                  , false
                fn (error) true
              assert= true $ try
                do
                  decode-op $ :: :stack/close |bad
                  , false
                fn (error) true
              assert= true $ try
                do
                  decode-credentials $ [] |one
                  , false
                fn (error) true
            :tags $ #{} :migration :unit
        'decode-option $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-option (raw decode)
            if (enum? raw)
              match raw
                (:none) (Option :none)
                (:some payload)
                  Option :some $ decode payload
                _ $ raise "|Invalid optional wire value"
              raise "|Expected optional wire enum"
          :examples $ []
          :schema $ quote $ Fn Dynamic
            Fn Dynamic $ -> T
            -> $ Option T
            :generics T
        'decode-optional-string $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-optional-string (raw)
            if (nil? raw) (Option :none)
              if (enum? raw)
                match raw
                  (:none) (Option :none)
                  (:some value)
                    Option :some $ decode-map-as value 'String
                  _ $ raise |Invalid-optional-string
                Option :some $ decode-map-as raw 'String
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Option String
        'decode-reply-view $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-reply-view (raw)
            let
                data $ data-map raw
              ReplyView :id
                decode-map-as
                  .unwrap $ get data :id
                  , 'String
                , :content
                  decode-map-as
                    .unwrap $ get data :content
                    , 'String
                  , :time
                    decode-map-as
                      .unwrap $ get data :time
                      , 'Number
                    , :author $ decode-option
                      .unwrap $ get data :author
                      , decode-user-view
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> app.schema/ReplyView)
        'decode-route-view $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-route-view (raw)
            if (enum? raw)
              match raw
                (:home) (RouteView :home)
                (:profile payload)
                  RouteView :profile $ filter-map-kv
                    decode-map-as payload $ Map Number Dynamic
                    fn (id name)
                      MapEntryDecision :keep id $ decode-optional-string name
                (:unknown payload)
                  RouteView :unknown $ decode-router payload
                _ $ raise "|Invalid route view variant"
              raise "|Expected route view enum"
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> app.schema/RouteView)
        'decode-router $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-router (raw)
            decode-map-as (normalize-router raw) 'app.schema/Router
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> app.schema/Router)
        'decode-session $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-session (raw)
            let
                data $ data-map raw
              Session :id
                decode-map-as
                  .unwrap $ get data :id
                  , 'Number
                , :user-id
                  .and-then (get data :user-id) decode-optional-string
                  , :nickname
                    .and-then (get data :nickname) decode-optional-string
                    , :router
                      decode-router $ .unwrap $ get data :router
                      , :messages
                        normalize-items
                          .unwrap $ get data :messages
                          fn (message)
                            decode-map-as (data-map message) 'app.schema/Notification
                        , :stack $ map
                          decode-map-as
                            .unwrap $ get data :stack
                            List Dynamic
                          , decode-stack
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> app.schema/Session)
        'decode-stack $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-stack (raw)
            decode-map-as (data-map raw) 'app.schema/Stack
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> app.schema/Stack)
        'decode-store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-store (raw)
            let
                data $ data-map raw
              Store :logged-in?
                decode-map-as
                  .unwrap $ get data :logged-in?
                  , 'Bool
                , :session
                  decode-session $ .unwrap $ get data :session
                  , :reel-length
                    decode-map-as
                      .unwrap $ get data :reel-length
                      , 'Number
                    , :user
                      decode-option
                        .unwrap $ get data :user
                        , decode-user-view
                      , :router
                        decode-option
                          .unwrap $ get data :router
                          , decode-route-view
                        , :stack
                          map
                            decode-map-as
                              .unwrap $ get data :stack
                              List Dynamic
                            , decode-card-view
                          , :count
                            decode-map-as
                              .unwrap $ get data :count
                              , 'Number
                            , :color $ decode-map-as
                              .unwrap $ get data :color
                              , 'String
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> app.schema/Store)
          :tests $ [] $ %{} 'TestEntry
            :name |nominal-store-author-options-cards-and-incremental-patch
            :code $ quote $ let
                user $ UserView :id |u :name "|用户" :nickname (Option :some "|昵称") :avatar $ Option :none
                reply $ ReplyView :id |r :content "|回复 🌸" :time 2 :author $ Option :some user
                topic $ TopicView :id |t :content "|话题" :time 1 :author (Option :some user) :replies $ {} (|r reply)
                session $ Session :id 7 :user-id (Option :some |u) :nickname (Option :none) :router router :messages
                  {} $ |note $ Notification :id |note :text "|提示"
                  , :stack $ [] (Stack :name :topics :data nil)
                initial $ Store :logged-in? true :session session :reel-length 4 :user (Option :some user) :router
                  Option :some $ RouteView :home
                  , :stack
                    []
                      CardView :topics $ {} $ |t topic
                      CardView :topic $ Option :none
                      CardView :unknown $ Stack :name :future :data $ {} (:draft "|保留")
                    , :count 2 :color |#abcdef
                wire $ parse-cirru-edn $ format-cirru-edn initial
                changed $ -> initial
                  assoc :router $ Option :some $ RouteView :profile
                    {}
                      7 $ Option :some "|用户"
                      8 $ Option :none
                  assoc :stack $ [] $ CardView :topic
                    Option :some $ assoc topic :replies $ {}
                      |r $ assoc reply :content "|已编辑"
                changes $ diff-twig initial changed $ {} (:key :id)
                patched $ try-patch-twig wire $ decode-changes
                  parse-cirru-edn $ format-cirru-edn changes
              assert= initial $ decode-store wire
              match patched
                (:ok value)
                  assert= changed $ decode-store value
                (:err error)
                  raise $ patch-error-message error
              let
                  guest $ -> initial (assoc :logged-in? false)
                    assoc :user $ Option :none
                    assoc :router $ Option :none
                    assoc :stack $ []
                    assoc :session $ assoc session :user-id $ Option :none
                assert= guest $ decode-store $ parse-cirru-edn (format-cirru-edn guest)
              let
                  unknown $ assoc initial :router $ Option :some
                    RouteView :unknown $ assoc router :name :future
                assert= unknown $ decode-store $ parse-cirru-edn (format-cirru-edn unknown)
              assert= true $ try
                do
                  decode-store $ assoc (data-map wire) :count |bad
                  , false
                fn (error) true
            :tags $ #{} :migration :unit
        'decode-topic-view $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-topic-view (raw)
            let
                data $ data-map raw
              TopicView :id
                decode-map-as
                  .unwrap $ get data :id
                  , 'String
                , :content
                  decode-map-as
                    .unwrap $ get data :content
                    , 'String
                  , :time
                    decode-map-as
                      .unwrap $ get data :time
                      , 'Number
                    , :author
                      decode-option
                        .unwrap $ get data :author
                        , decode-user-view
                      , :replies $ normalize-items
                        .unwrap $ get data :replies
                        , decode-reply-view
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> app.schema/TopicView)
        'decode-user-view $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-user-view (raw)
            decode-map-as
              -> (data-map raw) (without-legacy-nil :nickname) (without-legacy-nil :avatar)
              , 'app.schema/UserView
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> app.schema/UserView)
        'encode-op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn encode-op (op)
            match op
              (:session/connect) (:: :session/connect)
              (:session/disconnect) (:: :session/disconnect)
              (:session/remove-message id)
                :: :session/remove-message $ {} $ :id id
              (:user/log-in payload) (:: :user/log-in payload)
              (:user/sign-up payload) (:: :user/sign-up payload)
              (:user/log-out) (:: :user/log-out)
              (:router/change route)
                let
                    data $ {}
                      :name $ :name route
                      :data $ :data route
                      :router $ :router route
                  :: :router/change $ .fold (:title route)
                    fn () data
                    fn (title) (assoc data :title title)
              (:states cursor state) (:: :states cursor state)
              (:effect/connect) (:: :effect/connect)
              (:reel/reset) (:: :reel/reset)
              (:reel/merge) (:: :reel/merge)
              (:effect/persist) (:: :effect/persist)
              (:stack/add payload)
                :: :stack/add $ {}
                  :name $ :name payload
                  :data $ :data payload
              (:stack/close payload) (:: :stack/close payload)
              (:topic/add payload) (:: :topic/add payload)
              (:topic/reply payload)
                :: :topic/reply $ {}
                  :topic-id $ :topic-id payload
                  :text $ :text payload
          :examples $ []
          :schema $ quote $ Fn app.schema/Op (-> AnyEnum)
        'normalize-author $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-author (raw)
            let
                data $ data-map raw
              match
                .and-then (get data :author-id) decode-author-id
                (:none) (dissoc data :author-id)
                (:some value) (assoc data :author-id value)
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Map Tag Dynamic
        'normalize-items $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-items (raw f)
            filter-map-kv
              decode-map-as raw $ Map String Dynamic
              fn (id item)
                MapEntryDecision :keep id $ f item
          :examples $ []
          :schema $ quote $ Fn Dynamic
            Fn Dynamic $ -> T
            -> $ Map String T
            :generics T
          :tests $ [] $ %{} 'TestEntry (:name |preserves-decoder-result-type)
            :code $ quote $ assert=
              {} $ |a 5
              normalize-items
                {} $ |a 4
                fn (raw)
                  inc $ decode-map-as raw 'Number
            :tags $ #{} :migration :unit
        'normalize-router $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-router (raw)
            without-legacy-nil
              merge
                {} (:name :home) (:data nil) (:router nil)
                data-map raw
              , :title
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Map Tag Dynamic
        'normalize-session $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-session (raw)
            let
                data $ data-map raw
              -> data (without-legacy-nil :user-id) (without-legacy-nil :nickname)
                assoc :router $ normalize-router $ .unwrap-or (get data :router)
                  {} $ :name :home
                assoc :messages $ normalize-items
                  .unwrap-or (get data :messages) ({})
                  , data-map
                assoc :stack $ map
                  decode-map-as
                    .unwrap-or (get data :stack) ([])
                    List Dynamic
                  , data-map
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Map Tag Dynamic
        'normalize-topic $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-topic (raw)
            let
                data $ normalize-author raw
              assoc data :replies $ normalize-items
                .unwrap-or (get data :replies) ({})
                , normalize-author
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Map Tag Dynamic
        'normalize-user $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-user (raw)
            -> (data-map raw) (without-legacy-nil :nickname) (without-legacy-nil :avatar)
          :examples $ []
          :schema $ quote $ Fn Dynamic
            -> $ Map Tag Dynamic
        'without-legacy-nil $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn without-legacy-nil (data key)
            match
              .and-then (get data key) decode-optional-string
              (:none) (dissoc data key)
              (:some value) (assoc data key value)
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) Tag
            -> $ Map Tag Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.protocol
          :require
            app.schema :refer $ Op Router Stack Session Notification ReplyPayload Store UserView TopicView ReplyView CardView RouteView router
            recollect.diff :refer $ diff-twig
            recollect.patch :refer $ try-patch-twig patch-error-message
            recollect.schema :refer $ decode-changes
    'app.schema $ %{} 'FileEntry
      :defs $ {}
        'CardView $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum CardView
            :topics $ Map String app.schema/TopicView
            :topic $ Option app.schema/TopicView
            :unknown app.schema/Stack
          :examples $ []
          :schema $ quote EnumDef
        'Db $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Db
            :sessions $ Map Number app.schema/Session
            :users $ Map String app.schema/User
            :topics $ Map String app.schema/Topic
          :examples $ []
          :schema $ quote StructDef
        'Notification $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Notification (:id String) (:text String)
          :examples $ []
          :schema $ quote StructDef
        'Op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum Op (:session/connect) (:session/disconnect) (:session/remove-message String)
            :user/log-in $ List String
            :user/sign-up $ List String
            :user/log-out
            :router/change app.schema/Router
            :stack/add app.schema/Stack
            :stack/close Number
            :topic/add String
            :topic/reply app.schema/ReplyPayload
            :states (List Dynamic) Dynamic
            :effect/connect
            :reel/reset
            :reel/merge
            :effect/persist
          :examples $ []
          :schema $ quote EnumDef
        'Reply $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Reply (:id String) (:content String)
            :author-id $ Option String
            :time Number
          :examples $ []
          :schema $ quote StructDef
        'ReplyPayload $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct ReplyPayload (:topic-id String) (:text String)
          :examples $ []
          :schema $ quote StructDef
        'ReplyView $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct ReplyView (:id String) (:content String) (:time Number)
            :author $ Option app.schema/UserView
          :examples $ []
          :schema $ quote StructDef
        'RouteView $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum RouteView (:home)
            :profile $ Map Number $ Option String
            :unknown app.schema/Router
          :examples $ []
          :schema $ quote EnumDef
        'Router $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Router (:name Tag)
            :title $ Option String
            :data Dynamic
            :router Dynamic
          :examples $ []
          :schema $ quote StructDef
        'Session $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Session (:id Number)
            :user-id $ Option String
            :nickname $ Option String
            :router app.schema/Router
            :messages $ Map String app.schema/Notification
            :stack $ List app.schema/Stack
          :examples $ []
          :schema $ quote StructDef
        'Site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Site (:port Number) (:title String) (:icon String) (:theme String) (:storage-key String) (:storage-file String)
          :examples $ []
          :schema $ quote StructDef
        'Stack $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Stack (:name Tag) (:data Dynamic)
          :examples $ []
          :schema $ quote StructDef
        'Store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Store (:logged-in? Bool) (:session app.schema/Session) (:reel-length Number)
            :user $ Option app.schema/UserView
            :router $ Option app.schema/RouteView
            :stack $ List app.schema/CardView
            :count Number
            :color String
          :examples $ []
          :schema $ quote StructDef
        'Topic $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Topic (:id String) (:content String) (:time Number)
            :replies $ Map String app.schema/Reply
            :author-id $ Option String
          :examples $ []
          :schema $ quote StructDef
        'TopicView $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct TopicView (:id String) (:content String) (:time Number)
            :author $ Option app.schema/UserView
            :replies $ Map String app.schema/ReplyView
          :examples $ []
          :schema $ quote StructDef
        'User $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct User (:id String) (:name String) (:password String)
            :nickname $ Option String
            :avatar $ Option String
          :examples $ []
          :schema $ quote StructDef
        'UserView $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct UserView (:id String) (:name String)
            :nickname $ Option String
            :avatar $ Option String
          :examples $ []
          :schema $ quote StructDef
        'database $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def database
            Db :sessions ({}) :users ({}) :topics $ {}
          :examples $ []
          :schema $ quote app.schema/Db
        'event-value $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn event-value (event)
            let
                fields $ if (struct? event) (&struct:to-map event)
                  decode-map-as event $ Map Tag Dynamic
              match (get fields :value)
                (:some value)
                  if (nil? value) | $ decode-map-as value 'String
                (:none) |
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> String)
          :tests $ [] $ %{} 'TestEntry (:name |checked-unicode-text-input)
            :code $ quote $ do
              assert= "|小猫 🌸" $ event-value $ {} (:value "|小猫 🌸")
              assert= | $ event-value $ {}
              assert= | $ event-value $ {} (:value |)
            :tags $ #{} :migration :unit
        'router $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def router
            Router :name :home :title (Option :none) :data nil :router nil
          :examples $ []
          :schema $ quote app.schema/Router
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.schema
    'app.server $ %{} 'FileEntry
      :defs $ {}
        '*client-caches $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *client-caches ({})
          :examples $ []
          :schema $ quote $ Ref (Map Number app.schema/Store)
        '*initial-db $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *initial-db
            if (path-exists? storage-file)
              match
                .read-text $ FsPath :value storage-file
                (:ok content) (parse-database content)
                (:err message) (raise message)
              , schema/database
          :examples $ []
          :schema $ quote $ Ref app.schema/Db
        '*reader-reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *reader-reel @*reel
          :examples $ []
          :schema $ quote $ Ref (cumulo-reel.core/ReelState app.schema/Db)
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *reel
            ReelState :base @*initial-db :db @*initial-db :records ([]) :merged? false
          :examples $ []
          :schema $ quote $ Ref (cumulo-reel.core/ReelState app.schema/Db)
        '*sync-pending? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *sync-pending? false
          :examples $ []
          :schema $ quote $ Ref Bool
        '*tasks $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *tasks ([])
          :examples $ []
          :schema $ quote $ Ref (List FfiTask)
        'changes-for $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn changes-for (old next)
            match old
              (:none)
                diff-twig nil next $ {} $ :key :id
              (:some previous)
                diff-twig previous next $ {} $ :key :id
          :examples $ []
          :schema $ quote $ Fn (Option app.schema/Store) app.schema/Store
            -> $ List recollect.schema/change-op
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op sid)
            match op
              (:effect/persist)
                when config/dev? $ persist-db!
              _ $ when
                or config/dev? $ match op
                  (:reel/reset) false
                  (:reel/merge) false
                  _ true
                let
                    previous @*reel
                    op-id $ generate-id!
                    op-time $ get-timestamp $ get-time!
                    next $ reel-reducer previous updater op sid op-id op-time config/dev?
                  when config/dev? $ println |Dispatch! sid
                  reset! *reel $ match op
                    (:reel/reset)
                      assoc next :db $ assoc (:db next) :sessions $ :sessions (:db previous)
                    _ next
            , &unit
          :examples $ []
          :schema $ quote $ Fn app.schema/Op Number (-> Unit)
        'get-backup-path! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn get-backup-path! ()
            let
                now $ calcit.std.date/extract-time $ get-time!
              join-path calcit-dirname |backups
                str $ .unwrap $ get now :month
                str
                  .unwrap $ get now :day
                  , |-snapshot.cirru
          :examples $ []
          :schema $ quote $ Fn (-> String)
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            println "|Running mode:" $ if config/dev? |dev |release
            identity @*reader-reel
            let
                port $ .fold (get-env |port)
                  fn () $ :port config/site
                  fn (raw)
                    .unwrap-or (parse-float raw) (:port config/site)
                server $ run-server! port
                render-timer $ set-interval! 200 $ fn () (render-loop!)
                persist-timer $ set-interval! 600000 $ fn () (persist-db!)
              reset! *tasks $ [] server render-timer persist-timer
              println "|Server started on port:" port
            on-control-c on-exit!
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit)
        'on-exit! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn on-exit! ()
            foldl @*tasks &unit $ fn (acc task) (.cancel! task)
            reset! *tasks $ []
            persist-db!
            quit! 0
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit)
        'parse-database $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn parse-database (content)
            protocol/decode-database $ parse-cirru-edn content
          :examples $ []
          :schema $ quote $ Fn String (-> app.schema/Db)
        'parse-op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn parse-op (content)
            protocol/decode-op $ parse-cirru-edn content
          :examples $ []
          :schema $ quote $ Fn String (-> app.schema/Op)
        'persist-db! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn persist-db! ()
            let
                content $ format-cirru-edn $ assoc (:db @*reel) :sessions ({})
              check-write-file! storage-file content
              check-write-file! (get-backup-path!) content
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit)
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! ()
            when (not config/dev?) (raise |Reloading-only-happens-in-dev-mode)
            clear-twig-caches!
            reset! *reel $ refresh-reel @*reel @*initial-db replay-op
            reset! *reader-reel @*reel
            sync-clients! @*reader-reel
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit)
        'render-loop! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-loop! ()
            when
              or @*sync-pending? $ not $ identical? @*reader-reel @*reel
              reset! *sync-pending? false
              reset! *reader-reel @*reel
              sync-clients! @*reader-reel
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit)
        'replay-op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn replay-op (db raw-op raw-sid raw-id raw-time)
            updater db (protocol/decode-op raw-op) (decode-map-as raw-sid 'Number) (decode-map-as raw-id 'String) (decode-map-as raw-time 'Number)
          :examples $ []
          :schema $ quote $ Fn app.schema/Db Dynamic Dynamic Dynamic Dynamic (-> app.schema/Db)
          :tests $ [] $ %{} 'TestEntry
            :name |typed-refresh-replays-records-without-dropping-sessions
            :code $ quote $ let
                initial $ assert-type
                  ReelState :base schema/database :db schema/database :records ([]) :merged? false
                  quote $ cumulo-reel.core/ReelState app.schema/Db
                connected $ reel-reducer initial updater (schema/Op :session/connect) 1 |c 0 true
                changed $ reel-reducer connected updater (schema/Op :topic/add "|重放话题 🌸") 1 |t 1 true
                replayed $ refresh-reel changed schema/database replay-op
              assert= (:db changed) (:db replayed)
              assert= 2 $ count $ :records replayed
              assert= "|重放话题 🌸" $ :content $ .unwrap
                get
                  :topics $ :db replayed
                  , |t
            :tags $ #{} :migration :unit
        'run-server! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn run-server! (port)
            wss-serve!
              {} $ :port port
              fn (data)
                match data
                  (:connect sid)
                    dispatch! (schema/Op :session/connect) sid
                  (:message sid content)
                    try
                      dispatch! (parse-op content) sid
                      fn (_error) (eprintln |Rejected-client-operation sid) &unit
                  (:disconnect sid)
                    do (swap! *client-caches dissoc sid)
                      dispatch! (schema/Op :session/disconnect) sid
                  (:blob sid payload) (eprintln |Unsupported-binary-message sid)
                , &unit
              .unwrap-or (get-env |POLYGONUM_BIND_ADDRESS) |0.0.0.0
          :examples $ []
          :schema $ quote $ Fn Number (-> FfiTask)
        'storage-file $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def storage-file
            if (empty? calcit-dirname)
              str calcit-dirname $ :storage-file config/site
              str calcit-dirname |/ $ :storage-file config/site
          :examples $ []
          :schema $ quote String
        'sync-client! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn sync-client! (sid reel)
            when (identical? reel @*reader-reel)
              match
                get
                  :sessions $ :db reel
                  , sid
                (:none) (swap! *client-caches dissoc sid)
                (:some session)
                  let
                      next $ twig-container (:db reel) session $ count (:records reel)
                      changes $ changes-for (get @*client-caches sid) next
                    when
                      not $ empty? changes
                      match
                        wss-send! sid $ format-cirru-edn $ :: :patch changes
                        (:accepted) (swap! *client-caches assoc sid next)
                        (:backpressured) (reset! *sync-pending? true)
                        (:closed) (swap! *client-caches dissoc sid)
                        (:too-large) (eprintln |Patch-exceeds-WebSocket-message-limit sid)
            , &unit
          :examples $ []
          :schema $ quote $ Fn Number (cumulo-reel.core/ReelState app.schema/Db) (-> Unit)
        'sync-clients! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn sync-clients! (reel)
            wss-each! $ fn (sid) (sync-client! sid reel)
            , &unit
          :examples $ []
          :schema $ quote $ Fn (cumulo-reel.core/ReelState app.schema/Db) (-> Unit)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.server
          :require (app.schema :as schema) (app.protocol :as protocol)
            app.updater :refer $ updater
            cumulo-reel.core :refer $ ReelState reel-reducer refresh-reel
            app.config :as config
            app.twig.container :refer $ twig-container
            recollect.diff :refer $ diff-twig
            wss.core :refer $ wss-serve! wss-send! wss-each!
            recollect.twig :refer $ clear-twig-caches!
            app.$meta :refer $ calcit-dirname
            calcit.std.fs :refer $ path-exists? check-write-file!
            calcit.std.time :refer $ set-interval!
            calcit.std.date :refer $ get-time! get-timestamp extract-time
            calcit.std.path :refer $ join-path
    'app.twig.container $ %{} 'FileEntry
      :defs $ {}
        'twig-author $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn twig-author (users author-id)
            .and-then author-id $ fn (id)
              .map (get users id) twig-user
          :examples $ []
          :schema $ quote $ Fn (Map String app.schema/User) (Option String)
            -> $ Option app.schema/UserView
        'twig-container $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn twig-container (db session record-count)
            let
                maybe-user $ .and-then (:user-id session)
                  fn (id)
                    get (:users db) id
                logged-in? $ .some? maybe-user
              schema/Store :logged-in? logged-in? :session session :reel-length record-count :user (.map maybe-user twig-user) :router
                .map maybe-user $ fn (user)
                  match
                    :name $ :router session
                    :home $ schema/RouteView :home
                    :profile $ schema/RouteView :profile $ twig-members (:sessions db) (:users db)
                    _ $ schema/RouteView :unknown $ :router session
                , :stack
                  if
                    and logged-in? $ =
                      :name $ :router session
                      , :home
                    map (:stack session)
                      fn (card) (twig-stack card db)
                    []
                  , :count
                    count $ :sessions db
                    , :color $ if logged-in? (rand-hex-color!) |
          :examples $ []
          :schema $ quote $ Fn app.schema/Db app.schema/Session Number (-> app.schema/Store)
          :tests $ [] $ %{} 'TestEntry
            :name |logged-in-guest-profile-and-unknown-route-contract
            :code $ quote $ let
                user $ schema/User :id |u :name "|用户" :password |private-password-hash :nickname (Option :some "|昵称") :avatar $ Option :none
                guest $ schema/Session :id 1 :user-id (Option :none) :nickname (Option :none) :router schema/router :messages ({}) :stack $ []
                authenticated $ assoc (assoc guest :id 2) :user-id $ Option :some |u
                card $ schema/Stack :name :topics :data nil
                current $ assoc authenticated :stack $ [] card
                db $ -> schema/database
                  assoc :users $ {} $ |u user
                  assoc :sessions $ {} (1 guest) (2 current)
                home $ twig-container db current 9
                profile $ twig-container db
                  assoc current :router $ assoc schema/router :name :profile
                  , 9
                guest-view $ twig-container db guest 9
                orphan-view $ twig-container db
                  assoc current :user-id $ Option :some |deleted
                  , 9
              assert= true $ :logged-in? home
              assert= 2 $ :count home
              assert= 9 $ :reel-length home
              assert= 1 $ count $ :stack home
              assert= (Option :none)
                get
                  &struct:to-map $ .unwrap $ :user home
                  , :password
              match
                .unwrap $ :router profile
                (:profile members)
                  assert=
                    {}
                      1 $ Option :none
                      2 $ Option :some "|用户"
                    , members
                _ $ raise "|Expected profile members"
              assert= 0 $ count $ :stack profile
              assert= false $ :logged-in? guest-view
              assert= (Option :none) (:router guest-view)
              assert= 0 $ count $ :stack guest-view
              assert= false $ :logged-in? orphan-view
              assert= (Option :none) (:user orphan-view)
              assert= (Option :none) (:router orphan-view)
              let
                  route $ assoc schema/router :name :future
                match
                  .unwrap $ :router $ twig-container db (assoc current :router route) 9
                  (:unknown original) (assert= route original)
                  _ $ raise "|Expected unknown route preservation"
            :tags $ #{} :migration :unit
        'twig-members $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn twig-members (sessions users)
            filter-map-kv sessions $ fn (id session)
              let
                  name $ match (:user-id session)
                    (:none) (Option :none)
                    (:some user-id)
                      .map (get users user-id)
                        fn (user) (:name user)
                MapEntryDecision :keep id name
          :examples $ []
          :schema $ quote $ Fn (Map Number app.schema/Session) (Map String app.schema/User)
            -> $ Map Number $ Option String
          :tests $ [] $ %{} 'TestEntry
            :name |members-preserve-guests-and-missing-user-boundaries
            :code $ quote $ let
                guest $ schema/Session :id 1 :user-id (Option :none) :nickname (Option :none) :router schema/router :messages ({}) :stack $ []
                logged $ assoc (assoc guest :id 2) :user-id $ Option :some |u
                missing $ assoc (assoc guest :id 3) :user-id $ Option :some |deleted
                user $ schema/User :id |u :name "|用户" :password |private :nickname (Option :none) :avatar $ Option :none
                members $ twig-members
                  {} (1 guest) (2 logged) (3 missing)
                  {} $ |u user
              assert= 3 $ count members
              assert=
                Option :some $ Option :none
                get members 1
              assert=
                Option :some $ Option :some "|用户"
                get members 2
              assert=
                Option :some $ Option :none
                get members 3
            :tags $ #{} :migration :unit
        'twig-reply $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn twig-reply (reply users)
            schema/ReplyView :id (:id reply) :content (:content reply) :time (:time reply) :author $ twig-author users $ :author-id reply
          :examples $ []
          :schema $ quote $ Fn app.schema/Reply (Map String app.schema/User) (-> app.schema/ReplyView)
        'twig-stack $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn twig-stack (card db)
            match (:name card)
              :topics $ schema/CardView :topics $ filter-map-kv (:topics db)
                fn (id topic)
                  MapEntryDecision :keep id $ twig-topic topic $ :users db
              :topic $ match
                try-decode-map-as (:data card) 'String
                (:ok id)
                  schema/CardView :topic $ .map
                    get (:topics db) id
                    fn (topic)
                      twig-topic topic $ :users db
                (:err _) (schema/CardView :unknown card)
              _ $ schema/CardView :unknown card
          :examples $ []
          :schema $ quote $ Fn app.schema/Stack app.schema/Db (-> app.schema/CardView)
          :tests $ [] $ %{} 'TestEntry
            :name |typed-cards-authors-replies-and-missing-boundaries
            :code $ quote $ let
                user $ schema/User :id |u :name "|用户" :password |private-password-hash :nickname (Option :some "|昵称") :avatar $ Option :none
                reply $ schema/Reply :id |r :content "|回复" :time 22 :author-id $ Option :none
                topic $ schema/Topic :id |t :content "|话题" :time 11 :author-id (Option :some |u) :replies $ {} (|r reply)
                db $ -> schema/database
                  assoc :users $ {} $ |u user
                  assoc :topics $ {} $ |t topic
                topics-card $ schema/Stack :name :topics :data nil
                unknown-card $ schema/Stack :name :future :data $ {} (:draft "|保留")
              match (twig-stack topics-card db)
                (:topics topics)
                  let
                      view $ .unwrap $ get topics |t
                      author $ .unwrap $ :author view
                      reply-view $ .unwrap $ get (:replies view) |r
                    assert= 1 $ count topics
                    assert= "|用户" $ :name author
                    assert= (Option :none)
                      get (&struct:to-map author) :password
                    assert= 11 $ :time view
                    assert= 22 $ :time reply-view
                    assert= (Option :none) (:author reply-view)
                _ $ raise "|Expected topics card"
              match
                twig-stack (schema/Stack :name :topic :data |t) db
                (:topic value)
                  assert= "|话题" $ :content $ .unwrap value
                _ $ raise "|Expected topic card"
              match
                twig-stack (schema/Stack :name :topic :data |missing) db
                (:topic value)
                  assert= (Option :none) value
                _ $ raise "|Expected missing topic boundary"
              let
                  malformed $ schema/Stack :name :topic :data 123
                assert= (schema/CardView :unknown malformed) (twig-stack malformed db)
              assert= (schema/CardView :unknown unknown-card) (twig-stack unknown-card db)
              assert= (Option :none)
                :author $ twig-topic
                  assoc topic :author-id $ Option :some |deleted
                  :users db
              assert= topic $ .unwrap $ get (:topics db) |t
            :tags $ #{} :migration :unit
        'twig-topic $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn twig-topic (topic users)
            schema/TopicView :id (:id topic) :content (:content topic) :time (:time topic) :author
              twig-author users $ :author-id topic
              , :replies $ filter-map-kv (:replies topic)
                fn (id reply)
                  MapEntryDecision :keep id $ twig-reply reply users
          :examples $ []
          :schema $ quote $ Fn app.schema/Topic (Map String app.schema/User) (-> app.schema/TopicView)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.twig.container
          :require
            app.twig.user :refer $ twig-user
            calcit.std.rand :refer $ rand-hex-color!
            app.schema :as schema
    'app.twig.user $ %{} 'FileEntry
      :defs $ {} $ 'twig-user
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn twig-user (user)
            schema/UserView :id (:id user) :name (:name user) :nickname (:nickname user) :avatar $ :avatar user
          :examples $ []
          :schema $ quote $ Fn app.schema/User (-> app.schema/UserView)
          :tests $ [] $ %{} 'TestEntry (:name |public-user-excludes-password)
            :code $ quote $ let
                user $ schema/User :id |u :name |alice :nickname (Option :some "|阿狸") :avatar (Option :none) :password |synthetic-hash
                public-user $ twig-user user
              assert= false $ contains-field? public-user :password
              assert= |u $ :id public-user
              assert= |alice $ :name public-user
              assert= "|阿狸" $ .unwrap $ :nickname public-user
            :tags $ #{} :migration :unit
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.twig.user
          :require $ app.schema :as schema
    'app.updater $ %{} 'FileEntry
      :defs $ {} $ 'updater
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (db op sid op-id op-time)
            match op
              (:session/connect) (session/connect db sid op-id op-time)
              (:session/disconnect) (session/disconnect db sid op-id op-time)
              (:session/remove-message data) (session/remove-message db data sid op-id op-time)
              (:user/log-in data) (user/log-in db data sid op-id op-time)
              (:user/sign-up data) (user/sign-up db data sid op-id op-time)
              (:user/log-out) (user/log-out db sid op-id op-time)
              (:router/change data) (router/change db data sid op-id op-time)
              (:stack/add data) (router/add-stack db data sid op-id op-time)
              (:stack/close data) (router/close-stack db data sid op-id op-time)
              (:topic/add data) (topic/add-topic db data sid op-id op-time)
              (:topic/reply data) (topic/add-reply db data sid op-id op-time)
              (:states cursor state) db
              (:effect/connect) db
              (:reel/reset) db
              (:reel/merge) db
              (:effect/persist) db
          :examples $ []
          :schema $ quote $ Fn app.schema/Db app.schema/Op Number String Number (-> app.schema/Db)
          :tests $ [] $ %{} 'TestEntry
            :name |account-session-notifications-and-private-user-contract
            :code $ quote $ let
                connected $ -> schema/database
                  updater (schema/Op :session/connect) 1 |c1 0
                  updater (schema/Op :session/connect) 2 |c2 0
                signed $ updater connected
                  schema/Op :user/sign-up $ [] |alice |synthetic-only
                  , 1 |u1 10
                wrong $ updater signed
                  schema/Op :user/log-in $ [] |alice |wrong-synthetic
                  , 2 |wrong 20
                logged $ updater wrong
                  schema/Op :user/log-in $ [] |alice |synthetic-only
                  , 2 |login 30
                cleared $ updater logged (schema/Op :session/remove-message |wrong) 2 |dismiss 40
                duplicate $ updater cleared
                  schema/Op :user/sign-up $ [] |alice |another-synthetic
                  , 2 |duplicate 50
                out $ updater duplicate (schema/Op :user/log-out) 1 |logout 60
                disconnected $ updater out (schema/Op :session/disconnect) 1 |disconnect 70
              assert= |u1 $ .unwrap $ :user-id
                .unwrap $ get (:sessions signed) 1
              assert= true $ .none? $ :user-id
                .unwrap $ get (:sessions wrong) 2
              assert= "|Wrong password for alice" $ :text $ .unwrap
                get
                  :messages $ .unwrap $ get (:sessions wrong) 2
                  , |wrong
              assert= |u1 $ .unwrap $ :user-id
                .unwrap $ get (:sessions logged) 2
              assert= 0 $ count $ :messages
                .unwrap $ get (:sessions cleared) 2
              assert= 1 $ count $ :users duplicate
              assert= "|Name is taken: alice" $ :text $ .unwrap
                get
                  :messages $ .unwrap $ get (:sessions duplicate) 2
                  , |duplicate
              assert= true $ .none? $ :user-id
                .unwrap $ get (:sessions out) 1
              assert= |u1 $ .unwrap $ :user-id
                .unwrap $ get (:sessions out) 2
              assert= 1 $ count $ :sessions disconnected
              assert= false $ =
                :password $ .unwrap $ get (:users signed) |u1
                , |synthetic-only
            :tags $ #{} :migration :unit
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require (app.schema :as schema) (app.updater.session :as session) (app.updater.user :as user) (app.updater.router :as router) (app.updater.topic :as topic)
    'app.updater.router $ %{} 'FileEntry
      :defs $ {}
        'add-stack $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn add-stack (db payload sid op-id op-time)
            session/update-session db sid $ fn (current)
              assoc current :stack $ conj (:stack current) payload
          :examples $ []
          :schema $ quote $ Fn app.schema/Db app.schema/Stack Number String Number (-> app.schema/Db)
        'change $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn change (db payload sid op-id op-time)
            session/update-session db sid $ fn (current) (assoc current :router payload)
          :examples $ []
          :schema $ quote $ Fn app.schema/Db app.schema/Router Number String Number (-> app.schema/Db)
        'close-stack $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn close-stack (db payload sid op-id op-time)
            session/update-session db sid $ fn (current)
              assoc current :stack $ dissoc (:stack current) payload
          :examples $ []
          :schema $ quote $ Fn app.schema/Db Number Number String Number (-> app.schema/Db)
          :tests $ [] $ %{} 'TestEntry (:name |stack-index-order-and-session-preservation)
            :code $ quote $ let
                connected $ session/connect schema/database 1 |c 0
                topics-card $ schema/Stack :name :topics :data nil
                topic-card $ schema/Stack :name :topic :data |topic-id
                stacked $ -> connected (add-stack topics-card 1 |a 1) (add-stack topic-card 1 |b 2)
                routed $ change stacked (assoc schema/router :name :profile) 1 |route 3
                closed $ close-stack routed 0 1 |close 4
              assert= ([] topics-card topic-card)
                :stack $ .unwrap $ get (:sessions stacked) 1
              assert= ([] topic-card)
                :stack $ .unwrap $ get (:sessions closed) 1
              assert= :profile $ :name $ :router
                .unwrap $ get (:sessions closed) 1
              assert= closed $ add-stack closed topics-card 99 |no-session 5
            :tags $ #{} :migration :unit
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater.router
          :require (app.updater.session :as session) (app.schema :as schema)
    'app.updater.session $ %{} 'FileEntry
      :defs $ {}
        'add-message $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn add-message (db sid id text)
            update-session db sid $ fn (session)
              assoc session :messages $ assoc (:messages session) id $ schema/Notification :id id :text text
          :examples $ []
          :schema $ quote $ Fn app.schema/Db Number String String (-> app.schema/Db)
        'connect $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn connect (db sid op-id op-time)
            assoc db :sessions $ assoc (:sessions db) sid $ schema/Session :id sid :user-id (Option :none) :nickname (Option :none) :router schema/router :messages ({}) :stack ([])
          :examples $ []
          :schema $ quote $ Fn app.schema/Db Number String Number (-> app.schema/Db)
        'disconnect $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn disconnect (db sid op-id op-time)
            assoc db :sessions $ dissoc (:sessions db) sid
          :examples $ []
          :schema $ quote $ Fn app.schema/Db Number String Number (-> app.schema/Db)
        'remove-message $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn remove-message (db message-id sid op-id op-time)
            update-session db sid $ fn (session)
              assoc session :messages $ dissoc (:messages session) message-id
          :examples $ []
          :schema $ quote $ Fn app.schema/Db String Number String Number (-> app.schema/Db)
        'update-session $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn update-session (db sid f)
            match
              get (:sessions db) sid
              (:some session)
                assoc db :sessions $ assoc (:sessions db) sid $ f session
              (:none) db
          :examples $ []
          :schema $ quote $ Fn app.schema/Db Number
            Fn app.schema/Session $ -> app.schema/Session
            -> app.schema/Db
        'user-id $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn user-id (db sid)
            .and-then
              get (:sessions db) sid
              fn (session) (:user-id session)
          :examples $ []
          :schema $ quote $ Fn app.schema/Db Number
            -> $ Option String
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater.session
          :require $ app.schema :as schema
    'app.updater.topic $ %{} 'FileEntry
      :defs $ {}
        'add-reply $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn add-reply (db payload sid op-id op-time)
            match
              get (:topics db) (:topic-id payload)
              (:none) db
              (:some topic)
                assoc db :topics $ assoc (:topics db) (:topic-id payload)
                  assoc topic :replies $ assoc (:replies topic) op-id $ schema/Reply :id op-id :content (:text payload) :time op-time :author-id (session/user-id db sid)
          :examples $ []
          :schema $ quote $ Fn app.schema/Db app.schema/ReplyPayload Number String Number (-> app.schema/Db)
          :tests $ [] $ %{} 'TestEntry
            :name |topic-and-reply-ids-authors-time-and-missing-topic
            :code $ quote $ let
                connected $ session/connect schema/database 1 |c 0
                authored $ session/update-session connected 1 $ fn (current)
                  assoc current :user-id $ Option :some |author-id
                topic-db $ add-topic authored "|主题 🌸" 1 |topic-id 10
                reply-db $ add-reply topic-db (schema/ReplyPayload :topic-id |topic-id :text "|回复 🐈") 1 |reply-id 20
                guest-db $ add-reply reply-db (schema/ReplyPayload :topic-id |topic-id :text |guest) 2 |guest-reply 30
              assert= "|主题 🌸" $ :content $ .unwrap
                get (:topics topic-db) |topic-id
              assert= 10 $ :time $ .unwrap
                get (:topics topic-db) |topic-id
              assert= |author-id $ .unwrap $ :author-id
                .unwrap $ get (:topics topic-db) |topic-id
              assert= "|回复 🐈" $ :content $ .unwrap
                get
                  :replies $ .unwrap $ get (:topics reply-db) |topic-id
                  , |reply-id
              assert= |reply-id $ :id $ .unwrap
                get
                  :replies $ .unwrap $ get (:topics reply-db) |topic-id
                  , |reply-id
              assert= 20 $ :time $ .unwrap
                get
                  :replies $ .unwrap $ get (:topics reply-db) |topic-id
                  , |reply-id
              assert= |author-id $ .unwrap $ :author-id
                .unwrap $ get
                  :replies $ .unwrap $ get (:topics reply-db) |topic-id
                  , |reply-id
              assert= true $ .none? $ :author-id
                .unwrap $ get
                  :replies $ .unwrap $ get (:topics guest-db) |topic-id
                  , |guest-reply
              assert= guest-db $ add-reply guest-db (schema/ReplyPayload :topic-id |missing :text |not-created) 1 |bad-reply 40
            :tags $ #{} :migration :unit
        'add-topic $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn add-topic (db content sid op-id op-time)
            assoc db :topics $ assoc (:topics db) op-id $ schema/Topic :id op-id :content content :time op-time :author-id (session/user-id db sid) :replies ({})
          :examples $ []
          :schema $ quote $ Fn app.schema/Db String Number String Number (-> app.schema/Db)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater.topic
          :require (app.schema :as schema) (app.updater.session :as session)
    'app.updater.user $ %{} 'FileEntry
      :defs $ {}
        'find-user $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn find-user (db username)
            find
              map-list-kv (:users db)
                fn (id user) user
              fn (user)
                = username $ :name user
          :examples $ []
          :schema $ quote $ Fn app.schema/Db String
            -> $ Option app.schema/User
        'log-in $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn log-in (db credentials sid op-id op-time)
            let
                username $ .unwrap $ nth credentials 0
                password $ .unwrap $ nth credentials 1
              match (find-user db username)
                (:some user)
                  if
                    = (md5 password) (:password user)
                    session/update-session db sid $ fn (current)
                      assoc current :user-id $ Option :some $ :id user
                    session/add-message db sid op-id $ str "|Wrong password for " username
                (:none)
                  session/add-message db sid op-id $ str "|No user named: " username
          :examples $ []
          :schema $ quote $ Fn app.schema/Db (List String) Number String Number (-> app.schema/Db)
        'log-out $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn log-out (db sid op-id op-time)
            session/update-session db sid $ fn (current)
              assoc current :user-id $ Option :none
          :examples $ []
          :schema $ quote $ Fn app.schema/Db Number String Number (-> app.schema/Db)
        'sign-up $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn sign-up (db credentials sid op-id op-time)
            let
                username $ .unwrap $ nth credentials 0
                password $ .unwrap $ nth credentials 1
              match (find-user db username)
                (:some user)
                  session/add-message db sid op-id $ str "|Name is taken: " username
                (:none)
                  let
                      new-user $ schema/User :id op-id :name username :nickname (Option :some username) :avatar (Option :none) :password $ md5 password
                      next-db $ assoc db :users $ assoc (:users db) op-id new-user
                    session/update-session next-db sid $ fn (current)
                      assoc current :user-id $ Option :some op-id
          :examples $ []
          :schema $ quote $ Fn app.schema/Db (List String) Number String Number (-> app.schema/Db)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater.user
          :require (app.schema :as schema) (app.updater.session :as session)
            calcit.std.hash :refer $ md5
