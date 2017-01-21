{:user {:plugins [
                  [cider/cider-nrepl "0.8.2"]
                  ; [lein-ancient "0.5.4"]
                  ; [lein-clojars "0.9.1"]
                  ; [lein-exec "0.3.1"]
                  ; [lein-kibit "0.0.8"]
                  [lein-pprint "1.1.1"]
                  ; [lein-try "0.4.1"]
                  ]
        :dependencies [
                       ; [criterium "0.4.3"]
                       ; [im.chit/vinyasa "0.1.8"]
                       ; [leiningen "2.3.4"]
                       ; [im.chit/vinyasa.inject "0.2.0"]
                       ; [im.chit/vinyasa.pull "0.2.0"]
                       ; [org.clojars.gjahad/debug-repl "0.3.3"]
                       ; [org.clojure/tools.trace "0.7.6"]
                       ; [slamhound "1.5.1"]
                       ; [spyscope "0.1.4"]
                       ]
        :injections [
                     ; (require '[vinyasa.inject :as inj])
                     ; (inj/inject 'clojure.core
                     ;             '[
                                   ; [alex-and-georges.debug-repl debug-repl]
                                   ; [clojure.stacktrace e print-stack-trace]
                                   ; [clojure.tools.trace trace-ns trace-vars untrace-ns untrace-vars]
                                   ; [criterium.core bench quick-bench]
                                   ; [vinyasa.inject inject]
                                   ; [vinyasa.pull pull]
                                   ; [vinyasa.lein lein]
                                   ; [vinyasa.reimport reimport]
                                   ; ])
                     ; (require 'spyscope.core) ; for the reader macro #spy/d, available in all namespaces
                     (require '[clojure.pprint :refer [pprint pp]])
                     ]
        :aliases {"slamhound" ["run" "-m" "slam.hound"]}}}
