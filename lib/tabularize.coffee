_ = require 'underscore'

module.exports =
  class Tabularize

    @tabularize: (separator, editor) ->
      # Change selections to entire lines inside selections
      _(editor.getSelections()).each (selection) ->
        range = selection.getBufferRange()
        first_row = range.start.row
        last_row = range.end.row
        last_column = range.end.column
        selection.setBufferRange([[first_row,0],[last_row,last_column]])
        unless selection.isReversed()
          selection.selectToEndOfLine()

      editor.mutateSelectedText (selection, index) ->
        separator_regex = RegExp(separator,'g')
        lines = selection.getText().split("\n")
        matches = []

        # split lines and save the matches
        lines = _(lines).map (line) ->
          matches.push line.match(separator_regex)
          line.split(separator_regex)

        # strip spaces from cells
        stripped_lines = Tabularize.stripSpaces(lines)

        num_columns = _.chain(stripped_lines).map (cells) ->
          cells.length
        .max()
        .value()

        padded_columns = (Tabularize.paddingColumn(i, stripped_lines) for i in [0..num_columns-1])

        padded_lines = (Tabularize.paddedLine(i, padded_columns) for i in [0..lines.length-1])

        # Combine padded lines and previously saved matches and join them back
        result = _.chain(padded_lines).zip(matches).map (e) ->
          line = _(e).first()
          matches = _(e).last()
          line = _.chain(line)
            .zip(matches)
            .flatten()
            .compact()
            .value()
            .join(' ')
          Tabularize.stripTrailingWhitespace(line)
        .value().join("\n")

        selection.insertText(result)

    # Left align 'string' in a field of size 'fieldwidth'
    @leftAlign: (string, fieldWidth) ->
      spaces = fieldWidth - string.length
      right = spaces
      "#{string}#{Tabularize.repeatPadding(right)}"

    @stripTrailingWhitespace: (text) ->
      text.replace /\s+$/g, ""

    @repeatPadding: (size) ->
      Array(size+1).join ' '

    # Pad cells of the #nth column
    @paddingColumn: (col_index, matrix) ->
      # Extract the #nth column, extract the biggest cell while at it
      cell_size = 0
      column = _(matrix).map (line) ->
        if line.length > col_index
          cell_size = line[col_index].length if cell_size < line[col_index].length
          line[col_index]
        else
          null

      # Pad the cells
      (Tabularize.leftAlign(cell, cell_size) for cell in column)

    # Extract the #nth line
    @paddedLine: (line_index, columns) ->
      # extract #nth line, filter null values and return
      _.chain(columns).map (column) ->
        column[line_index]
      .compact()
      .value()

    @stripSpaces: (lines) ->
      # Strip spaces
      #   - Don't strip leading spaces from the first element; we like indenting.
      _.map lines, (cells) ->
        cells = _.map cells, (cell, i) ->
          if i == 0
            Tabularize.stripTrailingWhitespace(cell)
          else
            cell.trim()
