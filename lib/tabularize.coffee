_ = require 'underscore'

module.exports =
  class Tabularize

    @tabularize: (separator, editor) ->
      editor.mutateSelectedText (selection, index) ->
        lines = selection.getText().split("\n")

        separator = " #{separator} "
        lines = _(lines).map (line) ->
          line.split(separator)

        # Strip spaces
        #   - Only from non-delimiters; spaces in delimiters must have been matched
        #     intentionally
        #   - Don't strip leading spaces from the first element; we like indenting.

        stripped_lines = _.map lines, (cells) ->
          cells = _.map cells, (cell, i) ->
            if i == 0
              Tabularize.stripTrailingWhitespace(cell)
            else
              cell.trim()

        biggest_cell = _.chain(stripped_lines).flatten().reduce (memo, cell) ->
          length = if memo then memo.length else 0
          if length > cell.length then memo else cell
        .value()

        cell_size = biggest_cell.length

        padded_lines = _.map stripped_lines, (cells) ->
          padded = _.map cells, (cell, i) ->
            cell = Tabularize.leftAlign(cell, cell_size)
            if i == cells.length - 1
              cell = Tabularize.stripTrailingWhitespace(cell)
            cell

          padded.join(separator)

        result = padded_lines.join("\n")
        selection.insertText(result)

    # Left align 'string' in a field of size 'fieldwidth'
    @leftAlign: (string, fieldWidth) ->
      spaces = fieldWidth - string.length
      right = spaces
      "#{string}#{Tabularize.repeatPadding(right)}"

    @stripTrailingWhitespace: (text) ->
      text.replace /\s+$/g, ""

    @repeatPadding: (size) ->
      e = ''
      while e.length < size
        e += ' '
      e
