class HostDetail < ActiveRecord::Base
  belongs_to :user
  enum activity_status: { inactive: 0, active: 1, legacy: 2 }
  validates :commitment, numericality: { only_integer: true }

  COMMITMENT_OVERVIEW = [
    'regular',
    0,
    -1,
  ]

  COMMITMENT_OVERVIEW_TEXT = {
    'regular' => 'I will commit to hosting regularly.',
    0 => 'I\'ll host when I want.',
    -1 => 'I don\'t plan to host tea times anymore.',
  }

  COMMITMENT_DETAILS = [
    2,
    4,
    8,
    'custom',
  ]

  COMMITMENT_DETAILS_TEXT = {
    2 => 'Two times a month',
    4 => 'Once a month',
    8 => 'Once every two months',
    'custom' => 'Every __ weeks',
  }

  REGULAR_COMMITMENT = 'regular'
  CUSTOM_COMMITMENT = 'custom'
  IRREGULAR_COMMITMENTS = COMMITMENT_OVERVIEW - [REGULAR_COMMITMENT]
  INACTIVE_COMMITMENT = -1
end
