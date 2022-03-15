const test = require('ava')
const fs = require('fs')

const template = fs.readFileSync(__dirname + '/hello.md', 'utf8')
const emptyTemplate = fs.readFileSync(__dirname + '/empty.md', 'utf8')

test('[Markdown] retrieve markdown', async t => {
  const markDownFunction = require('../../src/Engine/Internal__Dust_Markdown')
  const { content } = markDownFunction.mdToMatter(template)
  t.is(content, 'this is excerpt\n---\n# Hello World\n## this is subtitle\n\nthis is the content')
})

test('[Markdown] retrieve matter from markdown', async t => {
  const markDownFunction = require('../../src/Engine/Internal__Dust_Markdown')
  t.like(markDownFunction.mdToMatter(template), {
    data: {
      title: 'Hello World',
    },
    isEmpty: false,
    excerpt: 'this is excerpt\n',
  })
})

test('[Markdown] retrieve empty markdown', async t => {
  const markDownFunction = require('../../src/Engine/Internal__Dust_Markdown')
  t.like(markDownFunction.mdToMatter(''), {
    isEmpty: undefined,
  })
})

test('[Markdown] retrieve empty frontmatter', async t => {
  const markDownFunction = require('../../src/Engine/Internal__Dust_Markdown')
  t.like(markDownFunction.mdToMatter(emptyTemplate), {
    isEmpty: true,
  })
})
