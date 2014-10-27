{WorkspaceView} = require 'atom'
Tabularize = require '../lib/tabularize'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Tabularize", ->
  activationPromise = null
  [editorView, editor, buffer] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()
    activationPromise = atom.packages.activatePackage('tabularize')

    waitsForPromise ->
      atom.workspace.open()

    runs ->
      editorView = atom.workspaceView.getActiveView()
      {editor} = editorView
      {buffer} = editor

  describe ".tabularize", ->

    it "", ->
      regex = "values"
      text = "INSERT INTO region(id, description, active) values(0, 0, 'AB', 'Alberta', true);"
      text += "\n"
      text += "INSERT INTO region(id, code, description, active) values (1, 0, 'BC', 'British Columbia', true);"
      expected = "INSERT INTO region(id, description, active)       values (0, 0, 'AB', 'Alberta', true);"
      expected += "\n"
      expected += "INSERT INTO region(id, code, description, active) values (1, 0, 'BC', 'British Columbia', true);"
      editor.setText(text)
      editor.selectAll()
      Tabularize.tabularize(regex, editor)
      actual = editor.getText()
      expect(actual).toEqual(expected)

    it "tabularizes columns", ->
      regex = "|"
      text = "a | bbbbbbb | c\naaa | b | ccc"
      expected = "a   | bbbbbbb | c\naaa | b       | ccc"
      editor.setText(text)
      editor.selectAll()
      Tabularize.tabularize(regex, editor)
      actual = editor.getText()
      expect(actual).toEqual(expected)


  describe ".stripTrailingWhitespace", ->
    it "removes only trailing whitespace from string", ->
      expect(Tabularize.stripTrailingWhitespace("      object    ")).toEqual("      object")
