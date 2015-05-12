Tabularize = require './tabularize'

{Point} = require 'atom'
{$, TextEditorView, View}  = require 'atom-space-pen-views'

module.exports =
class TabularizeView extends View
  @activate: -> new TabularizeView

  @content: ->
    @div class: 'tabularize overlay from-top mini', =>
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'message', outlet: 'message'
      @div class: 'block', =>
        @div class: 'btn-group centered', =>
          @button class: 'btn selected', 'Left'
          @button class: 'btn disabled', 'Center'
          @button class: 'btn disabled', 'Right'

  detaching: false

  initialize: ->
    @panel = atom.workspace.addModalPanel(item: this, visible: false)

    atom.commands.add 'atom-text-editor', 'tabularize:toggle', =>
      @toggle()
      false

    @miniEditor.on 'blur', => @close()
    atom.commands.add @miniEditor.element, 'core:confirm', => @confirm()
    atom.commands.add @miniEditor.element, 'core:cancel', => @close()

  toggle: ->
    if @panel.isVisible()
      @close()
    else
      @open()

  close: ->
    return unless @panel.isVisible()

    miniEditorFocused = @miniEditor.hasFocus()
    @miniEditor.setText('')
    @panel.hide()
    @restoreFocus() if miniEditorFocused

  confirm: ->
    regex = @miniEditor.getText()
    editor = atom.workspace.getActiveTextEditor()

    @close()

    return unless editor and regex.length
    Tabularize.tabularize(regex, editor)

  storeFocusedElement: ->
    @previouslyFocusedElement = $(':focus')

  restoreFocus: ->
    if @previouslyFocusedElement?.isOnDom()
      @previouslyFocusedElement.focus()
    else
      atom.views.getView(atom.workspace).focus()

  open: ->
    return if @panel.isVisible()

    if editor = atom.workspace.getActiveTextEditor()
      @storeFocusedElement()
      @panel.show()
      @message.text("Use a regex to select the separator")
      @miniEditor.focus()
