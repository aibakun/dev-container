class Event < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true

  validate :end_at_after_start_at

  scope :future, -> { where('start_at > ?', Time.current) }
  scope :past, -> { where('end_at < ?', Time.current) }

  private

  def end_at_after_start_at
    return if end_at.blank? || start_at.blank?
    return if end_at > start_at

    errors.add(:end_at, '開始時間より後に設定してください')
  end
end
