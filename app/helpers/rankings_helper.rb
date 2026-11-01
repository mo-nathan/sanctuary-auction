# frozen_string_literal: true

module RankingsHelper
  RANKING_MOVES = [
    { action: 'top', heart: '❤️', help: 'My True Love', label: 'Move to top', meaning: 'Move to the top' },
    { action: 'up', heart: '💗', help: '+1 Heart', label: 'Move up', meaning: 'Move up one, or add to your list' },
    { action: 'down', heart: '🧡', help: '-1 Heart', label: 'Move down', meaning: 'Move down one' },
    { action: 'bottom', heart: '💛', help: "Let's be friends...", label: 'Move to bottom',
      meaning: 'Move to the bottom' },
    { action: 'remove', heart: '💔', help: 'Maybe not', label: 'Remove', meaning: 'Remove from your list' }
  ].freeze
end
