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
      regex = "\\|"
      text = "a | bbbbbbb | c\naaa | b | ccc"
      expected = "a   | bbbbbbb | c\naaa | b       | ccc"
      editor.setText(text)
      editor.selectAll()
      Tabularize.tabularize(regex, editor)
      actual = editor.getText()
      expect(actual).toEqual(expected)

    it "treats the input as a regex", ->
      regex = "\\d"
      text = "a 1 bbbbbbb 2 c\naaa 3 b 4 ccc"
      expected = "a   1 bbbbbbb 2 c\naaa 3 b       4 ccc"
      editor.setText(text)
      editor.selectAll()
      Tabularize.tabularize(regex, editor)
      actual = editor.getText()
      expect(actual).toEqual(expected)

    it "deals with indenting correctly when not selecting whole lines", ->
      text = "    @on 'core:confirm', => @confirm()"
      text += "\n"
      text +="    @on 'core:cancel', => @detach()"
      expected = "    @on 'core:confirm', => @confirm()"
      expected += "\n"
      expected +="    @on 'core:cancel',  => @detach()"
      regex = "=>"
      editor.setText(text)
      editor.setCursorBufferPosition([0,4])
      editor.selectToBottom()
      Tabularize.tabularize(regex, editor)
      actual = editor.getText()
      expect(actual).toEqual(expected)

    it "deals with partial reverse selections correctly", ->
      text = "    @on 'core:confirm', => @confirm()"
      text += "\n"
      text +="    @on 'core:cancel', => @detach()"
      expected = "    @on 'core:confirm', => @confirm()"
      expected += "\n"
      expected +="    @on 'core:cancel',  => @detach()"
      regex = "=>"
      editor.setText(text)
      editor.moveToBottom()
      editor.moveToEndOfLine()
      editor.selectToBufferPosition([0,4])
      Tabularize.tabularize(regex, editor)
      actual = editor.getText()
      expect(actual).toEqual(expected)


  describe ".stripTrailingWhitespace", ->
    it "removes only trailing whitespace from string", ->
      expect(Tabularize.stripTrailingWhitespace("      object    ")).toEqual("      object")
