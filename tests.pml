(indeces "stx.testtest.Tests" "stx.test.Test")
("picky pick"
  include 
    (
      ("stx.test.test.SynchronousErrorTest" exclude
        "test"
      )
      (
        "stx.test.test.TestTest" include "test_assertion"
      )
      "stx.test.TestResource"
    )
)
("pushing for release" 
  exclude ("SingleArg")
)
("pushy pushy push" 
  exclude ("SingleArgWrapped")
)
("spotty" 
  include (
    ("OtherTest" include "test_a")
  )
)