package stx.test.auto;

typedef ClassSpecDef = {
  var path        : ClassPath;
  var op          : Op;
  var ?methods    : Cluster<String>;
}