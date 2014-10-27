Tabularize = require './tabularize'

{$, TextEditorView, Point, View} = require 'atom'

module.exports =
class TabularizeView extends View
  @activate: -> new TabularizeView

  @content: ->
    @div class: 'tabularize overlay from-top mini', =>
      @subview 'miniEditor', new EditorView(mini: true)

  detaching: false

  initialize: ->
    atom.workspaceView.command 'tabularize:toggle', '.editor', =>
      @toggle()
      false

    @miniEditor.hiddenInput.on 'focusout', => @detach() unless @detaching
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      @attach()

  detach: ->
    return unless @hasParent()

    @detaching = true
    miniEditorFocused = @miniEditor.isFocused
    @miniEditor.setText('')

    super

    @restoreFocus() if miniEditorFocused
    @detaching = false

  confirm: ->
    regex = @miniEditor.getText()
    editor = atom.workspace.getActiveEditor()

    @detach()

    return unless editor and regex.length
    Tabularize.tabularize(regex, editor)

  storeFocusedElement: ->
    @previouslyFocusedElement = $(':focus')

  restoreFocus: ->
    if @previouslyFocusedElement?.isOnDom()
      @previouslyFocusedElement.focus()
    else
      atom.workspaceView.focus()

  attach: ->
    if editor = atom.workspace.getActiveEditor()
      @storeFocusedElement()
      atom.workspaceView.append(this)
      @miniEditor.focus()
