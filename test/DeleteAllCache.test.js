const test = require("ava");

test("[Engine] cache should be empty", t => {
  const { deleteAllCache } = require("./../src/Engine/Engine");
  t.is(Object.keys(require.cache).length > 0, true);
  deleteAllCache();
  t.is(Object.keys(require.cache).length, 0);
})