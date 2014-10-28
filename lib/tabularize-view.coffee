Tabularize = require './tabularize'

{$, TextEditorView, Point, View} = require 'atom'

module.exports =
class TabularizeView extends View
  @activate: -> new TabularizeView

  @content: ->
    @div class: 'tabularize overlay from-top mini', =>
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'block', =>
        @div class: 'btn-group centered', =>
          @button class: 'btn selected', 'Left'
          @button class: 'btn disabled', 'Center'
          @button class: 'btn disabled', 'Right'

  detaching: false

  initialize: ->
    atom.workspaceView.command 'tabularize:toggle', '.editor', =>
      @toggle()
      false

    @on 'core:confirm', => @confirm()
    @on 'core:cancel',  => @detach()

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
