package petclinic

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class PetclinicSimulation extends Simulation {
  val httpConf = http.baseURL("http://petclinic-svc.petclinic-staging:8080")
                     .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
                     .doNotTrackHeader("1")
                     .acceptLanguageHeader("en-US,en;q=0.5")
                     .acceptEncodingHeader("gzip")
                     .userAgentHeader("Gatling/2.3.0")

  val scn = scenario("PetClinic Loadtest")
               .exec(http("request frontpage").get("/"))
               .pause(1)

  setUp(
    scn.inject(atOnceUsers(10))
  ).protocols(httpConf)
     .assertions(
        global.responseTime.max.lt(500),
        global.successfulRequests.percent.gt(98)
     )

}

