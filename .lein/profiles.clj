{:user {:plugins [[lein-ancient "0.4.4"]
                  [lein-clojars "0.9.1"]
                  [lein-exec "0.2.1"]
                  [lein-kibit "0.0.7"]
                  [lein-try "0.3.2"]
                  [spyscope "0.1.2"]]
        :dependencies [[criterium "0.4.2"]
                       [org.clojure/tools.trace "0.7.6"]
                       [slamhound "1.3.3"]
                       [spyscope "0.1.2"]]
        :injections [(do
                       (require 'spyscope.core) ; for reader macro #spy/d
                       (require '[clojure.stacktrace :refer [e print-stack-trace]])
                       (require '[clojure.tools.trace :refer [trace-ns trace-vars untrace-ns untrace-vars]]))]
        :aliases {"slamhound" ["run" "-m" "slam.hound"]}}}
