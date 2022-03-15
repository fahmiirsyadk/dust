const test = require('ava')

test('[Template] render basic template', async t => {
  const { main } = require('./source/Template')
  t.is(main(), '<!DOCTYPE html><html><body><h1>TEST</h1></body></html>')
})

test('[Template] render props template', async t => {
  const { main } = require('./source/TemplateProps')
  const animals = ['cat', 'dog', 'bird']
  t.is(main(animals), '<!DOCTYPE html><html><body><h1>cat</h1><h1>dog</h1><h1>bird</h1></body></html>')
})

test('[Template] render component template', async t => {
  const { main } = require('./source/TemplateComponent')
  t.is(main(), '<!DOCTYPE html><html><head><title>test</title></head><body><h1>another comp</h1></body></html>')
})