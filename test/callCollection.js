const { parseCollection } = require("./../src/Engine/Engine");

(async () => {
  try {
    const config = {
      blog: {
        layout: "layout_blog",
        source: "posts/blog",
      },
    };
    const data = await parseCollection(config);
    console.log(data);
  } catch (e) {
    console.log(e);
  }
})();
