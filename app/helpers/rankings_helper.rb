# frozen_string_literal: true

module RankingsHelper
  RANKING_MOVES = [
    { action: 'top', heart: '❤️', symbol: '▲▲', label: 'Move to Top' },
    { action: 'up', heart: '💗', symbol: '▲', label: 'Move Up One' },
    { action: 'down', heart: '🧡', symbol: '▼', label: 'Move Down One' },
    { action: 'bottom', heart: '💛', symbol: '▼▼', label: 'Move to Bottom' },
    { action: 'remove', heart: '💔', symbol: '▬', label: 'Remove from Your List' }
  ].freeze
  ADD_HEART = '💗'
  ADD_LABEL = 'Add to Your List'

  def ranking_button(heart, symbol, label, action, move: nil)
    button_tag(safe_join([tag.span(heart, class: 'fs-5'), symbol].compact, ' '),
               type: 'button', class: 'btn btn-sm btn-outline-secondary', 'aria-label': label,
               data: { action:, move: }.compact)
  end
end
