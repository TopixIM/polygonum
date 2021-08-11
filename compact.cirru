
{} (:package |app)
  :configs $ {} (:init-fn |app.server/main!) (:reload-fn |app.server/reload!)
    :modules $ [] |respo.calcit/ |lilac/ |recollect/ |memof/ |respo-ui.calcit/ |ws-edn.calcit/ |cumulo-util.calcit/ |respo-message.calcit/ |cumulo-reel.calcit/ |alerts.calcit/
    :version nil
  :files $ {}
    |app.comp.container $ {}
      :ns $ quote
        ns app.comp.container $ :require
          respo.util.format :refer $ hsl
          respo-ui.core :as ui
          respo.core :refer $ defcomp <> >> div span button input textarea pre list-> a pre code
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
          "\"dayjs" :default dayjs
          respo-alerts.core :refer $ use-prompt
          app.comp.widget :refer $ =-
      :defs $ {}
        |comp-container $ quote
          defcomp comp-container (states store)
            let
                state $ either (:data states)
                  {} $ :demo "\""
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
                  when dev? $ comp-inspect "\"Store" store
                    {} (:bottom 80) (:left 0) (:max-width "\"100%")
                  comp-messages
                    get-in store $ [] :session :messages
                    {}
                    fn (info d!) (d! :session/remove-message info)
                  when dev? $ comp-reel (:reel-length store) ({})
        |comp-offline $ quote
          defcomp comp-offline () $ div
            {} $ :style
              merge ui/global ui/fullscreen ui/column-dispersive $ {}
                :background-color $ :theme config/site
            div $ {}
              :style $ {} (:height 0)
            div $ {}
              :style $ {}
                :background-image $ str "\"url(" (:icon config/site) "\")"
                :width 128
                :height 128
                :background-size :contain
            div
              {}
                :style $ {} (:cursor :pointer) (:line-height "\"32px")
                :on-click $ fn (e d!) (d! :effect/connect nil)
              <> "\"No connection..." $ {} (:font-family ui/font-fancy) (:font-size 24)
        |comp-stack $ quote
          defcomp comp-stack (states stack)
            list->
              {} $ :style (merge ui/expand ui/row)
              -> stack
                map-indexed $ fn (idx router)
                  [] idx $ div
                    {} $ :style
                      merge ui/column $ {} (:width 400) (:height "\"100%")
                        :border-right $ str "\"1px solid " (hsl 0 0 90)
                    comp-card-header (:name router) idx
                    case-default (:name router) (comp-unknown-card router)
                      :topics $ comp-topics (>> states :chat) (:data router)
                      :topic $ comp-topic
                        >> states $ str :topic
                          get-in router $ [] :data :id
                        :data router
                concat $ []
                  [] 999 $ comp-start
        |comp-start $ quote
          defcomp comp-start () $ div
            {} $ :style
              {} $ :padding "\"16px 40px"
            div ({}) (<> "\"Start...")
            =< nil 16
            div ({})
              button $ {} (:style ui/button) (:inner-text "\"Open Chat")
                :on-click $ fn (e d!)
                  d! :stack/add $ {} (:name :topics)
            div ({})
              button $ {} (:style ui/button) (:inner-text "\"Open Threads")
                :on-click $ fn (e d!) (println "\"TODO")
            div ({})
              button $ {} (:style ui/button) (:inner-text "\"Open Wiki")
                :on-click $ fn (e d!) (println "\"TODO")
            div ({})
              button $ {} (:style ui/button) (:inner-text "\"Open Tags")
                :on-click $ fn (e d!) (println "\"TODO")
            div ({})
              button $ {} (:style ui/button) (:inner-text "\"Open Votes")
                :on-click $ fn (e d!) (println "\"TODO")
        |comp-topic $ quote
          defcomp comp-topic (states topic)
            let
                cursor $ :cursor states
                state $ or (:data states)
                  {} $ :draft "\""
              div
                {} $ :style
                  merge ui/expand ui/column $ {}
                    :border-top $ str "\"1px solid " (hsl 0 0 88)
                div
                  {} $ :style
                    {} $ :padding 8
                  span $ {}
                    :inner-text $ or (:content topic) "\"-"
                div
                  {} $ :style
                    {} (:padding 8)
                      :border-bottom $ str "\"1px solid " (hsl 0 0 90)
                  <>
                    str "\"@" $ get-in topic ([] :author :nickname)
                    {} $ :color (hsl 0 0 50)
                  =< 8 nil
                  <>
                    -> (:time topic) (dayjs) (.!format "\"HH:mm")
                    {}
                      :color $ hsl 0 0 70
                      :font-weight 300
                      :font-family ui/font-fancy
                div
                  {} $ :style
                    merge ui/expand $ {}
                  list-> ({})
                    -> (:replies topic) (.to-list)
                      .sort-by $ fn (x)
                        :time $ nth x 1
                      map $ fn (pair)
                        &let
                          reply $ nth pair 1
                          [] (nth pair 0)
                            div
                              {} $ :style
                                {} (:padding "\"8px")
                                  :border-bottom $ str "\"1px solid " (hsl 0 0 90)
                              div ({})
                                <> $ str "\"@"
                                  get-in reply $ [] :author :nickname
                                =< 8 nil
                                <> $ -> (:time reply) (dayjs) (.!format "\"HH:mm")
                              div ({})
                                <> $ :content (w-log reply)
                  =< nil 80
                div
                  {} $ :style
                    merge ui/row $ {}
                      :border-top $ str "\"1px solid " (hsl 0 0 90)
                  textarea $ {}
                    :style $ merge ui/expand ui/textarea
                    :value $ :draft state
                    :placeholder "\"Reply..."
                    :on-change $ fn (e d!)
                      d! cursor $ assoc state :draft (:value e)
                  =< 8 nil
                  div ({})
                    button $ {} (:inner-text "\"Send") (:style ui/button)
                      :on-click $ fn (e d!)
                        let
                            content $ .trim (:draft state)
                          when
                            not $ .blank? content
                            d! :topic/reply $ {}
                              :topic-id $ :id topic
                              :text content
                            d! cursor $ assoc state :draft "\""
        |comp-status-color $ quote
          defcomp comp-status-color (color)
            div $ {}
              :style $ let
                  size 24
                {} (:width size) (:height size) (:position :absolute) (:bottom 60) (:left 8) (:background-color color) (:border-radius "\"50%") (:opacity 0.6) (:pointer-events :none)
        |comp-topics $ quote
          defcomp comp-topics (states data)
            let
                cursor $ :cursor states
                state $ or (:data states) ({})
                create-plugin $ use-prompt (>> states :new)
                  {} $ :title "\"Create Topic"
              div
                {} $ :style
                  merge ui/expand ui/column $ {}
                div
                  {} $ :style
                    merge ui/row-middle $ {}
                      ; :border-bottom $ str "\"1px solid " (hsl 0 0 90)
                      :padding "\"4px 8px"
                  <> "\"Topics"
                  =< 16 nil
                  a $ {} (:style ui/link) (:inner-text "\"New")
                    :on-click $ fn (e d!)
                      .show create-plugin d! $ fn (text) (d! :topic/add text)
                div
                  {} $ :style ui/expand
                  list->
                    {} $ :style
                      {} $ :border-bottom
                        str "\"1px solid " $ hsl 0 0 80
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
        |comp-topic-item $ quote
          defcomp comp-topic-item (topic)
            div
              {} $ :style
                {} (:padding 8)
                  :border-top $ str "\"1px solid " (hsl 0 0 88)
              div ({})
                span $ {}
                  :inner-text $ or (:content topic) "\"-"
                  :on-click $ fn (e d!)
                    d! :stack/add $ {} (:name :topic)
                      :data $ :id topic
              div ({})
                <>
                  str "\"@" $ get-in topic ([] :author :nickname)
                  {} $ :color (hsl 0 0 50)
                =< 8 nil
                <>
                  -> (:time topic) (dayjs) (.format "\"HH:mm")
                  {}
                    :color $ hsl 0 0 70
                    :font-weight 300
                    :font-family ui/font-fancy
        |comp-unknown-card $ quote
          defcomp comp-unknown-card (router)
            div
              {} $ :style
                merge ui/column $ {} (:width 400) (:height "\"100%")
                  :border-right $ str "\"1px solid " (hsl 0 0 90)
              div ({}) (<> "\"Unknown card")
              pre ({})
                code $ {}
                  :inner-text $ format-cirru-edn router
        |comp-card-header $ quote
          defcomp comp-card-header (name idx)
            div
              {} $ :style
                merge ui/row-parted $ {}
                  :border-bottom $ str "\"1px solid " (hsl 0 0 90)
                  :padding "\"0 8px"
              span $ {}
              <> $ str name
              span $ {} (:inner-text "\"✕")
                :style $ {}
                  :color $ hsl 0 80 70
                  :cursor :pointer
                :on-click $ fn (e d!) (d! :stack/close idx)
    |app.schema $ {}
      :ns $ quote (ns app.schema)
      :defs $ {}
        |user $ quote
          def user $ {} (:name nil) (:id nil) (:nickname nil) (:avatar nil) (:password nil)
        |session $ quote
          def session $ {} (:user-id nil) (:id nil) (:nickname nil)
            :router $ do router
              {} (:name :home) (:data nil) (:router nil)
            :messages $ {}
            :stack $ do stack ([])
        |reply $ quote
          def reply $ {} (:id nil) (:content "\"") (:author-id "\"") (:time nil)
        |stack $ quote
          def stack $ {} (:name nil) (:data nil)
        |topic $ quote
          def topic $ {} (:id nil) (:content "\"") (:time nil)
            :replies $ do reply ({})
            :author-id nil
        |database $ quote
          def database $ {}
            :sessions $ do session ({})
            :users $ do user ({})
            :topics $ do topic ({})
        |router $ quote
          def router $ {} (:name nil) (:title nil)
            :data $ {}
            :router nil
    |app.server $ {}
      :ns $ quote
        ns app.server $ :require (app.schema :as schema)
          app.updater :refer $ updater
          cljs.reader :refer $ read-string
          cumulo-reel.core :refer $ reel-reducer refresh-reel reel-schema
          "\"fs" :as fs
          "\"path" :as path
          app.config :as config
          cumulo-util.file :refer $ write-mildly! get-backup-path! merge-local-edn!
          cumulo-util.core :refer $ id! repeat! unix-time! delay!
          app.twig.container :refer $ twig-container
          recollect.diff :refer $ diff-twig
          ws-edn.server :refer $ wss-serve! wss-send! wss-each!
          recollect.twig :refer $ new-twig-loop! clear-twig-caches!
      :defs $ {}
        |*initial-db $ quote
          defatom *initial-db $ merge-local-edn! schema/database storage-file
            fn (found?)
              if found? (println "\"Found local EDN data") (println "\"Found no data")
        |persist-db! $ quote
          defn persist-db! () $ let
              file-content $ format-cirru-edn
                assoc (:db @*reel) :sessions $ {}
              storage-path storage-file
              backup-path $ get-backup-path!
            write-mildly! storage-path file-content
            write-mildly! backup-path file-content
        |sync-clients! $ quote
          defn sync-clients! (reel)
            wss-each! $ fn (sid socket)
              let
                  db $ :db reel
                  records $ :records reel
                  session $ get-in db ([] :sessions sid)
                  old-store $ or (get @*client-caches sid) nil
                  new-store $ twig-container db session records
                  changes $ diff-twig old-store new-store
                    {} $ :key :id
                when config/dev? $ println "\"Changes for" sid "\":" changes (count records)
                if
                  not= changes $ []
                  do
                    wss-send! sid $ {} (:kind :patch) (:data changes)
                    swap! *client-caches assoc sid new-store
            new-twig-loop!
        |storage-file $ quote
          def storage-file $ path/join js/__dirname (:storage-file config/site)
        |*reader-reel $ quote (defatom *reader-reel @*reel)
        |*reel $ quote
          defatom *reel $ merge reel-schema
            {} (:base @*initial-db) (:db @*initial-db)
        |*proxied-dispatch! $ quote (defatom *proxied-dispatch! dispatch!)
        |main! $ quote
          defn main! ()
            println "\"Running mode:" $ if config/dev? "\"dev" "\"release"
            let
                port $ if (some? js/process.env.port) (js/parseInt js/process.env.port) (:port config/site)
              run-server! port
              println $ str "\"Server started on port:" port
            render-loop! *loop-trigger
            js/process.on "\"SIGINT" on-exit!
            repeat! 600 $ fn () (persist-db!)
        |*loop-trigger $ quote (defatom *loop-trigger 0)
        |on-exit! $ quote
          defn on-exit! (code _) (persist-db!)
            ; println "\"exit code is:" $ pr-str code
            js/process.exit
        |dispatch! $ quote
          defn dispatch! (op op-data sid)
            let
                op-id $ id!
                op-time $ unix-time!
              if config/dev? $ println "\"Dispatch!" (str op) op-data sid
              if (= op :effect/persist) (persist-db!)
                reset! *reel $ reel-reducer @*reel updater op op-data sid op-id op-time config/dev?
        |run-server! $ quote
          defn run-server! (port)
            wss-serve! port $ {}
              :on-open $ fn (sid socket) (@*proxied-dispatch! :session/connect nil sid) (println "\"New client.")
              :on-data $ fn (sid action)
                case-default (:kind action) (println "\"unknown action:" action)
                  :op $ @*proxied-dispatch! (:op action) (:data action) sid
              :on-close $ fn (sid event) (println "\"Client closed!") (@*proxied-dispatch! :session/disconnect nil sid)
              :on-error $ fn (error) (js/console.error error)
        |render-loop! $ quote
          defn render-loop! (*loop)
            when
              not $ identical? @*reader-reel @*reel
              reset! *reader-reel @*reel
              sync-clients! @*reader-reel
            reset! *loop $ delay! 0.2
              fn () $ render-loop! *loop
        |*client-caches $ quote
          defatom *client-caches $ {}
        |reload! $ quote
          defn reload! () (println "\"Code updated.") (clear-twig-caches!) (reset! *proxied-dispatch! dispatch!)
            reset! *reel $ refresh-reel @*reel @*initial-db updater
            js/clearTimeout @*loop-trigger
            render-loop! *loop-trigger
            sync-clients! @*reader-reel
    |app.comp.widget $ {}
      :ns $ quote
        ns app.comp.widget $ :require
          respo-ui.core :refer $ hsl
          respo.core :refer $ defcomp <> >> div span button input textarea
      :defs $ {}
        |=- $ quote
          defn =- (direction ? style)
            div $ {}
              :style $ merge
                {} $ :background-color (hsl 0 0 88)
                if (= direction :v)
                  {} (:width 1) (:height "\"100%")
                  {} (:height 1) (:width "\"100%")
                , style
    |app.twig.container $ {}
      :ns $ quote
        ns app.twig.container $ :require
          app.twig.user :refer $ twig-user
          "\"randomcolor" :as color
          memof.alias :refer $ memof-call
      :defs $ {}
        |twig-container $ quote
          defn twig-container (db session records)
            let
                logged-in? $ some? (:user-id session)
                router $ :router session
                base-data $ {} (:logged-in? logged-in?) (:session session)
                  :reel-length $ count records
              merge base-data $ if logged-in?
                {}
                  :user $ memof-call twig-user
                    get-in db $ [] :users (:user-id session)
                  :router $ assoc router :data
                    case (:name router)
                      :home $ -> (:messages db)
                        map-kv $ fn (k v)
                          [] k $ assoc v :author
                            twig-user $ get-in db
                              [] :users $ :author-id v
                      :profile $ memof-call twig-members (:sessions db) (:users db)
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
                                  map-kv replies $ fn (k v)
                                    [] k $ assoc v :author
                                      twig-user $ get-in db
                                        [] :users $ :author-id v
                              , nil
                          :topics $ -> (:topics db)
                            map-kv $ fn (k v)
                              [] k $ assoc v :author
                                twig-user $ get-in db
                                  [] :users $ :author-id v
                    []
                  :count $ count (:sessions db)
                  :color $ color/randomColor
                , nil
        |twig-members $ quote
          defn twig-members (sessions users)
            -> sessions (.to-list)
              map $ fn (pair)
                let[] (k session) pair $ [] k
                  get-in users $ [] (:user-id session) :name
              pairs-map
    |app.updater $ {}
      :ns $ quote
        ns app.updater $ :require (app.updater.session :as session) (app.updater.user :as user) (app.updater.router :as router) (app.updater.topic :as topic) (app.schema :as schema)
          respo-message.updater :refer $ update-messages
      :defs $ {}
        |updater $ quote
          defn updater (db op op-data sid op-id op-time)
            let
                session $ get-in db ([] :sessions sid)
                user $ if (some? session)
                  get-in db $ [] :users (:user-id session)
                f $ case-default op
                  fn (& args) (println "\"Unknown op:" op) db
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
    |app.twig.user $ {}
      :ns $ quote
        ns app.twig.user $ :require
      :defs $ {}
        |twig-user $ quote
          defn twig-user (user) (dissoc user :password)
    |app.updater.topic $ {}
      :ns $ quote
        ns app.updater.topic $ :require (app.schema :as schema)
      :defs $ {}
        |add-reply $ quote
          defn add-reply (db op-data sid op-id op-time)
            let
                user-id $ get-in db ([] :sessions sid :user-id)
              assoc-in db
                [] :topics (:topic-id op-data) :replies op-id
                merge schema/reply $ {} (:id op-id) (:time op-time)
                  :content $ :text op-data
                  :author-id user-id
        |add-topic $ quote
          defn add-topic (db op-data sid op-id op-time)
            let
                user-id $ get-in db ([] :sessions sid :user-id)
              assoc-in db ([] :topics op-id)
                merge schema/topic $ {} (:id op-id) (:time op-time) (:content op-data) (:author-id user-id)
    |app.updater.user $ {}
      :ns $ quote
        ns app.updater.user $ :require
          cumulo-util.core :refer $ find-first
          "\"md5" :default md5
      :defs $ {}
        |sign-up $ quote
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
                      :text $ str "\"Name is taken: " username
                -> db
                  assoc-in ([] :sessions sid :user-id) op-id
                  assoc-in ([] :users op-id)
                    {} (:id op-id) (:name username) (:nickname username)
                      :password $ md5 password
                      :avatar nil
        |log-out $ quote
          defn log-out (db op-data sid op-id op-time)
            assoc-in db ([] :sessions sid :user-id) nil
        |log-in $ quote
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
                          :text $ str "\"Wrong password for " username
                    update session :messages $ fn (messages)
                      assoc messages op-id $ {} (:id op-id)
                        :text $ str "\"No user named: " username
    |app.comp.profile $ {}
      :ns $ quote
        ns app.comp.profile $ :require
          respo.util.format :refer $ hsl
          app.schema :as schema
          respo-ui.core :as ui
          respo.core :refer $ defcomp list-> <> span div button
          respo.comp.space :refer $ =<
          app.config :as config
      :defs $ {}
        |comp-profile $ quote
          defcomp comp-profile (user members)
            div
              {} $ :style
                merge ui/flex $ {} (:padding 16)
              div
                {} $ :style
                  {} (:font-family ui/font-fancy) (:font-size 32) (:font-weight 100)
                <> $ str "\"Hello! " (:name user)
              =< nil 16
              div
                {} $ :style ui/row
                <> "\"Members:"
                =< 8 nil
                list->
                  {} $ :style ui/row
                  -> members (.to-list)
                    map $ fn (pair)
                      let[] (k username) pair $ [] k
                        div
                          {} $ :style
                            {} (:padding "\"0 8px")
                              :border $ str "\"1px solid " (hsl 0 0 80)
                              :border-radius "\"16px"
                              :margin "\"0 4px"
                          <> username
              =< nil 48
              div ({})
                button
                  {}
                    :style $ merge ui/button
                    :on-click $ fn (e d!)
                      js/location.replace $ str js/location.origin "\"?time=" (.now js/Date)
                  <> "\"Refresh"
                =< 8 nil
                button
                  {}
                    :style $ merge ui/button
                      {} (:color :red) (:border-color :red)
                    :on-click $ fn (e dispatch!) (dispatch! :user/log-out nil)
                      .removeItem js/localStorage $ :storage-key config/site
                  <> "\"Log out"
    |app.comp.login $ {}
      :ns $ quote
        ns app.comp.login $ :require
          respo.core :refer $ defcomp <> div input button span
          respo.comp.space :refer $ =<
          respo.comp.inspect :refer $ comp-inspect
          respo-ui.core :as ui
          app.schema :as schema
          app.config :as config
      :defs $ {}
        |initial-state $ quote
          def initial-state $ {} (:username "\"") (:password "\"")
        |comp-login $ quote
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
                      input $ {} (:placeholder "\"Username")
                        :value $ :username state
                        :style ui/input
                        :on-input $ fn (e d!)
                          d! cursor $ assoc state :username (:value e)
                    =< nil 8
                    div ({})
                      input $ {} (:placeholder "\"Password")
                        :value $ :password state
                        :style ui/input
                        :on-input $ fn (e d!)
                          d! cursor $ assoc state :password (:value e)
                  =< nil 8
                  div
                    {} $ :style
                      {} $ :text-align :right
                    span $ {} (:inner-text "\"Sign up")
                      :style $ merge ui/link
                      :on-click $ on-submit (:username state) (:password state) true
                    =< 8 nil
                    span $ {} (:inner-text "\"Log in")
                      :style $ merge ui/link
                      :on-click $ on-submit (:username state) (:password state) false
        |on-submit $ quote
          defn on-submit (username password signup?)
            fn (e dispatch!)
              dispatch! (if signup? :user/sign-up :user/log-in) ([] username password)
              .setItem js/localStorage (:storage-key config/site)
                format-cirru-edn $ [] username password
    |app.comp.navigation $ {}
      :ns $ quote
        ns app.comp.navigation $ :require
          respo.util.format :refer $ hsl
          respo-ui.core :as ui
          respo.comp.space :refer $ =<
          respo.core :refer $ defcomp <> span div
          app.config :as config
      :defs $ {}
        |comp-navigation $ quote
          defcomp comp-navigation (logged-in? count-members)
            div
              {} $ :style
                merge ui/column-parted $ {} (:width 64) (:justify-content :space-between) (:padding "\"0 16px") (:font-size 16) (:font-family ui/font-fancy)
              div
                {} $ :style ui/column
                div
                  {}
                    :on-click $ fn (e d!)
                      d! :router/change $ {} (:name :home)
                    :style $ {} (:cursor :pointer)
                  <> "\"Ploy" nil
              div
                {}
                  :style $ merge ui/row
                    {} $ :cursor "\"pointer"
                  :on-click $ fn (e d!)
                    d! :router/change $ {} (:name :profile)
                <> $ if logged-in? "\"Me" "\"Guest"
                =< 4 nil
                <> count-members
    |app.updater.router $ {}
      :ns $ quote (ns app.updater.router)
      :defs $ {}
        |close-stack $ quote
          defn close-stack (db op-data sid op-id op-time)
            update-in db ([] :sessions sid :stack)
              fn (s) (dissoc s op-data)
        |add-stack $ quote
          defn add-stack (db op-data sid op-id op-time)
            update-in db ([] :sessions sid :stack)
              fn (s) (conj s op-data)
        |change $ quote
          defn change (db op-data sid op-id op-time)
            assoc-in db ([] :sessions sid :router) op-data
    |app.updater.session $ {}
      :ns $ quote
        ns app.updater.session $ :require (app.schema :as schema)
      :defs $ {}
        |disconnect $ quote
          defn disconnect (db op-data sid op-id op-time)
            update db :sessions $ fn (session) (dissoc session sid)
        |remove-message $ quote
          defn remove-message (db op-data sid op-id op-time)
            update-in db ([] :sessions sid :messages)
              fn (messages)
                dissoc messages $ :id op-data
        |connect $ quote
          defn connect (db op-data sid op-id op-time)
            assoc-in db ([] :sessions sid)
              merge schema/session $ {} (:id sid)
    |app.client $ {}
      :ns $ quote
        ns app.client $ :require
          respo.core :refer $ render! clear-cache! realize-ssr!
          respo.cursor :refer $ update-states
          app.comp.container :refer $ comp-container
          app.schema :as schema
          app.config :as config
          ws-edn.client :refer $ ws-connect! ws-send!
          recollect.patch :refer $ patch-twig
          cumulo-util.core :refer $ on-page-touch
          "\"url-parse" :default url-parse
          "\"bottom-tip" :default tip!
          "\"./calcit.build-errors" :default client-errors
          "\"../js-out/calcit.build-errors" :default server-errors
      :defs $ {}
        |render-app! $ quote
          defn render-app! () $ render! mount-target
            comp-container (:states @*states) @*store
            , dispatch!
        |*states $ quote
          defatom *states $ {}
            :states $ {}
              :cursor $ []
        |mount-target $ quote
          def mount-target $ .querySelector js/document "\".app"
        |connect! $ quote
          defn connect! () $ let
              url-obj $ url-parse js/location.href true
              host $ either (-> url-obj .-query .-host) js/location.hostname
              port $ either (-> url-obj .-query .-port) (:port config/site)
            ws-connect! (str "\"ws://" host "\":" port)
              {}
                :on-open $ fn (event) (simulate-login!)
                :on-close $ fn (event) (reset! *store nil) (js/console.error "\"Lost connection!")
                :on-data on-server-data
        |main! $ quote
          defn main! () (load-console-formatter!)
            println "\"Running mode:" $ if config/dev? "\"dev" "\"release"
            render-app!
            connect!
            add-watch *store :changes $ fn (store prev) (render-app!)
            add-watch *states :changes $ fn (states prev) (render-app!)
            on-page-touch $ fn ()
              if (nil? @*store) (connect!)
            println "\"App started!"
        |*store $ quote (defatom *store nil)
        |dispatch! $ quote
          defn dispatch! (op op-data)
            when
              and config/dev? $ not= op :states
              println "\"Dispatch" op op-data
            case-default op
              ws-send! $ {} (:kind :op) (:op op) (:data op-data)
              :states $ reset! *states (update-states @*states op-data)
              :effect/connect $ connect!
        |on-server-data $ quote
          defn on-server-data (data)
            case-default (:kind data) (println "\"unknown server data kind:" data)
              :patch $ let
                  changes $ :data data
                when config/dev? $ js/console.log "\"Changes" (to-js-data changes)
                reset! *store $ patch-twig @*store changes
        |simulate-login! $ quote
          defn simulate-login! () $ let
              raw $ .!getItem js/localStorage (:storage-key config/site)
            if (some? raw)
              do (println "\"Found storage.")
                dispatch! :user/log-in $ parse-cirru-edn raw
              do $ println "\"Found no storage."
        |reload! $ quote
          defn reload! () $ if
            or (some? client-errors) (some? server-errors)
            tip! "\"error" $ str client-errors &newline server-errors
            do (tip! "\"ok~" nil) (remove-watch *store :changes) (remove-watch *states :changes) (clear-cache!) (render-app!)
              add-watch *store :changes $ fn (store prev) (render-app!)
              add-watch *states :changes $ fn (states prev) (render-app!)
              println "\"Code updated."
    |app.config $ {}
      :ns $ quote (ns app.config)
      :defs $ {}
        |dev? $ quote
          def dev? $ = "\"dev" (get-env "\"mode")
        |site $ quote
          def site $ {} (:port 5021) (:title "\"Polygonum") (:icon "\"http://cdn.tiye.me/logo/cumulo.png") (:theme "\"#eeeeff") (:storage-key "\"polygonum") (:storage-file "\"storage.cirru")
