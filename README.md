# stx_test

To write a test file;

```haxe
  using stx.Test;
  class SomeTest extends TestCase{
    public function test(){
      //....
    }
  }
```
The convention is to create an index file;

```haxe
  class Tests{
    static public function tests(){
      return [new SomeTest()];
    }
  }
```

Create a file `tests.pml`

```clj
  (indeces Tests)
```


### Environmental Variables

`STX_LOG_VERBOSE` is used if `--debug` is not set in the build to get stack traces of thrown errors.

