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
    it "works", ->
      editor.insertText("variable => 1\nother => 1")
      editor.selectAll()

  describe ".stripTrailingWhitespace", ->
    it "removes only trailing whitespace from string", ->
      expect(Tabularize.stripTrailingWhitespace("      object    ")).toEqual("      object")

  describe "when the tabularize:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.tabularize')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'tabularize:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.tabularize')).toExist()
        atom.workspaceView.trigger 'tabularize:toggle'
        expect(atom.workspaceView.find('.tabularize')).not.toExist()
