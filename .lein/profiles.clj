{:user {:plugins [[lein-ancient "0.5.4"]
                  [lein-clojars "0.9.1"]
                  [lein-exec "0.3.1"]
                  [lein-kibit "0.0.8"]
                  [lein-try "0.4.1"]]
        :dependencies [[criterium "0.4.3"]
                       [im.chit/vinyasa "0.1.8"]
                       [leiningen "2.3.4"]
                       [org.clojure/tools.trace "0.7.6"]
                       [slamhound "1.5.1"]
                       [spyscope "0.1.4"]]
        :injections [#_(require '[vinyasa.inject :as inj])
                     #_(inj/inject 'clojure.core
                       '[[vinyasa.inject inject]
                         [vinyasa.pull pull]
                         [vinyasa.lein lein]
                         [vinyasa.reimport reimport]
                         [clojure.stacktrace e print-stack-trace]
                         [clojure.tools.trace trace-ns trace-vars untrace-ns untrace-vars]
                         [criterium.core bench quick-bench]])
                     #_(require 'spyscope.core) ; for the reader macro #spy/d, available in all namespaces
                     ]
        :aliases {"slamhound" ["run" "-m" "slam.hound"]}}}
