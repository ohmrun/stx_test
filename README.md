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

```kl
  (indeces Tests)
```
