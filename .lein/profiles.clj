{:user {:plugins [[lein-pprint "1.1.1"]]
        :dependencies [[com.stuartsierra/frequencies "0.1.0"]]
        :injections [(require '[clojure.pprint :refer [pprint pp]])]}
 :repl {:middleware [cider-nrepl.plugin/middleware]
        :plugins [[cider/cider-nrepl "0.20.1-SNAPSHOT"]]}}
