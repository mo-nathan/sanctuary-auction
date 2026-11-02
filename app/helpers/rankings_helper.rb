# frozen_string_literal: true

module RankingsHelper
  RANKING_MOVES = [
    { action: 'top', heart: '❤️', symbol: '▲▲', label: 'Move to Top' },
    { action: 'up', heart: '💗', symbol: '▲', label: 'Move Up One' },
    { action: 'down', heart: '🧡', symbol: '▼', label: 'Move Down One' },
    { action: 'bottom', heart: '💛', symbol: '▼▼', label: 'Move to Bottom' },
    { action: 'remove', heart: '💔', symbol: '▬', label: 'Remove from Your List' }
  ].freeze
  ADD_MOVE = { action: 'add', heart: '💗', label: 'Add to Your List' }.freeze

  def ranking_button(move, describedby: nil, action: "ranking##{move[:action]}")
    button_tag(safe_join([tag.span(move[:heart], class: 'fs-5'), move[:symbol]].compact, ' '),
               type: 'button', class: 'btn btn-sm btn-outline-secondary', 'aria-label': move[:label],
               'aria-describedby': describedby, data: { action:, move: move[:action] })
  end
end
